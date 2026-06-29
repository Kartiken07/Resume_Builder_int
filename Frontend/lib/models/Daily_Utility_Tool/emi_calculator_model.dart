enum TimeUnit { months, years }

enum PaymentFrequency { monthly, quarterly, semiAnnual, annual }

extension TimeUnitX on TimeUnit {
  String get value {
    switch (this) {
      case TimeUnit.months:
        return 'months';
      case TimeUnit.years:
        return 'years';
    }
  }
}

extension PaymentFrequencyX on PaymentFrequency {
  String get value {
    switch (this) {
      case PaymentFrequency.monthly:
        return 'monthly';
      case PaymentFrequency.quarterly:
        return 'quarterly';
      case PaymentFrequency.semiAnnual:
        return 'semi_annual';
      case PaymentFrequency.annual:
        return 'annual';
    }
  }

  String get label {
    switch (this) {
      case PaymentFrequency.monthly:
        return 'Monthly';
      case PaymentFrequency.quarterly:
        return 'Quarterly';
      case PaymentFrequency.semiAnnual:
        return 'Semi-Annual';
      case PaymentFrequency.annual:
        return 'Annual';
    }
  }
}

TimeUnit timeUnitFromJson(String? value) {
  switch (value) {
    case 'years':
      return TimeUnit.years;
    case 'months':
    default:
      return TimeUnit.months;
  }
}

PaymentFrequency paymentFrequencyFromJson(String? value) {
  switch (value) {
    case 'quarterly':
      return PaymentFrequency.quarterly;
    case 'semi_annual':
      return PaymentFrequency.semiAnnual;
    case 'annual':
      return PaymentFrequency.annual;
    case 'monthly':
    default:
      return PaymentFrequency.monthly;
  }
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _asInt(dynamic value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

class EMIRequest {
  const EMIRequest({
    required this.principal,
    required this.rate,
    required this.time,
    this.unit = TimeUnit.months,
    this.paymentFrequency = PaymentFrequency.monthly,
  });

  final double principal;
  final double rate;
  final int time;
  final TimeUnit unit;
  final PaymentFrequency paymentFrequency;

  Map<String, dynamic> toJson() {
    return {
      'principal': principal,
      'rate': rate,
      'time': time,
      'unit': unit.value,
      'payment_frequency': paymentFrequency.value,
    };
  }
}

class AmortizationScheduleRequest extends EMIRequest {
  const AmortizationScheduleRequest({
    required super.principal,
    required super.rate,
    required super.time,
    super.unit,
    super.paymentFrequency,
    this.summaryByYear = false,
  });

  final bool summaryByYear;

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'summary_by_year': summaryByYear};
  }
}

class PrepaymentScenario {
  const PrepaymentScenario({required this.amount, required this.month});

  final double amount;
  final int month;

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'month': month};
  }
}

class PrepaymentAnalysisRequest extends EMIRequest {
  const PrepaymentAnalysisRequest({
    required super.principal,
    required super.rate,
    required super.time,
    super.unit,
    super.paymentFrequency,
    this.prepayments = const [],
  });

  final List<PrepaymentScenario> prepayments;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'prepayments': prepayments.map((e) => e.toJson()).toList(),
    };
  }
}

class ReverseCalculationLoanAmountRequest extends EMIRequest {
  const ReverseCalculationLoanAmountRequest({
    required this.targetEmi,
    required super.rate,
    required super.time,
    super.unit,
    super.paymentFrequency,
  }) : super(principal: 1);

  final double targetEmi;

  @override
  Map<String, dynamic> toJson() {
    return {
      'target_emi': targetEmi,
      'rate': rate,
      'time': time,
      'unit': unit.value,
      'payment_frequency': paymentFrequency.value,
    };
  }
}

class ReverseCalculationRateRequest {
  const ReverseCalculationRateRequest({
    required this.principal,
    required this.targetEmi,
    required this.time,
    this.unit = TimeUnit.months,
    this.paymentFrequency = PaymentFrequency.monthly,
  });

  final double principal;
  final double targetEmi;
  final int time;
  final TimeUnit unit;
  final PaymentFrequency paymentFrequency;

  Map<String, dynamic> toJson() {
    return {
      'principal': principal,
      'target_emi': targetEmi,
      'time': time,
      'unit': unit.value,
      'payment_frequency': paymentFrequency.value,
    };
  }
}

class ReverseCalculationTenureRequest {
  const ReverseCalculationTenureRequest({
    required this.principal,
    required this.rate,
    required this.targetEmi,
    this.paymentFrequency = PaymentFrequency.monthly,
  });

