// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:pass_point/core/utils/dev.log.dart';
//
// import '../../../core/services/auth_service.dart';
// import '../../../core/theme/app_theme.dart';
//
// class AdminLoginScreen extends StatefulWidget {
//   const AdminLoginScreen({super.key});
//
//   @override
//   State<AdminLoginScreen> createState() => _AdminLoginScreenState();
// }
//
// class _AdminLoginScreenState extends State<AdminLoginScreen> {
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
//       devLog('Admin Sign In Attempt', params: {'email': _emailController.text});
//       final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );
//       devLog('Admin signed in successfully', params: {'uid': cred.user?.uid});
//
//       await AuthService.setLoggedIn(true);
//
//       if (mounted) {
//         Navigator.of(context).pushReplacementNamed('/home');
//       }
//     } on FirebaseAuthException catch (e) {
//       String message;
//       if (e.code == 'user-not-found' || e.code == 'wrong-password') {
//         message = 'Invalid credentials. Please check your email and password';
//       } else {
//         message = 'Login failed: ${e.message}';
//       }
//       devLog('Admin Login failed', params: {'code': e.code, 'msg': e.message});
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message), backgroundColor: AppTheme.error),
//         );
//       }
//     } catch (e) {
//       devLog('Admin Login Error', params: {'error': e.toString()});
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
//                       // Back to Home Button
//                       const SizedBox(height: 40),
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
//                                   color: AppTheme.dark,
//                                   borderRadius: AppTheme.radiusMedium,
//                                 ),
//                                 child: const Icon(
//                                   Icons.shield_outlined,
//                                   color: AppTheme.white,
//                                   size: 40,
//                                 ),
//                               ),
//
//                               const SizedBox(height: 24),
//
//                               // Title
//                               const Text('Admin Login', style: AppTheme.h2),
//
//                               const SizedBox(height: 8),
//
//                               // Subtitle
//                               const Text(
//                                 'Access the admin dashboard',
//                                 style: AppTheme.bodyMedium,
//                                 textAlign: TextAlign.center,
//                               ),
//
//                               const SizedBox(height: 32),
//
//                               // Username Field
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.person_outline,
//                                         size: 18,
//                                         color: AppTheme.textSecondary,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       const Text(
//                                         'Username',
//                                         style: AppTheme.labelLarge,
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   TextField(
//                                     controller: _emailController,
//                                     keyboardType: TextInputType.emailAddress,
//                                     decoration: InputDecoration(
//                                       hintText: 'Enter your username',
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
//                               const SizedBox(height: 24),
//
//                               // Demo Credentials Box
//                               // Container(
//                               //   padding: const EdgeInsets.all(16),
//                               //   decoration: BoxDecoration(
//                               //     color: AppTheme.greyLight,
//                               //     borderRadius: AppTheme.radiusSmall,
//                               //   ),
//                               //   child: Column(
//                               //     crossAxisAlignment: CrossAxisAlignment.start,
//                               //     children: [
//                               //       const Text(
//                               //         'Demo Credentials:',
//                               //         style: AppTheme.labelMedium,
//                               //       ),
//                               //       const SizedBox(height: 8),
//                               //       Text(
//                               //         'Username: admin@gmail.com',
//                               //         style: AppTheme.bodySmall.copyWith(
//                               //           fontFamily: 'monospace',
//                               //         ),
//                               //       ),
//                               //       Text(
//                               //         'Password: admin.login',
//                               //         style: AppTheme.bodySmall.copyWith(
//                               //           fontFamily: 'monospace',
//                               //         ),
//                               //       ),
//                               //     ],
//                               //   ),
//                               // ),
//
//                               // const SizedBox(height: 24),
//
//                               // Login Button
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 50,
//                                 child: ElevatedButton(
//                                   onPressed: _loading ? null : _signIn,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppTheme.dark,
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
//                                             const Icon(
//                                               Icons.shield_outlined,
//                                               size: 20,
//                                             ),
//                                             const SizedBox(width: 8),
//                                             const Text(
//                                               'Login to Admin Dashboard',
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
