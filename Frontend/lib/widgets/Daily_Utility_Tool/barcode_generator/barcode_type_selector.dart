import 'package:flutter/material.dart';

import '../../../models/Daily_Utility_Tool/barcode_model.dart';
import '../../../theme/app_theme.dart';

class BarcodeTypeSelector extends StatelessWidget {
  const BarcodeTypeSelector({
    required this.currentValue,
    required this.onSelected,
    super.key,
  });

  final BarcodeType currentValue;
  final ValueChanged<BarcodeType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Barcode Type', style: AppTheme.labelMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BarcodeType.values.map((type) {
            final isSelected = type == currentValue;
            return GestureDetector(
              onTap: () => onSelected(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accent
                      : AppTheme.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accent
                        : AppTheme.borderLight,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  type.label,
                  style: AppTheme.labelSmall.copyWith(
                    color: isSelected ? AppTheme.background : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}