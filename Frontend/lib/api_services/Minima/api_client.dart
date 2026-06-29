import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class ApiClient {
  late final String _baseUrl;
  late final Dio dio;

  ApiClient() {
    _baseUrl = _resolveBaseUrl();
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  String _resolveBaseUrl() {
    // Check if API_BASE_URL is defined at compile time
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (apiBaseUrl.isNotEmpty) {
      return apiBaseUrl;
    }

    // For mobile/desktop
    if (!kIsWeb) return 'http://10.0.2.2';

    final currentOrigin = html.window.location.origin;

    // For local development, use the configured backend IP (Nginx on port 80)
    if (currentOrigin.contains('localhost') || currentOrigin.contains('127.0.0.1')) {
       return 'http://192.168.1.6';
    }

    // If running on dev port 8080, assume backend is on port 80
    if (currentOrigin.contains(':8080')) {
       return currentOrigin.replaceFirst(':8080', '');
    }

    // Route all other requests (Nginx gateway or public tunnels) via the /api prefix
    return '$currentOrigin/api';
  }

  Future<Map<String, dynamic>> fetchStats(String shortCode) async {
    final response = await dio.get('/$shortCode/stats');
    return response.data;
  }
}
