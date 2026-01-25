import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dev.log.dart';

class StaffService {
  static const String _keyStaffLoggedIn = 'is_staff_logged_in';
  static const String _keyStaffEmail = 'staff_email';
  static const String _keyStaffName = 'staff_name';
  static const String _keyStaffId = 'staff_id';
  static const String _keyStaffDepartmentId = 'staff_department_id';
  static const String _keyStaffDepartmentName = 'staff_department_name';
  static const String _keyAccessToken = 'staff_access_token';

  /// Check if staff is logged in
  static Future<bool> isStaffLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final localFlag = prefs.getBool(_keyStaffLoggedIn) ?? false;
    final email = prefs.getString(_keyStaffEmail);

    if (localFlag && email != null) {
      // Verify staff still exists in Firestore
      try {
        final staffId = prefs.getString(_keyStaffId);
        if (staffId == null) return false;

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(staffId)
            .get();

        if (doc.exists) {
          final role = doc.data()?['role'] as String?;
          return role == 'staff';
        }
      } catch (e) {
        devLog('Error checking staff status', params: {'error': e.toString()});
      }
    }

    return false;
  }

  /// Save staff login state
  static Future<void> setStaffLoggedIn(
    bool value, {
    String? email,
    String? name,
    String? userId,
    String? departmentId,
    String? departmentName,
    String? accessToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStaffLoggedIn, value);

    if (value && email != null) {
      await prefs.setString(_keyStaffEmail, email);
      if (name != null) await prefs.setString(_keyStaffName, name);
      if (userId != null) await prefs.setString(_keyStaffId, userId);
      if (departmentId != null) {
        await prefs.setString(_keyStaffDepartmentId, departmentId);
      }
      if (departmentName != null) {
        await prefs.setString(_keyStaffDepartmentName, departmentName);
      }
      if (accessToken != null) {
        await prefs.setString(_keyAccessToken, accessToken);
      }
    } else {
      await prefs.remove(_keyStaffEmail);
      await prefs.remove(_keyStaffName);
      await prefs.remove(_keyStaffId);
      await prefs.remove(_keyStaffDepartmentId);
      await prefs.remove(_keyStaffDepartmentName);
      await prefs.remove(_keyAccessToken);
    }

    devLog('StaffService.setStaffLoggedIn', params: {'value': value});
  }

  /// Get staff email
  static Future<String?> getStaffEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStaffEmail);
  }

  /// Get staff name
  static Future<String?> getStaffName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStaffName);
  }

  /// Get staff profile from Firestore
  static Future<Map<String, dynamic>?> getStaffProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final staffId = prefs.getString(_keyStaffId);

      if (staffId == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(staffId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      devLog('Error fetching staff profile', params: {'error': e.toString()});
    }
    return null;
  }

  /// Sign out staff
  static Future<void> signOut() async {
    await setStaffLoggedIn(false);
    devLog('StaffService.signOut completed');
  }

  /// Register new staff member in Firestore
  static Future<bool> registerStaff({
    required String microsoftId,
    required String email,
    required String name,
    required String departmentId,
    required String departmentName,
  }) async {
    try {
      devLog(
        'Registering staff member',
        params: {'email': email, 'department': departmentName},
      );

      // Check if already registered
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        devLog('Staff already registered');
        return false;
      }

      // Create new staff document
      final docRef = FirebaseFirestore.instance.collection('users').doc();

      await docRef.set({
        'uid': docRef.id,
        'microsoftId': microsoftId,
        'email': email,
        'name': name,
        'role': 'staff',
        'departmentId': departmentId,
        'departmentName': departmentName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      devLog('Staff registered successfully', params: {'id': docRef.id});
      return true;
    } catch (e) {
      devLog('Staff registration failed', params: {'error': e.toString()});
      return false;
    }
  }

  /// Check if staff is already registered
  static Future<Map<String, dynamic>?> getStaffByEmail(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'staff')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return data;
      }
    } catch (e) {
      devLog('Error getting staff by email', params: {'error': e.toString()});
    }
    return null;
  }
}
