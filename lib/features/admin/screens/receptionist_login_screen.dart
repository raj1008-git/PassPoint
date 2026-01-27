import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/receptionist_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';

class ReceptionistLoginScreen extends StatefulWidget {
  const ReceptionistLoginScreen({super.key});

  @override
  State<ReceptionistLoginScreen> createState() =>
      _ReceptionistLoginScreenState();
}

class _ReceptionistLoginScreenState extends State<ReceptionistLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      devLog(
        'Receptionist Sign In Attempt',
        params: {'email': _emailController.text},
      );

      await ReceptionistAuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      devLog('Receptionist logged in successfully');

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid credentials. Please check your email and password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
      } else {
        message = 'Login failed: ${e.message}';
      }
      devLog(
        'Receptionist Login failed',
        params: {'code': e.code, 'msg': e.message},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppTheme.error),
        );
      }
    } catch (e) {
      devLog('Receptionist Login Error', params: {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
            final maxWidth = isTablet ? 500.0 : constraints.maxWidth * 0.9;

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
                      // Back Button
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

                      // Login Card
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
                              // Icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryRed,
                                      AppTheme.primaryRedDark,
                                    ],
                                  ),
                                  borderRadius: AppTheme.radiusMedium,
                                ),
                                child: const Icon(
                                  Icons.business_center,
                                  color: AppTheme.white,
                                  size: 40,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Title
                              const Text('Reception Login', style: AppTheme.h2),

                              const SizedBox(height: 8),

                              // Subtitle
                              const Text(
                                'Access the admin dashboard',
                                style: AppTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 32),

                              // Email Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.email_outlined,
                                        size: 18,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Email Address',
                                        style: AppTheme.labelLarge,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'name@pmlil.com',
                                      hintStyle: TextStyle(
                                        color: AppTheme.grey.withOpacity(0.5),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.greyLight,
                                      border: OutlineInputBorder(
                                        borderRadius: AppTheme.radiusSmall,
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Password Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.lock_outline,
                                        size: 18,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Password',
                                        style: AppTheme.labelLarge,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      hintStyle: TextStyle(
                                        color: AppTheme.grey.withOpacity(0.5),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.greyLight,
                                      border: OutlineInputBorder(
                                        borderRadius: AppTheme.radiusSmall,
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AppTheme.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    onSubmitted: (_) => _signIn(),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _signIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryRed,
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
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.login, size: 20),
                                            const SizedBox(width: 8),
                                            const Text(
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

                              const SizedBox(height: 20),

                              // Info
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.info.withOpacity(0.1),
                                  borderRadius: AppTheme.radiusSmall,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: AppTheme.info,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Only @pmlil.com email addresses are allowed',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.info,
                                        ),
                                      ),
                                    ),
                                  ],
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
