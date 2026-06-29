import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/Daily_Utility_Tool/age_calculator_model.dart';
import '../../api_services/Daily_Utility_Tool/services/age_services.dart';

class AgeCalculatorNotifier extends StateNotifier<AgeCalculatorState> {
  AgeCalculatorNotifier(this._service)
      : super(const AgeCalculatorState());

  final AgeServices _service;

  void updateSelectedDate(DateTime date) {
    state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
      clearError: true,
      clearResult: true,
    );
  }

  void updateTimezone(Duration offset) {
    state = state.copyWith(
      timezoneOffset: offset,
      clearError: true,
      clearResult: true,
    );
  }

  Future<void> calculateAge() async {
    final selectedDate = state.selectedDate;

    if (selectedDate == null) {
      state = state.copyWith(
        errorMessage: 'Please select date of birth.',
        clearResult: true,
      );
      return;
    }

    try {
      // Format date as YYYY-MM-DD
      final dobString = '${selectedDate.year.toString().padLeft(4, '0')}-'
          '${selectedDate.month.toString().padLeft(2, '0')}-'
          '${selectedDate.day.toString().padLeft(2, '0')}';

      // Use UTC as default timezone
      // Backend expects pytz timezone names like "UTC", "Asia/Kolkata", "America/New_York"
      const timezone = 'UTC';

      final request = AgeRequest(
        dob: dobString,
        targetDate: null, // Use current date
        timezone: timezone,
      );

      // Call backend API
      final response = await _service.calculateAge(request);
      final ageData = response.data;

      // Convert backend response to UI result model
      final result = AgeCalculationResult(
        years: ageData.years,
        months: ageData.months,
        days: ageData.days,
        daysToNextBirthday: ageData.nextBirthdayDays,
        totalDaysLived: ageData.totalDays,
        totalHoursLived: ageData.totalHours,
        zodiacSign: ageData.zodiacSign,
        planetAges: _calculatePlanetAges(ageData.years),
        historicalEvents: ageData.famousBirthdays.isNotEmpty 
            ? [ageData.historicalEvent]
            : [],
        famousBirthdays: ageData.famousBirthdays,
      );

      state = state.copyWith(result: result, clearError: true);
    } on DioException catch (e) {
      state = state.copyWith(
        errorMessage: _extractErrorMessage(e),
        clearResult: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Unable to calculate age. Please try again.',
        clearResult: true,
      );
    }
  }

  Map<String, double> _calculatePlanetAges(int earthYears) {
    return {
      "Mercury": earthYears / 0.24,
      "Venus": earthYears / 0.62,
      "Mars": earthYears / 1.88,
      "Jupiter": earthYears / 11.86,
      "Saturn": earthYears / 29.46,
    };
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