  final double principal;
  final double rate;
  final double targetEmi;
  final PaymentFrequency paymentFrequency;

  Map<String, dynamic> toJson() {
    return {
      'principal': principal,
      'rate': rate,
      'target_emi': targetEmi,
      'payment_frequency': paymentFrequency.value,
    };
  }
}

class LoanComparisonItem {
  const LoanComparisonItem({
    required this.principal,
    required this.rate,
    required this.tenureMonths,
    required this.paymentFrequency,
  });

  final double principal;
  final double rate;
  final int tenureMonths;
  final PaymentFrequency paymentFrequency;

  Map<String, dynamic> toJson() {
    return {
      'principal': principal,
      'rate': rate,
      'tenure_months': tenureMonths,
      'payment_frequency': paymentFrequency.value,
    };
  }
}

class LoanComparisonRequest {
  const LoanComparisonRequest({required this.loans});

  final List<LoanComparisonItem> loans;

  Map<String, dynamic> toJson() {
    return {'loans': loans.map((e) => e.toJson()).toList()};
  }
}

class EMIResponseData {
  const EMIResponseData({
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    required this.paymentFrequency,
  });

  final double emi;
  final double totalInterest;
  final double totalPayment;
  final PaymentFrequency paymentFrequency;

  factory EMIResponseData.fromJson(Map<String, dynamic> json) {
    return EMIResponseData(
      emi: _asDouble(json['emi']),
      totalInterest: _asDouble(json['total_interest']),
      totalPayment: _asDouble(json['total_payment']),
      paymentFrequency: paymentFrequencyFromJson(
        json['payment_frequency']?.toString(),
      ),
    );
  }
}

class EMIResponse {
  const EMIResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final EMIResponseData data;

  factory EMIResponse.fromJson(Map<String, dynamic> json) {
    return EMIResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? 'EMI calculated',
      data: EMIResponseData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      ),
    );
  }
}

class AmortizationScheduleRow {
  const AmortizationScheduleRow({
    required this.period,
    required this.payment,
    required this.principalPortion,
    required this.interestPortion,
    required this.remainingBalance,
  });

  final int period;
  final double payment;
  final double principalPortion;
  final double interestPortion;
  final double remainingBalance;

  factory AmortizationScheduleRow.fromJson(Map<String, dynamic> json) {
    return AmortizationScheduleRow(
      period: _asInt(json['period']),
      payment: _asDouble(json['payment']),
      principalPortion: _asDouble(json['principal_portion']),
      interestPortion: _asDouble(json['interest_portion']),
      remainingBalance: _asDouble(json['remaining_balance']),
    );
  }
}

class AmortizationScheduleSummary {
  const AmortizationScheduleSummary({
    required this.totalEmiPaid,
    required this.totalPrincipalPaid,
    required this.totalInterestPaid,
    required this.finalBalance,
  });

  final double totalEmiPaid;
  final double totalPrincipalPaid;
  final double totalInterestPaid;
  final double finalBalance;

  factory AmortizationScheduleSummary.fromJson(Map<String, dynamic> json) {
    return AmortizationScheduleSummary(
      totalEmiPaid: _asDouble(json['total_emi_paid']),
      totalPrincipalPaid: _asDouble(json['total_principal_paid']),
      totalInterestPaid: _asDouble(json['total_interest_paid']),
      finalBalance: _asDouble(json['final_balance']),
    );
  }
}

class AmortizationScheduleResponse {
  const AmortizationScheduleResponse({
    required this.success,
    required this.message,
    required this.schedule,
    required this.summary,
  });

  final bool success;
  final String message;
  final List<AmortizationScheduleRow> schedule;
  final AmortizationScheduleSummary summary;

  factory AmortizationScheduleResponse.fromJson(Map<String, dynamic> json) {
    final scheduleJson = (json['schedule'] as List? ?? []).cast<dynamic>();
    return AmortizationScheduleResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? 'Amortization schedule generated',
      schedule: scheduleJson
          .map(
            (e) => AmortizationScheduleRow.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      summary: AmortizationScheduleSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map? ?? {}),
      ),
    );
  }
}

class PrepaymentImpact {
  const PrepaymentImpact({
    required this.prepaymentAmount,
    required this.prepaymentMonth,
    required this.originalTenureMonths,
    required this.newTenureMonths,
    required this.monthsSaved,
    required this.originalTotalInterest,
    required this.newTotalInterest,
    required this.interestSaved,
    required this.newEmi,
  });

