import 'package:flutter/material.dart';

/// API Configuration
const String kBaseUrl = 'http://localhost:8001';
const String kStatusEndpoint = '/api/v1/status';
const String kUploadEndpoint = '/api/v1/upload';

/// Polling
const Duration kPollInterval = Duration(seconds: 3);
const Duration kMockTaskDuration = Duration(seconds: 5);

/// Animation Durations
const Duration kFloatingDuration = Duration(seconds: 3);
const Duration kEntryAnimationDuration = Duration(milliseconds: 600);
const Duration kStaggerDelay = Duration(milliseconds: 100);
const Duration kPageTransitionDuration = Duration(milliseconds: 400);

/// Blur
const double kGlassBlurSigma = 18.0;
const double kGlassBorderOpacity = 0.15;
const double kGlassFillOpacity = 0.08;

/// Border Radius
const double kCardBorderRadius = 24.0;
const double kInputBorderRadius = 16.0;
const double kButtonBorderRadius = 20.0;

/// Floating Animation
const double kFloatingAmplitude = 8.0;

/// ── Color Palette ──────────────────────────────────────────────────────────
/// Deep dark background
const Color kBackgroundDark = Color(0xFF0A0E21);
const Color kBackgroundMedium = Color(0xFF111632);
const Color kSurfaceDark = Color(0xFF161B3A);

/// Accent colors
const Color kAccentCyan = Color(0xFF00D4FF);
const Color kAccentViolet = Color(0xFF7B2FBE);
const Color kAccentPink = Color(0xFFFF2D78);
const Color kAccentGreen = Color(0xFF00E676);
const Color kAccentOrange = Color(0xFFFF9100);
const Color kAccentBlue = Color(0xFF448AFF);

/// Glass surface
const Color kGlassBorder = Color(0x26FFFFFF); // white15
const Color kGlassFill = Color(0x14FFFFFF);   // white08
const Color kGlassHighlight = Color(0x1AFFFFFF); // white10

/// Text
const Color kTextPrimary = Color(0xFFF0F0F5);
const Color kTextSecondary = Color(0xB3F0F0F5); // 70%
const Color kTextTertiary = Color(0x80F0F0F5);  // 50%

/// Gradient presets for tool cards
const List<List<Color>> kToolGradients = [
  [Color(0xFF00D4FF), Color(0xFF7B2FBE)], // cyan → violet
  [Color(0xFFFF2D78), Color(0xFFFF9100)], // pink → orange
  [Color(0xFF00E676), Color(0xFF00D4FF)], // green → cyan
  [Color(0xFF448AFF), Color(0xFF7B2FBE)], // blue → violet
  [Color(0xFFFF9100), Color(0xFFFF2D78)], // orange → pink
  [Color(0xFF7B2FBE), Color(0xFFFF2D78)], // violet → pink
];
