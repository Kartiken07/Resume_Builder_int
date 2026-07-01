import 'package:flutter/material.dart';

Widget createWebPreview(String url) {
  return const Center(
    child: Text(
      'Preview is not supported on this platform.\nPlease download the file to view it.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white70),
    ),
  );
}
