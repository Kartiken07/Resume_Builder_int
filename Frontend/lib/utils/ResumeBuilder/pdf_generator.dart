import 'dart:js_interop';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:web/web.dart' as web;

class ResumePdfGenerator {
  static Future<void> downloadPdf({
    required String name,
    required String jobTitle,
    required String email,
    required String phone,
    required String summary,
    required String experience,
    required String education,
    required String projectName,
    required String projectDesc,
    required String techSkills,
    required String softSkills,
    int templateIndex = 0,
  }) async {
    final bytes = await generatePdfBytes(
      name: name,
      jobTitle: jobTitle,
      email: email,
      phone: phone,
      summary: summary,
      experience: experience,
      education: education,
      projectName: projectName,
      projectDesc: projectDesc,
      techSkills: techSkills,
      softSkills: softSkills,
      templateIndex: templateIndex,
    );

    _downloadBytes(bytes, '${name.replaceAll(' ', '_')}_resume.pdf', 'application/pdf');
  }

  static Future<void> downloadDocx({
    required String name,
    required String jobTitle,
    required String email,
    required String phone,
    required String summary,
    required String experience,
    required String education,
    required String projectName,
    required String projectDesc,
    required String techSkills,
    required String softSkills,
  }) async {
    final html = _buildDocxHtml(
      name: name,
      jobTitle: jobTitle,
      email: email,
      phone: phone,
      summary: summary,
      experience: experience,
      education: education,
      projectName: projectName,
      projectDesc: projectDesc,
      techSkills: techSkills,
      softSkills: softSkills,
    );

    final bytes = Uint8List.fromList(html.codeUnits);
    _downloadBytes(bytes, '${name.replaceAll(' ', '_')}_resume.doc', 'application/msword');
  }

  static void _downloadBytes(List<int> bytes, String filename, String mimeType) {
    final data = Uint8List.fromList(bytes).buffer.toJS;
    final blob = web.Blob([data].toJS, web.BlobPropertyBag(type: mimeType));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = filename;
    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }

