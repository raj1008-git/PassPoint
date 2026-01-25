import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dev.log.dart';

class AuthService {
  static const String _keyLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserId = 'user_id';
  static const String _keyAccessToken = 'access_token';

  /// Check if receptionist is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final localFlag = prefs.getBool(_keyLoggedIn) ?? false;
    final email = prefs.getString(_keyUserEmail);

    final result = localFlag && email != null;
    devLog('AuthService.isLoggedIn check', params: {'result': result});
    return result;
  }

  /// Save receptionist login state
  static Future<void> setLoggedIn(
    bool value, {
    String? email,
    String? name,
    String? userId,
    String? accessToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);

    if (value && email != null) {
      await prefs.setString(_keyUserEmail, email);
      if (name != null) await prefs.setString(_keyUserName, name);
      if (userId != null) await prefs.setString(_keyUserId, userId);
      if (accessToken != null)
        await prefs.setString(_keyAccessToken, accessToken);
    } else {
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyAccessToken);
    }

    devLog('AuthService.setLoggedIn', params: {'value': value, 'email': email});
  }

  /// Get receptionist email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  /// Get receptionist name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Sign out receptionist
  static Future<void> signOut() async {
    await setLoggedIn(false);
    devLog('AuthService.signOut completed');
  }
}