  final double prepaymentAmount;
  final int prepaymentMonth;
  final int originalTenureMonths;
  final int newTenureMonths;
  final int monthsSaved;
  final double originalTotalInterest;
  final double newTotalInterest;
  final double interestSaved;
  final double? newEmi;

  factory PrepaymentImpact.fromJson(Map<String, dynamic> json) {
    return PrepaymentImpact(
      prepaymentAmount: _asDouble(json['prepayment_amount']),
      prepaymentMonth: _asInt(json['prepayment_month']),
      originalTenureMonths: _asInt(json['original_tenure_months']),
      newTenureMonths: _asInt(json['new_tenure_months']),
      monthsSaved: _asInt(json['months_saved']),
      originalTotalInterest: _asDouble(json['original_total_interest']),
      newTotalInterest: _asDouble(json['new_total_interest']),
      interestSaved: _asDouble(json['interest_saved']),
      newEmi: json['new_emi'] == null ? null : _asDouble(json['new_emi']),
    );
  }
}

class PrepaymentAnalysisResponse {
  const PrepaymentAnalysisResponse({
    required this.success,
    required this.message,
    required this.originalEmi,
    required this.originalTotalInterest,
    required this.impacts,
  });

  final bool success;
  final String message;
  final double originalEmi;
  final double originalTotalInterest;
  final List<PrepaymentImpact> impacts;

  factory PrepaymentAnalysisResponse.fromJson(Map<String, dynamic> json) {
    final impactsJson = (json['impacts'] as List? ?? []).cast<dynamic>();
    return PrepaymentAnalysisResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? 'Prepayment analysis generated',
      originalEmi: _asDouble(json['original_emi']),
      originalTotalInterest: _asDouble(json['original_total_interest']),
      impacts: impactsJson
          .map(
            (e) =>
                PrepaymentImpact.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }
}

class ReverseCalculationResponse {
  const ReverseCalculationResponse({
    required this.success,
    required this.message,
    required this.calculatedValue,
    required this.unit,
    required this.validationWarnings,
  });

  final bool success;
  final String message;
  final double calculatedValue;
  final String unit;
  final List<String> validationWarnings;

