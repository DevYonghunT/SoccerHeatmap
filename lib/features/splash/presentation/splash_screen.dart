import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/ad_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _subtitleOpacity;

  final AdService _adService = AdService();
  bool _adLoaded = false;
  bool _animationDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Load interstitial ad
    _adService.loadInterstitialAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() => _adLoaded = true);
          _tryShowAd();
        }
      },
    );

    // Minimum splash duration: 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _animationDone = true;
        _tryShowAd();
      }
    });
  }

  void _tryShowAd() {
    if (_navigated) return;

    if (_animationDone && _adLoaded) {
      // Show ad, then navigate
      _navigated = true;
      _adService.showInterstitialAd(
        onAdDismissed: () => _navigateToDashboard(),
      );
    } else if (_animationDone && !_adLoaded) {
      // Timeout: navigate without ad after 4 seconds total
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && !_navigated) {
          _navigated = true;
          if (_adService.isInterstitialReady) {
            _adService.showInterstitialAd(
              onAdDismissed: () => _navigateToDashboard(),
            );
          } else {
            _navigateToDashboard();
          }
        }
      });
    }
  }

  void _navigateToDashboard() {
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Logo
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Column(
                      children: [
                        // App icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.sports_soccer,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Brand name
                        Text(
                          'KICKOFF',
                          style: GoogleFonts.sora(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Opacity(
                  opacity: _subtitleOpacity.value,
                  child: Text(
                    '나의 축구를 기록하다',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // Loading indicator
                Opacity(
                  opacity: _subtitleOpacity.value,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}
