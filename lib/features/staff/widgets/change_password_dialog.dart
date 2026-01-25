// import 'package:flutter/material.dart';
//
// import '../../../core/services/staff_service.dart';
// import '../../../core/theme/app_theme.dart';
//
// class ChangePasswordDialog extends StatefulWidget {
//   const ChangePasswordDialog({Key? key}) : super(key: key);
//
//   @override
//   State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
// }
//
// class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
//   final _currentPasswordController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _obscureCurrent = true;
//   bool _obscureNew = true;
//   bool _obscureConfirm = true;
//   bool _loading = false;
//
//   @override
//   void dispose() {
//     _currentPasswordController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _changePassword() async {
//     final current = _currentPasswordController.text.trim();
//     final newPass = _newPasswordController.text.trim();
//     final confirm = _confirmPasswordController.text.trim();
//
//     if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all fields'),
//           backgroundColor: AppTheme.error,
//         ),
//       );
//       return;
//     }
//
//     if (newPass.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('New password must be at least 6 characters'),
//           backgroundColor: AppTheme.error,
//         ),
//       );
//       return;
//     }
//
//     if (newPass != confirm) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('New passwords do not match'),
//           backgroundColor: AppTheme.error,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _loading = true);
//
//     try {
//       await StaffService.changePassword(current, newPass);
//
//       if (mounted) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Password changed successfully!'),
//             backgroundColor: AppTheme.success,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to change password: ${e.toString()}'),
//             backgroundColor: AppTheme.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 400),
//         child: SingleChildScrollView(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(32),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Icon
//                 Container(
//                   width: 64,
//                   height: 64,
//                   decoration: BoxDecoration(
//                     color: AppTheme.info.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: const Icon(
//                     Icons.lock_reset,
//                     size: 32,
//                     color: AppTheme.info,
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Title
//                 const Text(
//                   'Change Password',
//                   style: AppTheme.h3,
//                   textAlign: TextAlign.center,
//                 ),
//
//                 const SizedBox(height: 8),
//
//                 // Subtitle
//                 Text(
//                   'Enter your current password and new password',
//                   style: AppTheme.bodyMedium.copyWith(
//                     color: AppTheme.textSecondary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 const SizedBox(height: 32),
//
//                 // Current Password
//                 TextField(
//                   controller: _currentPasswordController,
//                   obscureText: _obscureCurrent,
//                   decoration: InputDecoration(
//                     labelText: 'Current Password',
//                     hintText: 'Enter current password',
//                     hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
//                     filled: true,
//                     fillColor: AppTheme.greyLight.withOpacity(0.5),
//                     border: OutlineInputBorder(
//                       borderRadius: AppTheme.radiusSmall,
//                       borderSide: BorderSide.none,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureCurrent
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                         color: AppTheme.grey,
//                       ),
//                       onPressed: () {
//                         setState(() => _obscureCurrent = !_obscureCurrent);
//                       },
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // New Password
//                 TextField(
//                   controller: _newPasswordController,
//                   obscureText: _obscureNew,
//                   decoration: InputDecoration(
//                     labelText: 'New Password',
//                     hintText: 'Enter new password (min 6 chars)',
//                     hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
//                     filled: true,
//                     fillColor: AppTheme.greyLight.withOpacity(0.5),
//                     border: OutlineInputBorder(
//                       borderRadius: AppTheme.radiusSmall,
//                       borderSide: BorderSide.none,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureNew
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                         color: AppTheme.grey,
//                       ),
//                       onPressed: () {
//                         setState(() => _obscureNew = !_obscureNew);
//                       },
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Confirm Password
//                 TextField(
//                   controller: _confirmPasswordController,
//                   obscureText: _obscureConfirm,
//                   decoration: InputDecoration(
//                     labelText: 'Confirm New Password',
//                     hintText: 'Re-enter new password',
//                     hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
//                     filled: true,
//                     fillColor: AppTheme.greyLight.withOpacity(0.5),
//                     border: OutlineInputBorder(
//                       borderRadius: AppTheme.radiusSmall,
//                       borderSide: BorderSide.none,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureConfirm
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                         color: AppTheme.grey,
//                       ),
//                       onPressed: () {
//                         setState(() => _obscureConfirm = !_obscureConfirm);
//                       },
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: _loading
//                             ? null
//                             : () => Navigator.of(context).pop(),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: AppTheme.dark,
//                           side: const BorderSide(color: AppTheme.greyLight),
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: AppTheme.radiusSmall,
//                           ),
//                         ),
//                         child: const Text('Cancel'),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: _loading ? null : _changePassword,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.info,
//                           foregroundColor: AppTheme.white,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: AppTheme.radiusSmall,
//                           ),
//                           elevation: 0,
//                         ),
//                         child: _loading
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   color: AppTheme.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text('Change Password'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
