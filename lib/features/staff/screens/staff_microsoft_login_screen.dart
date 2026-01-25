import 'package:flutter/material.dart';

import '../../../core/services/microsoft_auth_service.dart';
import '../../../core/services/staff_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';

class StaffMicrosoftLoginScreen extends StatefulWidget {
  const StaffMicrosoftLoginScreen({super.key});

  @override
  State<StaffMicrosoftLoginScreen> createState() =>
      _StaffMicrosoftLoginScreenState();
}

class _StaffMicrosoftLoginScreenState extends State<StaffMicrosoftLoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithMicrosoft() async {
    setState(() => _isLoading = true);

    try {
      devLog('Starting Microsoft sign-in for staff');

      final result = await MicrosoftAuthService.signInWithMicrosoft();

      if (result == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign-in was cancelled or failed'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final email = result['email'] as String;
      final name = result['name'] as String;
      final microsoftId = result['id'] as String;

      devLog('Microsoft sign-in successful', params: {'email': email});

      // Check 1: Must be @pmlil.com domain
      if (!MicrosoftAuthService.isValidPmilDomain(email)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only @pmlil.com email accounts are allowed'),
              backgroundColor: AppTheme.error,
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Check 2: Cannot be receptionist email
      if (MicrosoftAuthService.isReceptionistEmail(email)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Receptionist accounts cannot access staff dashboard. Please use the Receptionist/Visitor option.',
              ),
              backgroundColor: AppTheme.error,
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Check 3: Is staff already registered?
      final existingStaff = await StaffService.getStaffByEmail(email);

      if (existingStaff != null) {
        // Staff is already registered - log them in
        devLog('Staff already registered, logging in');

        await StaffService.setStaffLoggedIn(
          true,
          email: email,
          name: existingStaff['name'],
          userId: existingStaff['id'],
          departmentId: existingStaff['departmentId'],
          departmentName: existingStaff['departmentName'],
          accessToken: result['accessToken'],
        );

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/staff-dashboard');
        }
      } else {
        // Staff is new - send to registration screen
        devLog('New staff member, navigating to registration');

        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/staff-registration',
            arguments: {
              'microsoftId': microsoftId,
              'email': email,
              'name': name,
              'accessToken': result['accessToken'],
            },
          );
        }
      }
    } catch (e) {
      devLog('Sign-in error', params: {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

                              // Title
                              const Text('Staff Login', style: AppTheme.h2),

                              const SizedBox(height: 8),

                              // Subtitle
                              const Text(
                                'Sign in with your Microsoft account',
                                style: AppTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 32),

                              // Microsoft Sign-In Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : _signInWithMicrosoft,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: AppTheme.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/microsoft_logo.png',
                                          width: 24,
                                          height: 24,
                                          errorBuilder:
                                              (context, error, stack) =>
                                                  const Icon(
                                                    Icons.business,
                                                    size: 24,
                                                  ),
                                        ),
                                  label: Text(
                                    _isLoading
                                        ? 'Signing in...'
                                        : 'Sign in with Microsoft',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.info,
                                    foregroundColor: AppTheme.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppTheme.radiusSmall,
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Info Box
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.info.withOpacity(0.1),
                                  borderRadius: AppTheme.radiusSmall,
                                  border: Border.all(
                                    color: AppTheme.info.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.info_outline,
                                          size: 18,
                                          color: AppTheme.info,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Staff Members Only',
                                          style: AppTheme.labelLarge,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Use your @pmlil.com staff account to access your visitor dashboard.',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondary,
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
