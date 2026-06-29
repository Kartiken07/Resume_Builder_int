import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/Daily_Utility_Tool/qr_code_model.dart';
import '../../providers/Daily_Utility_Tool/qr_generator_provider.dart';
import '../../theme/app_theme.dart';

class QrGeneratorScreen extends ConsumerStatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  ConsumerState<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends ConsumerState<QrGeneratorScreen> {
  final TextEditingController dataController = TextEditingController();

  @override
  void dispose() {
    dataController.dispose();
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
    final state = ref.watch(qrGeneratorProvider);
    final notifier = ref.read(qrGeneratorProvider.notifier);

    _setControllerValue(dataController, state.data);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Bottom curved background with gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.45,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  _buildDecorativeLine(),
                  const SizedBox(height: 20),

                  Text(
                    "QR CODE",
                    style: AppTheme.headingLarge.copyWith(
                      height: 1.0,
                    ),
                  ).animate().fade().slideY(begin: -0.2),

                  Text(
                    "Generator",
                    style: AppTheme.decorative.copyWith(
                      height: 0.8,
                    ),
                  ).animate().fade(delay: 150.ms).slideY(begin: -0.2),

                  const SizedBox(height: 20),

                  Text(
                    "CREATE & CUSTOMIZE QR CODES",
                    style: AppTheme.labelMedium.copyWith(
                      letterSpacing: 6,
                    ),
                  ).animate().fade(delay: 300.ms),

                  const SizedBox(height: 40),

                  // Input card
                  Container(
                    width: 480,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                      boxShadow: AppTheme.shadowLarge,
                      border: Border.all(
                        color: AppTheme.borderLight,
                        width: 1,
                      ),
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
                              "QR CONFIGURATION",
                              style: AppTheme.labelMedium.copyWith(
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Data input
                            TextFormField(
                              controller: dataController,
                              onChanged: notifier.updateData,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Data (text, URL, email, phone...)',
                                labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                                filled: true,
                                fillColor: AppTheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  borderSide: BorderSide(color: AppTheme.borderLight),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  borderSide: BorderSide(color: AppTheme.borderLight),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  borderSide: BorderSide(color: AppTheme.accent, width: 2),
                                ),
                              ),
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 16),

                            // Size slider
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Size: ${state.size}px',
                                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppTheme.primary,
                                inactiveTrackColor: AppTheme.primary.withValues(alpha: 0.2),
                                thumbColor: AppTheme.primary,
                                overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: state.size.toDouble(),
                                min: 100,
                                max: 1000,
                                divisions: 18,
                                onChanged: (value) => notifier.updateSize(value.toInt()),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Shape selector
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Shape',
                                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                                  ),
                                ),
                                ...QRShape.values.map((shape) => Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: ChoiceChip(
                                    label: Text(shape.label),
                                    selected: state.shape == shape,
                                    onSelected: (_) => notifier.updateShape(shape),
                                    selectedColor: AppTheme.accent,
                                    backgroundColor: AppTheme.surface,
                                    labelStyle: AppTheme.bodySmall.copyWith(
                                      color: state.shape == shape 
                                        ? AppTheme.background 
                                        : AppTheme.textSecondary,
                                    ),
                                  ),
                                )),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Error correction level
                            DropdownButtonFormField<ErrorCorrectionLevel>(
                              value: state.errorCorrection,
                              dropdownColor: AppTheme.surface,
                              decoration: InputDecoration(
                                labelText: 'Error Correction',
                                labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                                filled: true,
                                fillColor: AppTheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  borderSide: BorderSide(color: AppTheme.borderLight),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  borderSide: BorderSide(color: AppTheme.borderLight),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  borderSide: BorderSide(color: AppTheme.accent, width: 2),
                                ),
                              ),
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                              items: ErrorCorrectionLevel.values.map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level.label),
                              )).toList(),
                              onChanged: (value) {
                                if (value != null) notifier.updateErrorCorrection(value);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Frame toggle
                            Material(
                              color: Colors.transparent,
                              child: SwitchListTile(
                                title: Text(
                                  'Add Frame',
                                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                                ),
                                value: state.frame,
                                onChanged: notifier.updateFrame,
                                activeThumbColor: AppTheme.accent,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Generate button
                            SizedBox(
                              width: double.infinity,
                              height: AppTheme.buttonHeight,
                              child: ElevatedButton.icon(
                                onPressed: state.isLoading ? null : notifier.generateQRCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accent,
                                  foregroundColor: AppTheme.background,
                                  padding: AppTheme.buttonPadding,
                                  disabledBackgroundColor: AppTheme.textTertiary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  ),
                                ),
                                icon: state.isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.qr_code_2, size: 18),
                                label: Text(
                                  state.isLoading ? "GENERATING..." : "GENERATE QR CODE",
                                  style: AppTheme.labelLarge.copyWith(
                                    color: AppTheme.background,
                                  ),
                                ),
                              ),
                            ),

                            // Error message
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  border: Border.all(
                                    color: AppTheme.error.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  state.errorMessage!,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 450.ms).slideY(begin: 0.1),

                  // Result card
                  if (state.result != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: 480,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                        boxShadow: AppTheme.shadowLarge,
                        border: Border.all(
                          color: AppTheme.borderLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "GENERATED QR CODE",
                            style: AppTheme.labelMedium.copyWith(
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Text(
                              'Type: ${state.result!.qrType.toUpperCase()}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              boxShadow: AppTheme.shadowMedium,
                            ),
                            child: Image.memory(
                              base64Decode(state.result!.image),
                              width: 280,
                              height: 280,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            state.result!.message,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => notifier.clearResult(),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              'Generate Another',
                              style: AppTheme.labelMedium,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
                              foregroundColor: AppTheme.secondary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade().slideY(begin: 0.1),
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


