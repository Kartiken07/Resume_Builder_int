import 'dart:js_interop';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;
import '../../utils/ResumeBuilder/constants.dart';
import '../../providers/ResumeBuilder/task_provider.dart';
import '../../providers/ResumeBuilder/ui_state_provider.dart';
import '../../widgets/ResumeBuilder/animated_gradient_background.dart';
import '../../cards/ResumeBuilder/glass_card.dart';
import '../../widgets/ResumeBuilder/glass_loading_spinner.dart';
import '../../widgets/ResumeBuilder/animated_upload_button.dart';
import '../../cards/ResumeBuilder/document_preview_card.dart';

const _allFormats = ['PDF', 'Word', 'Excel', 'Images', 'Text', 'JPG', 'PNG', 'WebP', 'BMP', 'TIFF', 'GIF'];

const _conversionMap = <String, List<String>>{
  // Document conversions
  'Word': ['PDF', 'Text'],
  'Excel': ['PDF', 'Text'],
  'PDF': ['Word', 'Excel', 'Text'],
  'Text': ['PDF', 'Word', 'Excel'],

  // Image → Document
  'Images': ['PDF', 'Word', 'Text'],

  // Document → Image
  // (handled via PDF intermediate: Word/Excel → PDF → Image)

  // Image format ↔ Image format (all inter-convertible)
  'JPG': ['PNG', 'WebP', 'BMP', 'TIFF', 'GIF', 'PDF'],
  'PNG': ['JPG', 'WebP', 'BMP', 'TIFF', 'GIF', 'PDF'],
  'WebP': ['JPG', 'PNG', 'BMP', 'TIFF', 'GIF', 'PDF'],
  'BMP': ['JPG', 'PNG', 'WebP', 'TIFF', 'GIF', 'PDF'],
  'TIFF': ['JPG', 'PNG', 'WebP', 'BMP', 'GIF', 'PDF'],
  'GIF': ['JPG', 'PNG', 'WebP', 'BMP', 'TIFF', 'PDF'],
};

const _formatExtensions = <String, List<String>>{
  'Word': ['docx', 'doc'],
  'Excel': ['xlsx', 'xls', 'csv'],
  'PDF': ['pdf'],
  'Images': ['jpg', 'jpeg', 'png', 'bmp', 'tiff', 'webp', 'gif'],
  'Text': ['txt', 'rtf'],
  'JPG': ['jpg', 'jpeg'],
  'PNG': ['png'],
  'WebP': ['webp'],
  'BMP': ['bmp'],
  'TIFF': ['tiff', 'tif'],
  'GIF': ['gif'],
};

const _formatEndpoints = <String, String>{
  // Document ↔ Document
  'Word→PDF': '/convert/word-to-pdf',
  'Word→Text': '/convert/word-to-text',
  'Excel→PDF': '/convert/excel-to-pdf',
  'Excel→Text': '/convert/excel-to-text',
  'PDF→Word': '/convert/pdf-to-word',
  'PDF→Excel': '/convert/pdf-to-excel',
  'PDF→Text': '/convert/pdf-to-text',
  'Text→PDF': '/convert/text-to-pdf',
  'Text→Word': '/convert/text-to-word',
  'Text→Excel': '/convert/text-to-excel',

  // Images → Document
  'Images→PDF': '/api/v1/convert/image-to-pdf',
  'Images→Word': '/convert/image-to-word',
  'Images→Text': '/convert/image-to-text',

  // Image format conversions
  'JPG→PNG': '/convert/jpg-to-png',
  'JPG→WebP': '/convert/jpg-to-webp',
  'JPG→BMP': '/convert/jpg-to-bmp',
  'JPG→TIFF': '/convert/jpg-to-tiff',
  'JPG→GIF': '/convert/jpg-to-gif',
  'JPG→PDF': '/convert/jpg-to-pdf',
  'PNG→JPG': '/convert/png-to-jpg',
  'PNG→WebP': '/convert/png-to-webp',
  'PNG→BMP': '/convert/png-to-bmp',
  'PNG→TIFF': '/convert/png-to-tiff',
  'PNG→GIF': '/convert/png-to-gif',
  'PNG→PDF': '/convert/png-to-pdf',
  'WebP→JPG': '/convert/webp-to-jpg',
  'WebP→PNG': '/convert/webp-to-png',
  'WebP→BMP': '/convert/webp-to-bmp',
  'WebP→TIFF': '/convert/webp-to-tiff',
  'WebP→GIF': '/convert/webp-to-gif',
  'WebP→PDF': '/convert/webp-to-pdf',
  'BMP→JPG': '/convert/bmp-to-jpg',
  'BMP→PNG': '/convert/bmp-to-png',
  'BMP→WebP': '/convert/bmp-to-webp',
  'BMP→TIFF': '/convert/bmp-to-tiff',
  'BMP→GIF': '/convert/bmp-to-gif',
  'BMP→PDF': '/convert/bmp-to-pdf',
  'TIFF→JPG': '/convert/tiff-to-jpg',
  'TIFF→PNG': '/convert/tiff-to-png',
  'TIFF→WebP': '/convert/tiff-to-webp',
  'TIFF→BMP': '/convert/tiff-to-bmp',
  'TIFF→GIF': '/convert/tiff-to-gif',
  'TIFF→PDF': '/convert/tiff-to-pdf',
  'GIF→JPG': '/convert/gif-to-jpg',
  'GIF→PNG': '/convert/gif-to-png',
  'GIF→WebP': '/convert/gif-to-webp',
  'GIF→BMP': '/convert/gif-to-bmp',
  'GIF→TIFF': '/convert/gif-to-tiff',
  'GIF→PDF': '/convert/gif-to-pdf',
};

