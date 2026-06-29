import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/Daily_Utility_Tool/unit_converter_model.dart';
import '../../api_services/Daily_Utility_Tool/services/unit_converter_services.dart';

class UnitConverterNotifier extends StateNotifier<UnitConverterState> {
  UnitConverterNotifier(this._service)
      : super(
          const UnitConverterState(
            category: UnitCategory.length,
            value: 1.0,
            fromUnit: 'm',
            toUnit: 'km',
            isLoading: false,
            result: null,
            errorMessage: null,
            availableUnits: [],
            isLoadingUnits: false,
          ),
        ) {
    // Load units for the default category
    loadUnitsForCategory(state.category);
  }

  final UnitConverterServices _service;

  void updateCategory(UnitCategory category) {
    state = state.copyWith(
      category: category,
      clearError: true,
      clearResult: true,
    );
    loadUnitsForCategory(category);
  }

  void updateValue(double value) {
    state = state.copyWith(value: value, clearError: true);
  }

  void updateFromUnit(String unit) {
    state = state.copyWith(fromUnit: unit, clearError: true, clearResult: true);
  }

  void updateToUnit(String unit) {
    state = state.copyWith(toUnit: unit, clearError: true, clearResult: true);
  }

  void swapUnits() {
    final temp = state.fromUnit;
    state = state.copyWith(
      fromUnit: state.toUnit,
      toUnit: temp,
      clearError: true,
      clearResult: true,
    );
  }

  Future<void> loadUnitsForCategory(UnitCategory category) async {
    state = state.copyWith(isLoadingUnits: true);

    try {
      final response = await _service.getUnits(category);
      
      // Set default units based on category
      String defaultFromUnit = response.units.isNotEmpty ? response.units.first : '';
      String defaultToUnit = response.units.length > 1 ? response.units[1] : defaultFromUnit;

      // Special defaults for common categories
      if (category == UnitCategory.length && response.units.contains('m')) {
        defaultFromUnit = 'm';
        defaultToUnit = response.units.contains('km') ? 'km' : defaultFromUnit;
      } else if (category == UnitCategory.weight && response.units.contains('kg')) {
        defaultFromUnit = 'kg';
        defaultToUnit = response.units.contains('g') ? 'g' : defaultFromUnit;
      } else if (category == UnitCategory.temperature && response.units.contains('Celsius')) {
        defaultFromUnit = 'Celsius';
        defaultToUnit = response.units.contains('Fahrenheit') ? 'Fahrenheit' : defaultFromUnit;
      }

      state = state.copyWith(
        availableUnits: response.units,
        fromUnit: defaultFromUnit,
        toUnit: defaultToUnit,
        isLoadingUnits: false,
        clearError: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoadingUnits: false,
        errorMessage: _extractErrorMessage(e),
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingUnits: false,
        errorMessage: 'Unable to load units. Please try again.',
      );
    }
  }

  Future<void> convert() async {
    if (state.fromUnit.isEmpty || state.toUnit.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please select both from and to units.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = UnitConversionRequest(
        category: state.category,
        value: state.value,
        fromUnit: state.fromUnit,
        toUnit: state.toUnit,
      );

      final response = await _service.convert(request);

      state = state.copyWith(
        isLoading: false,
        result: response.result,
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
        errorMessage: 'Unable to convert units. Please try again.',
      );
    }
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
