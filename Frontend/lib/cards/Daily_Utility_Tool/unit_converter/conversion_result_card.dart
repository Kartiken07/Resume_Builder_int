import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ConversionResultCard extends StatelessWidget {
  const ConversionResultCard({
    required this.inputValue,
    required this.fromUnit,
    required this.toUnit,
    required this.result,
    super.key,
  });

  final String inputValue;
  final String fromUnit;
  final String toUnit;
  final double result;

  String _formatResult(double value) {
    if (value == value.toInt()) return value.toInt().toString();
    String formatted = value.toStringAsFixed(6);
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.cardPaddingH),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Text('$inputValue $fromUnit', style: AppTheme.bodyLarge),
          const SizedBox(height: AppTheme.spacingSmall),
          Icon(Icons.arrow_downward_rounded, color: AppTheme.accent),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            '${_formatResult(result)} $toUnit',
            style: AppTheme.headingSmall.copyWith(color: AppTheme.accent),
          ),
        ],
      ),
    );
  }
}
