import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/ResumeBuilder/constants.dart';

/// Wraps a child widget in a continuous vertical floating animation.
///
/// Creates a smooth, infinite up-down drift on the y-axis to achieve
/// the "floating" modern view. Uses [flutter_animate] with mirror repeat.
class FloatingWrapper extends StatelessWidget {
  const FloatingWrapper({
    super.key,
    required this.child,
    this.amplitude = kFloatingAmplitude,
    this.duration = kFloatingDuration,
    this.delay = Duration.zero,
  });

  final Widget child;
  final double amplitude;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(
          delay: delay,
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .moveY(
          begin: -amplitude / 2,
          end: amplitude / 2,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}
