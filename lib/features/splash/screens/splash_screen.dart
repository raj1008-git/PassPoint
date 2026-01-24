import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    _navigateToRoleSelection();
  }

  Future<void> _navigateToRoleSelection() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    devLog('Navigating to Role Selection Screen');

    // UPDATED: Navigate to role selection instead of checking auth
    Navigator.of(context).pushReplacementNamed('/role-selection');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryRed, AppTheme.primaryRedDark],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              final isSmallHeight = constraints.maxHeight < 500;

              if (isLandscape) {
                return _buildLandscapeLayout(constraints, isSmallHeight);
              }

              return _buildPortraitLayout(constraints);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: constraints.maxHeight * 0.1),

              // Animated Logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.business,
                      size: 64,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'PassPoint',
                      style: AppTheme.h1.copyWith(
                        color: AppTheme.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Streamlined visitor management',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: constraints.maxHeight * 0.15),

              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLoadingIndicator(),
              ),

              SizedBox(height: constraints.maxHeight * 0.1),

              // Powered by
              FadeTransition(opacity: _fadeAnimation, child: _buildPoweredBy()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BoxConstraints constraints, bool isSmallHeight) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
            vertical: isSmallHeight ? 16 : 24,
          ),
          child: Row(
            children: [
              // LEFT: Logo and Name
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: isSmallHeight ? 80 : 100,
                          height: isSmallHeight ? 80 : 100,
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(
                              isSmallHeight ? 18 : 20,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.business,
                            size: isSmallHeight ? 48 : 56,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallHeight ? 16 : 24),

                    // App Name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'PassPoint',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: isSmallHeight ? 32 : 38,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: isSmallHeight ? 6 : 8),
                          Text(
                            'Streamlined visitor management',
                            style: TextStyle(
                              color: AppTheme.white.withOpacity(0.9),
                              fontSize: isSmallHeight ? 13 : 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: isSmallHeight ? 120 : 160,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.white.withOpacity(0.0),
                      AppTheme.white.withOpacity(0.3),
                      AppTheme.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),

              // RIGHT: Loading and Powered By
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading Indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLoadingIndicator(compact: isSmallHeight),
                    ),

                    SizedBox(height: isSmallHeight ? 24 : 32),

                    // Powered by
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildPoweredBy(compact: isSmallHeight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator({bool compact = false}) {
    return Column(
      children: [
        // Three Dots Loading Animation
        SizedBox(
          width: compact ? 60 : 80,
          height: compact ? 20 : 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -8 * (value * (index % 2 == 0 ? 1 : -1)).abs(),
                    ),
                    child: Container(
                      width: compact ? 10 : 12,
                      height: compact ? 10 : 12,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.white.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onEnd: () {
                  if (mounted) {
                    setState(() {});
                  }
                },
              );
            }),
          ),
        ),
        SizedBox(height: compact ? 16 : 24),
        Text(
          'Loading...',
          style: TextStyle(
            color: AppTheme.white.withOpacity(0.9),
            fontSize: compact ? 13 : 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPoweredBy({bool compact = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 16 : 32),
      child: Column(
        children: [
          Text(
            'Powered by',
            style: TextStyle(
              color: AppTheme.white.withOpacity(0.7),
              fontSize: compact ? 11 : 12,
            ),
          ),
          SizedBox(height: compact ? 4 : 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: compact ? 16 : 18,
                color: AppTheme.white.withOpacity(0.9),
              ),
              SizedBox(width: compact ? 6 : 8),
              Text(
                'Nexora AI',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: compact ? 15 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
