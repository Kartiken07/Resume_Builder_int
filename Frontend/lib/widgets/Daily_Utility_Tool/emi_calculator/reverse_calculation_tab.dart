import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/Daily_Utility_Tool/emi_calculator_model.dart';
import '../../../providers/Daily_Utility_Tool/emi_calculator_provider.dart';
import '../../../theme/app_theme.dart';

enum ReverseCalculationType {
  loanAmount,
  requiredRate,
  tenure,
}

class ReverseCalculationTab extends ConsumerStatefulWidget {
  const ReverseCalculationTab({super.key});

  @override
  ConsumerState<ReverseCalculationTab> createState() =>
      _ReverseCalculationTabState();
}

class _ReverseCalculationTabState extends ConsumerState<ReverseCalculationTab> {
  ReverseCalculationType _calculationType = ReverseCalculationType.loanAmount;

  // Controllers for different calculation types
  final targetEmiController = TextEditingController(text: "23072");
  final rateController = TextEditingController(text: "10");
  final timeController = TextEditingController(text: "24");
  final principalController = TextEditingController(text: "500000");

  double _targetEmi = 23072;
  double _rate = 10;
  int _time = 24;
  double _principal = 500000;
  TimeUnit _unit = TimeUnit.months;
  PaymentFrequency _paymentFrequency = PaymentFrequency.monthly;

  bool _isLoading = false;
  String? _errorMessage;
  ReverseCalculationResponse? _result;

