// ============================================================================
// API REQUEST/RESPONSE MODELS (aligned with backend)
// ============================================================================

class AgeRequest {
  const AgeRequest({
    required this.dob,
    this.targetDate,
    this.timezone = 'UTC',
  });

  final String dob;
  final String? targetDate;
  final String timezone;

  Map<String, dynamic> toJson() {
    return {
      'dob': dob,
      if (targetDate != null) 'target_date': targetDate,
      'timezone': timezone,
    };
  }
}

class AgeResponse {
  const AgeResponse({
    required this.message,
    required this.data,
  });

  final String message;
  final AgeData data;

  factory AgeResponse.fromJson(Map<String, dynamic> json) {
    return AgeResponse(
      message: json['message']?.toString() ?? 'Age calculated successfully',
      data: AgeData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      ),
    );
  }
}

class AgeData {
  const AgeData({
    required this.years,
    required this.months,
    required this.days,
    required this.nextBirthdayDays,
    required this.totalDays,
    required this.totalWeeks,
    required this.totalHours,
    required this.dayOfBirth,
    required this.zodiacSign,
    required this.workingDays,
    required this.weekends,
    required this.lifeProgress,
    required this.historicalEvent,
    required this.famousBirthdays,
  });

  final int years;
  final int months;
  final int days;
  final int nextBirthdayDays;
  final int totalDays;
  final int totalWeeks;
  final int totalHours;
  final String dayOfBirth;
  final String zodiacSign;
  final int workingDays;
  final int weekends;
  final double lifeProgress;
  final String historicalEvent;
  final List<String> famousBirthdays;

  factory AgeData.fromJson(Map<String, dynamic> json) {
    // Parse famous_birthdays which can be either a Map or List
    List<String> parseFamousBirthdays(dynamic data) {
      if (data == null) return [];
      
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      
      if (data is Map) {
        // Flatten the map of categories into a single list
        final List<String> result = [];
        data.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            result.addAll(value.map((e) => e.toString()));
          }
        });
        return result;
      }
      
      return [];
    }

    return AgeData(
      years: json['years'] as int? ?? 0,
      months: json['months'] as int? ?? 0,
      days: json['days'] as int? ?? 0,
      nextBirthdayDays: json['next_birthday_days'] as int? ?? 0,
      totalDays: json['total_days'] as int? ?? 0,
      totalWeeks: json['total_weeks'] as int? ?? 0,
      totalHours: json['total_hours'] as int? ?? 0,
      dayOfBirth: json['day_of_birth']?.toString() ?? '',
      zodiacSign: json['zodiac_sign']?.toString() ?? '',
      workingDays: json['working_days'] as int? ?? 0,
      weekends: json['weekends'] as int? ?? 0,
      lifeProgress: (json['life_progress'] as num?)?.toDouble() ?? 0.0,
      historicalEvent: json['historical_event']?.toString() ?? '',
      famousBirthdays: parseFamousBirthdays(json['famous_birthdays']),
    );
  }
}

// ============================================================================
// UI STATE MODELS (for internal state management)
// ============================================================================

class AgeCalculationResult {
  const AgeCalculationResult({
    required this.years,
    required this.months,
    required this.days,
    required this.daysToNextBirthday,
    required this.totalDaysLived,

    // EXISTING NEW
    required this.totalHoursLived,
    required this.zodiacSign,
    required this.planetAges,

    // 🔥 NEW (BACKEND DATA)
    required this.historicalEvents,
    required this.famousBirthdays,
  });

  final int years;
  final int months;
  final int days;
  final int daysToNextBirthday;
  final int totalDaysLived;

  // EXISTING
  final int totalHoursLived;
  final String zodiacSign;
  final Map<String, double> planetAges;

  // 🔥 NEW
  final List<String> historicalEvents;
  final List<String> famousBirthdays;

  String get ageText => '$years Years, $months Months, $days Days';
  String get nextBirthdayText => '$daysToNextBirthday days left 🎉';
  String get totalDaysText => '$totalDaysLived days lived';

  // EXISTING
  String get totalHoursText => '$totalHoursLived hours lived';
  String get zodiacText => 'Zodiac: $zodiacSign';

  // 🔥 NEW GETTERS
  List<String> get historyList => historicalEvents;
  List<String> get birthdayList => famousBirthdays;
}

class AgeCalculatorState {
  const AgeCalculatorState({
    this.selectedDate,
    this.result,
    this.errorMessage,
    this.timezoneOffset,
  });

  final DateTime? selectedDate;
  final AgeCalculationResult? result;
  final String? errorMessage;
  final Duration? timezoneOffset;

  bool get hasResult => result != null;

  AgeCalculatorState copyWith({
    DateTime? selectedDate,
    AgeCalculationResult? result,
    String? errorMessage,
    Duration? timezoneOffset,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return AgeCalculatorState(
      selectedDate: selectedDate ?? this.selectedDate,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
    );
  }
}