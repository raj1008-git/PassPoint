import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';
import '../utils/dev.log.dart';

class StaffAuthService {
  static const String _keyLoggedIn = 'staff_logged_in';
  static const String _keyPhone = 'staff_phone';
  static const String _keyEmail =
      'staff_email'; // Keep for backward compatibility

  // Check if staff is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final localFlag = prefs.getBool(_keyLoggedIn) ?? false;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (localFlag && firebaseUser != null) {
      // Verify user is actually a staff member and is active
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
      // Store phone number primarily, email as fallback
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

  // Register new staff (phone-based, email optional)
  static Future<UserModel> register({
    required String name,
    required String phoneNumber,
    String? email, // OPTIONAL now
    required String password,
    required String branchId,
    required String branchName,
    String? departmentId, // Only for HQ staff
    String? departmentName, // Only for HQ staff
  }) async {
    try {
      devLog(
        'Staff registration attempt',
        params: {'phone': phoneNumber, 'name': name, 'branch': branchName},
      );

      // Create a unique email if not provided (for Firebase Auth requirement)
      final authEmail = email ?? '${phoneNumber}@staff.pmlil.internal';

      // Create Firebase Auth account
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      if (cred.user == null) {
        throw Exception('Registration failed');
      }

      // Determine status: HQ staff approved by receptionist, Branch staff approved by HQ staff
      final isPendingApproval = true; // All new registrations need approval

      // Create user document in Firestore
      final userData = UserModel(
        uid: cred.user!.uid,
        name: name.trim(),
        email: email?.trim(), // Store actual email if provided, else null
        phoneNumber: phoneNumber.trim(),
        role: 'staff',
        branchId: branchId,
        branchName: branchName,
        departmentId: departmentId,
        departmentName: departmentName,
        status: isPendingApproval ? 'pending' : 'active',
        createdAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set(userData.toMap());

      // Sign out immediately - staff cannot login until approved
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

  // Login with phone number + password (PRIMARY METHOD)
  static Future<UserModel> loginWithPhone(
    String phoneNumber,
    String password,
  ) async {
    try {
      devLog('Staff login attempt (phone)', params: {'phone': phoneNumber});

      // Find user by phone number
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

      // Get the auth email (could be real email or generated one)
      final authEmail = userData.email ?? '${phoneNumber}@staff.pmlil.internal';

      // Sign in with Firebase Auth
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      if (cred.user == null) {
        throw Exception('Login failed');
      }

      // Verify it's the correct user
      if (cred.user!.uid != userData.uid) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account mismatch');
      }

      // Check if pending
      if (userData.isPending) {
        await FirebaseAuth.instance.signOut();
        throw Exception(
          'Your account is pending approval. Please contact the receptionist.',
        );
      }

      // Check if active
      if (!userData.isActive) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account is not active');
      }

      // Set persistent login
      await setLoggedIn(true, phoneNumber.trim());

      devLog('Staff logged in successfully', params: {'uid': cred.user!.uid});
      return userData;
    } catch (e) {
      devLog('Staff login error', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Login with email + password (FALLBACK for old users)
  static Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      devLog('Staff login attempt (email)', params: {'email': email});

      // Sign in with Firebase
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (cred.user == null) {
        throw Exception('Login failed');
      }

      // Get user data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception('User account not found');
      }

      final userData = UserModel.fromMap(doc.data()!);

      // Check if staff
      if (!userData.isStaff) {
        await FirebaseAuth.instance.signOut();
        throw Exception('This account is not a staff account');
      }

      // Check if pending
      if (userData.isPending) {
        await FirebaseAuth.instance.signOut();
        throw Exception(
          'Your account is pending approval. Please contact the receptionist.',
        );
      }

      // Check if active
      if (!userData.isActive) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account is not active');
      }

      // Set persistent login
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
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
      devLog('Staff password changed successfully');
    } catch (e) {
      devLog('Password change failed', params: {'error': e.toString()});
      rethrow;
    }
  }
}