  @override
  void dispose() {
    targetEmiController.dispose();
    rateController.dispose();
    timeController.dispose();
    principalController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final service = ref.read(emiConverterServicesProvider);
      ReverseCalculationResponse response;

      switch (_calculationType) {
        case ReverseCalculationType.loanAmount:
          final request = ReverseCalculationLoanAmountRequest(
            targetEmi: _targetEmi,
            rate: _rate,
            time: _time,
            unit: _unit,
            paymentFrequency: _paymentFrequency,
          );
          response = await service.reverseLoanAmount(request);
          break;

        case ReverseCalculationType.requiredRate:
          final request = ReverseCalculationRateRequest(
            principal: _principal,
            targetEmi: _targetEmi,
            time: _time,
            unit: _unit,
            paymentFrequency: _paymentFrequency,
          );
          response = await service.reverseRequiredRate(request);
          break;

        case ReverseCalculationType.tenure:
          final request = ReverseCalculationTenureRequest(
            principal: _principal,
            rate: _rate,
            targetEmi: _targetEmi,
            paymentFrequency: _paymentFrequency,
          );
          response = await service.reverseTenure(request);
          break;
      }

      setState(() {
        _result = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Calculation failed. Please check your inputs.';
        _isLoading = false;
      });
    }
  }

  String format(double value) => "₹${value.toStringAsFixed(0)}";

  String _getResultLabel() {
    switch (_calculationType) {
      case ReverseCalculationType.loanAmount:
        return 'Maximum Loan Amount';
      case ReverseCalculationType.requiredRate:
        return 'Required Interest Rate';
      case ReverseCalculationType.tenure:
        return 'Required Tenure';
    }
  }

  String _getResultValue() {
    if (_result == null) return '';
    
    switch (_calculationType) {
      case ReverseCalculationType.loanAmount:
        return format(_result!.calculatedValue);
      case ReverseCalculationType.requiredRate:
        return '${_result!.calculatedValue.toStringAsFixed(2)}%';
      case ReverseCalculationType.tenure:
        return '${_result!.calculatedValue.toInt()} ${_result!.unit}';
    }
  }

  String _getCalculationDescription() {
    switch (_calculationType) {
      case ReverseCalculationType.loanAmount:
        return 'Find out how much you can borrow for your target EMI';
      case ReverseCalculationType.requiredRate:
        return 'Find the interest rate needed for your target EMI';
      case ReverseCalculationType.tenure:
        return 'Find how long it will take to repay your loan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),

            _buildDecorativeLine(),
            const SizedBox(height: 20),

            Text("REVERSE",
                    style: AppTheme.headingLarge.copyWith(height: 1.0))
                .animate()
                .fade()
                .slideY(begin: -0.2),

            Text("Calculation",
                    style: AppTheme.decorative.copyWith(height: 0.8))
                .animate()
                .fade(delay: 150.ms)
                .slideY(begin: -0.2),

            const SizedBox(height: 12),

            Text(
              "FIND MISSING PARAMETERS",
              style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
            ).animate().fade(delay: 300.ms),

            const SizedBox(height: 40),

            // Calculation Type Selector
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.shadowMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SELECT CALCULATION TYPE",
                    style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
                  ),
                  const SizedBox(height: 16),
                  _buildCalculationTypeCard(
                    ReverseCalculationType.loanAmount,
                    'Loan Amount',
                    'How much can I borrow?',
                    Icons.account_balance_wallet,
                  ),
                  const SizedBox(height: 12),
                  _buildCalculationTypeCard(
                    ReverseCalculationType.requiredRate,
                    'Required Rate',
                    'What rate do I need?',
                    Icons.percent,
                  ),
                  const SizedBox(height: 12),
                  _buildCalculationTypeCard(
                    ReverseCalculationType.tenure,
                    'Tenure',
                    'How long will it take?',
                    Icons.calendar_today,
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Input Card
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                boxShadow: AppTheme.shadowLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "INPUT PARAMETERS",
                      style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _getCalculationDescription(),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Target EMI (always shown)
                  TextField(
                    controller: targetEmiController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Target EMI (₹)',
                      labelStyle:
                          AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide:
                            BorderSide(color: AppTheme.primary, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        setState(() => _targetEmi = parsed);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Show different fields based on calculation type
                  if (_calculationType != ReverseCalculationType.loanAmount) ...[
                    // Principal (not needed for loan amount calc)
                    TextField(
                      controller: principalController,
                      keyboardType: TextInputType.number,
                      style: AppTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Loan Amount (₹)',
                        labelStyle: AppTheme.bodySmall
                            .copyWith(color: AppTheme.secondary),
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: BorderSide(color: AppTheme.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide:
                              BorderSide(color: AppTheme.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null) {
                          setState(() => _principal = parsed);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_calculationType != ReverseCalculationType.requiredRate) ...[
                    // Rate (not needed for rate calc)
                    TextField(
                      controller: rateController,
                      keyboardType: TextInputType.number,
                      style: AppTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Interest Rate (%)',
                        labelStyle: AppTheme.bodySmall
                            .copyWith(color: AppTheme.secondary),
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: BorderSide(color: AppTheme.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide:
                              BorderSide(color: AppTheme.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null) {
                          setState(() => _rate = parsed);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_calculationType != ReverseCalculationType.tenure) ...[
                    // Time (not needed for tenure calc)
                    TextField(
                      controller: timeController,
                      keyboardType: TextInputType.number,
                      style: AppTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText:
                            'Tenure (${_unit == TimeUnit.months ? 'months' : 'years'})',
                        labelStyle: AppTheme.bodySmall
                            .copyWith(color: AppTheme.secondary),
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: BorderSide(color: AppTheme.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide:
                              BorderSide(color: AppTheme.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null) {
                          setState(() => _time = parsed);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Time Unit
                    DropdownButtonFormField<TimeUnit>(
                      value: _unit,
                      dropdownColor: AppTheme.surface,
                      style: AppTheme.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Time Unit',
                        labelStyle: AppTheme.bodySmall
                            .copyWith(color: AppTheme.secondary),
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: BorderSide(color: AppTheme.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide:
                              BorderSide(color: AppTheme.primary, width: 2),
                        ),
                      ),
                      items: TimeUnit.values
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item == TimeUnit.months ? 'Months' : 'Years',
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _unit = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Payment Frequency
                  DropdownButtonFormField<PaymentFrequency>(
                    value: _paymentFrequency,
                    dropdownColor: AppTheme.surface,
                    style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Payment Frequency',
                      labelStyle:
                          AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide:
                            BorderSide(color: AppTheme.primary, width: 2),
                      ),
                    ),
                    items: PaymentFrequency.values
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _paymentFrequency = value);
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.background,
                        padding: AppTheme.buttonPadding,
                        disabledBackgroundColor: AppTheme.textTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.calculate_outlined, size: 18),
                      label: Text(
                        _isLoading ? "CALCULATING..." : "CALCULATE",
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.background,
                        ),
                      ),
                    ),
                  ),

                  // Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppTheme.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

            // Result Card
            if (_result != null) ...[
              const SizedBox(height: 24),

              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  boxShadow: AppTheme.shadowLarge,
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      "RESULT",
                      style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getResultLabel(),
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getResultValue(),
                            style: AppTheme.headingLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Validation Warnings
                    if (_result!.validationWarnings.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber,
                                    color: Colors.orange, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Warnings',
                                  style: AppTheme.labelSmall.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(
                              _result!.validationWarnings.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• ',
                                        style: AppTheme.bodySmall
                                            .copyWith(color: Colors.orange)),
                                    Expanded(
                                      child: Text(
                                        _result!.validationWarnings[index],
                                        style: AppTheme.bodySmall
                                            .copyWith(color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fade(delay: 200.ms).scale(),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationTypeCard(
    ReverseCalculationType type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _calculationType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _calculationType = type;
          _result = null;
          _errorMessage = null;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.background : AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 2,
          width: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
          ),
          child: const Icon(
            Icons.diamond_outlined,
            size: 12,
            color: AppTheme.background,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 2,
          width: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
