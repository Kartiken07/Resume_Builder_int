import 'package:go_router/go_router.dart';

import '../../screens/ResumeBuilder/dashboard_screen.dart';
import '../../screens/ResumeBuilder/resume_builder_screen.dart';
import '../../screens/ResumeBuilder/format_converter_screen.dart';
import '../../screens/ResumeBuilder/image_to_pdf_screen.dart';
import '../../screens/ResumeBuilder/digital_signature_screen.dart';
import '../../screens/ResumeBuilder/merge_split_screen.dart';
import 'app_pages.dart';

/// All routes for the ResumeBuilder project.
/// Consumed by the top-level AppRouter via spread: [...resumeBuilderRoutes]
final List<RouteBase> resumeBuilderRoutes = [
  GoRoute(
    path: ResumeBuilderRoutes.dashboard,
    name: 'rb-dashboard',
    builder: (context, state) => const DashboardScreen(),
  ),
  GoRoute(
    path: ResumeBuilderRoutes.resumeBuilder,
    name: 'rb-resume-builder',
    builder: (context, state) => const ResumeBuilderScreen(),
  ),
  GoRoute(
    path: ResumeBuilderRoutes.formatConverter,
    name: 'rb-format-converter',
    builder: (context, state) => const FormatConverterScreen(),
  ),
  GoRoute(
    path: ResumeBuilderRoutes.imageToPdf,
    name: 'rb-image-to-pdf',
    builder: (context, state) => const ImageToPdfScreen(),
  ),
  GoRoute(
    path: ResumeBuilderRoutes.digitalSignature,
    name: 'rb-digital-signature',
    builder: (context, state) => const DigitalSignatureScreen(),
  ),
  GoRoute(
    path: ResumeBuilderRoutes.mergeSplit,
    name: 'rb-merge-split',
    builder: (context, state) => const MergeSplitScreen(),
  ),
];
