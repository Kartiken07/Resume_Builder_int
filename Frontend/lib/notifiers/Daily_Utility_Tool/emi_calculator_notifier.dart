import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/Daily_Utility_Tool/emi_calculator_model.dart';
import '../../api_services/Daily_Utility_Tool/services/emi_converter_services.dart';

class EmiCalculatorNotifier extends StateNotifier<EmiCalculatorState> {
  EmiCalculatorNotifier(this._service)
    : super(
        const EmiCalculatorState(
          principal: 500000,
          rate: 10,
          time: 24,
          unit: TimeUnit.months,
          paymentFrequency: PaymentFrequency.monthly,
          isLoading: false,
          result: null,
          errorMessage: null,
        ),
      );

  final EmiConverterServices _service;

  static const double minPrincipal = 1;
  static const double maxPrincipal = 10000000;
  static const double minRate = 0.1;
  static const double maxRate = 40;
  static const int minTime = 1;
  static const int maxTimeYears = 40;
  static const int maxTimeMonths = 480;

  void updatePrincipal(double value) {
    state = state.copyWith(
      principal: value.clamp(minPrincipal, maxPrincipal),
      clearError: true,
    );
  }

  void updateRate(double value) {
    state = state.copyWith(
      rate: value.clamp(minRate, maxRate),
      clearError: true,
    );
  }

  void updateTime(int value) {
    final max = state.unit == TimeUnit.years ? maxTimeYears : maxTimeMonths;
    state = state.copyWith(time: value.clamp(minTime, max), clearError: true);
  }

  void updateUnit(TimeUnit unit) {
    final max = unit == TimeUnit.years ? maxTimeYears : maxTimeMonths;
    final adjustedTime = state.time.clamp(minTime, max);
    state = state.copyWith(unit: unit, time: adjustedTime, clearError: true);
  }

  void updatePaymentFrequency(PaymentFrequency frequency) {
    state = state.copyWith(paymentFrequency: frequency, clearError: true);
  }

  Future<void> calculateEmi() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = EMIRequest(
        principal: state.principal,
        rate: state.rate,
        time: state.time,
        unit: state.unit,
        paymentFrequency: state.paymentFrequency,
      );

      final response = await _service.calculateEmi(request);

      state = state.copyWith(
        isLoading: false,
        result: response.data,
        clearError: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractErrorMessage(e),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to calculate EMI. Please try again.',
      );
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail != null) {
        return detail.toString();
      }

      final message = data['message'];
      if (message != null) {
        return message.toString();
      }
    }

    if (e.type == DioExceptionType.connectionError) {
      if (kIsWeb) {
        return 'Could not connect. Verify backend is running, API base URL is correct, and CORS is enabled for your web localhost origin.';
      }
      return 'Could not connect to the server. Verify host/port and server status.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Request timed out. Please try again.';
    }

    return e.message ?? 'Something went wrong.';
  }
}
