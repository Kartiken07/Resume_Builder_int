import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/ResumeBuilder/constants.dart';

/// A frosted-glass loading spinner with a rotating gradient arc.
///
/// Displays inside a glassmorphic container with an optional
/// status message underneath.
class GlassLoadingSpinner extends StatefulWidget {
  const GlassLoadingSpinner({
    super.key,
    this.message = 'Processing...',
    this.size = 80,
  });

  final String message;
  final double size;

  @override
  State<GlassLoadingSpinner> createState() => _GlassLoadingSpinnerState();
}

class _GlassLoadingSpinnerState extends State<GlassLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glassmorphic container with spinning arc
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: widget.size + 40,
              height: widget.size + 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kGlassHighlight, kGlassFill],
                ),
                border: Border.all(color: kGlassBorder, width: 1),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _SpinnerPainter(
                        progress: _controller.value,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Status text
        Text(
          widget.message,
          style: const TextStyle(
            color: kTextSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background ring
    final bgPaint = Paint()
      ..color = kGlassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient arc
    final sweepAngle = 1.8; // ~103 degrees
    final startAngle = progress * 2 * math.pi;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: const [kAccentCyan, kAccentViolet],
        tileMode: TileMode.clamp,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
