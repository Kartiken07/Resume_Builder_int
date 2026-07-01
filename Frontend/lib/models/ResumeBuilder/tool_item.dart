import 'package:flutter/material.dart';

/// Data model for a tool tile shown on the dashboard.
class ToolItem {
  const ToolItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
    required this.gradientColors,
  });

  final String name;
  final String description;
  final IconData icon;
  final String route;
  final List<Color> gradientColors;
}
