import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ValueInputField extends StatelessWidget {
  const ValueInputField({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: 'Enter value',
        hintText: 'e.g., 100',
        prefixIcon: Icon(Icons.numbers_rounded, color: AppTheme.accent),
        labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.secondary),
        hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
