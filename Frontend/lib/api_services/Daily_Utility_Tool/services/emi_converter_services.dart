import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../api_routes.dart';
import '../../../models/Daily_Utility_Tool/emi_calculator_model.dart';

class EmiConverterServices {
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

  /// Calls EMI calculate endpoint and parses response payload.
  Future<EMIResponse> calculateEmi(EMIRequest request) async {
    final response = await dio.post(
      emiCalculateEndpoint,
      data: request.toJson(),
    );
    return EMIResponse.fromJson(_mapResponse(response.data));
  }

  /// Calls amortization schedule endpoint and parses schedule + summary.
  Future<AmortizationScheduleResponse> amortizationSchedule(
    AmortizationScheduleRequest request,
  ) async {
    final response = await dio.post(
      emiAmortizationScheduleEndpoint,
      data: request.toJson(),
    );
    return AmortizationScheduleResponse.fromJson(_mapResponse(response.data));
  }

  /// Calls prepayment analysis endpoint and parses impacts list.
  Future<PrepaymentAnalysisResponse> prepaymentAnalysis(
    PrepaymentAnalysisRequest request,
  ) async {
    final response = await dio.post(
      emiPrepaymentAnalysisEndpoint,
      data: request.toJson(),
    );
    return PrepaymentAnalysisResponse.fromJson(_mapResponse(response.data));
  }

  /// Calls reverse loan amount endpoint for target EMI scenarios.
  Future<ReverseCalculationResponse> reverseLoanAmount(
    ReverseCalculationLoanAmountRequest request,
  ) async {
    final response = await dio.post(
      emiReverseLoanAmountEndpoint,
      data: request.toJson(),
    );
    return ReverseCalculationResponse.fromJson(_mapResponse(response.data));
  }

  /// Calls reverse required rate endpoint for target EMI scenarios.
  Future<ReverseCalculationResponse> reverseRequiredRate(
    ReverseCalculationRateRequest request,
  ) async {
    final response = await dio.post(
      emiReverseRequiredRateEndpoint,
      data: request.toJson(),
    );
    return ReverseCalculationResponse.fromJson(_mapResponse(response.data));
  }

  /// Calls reverse tenure endpoint for target EMI scenarios.
  Future<ReverseCalculationResponse> reverseTenure(
    ReverseCalculationTenureRequest request,
  ) async {
    final response = await dio.post(
      emiReverseTenureEndpoint,
      data: request.toJson(),
    );
    return ReverseCalculationResponse.fromJson(_mapResponse(response.data));
  }

  /// Calls loan comparison endpoint and parses ranked loan list.
  Future<LoanComparisonResponse> compareLoans(
    LoanComparisonRequest request,
  ) async {
    final response = await dio.post(emiCompareEndpoint, data: request.toJson());
    return LoanComparisonResponse.fromJson(_mapResponse(response.data));
  }

  /// Calculates loan eligibility based on FOIR and existing EMIs.
  Future<EligibilityResponse> calculateEligibility(
    EligibilityRequest request,
  ) async {
    final response = await dio.post(
      emiEligibilityEndpoint,
      data: request.toJson(),
    );
    return EligibilityResponse.fromJson(_mapResponse(response.data));
  }

  /// Retrieves EMI calculation history from backend.
  Future<EMIHistoryResponse> getEMIHistory({
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await dio.get(
      emiHistoryEndpoint,
      queryParameters: {
        'skip': skip,
        'limit': limit,
      },
    );
    return EMIHistoryResponse.fromJson(_mapResponse(response.data));
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
