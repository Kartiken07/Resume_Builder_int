import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/ResumeBuilder/constants.dart';
import '../../models/ResumeBuilder/task_status.dart';
import '../../providers/ResumeBuilder/task_provider.dart';
import '../../widgets/ResumeBuilder/animated_gradient_background.dart';
import '../../cards/ResumeBuilder/glass_card.dart';
import '../../widgets/ResumeBuilder/glass_text_field.dart';
import '../../widgets/ResumeBuilder/glass_loading_spinner.dart';
import '../../widgets/ResumeBuilder/animated_upload_button.dart';
import '../../cards/ResumeBuilder/document_preview_card.dart';

/// PDF Merge & Split screen.
///
/// **Merge tab**: Drag-and-drop file list with reorder.
/// **Split tab**: Single file upload + integer-only page range input.
class MergeSplitScreen extends ConsumerStatefulWidget {
  const MergeSplitScreen({super.key});

  @override
  ConsumerState<MergeSplitScreen> createState() => _MergeSplitScreenState();
}

class _MergeSplitScreenState extends ConsumerState<MergeSplitScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _pageRangeCtrl = TextEditingController();

  // Real file list for merge (stores picker results)
  final List<PlatformFile> _mergeFiles = [];
  PlatformFile? _splitFile;

  // Track which tab triggered the last upload so preview is accurate
  int _lastUploadedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Reset shared task state when entering this screen
    Future.microtask(() => ref.read(taskNotifierProvider.notifier).reset());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageRangeCtrl.dispose();
    super.dispose();
  }

  // ── File picking ──────────────────────────────────────────────────────────

  Future<void> _addFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _mergeFiles.addAll(result.files));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick files: $e')),
        );
      }
    }
  }

  Future<void> _selectSplitFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _splitFile = result.files.first);
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

  void _uploadMerge() {
    setState(() => _lastUploadedTab = 0);
    ref.read(taskNotifierProvider.notifier).uploadFiles(
          filePaths: kIsWeb ? null : _mergeFiles.map((f) => f.path).toList(),
          fileBytesList: _mergeFiles.map((f) => f.bytes).toList(),
          fileNames: _mergeFiles.map((f) => f.name).toList(),
          endpoint: kUploadEndpoint,
        );
  }

  void _uploadSplit() {
    if (_splitFile == null) return;
    setState(() => _lastUploadedTab = 1);
    ref.read(taskNotifierProvider.notifier).uploadFile(
          filePath: kIsWeb ? null : _splitFile!.path,
          fileBytes: _splitFile!.bytes,
          fileName: _splitFile!.name,
          endpoint: kUploadEndpoint,
        );
  }

  // ── Download handler ──────────────────────────────────────────────────────

  Future<void> _launchDownload(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open download link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Merge & Split PDF'),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            borderRadius: 14,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: kAccentCyan.withValues(alpha: 0.15),
              ),
              dividerHeight: 0,
              tabs: const [
                Tab(text: 'Merge'),
                Tab(text: 'Split'),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMergeTab(taskState),
              _buildSplitTab(taskState),
            ],
          ),
        ),
      ),
    );
  }

  // ── Merge Tab ─────────────────────────────────────────────────────────────

  Widget _buildMergeTab(AsyncValue taskState) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Drop zone
          GlassCard(
            padding: EdgeInsets.zero,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(kCardBorderRadius),
              color: kAccentPink.withValues(alpha: 0.4),
              strokeWidth: 1.5,
              dashPattern: const [8, 6],
              child: InkWell(
                onTap: _addFiles,
                borderRadius: BorderRadius.circular(kCardBorderRadius),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          size: 36, color: kAccentPink.withValues(alpha: 0.7)),
                      const SizedBox(height: 10),
                      const Text(
                        'Tap to add PDF files',
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Files will be merged in the order listed',
                        style: TextStyle(color: kTextTertiary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

          const SizedBox(height: 20),

          // File list
          if (_mergeFiles.isNotEmpty) ...[
            GlassCard(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mergeFiles.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _mergeFiles.removeAt(oldIndex);
                    _mergeFiles.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  return ListTile(
                    key: ValueKey('${_mergeFiles[index].name}-$index'),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kAccentPink.withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: kAccentPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      _mergeFiles[index].name,
                      style:
                          const TextStyle(color: kTextPrimary, fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: kTextTertiary, size: 18),
                      onPressed: () {
                        setState(() => _mergeFiles.removeAt(index));
                      },
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 24),

            AnimatedUploadButton(
              onPressed: _uploadMerge,
              label: 'Merge ${_mergeFiles.length} Files',
              icon: Icons.call_merge_rounded,
              gradient: const [kAccentPink, kAccentOrange],
              isLoading: taskState is AsyncLoading,
            ).animate().fadeIn(delay: 300.ms),
          ],

          // Loading / result
          _buildTaskResult(taskState),
        ],
      ),
    );
  }

  // ── Split Tab ─────────────────────────────────────────────────────────────

  Widget _buildSplitTab(AsyncValue taskState) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // File selection
          GlassCard(
            padding: EdgeInsets.zero,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(kCardBorderRadius),
              color: kAccentCyan.withValues(alpha: 0.4),
              strokeWidth: 1.5,
              dashPattern: const [8, 6],
              child: InkWell(
                onTap: _selectSplitFile,
                borderRadius: BorderRadius.circular(kCardBorderRadius),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        _splitFile != null
                            ? Icons.description_rounded
                            : Icons.upload_file_rounded,
                        size: 36,
                        color: kAccentCyan.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _splitFile?.name ?? 'Select a PDF to split',
                        style: TextStyle(
                          color: _splitFile != null
                              ? kTextPrimary
                              : kTextSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

          const SizedBox(height: 20),

          // Page range input
          if (_splitFile != null) ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Page Extraction',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter page numbers to extract (e.g. 1, 3, 5-8)',
                    style: TextStyle(color: kTextTertiary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Integer-only text field
                  GlassTextField(
                    controller: _pageRangeCtrl,
                    label: 'Page Numbers',
                    hint: '1, 3, 5-8',
                    prefixIcon: Icons.pages_rounded,
                    // Allow digits, commas, hyphens, and spaces
                    integerOnly: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9,\- ]'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: AnimatedUploadButton(
                      onPressed: _uploadSplit,
                      label: 'Split PDF',
                      icon: Icons.call_split_rounded,
                      isLoading: taskState is AsyncLoading,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ],

          // Loading / result
          _buildTaskResult(taskState),
        ],
      ),
    );
  }

  // ── Shared Task Result ────────────────────────────────────────────────────

  Widget _buildTaskResult(AsyncValue taskState) {
    return taskState.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: const GlassLoadingSpinner(message: 'Processing your PDF...')
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.9, 0.9)),
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
      data: (taskStatus) {
        if (taskStatus == null) return const SizedBox.shrink();

        if (taskStatus.isPending) {
          return Padding(
            padding: const EdgeInsets.only(top: 40),
            child: GlassLoadingSpinner(
              message: taskStatus.status == TaskState.processing
                  ? 'Processing... ${((taskStatus.progress ?? 0) * 100).toInt()}%'
                  : 'Uploading...',
            ).animate().fadeIn(duration: 400.ms),
          );
        }

        if (taskStatus.isCompleted) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                _buildPreviewPanel(taskStatus.downloadUrl),
                const SizedBox(height: 16),
                GlassCard(
                  borderGradient: const [kAccentGreen, kAccentCyan],
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: kAccentGreen, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'Processing Complete!',
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (taskStatus.downloadUrl != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _launchDownload(taskStatus.downloadUrl!),
                            icon: const Icon(Icons.download_rounded, size: 20),
                            label: const Text('Download'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          ref.read(taskNotifierProvider.notifier).reset();
                          setState(() {
                            _mergeFiles.clear();
                            _splitFile = null;
                            _pageRangeCtrl.clear();
                          });
                        },
                        child: const Text('Process Another',
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

        if (taskStatus.isFailed) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GlassCard(
              borderGradient: const [kAccentPink, kAccentOrange],
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: kAccentPink, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    taskStatus.errorMessage ?? 'Processing failed',
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
    final isMergeTab = _lastUploadedTab == 0;
    final fileCount = _mergeFiles.length;

    return DocumentPreviewCard(
      fileName: isMergeTab
          ? '$fileCount files merged'
          : (_splitFile?.name ?? 'output.pdf'),
      outputType: 'PDF',
      pageCount: isMergeTab ? fileCount.clamp(1, 99) : 1,
      accentColor: isMergeTab ? kAccentPink : kAccentCyan,
      extraInfo: isMergeTab
          ? 'Merged $fileCount PDF file${fileCount == 1 ? '' : 's'}'
          : 'Split PDF ready',
      downloadUrl: url,
    );
  }

}
