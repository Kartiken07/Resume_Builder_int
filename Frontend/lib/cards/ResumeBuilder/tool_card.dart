import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/ResumeBuilder/tool_item.dart';
import '../../utils/ResumeBuilder/constants.dart';
import 'glass_card.dart';

/// A single tool card for the dashboard grid.
class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.tool,
  });

  final ToolItem tool;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderGradient: tool.gradientColors,
      onTap: () => context.push(tool.route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  tool.gradientColors[0].withValues(alpha: 0.2),
                  tool.gradientColors[1].withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              tool.icon,
              color: tool.gradientColors[0],
              size: 24,
            ),
          ),

          const SizedBox(height: 16),

          // Tool name
          Text(
            tool.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // Description
          Expanded(
            child: Text(
              tool.description,
              style: const TextStyle(
                fontSize: 12,
                color: kTextTertiary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Arrow indicator
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: tool.gradientColors[0].withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
