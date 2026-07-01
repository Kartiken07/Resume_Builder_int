import 'dart:js_interop';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:web/web.dart' as web;
import '../../utils/ResumeBuilder/constants.dart';
import '../../providers/ResumeBuilder/task_provider.dart';
import '../../providers/ResumeBuilder/ui_state_provider.dart';
import '../../widgets/ResumeBuilder/animated_gradient_background.dart';
import '../../cards/ResumeBuilder/glass_card.dart';
import '../../widgets/ResumeBuilder/glass_loading_spinner.dart';
import '../../widgets/ResumeBuilder/animated_upload_button.dart';

/// Image & PDF Converter screen.
///
/// Mode 0: Image to PDF (Gallery grid for uploading images, OCR toggle).
/// Mode 1: PDF to Image (Single PDF upload, format selection chips).
class ImageToPdfScreen extends ConsumerStatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  ConsumerState<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends ConsumerState<ImageToPdfScreen> {
  // Mode 0: Image to PDF
  final List<PlatformFile> _images = [];

  // Mode 1: PDF to Image
  PlatformFile? _pdfFile;

  /// Color palette for image placeholders in the gallery grid.
  static const _placeholderColors = [
    kAccentCyan,
    kAccentViolet,
    kAccentPink,
    kAccentGreen,
    kAccentOrange,
    kAccentBlue,
  ];

  @override
  void initState() {
    super.initState();
    // Reset shared task state when entering this screen
    Future.microtask(() => ref.read(taskNotifierProvider.notifier).reset());
  }

  // ── File picking ──────────────────────────────────────────────────────────

