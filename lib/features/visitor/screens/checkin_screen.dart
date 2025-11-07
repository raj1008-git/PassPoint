import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/utils/dev.log.dart';
import '../../../data/repositories/visitor_repository.dart'; // Import the Repository
import '../../visitor/widgets/checkin_form.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  // This function acts as the final handler, connecting the UI to the Repository
  Future<void> _handleSubmit({
    required BuildContext context,
    required String name,
    required String phone,
    String? email,
    required String toMeet,
    required String purpose,
    required File photoFile,
    // NEW: optional department fields
    String? departmentId,
    String? departmentName,
  }) async {
    // 1. Instantiate the Repository (we rely on the defaults here)
    final repo = VisitorRepository();

    try {
      devLog(
        'Starting createVisitor flow',
        params: {'name': name, 'department': departmentName},
      );

      // 2. Call the repository method to handle the business logic (Upload + Firestore Save)
      await repo.createVisitor(
        name: name,
        phone: phone,
        email: email,
        toMeet: toMeet,
        purpose: purpose,
        photoFile: photoFile,
        departmentId: departmentId,
        departmentName: departmentName,
      );

      devLog('Visitor created, showing confirmation');

      // 3. Show success confirmation to the visitor
      await showDialog(
        context: context,
        barrierDismissible: false, // Visitor must press OK to proceed
        builder: (context) => AlertDialog(
          title: const Text('Check request submitted successfully'),
          content: const Text(
            'Please wait — reception will verify your details.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Closes the dialog
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // 4. Pop back to the home screen after the dialog is closed
      Navigator.of(context).pop();
    } catch (e) {
      devLog('Error in _handleSubmit', params: {'error': e.toString()});
      // The form widget handles showing the Snackbar error message, but we rethrow for logging purposes.
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visitor Check-In')),
      // The screen passes the core submission logic down to the form widget
      body: CheckInForm(
        onSubmit:
            ({
              required String name,
              required String phone,
              String? email,
              required String toMeet,
              required String purpose,
              required File photoFile,
              String? departmentId,
              String? departmentName,
            }) async {
              // Pass all arguments directly to our handler function
              await _handleSubmit(
                context: context,
                name: name,
                phone: phone,
                email: email,
                toMeet: toMeet,
                purpose: purpose,
                photoFile: photoFile,
                departmentId: departmentId,
                departmentName: departmentName,
              );
            },
      ),
    );
  }
}
