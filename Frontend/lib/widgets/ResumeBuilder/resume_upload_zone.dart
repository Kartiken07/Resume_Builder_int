import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/ResumeBuilder/constants.dart';
import '../../cards/ResumeBuilder/glass_card.dart';

/// Reusable resume upload zone.
/// Renders a dotted-border container with custom animations and a loading indicator
/// when parsing/uploading.
class ResumeUploadZone extends StatelessWidget {
  const ResumeUploadZone({
    super.key,
    required this.isAutoFilling,
    required this.onTap,
  });

  final bool isAutoFilling;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(kCardBorderRadius),
        color: kAccentCyan.withValues(alpha: 0.4),
        strokeWidth: 1.5,
        dashPattern: const [8, 6],
        child: InkWell(
          onTap: isAutoFilling ? null : onTap,
          borderRadius: BorderRadius.circular(kCardBorderRadius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Column(
              children: [
                if (isAutoFilling)
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(kAccentCyan),
                    ),
                  )
                else
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kAccentCyan.withValues(alpha: 0.1),
                      border: Border.all(
                        color: kAccentCyan.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(
                      Icons.upload_file_rounded,
                      size: 26,
                      color: kAccentCyan.withValues(alpha: 0.8),
                    ),
                  )
                      .animate(
                        onPlay: (c) => c.repeat(reverse: true),
                      )
                      .scaleXY(
                        begin: 1.0,
                        end: 1.08,
                        duration: 2.seconds,
                        curve: Curves.easeInOut,
                      ),
                const SizedBox(height: 14),
                Text(
                  isAutoFilling
                      ? 'AI is parsing your resume...'
                      : 'Drop your old resume to auto-fill',
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Supports TXT and PDF formats',
                  style: TextStyle(
                    color: kTextTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
