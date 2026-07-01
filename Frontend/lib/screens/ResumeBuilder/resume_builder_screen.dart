import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/ResumeBuilder/constants.dart';
import '../../utils/ResumeBuilder/pdf_generator.dart';
import '../../api_services/ResumeBuilder/services/ai_service.dart';
import '../../providers/ResumeBuilder/ui_state_provider.dart';
import '../../providers/ResumeBuilder/task_provider.dart';
import '../../widgets/ResumeBuilder/animated_gradient_background.dart';
import '../../cards/ResumeBuilder/glass_card.dart';
import '../../widgets/ResumeBuilder/glass_text_field.dart';
import '../../widgets/ResumeBuilder/glass_loading_spinner.dart';
import '../../widgets/ResumeBuilder/section_header.dart';
import '../../widgets/ResumeBuilder/resume_upload_zone.dart';
import '../../cards/ResumeBuilder/resume_preview_card.dart';
import '../../cards/ResumeBuilder/document_preview_card.dart';

/// AI Resume Builder screen with a responsive layout.
///
/// Desktop: Form on the left, Preview on the right (split 55/45).
/// Tablet: Adaptive narrower split layout.
/// Mobile: Stacked layout.
class ResumeBuilderScreen extends ConsumerStatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  ConsumerState<ResumeBuilderScreen> createState() =>
      _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends ConsumerState<ResumeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _techSkillsCtrl = TextEditingController();
  final _softSkillsCtrl = TextEditingController();
  final _projectNameCtrl = TextEditingController();
  final _projectDescCtrl = TextEditingController();

  bool _isAutoFilling = false;
  bool _isGenerating = false;
  bool _isCheckingAts = false;
  Map<String, dynamic>? _atsResult;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(taskNotifierProvider.notifier).reset());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _titleCtrl.dispose();
    _summaryCtrl.dispose();
    _experienceCtrl.dispose();
    _educationCtrl.dispose();
    _techSkillsCtrl.dispose();
    _softSkillsCtrl.dispose();
    _projectNameCtrl.dispose();
    _projectDescCtrl.dispose();
    super.dispose();
  }

  /// Picks a resume file and uses AI to parse and auto-fill all form fields.
  Future<void> _pickAndParseResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      setState(() => _isAutoFilling = true);

      final file = result.files.first;
      final ext = file.extension?.toLowerCase() ?? '';
      String resumeText = '';

      if (ext == 'pdf') {
        // Send PDF to backend for text extraction
        try {
          resumeText = await AIService.extractPdfText(file.bytes!, file.name);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not read PDF: $e'),
                backgroundColor: kAccentOrange,
              ),
            );
          }
          setState(() => _isAutoFilling = false);
          return;
        }
      } else {
        // Read .txt file as UTF-8
        try {
          resumeText = String.fromCharCodes(file.bytes!);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not read file. Please upload a valid text file.'),
                backgroundColor: kAccentOrange,
              ),
            );
          }
          setState(() => _isAutoFilling = false);
          return;
        }
      }

      if (resumeText.trim().isEmpty || resumeText.trim().length < 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File appears empty or too short. Please upload a valid resume.'),
              backgroundColor: kAccentPink,
            ),
          );
        }
        setState(() => _isAutoFilling = false);
        return;
      }

      // Use AI to parse the resume text
      final parsed = await AIService.parseResume(resumeText);

      // Check if AI actually returned meaningful data
      final hasData = (parsed['name']?.isNotEmpty == true) ||
          (parsed['email']?.isNotEmpty == true) ||
          (parsed['jobTitle']?.isNotEmpty == true);

      _nameCtrl.text = parsed['name'] ?? '';
      _emailCtrl.text = parsed['email'] ?? '';
      _phoneCtrl.text = parsed['phone'] ?? '';
      _titleCtrl.text = parsed['jobTitle'] ?? '';
      _summaryCtrl.text = parsed['summary'] ?? '';
      _experienceCtrl.text = parsed['experience'] ?? '';
      _educationCtrl.text = parsed['education'] ?? '';
      _projectNameCtrl.text = parsed['projectName'] ?? '';
      _projectDescCtrl.text = parsed['projectDesc'] ?? '';
      _techSkillsCtrl.text = parsed['techSkills'] ?? '';
      _softSkillsCtrl.text = parsed['softSkills'] ?? '';

      // Force UI rebuild so all fields visually update
      if (mounted) setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasData
                ? 'Resume parsed and fields filled successfully!'
                : 'AI could not extract data. Try a different file.'),
            backgroundColor: hasData ? kAccentGreen : kAccentOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI parsing failed: $e'),
            backgroundColor: kAccentPink,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAutoFilling = false);
    }
  }

  /// Uses AI to improve a specific field's content.
  Future<void> _improveField({
    required String fieldType,
    required TextEditingController controller,
  }) async {
    if (controller.text.trim().isEmpty) return;

    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('AI improving $fieldType...'),
            ],
          ),
          duration: const Duration(seconds: 30),
          backgroundColor: kAccentViolet,
        ),
      );

      final improved = await AIService.improveField(
        fieldType: fieldType,
        content: controller.text,
        jobTitle: _titleCtrl.text,
      );

      controller.text = improved;

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fieldType improved by AI!'),
            backgroundColor: kAccentGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI improvement failed: $e'),
            backgroundColor: kAccentPink,
          ),
        );
      }
    }
  }

  /// Downloads the resume as a locally-generated PDF.
  Future<void> _downloadPdf() async {
    try {
      await ResumePdfGenerator.downloadPdf(
        name: _nameCtrl.text,
        jobTitle: _titleCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        summary: _summaryCtrl.text,
        experience: _experienceCtrl.text,
        education: _educationCtrl.text,
        projectName: _projectNameCtrl.text,
        projectDesc: _projectDescCtrl.text,
        techSkills: _techSkillsCtrl.text,
        softSkills: _softSkillsCtrl.text,
        templateIndex: ref.read(resumeTemplateProvider),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF download failed: $e'),
            backgroundColor: kAccentPink,
          ),
        );
      }
    }
  }

  /// Downloads the resume as a .doc file (Word-compatible).
  Future<void> _downloadDocx() async {
    try {
      await ResumePdfGenerator.downloadDocx(
        name: _nameCtrl.text,
        jobTitle: _titleCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        summary: _summaryCtrl.text,
        experience: _experienceCtrl.text,
        education: _educationCtrl.text,
        projectName: _projectNameCtrl.text,
        projectDesc: _projectDescCtrl.text,
        techSkills: _techSkillsCtrl.text,
        softSkills: _softSkillsCtrl.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('DOCX download failed: $e'),
            backgroundColor: kAccentPink,
          ),
        );
      }
    }
  }

  /// Checks the ATS score of the current resume content using AI.
  Future<void> _checkAtsScore() async {
    if (_nameCtrl.text.trim().isEmpty && _summaryCtrl.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in some resume fields first.'),
            backgroundColor: kAccentOrange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isCheckingAts = true;
      _atsResult = null;
    });

    try {
      final result = await AIService.checkAtsScore(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        jobTitle: _titleCtrl.text,
        summary: _summaryCtrl.text,
        experience: _experienceCtrl.text,
        education: _educationCtrl.text,
        projectName: _projectNameCtrl.text,
        projectDesc: _projectDescCtrl.text,
        techSkills: _techSkillsCtrl.text,
        softSkills: _softSkillsCtrl.text,
      );

      if (mounted) {
        setState(() {
          _atsResult = result;
          _isCheckingAts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingAts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ATS check failed: $e'),
            backgroundColor: kAccentPink,
          ),
        );
      }
    }
  }

  // ── Template data ─────────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> _templates = [
    {
      'name': 'Modern',
      'icon': Icons.auto_awesome_rounded,
      'colors': [kAccentCyan, kAccentViolet],
    },
    {
      'name': 'Classic',
      'icon': Icons.menu_book_rounded,
      'colors': [kAccentBlue, kAccentCyan],
    },
    {
      'name': 'Minimal',
      'icon': Icons.crop_square_rounded,
      'colors': [kTextSecondary, kTextTertiary],
    },
    {
      'name': 'Creative',
      'icon': Icons.palette_rounded,
      'colors': [kAccentPink, kAccentOrange],
    },
    {
      'name': 'Elegant',
      'icon': Icons.diamond_rounded,
      'colors': [Color(0xFFD4AF37), Color(0xFF1E1E2C)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;
    final bool isTablet = width <= 900 && width >= 600;
    final selectedTemplate = ref.watch(resumeTemplateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI Resume Builder'),
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
                // ── Template Selector ────────────────────────────────
                _buildTemplateSelector(selectedTemplate),

                const SizedBox(height: 24),

                // ── Upload Zone ─────────────────────────────────────
                ResumeUploadZone(
                  isAutoFilling: _isAutoFilling,
                  onTap: _pickAndParseResume,
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),

                const SizedBox(height: 24),

                // ── Split Layout ────────────────────────────────────
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildForm(),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 5,
                        child: _buildPreview(selectedTemplate),
                      ),
                    ],
                  )
                else if (isTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildForm(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _buildPreview(selectedTemplate),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildForm(),
                      const SizedBox(height: 20),
                       _buildPreview(selectedTemplate),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEMPLATE SELECTOR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTemplateSelector(int selectedIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Choose Template',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final template = _templates[index];
              final isSelected = index == selectedIndex;
              final colors = template['colors'] as List<Color>;

              return GestureDetector(
                onTap: () =>
                    ref.read(resumeTemplateProvider.notifier).state = index,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors[0].withValues(alpha: isSelected ? 0.2 : 0.08),
                        colors[1].withValues(alpha: isSelected ? 0.12 : 0.04),
                      ],
                    ),
                    border: Border.all(
                      color: isSelected
                          ? colors[0].withValues(alpha: 0.6)
                          : kGlassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colors[0].withValues(alpha: 0.2),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        template['icon'] as IconData,
                        color: isSelected ? colors[0] : kTextTertiary,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        template['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected ? colors[0] : kTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 80 * index),
                    duration: 400.ms,
                  )
                  .slideX(begin: 0.1);
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FORM
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Personal Details',
              subtitle: 'Specify your basic contact details',
              prefixIcon: Icons.person_rounded,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 18),

            GlassTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'e.g. Arjun Mehta',
              prefixIcon: Icons.person_rounded,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            GlassTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'arjun@email.com',
              prefixIcon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            GlassTextField(
              controller: _phoneCtrl,
              label: 'Phone',
              hint: '+91 98765 43210',
              prefixIcon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            GlassTextField(
              controller: _titleCtrl,
              label: 'Job Title',
              hint: 'Senior Flutter Developer',
              prefixIcon: Icons.work_rounded,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your job title';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            GlassTextField(
              controller: _summaryCtrl,
              label: 'Professional Summary',
              hint: 'Brief overview of your career...',
              maxLines: 3,
              minLines: 2,
              onChanged: (_) => setState(() {}),
              suffixIcon: _AiImproveButton(
                onTap: () => _improveField(fieldType: 'summary', controller: _summaryCtrl),
              ),
            ),

            const SizedBox(height: 28),

            // ── Section Divider ──────────────────────────────────
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    kGlassBorder.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const SectionHeader(
              title: 'Work Experience & Education',
              subtitle: 'Highlight your career path and academic credentials',
              prefixIcon: Icons.history_edu_rounded,
            ),
            const SizedBox(height: 18),

            GlassTextField(
              controller: _experienceCtrl,
              label: 'Experience',
              hint: '• Role @ Company (Year-Year)',
              maxLines: 5,
              minLines: 3,
              onChanged: (_) => setState(() {}),
              suffixIcon: _AiImproveButton(
                onTap: () => _improveField(fieldType: 'experience', controller: _experienceCtrl),
              ),
            ),
            const SizedBox(height: 18),

            GlassTextField(
              controller: _educationCtrl,
              label: 'Education',
              hint: 'Degree — Institution (Year)',
              maxLines: 2,
              onChanged: (_) => setState(() {}),
              suffixIcon: _AiImproveButton(
                onTap: () => _improveField(fieldType: 'education', controller: _educationCtrl),
              ),
            ),

            const SizedBox(height: 28),

            // ── Section Divider ──────────────────────────────────
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    kGlassBorder.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const SectionHeader(
              title: 'Projects',
              subtitle: 'Feature your key project achievements',
              prefixIcon: Icons.code_rounded,
            ),
            const SizedBox(height: 18),

            GlassTextField(
              controller: _projectNameCtrl,
              label: 'Project Name',
              hint: 'e.g. DocuForge Smart Document Suite',
              prefixIcon: Icons.title_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),

            GlassTextField(
              controller: _projectDescCtrl,
              label: 'Project Description',
              hint: 'Describe your responsibilities, tech stack, and achievements...',
              maxLines: 3,
              minLines: 2,
              onChanged: (_) => setState(() {}),
              suffixIcon: _AiImproveButton(
                onTap: () => _improveField(fieldType: 'projectDesc', controller: _projectDescCtrl),
              ),
            ),

            const SizedBox(height: 28),

            // ── Section Divider ──────────────────────────────────
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    kGlassBorder.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const SectionHeader(
              title: 'Skills',
              subtitle: 'Detail your engineering tools and soft credentials',
              prefixIcon: Icons.construction_rounded,
            ),
            const SizedBox(height: 18),

            GlassTextField(
              controller: _techSkillsCtrl,
              label: 'Technical Skills',
              hint: 'Flutter, Dart, Riverpod, REST APIs...',
              onChanged: (_) => setState(() {}),
              suffixIcon: _AiImproveButton(
                onTap: () => _improveField(fieldType: 'techSkills', controller: _techSkillsCtrl),
              ),
            ),
            const SizedBox(height: 18),

            GlassTextField(
              controller: _softSkillsCtrl,
              label: 'Soft Skills',
              hint: 'Communication, Teamwork, Leadership...',
              onChanged: (_) => setState(() {}),
              suffixIcon: _AiImproveButton(
                onTap: () => _improveField(fieldType: 'softSkills', controller: _softSkillsCtrl),
              ),
            ),

            const SizedBox(height: 28),

            // ── ATS Score Check Button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isCheckingAts ? null : _checkAtsScore,
                icon: _isCheckingAts
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kAccentCyan,
                        ),
                      )
                    : const Icon(Icons.analytics_rounded, size: 20),
                label: Text(_isCheckingAts ? 'Analyzing ATS Score...' : 'Check ATS Score'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kAccentCyan,
                  side: BorderSide(color: kAccentCyan.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kButtonBorderRadius),
                  ),
                ),
              ),
            ),

            // ── ATS Score Result Display ─────────────────────────────
            if (_atsResult != null) ...[
              const SizedBox(height: 20),
              _buildAtsScoreCard(_atsResult!),
            ],

            const SizedBox(height: 20),

            // Download PDF button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating
                    ? null
                    : () async {
                        if (_nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your name first.'),
                              backgroundColor: kAccentOrange,
                            ),
                          );
                          return;
                        }
                        setState(() => _isGenerating = true);
                        try {
                          await _downloadPdf();
                        } finally {
                          if (mounted) setState(() => _isGenerating = false);
                        }
                      },
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(kBackgroundDark),
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded, size: 20),
                label: Text(
                    _isGenerating ? 'Generating...' : 'Download as PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kButtonBorderRadius),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Download DOCX button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isGenerating
                    ? null
                    : () async {
                        if (_nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your name first.'),
                              backgroundColor: kAccentOrange,
                            ),
                          );
                          return;
                        }
                        setState(() => _isGenerating = true);
                        try {
                          await _downloadDocx();
                        } finally {
                          if (mounted) setState(() => _isGenerating = false);
                        }
                      },
                icon: const Icon(Icons.description_rounded, size: 20),
                label: const Text('Download as DOC'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kAccentCyan,
                  side: BorderSide(color: kAccentCyan.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kButtonBorderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.05);
  }

  Widget _buildPreview(int templateIndex) {
    return ResumePreviewCard(
      templateIndex: templateIndex,
      name: _nameCtrl.text,
      jobTitle: _titleCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      summary: _summaryCtrl.text,
      experience: _experienceCtrl.text,
      education: _educationCtrl.text,
      techSkills: _techSkillsCtrl.text,
      softSkills: _softSkillsCtrl.text,
      projectName: _projectNameCtrl.text,
      projectDesc: _projectDescCtrl.text,
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.05);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ATS SCORE CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAtsScoreCard(Map<String, dynamic> result) {
    final score = (result['score'] as num?)?.toInt() ?? 0;
    final breakdown =
        (result['breakdown'] as Map<String, dynamic>?) ?? {};
    final strengths = (result['strengths'] as List?)?.cast<String>() ?? [];
    final weaknesses =
        (result['weaknesses'] as List?)?.cast<String>() ?? [];
    final suggestions =
        (result['suggestions'] as List?)?.cast<String>() ?? [];
    final overallFeedback = result['overallFeedback']?.toString() ?? '';

    Color scoreColor;
    String scoreLabel;
    if (score >= 80) {
      scoreColor = kAccentGreen;
      scoreLabel = 'Excellent';
    } else if (score >= 60) {
      scoreColor = kAccentCyan;
      scoreLabel = 'Good';
    } else if (score >= 40) {
      scoreColor = kAccentOrange;
      scoreLabel = 'Needs Work';
    } else {
      scoreColor = kAccentPink;
      scoreLabel = 'Poor';
    }

    return GlassCard(
      borderGradient: [scoreColor, kAccentViolet],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Score Circle + Label ────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular score indicator
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 7,
                        backgroundColor: kGlassFill,
                        valueColor: AlwaysStoppedAnimation(scoreColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: TextStyle(
                            color: scoreColor,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '/100',
                          style: TextStyle(
                            color: kTextTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ATS Compatibility',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scoreLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      overallFeedback,
                      style: TextStyle(
                        color: kTextTertiary,
                        fontSize: 11,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Breakdown Bars ──────────────────────────────────────
          if (breakdown.isNotEmpty) ...[
            Text(
              'Score Breakdown',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...breakdown.entries.map((e) {
              final val = (e.value as num?)?.toDouble() ?? 0;
              final label = e.key[0].toUpperCase() + e.key.substring(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label,
                            style: TextStyle(
                                color: kTextSecondary, fontSize: 12)),
                        Text('${val.toInt()}/25',
                            style: TextStyle(
                                color: kTextTertiary, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: val / 25,
                        backgroundColor: kGlassFill,
                        valueColor: AlwaysStoppedAnimation(scoreColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // ── Strengths ───────────────────────────────────────────
          if (strengths.isNotEmpty) ...[
            const SizedBox(height: 12),
            _atsSectionHeader('Strengths', kAccentGreen, Icons.check_circle_rounded),
            const SizedBox(height: 6),
            ...strengths.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_rounded,
                          color: kAccentGreen, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(s,
                            style: TextStyle(
                                color: kTextSecondary, fontSize: 12, height: 1.4)),
                      ),
                    ],
                  ),
                )),
          ],

          // ── Weaknesses ──────────────────────────────────────────
          if (weaknesses.isNotEmpty) ...[
            const SizedBox(height: 12),
            _atsSectionHeader('Weaknesses', kAccentPink, Icons.warning_rounded),
            const SizedBox(height: 6),
            ...weaknesses.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.close_rounded,
                          color: kAccentPink, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(w,
                            style: TextStyle(
                                color: kTextSecondary, fontSize: 12, height: 1.4)),
                      ),
                    ],
                  ),
                )),
          ],

          // ── Suggestions ─────────────────────────────────────────
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _atsSectionHeader('Suggestions', kAccentCyan, Icons.lightbulb_rounded),
            const SizedBox(height: 6),
            ...suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right_rounded,
                          color: kAccentCyan, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(s,
                            style: TextStyle(
                                color: kTextSecondary, fontSize: 12, height: 1.4)),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05);
  }

  Widget _atsSectionHeader(String label, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Small AI sparkle icon button used as suffixIcon in GlassTextField.
class _AiImproveButton extends StatelessWidget {
  const _AiImproveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              kAccentViolet.withValues(alpha: 0.2),
              kAccentCyan.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: kAccentViolet.withValues(alpha: 0.3),
          ),
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: kAccentViolet,
          size: 18,
        ),
      ),
    );
  }
}
