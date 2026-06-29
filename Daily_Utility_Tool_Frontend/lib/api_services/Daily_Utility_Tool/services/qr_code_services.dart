import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../api_routes.dart';
import '../../../models/Daily_Utility_Tool/qr_code_model.dart';

class QRCodeServices {
  static final Dio _dio = Dio();
  static bool _initialized = false;

  /// Initializes shared Dio instance with base URL, headers and debug logger.
  static void initializeDio() {
    if (_initialized) {
      return;
    }

    _dio.options = BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: kIsWeb ? null : const Duration(seconds: 20),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.clear();
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 120,
      ),
    );

    _initialized = true;
  }

  Dio get dio {
    if (!_initialized) {
      initializeDio();
    }
    return _dio;
  }

  /// Calls QR Code generation endpoint and parses response payload.
  Future<QRResponse> generateQRCode(QRRequest request) async {
    final response = await dio.post(
      qrCodeGenerateEndpoint,
      data: request.toJson(),
    );
    return QRResponse.fromJson(_mapResponse(response.data));
  }

  /// Safely normalizes dynamic API response into a JSON map.
  Map<String, dynamic> _mapResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }
}
