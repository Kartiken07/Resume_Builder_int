import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../api_routes.dart';
import '../../../models/Daily_Utility_Tool/barcode_model.dart';

class BarcodeServices {
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

  /// Calls barcode generate endpoint and parses response payload.
  Future<BarcodeGenerationResponse> generateBarcode(
    BarcodeGenerationRequest request,
  ) async {
    final response = await dio.post(
      barcodeGenerateEndpoint,
      data: request.toJson(),
    );
    return BarcodeGenerationResponse.fromJson(_mapResponse(response.data));
  }

  /// Retrieves barcode generation history from backend.
  Future<BarcodeHistoryResponse> getBarcodeHistory({
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await dio.get(
      barcodeHistoryEndpoint,
      queryParameters: {
        'skip': skip,
        'limit': limit,
      },
    );
    return BarcodeHistoryResponse.fromJson(_mapResponse(response.data));
  }

  /// Downloads a barcode image by history ID.
  Future<void> downloadBarcode(int historyId, String filePath) async {
    await dio.download(
      '$barcodeDownloadEndpoint/$historyId',
      filePath,
    );
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
