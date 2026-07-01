import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/ResumeBuilder/constants.dart';
import 'glass_card.dart';

/// Template style configurations for the resume preview.
class _TemplateStyle {
  final String name;
  final Color accentColor;
  final Color secondaryColor;
  final List<Color> borderGradient;

  const _TemplateStyle({
    required this.name,
    required this.accentColor,
    required this.secondaryColor,
    required this.borderGradient,
  });
}

const _templateStyles = [
  _TemplateStyle(
    name: 'Modern',
    accentColor: kAccentCyan,
    secondaryColor: kAccentViolet,
    borderGradient: [kAccentCyan, kAccentViolet],
  ),
  _TemplateStyle(
    name: 'Classic',
    accentColor: kAccentBlue,
    secondaryColor: kAccentCyan,
    borderGradient: [kAccentBlue, kAccentCyan],
  ),
  _TemplateStyle(
    name: 'Minimal',
    accentColor: kTextSecondary,
    secondaryColor: kTextTertiary,
    borderGradient: [kTextSecondary, kTextTertiary],
  ),
  _TemplateStyle(
    name: 'Creative',
    accentColor: kAccentPink,
    secondaryColor: kAccentOrange,
    borderGradient: [kAccentPink, kAccentOrange],
  ),
  _TemplateStyle(
    name: 'Elegant',
    accentColor: const Color(0xFFD4AF37), // Gold
    secondaryColor: const Color(0xFF1E1E2C), // Dark Navy
    borderGradient: [Color(0xFFD4AF37), Color(0xFF1E1E2C)],
  ),
];

/// Reusable resume preview card.
/// Renders a real-time professional resume layout from form inputs.
/// Adapts its color scheme based on [templateIndex].
class ResumePreviewCard extends StatelessWidget {
  const ResumePreviewCard({
    super.key,
    this.templateIndex = 0,
    required this.name,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.summary,
    required this.experience,
    required this.education,
    required this.techSkills,
    required this.softSkills,
    required this.projectName,
    required this.projectDesc,
  });

  final int templateIndex;
  final String name;
  final String jobTitle;
  final String email;
  final String phone;
  final String summary;
  final String experience;
  final String education;
  final String techSkills;
  final String softSkills;
  final String projectName;
  final String projectDesc;

  bool get _isEmpty =>
      name.isEmpty &&
      jobTitle.isEmpty &&
      email.isEmpty &&
      phone.isEmpty &&
      summary.isEmpty &&
      experience.isEmpty &&
      education.isEmpty &&
      techSkills.isEmpty &&
      softSkills.isEmpty &&
      projectName.isEmpty &&
      projectDesc.isEmpty;

  _TemplateStyle get _style {
    if (templateIndex >= 0 && templateIndex < _templateStyles.length) {
      return _templateStyles[templateIndex];
    }
    return _templateStyles[0];
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return GlassCard(
      borderGradient: style.borderGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview header
          Row(
            children: [
              Icon(
                Icons.visibility_rounded,
                color: style.accentColor.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Live Preview',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: style.accentColor,
                ),
              ),
              const Spacer(),
              // Template badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: style.accentColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: style.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  style.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: style.accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Simulated resume preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGlassBorder),
            ),
            child: _isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: style.accentColor.withValues(alpha: 0.3),
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Start typing to see\nyour resume preview',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTextTertiary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        name.isEmpty ? 'Your Name' : name,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: name.isEmpty ? kTextTertiary : kTextPrimary,
                        ),
                      ),

                      if (jobTitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          jobTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: style.accentColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Contact row
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          if (email.isNotEmpty)
                            _previewContact(Icons.email_rounded, email),
                          if (phone.isNotEmpty)
                            _previewContact(Icons.phone_rounded, phone),
                        ],
                      ),

                      if (summary.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _previewSection('Summary', summary, style),
                      ],

                      if (experience.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _previewSection('Experience', experience, style),
                      ],

                      if (projectName.isNotEmpty || projectDesc.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _previewProjectSection(
                            projectName, projectDesc, style),
                      ],

                      if (education.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _previewSection('Education', education, style),
                      ],

                      if (techSkills.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _previewSection(
                            'Technical Skills', techSkills, style),
                      ],

                      if (softSkills.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _previewSection('Soft Skills', softSkills, style),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _previewContact(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 13, color: kTextTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: kTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _previewSection(
      String title, String content, _TemplateStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: style.accentColor.withValues(alpha: 0.6),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                style.accentColor.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 12,
            color: kTextSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _previewProjectSection(
      String projName, String projDesc, _TemplateStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROJECTS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: style.accentColor.withValues(alpha: 0.6),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                style.accentColor.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (projName.isNotEmpty)
          Text(
            projName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
        if (projDesc.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            projDesc,
            style: const TextStyle(
              fontSize: 12,
              color: kTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
