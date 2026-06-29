import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../routes/Daily_Utility_Tool/app_pages.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Bottom curved background with gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: ClipPath(
              clipper: _CurveClipper(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.curvedBackgroundGradient,
                ),
              ),
            ),
          ),

          // Back to Main Home button
          Positioned(
            top: 20,
            right: 24,
            child: _BackToHomeButton(),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  _buildDecorativeLine(),
                  const SizedBox(height: 20),

                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "DAILY",
                        style: AppTheme.headingLarge.copyWith(letterSpacing: 4),
                      ).animate().fade().slideY(begin: -0.2),
                      const SizedBox(width: 12),
                      Text(
                        "Utility",
                        style: AppTheme.decorative,
                      ).animate().fade(delay: 200.ms).slideX(begin: 0.2),
                    ],
                  ),

                  Text(
                    "TOOLS IN ONE PLACE",
                    style: AppTheme.labelMedium.copyWith(letterSpacing: 6),
                  ).animate().fade(delay: 300.ms),

                  const SizedBox(height: 50),

                  // Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 30,
                    childAspectRatio: 1.4,
                    children: [
                      ElegantCard(
                        title: "QR Code",
                        icon: LucideIcons.qrCode,
                        onTap: () => context.go(AppRoutes.qrGenerator),
                      ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                      ElegantCard(
                        title: "Age Calc",
                        icon: LucideIcons.cakeSlice,
                        onTap: () => context.go(AppRoutes.ageCalculator),
                      ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
                      ElegantCard(
                        title: "EMI Calc",
                        icon: LucideIcons.calculator,
                        onTap: () => context.go(AppRoutes.emiCalculator),
                      ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
                      ElegantCard(
                        title: "Barcode",
                        icon: LucideIcons.scan,
                        onTap: () => context.go(AppRoutes.barcodeGenerator),
                      ).animate().fade(delay: 700.ms).slideY(begin: 0.1),
                      ElegantCard(
                        title: "Unit Converter",
                        icon: LucideIcons.arrowLeftRight,
                        onTap: () => context.go(AppRoutes.unitConverter),
                      ).animate().fade(delay: 800.ms).slideY(begin: 0.1),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 2,
          width: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
          ),
          child: const Icon(Icons.diamond_outlined, size: 12, color: AppTheme.background),
        ),
        const SizedBox(width: 10),
        Container(
          height: 2,
          width: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

class _BackToHomeButton extends StatefulWidget {
  @override
  State<_BackToHomeButton> createState() => _BackToHomeButtonState();
}

class _BackToHomeButtonState extends State<_BackToHomeButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered
                ? AppTheme.accent.withValues(alpha: 0.15)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: _hovered
                  ? AppTheme.accent.withValues(alpha: 0.5)
                  : AppTheme.borderLight,
              width: 1.5,
            ),
            boxShadow: _hovered ? AppTheme.shadowMedium : AppTheme.shadowSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.arrowLeft,
                size: 14,
                color: _hovered ? AppTheme.accent : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'HOME',
                style: AppTheme.labelSmall.copyWith(
                  color: _hovered ? AppTheme.accent : AppTheme.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElegantCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const ElegantCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  State<ElegantCard> createState() => _ElegantCardState();
}

class _ElegantCardState extends State<ElegantCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..translate(0.0, isHovered ? -12.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            gradient: isHovered
                ? AppTheme.primaryGradient
                : LinearGradient(
                    colors: [AppTheme.surface, AppTheme.backgroundSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border.all(
              color: isHovered
                  ? AppTheme.accent.withValues(alpha: 0.5)
                  : AppTheme.borderLight,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: isHovered ? AppTheme.shadowLarge : AppTheme.shadowSmall,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Stack(
                children: [
                  _buildReticleCorner(Alignment.topLeft),
                  _buildReticleCorner(Alignment.topRight),
                  _buildReticleCorner(Alignment.bottomLeft),
                  _buildReticleCorner(Alignment.bottomRight),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          size: 40,
                          color: isHovered ? AppTheme.accent : AppTheme.textPrimary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.title.toUpperCase(),
                          style: AppTheme.labelLarge.copyWith(
                            color: isHovered ? AppTheme.accent : AppTheme.textPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReticleCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CustomPaint(
          size: const Size(16, 16),
          painter: _ReticlePainter(alignment: alignment),
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  final Alignment alignment;
  _ReticlePainter({required this.alignment});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (alignment == Alignment.topLeft) {
      path.moveTo(0, size.height); path.lineTo(0, 0); path.lineTo(size.width, 0);
    } else if (alignment == Alignment.topRight) {
      path.moveTo(0, 0); path.lineTo(size.width, 0); path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, 0); path.lineTo(0, size.height); path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomRight) {
      path.moveTo(size.width, 0); path.lineTo(size.width, size.height); path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(size.width / 2, -size.height * 0.1, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
