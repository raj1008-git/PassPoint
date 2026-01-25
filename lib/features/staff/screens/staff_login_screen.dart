// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../../../core/services/staff_service.dart';
// import '../../../core/theme/app_theme.dart';
// import '../../../core/utils/dev.log.dart';
//
// class StaffLoginScreen extends StatefulWidget {
//   const StaffLoginScreen({super.key});
//
//   @override
//   State<StaffLoginScreen> createState() => _StaffLoginScreenState();
// }
//
// class _StaffLoginScreenState extends State<StaffLoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;
//   bool _obscurePassword = true;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _signIn() async {
//     if (_emailController.text.trim().isEmpty ||
//         _passwordController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter both email and password'),
//           backgroundColor: AppTheme.error,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _loading = true);
//
//     try {
//       devLog('Staff Sign In Attempt', params: {'email': _emailController.text});
//
//       // Sign in with Firebase
//       final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );
//
//       devLog('Staff signed in', params: {'uid': cred.user?.uid});
//
//       // Verify user is a staff member
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(cred.user!.uid)
//           .get();
//
//       if (!doc.exists || doc.data()?['role'] != 'staff') {
//         // Not a staff member
//         await FirebaseAuth.instance.signOut();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Invalid staff credentials'),
//               backgroundColor: AppTheme.error,
//             ),
//           );
//         }
//         setState(() => _loading = false);
//         return;
//       }
//
//       await StaffService.setStaffLoggedIn(true, _emailController.text.trim());
//
//       if (mounted) {
//         Navigator.of(context).pushReplacementNamed('/staff-dashboard');
//       }
//     } on FirebaseAuthException catch (e) {
//       String message;
//       if (e.code == 'user-not-found' || e.code == 'wrong-password') {
//         message = 'Invalid credentials. Please check your email and password';
//       } else {
//         message = 'Login failed: ${e.message}';
//       }
//       devLog('Staff Login failed', params: {'code': e.code, 'msg': e.message});
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message), backgroundColor: AppTheme.error),
//         );
//       }
//     } catch (e) {
//       devLog('Staff Login Error', params: {'error': e.toString()});
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('An unexpected error occurred: $e'),
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
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final isTablet = constraints.maxWidth > 600;
//             final maxWidth = isTablet ? 500.0 : constraints.maxWidth * 0.9;
//
//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isTablet ? 40 : 20,
//                     vertical: 40,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Back Button
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: TextButton.icon(
//                           onPressed: () => Navigator.of(context).pop(),
//                           icon: const Icon(Icons.arrow_back),
//                           label: const Text('Back to Home'),
//                           style: TextButton.styleFrom(
//                             foregroundColor: AppTheme.dark,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // Login Card
//                       Center(
//                         child: Container(
//                           width: maxWidth,
//                           padding: EdgeInsets.all(isTablet ? 48 : 32),
//                           decoration: BoxDecoration(
//                             color: AppTheme.white,
//                             borderRadius: AppTheme.radiusLarge,
//                             boxShadow: AppTheme.elevatedShadow,
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               // Icon
//                               Container(
//                                 width: 80,
//                                 height: 80,
//                                 decoration: BoxDecoration(
//                                   color: AppTheme.info,
//                                   borderRadius: AppTheme.radiusMedium,
//                                 ),
//                                 child: const Icon(
//                                   Icons.people_alt_outlined,
//                                   color: AppTheme.white,
//                                   size: 40,
//                                 ),
//                               ),
//
//                               const SizedBox(height: 24),
//
//                               // Title
//                               const Text('Staff Login', style: AppTheme.h2),
//
//                               const SizedBox(height: 8),
//
//                               // Subtitle
//                               const Text(
//                                 'Access your visitor dashboard',
//                                 style: AppTheme.bodyMedium,
//                                 textAlign: TextAlign.center,
//                               ),
//
//                               const SizedBox(height: 32),
//
//                               // Email Field
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.email_outlined,
//                                         size: 18,
//                                         color: AppTheme.textSecondary,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       const Text(
//                                         'Email Address',
//                                         style: AppTheme.labelLarge,
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   TextField(
//                                     controller: _emailController,
//                                     keyboardType: TextInputType.emailAddress,
//                                     decoration: InputDecoration(
//                                       hintText: 'Enter your email',
//                                       hintStyle: TextStyle(
//                                         color: AppTheme.grey.withOpacity(0.5),
//                                       ),
//                                       filled: true,
//                                       fillColor: AppTheme.greyLight,
//                                       border: OutlineInputBorder(
//                                         borderRadius: AppTheme.radiusSmall,
//                                         borderSide: BorderSide.none,
//                                       ),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                             horizontal: 16,
//                                             vertical: 14,
//                                           ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 20),
//
//                               // Password Field
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.lock_outline,
//                                         size: 18,
//                                         color: AppTheme.textSecondary,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       const Text(
//                                         'Password',
//                                         style: AppTheme.labelLarge,
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   TextField(
//                                     controller: _passwordController,
//                                     obscureText: _obscurePassword,
//                                     decoration: InputDecoration(
//                                       hintText: 'Enter your password',
//                                       hintStyle: TextStyle(
//                                         color: AppTheme.grey.withOpacity(0.5),
//                                       ),
//                                       filled: true,
//                                       fillColor: AppTheme.greyLight,
//                                       border: OutlineInputBorder(
//                                         borderRadius: AppTheme.radiusSmall,
//                                         borderSide: BorderSide.none,
//                                       ),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                             horizontal: 16,
//                                             vertical: 14,
//                                           ),
//                                       suffixIcon: IconButton(
//                                         icon: Icon(
//                                           _obscurePassword
//                                               ? Icons.visibility_off_outlined
//                                               : Icons.visibility_outlined,
//                                           color: AppTheme.grey,
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             _obscurePassword =
//                                                 !_obscurePassword;
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                     onSubmitted: (_) => _signIn(),
//                                   ),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 32),
//
//                               // Login Button
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 50,
//                                 child: ElevatedButton(
//                                   onPressed: _loading ? null : _signIn,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppTheme.info,
//                                     foregroundColor: AppTheme.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: AppTheme.radiusSmall,
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   child: _loading
//                                       ? const SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             color: AppTheme.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                       : Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             const Icon(Icons.login, size: 20),
//                                             const SizedBox(width: 8),
//                                             const Text(
//                                               'Login to Dashboard',
//                                               style: TextStyle(
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
