import 'dart:convert';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../utils/dev.log.dart';

class MicrosoftAuthService {
  // Using Microsoft's common endpoint - works for any Microsoft account
  static const String _clientId =
      '872cd9fa-d31f-45e0-9eab-6e460a02d1f1'; // Microsoft's demo client ID
  static const String _redirectUri = 'msauth://com.pmlil.passpoint/auth';

  /// Authenticate user with Microsoft using device code flow
  static Future<Map<String, dynamic>?> signInWithMicrosoft() async {
    try {
      devLog('Starting Microsoft authentication (simplified flow)');

      // Build authorization URL - uses common endpoint
      final authUrl = Uri.https(
        'login.microsoftonline.com',
        '/common/oauth2/v2.0/authorize',
        {
          'client_id': _clientId,
          'response_type': 'token id_token',
          'redirect_uri': _redirectUri,
          'response_mode': 'fragment',
          'scope': 'openid email profile User.Read',
          'prompt': 'select_account',
          'nonce': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      devLog('Opening Microsoft login');

      // Open browser for authentication
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'msauth',
      );

      devLog('Auth result received', params: {'result': result});

      // Extract tokens from URL fragment
      final fragment = Uri.parse(result).fragment;
      final params = Uri.splitQueryString(fragment);

      final idToken = params['id_token'];
      final accessToken = params['access_token'];

      if (idToken == null || accessToken == null) {
        devLog('No tokens received from Microsoft');
        return null;
      }

      devLog('Tokens received, decoding user info');

      // Decode ID token to get user info (JWT token)
      final userInfo = _decodeJwtPayload(idToken);

      if (userInfo == null) {
        devLog('Failed to decode ID token');
        return null;
      }

      final email = (userInfo['email'] ?? userInfo['preferred_username'] ?? '')
          .toString()
          .toLowerCase();
      final name = userInfo['name'] ?? 'Unknown User';

      devLog('User authenticated', params: {'email': email, 'name': name});

      return {
        'id': userInfo['oid'] ?? userInfo['sub'],
        'email': email,
        'name': name,
        'accessToken': accessToken,
      };
    } catch (e, stackTrace) {
      devLog(
        'Microsoft auth error',
        params: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
      );
      return null;
    }
  }

  /// Decode JWT token payload
  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      var decoded = utf8.decode(base64Url.decode(normalized));

      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      devLog('JWT decode error', params: {'error': e.toString()});
      return null;
    }
  }

  /// Validate if email is from @pmlil.com domain
  static bool isValidPmilDomain(String email) {
    return email.toLowerCase().endsWith('@pmlil.com');
  }

  /// Check if email is a receptionist email
  /// Check if email is a receptionist email
  static bool isReceptionistEmail(String email) {
    final receptionistEmails = [
      'reshma.pandey@pmlil.com',
      'arnisha.adhikari@pmlil.com',
      'meeting@pmlil.com', // NEW
    ];
    return receptionistEmails.contains(email.toLowerCase());
  }
}
