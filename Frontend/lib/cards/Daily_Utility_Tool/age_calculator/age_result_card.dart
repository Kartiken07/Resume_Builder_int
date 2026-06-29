import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class AgeResultCard extends StatelessWidget {
  const AgeResultCard({required this.title, required this.value, super.key});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.cardMarginBottom),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.cardPaddingH,
        vertical: AppTheme.cardPaddingV,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.cardLabelStyle),
          Text(value, style: AppTheme.cardValueStyle),
        ],
      ),
    );
  }
}
