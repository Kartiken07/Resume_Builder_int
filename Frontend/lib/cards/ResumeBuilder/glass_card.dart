import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/ResumeBuilder/constants.dart';

/// A reusable frosted-glass card built with [BackdropFilter].
///
/// Uses a semi-transparent fill with a blurred backdrop to achieve
/// the glassmorphism aesthetic. Configurable border radius, padding,
/// and optional gradient border. When [onTap] is provided, the card
/// responds to hover with a subtle scale + glow effect.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = kCardBorderRadius,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.blurSigma = kGlassBlurSigma,
    this.borderGradient,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final List<Color>? borderGradient;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget card = MouseRegion(
      onEnter: widget.onTap != null ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.onTap != null ? (_) => setState(() => _isHovered = false) : null,
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: widget.onTap != null && _isHovered
            ? (Matrix4.identity()..scale(1.025, 1.025))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isHovered && widget.onTap != null
              ? [
                  BoxShadow(
                    color: (widget.borderGradient != null
                            ? widget.borderGradient![0]
                            : kAccentCyan)
                        .withValues(alpha: 0.15),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _isHovered
                        ? kGlassHighlight.withValues(alpha: 0.14)
                        : kGlassHighlight, // white10
                    kGlassFill, // white08
                  ],
                ),
                border: widget.borderGradient != null
                    ? null
                    : Border.all(
                        color: _isHovered
                            ? kGlassBorder.withValues(alpha: 0.3)
                            : kGlassBorder,
                        width: 1,
                      ),
              ),
              foregroundDecoration: widget.borderGradient != null
                  ? BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.borderGradient![0]
                              .withValues(alpha: _isHovered ? 0.55 : 0.4),
                          widget.borderGradient![1]
                              .withValues(alpha: _isHovered ? 0.25 : 0.15),
                        ],
                      ),
                    )
                  : null,
              child: Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.margin != null) {
      card = Padding(padding: widget.margin!, child: card);
    }

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
