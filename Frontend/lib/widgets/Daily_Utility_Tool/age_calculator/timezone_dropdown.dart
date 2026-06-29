import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class TimezoneDropdown extends StatelessWidget {
  final Duration? selected;
  final Function(Duration) onChanged;

  const TimezoneDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final timezones = {
      "IST (India)": const Duration(hours: 5, minutes: 30),
      "UTC": const Duration(hours: 0),
      "PST (US)": const Duration(hours: -8),
      "EST (US)": const Duration(hours: -5),
    };

    return DropdownButtonFormField<Duration>(
      value: selected,
      dropdownColor: AppTheme.surface,
      style: AppTheme.bodyMedium,

      decoration: InputDecoration(
        labelText: "Timezone",
        labelStyle: AppTheme.labelMedium,
        filled: true,
        fillColor: AppTheme.background.withOpacity(0.4),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.amber.shade400,
            width: 1.2,
          ),
        ),
      ),

      items: timezones.entries.map((e) {
        return DropdownMenuItem(
          value: e.value,
          child: Text(e.key),
        );
      }).toList(),

      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}