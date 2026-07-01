import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether AI OCR is enabled on the Image to PDF screen.
final ocrEnabledProvider = StateProvider<bool>((ref) => false);

/// The currently selected tool index on the dashboard (for animations).
final selectedToolIndexProvider = StateProvider<int>((ref) => -1);

/// The list of file names queued for merging.
final mergeFileQueueProvider = StateProvider<List<String>>((ref) => []);

/// The selected conversion direction on the Format Converter screen.
/// 0 = Word → PDF, 1 = PDF → Word, 1 = PDF → Word, 2 = PDF → Images, 3 = Images → PDF.
final conversionTypeProvider = StateProvider<int>((ref) => 0);

/// Format converter: selected "from" format.
final fromFormatProvider = StateProvider<String>((ref) => 'Word');

/// Format converter: selected "to" format.
final toFormatProvider = StateProvider<String>((ref) => 'PDF');

/// Active tab index on the Merge & Split screen (0 = Merge, 1 = Split).
final mergeSplitTabProvider = StateProvider<int>((ref) => 0);

/// Format Converter active mode: 0=Convert, 1=Compress, 2=Enhance.
final formatModeProvider = StateProvider<int>((ref) => 0);

/// Pixel enhancement options.
final enhanceSharpenProvider = StateProvider<bool>((ref) => true);
final enhanceUpscaleProvider = StateProvider<bool>((ref) => false);
final enhanceDenoiseProvider = StateProvider<bool>((ref) => false);

/// Selected resume template index.
final resumeTemplateProvider = StateProvider<int>((ref) => 0);

/// Active mode on the Image/PDF screen: 0 = Image to PDF, 1 = PDF to Image.
final imagePdfModeProvider = StateProvider<int>((ref) => 0);

/// Selected output format for PDF to Image conversion ('jpeg', 'png', 'heif').
final pdfToImageFormatProvider = StateProvider<String>((ref) => 'jpeg');