const _formatColors = <String, Color>{
  'Word': kAccentBlue,
  'Excel': Color(0xFF217346),
  'PDF': kAccentPink,
  'Images': kAccentGreen,
  'Text': kAccentViolet,
  'JPG': Color(0xFFFF6F00),
  'PNG': Color(0xFF1565C0),
  'WebP': Color(0xFF00897B),
  'BMP': Color(0xFF5D4037),
  'TIFF': Color(0xFF6A1B9A),
  'GIF': Color(0xFFC62828),
};

const _formatIcons = <String, IconData>{
  'Word': Icons.description_rounded,
  'Excel': Icons.table_chart_rounded,
  'PDF': Icons.picture_as_pdf_rounded,
  'Images': Icons.photo_library_rounded,
  'Text': Icons.article_rounded,
  'JPG': Icons.image_rounded,
  'PNG': Icons.image_rounded,
  'WebP': Icons.image_rounded,
  'BMP': Icons.image_rounded,
  'TIFF': Icons.image_rounded,
  'GIF': Icons.gif_box_rounded,
};

class FormatConverterScreen extends ConsumerStatefulWidget {
  const FormatConverterScreen({super.key});

  @override
  ConsumerState<FormatConverterScreen> createState() =>
      _FormatConverterScreenState();
}

