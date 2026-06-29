import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../theme/app_theme.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

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
                        "MULTI",
                        style: AppTheme.headingLarge.copyWith(letterSpacing: 4),
                      ).animate().fade().slideY(begin: -0.2),
                      const SizedBox(width: 12),
                      Text(
                        "Project",
                        style: AppTheme.decorative,
                      ).animate().fade(delay: 200.ms).slideX(begin: 0.2),
                    ],
                  ),

                  Text(
                    "HUB FOR ALL YOUR TOOLS",
                    style: AppTheme.labelMedium.copyWith(letterSpacing: 6),
                  ).animate().fade(delay: 300.ms),

                  const SizedBox(height: 50),

                  // Project Cards Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: MediaQuery.of(context).size.width < 720 ? 1 : 3,
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 30,
                    childAspectRatio: 1.4,
                    children: [
                      ProjectCard(
                        title: "Daily Utility Tool",
                        description: "QR, Age Calc, EMI & More",
                        icon: LucideIcons.layoutGrid,
                        onTap: () => context.go('/daily-utility-tool'),
                      ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                      
                      ProjectCard(
                        title: "Minima",
                        description: "URL Shortener & Link Manager",
                        icon: LucideIcons.link2,
                        onTap: () => context.go('/minima'),
                      ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
                      
                      ProjectCard(
                        title: "Coming Soon",
                        description: "Stay tuned for updates",
                        icon: LucideIcons.sparkles,
                        isComingSoon: true,
                      ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
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

class ProjectCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isComingSoon;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
    this.isComingSoon = false,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: widget.isComingSoon ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isComingSoon ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..translate(0.0, isHovered && !widget.isComingSoon ? -12.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            gradient: isHovered && !widget.isComingSoon
                ? AppTheme.primaryGradient
                : LinearGradient(
                    colors: widget.isComingSoon
                        ? [AppTheme.surface.withOpacity(0.5), AppTheme.backgroundSecondary.withOpacity(0.5)]
                        : [AppTheme.surface, AppTheme.backgroundSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border.all(
              color: isHovered && !widget.isComingSoon
                  ? AppTheme.accent.withValues(alpha: 0.5)
                  : AppTheme.borderLight,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: isHovered && !widget.isComingSoon ? AppTheme.shadowLarge : AppTheme.shadowSmall,
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
                  
                  if (widget.isComingSoon)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Text(
                          'COMING SOON',
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          size: 50,
                          color: widget.isComingSoon
                              ? AppTheme.textSecondary.withOpacity(0.5)
                              : isHovered
                                  ? AppTheme.accent
                                  : AppTheme.textPrimary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.title.toUpperCase(),
                          style: AppTheme.labelLarge.copyWith(
                            color: widget.isComingSoon
                                ? AppTheme.textSecondary.withOpacity(0.5)
                                : isHovered
                                    ? AppTheme.accent
                                    : AppTheme.textPrimary,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            widget.description,
                            style: AppTheme.labelSmall.copyWith(
                              color: widget.isComingSoon
                                  ? AppTheme.textSecondary.withOpacity(0.4)
                                  : AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
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
          painter: _ReticlePainter(alignment: alignment, isComingSoon: widget.isComingSoon),
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  final Alignment alignment;
  final bool isComingSoon;
  
  _ReticlePainter({required this.alignment, this.isComingSoon = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isComingSoon
          ? AppTheme.accent.withValues(alpha: 0.15)
          : AppTheme.accent.withValues(alpha: 0.3)
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
