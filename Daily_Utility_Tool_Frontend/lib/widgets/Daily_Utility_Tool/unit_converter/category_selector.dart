import 'package:flutter/material.dart';

import '../../../models/Daily_Utility_Tool/unit_converter_model.dart';
import '../../../theme/app_theme.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final UnitCategory value;
  final ValueChanged<UnitCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<UnitCategory>(
      value: value,
      dropdownColor: AppTheme.surface,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category_outlined, color: AppTheme.primary),
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
      items: UnitCategory.values
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Text(category.label),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
