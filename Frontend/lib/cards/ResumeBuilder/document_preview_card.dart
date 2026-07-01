import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/ResumeBuilder/constants.dart';
import 'glass_card.dart';

/// A beautiful in-app document preview card.
///
/// Shows a simulated paper page so the user can see what the output
/// will look like before downloading.  No iframe or network request needed.
class DocumentPreviewCard extends StatefulWidget {
  const DocumentPreviewCard({
    super.key,
    required this.fileName,
    required this.outputType,   // e.g. 'PDF', 'Word', 'Image', 'Signed PDF'
    this.pageCount = 1,
    this.accentColor = kAccentCyan,
    this.extraInfo,             // optional subtitle line
    this.downloadUrl,           // unused for rendering, just shown as badge
  });

  final String fileName;
  final String outputType;
  final int pageCount;
  final Color accentColor;
  final String? extraInfo;
  final String? downloadUrl;

  @override
  State<DocumentPreviewCard> createState() => _DocumentPreviewCardState();
}

class _DocumentPreviewCardState extends State<DocumentPreviewCard> {
  bool _zoomed = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderGradient: [widget.accentColor, kAccentCyan],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor.withValues(alpha: 0.25),
                      kAccentCyan.withValues(alpha: 0.15),
                    ],
                  ),
                ),
                child: Icon(
                  _outputIcon(widget.outputType),
                  color: widget.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Output Preview',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                    Text(
                      '${widget.outputType} · ${widget.pageCount} page${widget.pageCount == 1 ? '' : 's'}',
                      style:
                          TextStyle(color: kTextTertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Zoom toggle
              GestureDetector(
                onTap: () => setState(() => _zoomed = !_zoomed),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: widget.accentColor.withValues(alpha: 0.1),
                    border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _zoomed
                            ? Icons.zoom_out_rounded
                            : Icons.zoom_in_rounded,
                        color: widget.accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _zoomed ? 'Zoom Out' : 'Zoom In',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Simulated Document Page ─────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            height: _zoomed ? 500 : 280,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Page content
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildPageContent(),
                      ),
                    ),
                    // Corner dog-ear
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildDogEar(),
                    ),
                    // File type badge (bottom-right)
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: widget.accentColor.withValues(alpha: 0.15),
                          border: Border.all(
                              color: widget.accentColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          widget.outputType,
                          style: TextStyle(
                            color: widget.accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.97, 0.97)),

          const SizedBox(height: 12),

          // ── File info strip ─────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: kAccentGreen, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.extraInfo ?? widget.fileName,
                  style:
                      TextStyle(color: kTextSecondary, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.downloadUrl != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_done_rounded,
                        color: kAccentCyan, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Ready to download',
                      style:
                          TextStyle(color: kAccentCyan, fontSize: 11),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.06);
  }

  // ── Simulated page lines ───────────────────────────────────────────

  Widget _buildPageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title bar
        Container(
          width: double.infinity,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 180,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(height: 16),
        // Divider
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
        ),
        const SizedBox(height: 14),
        // Body text lines
        ..._buildTextLines(),
        const SizedBox(height: 16),
        // Image/chart placeholder if output is image
        if (widget.outputType == 'Image' || widget.outputType == 'PDF')
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: widget.accentColor.withValues(alpha: 0.08),
              border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Icon(
                _outputIcon(widget.outputType),
                color: widget.accentColor.withValues(alpha: 0.4),
                size: 28,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildTextLines() {
    const lineHeights = [10.0, 10.0, 10.0, 10.0, 10.0, 10.0];
    const lineWidths = [1.0, 0.85, 0.92, 0.78, 0.88, 0.65];
    final List<Widget> lines = [];
    for (int i = 0; i < lineHeights.length; i++) {
      lines.add(
        FractionallySizedBox(
          widthFactor: lineWidths[i],
          alignment: Alignment.centerLeft,
          child: Container(
            height: lineHeights[i],
            margin: const EdgeInsets.only(bottom: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: const Color(0xFF1A1A2E)
                  .withValues(alpha: 0.12 + (i.isEven ? 0.05 : 0)),
            ),
          ),
        ),
      );
    }
    return lines;
  }

  Widget _buildDogEar() {
    return CustomPaint(
      size: const Size(28, 28),
      painter: _DogEarPainter(color: widget.accentColor.withValues(alpha: 0.4)),
    );
  }

  IconData _outputIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'word':
        return Icons.article_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'signed pdf':
        return Icons.verified_rounded;
      case 'compressed':
        return Icons.compress_rounded;
      case 'enhanced':
        return Icons.auto_fix_high_rounded;
      default:
        return Icons.description_rounded;
    }
  }
}

class _DogEarPainter extends CustomPainter {
  const _DogEarPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DogEarPainter oldDelegate) =>
      oldDelegate.color != color;
}
