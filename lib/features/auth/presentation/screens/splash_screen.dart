import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _logoAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();

    _navigationTimer = Timer(
      const Duration(milliseconds: 2200),
      _checkAuthAndNavigate,
    );
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = colorScheme.surface;

    final primaryColor = colorScheme.primary;

    final primaryTextColor = colorScheme.onSurface;

    final secondaryTextColor = colorScheme.onSurfaceVariant;

    final gridColor = primaryColor.withValues(alpha: isDark ? 0.035 : 0.055);

    final glowOpacity = isDark ? 0.12 : 0.07;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // ==================================================
          // BACKGROUND
          // ==================================================
          Positioned.fill(
            child: CustomPaint(
              painter: _SplashBackgroundPainter(
                primaryColor: primaryColor,
                gridColor: gridColor,
                glowOpacity: glowOpacity,
              ),
            ),
          ),

          // ==================================================
          // CENTRAL GLOW
          // ==================================================
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      primaryColor.withValues(alpha: glowOpacity),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==================================================
          // MAIN CONTENT
          // ==================================================
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==================================================
                    // LOGO
                    // ==================================================
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.85 + (_logoAnimation.value * 0.15),
                          child: Opacity(
                            opacity: _logoAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: _BrivoraLogo(glowColor: primaryColor),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // APP NAME
                    // ==================================================
                    Text(
                      'Brivora',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.4,
                        height: 1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // SUBTITLE
                    // ==================================================
                    Text(
                      'PROJECT MANAGEMENT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: secondaryTextColor.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.8,
                        height: 1,
                      ),
                    ),

                    const SizedBox(height: 42),

                    // ==================================================
                    // LOADING INDICATOR
                    // ==================================================
                    _SplashProgressIndicator(
                      color: primaryColor,
                      backgroundColor: colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.08 : 0.10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================
          // BOTTOM LABEL
          // ==================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Text(
              'BRIVORA',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: secondaryTextColor.withValues(
                  alpha: isDark ? 0.30 : 0.45,
                ),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BRIVORA LOGO
// ============================================================

class _BrivoraLogo extends StatelessWidget {
  final Color glowColor;

  const _BrivoraLogo({required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.28),
            blurRadius: 38,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          'assets/icons/splash.png',
          width: 104,
          height: 104,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ============================================================
// SPLASH PROGRESS INDICATOR
// ============================================================

class _SplashProgressIndicator extends StatefulWidget {
  final Color color;
  final Color backgroundColor;

  const _SplashProgressIndicator({
    required this.color,
    required this.backgroundColor,
  });

  @override
  State<_SplashProgressIndicator> createState() =>
      _SplashProgressIndicatorState();
}

class _SplashProgressIndicatorState extends State<_SplashProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 3,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ProgressPainter(
              color: widget.color,
              backgroundColor: widget.backgroundColor,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;
  final double progress;

  const _ProgressPainter({
    required this.color,
    required this.backgroundColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final backgroundRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );

    canvas.drawRRect(backgroundRect, backgroundPaint);

    final width = size.width * 0.32;

    final start = (size.width + width) * progress - width;

    final foregroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(start, 0, width, size.height),
      const Radius.circular(4),
    );

    canvas.save();

    canvas.clipRect(Offset.zero & size);

    canvas.drawRRect(foregroundRect, foregroundPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

// ============================================================
// SPLASH BACKGROUND
// ============================================================

class _SplashBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color gridColor;
  final double glowOpacity;

  const _SplashBackgroundPainter({
    required this.primaryColor,
    required this.gridColor,
    required this.glowOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ==================================================
    // GRID
    // ==================================================

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColor;

    const gridSize = 52.0;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ==================================================
    // CENTRAL GLOW
    // ==================================================

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              primaryColor.withValues(alpha: glowOpacity),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.5, size.height * 0.42),
              radius: size.width * 0.55,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.42),
      size.width * 0.55,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashBackgroundPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.glowOpacity != glowOpacity;
  }
}