  Future<void> _addImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg'],
        allowMultiple: true,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _images.addAll(result.files));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick images: $e')),
        );
      }
    }
  }

  Future<void> _selectPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _pdfFile = result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick file: $e')),
        );
      }
    }
  }

  // ── Upload handler ────────────────────────────────────────────────────────

  void _uploadImageToPdf() {
    if (_images.isEmpty) return;
    final ocr = ref.read(ocrEnabledProvider);
    ref.read(taskNotifierProvider.notifier).uploadFiles(
          filePaths: kIsWeb ? null : _images.map((f) => f.path).toList(),
          fileBytesList: _images.map((f) => f.bytes).toList(),
          fileNames: _images.map((f) => f.name).toList(),
          endpoint: '/api/v1/convert/image-to-pdf${ocr ? '?ocr=true' : ''}',
        );
  }

  void _uploadPdfToImage() {
    if (_pdfFile == null) return;
    ref.read(taskNotifierProvider.notifier).uploadFile(
          filePath: kIsWeb ? null : _pdfFile!.path,
          fileBytes: _pdfFile!.bytes,
          fileName: _pdfFile!.name,
          endpoint: '/api/v1/convert/pdf-to-image',
        );
  }

  // ── Download handler ──────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(imagePdfModeProvider);
    final taskState = ref.watch(taskNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Image & PDF Converter'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ── Mode Selector ──────────────────────────────────────
                _buildModeSelector(mode),

                const SizedBox(height: 20),

                // ── Mode-specific content ──────────────────────────────
                if (mode == 0) _buildImageToPdfMode(taskState),
                if (mode == 1) _buildPdfToImageMode(taskState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODE SELECTOR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildModeSelector(int activeMode) {
    const modes = [
      {'icon': Icons.image_rounded, 'label': 'Image to PDF'},
      {'icon': Icons.picture_as_pdf_rounded, 'label': 'PDF to Image'},
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(modes.length, (index) {
          final isActive = index == activeMode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(imagePdfModeProvider.notifier).state = index;
                ref.read(taskNotifierProvider.notifier).reset();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isActive
                      ? kAccentCyan.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: isActive
                        ? kAccentCyan.withValues(alpha: 0.4)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      modes[index]['icon'] as IconData,
                      color: isActive ? kAccentCyan : kTextTertiary,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      modes[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? kAccentCyan : kTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // IMAGE TO PDF MODE (Mode 0)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildImageToPdfMode(AsyncValue taskState) {
    final ocrEnabled = ref.watch(ocrEnabledProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── OCR Toggle ────────────────────────────────────────
        GlassCard(
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      kAccentBlue.withValues(alpha: 0.2),
                      kAccentViolet.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: const Icon(Icons.text_fields_rounded,
                    color: kAccentBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Text Recognition (OCR)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Make text selectable in the final PDF',
                      style: TextStyle(color: kTextTertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: ocrEnabled,
                onChanged: (val) {
                  ref.read(ocrEnabledProvider.notifier).state = val;
                },
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

        const SizedBox(height: 20),

        // ── Gallery Header ────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gallery',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            GestureDetector(
              onTap: _addImages,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: kAccentBlue.withValues(alpha: 0.12),
                  border: Border.all(color: kAccentBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_photo_alternate_rounded,
                        color: kAccentBlue, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Add Photo',
                      style: TextStyle(
                        color: kAccentBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

        const SizedBox(height: 16),

        // ── Image Grid ────────────────────────────────────────
        if (_images.isEmpty)
          GlassCard(
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      color: kTextTertiary, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'No images added yet',
                    style: TextStyle(color: kTextTertiary, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Add Photo" to get started',
                    style: TextStyle(color: kTextTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: _images.length,
            itemBuilder: (context, index) {
              final img = _images[index];
              final color =
                  _placeholderColors[index % _placeholderColors.length];
              return GlassCard(
                padding: const EdgeInsets.all(4),
                borderRadius: 16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Color placeholder for image
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withValues(alpha: 0.3),
                            color.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_rounded,
                          color: color.withValues(alpha: 0.5),
                          size: 28,
                        ),
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _images.removeAt(index));
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black45,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                    // File name
                    Positioned(
                      bottom: 6,
                      left: 6,
                      right: 6,
                      child: Text(
                        img.name,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 100 * index),
                    duration: 400.ms,
                  )
                  .scale(begin: const Offset(0.9, 0.9));
            },
          ),

        const SizedBox(height: 28),

        // ── Convert Button ────────────────────────────────────
        if (_images.isNotEmpty)
          Center(
            child: AnimatedUploadButton(
              onPressed: _uploadImageToPdf,
              label: 'Convert ${_images.length} Images to PDF',
              icon: Icons.picture_as_pdf_rounded,
              gradient: const [kAccentBlue, kAccentViolet],
              isLoading: taskState is AsyncLoading,
            ).animate().fadeIn(delay: 300.ms),
          ),

        // ── Result ────────────────────────────────────────────
        _buildResult(taskState, ocrEnabled, isImageToPdf: true),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PDF TO IMAGE MODE (Mode 1)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPdfToImageMode(AsyncValue taskState) {
    final selectedFormat = ref.watch(pdfToImageFormatProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Upload Zone ─────────────────────────────────────────────
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
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(
                  children: [
                    Icon(
                      _pdfFile != null
                          ? Icons.description_rounded
                          : Icons.cloud_upload_rounded,
                      size: 40,
                      color: kAccentOrange.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _pdfFile?.name ?? 'Upload PDF file',
                      style: TextStyle(
                        color: _pdfFile != null
                            ? kTextPrimary
                            : kTextSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Supports .pdf format',
                      style: TextStyle(color: kTextTertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.05),

        const SizedBox(height: 20),

        // ── Auto-detect info ─────────────────────────────────────
        if (_pdfFile != null)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: kAccentOrange.withValues(alpha: 0.7), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_pdfFile!.name,
                          style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        'Best format will be auto-detected from PDF content',
                        style: TextStyle(color: kTextTertiary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

        const SizedBox(height: 24),

        // ── Convert Button ──────────────────────────────────────────
        if (_pdfFile != null)
          Center(
            child: AnimatedUploadButton(
              onPressed: _uploadPdfToImage,
              label: 'Convert to Images',
              icon: Icons.image_rounded,
              gradient: const [kAccentOrange, kAccentPink],
              isLoading: taskState is AsyncLoading,
            ).animate().fadeIn(delay: 300.ms),
          ),

        // ── Result ──────────────────────────────────────────────────
        _buildResult(taskState, false, isImageToPdf: false),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED RESULT BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildResult(AsyncValue taskState, bool ocrEnabled,
      {required bool isImageToPdf}) {
    return taskState.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 30),
        child: const GlassLoadingSpinner(
          message: 'Converting...',
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
        if (task == null || task.isPending) {
          if (task != null && task.isPending) {
            return Padding(
              padding: const EdgeInsets.only(top: 30),
              child: GlassLoadingSpinner(
                message:
                    'Processing... ${((task.progress ?? 0) * 100).toInt()}%',
              ).animate().fadeIn(duration: 400.ms),
            );
          }
          return const SizedBox.shrink();
        }
        if (task.isCompleted) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                _buildPreviewPanel(task.downloadUrl),
                const SizedBox(height: 16),
                GlassCard(
                  borderGradient: const [kAccentGreen, kAccentBlue],
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: kAccentGreen, size: 36),
                      const SizedBox(height: 10),
                      Text(
                        isImageToPdf
                            ? (ocrEnabled ? 'PDF Created with OCR!' : 'PDF Created!')
                            : 'Images Created!',
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isImageToPdf && ocrEnabled) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Text is selectable in the final PDF',
                          style: TextStyle(color: kTextTertiary, fontSize: 12),
                        ),
                      ],
                      if (task.downloadUrl != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchDownload(task.downloadUrl!),
                            icon: const Icon(Icons.download_rounded, size: 20),
                            label: Text(
                                isImageToPdf ? 'Download PDF' : 'Download ZIP'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          ref.read(taskNotifierProvider.notifier).reset();
                          if (isImageToPdf) {
                            setState(() => _images.clear());
                          } else {
                            setState(() => _pdfFile = null);
                          }
                        },
                        child: const Text('Convert More',
                            style: TextStyle(color: kAccentCyan)),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
              ],
            ),
          );
        }
        if (task.isFailed) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GlassCard(
              borderGradient: const [kAccentPink, kAccentOrange],
              child: Column(
                children: [
                  const Icon(Icons.error_outline,
                      color: kAccentPink, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    task.errorMessage ?? 'Conversion failed',
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

  Widget _buildPreviewPanel(String? url) {
    final mode = ref.read(imagePdfModeProvider);
    final isImageToPdf = mode == 0;

    if (isImageToPdf && _images.isNotEmpty) {
      return GlassCard(
        borderGradient: const [kAccentBlue, kAccentCyan],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(colors: [
                      kAccentBlue.withValues(alpha: 0.25),
                      kAccentCyan.withValues(alpha: 0.15),
                    ]),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: kAccentBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Output Preview', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary)),
                      Text('PDF · ${_images.length} page${_images.length == 1 ? '' : 's'}', style: const TextStyle(color: kTextTertiary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final img = _images[index];
                  return Container(
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF8F9FA),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: img.bytes != null
                                ? Image.memory(img.bytes!, fit: BoxFit.cover, width: double.infinity)
                                : Container(
                                    color: kAccentBlue.withValues(alpha: 0.06),
                                    child: Icon(Icons.image_rounded, color: kAccentBlue.withValues(alpha: 0.3), size: 40),
                                  ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                            color: Color(0xFFF0F1F3),
                          ),
                          child: Text(
                            img.name.length > 18 ? '${img.name.substring(0, 15)}...' : img.name,
                            style: TextStyle(fontSize: 10, color: kTextSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: kAccentGreen, size: 14),
                const SizedBox(width: 6),
                Text(
                  ref.read(ocrEnabledProvider) ? 'PDF with OCR text layer' : 'PDF from images',
                  style: const TextStyle(color: kTextSecondary, fontSize: 12),
                ),
                if (url != null) ...[
                  const Spacer(),
                  Icon(Icons.cloud_done_rounded, color: kAccentCyan, size: 14),
                  const SizedBox(width: 4),
                  const Text('Ready to download', style: TextStyle(color: kAccentCyan, fontSize: 11)),
                ],
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.06);
    }

    // PDF to Image mode: simple card
    return GlassCard(
      borderGradient: const [kAccentOrange, kAccentPink],
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(colors: [
                    kAccentOrange.withValues(alpha: 0.25),
                    kAccentPink.withValues(alpha: 0.15),
                  ]),
                ),
                child: const Icon(Icons.image_rounded, color: kAccentOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Output Preview', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary)),
                    Text('Images extracted from ${_pdfFile?.name ?? "PDF"}', style: const TextStyle(color: kTextTertiary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms);
  }

}

// ═══════════════════════════════════════════════════════════════════════════
// FORMAT CHIP (used for Output Format selection)
// ═══════════════════════════════════════════════════════════════════════════

class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.4) : kGlassBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? color : kTextTertiary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
