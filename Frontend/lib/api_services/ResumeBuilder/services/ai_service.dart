import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = 'http://localhost:8001';

  static Future<String> extractPdfText(List<int> pdfBytes, String filename) async {
    final uri = Uri.parse('$_baseUrl/api/v1/ai/extract-pdf-text');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      pdfBytes,
      filename: filename,
    ));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['text'] as String;
    }
    throw Exception('PDF extraction failed: ${response.body}');
  }

  static Future<String> chat(String systemPrompt, String userMessage) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/ai/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('AI API error ${response.statusCode}: ${response.body}');
    }
  }

  static Future<Map<String, String>> parseResume(String resumeText) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/ai/parse-resume'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'resume_text': resumeText}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as Map<String, dynamic>).map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }
    throw Exception('Parse failed: ${response.body}');
  }

  static Future<String> improveField({
    required String fieldType,
    required String content,
    required String jobTitle,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/ai/improve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'field_type': fieldType,
        'content': content,
        'job_title': jobTitle,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result'] as String;
    }
    throw Exception('Improve failed: ${response.body}');
  }

  static Future<Map<String, dynamic>> checkAtsScore({
    required String name,
    required String email,
    required String phone,
    required String jobTitle,
    required String summary,
    required String experience,
    required String education,
    required String projectName,
    required String projectDesc,
    required String techSkills,
    required String softSkills,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/ai/ats-score'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'job_title': jobTitle,
        'summary': summary,
        'experience': experience,
        'education': education,
        'project_name': projectName,
        'project_desc': projectDesc,
        'tech_skills': techSkills,
        'soft_skills': softSkills,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return {
      'score': 0,
      'breakdown': {'formatting': 0, 'keywords': 0, 'content': 0, 'impact': 0},
      'strengths': <String>[],
      'weaknesses': <String>[],
      'suggestions': <String>[],
      'overallFeedback': 'Could not analyze resume.',
    };
  }
}
