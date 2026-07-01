import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/ResumeBuilder/constants.dart';

/// A full-screen animated gradient background using [CustomPainter].
///
/// Draws organic, slowly drifting gradient blobs to create a living,
/// premium dark background. The colors shift between deep navy,
/// violet, and cyan.
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, this.child});

  final Widget? child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark layer
        Container(color: kBackgroundDark),
        // Animated blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _GradientBlobPainter(progress: _controller.value),
              size: Size.infinite,
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _GradientBlobPainter extends CustomPainter {
  _GradientBlobPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Blob 1: Cyan — top-right area
    _drawBlob(
      canvas,
      center: Offset(
        w * 0.75 + math.sin(progress * 2 * math.pi) * w * 0.08,
        h * 0.2 + math.cos(progress * 2 * math.pi) * h * 0.06,
      ),
      radius: w * 0.4,
      color: kAccentCyan.withValues(alpha: 0.07),
    );

    // Blob 2: Violet — center-left area
    _drawBlob(
      canvas,
      center: Offset(
        w * 0.25 + math.cos(progress * 2 * math.pi + 1) * w * 0.1,
        h * 0.5 + math.sin(progress * 2 * math.pi + 1) * h * 0.08,
      ),
      radius: w * 0.45,
      color: kAccentViolet.withValues(alpha: 0.06),
    );

    // Blob 3: Pink — bottom-right area
    _drawBlob(
      canvas,
      center: Offset(
        w * 0.7 + math.sin(progress * 2 * math.pi + 2.5) * w * 0.07,
        h * 0.8 + math.cos(progress * 2 * math.pi + 2.5) * h * 0.05,
      ),
      radius: w * 0.35,
      color: kAccentPink.withValues(alpha: 0.04),
    );
  }

  void _drawBlob(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBlobPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
