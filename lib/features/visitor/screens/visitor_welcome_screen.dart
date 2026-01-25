import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/pin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../admin/widgets/pin_dialog.dart';
import '../widgets/carousel_section.dart';
import 'checkin_screen.dart';

class VisitorWelcomeScreen extends StatefulWidget {
  const VisitorWelcomeScreen({Key? key}) : super(key: key);

  @override
  State<VisitorWelcomeScreen> createState() => _VisitorWelcomeScreenState();
}

class _VisitorWelcomeScreenState extends State<VisitorWelcomeScreen> {
  int _currentSlide = 0;
  List<String> _slideUrls = [];
  bool _isLoadingSlides = true;

  @override
  void initState() {
    super.initState();
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('welcome_slider')
          .orderBy('order')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _slideUrls = snapshot.docs
              .map((doc) {
                final data = doc.data();
                return data['imageUrl'] as String? ?? '';
              })
              .where((url) => url.isNotEmpty)
              .toList();
          _isLoadingSlides = false;
        });
      } else {
        setState(() {
          _slideUrls = [];
          _isLoadingSlides = false;
        });
      }
    } catch (e) {
      devLog('Error loading slides: $e');
      setState(() {
        _slideUrls = [];
        _isLoadingSlides = false;
      });
    }
  }

  Future<void> _handleAdminAccess(BuildContext context) async {
    devLog('Admin button pressed');
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!context.mounted) return;

    final enteredPin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PinDialog(),
    );

    if (enteredPin == null || enteredPin.isEmpty) return;

    final isValidPin = await PinService.verifyPin(enteredPin);
    if (!context.mounted) return;

    if (!isValidPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect PIN code'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (isLoggedIn) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
    } else {
      Navigator.of(context).pushNamed('/admin-login');
    }
  }

  void _onCheckIn() {
    devLog('Check In Now button pressed');
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CheckInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                final isLandscape = orientation == Orientation.landscape;

                if (isTablet && isLandscape) {
                  return _buildLandscapeLayout(context, constraints);
                }

                return _buildPortraitLayout(context, constraints, isTablet);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final isSmallHeight = constraints.maxHeight < 500;

    return Row(
      children: [
        // LEFT: Carousel (takes more space)
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CarouselSection(
              slideUrls: _slideUrls,
              isLoadingSlides: _isLoadingSlides,
              currentSlide: _currentSlide,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() => _currentSlide = index);
                }
              },
            ),
          ),
        ),

        // RIGHT: Content
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallHeight ? 24 : 40,
                vertical: 24,
              ),
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Branding
                  _buildBrandingSection(compact: isSmallHeight),
                  SizedBox(height: isSmallHeight ? 24 : 48),

                  // Welcome Section
                  _buildWelcomeSection(compact: isSmallHeight),

                  SizedBox(height: isSmallHeight ? 24 : 32),

                  // Footer
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    BoxConstraints constraints,
    bool isTablet,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 40 : 24,
          vertical: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Branding
            _buildBrandingSection(),

            const SizedBox(height: 32),

            // Carousel
            SizedBox(
              height: isTablet ? 400 : 300,
              child: CarouselSection(
                slideUrls: _slideUrls,
                isLoadingSlides: _isLoadingSlides,
                currentSlide: _currentSlide,
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() => _currentSlide = index);
                  }
                },
              ),
            ),

            const SizedBox(height: 48),

            // Welcome Section
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 500 : double.infinity,
              ),
              child: _buildWelcomeSection(),
            ),

            const SizedBox(height: 40),

            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingSection({bool compact = false}) {
    return Column(
      children: [
        // Pass Point Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: compact ? 48 : 56,
              height: compact ? 48 : 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryRed, AppTheme.primaryRedDark],
                ),
                borderRadius: BorderRadius.circular(compact ? 14 : 16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.business,
                color: AppTheme.white,
                size: compact ? 28 : 32,
              ),
            ),
            SizedBox(width: compact ? 12 : 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pass Point',
                  style: TextStyle(
                    fontSize: compact ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
                Text(
                  'Visitor Management',
                  style: TextStyle(
                    fontSize: compact ? 10 : 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: compact ? 12 : 16),

        // Powered by Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 20,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.dark.withOpacity(0.95), AppTheme.darkLight],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: compact ? 14 : 16,
                color: AppTheme.white,
              ),
              SizedBox(width: compact ? 6 : 8),
              Text(
                'Powered by ',
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  color: AppTheme.white.withOpacity(0.8),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    AppTheme.primaryRed,
                    AppTheme.info,
                    AppTheme.success,
                  ],
                ).createShader(bounds),
                child: Text(
                  'Nexora AI',
                  style: TextStyle(
                    fontSize: compact ? 12 : 14,
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection({bool compact = false}) {
    return Column(
      children: [
        // Welcome Text
        Text(
          'Welcome!',
          style: TextStyle(
            fontSize: compact ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          'Please check in to notify your host',
          style: TextStyle(
            fontSize: compact ? 14 : 16,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: compact ? 24 : 40),

        // Check In Button
        SizedBox(
          width: double.infinity,
          height: compact ? 52 : 64,
          child: ElevatedButton(
            onPressed: _onCheckIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(compact ? 14 : 16),
              ),
              elevation: 8,
              shadowColor: AppTheme.primaryRed.withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: compact ? 22 : 28),
                SizedBox(width: compact ? 12 : 16),
                Text(
                  'Check In Now',
                  style: TextStyle(
                    fontSize: compact ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: compact ? 8 : 12),
                Icon(Icons.arrow_forward_rounded, size: compact ? 20 : 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          '© 2025 PassPoint. All rights reserved.',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Admin Dashboard button (with PIN protection)
        TextButton.icon(
          onPressed: () => _handleAdminAccess(context),
          icon: const Icon(Icons.shield_outlined, size: 16),
          label: const Text('Admin Dashboard', style: TextStyle(fontSize: 13)),
          style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
