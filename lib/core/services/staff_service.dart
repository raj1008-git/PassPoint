import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dev.log.dart';

class StaffService {
  static const String _keyStaffLoggedIn = 'is_staff_logged_in';
  static const String _keyStaffEmail = 'staff_email';

  static Future<bool> isStaffLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final localFlag = prefs.getBool(_keyStaffLoggedIn) ?? false;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (localFlag && firebaseUser != null) {
      // Verify user is actually a staff member
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        return role == 'staff';
      }
    }

    return false;
  }

  static Future<void> setStaffLoggedIn(bool value, String? email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStaffLoggedIn, value);
    if (email != null) {
      await prefs.setString(_keyStaffEmail, email);
    } else {
      await prefs.remove(_keyStaffEmail);
    }
    devLog('StaffService.setStaffLoggedIn', params: {'value': value});
  }

  static Future<String?> getStaffEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStaffEmail);
  }

  static Future<Map<String, dynamic>?> getStaffProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      devLog('Error fetching staff profile', params: {'error': e.toString()});
    }
    return null;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await setStaffLoggedIn(false, null);
    devLog('StaffService.signOut completed');
  }

  static Future<void> changePassword(String currentPassword, String newPassword) async {
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
      devLog('Password changed successfully');
    } catch (e) {
      devLog('Password change failed', params: {'error': e.toString()});
      rethrow;
    }
  }
}