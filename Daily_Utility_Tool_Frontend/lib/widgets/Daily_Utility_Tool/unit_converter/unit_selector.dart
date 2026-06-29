import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class UnitSelector extends StatelessWidget {
  const UnitSelector({
    required this.label,
    required this.value,
    required this.units,
    required this.onChanged,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final List<String> units;
  final ValueChanged<String?> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: units.contains(value) ? value : (units.isNotEmpty ? units.first : null),
      dropdownColor: AppTheme.surface,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.secondary) : null,
        labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
        filled: true,
        fillColor: AppTheme.surface,
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
      ),
      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
      items: units
          .map(
            (unit) => DropdownMenuItem(
              value: unit,
              child: Text(unit),
            ),
          )
          .toList(),
      onChanged: units.isEmpty ? null : onChanged,
    );
  }
}
