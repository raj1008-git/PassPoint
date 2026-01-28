// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../utils/dev.log.dart';
//
// class AuthService {
//   static const String _keyLoggedIn = 'is_logged_in';
//
//   static Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     final localFlag = prefs.getBool(_keyLoggedIn) ?? false;
//     final firebaseUser = FirebaseAuth.instance.currentUser;
//
//     final result = localFlag && firebaseUser != null;
//     devLog('AuthService.isLoggedIn check', params: {'result': result});
//     return result;
//   }
//
//   static Future<void> setLoggedIn(bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyLoggedIn, value);
//     devLog('AuthService.setLoggedIn', params: {'value': value});
//   }
//
//   static Future<void> signOut() async {
//     await FirebaseAuth.instance.signOut();
//     await setLoggedIn(false);
//     devLog('AuthService.signOut completed');
//   }
// }
