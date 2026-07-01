import 'package:flutter/material.dart';
import '../../utils/ResumeBuilder/constants.dart';

/// A premium glassmorphic tag or chip component.
/// Displays text labels with optional icons and delete/action buttons.
class FeatureChip extends StatelessWidget {
  const FeatureChip({
    super.key,
    required this.label,
    this.icon,
    this.onDeleted,
    this.accentColor = kAccentCyan,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onDeleted;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kGlassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kGlassBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: accentColor,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDeleted,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: kAccentPink.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
