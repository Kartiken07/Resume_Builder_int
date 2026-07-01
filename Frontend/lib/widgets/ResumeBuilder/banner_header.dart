import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/ResumeBuilder/constants.dart';

/// A large, stylized header displaying the app name.
/// Uses a gradient on the text for a premium look.
class BannerHeader extends StatelessWidget {
  const BannerHeader({
    super.key,
    required this.title,
    this.gradientColors = const [kAccentCyan, kAccentViolet],
  });

  final String title;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.outfit(
      fontSize: 48,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.5,
    );
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        title,
        style: textStyle.copyWith(color: Colors.white),
      ),
    );
  }
}
