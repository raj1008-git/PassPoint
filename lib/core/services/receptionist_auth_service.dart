import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_model.dart';
import '../utils/dev.log.dart';

class ReceptionistAuthService {
  static const String _keyLoggedIn = 'receptionist_logged_in';
  static const String _keyEmail = 'receptionist_email';
  static const String _allowedDomain = '@pmlil.com';

  // Check if receptionist is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final localFlag = prefs.getBool(_keyLoggedIn) ?? false;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (localFlag && firebaseUser != null) {
      // Verify user is actually a receptionist
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        final userData = UserModel.fromMap(doc.data()!);
        return userData.isReceptionist && userData.isActive;
      }
    }

    return false;
  }

  // Set logged in state
  static Future<void> setLoggedIn(bool value, String? email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
    if (email != null) {
      await prefs.setString(_keyEmail, email);
    } else {
      await prefs.remove(_keyEmail);
    }
    devLog('ReceptionistAuthService.setLoggedIn', params: {'value': value});
  }

  // Get stored email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  // Validate email domain
  static bool isValidEmail(String email) {
    final trimmed = email.trim().toLowerCase();
    return trimmed.endsWith(_allowedDomain);
  }

  // Login
  static Future<UserModel> login(String email, String password) async {
    try {
      // Validate domain
      if (!isValidEmail(email)) {
        throw Exception('Only $_allowedDomain emails are allowed');
      }

      devLog('Receptionist login attempt', params: {'email': email});

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
        // User doesn't exist in Firestore, sign out
        await FirebaseAuth.instance.signOut();
        throw Exception('User account not found');
      }

      final userData = UserModel.fromMap(doc.data()!);

      // Check if receptionist
      if (!userData.isReceptionist) {
        await FirebaseAuth.instance.signOut();
        throw Exception('This account is not authorized as receptionist');
      }

      // Check if active
      if (!userData.isActive) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account is not active');
      }

      // Set persistent login
      await setLoggedIn(true, email.trim());

      devLog(
        'Receptionist logged in successfully',
        params: {'uid': cred.user!.uid},
      );
      return userData;
    } catch (e) {
      devLog('Receptionist login error', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await setLoggedIn(false, null);
    devLog('Receptionist signed out');
  }

  // Get current receptionist profile
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
      devLog(
        'Error fetching receptionist profile',
        params: {'error': e.toString()},
      );
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
      devLog('Receptionist password changed successfully');
    } catch (e) {
      devLog('Password change failed', params: {'error': e.toString()});
      rethrow;
    }
  }
}
