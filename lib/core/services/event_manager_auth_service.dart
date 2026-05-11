// lib/core/services/event_manager_auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/dev.log.dart';

class EventManagerAuthService {
  static const String _keyLoggedIn = 'event_manager_logged_in';
  static const String _keyEmail = 'event_manager_email';
  static const String _keyUid = 'event_manager_uid';
  static const String _keyName = 'event_manager_name';
  static const String _allowedDomain = '@pmlil.com';

  // ---------------------------------------------------------------------------
  // Session check — called from splash_screen
  // ---------------------------------------------------------------------------

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final localFlag = prefs.getBool(_keyLoggedIn) ?? false;
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (localFlag && firebaseUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          return data['role'] == 'event_manager' &&
              data['status'] == 'active';
        }
      } catch (e) {
        devLog(
          'EventManagerAuthService.isLoggedIn error',
          params: {'error': e.toString()},
        );
      }
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  static Future<Map<String, String>> login(
      String email,
      String password,
      ) async {
    try {
      if (!email.trim().toLowerCase().endsWith(_allowedDomain)) {
        throw Exception('Only $_allowedDomain emails are allowed');
      }

      devLog(
        'EventManagerAuthService.login attempt',
        params: {'email': email},
      );

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

      final data = doc.data()!;

      if (data['role'] != 'event_manager') {
        await FirebaseAuth.instance.signOut();
        throw Exception('This account is not authorized as Event Manager');
      }

      if (data['status'] != 'active') {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account is inactive. Contact administrator');
      }

      final uid = cred.user!.uid;
      final name = data['name'] as String? ?? 'Event Manager';

      await _setSession(
        loggedIn: true,
        email: email.trim(),
        uid: uid,
        name: name,
      );

      devLog(
        'EventManagerAuthService.login success',
        params: {'uid': uid},
      );

      return {'uid': uid, 'name': name, 'email': email.trim()};
    } catch (e) {
      devLog(
        'EventManagerAuthService.login error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _clearSession();
    devLog('EventManagerAuthService.signOut');
  }

  // ---------------------------------------------------------------------------
  // Getters for cached session data
  // ---------------------------------------------------------------------------

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUid);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static Future<void> _setSession({
    required bool loggedIn,
    required String email,
    required String uid,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, loggedIn);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyUid, uid);
    await prefs.setString(_keyName, name);
  }

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUid);
    await prefs.remove(_keyName);
  }
}