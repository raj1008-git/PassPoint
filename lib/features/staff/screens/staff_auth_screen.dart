// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// //
// // import '../../../core/di/service_locator.dart';
// // import '../../../core/services/staff_auth_service.dart';
// // import '../../../core/theme/app_theme.dart';
// // import '../../../core/utils/dev.log.dart';
// // import '../../../data/local/models/staff_local_model.dart';
// //
// // class StaffAuthScreen extends StatefulWidget {
// //   const StaffAuthScreen({super.key});
// //
// //   @override
// //   State<StaffAuthScreen> createState() => _StaffAuthScreenState();
// // }
// //
// // class _StaffAuthScreenState extends State<StaffAuthScreen>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 2, vsync: this);
// //   }
// //
// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppTheme.background,
// //       body: SafeArea(
// //         child: LayoutBuilder(
// //           builder: (context, constraints) {
// //             final isTablet = constraints.maxWidth > 600;
// //             final maxWidth = isTablet ? 600.0 : constraints.maxWidth * 0.9;
// //
// //             return SingleChildScrollView(
// //               child: ConstrainedBox(
// //                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
// //                 child: Padding(
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: isTablet ? 40 : 20,
// //                     vertical: 40,
// //                   ),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Align(
// //                         alignment: Alignment.centerLeft,
// //                         child: TextButton.icon(
// //                           onPressed: () => Navigator.of(context).pop(),
// //                           icon: const Icon(Icons.arrow_back),
// //                           label: const Text('Back'),
// //                           style: TextButton.styleFrom(
// //                             foregroundColor: AppTheme.dark,
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       Center(
// //                         child: Container(
// //                           width: maxWidth,
// //                           padding: EdgeInsets.all(isTablet ? 48 : 32),
// //                           decoration: BoxDecoration(
// //                             color: AppTheme.white,
// //                             borderRadius: AppTheme.radiusLarge,
// //                             boxShadow: AppTheme.elevatedShadow,
// //                           ),
// //                           child: Column(
// //                             mainAxisSize: MainAxisSize.min,
// //                             children: [
// //                               Container(
// //                                 width: 80,
// //                                 height: 80,
// //                                 decoration: BoxDecoration(
// //                                   color: AppTheme.info,
// //                                   borderRadius: AppTheme.radiusMedium,
// //                                 ),
// //                                 child: const Icon(
// //                                   Icons.people_alt_outlined,
// //                                   color: AppTheme.white,
// //                                   size: 40,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 24),
// //                               const Text('PMLIL Staff', style: AppTheme.h2),
// //                               const SizedBox(height: 8),
// //                               const Text(
// //                                 'Login or set up your account',
// //                                 style: AppTheme.bodyMedium,
// //                                 textAlign: TextAlign.center,
// //                               ),
// //                               const SizedBox(height: 32),
// //                               Container(
// //                                 decoration: BoxDecoration(
// //                                   color: AppTheme.greyLight.withOpacity(0.5),
// //                                   borderRadius: AppTheme.radiusSmall,
// //                                 ),
// //                                 child: TabBar(
// //                                   controller: _tabController,
// //                                   labelColor: AppTheme.white,
// //                                   unselectedLabelColor: AppTheme.textSecondary,
// //                                   indicator: BoxDecoration(
// //                                     color: AppTheme.info,
// //                                     borderRadius: AppTheme.radiusSmall,
// //                                   ),
// //                                   dividerColor: Colors.transparent,
// //                                   tabs: const [
// //                                     Tab(text: 'Login'),
// //                                     Tab(text: 'First Time Setup'),
// //                                   ],
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 24),
// //                               SizedBox(
// //                                 height: 520,
// //                                 child: TabBarView(
// //                                   controller: _tabController,
// //                                   physics: const NeverScrollableScrollPhysics(),
// //                                   children: [_LoginTab(), _FirstTimeTab()],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // =============================================================================
// // // LOGIN TAB — unchanged from original
// // // =============================================================================
// //
// // class _LoginTab extends StatefulWidget {
// //   @override
// //   State<_LoginTab> createState() => _LoginTabState();
// // }
// //
// // class _LoginTabState extends State<_LoginTab> {
// //   final _phoneController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   bool _loading = false;
// //   bool _obscurePassword = true;
// //
// //   @override
// //   void dispose() {
// //     _phoneController.dispose();
// //     _passwordController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _signIn() async {
// //     if (_phoneController.text.trim().isEmpty ||
// //         _passwordController.text.trim().isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Please enter both phone number and password'),
// //           backgroundColor: AppTheme.error,
// //         ),
// //       );
// //       return;
// //     }
// //     setState(() => _loading = true);
// //     try {
// //       await StaffAuthService.loginWithPhone(
// //         _phoneController.text.trim(),
// //         _passwordController.text,
// //       );
// //       devLog('Staff logged in successfully');
// //       if (mounted)
// //         Navigator.of(context).pushReplacementNamed('/staff-dashboard');
// //     } catch (e) {
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(e.toString()),
// //             backgroundColor: AppTheme.error,
// //           ),
// //         );
// //       }
// //     } finally {
// //       if (mounted) setState(() => _loading = false);
// //     }
// //   }
// //
// //   InputDecoration _dec(String hint) => InputDecoration(
// //     hintText: hint,
// //     hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
// //     filled: true,
// //     fillColor: AppTheme.greyLight,
// //     border: OutlineInputBorder(
// //       borderRadius: AppTheme.radiusSmall,
// //       borderSide: BorderSide.none,
// //     ),
// //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //   );
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Row(
// //             children: [
// //               Icon(Icons.phone_outlined, size: 18, color: AppTheme.info),
// //               SizedBox(width: 8),
// //               Text('Phone Number', style: AppTheme.labelLarge),
// //             ],
// //           ),
// //           const SizedBox(height: 8),
// //           TextField(
// //             controller: _phoneController,
// //             keyboardType: TextInputType.phone,
// //             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// //             decoration: _dec('98XXXXXXXX'),
// //           ),
// //           const SizedBox(height: 20),
// //           const Row(
// //             children: [
// //               Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
// //               SizedBox(width: 8),
// //               Text('Password', style: AppTheme.labelLarge),
// //             ],
// //           ),
// //           const SizedBox(height: 8),
// //           TextField(
// //             controller: _passwordController,
// //             obscureText: _obscurePassword,
// //             decoration: _dec('Enter your password').copyWith(
// //               suffixIcon: IconButton(
// //                 icon: Icon(
// //                   _obscurePassword
// //                       ? Icons.visibility_off_outlined
// //                       : Icons.visibility_outlined,
// //                   color: AppTheme.grey,
// //                 ),
// //                 onPressed: () =>
// //                     setState(() => _obscurePassword = !_obscurePassword),
// //               ),
// //             ),
// //             onSubmitted: (_) => _signIn(),
// //           ),
// //           const SizedBox(height: 32),
// //           SizedBox(
// //             width: double.infinity,
// //             height: 50,
// //             child: ElevatedButton(
// //               onPressed: _loading ? null : _signIn,
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: AppTheme.info,
// //                 foregroundColor: AppTheme.white,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: AppTheme.radiusSmall,
// //                 ),
// //                 elevation: 0,
// //               ),
// //               child: _loading
// //                   ? const SizedBox(
// //                       width: 20,
// //                       height: 20,
// //                       child: CircularProgressIndicator(
// //                         color: AppTheme.white,
// //                         strokeWidth: 2,
// //                       ),
// //                     )
// //                   : const Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Icon(Icons.login, size: 20),
// //                         SizedBox(width: 8),
// //                         Text(
// //                           'Login',
// //                           style: TextStyle(
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // =============================================================================
// // // FIRST TIME SETUP TAB
// // // =============================================================================
// //
// // enum _Step { enterPhone, confirmIdentity, setPassword }
// //
// // class _FirstTimeTab extends StatefulWidget {
// //   @override
// //   State<_FirstTimeTab> createState() => _FirstTimeTabState();
// // }
// //
// // class _FirstTimeTabState extends State<_FirstTimeTab> {
// //   _Step _step = _Step.enterPhone;
// //   StaffLocalModel? _foundStaff;
// //
// //   final _phoneController = TextEditingController();
// //   bool _lookingUp = false;
// //   String? _lookupError;
// //
// //   final _passwordController = TextEditingController();
// //   final _confirmController = TextEditingController();
// //   bool _obscurePassword = true;
// //   bool _obscureConfirm = true;
// //   bool _registering = false;
// //   String? _registerError;
// //
// //   @override
// //   void dispose() {
// //     _phoneController.dispose();
// //     _passwordController.dispose();
// //     _confirmController.dispose();
// //     super.dispose();
// //   }
// //
// //   InputDecoration _dec(String hint) => InputDecoration(
// //     hintText: hint,
// //     hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
// //     filled: true,
// //     fillColor: AppTheme.greyLight,
// //     border: OutlineInputBorder(
// //       borderRadius: AppTheme.radiusSmall,
// //       borderSide: BorderSide.none,
// //     ),
// //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //   );
// //
// //   // ── Step 1 logic ──────────────────────────────────────────────────────────
// //
// //   Future<void> _lookupPhone() async {
// //     final phone = _phoneController.text.trim();
// //     if (phone.isEmpty) {
// //       setState(() => _lookupError = 'Enter your phone number');
// //       return;
// //     }
// //     setState(() {
// //       _lookingUp = true;
// //       _lookupError = null;
// //     });
// //     try {
// //       final staff = await ServiceLocator.staffSync.findByPhone(phone);
// //       if (staff == null) {
// //         setState(
// //           () => _lookupError =
// //               'Phone number not found in the staff directory.\n'
// //               'Contact IT if you are a new employee.',
// //         );
// //         return;
// //       }
// //       final alreadyExists = await StaffAuthService.isPhoneAlreadyRegistered(
// //         phone,
// //       );
// //       if (alreadyExists) {
// //         setState(
// //           () => _lookupError =
// //               'This number is already registered.\nUse the Login tab to sign in.',
// //         );
// //         return;
// //       }
// //       setState(() {
// //         _foundStaff = staff;
// //         _step = _Step.confirmIdentity;
// //       });
// //     } catch (e) {
// //       setState(() => _lookupError = 'Something went wrong. Try again.');
// //     } finally {
// //       if (mounted) setState(() => _lookingUp = false);
// //     }
// //   }
// //
// //   // ── Step 3 logic ──────────────────────────────────────────────────────────
// //
// //   Future<void> _register() async {
// //     final password = _passwordController.text;
// //     final confirm = _confirmController.text;
// //     final staff = _foundStaff!;
// //
// //     if (password.isEmpty || confirm.isEmpty) {
// //       setState(() => _registerError = 'Please fill in both password fields.');
// //       return;
// //     }
// //     if (password.length < 6) {
// //       setState(
// //         () => _registerError = 'Password must be at least 6 characters.',
// //       );
// //       return;
// //     }
// //     if (password != confirm) {
// //       setState(() => _registerError = 'Passwords do not match.');
// //       return;
// //     }
// //
// //     setState(() {
// //       _registering = true;
// //       _registerError = null;
// //     });
// //
// //     try {
// //       final isHQ = staff.isHQStaff;
// //       final branchId = isHQ ? 'kamaladi' : staff.branchCode;
// //       final branchName = isHQ ? 'KAMALADI' : staff.branchName;
// //
// //       // Resolve departmentId from Firestore for HQ staff
// //       String? departmentId;
// //       String? departmentName;
// //       if (isHQ &&
// //           staff.departmentName != null &&
// //           staff.departmentName!.trim().isNotEmpty) {
// //         departmentName = staff.departmentName!.trim();
// //         final snap = await FirebaseFirestore.instance
// //             .collection('departments')
// //             .where('name', isEqualTo: departmentName)
// //             .limit(1)
// //             .get();
// //         if (snap.docs.isNotEmpty) departmentId = snap.docs.first.id;
// //       }
// //
// //       await StaffAuthService.registerFromApi(
// //         name: staff.fullName,
// //         phone: staff.phone,
// //         email: staff.email,
// //         password: password,
// //         branchId: branchId,
// //         branchName: branchName,
// //         departmentId: departmentId,
// //         departmentName: departmentName,
// //       );
// //
// //       // Firebase Auth session is active — just set persistence flag
// //       await StaffAuthService.setLoggedIn(true, staff.phone);
// //
// //       devLog('First-time setup complete');
// //       if (!mounted) return;
// //       Navigator.of(context).pushReplacementNamed('/staff-dashboard');
// //     } catch (e) {
// //       String msg = 'Registration failed. Please try again.';
// //       if (e.toString().contains('email-already-in-use')) {
// //         msg = 'Account already exists. Use the Login tab.';
// //       } else if (e.toString().contains('network')) {
// //         msg = 'Network error. Check your connection.';
// //       }
// //       setState(() => _registerError = msg);
// //     } finally {
// //       if (mounted) setState(() => _registering = false);
// //     }
// //   }
// //
// //   String _maskEmail(String email) {
// //     final parts = email.split('@');
// //     if (parts.length != 2) return email;
// //     final local = parts[0];
// //     if (local.length <= 2) return '${local[0]}*@${parts[1]}';
// //     return '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}@${parts[1]}';
// //   }
// //
// //   // ── Build ─────────────────────────────────────────────────────────────────
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       child: AnimatedSwitcher(
// //         duration: const Duration(milliseconds: 200),
// //         child: _buildStep(),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStep() {
// //     switch (_step) {
// //       case _Step.enterPhone:
// //         return _buildEnterPhone();
// //       case _Step.confirmIdentity:
// //         return _buildConfirmIdentity();
// //       case _Step.setPassword:
// //         return _buildSetPassword();
// //     }
// //   }
// //
// //   Widget _buildEnterPhone() {
// //     return Column(
// //       key: const ValueKey('s1'),
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Container(
// //           padding: const EdgeInsets.all(12),
// //           decoration: BoxDecoration(
// //             color: AppTheme.info.withOpacity(0.1),
// //             borderRadius: AppTheme.radiusSmall,
// //           ),
// //           child: Row(
// //             children: [
// //               const Icon(Icons.info_outline, size: 16, color: AppTheme.info),
// //               const SizedBox(width: 8),
// //               Expanded(
// //                 child: Text(
// //                   'First time? Enter your phone number to find your account.',
// //                   style: AppTheme.bodySmall.copyWith(color: AppTheme.info),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 20),
// //         const Row(
// //           children: [
// //             Icon(Icons.phone_outlined, size: 18, color: AppTheme.info),
// //             SizedBox(width: 8),
// //             Text('Phone Number', style: AppTheme.labelLarge),
// //           ],
// //         ),
// //         const SizedBox(height: 8),
// //         TextField(
// //           controller: _phoneController,
// //           keyboardType: TextInputType.phone,
// //           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// //           decoration: _dec('98XXXXXXXX'),
// //           onSubmitted: (_) => _lookupPhone(),
// //         ),
// //         if (_lookupError != null) ...[
// //           const SizedBox(height: 12),
// //           Container(
// //             padding: const EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //               color: AppTheme.error.withOpacity(0.1),
// //               borderRadius: AppTheme.radiusSmall,
// //             ),
// //             child: Row(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Icon(
// //                   Icons.error_outline,
// //                   size: 16,
// //                   color: AppTheme.error,
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: Text(
// //                     _lookupError!,
// //                     style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //         const SizedBox(height: 32),
// //         SizedBox(
// //           width: double.infinity,
// //           height: 50,
// //           child: ElevatedButton(
// //             onPressed: _lookingUp ? null : _lookupPhone,
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: AppTheme.info,
// //               foregroundColor: AppTheme.white,
// //               shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
// //               elevation: 0,
// //             ),
// //             child: _lookingUp
// //                 ? const SizedBox(
// //                     width: 20,
// //                     height: 20,
// //                     child: CircularProgressIndicator(
// //                       color: AppTheme.white,
// //                       strokeWidth: 2,
// //                     ),
// //                   )
// //                 : const Text(
// //                     'Find My Account',
// //                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
// //                   ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildConfirmIdentity() {
// //     final staff = _foundStaff!;
// //     return Column(
// //       key: const ValueKey('s2'),
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         const Text('Is this you?', style: AppTheme.h3),
// //         const SizedBox(height: 4),
// //         Text(
// //           'Confirm your identity before setting a password.',
// //           style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
// //         ),
// //         const SizedBox(height: 20),
// //         Container(
// //           width: double.infinity,
// //           padding: const EdgeInsets.all(20),
// //           decoration: BoxDecoration(
// //             color: AppTheme.greyLight,
// //             borderRadius: AppTheme.radiusMedium,
// //             border: Border.all(
// //               color: AppTheme.info.withOpacity(0.3),
// //               width: 1.5,
// //             ),
// //           ),
// //           child: Column(
// //             children: [
// //               CircleAvatar(
// //                 radius: 28,
// //                 backgroundColor: AppTheme.info.withOpacity(0.15),
// //                 child: Text(
// //                   staff.fullName.isNotEmpty
// //                       ? staff.fullName[0].toUpperCase()
// //                       : '?',
// //                   style: TextStyle(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.bold,
// //                     color: AppTheme.info,
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 12),
// //               Text(
// //                 staff.fullName,
// //                 style: AppTheme.h3,
// //                 textAlign: TextAlign.center,
// //               ),
// //               const SizedBox(height: 4),
// //               Text(
// //                 staff.branchName,
// //                 style: AppTheme.bodySmall.copyWith(
// //                   color: AppTheme.textSecondary,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //               if (staff.departmentName != null &&
// //                   staff.departmentName!.isNotEmpty) ...[
// //                 const SizedBox(height: 2),
// //                 Text(
// //                   staff.departmentName!,
// //                   style: AppTheme.bodySmall.copyWith(
// //                     color: AppTheme.textSecondary,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ],
// //               const SizedBox(height: 12),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const Icon(
// //                     Icons.email_outlined,
// //                     size: 14,
// //                     color: AppTheme.grey,
// //                   ),
// //                   const SizedBox(width: 6),
// //                   Text(
// //                     _maskEmail(staff.email),
// //                     style: AppTheme.bodySmall.copyWith(
// //                       color: AppTheme.textSecondary,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 20),
// //         SizedBox(
// //           width: double.infinity,
// //           height: 50,
// //           child: ElevatedButton(
// //             onPressed: () => setState(() => _step = _Step.setPassword),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: AppTheme.info,
// //               foregroundColor: AppTheme.white,
// //               shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
// //               elevation: 0,
// //             ),
// //             child: const Text(
// //               "Yes, that's me — Set Password",
// //               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //         SizedBox(
// //           width: double.infinity,
// //           height: 44,
// //           child: OutlinedButton(
// //             onPressed: () => setState(() {
// //               _step = _Step.enterPhone;
// //               _foundStaff = null;
// //               _lookupError = null;
// //             }),
// //             style: OutlinedButton.styleFrom(
// //               foregroundColor: AppTheme.textSecondary,
// //               side: BorderSide(color: AppTheme.grey.withOpacity(0.4)),
// //               shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
// //             ),
// //             child: const Text('Not me — Go back'),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildSetPassword() {
// //     final firstName = _foundStaff!.fullName.split(' ').first;
// //     return Column(
// //       key: const ValueKey('s3'),
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text('Welcome, $firstName!', style: AppTheme.h3),
// //         const SizedBox(height: 4),
// //         Text(
// //           'Choose a password to complete your setup.',
// //           style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
// //         ),
// //         const SizedBox(height: 20),
// //         const Row(
// //           children: [
// //             Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
// //             SizedBox(width: 8),
// //             Text('New Password', style: AppTheme.labelLarge),
// //           ],
// //         ),
// //         const SizedBox(height: 8),
// //         TextField(
// //           controller: _passwordController,
// //           obscureText: _obscurePassword,
// //           decoration: _dec('Min 6 characters').copyWith(
// //             suffixIcon: IconButton(
// //               icon: Icon(
// //                 _obscurePassword
// //                     ? Icons.visibility_off_outlined
// //                     : Icons.visibility_outlined,
// //                 color: AppTheme.grey,
// //               ),
// //               onPressed: () =>
// //                   setState(() => _obscurePassword = !_obscurePassword),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //         const Row(
// //           children: [
// //             Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
// //             SizedBox(width: 8),
// //             Text('Confirm Password', style: AppTheme.labelLarge),
// //           ],
// //         ),
// //         const SizedBox(height: 8),
// //         TextField(
// //           controller: _confirmController,
// //           obscureText: _obscureConfirm,
// //           decoration: _dec('Re-enter password').copyWith(
// //             suffixIcon: IconButton(
// //               icon: Icon(
// //                 _obscureConfirm
// //                     ? Icons.visibility_off_outlined
// //                     : Icons.visibility_outlined,
// //                 color: AppTheme.grey,
// //               ),
// //               onPressed: () =>
// //                   setState(() => _obscureConfirm = !_obscureConfirm),
// //             ),
// //           ),
// //           onSubmitted: (_) => _registering ? null : _register(),
// //         ),
// //         if (_registerError != null) ...[
// //           const SizedBox(height: 12),
// //           Container(
// //             padding: const EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //               color: AppTheme.error.withOpacity(0.1),
// //               borderRadius: AppTheme.radiusSmall,
// //             ),
// //             child: Row(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Icon(
// //                   Icons.error_outline,
// //                   size: 16,
// //                   color: AppTheme.error,
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: Text(
// //                     _registerError!,
// //                     style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //         const SizedBox(height: 24),
// //         SizedBox(
// //           width: double.infinity,
// //           height: 50,
// //           child: ElevatedButton(
// //             onPressed: _registering ? null : _register,
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: AppTheme.info,
// //               foregroundColor: AppTheme.white,
// //               shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
// //               elevation: 0,
// //             ),
// //             child: _registering
// //                 ? const SizedBox(
// //                     width: 20,
// //                     height: 20,
// //                     child: CircularProgressIndicator(
// //                       color: AppTheme.white,
// //                       strokeWidth: 2,
// //                     ),
// //                   )
// //                 : const Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.check_circle_outline, size: 20),
// //                       SizedBox(width: 8),
// //                       Text(
// //                         'Create Account & Login',
// //                         style: TextStyle(
// //                           fontSize: 15,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //         SizedBox(
// //           width: double.infinity,
// //           height: 44,
// //           child: OutlinedButton(
// //             onPressed: _registering
// //                 ? null
// //                 : () => setState(() => _step = _Step.confirmIdentity),
// //             style: OutlinedButton.styleFrom(
// //               foregroundColor: AppTheme.textSecondary,
// //               side: BorderSide(color: AppTheme.grey.withOpacity(0.4)),
// //               shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
// //             ),
// //             child: const Text('Back'),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import '../../../core/di/service_locator.dart';
// import '../../../core/services/staff_auth_service.dart';
// import '../../../core/theme/app_theme.dart';
// import '../../../core/utils/dev.log.dart';
// import '../../../data/local/models/staff_local_model.dart';
//
// class StaffAuthScreen extends StatefulWidget {
//   const StaffAuthScreen({super.key});
//
//   @override
//   State<StaffAuthScreen> createState() => _StaffAuthScreenState();
// }
//
// class _StaffAuthScreenState extends State<StaffAuthScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _syncing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _manualSync() async {
//     setState(() => _syncing = true);
//     try {
//       final result = await ServiceLocator.staffSync.forceSync();
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             result.success
//                 ? 'Sync complete. ${result.staffCount} staff updated.'
//                 : 'Sync failed: ${result.error}',
//           ),
//           backgroundColor: result.success ? AppTheme.success : AppTheme.error,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Sync failed: $e'),
//           backgroundColor: AppTheme.error,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _syncing = false);
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
//             final maxWidth = isTablet ? 600.0 : constraints.maxWidth * 0.9;
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
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: TextButton.icon(
//                           onPressed: () => Navigator.of(context).pop(),
//                           icon: const Icon(Icons.arrow_back),
//                           label: const Text('Back'),
//                           style: TextButton.styleFrom(
//                             foregroundColor: AppTheme.dark,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
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
//                               const SizedBox(height: 24),
//                               const Text('PMLIL Staff', style: AppTheme.h2),
//                               const SizedBox(height: 8),
//                               const Text(
//                                 'Login or set up your account',
//                                 style: AppTheme.bodyMedium,
//                                 textAlign: TextAlign.center,
//                               ),
//                               const SizedBox(height: 32),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: AppTheme.greyLight.withOpacity(0.5),
//                                   borderRadius: AppTheme.radiusSmall,
//                                 ),
//                                 child: TabBar(
//                                   controller: _tabController,
//                                   labelColor: AppTheme.white,
//                                   unselectedLabelColor: AppTheme.textSecondary,
//                                   indicator: BoxDecoration(
//                                     color: AppTheme.info,
//                                     borderRadius: AppTheme.radiusSmall,
//                                   ),
//                                   dividerColor: Colors.transparent,
//                                   tabs: const [
//                                     Tab(text: 'Login'),
//                                     Tab(text: 'First Time Setup'),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 24),
//                               SizedBox(
//                                 height: 520,
//                                 child: TabBarView(
//                                   controller: _tabController,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   children: [_LoginTab(), _FirstTimeTab()],
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               // Manual sync button
//                               TextButton.icon(
//                                 onPressed: _syncing ? null : _manualSync,
//                                 icon: _syncing
//                                     ? const SizedBox(
//                                         width: 14,
//                                         height: 14,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color: AppTheme.textSecondary,
//                                         ),
//                                       )
//                                     : const Icon(
//                                         Icons.sync,
//                                         size: 16,
//                                         color: AppTheme.textSecondary,
//                                       ),
//                                 label: Text(
//                                   _syncing ? 'Syncing...' : 'Sync Staff Data',
//                                   style: AppTheme.bodySmall.copyWith(
//                                     color: AppTheme.textSecondary,
//                                   ),
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
//
// // =============================================================================
// // LOGIN TAB
// // =============================================================================
//
// class _LoginTab extends StatefulWidget {
//   @override
//   State<_LoginTab> createState() => _LoginTabState();
// }
//
// class _LoginTabState extends State<_LoginTab> {
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;
//   bool _obscurePassword = true;
//
//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _signIn() async {
//     if (_phoneController.text.trim().isEmpty ||
//         _passwordController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter both phone number and password'),
//           backgroundColor: AppTheme.error,
//         ),
//       );
//       return;
//     }
//     setState(() => _loading = true);
//     try {
//       await StaffAuthService.loginWithPhone(
//         _phoneController.text.trim(),
//         _passwordController.text,
//       );
//       devLog('Staff logged in successfully');
//       if (mounted)
//         Navigator.of(context).pushReplacementNamed('/staff-dashboard');
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString()),
//             backgroundColor: AppTheme.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }
//
//   InputDecoration _dec(String hint) => InputDecoration(
//     hintText: hint,
//     hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
//     filled: true,
//     fillColor: AppTheme.greyLight,
//     border: OutlineInputBorder(
//       borderRadius: AppTheme.radiusSmall,
//       borderSide: BorderSide.none,
//     ),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.phone_outlined, size: 18, color: AppTheme.info),
//               SizedBox(width: 8),
//               Text('Phone Number', style: AppTheme.labelLarge),
//             ],
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: _phoneController,
//             keyboardType: TextInputType.phone,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             decoration: _dec('98XXXXXXXX'),
//           ),
//           const SizedBox(height: 20),
//           const Row(
//             children: [
//               Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
//               SizedBox(width: 8),
//               Text('Password', style: AppTheme.labelLarge),
//             ],
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: _passwordController,
//             obscureText: _obscurePassword,
//             decoration: _dec('Enter your password').copyWith(
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _obscurePassword
//                       ? Icons.visibility_off_outlined
//                       : Icons.visibility_outlined,
//                   color: AppTheme.grey,
//                 ),
//                 onPressed: () =>
//                     setState(() => _obscurePassword = !_obscurePassword),
//               ),
//             ),
//             onSubmitted: (_) => _signIn(),
//           ),
//           const SizedBox(height: 32),
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton(
//               onPressed: _loading ? null : _signIn,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.info,
//                 foregroundColor: AppTheme.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: AppTheme.radiusSmall,
//                 ),
//                 elevation: 0,
//               ),
//               child: _loading
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         color: AppTheme.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.login, size: 20),
//                         SizedBox(width: 8),
//                         Text(
//                           'Login',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // =============================================================================
// // FIRST TIME SETUP TAB
// // =============================================================================
//
// enum _Step { enterPhone, confirmIdentity, setPassword }
//
// class _FirstTimeTab extends StatefulWidget {
//   @override
//   State<_FirstTimeTab> createState() => _FirstTimeTabState();
// }
//
// class _FirstTimeTabState extends State<_FirstTimeTab> {
//   _Step _step = _Step.enterPhone;
//   StaffLocalModel? _foundStaff;
//
//   final _phoneController = TextEditingController();
//   bool _lookingUp = false;
//   String? _lookupError;
//
//   final _passwordController = TextEditingController();
//   final _confirmController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _obscureConfirm = true;
//   bool _registering = false;
//   String? _registerError;
//
//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmController.dispose();
//     super.dispose();
//   }
//
//   InputDecoration _dec(String hint) => InputDecoration(
//     hintText: hint,
//     hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
//     filled: true,
//     fillColor: AppTheme.greyLight,
//     border: OutlineInputBorder(
//       borderRadius: AppTheme.radiusSmall,
//       borderSide: BorderSide.none,
//     ),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//   );
//
//   Future<void> _lookupPhone() async {
//     final phone = _phoneController.text.trim();
//     if (phone.isEmpty) {
//       setState(() => _lookupError = 'Enter your phone number');
//       return;
//     }
//     setState(() {
//       _lookingUp = true;
//       _lookupError = null;
//     });
//     try {
//       final staff = await ServiceLocator.staffSync.findByPhone(phone);
//       if (staff == null) {
//         setState(
//           () => _lookupError =
//               'Phone number not found in the staff directory.\n'
//               'Contact IT if you are a new employee.',
//         );
//         return;
//       }
//       final alreadyExists = await StaffAuthService.isPhoneAlreadyRegistered(
//         phone,
//       );
//       if (alreadyExists) {
//         setState(
//           () => _lookupError =
//               'This number is already registered.\nUse the Login tab to sign in.',
//         );
//         return;
//       }
//       setState(() {
//         _foundStaff = staff;
//         _step = _Step.confirmIdentity;
//       });
//     } catch (e) {
//       setState(() => _lookupError = 'Something went wrong. Try again.');
//     } finally {
//       if (mounted) setState(() => _lookingUp = false);
//     }
//   }
//
//   Future<void> _register() async {
//     final password = _passwordController.text;
//     final confirm = _confirmController.text;
//     final staff = _foundStaff!;
//
//     if (password.isEmpty || confirm.isEmpty) {
//       setState(() => _registerError = 'Please fill in both password fields.');
//       return;
//     }
//     if (password.length < 6) {
//       setState(
//         () => _registerError = 'Password must be at least 6 characters.',
//       );
//       return;
//     }
//     if (password != confirm) {
//       setState(() => _registerError = 'Passwords do not match.');
//       return;
//     }
//
//     setState(() {
//       _registering = true;
//       _registerError = null;
//     });
//
//     try {
//       final isHQ = staff.isHQStaff;
//       final branchId = isHQ ? 'kamaladi' : staff.branchCode;
//       final branchName = isHQ ? 'KAMALADI' : staff.branchName;
//
//       String? departmentId;
//       String? departmentName;
//       if (isHQ &&
//           staff.departmentName != null &&
//           staff.departmentName!.trim().isNotEmpty) {
//         departmentName = staff.departmentName!.trim();
//         final snap = await FirebaseFirestore.instance
//             .collection('departments')
//             .where('name', isEqualTo: departmentName)
//             .limit(1)
//             .get();
//         if (snap.docs.isNotEmpty) departmentId = snap.docs.first.id;
//       }
//
//       await StaffAuthService.registerFromApi(
//         name: staff.fullName,
//         phone: staff.phone,
//         email: staff.email,
//         password: password,
//         branchId: branchId,
//         branchName: branchName,
//         departmentId: departmentId,
//         departmentName: departmentName,
//       );
//
//       await StaffAuthService.setLoggedIn(true, staff.phone);
//
//       devLog('First-time setup complete');
//       if (!mounted) return;
//       Navigator.of(context).pushReplacementNamed('/staff-dashboard');
//     } catch (e) {
//       String msg = 'Registration failed. Please try again.';
//       if (e.toString().contains('email-already-in-use')) {
//         msg = 'Account already exists. Use the Login tab.';
//       } else if (e.toString().contains('network')) {
//         msg = 'Network error. Check your connection.';
//       }
//       setState(() => _registerError = msg);
//     } finally {
//       if (mounted) setState(() => _registering = false);
//     }
//   }
//
//   String _maskEmail(String email) {
//     final parts = email.split('@');
//     if (parts.length != 2) return email;
//     final local = parts[0];
//     if (local.length <= 2) return '${local[0]}*@${parts[1]}';
//     return '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}@${parts[1]}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 200),
//         child: _buildStep(),
//       ),
//     );
//   }
//
//   Widget _buildStep() {
//     switch (_step) {
//       case _Step.enterPhone:
//         return _buildEnterPhone();
//       case _Step.confirmIdentity:
//         return _buildConfirmIdentity();
//       case _Step.setPassword:
//         return _buildSetPassword();
//     }
//   }
//
//   Widget _buildEnterPhone() {
//     return Column(
//       key: const ValueKey('s1'),
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: AppTheme.info.withOpacity(0.1),
//             borderRadius: AppTheme.radiusSmall,
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.info_outline, size: 16, color: AppTheme.info),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   'First time? Enter your phone number to find your account.',
//                   style: AppTheme.bodySmall.copyWith(color: AppTheme.info),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         const Row(
//           children: [
//             Icon(Icons.phone_outlined, size: 18, color: AppTheme.info),
//             SizedBox(width: 8),
//             Text('Phone Number', style: AppTheme.labelLarge),
//           ],
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _phoneController,
//           keyboardType: TextInputType.phone,
//           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           decoration: _dec('98XXXXXXXX'),
//           onSubmitted: (_) => _lookupPhone(),
//         ),
//         if (_lookupError != null) ...[
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppTheme.error.withOpacity(0.1),
//               borderRadius: AppTheme.radiusSmall,
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Icon(
//                   Icons.error_outline,
//                   size: 16,
//                   color: AppTheme.error,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     _lookupError!,
//                     style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//         const SizedBox(height: 32),
//         SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: ElevatedButton(
//             onPressed: _lookingUp ? null : _lookupPhone,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.info,
//               foregroundColor: AppTheme.white,
//               shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
//               elevation: 0,
//             ),
//             child: _lookingUp
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       color: AppTheme.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : const Text(
//                     'Find My Account',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildConfirmIdentity() {
//     final staff = _foundStaff!;
//     return Column(
//       key: const ValueKey('s2'),
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Is this you?', style: AppTheme.h3),
//         const SizedBox(height: 4),
//         Text(
//           'Confirm your identity before setting a password.',
//           style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
//         ),
//         const SizedBox(height: 20),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: AppTheme.greyLight,
//             borderRadius: AppTheme.radiusMedium,
//             border: Border.all(
//               color: AppTheme.info.withOpacity(0.3),
//               width: 1.5,
//             ),
//           ),
//           child: Column(
//             children: [
//               CircleAvatar(
//                 radius: 28,
//                 backgroundColor: AppTheme.info.withOpacity(0.15),
//                 child: Text(
//                   staff.fullName.isNotEmpty
//                       ? staff.fullName[0].toUpperCase()
//                       : '?',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: AppTheme.info,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 staff.fullName,
//                 style: AppTheme.h3,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 staff.branchName,
//                 style: AppTheme.bodySmall.copyWith(
//                   color: AppTheme.textSecondary,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               if (staff.departmentName != null &&
//                   staff.departmentName!.isNotEmpty) ...[
//                 const SizedBox(height: 2),
//                 Text(
//                   staff.departmentName!,
//                   style: AppTheme.bodySmall.copyWith(
//                     color: AppTheme.textSecondary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.email_outlined,
//                     size: 14,
//                     color: AppTheme.grey,
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     _maskEmail(staff.email),
//                     style: AppTheme.bodySmall.copyWith(
//                       color: AppTheme.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: ElevatedButton(
//             onPressed: () => setState(() => _step = _Step.setPassword),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.info,
//               foregroundColor: AppTheme.white,
//               shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
//               elevation: 0,
//             ),
//             child: const Text(
//               "Yes, that's me — Set Password",
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           height: 44,
//           child: OutlinedButton(
//             onPressed: () => setState(() {
//               _step = _Step.enterPhone;
//               _foundStaff = null;
//               _lookupError = null;
//             }),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: AppTheme.textSecondary,
//               side: BorderSide(color: AppTheme.grey.withOpacity(0.4)),
//               shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
//             ),
//             child: const Text('Not me — Go back'),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSetPassword() {
//     final firstName = _foundStaff!.fullName.split(' ').first;
//     return Column(
//       key: const ValueKey('s3'),
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Welcome, $firstName!', style: AppTheme.h3),
//         const SizedBox(height: 4),
//         Text(
//           'Choose a password to complete your setup.',
//           style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
//         ),
//         const SizedBox(height: 20),
//         const Row(
//           children: [
//             Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
//             SizedBox(width: 8),
//             Text('New Password', style: AppTheme.labelLarge),
//           ],
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _passwordController,
//           obscureText: _obscurePassword,
//           decoration: _dec('Min 6 characters').copyWith(
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _obscurePassword
//                     ? Icons.visibility_off_outlined
//                     : Icons.visibility_outlined,
//                 color: AppTheme.grey,
//               ),
//               onPressed: () =>
//                   setState(() => _obscurePassword = !_obscurePassword),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Row(
//           children: [
//             Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
//             SizedBox(width: 8),
//             Text('Confirm Password', style: AppTheme.labelLarge),
//           ],
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _confirmController,
//           obscureText: _obscureConfirm,
//           decoration: _dec('Re-enter password').copyWith(
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _obscureConfirm
//                     ? Icons.visibility_off_outlined
//                     : Icons.visibility_outlined,
//                 color: AppTheme.grey,
//               ),
//               onPressed: () =>
//                   setState(() => _obscureConfirm = !_obscureConfirm),
//             ),
//           ),
//           onSubmitted: (_) => _registering ? null : _register(),
//         ),
//         if (_registerError != null) ...[
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppTheme.error.withOpacity(0.1),
//               borderRadius: AppTheme.radiusSmall,
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Icon(
//                   Icons.error_outline,
//                   size: 16,
//                   color: AppTheme.error,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     _registerError!,
//                     style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//         const SizedBox(height: 24),
//         SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: ElevatedButton(
//             onPressed: _registering ? null : _register,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.info,
//               foregroundColor: AppTheme.white,
//               shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
//               elevation: 0,
//             ),
//             child: _registering
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       color: AppTheme.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.check_circle_outline, size: 20),
//                       SizedBox(width: 8),
//                       Text(
//                         'Create Account & Login',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           height: 44,
//           child: OutlinedButton(
//             onPressed: _registering
//                 ? null
//                 : () => setState(() => _step = _Step.confirmIdentity),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: AppTheme.textSecondary,
//               side: BorderSide(color: AppTheme.grey.withOpacity(0.4)),
//               shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
//             ),
//             child: const Text('Back'),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/staff_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../../data/local/models/staff_local_model.dart';

class StaffAuthScreen extends StatefulWidget {
  const StaffAuthScreen({super.key});

  @override
  State<StaffAuthScreen> createState() => _StaffAuthScreenState();
}

class _StaffAuthScreenState extends State<StaffAuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _manualSync() async {
    setState(() => _syncing = true);
    try {
      final result = await ServiceLocator.staffSync.forceSync();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? 'Sync complete. ${result.staffCount} staff updated.'
                : 'Sync failed: ${result.error}',
          ),
          backgroundColor: result.success ? AppTheme.success : AppTheme.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final maxWidth = isTablet ? 600.0 : constraints.maxWidth * 0.9;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 20,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.dark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: maxWidth,
                          padding: EdgeInsets.all(isTablet ? 48 : 32),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: AppTheme.radiusLarge,
                            boxShadow: AppTheme.elevatedShadow,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.info,
                                  borderRadius: AppTheme.radiusMedium,
                                ),
                                child: const Icon(
                                  Icons.people_alt_outlined,
                                  color: AppTheme.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text('PMLIL Staff', style: AppTheme.h2),
                              const SizedBox(height: 8),
                              const Text(
                                'Login or set up your account',
                                style: AppTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.greyLight.withOpacity(0.5),
                                  borderRadius: AppTheme.radiusSmall,
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor: AppTheme.white,
                                  unselectedLabelColor: AppTheme.textSecondary,
                                  indicator: BoxDecoration(
                                    color: AppTheme.info,
                                    borderRadius: AppTheme.radiusSmall,
                                  ),
                                  dividerColor: Colors.transparent,
                                  tabs: const [
                                    Tab(text: 'Login'),
                                    Tab(text: 'First Time Setup'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 520,
                                child: TabBarView(
                                  controller: _tabController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [_LoginTab(), _FirstTimeTab()],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _syncing ? null : _manualSync,
                                icon: _syncing
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppTheme.textSecondary,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.sync,
                                        size: 16,
                                        color: AppTheme.textSecondary,
                                      ),
                                label: Text(
                                  _syncing ? 'Syncing...' : 'Sync Staff Data',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// LOGIN TAB (unchanged)
// =============================================================================

class _LoginTab extends StatefulWidget {
  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both phone number and password'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await StaffAuthService.loginWithPhone(
        _phoneController.text.trim(),
        _passwordController.text,
      );
      devLog('Staff logged in successfully');
      if (mounted)
        Navigator.of(context).pushReplacementNamed('/staff-dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
    filled: true,
    fillColor: AppTheme.greyLight,
    border: OutlineInputBorder(
      borderRadius: AppTheme.radiusSmall,
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone_outlined, size: 18, color: AppTheme.info),
              SizedBox(width: 8),
              Text('Phone Number', style: AppTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _dec('98XXXXXXXX'),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
              SizedBox(width: 8),
              Text('Password', style: AppTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _dec('Enter your password').copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.grey,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            onSubmitted: (_) => _signIn(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.info,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusSmall,
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FIRST TIME SETUP TAB
// =============================================================================

// Added verifyOtp step between confirmIdentity and setPassword
enum _Step { enterPhone, confirmIdentity, verifyOtp, setPassword }

class _FirstTimeTab extends StatefulWidget {
  @override
  State<_FirstTimeTab> createState() => _FirstTimeTabState();
}

class _FirstTimeTabState extends State<_FirstTimeTab> {
  _Step _step = _Step.enterPhone;
  StaffLocalModel? _foundStaff;

  // Step 1
  final _phoneController = TextEditingController();
  bool _lookingUp = false;
  String? _lookupError;

  // Step 2.5 — OTP
  final _otpController = TextEditingController();
  bool _sendingOtp = false;
  bool _verifyingOtp = false;
  String? _otpError;
  bool _otpSent = false;
  // Resend cooldown
  int _resendCooldown = 0;
  bool _resendTimerActive = false;

  // Step 3
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _registering = false;
  String? _registerError;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
    filled: true,
    fillColor: AppTheme.greyLight,
    border: OutlineInputBorder(
      borderRadius: AppTheme.radiusSmall,
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  // ─── Step 1: Phone lookup ────────────────────────────────────────────────

  Future<void> _lookupPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _lookupError = 'Enter your phone number');
      return;
    }
    setState(() {
      _lookingUp = true;
      _lookupError = null;
    });
    try {
      final staff = await ServiceLocator.staffSync.findByPhone(phone);
      if (staff == null) {
        setState(
          () => _lookupError =
              'Phone number not found in the staff directory.\n'
              'Contact IT if you are a new employee.',
        );
        return;
      }
      final alreadyExists = await StaffAuthService.isPhoneAlreadyRegistered(
        phone,
      );
      if (alreadyExists) {
        setState(
          () => _lookupError =
              'This number is already registered.\nUse the Login tab to sign in.',
        );
        return;
      }
      setState(() {
        _foundStaff = staff;
        _step = _Step.confirmIdentity;
      });
    } catch (e) {
      setState(() => _lookupError = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _lookingUp = false);
    }
  }

  // ─── Step 2.5: OTP ───────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    final staff = _foundStaff!;
    setState(() {
      _sendingOtp = true;
      _otpError = null;
      _otpSent = false;
    });
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-south1',
      ).httpsCallable('sendOtp');
      await callable.call({
        'phone': staff.phone,
        'email': staff.email,
        'name': staff.fullName,
      });
      setState(() {
        _otpSent = true;
        _step = _Step.verifyOtp;
      });
      _startResendCooldown();
    } on FirebaseFunctionsException catch (e) {
      setState(() => _otpError = e.message ?? 'Failed to send OTP. Try again.');
    } catch (e) {
      setState(() => _otpError = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _otpError = 'Enter the 6-digit code from your email.');
      return;
    }
    setState(() {
      _verifyingOtp = true;
      _otpError = null;
    });
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-south1',
      ).httpsCallable('verifyOtp');
      await callable.call({'phone': _foundStaff!.phone, 'code': code});
      // OTP verified — proceed to set password
      setState(() => _step = _Step.setPassword);
    } on FirebaseFunctionsException catch (e) {
      final msg = e.message ?? 'Verification failed.';
      setState(() => _otpError = msg);
      // Clear the field so user can re-enter easily
      _otpController.clear();
    } catch (e) {
      setState(() => _otpError = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _verifyingOtp = false);
    }
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
      _resendTimerActive = true;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) {
        setState(() => _resendTimerActive = false);
        return false;
      }
      return true;
    });
  }

  // ─── Step 3: Register ────────────────────────────────────────────────────

  Future<void> _register() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final staff = _foundStaff!;

    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _registerError = 'Please fill in both password fields.');
      return;
    }
    if (password.length < 6) {
      setState(
        () => _registerError = 'Password must be at least 6 characters.',
      );
      return;
    }
    if (password != confirm) {
      setState(() => _registerError = 'Passwords do not match.');
      return;
    }

    setState(() {
      _registering = true;
      _registerError = null;
    });

    try {
      final isHQ = staff.isHQStaff;
      final branchId = isHQ ? 'kamaladi' : staff.branchCode;
      final branchName = isHQ ? 'KAMALADI' : staff.branchName;

      String? departmentId;
      String? departmentName;
      if (isHQ &&
          staff.departmentName != null &&
          staff.departmentName!.trim().isNotEmpty) {
        departmentName = staff.departmentName!.trim();
        final snap = await FirebaseFirestore.instance
            .collection('departments')
            .where('name', isEqualTo: departmentName)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) departmentId = snap.docs.first.id;
      }

      await StaffAuthService.registerFromApi(
        name: staff.fullName,
        phone: staff.phone,
        email: staff.email,
        password: password,
        branchId: branchId,
        branchName: branchName,
        departmentId: departmentId,
        departmentName: departmentName,
      );

      await StaffAuthService.setLoggedIn(true, staff.phone);

      devLog('First-time setup complete');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/staff-dashboard');
    } catch (e) {
      String msg = 'Registration failed. Please try again.';
      if (e.toString().contains('email-already-in-use')) {
        msg = 'Account already exists. Use the Login tab.';
      } else if (e.toString().contains('network')) {
        msg = 'Network error. Check your connection.';
      }
      setState(() => _registerError = msg);
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    if (local.length <= 2) return '${local[0]}*@${parts[1]}';
    return '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}@${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.enterPhone:
        return _buildEnterPhone();
      case _Step.confirmIdentity:
        return _buildConfirmIdentity();
      case _Step.verifyOtp:
        return _buildVerifyOtp();
      case _Step.setPassword:
        return _buildSetPassword();
    }
  }

  // ─── UI: Step 1 ──────────────────────────────────────────────────────────

  Widget _buildEnterPhone() {
    return Column(
      key: const ValueKey('s1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.info.withOpacity(0.1),
            borderRadius: AppTheme.radiusSmall,
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppTheme.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'First time? Enter your phone number to find your account.',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.info),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.phone_outlined, size: 18, color: AppTheme.info),
            SizedBox(width: 8),
            Text('Phone Number', style: AppTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _dec('98XXXXXXXX'),
          onSubmitted: (_) => _lookupPhone(),
        ),
        if (_lookupError != null) ...[
          const SizedBox(height: 12),
          _errorBox(_lookupError!),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _lookingUp ? null : _lookupPhone,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.info,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
              elevation: 0,
            ),
            child: _lookingUp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Find My Account',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  // ─── UI: Step 2 ──────────────────────────────────────────────────────────

  Widget _buildConfirmIdentity() {
    final staff = _foundStaff!;
    return Column(
      key: const ValueKey('s2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Is this you?', style: AppTheme.h3),
        const SizedBox(height: 4),
        Text(
          'Confirm your identity before setting a password.',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.greyLight,
            borderRadius: AppTheme.radiusMedium,
            border: Border.all(
              color: AppTheme.info.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.info.withOpacity(0.15),
                child: Text(
                  staff.fullName.isNotEmpty
                      ? staff.fullName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.info,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                staff.fullName,
                style: AppTheme.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                staff.branchName,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (staff.departmentName != null &&
                  staff.departmentName!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  staff.departmentName!,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: AppTheme.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _maskEmail(staff.email),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // "Yes that's me" now triggers OTP send instead of going straight to password
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _sendingOtp ? null : _sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.info,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
              elevation: 0,
            ),
            child: _sendingOtp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Yes, that's me — Send Verification Code",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        if (_otpError != null) ...[
          const SizedBox(height: 12),
          _errorBox(_otpError!),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: _sendingOtp
                ? null
                : () => setState(() {
                    _step = _Step.enterPhone;
                    _foundStaff = null;
                    _lookupError = null;
                    _otpError = null;
                  }),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: BorderSide(color: AppTheme.grey.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
            ),
            child: const Text('Not me — Go back'),
          ),
        ),
      ],
    );
  }

  // ─── UI: Step 2.5 — OTP ──────────────────────────────────────────────────

  Widget _buildVerifyOtp() {
    final maskedEmail = _maskEmail(_foundStaff!.email);
    return Column(
      key: const ValueKey('s2b'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Check your email', style: AppTheme.h3),
        const SizedBox(height: 4),
        Text(
          'We sent a 6-digit code to $maskedEmail.\nEnter it below to verify your identity.',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        // OTP input — large, centered, numbers only
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            hintText: '------',
            hintStyle: TextStyle(
              color: AppTheme.grey.withOpacity(0.4),
              fontSize: 28,
              letterSpacing: 12,
            ),
            filled: true,
            fillColor: AppTheme.greyLight,
            border: OutlineInputBorder(
              borderRadius: AppTheme.radiusSmall,
              borderSide: BorderSide.none,
            ),
            counterText: '', // hide the maxLength counter
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
          onSubmitted: (_) => _verifyingOtp ? null : _verifyOtp(),
        ),
        if (_otpError != null) ...[
          const SizedBox(height: 12),
          _errorBox(_otpError!),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _verifyingOtp ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.info,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
              elevation: 0,
            ),
            child: _verifyingOtp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Verify Code',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Resend button with cooldown
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: (_resendTimerActive || _sendingOtp)
                ? null
                : () async {
                    _otpController.clear();
                    setState(() => _otpError = null);
                    await _sendOtp();
                    if (mounted) setState(() => _step = _Step.verifyOtp);
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: BorderSide(color: AppTheme.grey.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
            ),
            child: _sendingOtp
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.textSecondary,
                    ),
                  )
                : Text(
                    _resendTimerActive
                        ? 'Resend code in ${_resendCooldown}s'
                        : 'Resend Code',
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton(
            onPressed: () => setState(() {
              _step = _Step.confirmIdentity;
              _otpController.clear();
              _otpError = null;
              _otpSent = false;
            }),
            child: Text(
              'Back',
              style: TextStyle(color: AppTheme.grey.withOpacity(0.7)),
            ),
          ),
        ),
      ],
    );
  }

  // ─── UI: Step 3 ──────────────────────────────────────────────────────────

  Widget _buildSetPassword() {
    final firstName = _foundStaff!.fullName.split(' ').first;
    return Column(
      key: const ValueKey('s3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, $firstName!', style: AppTheme.h3),
        const SizedBox(height: 4),
        Text(
          'Choose a password to complete your setup.',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
            SizedBox(width: 8),
            Text('New Password', style: AppTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _dec('Min 6 characters').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.grey,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(Icons.lock_outline, size: 18, color: AppTheme.info),
            SizedBox(width: 8),
            Text('Confirm Password', style: AppTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmController,
          obscureText: _obscureConfirm,
          decoration: _dec('Re-enter password').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.grey,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          onSubmitted: (_) => _registering ? null : _register(),
        ),
        if (_registerError != null) ...[
          const SizedBox(height: 12),
          _errorBox(_registerError!),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _registering ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.info,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
              elevation: 0,
            ),
            child: _registering
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Create Account & Login',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: _registering
                ? null
                : () => setState(() => _step = _Step.confirmIdentity),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: BorderSide(color: AppTheme.grey.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
            ),
            child: const Text('Back'),
          ),
        ),
      ],
    );
  }

  // ─── Shared widget ────────────────────────────────────────────────────────

  Widget _errorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: AppTheme.radiusSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppTheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
