import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cards/Daily_Utility_Tool/unit_converter/conversion_result_card.dart';
import '../../providers/Daily_Utility_Tool/unit_converter_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/Daily_Utility_Tool/unit_converter/category_selector.dart';
import '../../widgets/Daily_Utility_Tool/unit_converter/unit_selector.dart';
import '../../widgets/Daily_Utility_Tool/unit_converter/value_input_field.dart';

class UnitConverterScreen extends ConsumerStatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  ConsumerState<UnitConverterScreen> createState() =>
      _UnitConverterScreenState();
}

class _UnitConverterScreenState extends ConsumerState<UnitConverterScreen> {
  final valueController = TextEditingController(text: "1");

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }

  void _setControllerValue(TextEditingController controller, String text) {
    if (controller.text == text) return;
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitConverterProvider);
    final notifier = ref.read(unitConverterProvider.notifier);

    _setControllerValue(valueController, state.value.toString());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Bottom curved background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: ClipPath(
              clipper: _CurveClipper(),
              child: Container(
                decoration:
                    BoxDecoration(gradient: AppTheme.curvedBackgroundGradient),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  _buildDecorativeLine(),
                  const SizedBox(height: 20),

                  Text("UNIT",
                          style: AppTheme.headingLarge.copyWith(height: 1.0))
                      .animate()
                      .fade()
                      .slideY(begin: -0.2),
                  Text("Converter",
                          style: AppTheme.decorative.copyWith(height: 0.8))
                      .animate()
                      .fade(delay: 150.ms)
                      .slideY(begin: -0.2),

                  const SizedBox(height: 20),

                  Text(
                    "CONVERT BETWEEN UNITS",
                    style: AppTheme.labelMedium.copyWith(letterSpacing: 6),
                  ).animate().fade(delay: 300.ms),

                  const SizedBox(height: 40),

                  // ── Input card ──────────────────────────────────────────
                  Container(
                    width: 480,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusXLarge),
                      boxShadow: AppTheme.shadowLarge,
                      border: Border.all(color: AppTheme.borderLight, width: 1),
                    ),
                    child: Stack(
                      children: [
                        _buildReticleCorner(Alignment.topLeft),
                        _buildReticleCorner(Alignment.topRight),
                        _buildReticleCorner(Alignment.bottomLeft),
                        _buildReticleCorner(Alignment.bottomRight),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "CONVERSION DETAILS",
                              style: AppTheme.labelMedium
                                  .copyWith(letterSpacing: 4),
                            ),
                            const SizedBox(height: 24),

                            // Category selector
                            CategorySelector(
                              value: state.category,
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.updateCategory(value);
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // Value input
                            ValueInputField(
                              controller: valueController,
                              onChanged: (val) {
                                final parsed = double.tryParse(val);
                                if (parsed != null) {
                                  notifier.updateValue(parsed);
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // From unit selector
                            UnitSelector(
                              label: 'From Unit',
                              value: state.fromUnit,
                              units: state.availableUnits,
                              icon: Icons.input_outlined,
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.updateFromUnit(value);
                                }
                              },
                            ),

                            const SizedBox(height: 12),

                            // Swap button
                            IconButton(
                              onPressed: state.isLoadingUnits
                                  ? null
                                  : notifier.swapUnits,
                              icon: Icon(
                                Icons.swap_vert_rounded,
                                color: AppTheme.accent,
                                size: 32,
                              ),
                              tooltip: 'Swap units',
                            ),

                            const SizedBox(height: 12),

                            // To unit selector
                            UnitSelector(
                              label: 'To Unit',
                              value: state.toUnit,
                              units: state.availableUnits,
                              icon: Icons.output_outlined,
                              onChanged: (value) {
                                if (value != null) {
                                  notifier.updateToUnit(value);
                                }
                              },
                            ),

                            const SizedBox(height: 24),

                            // Convert button
                            SizedBox(
                              width: double.infinity,
                              height: AppTheme.buttonHeight,
                              child: ElevatedButton.icon(
                                onPressed: state.isLoading ||
                                        state.isLoadingUnits
                                    ? null
                                    : notifier.convert,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accent,
                                  foregroundColor: AppTheme.background,
                                  padding: AppTheme.buttonPadding,
                                  disabledBackgroundColor:
                                      AppTheme.textTertiary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusMedium),
                                  ),
                                ),
                                icon: state.isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.transform_outlined,
                                        size: 18),
                                label: Text(
                                  state.isLoading
                                      ? "CONVERTING..."
                                      : "CONVERT",
                                  style: AppTheme.labelLarge.copyWith(
                                    color: AppTheme.background,
                                  ),
                                ),
                              ),
                            ),

                            // Error
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMedium),
                                  border: Border.all(
                                      color:
                                          AppTheme.error.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  state.errorMessage!,
                                  style: AppTheme.bodySmall
                                      .copyWith(color: AppTheme.error),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 450.ms).slideY(begin: 0.1),

                  // ── Result card ─────────────────────────────────────────
                  if (state.result != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: 480,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusXLarge),
                        boxShadow: AppTheme.shadowLarge,
                        border:
                            Border.all(color: AppTheme.borderLight, width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "RESULT",
                            style: AppTheme.labelMedium
                                .copyWith(letterSpacing: 4),
                          ),
                          const SizedBox(height: 20),
                          ConversionResultCard(
                            inputValue: state.value.toString(),
                            fromUnit: state.fromUnit,
                            toUnit: state.toUnit,
                            result: state.result!,
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 32,
            left: 32,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
              onPressed: () => context.go('/daily-utility-tool'),
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
              shape: BoxShape.circle, gradient: AppTheme.primaryGradient),
          child: const Icon(Icons.diamond_outlined,
              size: 12, color: AppTheme.background),
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

  Widget _buildReticleCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CustomPaint(
          size: const Size(20, 20),
          painter: _ReticlePainter(alignment: alignment),
        ),
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
        size.width / 2, -size.height * 0.1, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ReticlePainter extends CustomPainter {
  final Alignment alignment;
  _ReticlePainter({required this.alignment});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    if (alignment == Alignment.topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (alignment == Alignment.topRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomRight) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
