import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dev.log.dart';

class CarouselSection extends StatelessWidget {
  final List<String> slideUrls;
  final bool isLoadingSlides;
  final int currentSlide;
  final Function(int) onPageChanged;

  const CarouselSection({
    Key? key,
    required this.slideUrls,
    required this.isLoadingSlides,
    required this.currentSlide,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoadingSlides) {
      return _buildLoadingState();
    }

    return slideUrls.isEmpty
        ? _buildDefaultCarousel()
        : _buildFirestoreCarousel();
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.greyLight,
        borderRadius: AppTheme.radiusLarge,
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      ),
    );
  }

  Widget _buildFirestoreCarousel() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: AppTheme.radiusLarge,
        child: Stack(
          children: [
            CarouselSlider.builder(
              key: ValueKey(slideUrls.length),
              itemCount: slideUrls.length,
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                autoPlay: slideUrls.length > 1,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                autoPlayCurve: Curves.easeInOutCubic,
                enableInfiniteScroll: slideUrls.length > 1,
                pauseAutoPlayOnTouch: true,
                onPageChanged: (index, reason) {
                  onPageChanged(index);
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return _buildSlideItem(slideUrls[index], index);
              },
            ),

            // Indicator Dots
            if (slideUrls.length > 1)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(slideUrls.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: currentSlide == index ? 32 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: currentSlide == index
                            ? AppTheme.primaryRed
                            : AppTheme.white.withOpacity(0.5),
                        boxShadow: currentSlide == index
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryRed.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCarousel() {
    final defaultImages = [
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200',
      'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=1200',
      'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=1200',
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.radiusLarge,
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: AppTheme.radiusLarge,
        child: Stack(
          children: [
            CarouselSlider.builder(
              itemCount: defaultImages.length,
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                autoPlayCurve: Curves.easeInOutCubic,
                pauseAutoPlayOnTouch: true,
                onPageChanged: (index, reason) {
                  onPageChanged(index);
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return _buildSlideItem(defaultImages[index], index);
              },
            ),

            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(defaultImages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: currentSlide == index ? 32 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: currentSlide == index
                          ? AppTheme.primaryRed
                          : AppTheme.white.withOpacity(0.5),
                      boxShadow: currentSlide == index
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryRed.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideItem(String imageUrl, int index) {
    return Container(
      key: ValueKey('slide_$index\_$imageUrl'),
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.background,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          devLog('Image load error for $imageUrl: $error');
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryRed.withOpacity(0.8),
                  AppTheme.primaryRedDark,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: AppTheme.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Image unavailable',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppTheme.background,
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
    );
  }
}
