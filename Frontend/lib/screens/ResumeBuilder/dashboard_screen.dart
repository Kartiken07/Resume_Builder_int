import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ResumeBuilder/tool_item.dart';
import '../../utils/ResumeBuilder/constants.dart';
import '../../widgets/ResumeBuilder/animated_gradient_background.dart';
import '../../widgets/ResumeBuilder/floating_wrapper.dart';
import '../../cards/ResumeBuilder/glass_card.dart';

/// The main dashboard screen:
/// - Brand chip with gradient fill at top
/// - Tagline and subtitle
/// - 2-column SliverGrid
/// - Floating GlassCard tiles with hover effects
/// - Staggered entry animations
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const List<ToolItem> _tools = [
    ToolItem(
      name: 'AI Resume Builder',
      description: 'Craft compelling resumes with AI-powered assistance and live preview',
      icon: Icons.rocket_launch_rounded,
      route: '/resume-builder/ai-resume',
      gradientColors: [Color(0xFF00D4FF), Color(0xFF7B2FBE)],
    ),
    ToolItem(
      name: 'Merge & Split PDF',
      description: 'Combine multiple PDFs or extract specific pages effortlessly',
      icon: Icons.call_merge_rounded,
      route: '/resume-builder/merge-split',
      gradientColors: [Color(0xFFFF9100), Color(0xFFFF6D00)],
    ),
    ToolItem(
      name: 'Format Converter',
      description: 'Convert, compress, and enhance documents with pixel-perfect quality',
      icon: Icons.swap_horiz_rounded,
      route: '/resume-builder/format-converter',
      gradientColors: [Color(0xFF00E676), Color(0xFF00BFA5)],
    ),
    ToolItem(
      name: 'Image to PDF',
      description: 'Transform photos into polished PDFs with optional OCR text extraction',
      icon: Icons.image_rounded,
      route: '/resume-builder/image-to-pdf',
      gradientColors: [Color(0xFF448AFF), Color(0xFF7B2FBE)],
    ),
    ToolItem(
      name: 'Digital Signature',
      description: 'Draw, apply, and seal your signature onto any PDF document',
      icon: Icons.draw_rounded,
      route: '/resume-builder/digital-signature',
      gradientColors: [Color(0xFFFF2D78), Color(0xFFFF9100)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int columns = screenWidth > 600 ? 2 : 1;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Brand Header ────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 48, bottom: 12, left: 24, right: 24),
                      child: Column(
                        children: [
                          // Brand chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [
                                  kAccentCyan.withValues(alpha: 0.15),
                                  kAccentViolet.withValues(alpha: 0.15),
                                ],
                              ),
                              border: Border.all(
                                color: kAccentCyan.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [kAccentCyan, kAccentViolet],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kAccentCyan.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.bolt_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'DocuForge',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: kTextPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: -0.3, curve: Curves.easeOutCubic),

                          const SizedBox(height: 28),

                          // Tagline
                          Text(
                            'Smart Document Suite',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary,
                              letterSpacing: -1,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 600.ms)
                              .slideY(begin: 0.15, curve: Curves.easeOutCubic),

                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            'Fast, secure, and AI-powered document processing',
                            style: TextStyle(
                              fontSize: 15,
                              color: kTextTertiary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .fadeIn(delay: 350.ms, duration: 600.ms)
                              .slideY(begin: 0.1),

                          const SizedBox(height: 40),

                          // Gradient accent line
                          Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [kAccentCyan, kAccentViolet],
                              ),
                            ),
                          ).animate().fadeIn(delay: 500.ms).scaleX(begin: 0),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // ── 2-Column SliverGrid ─────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: columns == 1 ? 200 : 230,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tool = _tools[index];
                          final int delayMs = 120 * index;

                          return FloatingWrapper(
                            amplitude: 5.0,
                            duration: Duration(seconds: 4 + (index % 2)),
                            delay: Duration(milliseconds: 300 * index),
                            child: GlassCard(
                              onTap: () => context.push(tool.route),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gradient Icon Container
                                  Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: tool.gradientColors,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: tool.gradientColors[0]
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          tool.icon,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Arrow indicator
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(alpha: 0.05),
                                          border: Border.all(
                                            color: kGlassBorder,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          color: kTextTertiary,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  // Tool Name
                                  Text(
                                    tool.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: kTextPrimary,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 8),

                                  // Description
                                  Text(
                                    tool.description,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: kTextTertiary,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                    milliseconds: 500 + delayMs),
                                duration: 600.ms,
                              )
                              .slideY(
                                begin: 0.12,
                                curve: Curves.easeOutCubic,
                              );
                        },
                        childCount: _tools.length,
                      ),
                    ),
                  ),

                  // ── Footer ──────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Built with Flutter & Riverpod',
                          style: TextStyle(
                            fontSize: 12,
                            color: kTextTertiary.withValues(alpha: 0.5),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1200.ms, duration: 800.ms),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
