import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class AgeDatePickerTile extends StatelessWidget {
  const AgeDatePickerTile({
    required this.selectedDate,
    required this.onTap,
    super.key,
  });

  final DateTime? selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.accent, size: 20),
            const SizedBox(width: 12),
            Text(
              selectedDate == null
                  ? 'Select Date of Birth'
                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              style: AppTheme.bodyMedium.copyWith(
                color: selectedDate == null
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: AppTheme.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