class _FormatConverterScreenState extends ConsumerState<FormatConverterScreen> {
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(taskNotifierProvider.notifier).reset());
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String get _endpointKey => '${ref.read(fromFormatProvider)}→${ref.read(toFormatProvider)}';

  // ── File picking ──────────────────────────────────────────────────────────

  Future<void> _selectFile() async {
    try {
      final mode = ref.read(formatModeProvider);
      List<String> extensions;

      if (mode == 0) {
        extensions = _formatExtensions[ref.read(fromFormatProvider)] ?? ['pdf'];
      } else if (mode == 1) {
        extensions = ['pdf', 'docx', 'doc'];
      } else {
        extensions = ['pdf'];
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _selectedFile = result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick file: $e')),
        );
      }
    }
  }

  // ── Upload handlers ───────────────────────────────────────────────────────

  void _uploadConvert() {
    if (_selectedFile == null) return;
    final endpoint = _formatEndpoints[_endpointKey];
    if (endpoint == null) return;
    ref.read(taskNotifierProvider.notifier).uploadFile(
          filePath: kIsWeb ? null : _selectedFile!.path,
          fileBytes: _selectedFile!.bytes,
          fileName: _selectedFile!.name,
          endpoint: endpoint,
        );
  }

  void _uploadCompress() {
    if (_selectedFile == null) return;
    ref.read(taskNotifierProvider.notifier).uploadFile(
          filePath: kIsWeb ? null : _selectedFile!.path,
          fileBytes: _selectedFile!.bytes,
          fileName: _selectedFile!.name,
          endpoint: '/compress',
        );
  }

  void _uploadEnhance() {
    if (_selectedFile == null) return;
    final sharpen = ref.read(enhanceSharpenProvider);
    final upscale = ref.read(enhanceUpscaleProvider);
    final denoise = ref.read(enhanceDenoiseProvider);
    ref.read(taskNotifierProvider.notifier).uploadFile(
          filePath: kIsWeb ? null : _selectedFile!.path,
          fileBytes: _selectedFile!.bytes,
          fileName: _selectedFile!.name,
          endpoint: '/enhance?sharpen=$sharpen&upscale=$upscale&denoise=$denoise',
        );
  }

  // ── Download handler ──────────────────────────────────────────────────────

  Future<void> _launchDownload(String url) async {
    if (kIsWeb) {
      // On web, trigger actual file download via anchor element
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
    final mode = ref.watch(formatModeProvider);
    final taskState = ref.watch(taskNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Format Converter'),
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
                _buildModeSelector(mode),
                const SizedBox(height: 20),
                if (mode == 0) _buildConvertMode(taskState),
                if (mode == 1) _buildCompressMode(taskState),
                if (mode == 2) _buildEnhanceMode(taskState),
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
      {'icon': Icons.swap_horiz_rounded, 'label': 'Convert'},
      {'icon': Icons.compress_rounded, 'label': 'Compress'},
      {'icon': Icons.auto_fix_high_rounded, 'label': 'Enhance'},
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(modes.length, (index) {
          final isActive = index == activeMode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(formatModeProvider.notifier).state = index;
                ref.read(taskNotifierProvider.notifier).reset();
                setState(() => _selectedFile = null);
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
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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
  // CONVERT MODE (two dropdowns)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildConvertMode(AsyncValue taskState) {
    final fromFmt = ref.watch(fromFormatProvider);
    final toFmt = ref.watch(toFormatProvider);
    final toOptions = _conversionMap[fromFmt] ?? [];
    final accentColor = _formatColors[fromFmt] ?? kAccentCyan;

    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conversion Type',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'From',
                      value: fromFmt,
                      items: _allFormats,
                      onChanged: (val) {
                        ref.read(fromFormatProvider.notifier).state = val;
                        final options = _conversionMap[val] ?? [];
                        if (!options.contains(ref.read(toFormatProvider))) {
                          ref.read(toFormatProvider.notifier).state = options.first;
                        }
                        ref.read(taskNotifierProvider.notifier).reset();
                        setState(() => _selectedFile = null);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Icon(Icons.arrow_forward_rounded, color: accentColor, size: 24),
                  ),
                  Expanded(
                    child: _buildDropdown(
                      label: 'To',
                      value: toOptions.contains(toFmt) ? toFmt : toOptions.first,
                      items: toOptions,
                      onChanged: (val) {
                        ref.read(toFormatProvider.notifier).state = val;
                        ref.read(taskNotifierProvider.notifier).reset();
                        setState(() => _selectedFile = null);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

        const SizedBox(height: 20),

        _buildUploadZone(
          label: 'Upload $fromFmt file',
          hint: 'Supports: ${(_formatExtensions[fromFmt] ?? []).map((e) => '.$e').join(', ')}',
          accentColor: accentColor,
        ),

        const SizedBox(height: 24),

        if (_selectedFile != null)
          AnimatedUploadButton(
            onPressed: _uploadConvert,
            label: 'Convert $fromFmt to $toFmt',
            icon: Icons.transform_rounded,
            gradient: [accentColor, kAccentCyan],
            isLoading: taskState is AsyncLoading,
          ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 20),

        _buildResult(taskState, 'Converting document...', 'Conversion Complete!', 'Convert Another', showPreview: false),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kTextTertiary, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: kGlassFill,
            border: Border.all(color: kGlassBorder, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: kBackgroundDark,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: kTextTertiary, size: 20),
              style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
              items: items.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Row(
                    children: [
                      Icon(_formatIcons[f], size: 16, color: _formatColors[f]),
                      const SizedBox(width: 8),
                      Text(f),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPRESS MODE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCompressMode(AsyncValue taskState) {
    return Column(
      children: [
        GlassCard(
          borderGradient: const [kAccentOrange, kAccentPink],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.compress_rounded, color: kAccentOrange.withValues(alpha: 0.8), size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'File Compression',
                    style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: kTextPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Reduce your file size without format conversion. Upload a PDF or Word document and set your desired target size.',
                style: TextStyle(color: kTextSecondary, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

        const SizedBox(height: 20),

        _buildUploadZone(
          label: 'Upload file to compress',
          hint: 'Supports .pdf, .docx, .doc formats',
          accentColor: kAccentOrange,
        ),

        const SizedBox(height: 20),

        if (_selectedFile != null)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.insert_drive_file_rounded, color: kAccentOrange.withValues(alpha: 0.7), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedFile!.name,
                          style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        'Original size: ${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(color: kTextTertiary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 20),

        // Info about compression
        if (_selectedFile != null)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: kAccentOrange.withValues(alpha: 0.7), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedFile!.name,
                          style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        'Size: ${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(color: kTextTertiary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 24),

        if (_selectedFile != null)
          AnimatedUploadButton(
            onPressed: _uploadCompress,
            label: 'Compress Now',
            icon: Icons.compress_rounded,
            gradient: const [kAccentOrange, kAccentPink],
            isLoading: taskState is AsyncLoading,
          ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 20),

        _buildResult(taskState, 'Compressing file...', 'Compression Complete!', 'Compress Another', showPreview: false),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ENHANCE MODE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildEnhanceMode(AsyncValue taskState) {
    final sharpen = ref.watch(enhanceSharpenProvider);
    final upscale = ref.watch(enhanceUpscaleProvider);
    final denoise = ref.watch(enhanceDenoiseProvider);

    return Column(
      children: [
        GlassCard(
          borderGradient: const [kAccentViolet, kAccentCyan],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_fix_high_rounded, color: kAccentViolet.withValues(alpha: 0.8), size: 22),
                  const SizedBox(width: 10),
                  Text('Pixel Improvement',
                      style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: kTextPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Enhance the visual quality of scanned or low-resolution PDFs. Sharpen text, upscale images, and remove noise artifacts.',
                style: TextStyle(color: kTextSecondary, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

        const SizedBox(height: 20),

        _buildUploadZone(label: 'Upload PDF to enhance', hint: 'Supports .pdf format', accentColor: kAccentViolet),

        const SizedBox(height: 20),

        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enhancement Options',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _EnhanceChip(label: 'Sharpen Text', icon: Icons.text_fields_rounded, isActive: sharpen, color: kAccentCyan,
                      onTap: () => ref.read(enhanceSharpenProvider.notifier).state = !sharpen),
                  _EnhanceChip(label: 'Upscale Images', icon: Icons.photo_size_select_large_rounded, isActive: upscale, color: kAccentGreen,
                      onTap: () => ref.read(enhanceUpscaleProvider.notifier).state = !upscale),
                  _EnhanceChip(label: 'Remove Noise', icon: Icons.blur_off_rounded, isActive: denoise, color: kAccentOrange,
                      onTap: () => ref.read(enhanceDenoiseProvider.notifier).state = !denoise),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05),

        const SizedBox(height: 24),

        if (_selectedFile != null)
          AnimatedUploadButton(
            onPressed: _uploadEnhance,
            label: 'Enhance Document',
            icon: Icons.auto_fix_high_rounded,
            gradient: const [kAccentViolet, kAccentCyan],
            isLoading: taskState is AsyncLoading,
          ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 20),

        _buildResult(taskState, 'Enhancing document...', 'Enhancement Complete!', 'Enhance Another', showPreview: false),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED UPLOAD ZONE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildUploadZone({required String label, required String hint, required Color accentColor}) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(kCardBorderRadius),
        color: accentColor.withValues(alpha: 0.4),
        strokeWidth: 1.5,
        dashPattern: const [8, 6],
        child: InkWell(
          onTap: _selectFile,
          borderRadius: BorderRadius.circular(kCardBorderRadius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Column(
              children: [
                Icon(
                  _selectedFile != null ? Icons.description_rounded : Icons.cloud_upload_rounded,
                  size: 40,
                  color: accentColor.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedFile?.name ?? label,
                  style: TextStyle(
                    color: _selectedFile != null ? kTextPrimary : kTextSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(hint, style: const TextStyle(color: kTextTertiary, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.05);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED RESULT BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildResult(AsyncValue taskState, String loadingMsg, String successMsg, String resetLabel, {bool showPreview = true}) {
    return taskState.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: GlassLoadingSpinner(message: loadingMsg).animate().fadeIn(duration: 400.ms),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: GlassCard(
          borderGradient: const [kAccentPink, kAccentOrange],
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: kAccentPink),
              const SizedBox(width: 12),
              Expanded(child: Text(error.toString(), style: const TextStyle(color: kTextSecondary))),
            ],
          ),
        ),
      ),
      data: (taskStatus) {
        if (taskStatus == null) return const SizedBox.shrink();
        if (taskStatus.isPending) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GlassLoadingSpinner(
              message: 'Processing... ${((taskStatus.progress ?? 0) * 100).toInt()}%',
            ).animate().fadeIn(duration: 400.ms),
          );
        }
        if (taskStatus.isCompleted) {
          return Column(
            children: [
              if (taskStatus.aiSummary != null)
                GlassCard(
                  borderGradient: const [kAccentViolet, kAccentCyan],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.auto_awesome_rounded, color: kAccentViolet.withValues(alpha: 0.8), size: 20),
                        const SizedBox(width: 8),
                        Text('AI Document Summary',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: kAccentViolet)),
                      ]),
                      const SizedBox(height: 12),
                      Text(taskStatus.aiSummary!, style: const TextStyle(color: kTextSecondary, fontSize: 13, height: 1.6)),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.08, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),
              if (showPreview) ...[
                _buildPreviewPanel(taskStatus.downloadUrl),
                const SizedBox(height: 16),
              ],

              GlassCard(
                borderGradient: const [kAccentGreen, kAccentCyan],
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: kAccentGreen, size: 36),
                    const SizedBox(height: 10),
                    Text(successMsg, style: const TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                    if (taskStatus.downloadUrl != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchDownload(taskStatus.downloadUrl!),
                          icon: const Icon(Icons.download_rounded, size: 20),
                          label: const Text('Download'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.read(taskNotifierProvider.notifier).reset();
                        setState(() => _selectedFile = null);
                      },
                      child: Text(resetLabel, style: const TextStyle(color: kAccentCyan)),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
            ],
          );
        }
        if (taskStatus.isFailed) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GlassCard(
              borderGradient: const [kAccentPink, kAccentOrange],
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: kAccentPink, size: 36),
                  const SizedBox(height: 12),
                  Text(taskStatus.errorMessage ?? 'Operation failed',
                      style: const TextStyle(color: kTextSecondary), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      ref.read(taskNotifierProvider.notifier).reset();
                      setState(() => _selectedFile = null);
                    },
                    child: const Text('Try Again', style: TextStyle(color: kAccentCyan)),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // PREVIEW PANEL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPreviewPanel(String? url) {
    final mode = ref.read(formatModeProvider);

    String outputType;
    Color accentColor;
    String extraInfo;

    if (mode == 0) {
      final toFmt = ref.read(toFormatProvider);
      outputType = toFmt;
      accentColor = _formatColors[toFmt] ?? kAccentCyan;
      extraInfo = 'Converted from ${ref.read(fromFormatProvider)}';
    } else if (mode == 1) {
      outputType = 'Compressed';
      accentColor = kAccentOrange;
      extraInfo = 'Compressed to target size';
    } else {
      outputType = 'Enhanced';
      accentColor = kAccentViolet;
      extraInfo = 'Pixel quality improved';
    }

    return DocumentPreviewCard(
      fileName: _selectedFile?.name ?? 'output',
      outputType: outputType,
      accentColor: accentColor,
      extraInfo: extraInfo,
      downloadUrl: url,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UNIT CHIP
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// GLASS TEXT FIELD
// ═══════════════════════════════════════════════════════════════════════════

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: kTextPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: kTextTertiary, size: 18) : null,
        labelStyle: const TextStyle(color: kTextTertiary, fontSize: 13),
        hintStyle: const TextStyle(color: kTextTertiary, fontSize: 13),
        filled: true,
        fillColor: kGlassFill,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kGlassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kAccentOrange.withValues(alpha: 0.5), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ENHANCE CHIP
// ═══════════════════════════════════════════════════════════════════════════

class _EnhanceChip extends StatelessWidget {
  const _EnhanceChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : kGlassBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? Icons.check_circle_rounded : icon, color: isActive ? color : kTextTertiary, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
                color: isActive ? color : kTextTertiary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
