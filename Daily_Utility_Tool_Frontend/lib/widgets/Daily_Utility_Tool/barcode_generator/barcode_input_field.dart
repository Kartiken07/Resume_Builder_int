import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class BarcodeInputField extends StatelessWidget {
  const BarcodeInputField({
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
      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: 'Enter barcode data',
        hintText: 'Text, number, or product code',
        prefixIcon: Icon(Icons.data_array_rounded, color: AppTheme.accent),
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
