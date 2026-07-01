import 'dart:js_interop';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;
import '../../utils/ResumeBuilder/constants.dart';
import '../../providers/ResumeBuilder/task_provider.dart';
import '../../models/ResumeBuilder/task_status.dart';
import '../../widgets/ResumeBuilder/animated_gradient_background.dart';
import '../../cards/ResumeBuilder/glass_card.dart';
import '../../widgets/ResumeBuilder/glass_loading_spinner.dart';
import '../../widgets/ResumeBuilder/animated_upload_button.dart';

class DigitalSignatureScreen extends ConsumerStatefulWidget {
  const DigitalSignatureScreen({super.key});

  @override
  ConsumerState<DigitalSignatureScreen> createState() =>
      _DigitalSignatureScreenState();
}

class _DigitalSignatureScreenState
    extends ConsumerState<DigitalSignatureScreen> {
  late SignatureController _signatureController;
  PlatformFile? _selectedPdf;
  double _penWidth = 3;
  Color _penColor = Colors.black;

  static const _penColors = [
    Colors.black,
    Color(0xFF1565C0),
    Color(0xFFC62828),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
  ];

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    Future.microtask(() => ref.read(taskNotifierProvider.notifier).reset());
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _selectPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _selectedPdf = result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick file: $e')),
        );
      }
    }
  }

  bool get _canSign =>
      _signatureController.isNotEmpty && _selectedPdf != null;

  void _upload() async {
    if (!_canSign) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw your signature and select a PDF'),
        ),
      );
      return;
    }

    // Export signature as PNG bytes
    final signatureBytes = await _signatureController.toPngBytes();
    if (signatureBytes == null) return;

    ref.read(taskNotifierProvider.notifier).uploadFileWithSignature(
          pdfPath: kIsWeb ? null : _selectedPdf!.path,
          pdfBytes: _selectedPdf!.bytes,
          pdfName: _selectedPdf!.name,
          signatureBytes: signatureBytes,
        );
  }

  Future<void> _launchDownload(String url) async {
    if (kIsWeb) {
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = url.split('/').last;
      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open download link')),
        );
      }
    }
  }

  void _downloadSignature() async {
    final bytes = await _signatureController.toPngBytes();
    if (bytes == null || !mounted) return;

    if (kIsWeb) {
      final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'image/png'));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = 'signature.png';
      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);
    }
  }

  void _showPreview() async {
    final signatureBytes = await _signatureController.toPngBytes();
    if (signatureBytes == null || !mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.preview_rounded, color: Colors.black87, size: 22),
                  const SizedBox(width: 8),
                  Text('Your Signature',
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: Colors.black38),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Image.memory(
                  signatureBytes,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This is how your signature will appear',
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Digital Signature'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ── Draw Signature ─────────────────────────────
                GlassCard(
                  borderGradient: const [kAccentCyan, kAccentViolet],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.draw_rounded,
                              color: kAccentCyan.withValues(alpha: 0.8), size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Draw Your Signature',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            border: Border.all(color: kGlassBorder, width: 1),
                          ),
                          child: Signature(
                            controller: _signatureController,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Color Picker ──────────────────────
                      Row(
                        children: [
                          const Text('Color', style: TextStyle(color: kTextSecondary, fontSize: 13)),
                          const SizedBox(width: 12),
                          ..._penColors.map((c) => GestureDetector(
                            onTap: () {
                              setState(() => _penColor = c);
                              _signatureController = SignatureController(
                                penStrokeWidth: _penWidth,
                                penColor: c,
                                exportBackgroundColor: Colors.white,
                              );
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _penColor == c ? Colors.black87 : Colors.grey.shade300,
                                  width: _penColor == c ? 2.5 : 1,
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Width Slider ──────────────────────
                      Row(
                        children: [
                          const Text('Width', style: TextStyle(color: kTextSecondary, fontSize: 13)),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: _penColor == Colors.black ? Colors.black87 : _penColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: _penColor == Colors.black ? Colors.black87 : _penColor,
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                              ),
                              child: Slider(
                                value: _penWidth,
                                min: 1,
                                max: 8,
                                onChanged: (val) {
                                  setState(() => _penWidth = val);
                                  _signatureController = SignatureController(
                                    penStrokeWidth: val,
                                    penColor: _penColor,
                                    exportBackgroundColor: Colors.white,
                                  );
                                },
                              ),
                            ),
                          ),
                          Text('${_penWidth.round()}px',
                              style: const TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Undo / Clear Row ──────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _signatureController.undo();
                                setState(() {});
                              },
                              icon: const Icon(Icons.undo_rounded, size: 18),
                              label: const Text('Undo'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black54,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _signatureController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              label: const Text('Clear and draw again'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade400,
                                side: BorderSide(color: Colors.red.shade200),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Download eSignature Button ────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _downloadSignature,
                          icon: const Icon(Icons.download_rounded, size: 20),
                          label: const Text('Download eSignature'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),

                const SizedBox(height: 20),

                // ── PDF Upload Zone ────────────────────────────
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(kCardBorderRadius),
                    color: kAccentOrange.withValues(alpha: 0.4),
                    strokeWidth: 1.5,
                    dashPattern: const [8, 6],
                    child: InkWell(
                      onTap: _selectPdf,
                      borderRadius: BorderRadius.circular(kCardBorderRadius),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Column(
                          children: [
                            Icon(
                              _selectedPdf != null
                                  ? Icons.description_rounded
                                  : Icons.upload_file_rounded,
                              size: 32,
                              color: kAccentOrange.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _selectedPdf?.name ?? 'Select PDF to sign',
                              style: TextStyle(
                                color: _selectedPdf != null
                                    ? kTextPrimary
                                    : kTextSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_selectedPdf == null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Signature will be placed at "Sign here" markers',
                                style: TextStyle(color: kTextTertiary, fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05),

                const SizedBox(height: 24),

                // ── Buttons Row ──────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _signatureController.isNotEmpty ? _showPreview : null,
                        icon: const Icon(Icons.preview_rounded, size: 20),
                        label: const Text('Preview'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kAccentCyan,
                          side: BorderSide(
                            color: _signatureController.isNotEmpty
                                ? kAccentCyan.withValues(alpha: 0.4)
                                : kGlassBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AnimatedUploadButton(
                        onPressed: _upload,
                        label: 'Seal & Sign',
                        icon: Icons.verified_rounded,
                        gradient: const [kAccentOrange, kAccentPink],
                        isLoading: taskState is AsyncLoading,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 20),

                // ── Result (no preview, just download) ──────────
                _buildResult(taskState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AsyncValue taskState) {
    return taskState.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: const GlassLoadingSpinner(
          message: 'Scanning for signature locations...',
        ).animate().fadeIn(duration: 400.ms),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: GlassCard(
          borderGradient: const [kAccentPink, kAccentOrange],
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: kAccentPink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.toString(),
                  style: const TextStyle(color: kTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (task) {
        if (task == null) return const SizedBox.shrink();

        if (task.isPending) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GlassLoadingSpinner(
              message: task.status == TaskState.processing
                  ? 'Placing signature... ${((task.progress ?? 0) * 100).toInt()}%'
                  : 'Uploading...',
            ).animate().fadeIn(duration: 400.ms),
          );
        }

        if (task.isCompleted) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: GlassCard(
              borderGradient: const [kAccentGreen, kAccentOrange],
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [
                        kAccentGreen.withValues(alpha: 0.2),
                        kAccentOrange.withValues(alpha: 0.1),
                      ]),
                    ),
                    child: const Icon(Icons.verified_rounded,
                        color: kAccentGreen, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Document Signed & Sealed',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.aiSummary ?? 'Signature placed at detected locations',
                    style: TextStyle(color: kTextTertiary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  if (task.downloadUrl != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchDownload(task.downloadUrl!),
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: const Text('Download Signed PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentGreen,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref.read(taskNotifierProvider.notifier).reset();
                      _signatureController.clear();
                      setState(() => _selectedPdf = null);
                    },
                    child: const Text('Sign Another',
                        style: TextStyle(color: kAccentCyan)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
          );
        }

        if (task.isFailed) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GlassCard(
              borderGradient: const [kAccentPink, kAccentOrange],
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: kAccentPink, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    task.errorMessage ?? 'Signing failed',
                    style: const TextStyle(color: kTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      ref.read(taskNotifierProvider.notifier).reset();
                    },
                    child: const Text('Try Again',
                        style: TextStyle(color: kAccentCyan)),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
