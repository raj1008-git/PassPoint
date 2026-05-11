// lib/features/events/screens/event_manager_login_screen.dart

import 'package:flutter/material.dart';

import '../../../core/services/event_manager_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';

class EventManagerLoginScreen extends StatefulWidget {
  const EventManagerLoginScreen({Key? key}) : super(key: key);

  @override
  State<EventManagerLoginScreen> createState() =>
      _EventManagerLoginScreenState();
}

class _EventManagerLoginScreenState extends State<EventManagerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await EventManagerAuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      devLog('EventManagerLoginScreen: login success');

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/event-dashboard');
      }
    } catch (e) {
      devLog(
        'EventManagerLoginScreen: login error',
        params: {'error': e.toString()},
      );
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 80 : 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.08),

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Icon + title
                      _buildHeader(isTablet),

                      SizedBox(height: isTablet ? 48 : 40),

                      // Form
                      _buildForm(isTablet),

                      const SizedBox(height: 32),

                      // Error
                      if (_errorMessage != null) _buildError(),

                      // Login button
                      _buildLoginButton(isTablet),

                      SizedBox(height: constraints.maxHeight * 0.08),
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

  Widget _buildHeader(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: isTablet ? 96 : 80,
          height: isTablet ? 96 : 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
            ),
            borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B1FA2).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.event_rounded,
            color: AppTheme.white,
            size: isTablet ? 48 : 40,
          ),
        ),
        SizedBox(height: isTablet ? 24 : 20),
        Text(
          'Event Manager',
          style: TextStyle(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage PMLIL events',
          style: AppTheme.bodyMedium.copyWith(fontSize: isTablet ? 16 : 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(bool isTablet) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              label: 'Email',
              hint: 'yourname@pmlil.com',
              icon: Icons.email_outlined,
              isTablet: isTablet,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.trim().toLowerCase().endsWith('@pmlil.com')) {
                return 'Must be a @pmlil.com email';
              }
              return null;
            },
          ),

          SizedBox(height: isTablet ? 20 : 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: _inputDecoration(
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              isTablet: isTablet,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6) return 'Password too short';
              return null;
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required bool isTablet,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppTheme.white,
      labelStyle: AppTheme.bodyMedium,
      hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isTablet ? 18 : 14,
      ),
      border: OutlineInputBorder(
        borderRadius: AppTheme.radiusMedium,
        borderSide: BorderSide(color: AppTheme.greyLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusMedium,
        borderSide: BorderSide(color: AppTheme.greyLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusMedium,
        borderSide: const BorderSide(color: Color(0xFF7B1FA2), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusMedium,
        borderSide: const BorderSide(color: AppTheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusMedium,
        borderSide: const BorderSide(color: AppTheme.error, width: 2),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.08),
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isTablet) {
    return SizedBox(
      height: isTablet ? 56 : 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B1FA2),
          foregroundColor: AppTheme.white,
          disabledBackgroundColor: AppTheme.greyLight,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.radiusMedium,
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppTheme.white,
          ),
        )
            : Text(
          'Sign In',
          style: TextStyle(
            fontSize: isTablet ? 16 : 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}