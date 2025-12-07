import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/pin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../admin/widgets/pin_dialog.dart';
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
    return Row(
      children: [
        // LEFT: Carousel
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
            child: _buildCarouselSection(),
          ),
        ),

        // RIGHT: Content
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWelcomeCard(context, compact: true),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.schedule,
                          iconColor: AppTheme.info,
                          title: 'Quick Process',
                          subtitle: 'Under 2 minutes',
                          compact: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.notifications_active,
                          iconColor: AppTheme.success,
                          title: 'Instant Alert',
                          subtitle: 'Immediate notification',
                          compact: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.security,
                          iconColor: AppTheme.totalPurpleIcon,
                          title: 'Secure',
                          subtitle: 'Protected & encrypted',
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
    final maxWidth = isTablet ? 600.0 : constraints.maxWidth * 0.9;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Carousel
              SizedBox(
                width: maxWidth,
                height: isTablet ? 320 : 260,
                child: _buildCarouselSection(),
              ),

              const SizedBox(height: 40),

              // Welcome Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: maxWidth,
                  child: _buildWelcomeCard(context, compact: false),
                ),
              ),

              const SizedBox(height: 32),

              // Features
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: maxWidth,
                  child: Row(
                    children: const [
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.schedule,
                          iconColor: AppTheme.info,
                          title: 'Quick Process',
                          subtitle: 'Complete check-in in under 2 minutes',
                          compact: false,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.notifications_active,
                          iconColor: AppTheme.success,
                          title: 'Instant Notification',
                          subtitle: 'Your host will be notified immediately',
                          compact: false,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.security,
                          iconColor: AppTheme.totalPurpleIcon,
                          title: 'Secure & Private',
                          subtitle: 'Your data is protected and encrypted',
                          compact: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _isLoadingSlides
          ? Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: AppTheme.radiusLarge,
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed),
              ),
            )
          : _slideUrls.isEmpty
          ? _buildDefaultCarousel()
          : _buildFirestoreCarousel(),
    );
  }

  Widget _buildFirestoreCarousel() {
    return Stack(
      children: [
        CarouselSlider.builder(
          key: ValueKey(_slideUrls.length), // Stable key based on count
          itemCount: _slideUrls.length,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1.0,
            autoPlay: _slideUrls.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut,
            enableInfiniteScroll: _slideUrls.length > 1,
            pauseAutoPlayOnTouch: true,
            onPageChanged: (index, reason) {
              if (mounted) {
                setState(() => _currentSlide = index);
              }
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return _buildSlideItem(_slideUrls[index], index);
          },
        ),

        // Indicator Dots (only show if more than 1 slide)
        if (_slideUrls.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slideUrls.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentSlide == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentSlide == index
                        ? AppTheme.white
                        : AppTheme.white.withOpacity(0.4),
                  ),
                );
              }),
            ),
          ),

        // Branding
        _buildBrandingOverlay(),
      ],
    );
  }

  Widget _buildDefaultCarousel() {
    final defaultImages = [
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200',
      'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=1200',
      'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=1200',
    ];

    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: defaultImages.length,
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut,
            pauseAutoPlayOnTouch: true,
            onPageChanged: (index, reason) {
              if (mounted) {
                setState(() => _currentSlide = index);
              }
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return _buildSlideItem(defaultImages[index], index);
          },
        ),

        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(defaultImages.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentSlide == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentSlide == index
                      ? AppTheme.white
                      : AppTheme.white.withOpacity(0.4),
                ),
              );
            }),
          ),
        ),

        _buildBrandingOverlay(),
      ],
    );
  }

  Widget _buildSlideItem(String imageUrl, int index) {
    return Container(
      key: ValueKey('slide_$index\_$imageUrl'), // Unique key per slide
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: AppTheme.radiusLarge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                devLog('Image load error for $imageUrl: $error');
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryRed, AppTheme.primaryRedDark],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.business, size: 80, color: AppTheme.white),
                        SizedBox(height: 16),
                        Text(
                          'Image unavailable',
                          style: TextStyle(color: AppTheme.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryRed,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingOverlay() {
    return Positioned(
      top: 30,
      left: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: AppTheme.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pass Point',
                  style: AppTheme.h3.copyWith(
                    color: AppTheme.primaryRed,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: AppTheme.white),
                const SizedBox(width: 8),
                Text(
                  'Powered by ',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppTheme.primaryRed,
                      AppTheme.info,
                      AppTheme.success,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Nexora AI',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, {required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 28 : 32),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        children: [
          Container(
            width: compact ? 60 : 80,
            height: compact ? 60 : 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              borderRadius: BorderRadius.circular(compact ? 14 : 20),
            ),
            child: Icon(
              Icons.person_add,
              size: compact ? 30 : 40,
              color: AppTheme.white,
            ),
          ),
          SizedBox(height: compact ? 16 : 24),
          Text(
            'Welcome to Our Office',
            style: compact
                ? AppTheme.labelLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )
                : AppTheme.h3,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            'Please check in to notify your host of your arrival',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontSize: compact ? 13 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: compact ? 20 : 32),
          SizedBox(
            width: double.infinity,
            height: compact ? 48 : 56,
            child: ElevatedButton(
              onPressed: () {
                devLog('Check In Now button pressed');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CheckInScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: compact ? 20 : 24),
                  SizedBox(width: compact ? 8 : 12),
                  Text(
                    'Check In Now',
                    style: TextStyle(
                      fontSize: compact ? 16 : 18,
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

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          '© 2025 VisitorEase. All rights reserved.',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => _handleAdminAccess(context),
          icon: const Icon(Icons.shield_outlined, size: 18),
          label: const Text('Admin Dashboard'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.dark),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool compact;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: compact ? 40 : 48,
            height: compact ? 40 : 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(compact ? 10 : 12),
            ),
            child: Icon(icon, color: iconColor, size: compact ? 20 : 24),
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            title,
            style: compact
                ? AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)
                : AppTheme.labelLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: compact ? 4 : 6),
          Text(
            subtitle,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontSize: compact ? 10 : 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
