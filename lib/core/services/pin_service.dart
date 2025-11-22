import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/dev.log.dart';

class PinService {
  static const String _defaultPin = '123';

  static Future<String> getAdminPin() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('admin_pin')
          .get();

      devLog('Firebase document exists: ${doc.exists}');

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        devLog('Full document data', params: data);

        if (data.containsKey('pin')) {
          final pin = data['pin'];
          devLog(
            'Raw pin value',
            params: {'pin': pin, 'type': pin.runtimeType.toString()},
          );

          if (pin != null) {
            // Handle both String and int types
            String pinString;
            if (pin is String) {
              pinString = pin.trim();
            } else if (pin is int) {
              pinString = pin.toString();
            } else {
              pinString = pin.toString().trim();
            }

            // Remove any quotes that might be in the string
            pinString = pinString.replaceAll('"', '').replaceAll("'", '');

            if (pinString.isNotEmpty) {
              devLog('Final PIN to use', params: {'pin': pinString});
              return pinString;
            }
          }
        } else {
          devLog('pin field does not exist in document');
        }
      } else {
        devLog('Document does not exist or has no data');
      }

      devLog('Falling back to default PIN: $_defaultPin');
      return _defaultPin;
    } catch (e, stackTrace) {
      devLog(
        'Error fetching PIN',
        params: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
      );
      return _defaultPin;
    }
  }

  static Future<bool> verifyPin(String enteredPin) async {
    final correctPin = await getAdminPin();
    final enteredTrimmed = enteredPin.trim();
    final isValid = enteredTrimmed == correctPin;

    devLog('=== PIN VERIFICATION ===');
    devLog('Entered PIN: "$enteredTrimmed" (length: ${enteredTrimmed.length})');
    devLog('Correct PIN: "$correctPin" (length: ${correctPin.length})');
    devLog('Match: $isValid');
    devLog('=======================');

    return isValid;
  }
}
