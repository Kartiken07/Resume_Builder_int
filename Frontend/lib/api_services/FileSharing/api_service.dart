import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// API service for the File Sharing project.
///
/// All traffic goes through the ToolHub Nginx reverse proxy.
/// Nginx maps  /fileshare/*  →  filesharesystem_backend:8000/*
///
/// Configure the base URL via dart-define:
///   flutter run --dart-define=FILESHARE_BASE_URL=http://192.168.1.5
///
/// Leave it empty (default) to hit the same host as the running app,
/// which on Windows/Linux desktop is http://127.0.0.1 (Nginx port 80).
class FileSharingApiService {
  static const String _nginxPrefix = '/fileshare';

  /// Your Mac / server LAN IP. Used as the default for mobile targets.
  /// Run `ipconfig getifaddr en0` on Mac to find it.
  static const String _lanIp = '192.168.1.5';

  static String get _defaultBaseUrl {
    // dart-define override takes highest priority
    const envUrl = String.fromEnvironment('FILESHARE_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      // Web: served from same machine, use relative host
      return 'http://127.0.0.1';
    }
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      // Mobile: needs the real LAN IP to reach Nginx
      return 'http://$_lanIp';
    }
    return 'http://127.0.0.1';
  }

  static String get baseUrl => _defaultBaseUrl;

  late final Dio _dio;

  FileSharingApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: '$baseUrl$_nginxPrefix',
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(minutes: 10),
      receiveTimeout: const Duration(seconds: 60),
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false, // avoid logging binary file data
        responseBody: true,
        error: true,
        logPrint: (o) => debugPrint('[FileSharing API] $o'),
      ));
    }
  }

  /// Upload a file and get back a shareable short link.
  Future<String> uploadFile({
    String? path,
    List<int>? bytes,
    String? filename,
    required int expiryMinutes,
  }) async {
    MultipartFile multipartFile;

    if (kIsWeb) {
      if (bytes == null || bytes.isEmpty) {
        throw Exception(
          'No file bytes available. Make sure FilePicker is called with withData: true on web.',
        );
      }
      multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: filename ?? 'upload.file',
      );
    } else if (path != null) {
      multipartFile = await MultipartFile.fromFile(path, filename: filename);
    } else {
      throw Exception('No file data provided (path is null on non-web platform)');
    }

    final formData = FormData.fromMap({
      'file': multipartFile,
      'expiry_minutes': expiryMinutes,
    });

    try {
      final response = await _dio.post(
        '/api/upload/simple',
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final link = response.data['link'] as String?;
      if (link == null || link.isEmpty) {
        throw Exception(
            'Server returned an empty link. Response: ${response.data}');
      }
      return link;
    } on DioException catch (e) {
      final msg = switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.connectionError =>
          'Cannot reach the server. Make sure ToolHub is running at $baseUrl.',
        DioExceptionType.sendTimeout =>
          'Upload timed out while sending the file. Try a smaller file or check your connection.',
        DioExceptionType.receiveTimeout =>
          'Server took too long to respond after upload. Please try again.',
        DioExceptionType.badResponse =>
          'Server error ${e.response?.statusCode}: ${e.response?.data}',
        _ => 'Upload failed: ${e.message}',
      };
      throw Exception(msg);
    }
  }
}