  factory ReverseCalculationResponse.fromJson(Map<String, dynamic> json) {
    return ReverseCalculationResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? 'Reverse calculation completed',
      calculatedValue: _asDouble(json['calculated_value']),
      unit: json['unit']?.toString() ?? '',
      validationWarnings: (json['validation_warnings'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class EligibilityRequest {
  const EligibilityRequest({
    required this.monthlyIncome,
    required this.existingEmi,
    required this.foirLimit,
    required this.rate,
    required this.time,
    this.unit = TimeUnit.months,
    this.paymentFrequency = PaymentFrequency.monthly,
  });

  final double monthlyIncome;
  final double existingEmi;
  final double foirLimit;
  final double rate;
  final int time;
  final TimeUnit unit;
  final PaymentFrequency paymentFrequency;

  Map<String, dynamic> toJson() {
    return {
      'monthly_income': monthlyIncome,
      'existing_emi': existingEmi,
      'foir_limit': foirLimit,
      'rate': rate,
      'time': time,
      'unit': unit.value,
      'payment_frequency': paymentFrequency.value,
    };
  }
}

class EligibilityResponseData {
  const EligibilityResponseData({
    required this.monthlyIncome,
    required this.existingEmi,
    required this.foirLimit,
    required this.maxAffordableEmi,
    required this.eligibleLoanAmount,
    required this.rate,
    required this.tenure,
    required this.unit,
    required this.paymentFrequency,
  });

  final double monthlyIncome;
  final double existingEmi;
  final double foirLimit;
  final double maxAffordableEmi;
  final double eligibleLoanAmount;
  final double rate;
  final int tenure;
  final TimeUnit unit;
  final PaymentFrequency paymentFrequency;

  factory EligibilityResponseData.fromJson(Map<String, dynamic> json) {
    return EligibilityResponseData(
      monthlyIncome: _asDouble(json['monthly_income']),
      existingEmi: _asDouble(json['existing_emi']),
      foirLimit: _asDouble(json['foir_limit']),
      maxAffordableEmi: _asDouble(json['max_affordable_emi']),
      eligibleLoanAmount: _asDouble(json['eligible_loan_amount']),
      rate: _asDouble(json['rate']),
      tenure: _asInt(json['tenure']),
      unit: timeUnitFromJson(json['unit']?.toString()),
      paymentFrequency: paymentFrequencyFromJson(
        json['payment_frequency']?.toString(),
      ),
    );
  }
}

class EligibilityResponse {
  const EligibilityResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final EligibilityResponseData data;

  factory EligibilityResponse.fromJson(Map<String, dynamic> json) {
    return EligibilityResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? 'Eligibility calculated',
      data: EligibilityResponseData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      ),
    );
  }
}

class LoanComparisonResult {
  const LoanComparisonResult({
    required this.rank,
    required this.principal,
    required this.rate,
    required this.tenureMonths,
    required this.paymentFrequency,
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    required this.costDifferenceFromCheapest,
  });

  final int rank;
  final double principal;
  final double rate;
  final int tenureMonths;
  final PaymentFrequency paymentFrequency;
  final double emi;
  final double totalInterest;
  final double totalPayment;
  final double costDifferenceFromCheapest;

  factory LoanComparisonResult.fromJson(Map<String, dynamic> json) {
    return LoanComparisonResult(
      rank: _asInt(json['rank']),
      principal: _asDouble(json['principal']),
      rate: _asDouble(json['rate']),
      tenureMonths: _asInt(json['tenure_months']),
      paymentFrequency: paymentFrequencyFromJson(
        json['payment_frequency']?.toString(),
      ),
      emi: _asDouble(json['emi']),
      totalInterest: _asDouble(json['total_interest']),
      totalPayment: _asDouble(json['total_payment']),
      costDifferenceFromCheapest: _asDouble(
        json['cost_difference_from_cheapest'],
      ),
    );
  }
}

class LoanComparisonResponse {
  const LoanComparisonResponse({
    required this.success,
    required this.message,
    required this.loans,
  });

  final bool success;
  final String message;
  final List<LoanComparisonResult> loans;

  factory LoanComparisonResponse.fromJson(Map<String, dynamic> json) {
    final loansJson = (json['loans'] as List? ?? []).cast<dynamic>();
    return LoanComparisonResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? 'Loan comparison generated',
      loans: loansJson
          .map(
            (e) => LoanComparisonResult.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class EmiCalculatorState {
  const EmiCalculatorState({
    required this.principal,
    required this.rate,
    required this.time,
    required this.unit,
    required this.paymentFrequency,
    required this.isLoading,
    required this.result,
    required this.errorMessage,
  });

  final double principal;
  final double rate;
  final int time;
  final TimeUnit unit;
  final PaymentFrequency paymentFrequency;
  final bool isLoading;
  final EMIResponseData? result;
  final String? errorMessage;

  EmiCalculatorState copyWith({
    double? principal,
    double? rate,
    int? time,
    TimeUnit? unit,
    PaymentFrequency? paymentFrequency,
    bool? isLoading,
    EMIResponseData? result,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return EmiCalculatorState(
      principal: principal ?? this.principal,
      rate: rate ?? this.rate,
      time: time ?? this.time,
      unit: unit ?? this.unit,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ============================================================================
// HISTORY MODELS
// ============================================================================

class EMIHistoryItem {
  const EMIHistoryItem({
    required this.id,
    required this.principal,
    required this.rate,
    required this.time,
    required this.unit,
    required this.paymentFrequency,
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    required this.createdAt,
  });

  final int id;
  final double principal;
  final double rate;
  final int time;
  final TimeUnit unit;
  final PaymentFrequency paymentFrequency;
  final double emi;
  final double totalInterest;
  final double totalPayment;
  final DateTime createdAt;

  factory EMIHistoryItem.fromJson(Map<String, dynamic> json) {
    return EMIHistoryItem(
      id: _asInt(json['id']),
      principal: _asDouble(json['principal']),
      rate: _asDouble(json['rate']),
      time: _asInt(json['time']),
      unit: timeUnitFromJson(json['unit']?.toString()),
      paymentFrequency:
          paymentFrequencyFromJson(json['payment_frequency']?.toString()),
      emi: _asDouble(json['emi']),
      totalInterest: _asDouble(json['total_interest']),
      totalPayment: _asDouble(json['total_payment']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class EMIHistoryResponse {
  const EMIHistoryResponse({
    required this.success,
    required this.message,
    required this.history,
    required this.totalCount,
  });

  final bool success;
  final String message;
  final List<EMIHistoryItem> history;
  final int totalCount;

  factory EMIHistoryResponse.fromJson(Map<String, dynamic> json) {
    final historyJson = (json['history'] as List? ?? []).cast<dynamic>();
    return EMIHistoryResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? 'History retrieved',
      history: historyJson
          .map(
            (e) => EMIHistoryItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      totalCount: _asInt(json['total_count']),
    );
  }
}
