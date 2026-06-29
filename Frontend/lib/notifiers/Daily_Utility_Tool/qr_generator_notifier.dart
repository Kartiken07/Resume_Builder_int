import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/Daily_Utility_Tool/qr_code_model.dart';
import '../../api_services/Daily_Utility_Tool/services/qr_code_services.dart';

class QRGeneratorNotifier extends StateNotifier<QRGeneratorState> {
  QRGeneratorNotifier(this._service)
      : super(
          const QRGeneratorState(
            data: '',
            size: 300,
            fillColor: '#000000',
            backColor: '#ffffff',
            errorCorrection: ErrorCorrectionLevel.M,
            shape: QRShape.square,
            frame: false,
            isLoading: false,
            result: null,
            errorMessage: null,
          ),
        );

  final QRCodeServices _service;

  static const int minSize = 100;
  static const int maxSize = 1000;

  void updateData(String value) {
    state = state.copyWith(data: value, clearError: true);
  }

  void updateSize(int value) {
    state = state.copyWith(
      size: value.clamp(minSize, maxSize),
      clearError: true,
    );
  }

  void updateFillColor(String value) {
    state = state.copyWith(fillColor: value, clearError: true);
  }

  void updateBackColor(String value) {
    state = state.copyWith(backColor: value, clearError: true);
  }

  void updateErrorCorrection(ErrorCorrectionLevel level) {
    state = state.copyWith(errorCorrection: level, clearError: true);
  }

  void updateShape(QRShape shape) {
    state = state.copyWith(shape: shape, clearError: true);
  }

  void updateFrame(bool value) {
    state = state.copyWith(frame: value, clearError: true);
  }

  Future<void> generateQRCode() async {
    if (state.data.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter data to generate QR code');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = QRRequest(
        data: state.data.trim(),
        size: state.size,
        fillColor: state.fillColor,
        backColor: state.backColor,
        errorCorrection: state.errorCorrection.value,
        shape: state.shape.value,
        frame: state.frame,
      );

      final response = await _service.generateQRCode(request);

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
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to generate QR code. Please try again.',
      );
    }
  }

  void clearResult() {
    state = state.copyWith(clearResult: true);
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