  static Future<List<int>> generatePdfBytes({
    required String name,
    required String jobTitle,
    required String email,
    required String phone,
    required String summary,
    required String experience,
    required String education,
    required String projectName,
    required String projectDesc,
    required String techSkills,
    required String softSkills,
    int templateIndex = 0,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interSemiBold();
    final fontHeader = await PdfGoogleFonts.outfitBold();

    final colors = _getTemplateColors(templateIndex);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text(
            name.isEmpty ? 'Your Name' : name,
            style: pw.TextStyle(
              font: fontHeader,
              fontSize: 26,
              color: PdfColor.fromHex(colors[0]),
            ),
          ),
          if (jobTitle.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              jobTitle,
              style: pw.TextStyle(
                font: font,
                fontSize: 13,
                color: PdfColor.fromHex(colors[1]),
              ),
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              if (email.isNotEmpty) ...[
                pw.Text(
                  email,
                  style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
                ),
                if (phone.isNotEmpty) pw.SizedBox(width: 20),
              ],
              if (phone.isNotEmpty)
                pw.Text(
                  phone,
                  style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
                ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(height: 1, color: PdfColor.fromHex(colors[0]).shade(0.3)),
          if (summary.isNotEmpty) ...[
            _sectionHeader('PROFESSIONAL SUMMARY', fontBold, colors[0]),
            pw.Text(
              summary,
              style: pw.TextStyle(font: font, fontSize: 10, height: 1.5, color: PdfColors.grey800),
            ),
          ],
          if (experience.isNotEmpty) ...[
            _sectionHeader('WORK EXPERIENCE', fontBold, colors[0]),
            pw.Text(
              experience,
              style: pw.TextStyle(font: font, fontSize: 10, height: 1.5, color: PdfColors.grey800),
            ),
          ],
          if (projectName.isNotEmpty || projectDesc.isNotEmpty) ...[
            _sectionHeader('PROJECTS', fontBold, colors[0]),
            if (projectName.isNotEmpty)
              pw.Text(
                projectName,
                style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColors.grey900),
              ),
            if (projectDesc.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                projectDesc,
                style: pw.TextStyle(font: font, fontSize: 10, height: 1.5, color: PdfColors.grey800),
              ),
            ],
          ],
          if (education.isNotEmpty) ...[
            _sectionHeader('EDUCATION', fontBold, colors[0]),
            pw.Text(
              education,
              style: pw.TextStyle(font: font, fontSize: 10, height: 1.5, color: PdfColors.grey800),
            ),
          ],
          if (techSkills.isNotEmpty || softSkills.isNotEmpty) ...[
            _sectionHeader('SKILLS', fontBold, colors[0]),
            if (techSkills.isNotEmpty)
              pw.Text(
                'Technical: $techSkills',
                style: pw.TextStyle(font: font, fontSize: 10, height: 1.5, color: PdfColors.grey800),
              ),
            if (softSkills.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                'Soft Skills: $softSkills',
                style: pw.TextStyle(font: font, fontSize: 10, height: 1.5, color: PdfColors.grey800),
              ),
            ],
          ],
        ],
      ),
    );

    return pdf.save();
  }

  static String _buildDocxHtml({
    required String name,
    required String jobTitle,
    required String email,
    required String phone,
    required String summary,
    required String experience,
    required String education,
    required String projectName,
    required String projectDesc,
    required String techSkills,
    required String softSkills,
  }) {
    String section(String title, String content) {
      if (content.isEmpty) return '';
      return '''
<p style="margin-top:16pt;margin-bottom:4pt;"><b style="color:#0078D4;font-size:11pt;letter-spacing:1pt;">$title</b></p>
<hr style="border:none;border-top:1px solid #0078D4;width:60px;margin:0 0 8pt 0;">
<p style="margin:0;font-size:10pt;line-height:1.5;color:#333;">${content.replaceAll('\n', '<br>')}</p>''';
    }

    return '''<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">
<head><meta charset="utf-8">
<style>
  body { font-family: Calibri, sans-serif; font-size: 10pt; color: #333; }
  h1 { font-size: 22pt; color: #0078D4; margin: 0 0 4pt 0; }
  h2 { font-size: 11pt; color: #555; margin: 0 0 8pt 0; font-weight: normal; }
  hr { border: none; border-top: 1px solid #ccc; margin: 12pt 0; }
</style>
</head>
<body>
<h1>${name.isEmpty ? 'Your Name' : name}</h1>
${jobTitle.isNotEmpty ? '<h2>$jobTitle</h2>' : ''}
<p>${email.isNotEmpty ? email : ''}${email.isNotEmpty && phone.isNotEmpty ? ' &nbsp;|&nbsp; ' : ''}${phone.isNotEmpty ? phone : ''}</p>
<hr>
${section('PROFESSIONAL SUMMARY', summary)}
${section('WORK EXPERIENCE', experience)}
${(projectName.isNotEmpty || projectDesc.isNotEmpty) ? '<p style="margin-top:16pt;margin-bottom:4pt;"><b style="color:#0078D4;font-size:11pt;letter-spacing:1pt;">PROJECTS</b></p><hr style="border:none;border-top:1px solid #0078D4;width:60px;margin:0 0 8pt 0;">${projectName.isNotEmpty ? '<p style="margin:0;font-weight:bold;font-size:10pt;">$projectName</p>' : ''}${projectDesc.isNotEmpty ? '<p style="margin:4pt 0 0 0;font-size:10pt;line-height:1.5;color:#333;">${projectDesc.replaceAll('\n', '<br>')}</p>' : ''}' : ''}
${section('EDUCATION', education)}
${(techSkills.isNotEmpty || softSkills.isNotEmpty) ? '<p style="margin-top:16pt;margin-bottom:4pt;"><b style="color:#0078D4;font-size:11pt;letter-spacing:1pt;">SKILLS</b></p><hr style="border:none;border-top:1px solid #0078D4;width:60px;margin:0 0 8pt 0;">${techSkills.isNotEmpty ? '<p style="margin:0;font-size:10pt;line-height:1.5;color:#333;"><b>Technical:</b> ${techSkills.replaceAll('\n', '<br>')}</p>' : ''}${softSkills.isNotEmpty ? '<p style="margin:4pt 0 0 0;font-size:10pt;line-height:1.5;color:#333;"><b>Soft Skills:</b> ${softSkills.replaceAll('\n', '<br>')}</p>' : ''}' : ''}
</body></html>''';
  }

  static pw.Widget _sectionHeader(String title, pw.Font font, String hexColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColor.fromHex(hexColor),
              letterSpacing: 1.2,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            height: 2,
            width: 60,
            color: PdfColor.fromHex(hexColor).shade(0.5),
          ),
        ],
      ),
    );
  }

  static List<String> _getTemplateColors(int index) {
    switch (index) {
      case 0:
        return ['#00D4FF', '#7B2FBE'];
      case 1:
        return ['#448AFF', '#00D4FF'];
      case 2:
        return ['#F0F0F5', '#808090'];
      case 3:
        return ['#FF2D78', '#FF9100'];
      case 4:
        return ['#D4AF37', '#1E1E2C'];
      default:
        return ['#00D4FF', '#7B2FBE'];
    }
  }
}
