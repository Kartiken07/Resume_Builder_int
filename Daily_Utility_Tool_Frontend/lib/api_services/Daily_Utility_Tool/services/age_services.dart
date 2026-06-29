import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../api_routes.dart';
import '../../../models/Daily_Utility_Tool/age_calculator_model.dart';

class AgeServices {
  static final Dio _dio = Dio();
  static bool _initialized = false;

  /// Initialize Dio (same pattern as EMI & QR)
  static void initializeDio() {
    if (_initialized) return;

    _dio.options = BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      // sendTimeout is unsupported on Web for requests without a body (e.g. GET)
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
        responseBody: true,
        error: true,
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

  // CALCULATE AGE
  
  Future<AgeResponse> calculateAge(AgeRequest request) async {
    final response = await dio.post(
      ageCalculateEndpoint,
      data: request.toJson(),
    );

    return AgeResponse.fromJson(_mapResponse(response.data));
  }

  // RESPONSE HANDLER

  Map<String, dynamic> _mapResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }
}
