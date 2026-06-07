import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';

/// Splash screen displayed on app launch.
///
/// Runs the branding animation while [AuthNotifier.build] restores any
/// persisted session, then routes to Home if a user was restored and
/// Login otherwise.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
          ),
        );

    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    _routeAfterSplash();
  }

  /// Waits for the branding animation and the initial auth check to
  /// both complete, then replaces this screen with Home or Login.
  Future<void> _routeAfterSplash() async {
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 2800));
    User? user;
    try {
      final results = await Future.wait([
        minDelay,
        ref.read(authProvider.future),
      ]);
      user = results[1] as User?;
    } catch (_) {
      await minDelay;
      user = null;
    }

    if (!mounted) return;
    final route = user != null ? Routes.home : Routes.login;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DetectooColors.canvasCream,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Faint seedling watermark, bottom-left.
            Positioned(
              bottom: -10,
              left: -20,
              child: Icon(
                Icons.eco_rounded,
                size: 220,
                color: DetectooColors.green600.withValues(alpha: 0.05),
              ),
            ),
            // Progress line + eyebrow at the bottom.
            Positioned(
              bottom: 56,
              left: 60,
              right: 60,
              child: AnimatedBuilder(
                animation: _loaderOpacity,
                builder: (context, _) {
                  return Opacity(
                    opacity: _loaderOpacity.value,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            backgroundColor: DetectooColors.green100,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              DetectooColors.green600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'INITIALISING AI CORE',
                          style: DetectooText.eyebrow.copyWith(
                            color: DetectooColors.textMuted,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Main content.
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo lockup: app tile + wordmark.
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: DetectooColors.green600,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  size: 26,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'detect',
                                      style: DetectooText.h2.copyWith(
                                        color: DetectooColors.green900,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'oo',
                                      style: DetectooText.h2.copyWith(
                                        color: DetectooColors.green500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 64),
                      // App name + tagline.
                      SlideTransition(
                        position: _textSlide,
                        child: Opacity(
                          opacity: _textOpacity.value,
                          child: Column(
                            children: [
                              Text(
                                'Detectoo',
                                style: DetectooText.h1.copyWith(
                                  color: DetectooColors.green700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'The Digital Curator for your Garden.',
                                textAlign: TextAlign.center,
                                style: DetectooText.body.copyWith(
                                  color: DetectooColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
