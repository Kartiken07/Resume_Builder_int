import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/Daily_Utility_Tool/barcode_model.dart';
import '../../api_services/Daily_Utility_Tool/services/barcode_services.dart';

class BarcodeGeneratorState {
  const BarcodeGeneratorState({
    this.data = '',
    this.barcodeType = BarcodeType.code128,
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  final String data;
  final BarcodeType barcodeType;
  final bool isLoading;
  final BarcodeGenerationResponse? result;
  final String? errorMessage;

  BarcodeGeneratorState copyWith({
    String? data,
    BarcodeType? barcodeType,
    bool? isLoading,
    BarcodeGenerationResponse? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return BarcodeGeneratorState(
      data: data ?? this.data,
      barcodeType: barcodeType ?? this.barcodeType,
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BarcodeGeneratorNotifier extends StateNotifier<BarcodeGeneratorState> {
  BarcodeGeneratorNotifier(this._service)
      : super(const BarcodeGeneratorState());

  final BarcodeServices _service;

  void updateData(String value) {
    state = state.copyWith(data: value, clearError: true);
  }

  void updateBarcodeType(BarcodeType type) {
    state = state.copyWith(barcodeType: type, clearError: true);
  }

  Future<void> generateBarcode() async {
    if (state.data.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please enter data to generate barcode',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = BarcodeGenerationRequest(
        data: state.data.trim(),
        barcodeType: state.barcodeType,
      );

      final response = await _service.generateBarcode(request);

      state = state.copyWith(
        isLoading: false,
        result: response,
        clearError: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to generate barcode. Please try again.',
      );
    }
  }

  void clearResult() {
    state = state.copyWith(clearResult: true, clearError: true);
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail != null) {
        // Handle FastAPI validation error format
        if (detail is Map && detail['message'] != null) {
          return detail['message'].toString();
        }
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