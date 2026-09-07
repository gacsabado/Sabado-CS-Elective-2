import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class HeroBannerSlider extends StatefulWidget {
  const HeroBannerSlider({super.key});

  @override
  State<HeroBannerSlider> createState() => _HeroBannerSliderState();
}

class _HeroBannerSliderState extends State<HeroBannerSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentIndex + 1) % featuredBanners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.85,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: featuredBanners.length,
            itemBuilder: (context, index) {
              final banner = featuredBanners[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    alignment: banner.alignment,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.black87),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Image.asset(
                      'assets/HIRONO.webp',
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Failed to load asset image: $error');
                        return Container(
                          color: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: const Text(
                            'HIRONO (Asset Not Found)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 16,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          banner.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFE55322),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(blurRadius: 8, color: Colors.black),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          banner.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                featuredBanners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 2.5,
                  width: _currentIndex == index ? 28 : 16,
                  color: _currentIndex == index ? Colors.white : Colors.white38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}