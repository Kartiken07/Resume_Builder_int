import 'package:flutter/material.dart';
import '../../utils/ResumeBuilder/constants.dart';

enum StatusType { pending, processing, success, failed, info }

/// A pill-shaped status badge for showing states like "Pending",
/// "Success", "Failed", or "AI Active".
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.info,
    this.customColor,
  });

  final String label;
  final StatusType type;
  final Color? customColor;

  Color _getColor() {
    if (customColor != null) return customColor!;
    switch (type) {
      case StatusType.pending:
        return kAccentOrange;
      case StatusType.processing:
        return kAccentCyan;
      case StatusType.success:
        return kAccentGreen;
      case StatusType.failed:
        return kAccentPink;
      case StatusType.info:
        return kAccentBlue;
    }
  }

  IconData? _getIcon() {
    switch (type) {
      case StatusType.pending:
        return Icons.hourglass_empty_rounded;
      case StatusType.processing:
        return Icons.sync_rounded;
      case StatusType.success:
        return Icons.check_circle_rounded;
      case StatusType.failed:
        return Icons.error_rounded;
      case StatusType.info:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
