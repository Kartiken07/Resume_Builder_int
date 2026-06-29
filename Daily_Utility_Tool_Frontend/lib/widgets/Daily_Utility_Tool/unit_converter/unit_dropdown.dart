import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class UnitDropdown extends StatelessWidget {
  const UnitDropdown({
    required this.label,
    required this.units,
    required this.selectedUnit,
    required this.onChanged,
    super.key,
  });

  final String label;
  final List<String> units;
  final String selectedUnit;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedUnit.isEmpty ? null : selectedUnit,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(color: AppTheme.accent, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            filled: true,
            fillColor: AppTheme.surface,
          ),
          hint: Text('Select unit', style: AppTheme.bodySmall),
          items: units.map((unit) {
            return DropdownMenuItem<String>(
              value: unit,
              child: Text(unit, style: AppTheme.bodyMedium),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
