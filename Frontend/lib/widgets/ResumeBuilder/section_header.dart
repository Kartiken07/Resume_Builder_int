import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/ResumeBuilder/constants.dart';

/// A reusable header component featuring a prominent Outfit title
/// with a gradient accent icon and an optional subtitle.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.prefixIcon,
    this.trailing,
    this.titleColor = kTextPrimary,
    this.subtitleColor = kTextSecondary,
    this.accentColor = kAccentCyan,
  });

  final String title;
  final String? subtitle;
  final IconData? prefixIcon;
  final Widget? trailing;
  final Color titleColor;
  final Color subtitleColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: accentColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                prefixIcon,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
