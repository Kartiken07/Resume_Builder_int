import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/ResumeBuilder/constants.dart';

/// A pulsing glassmorphic upload button with a glowing ring animation.
///
/// Designed as a prominent call-to-action for file upload operations.
/// The button pulses continuously to attract attention and triggers
/// the provided [onPressed] callback when tapped.
class AnimatedUploadButton extends StatelessWidget {
  const AnimatedUploadButton({
    super.key,
    required this.onPressed,
    this.label = 'Upload File',
    this.icon = Icons.cloud_upload_rounded,
    this.gradient,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final List<Color>? gradient;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? [kAccentCyan, kAccentViolet];

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kButtonBorderRadius),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(kBackgroundDark),
                ),
              )
            else
              Icon(icon, color: kBackgroundDark, size: 22),
            const SizedBox(width: 12),
            Text(
              isLoading ? 'Processing...' : label,
              style: const TextStyle(
                color: kBackgroundDark,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .scaleXY(
            begin: 1.0,
            end: 1.03,
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
          )
          .then()
          .shimmer(
            duration: const Duration(seconds: 3),
            color: Colors.white.withValues(alpha: 0.15),
          ),
    );
  }
}
