import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';
import '../utils/dev.log.dart';

class StaffAuthService {
  static const String _keyLoggedIn = 'staff_logged_in';
  static const String _keyPhone = 'staff_phone';
  static const String _keyEmail = 'staff_email';

  // Check if staff is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final localFlag = prefs.getBool(_keyLoggedIn) ?? false;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (localFlag && firebaseUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        final userData = UserModel.fromMap(doc.data()!);
        return userData.isStaff && userData.isActive;
      }
    }

    return false;
  }

  // Set logged in state
  static Future<void> setLoggedIn(bool value, String? identifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
    if (identifier != null) {
      if (identifier.contains('@')) {
        await prefs.setString(_keyEmail, identifier);
      } else {
        await prefs.setString(_keyPhone, identifier);
      }
    } else {
      await prefs.remove(_keyPhone);
      await prefs.remove(_keyEmail);
    }
    devLog('StaffAuthService.setLoggedIn', params: {'value': value});
  }

  // Get stored phone
  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }

  // Get stored email (backward compatibility)
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NEW: Check if a phone number already has a registered Firestore account.
  // Used by the first-time setup flow.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<bool> isPhoneAlreadyRegistered(String phone) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: phone.trim())
        .where('role', isEqualTo: 'staff')
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NEW: Register staff from API data — status is 'active' immediately
  // (no approval needed since identity is verified via the company API).
  // Called by the first-time setup flow.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<UserModel> registerFromApi({
    required String name,
    required String phone,
    required String email, // always present from API
    required String password,
    required String branchId, // 'kamaladi' for HQ, branchCode for others
    required String branchName,
    String? departmentId,
    String? departmentName,
  }) async {
    try {
      devLog(
        'StaffAuthService.registerFromApi',
        params: {'phone': phone, 'name': name, 'branch': branchName},
      );

      // Use real pmlil.com email for Firebase Auth (it's always present from API)
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (cred.user == null) throw Exception('Registration failed');

      final userData = UserModel(
        uid: cred.user!.uid,
        name: name.trim(),
        email: email.trim(),
        phoneNumber: phone.trim(),
        role: 'staff',
        branchId: branchId,
        branchName: branchName,
        departmentId: departmentId,
        departmentName: departmentName,
        status: 'active', // ← active immediately, no approval needed
        createdAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set(userData.toMap());

      // DO NOT sign out — we want them logged in immediately after this
      devLog(
        'StaffAuthService.registerFromApi success',
        params: {'uid': cred.user!.uid},
      );
      return userData;
    } catch (e) {
      devLog(
        'StaffAuthService.registerFromApi error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Register (original — manual form, status: pending, unchanged)
  // ─────────────────────────────────────────────────────────────────────────
  static Future<UserModel> register({
    required String name,
    required String phoneNumber,
    String? email,
    required String password,
    required String branchId,
    required String branchName,
    String? departmentId,
    String? departmentName,
  }) async {
    try {
      devLog(
        'Staff registration attempt',
        params: {'phone': phoneNumber, 'name': name, 'branch': branchName},
      );

      final authEmail = email ?? '${phoneNumber}@staff.pmlil.internal';

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      if (cred.user == null) throw Exception('Registration failed');

      final userData = UserModel(
        uid: cred.user!.uid,
        name: name.trim(),
        email: email?.trim(),
        phoneNumber: phoneNumber.trim(),
        role: 'staff',
        branchId: branchId,
        branchName: branchName,
        departmentId: departmentId,
        departmentName: departmentName,
        status: 'pending',
        createdAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set(userData.toMap());

      // Sign out — pending approval
      await FirebaseAuth.instance.signOut();

      devLog(
        'Staff registered successfully',
        params: {'uid': cred.user!.uid, 'status': 'pending'},
      );
      return userData;
    } catch (e) {
      devLog('Staff registration error', params: {'error': e.toString()});
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Login with phone number + password
  // FIX: query field is 'phone' (matches Firestore schema), not 'phoneNumber'
  // ─────────────────────────────────────────────────────────────────────────
  static Future<UserModel> loginWithPhone(
    String phoneNumber,
    String password,
  ) async {
    try {
      devLog('Staff login attempt (phone)', params: {'phone': phoneNumber});

      // Query by 'phone' field (correct Firestore field name)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber.trim())
          .where('role', isEqualTo: 'staff')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No account found with this phone number');
      }

      final userDoc = querySnapshot.docs.first;
      final userData = UserModel.fromMap(userDoc.data());

      // Auth email: real pmlil email if present, else generated internal email
      final authEmail = userData.email ?? '${phoneNumber}@staff.pmlil.internal';

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      if (cred.user == null) throw Exception('Login failed');

      if (cred.user!.uid != userData.uid) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account mismatch');
      }

      if (userData.isPending) {
        await FirebaseAuth.instance.signOut();
        throw Exception(
          'Your account is pending approval. Please contact the receptionist.',
        );
      }

      if (!userData.isActive) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account is not active');
      }

      await setLoggedIn(true, phoneNumber.trim());

      devLog('Staff logged in successfully', params: {'uid': cred.user!.uid});
      return userData;
    } catch (e) {
      devLog('Staff login error', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Login with email + password (fallback for old users)
  static Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      devLog('Staff login attempt (email)', params: {'email': email});

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (cred.user == null) throw Exception('Login failed');

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception('User account not found');
      }

      final userData = UserModel.fromMap(doc.data()!);

      if (!userData.isStaff) {
        await FirebaseAuth.instance.signOut();
        throw Exception('This account is not a staff account');
      }

      if (userData.isPending) {
        await FirebaseAuth.instance.signOut();
        throw Exception(
          'Your account is pending approval. Please contact the receptionist.',
        );
      }

      if (!userData.isActive) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account is not active');
      }

      await setLoggedIn(true, email.trim());

      devLog('Staff logged in successfully', params: {'uid': cred.user!.uid});
      return userData;
    } catch (e) {
      devLog('Staff login error', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await setLoggedIn(false, null);
    devLog('Staff signed out');
  }

  // Get current staff profile
  static Future<UserModel?> getCurrentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      devLog('Error fetching staff profile', params: {'error': e.toString()});
    }
    return null;
  }

  // Change password
  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      devLog('Staff password changed successfully');
    } catch (e) {
      devLog('Password change failed', params: {'error': e.toString()});
      rethrow;
    }
  }
}
