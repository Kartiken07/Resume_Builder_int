import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/Daily_Utility_Tool/emi_calculator_model.dart';
import '../../../providers/Daily_Utility_Tool/emi_calculator_provider.dart';
import '../../../theme/app_theme.dart';

class LoanEligibilityTab extends ConsumerStatefulWidget {
  const LoanEligibilityTab({super.key});

  @override
  ConsumerState<LoanEligibilityTab> createState() =>
      _LoanEligibilityTabState();
}

class _LoanEligibilityTabState extends ConsumerState<LoanEligibilityTab> {
  // Local state for this tab's inputs
  final monthlyIncomeController = TextEditingController(text: "50000");
  final existingEmiController = TextEditingController(text: "0");
  final foirLimitController = TextEditingController(text: "50");
  final rateController = TextEditingController(text: "10");
  final timeController = TextEditingController(text: "24");

  double _monthlyIncome = 50000;
  double _existingEmi = 0;
  double _foirLimit = 50;
  double _rate = 10;
  int _time = 24;
  TimeUnit _unit = TimeUnit.months;
  PaymentFrequency _paymentFrequency = PaymentFrequency.monthly;

  bool _isLoading = false;
  String? _errorMessage;
  EligibilityResponse? _result;

  @override
  void dispose() {
    monthlyIncomeController.dispose();
    existingEmiController.dispose();
    foirLimitController.dispose();
    rateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> _checkEligibility() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final service = ref.read(emiConverterServicesProvider);
      final request = EligibilityRequest(
        monthlyIncome: _monthlyIncome,
        existingEmi: _existingEmi,
        foirLimit: _foirLimit,
        rate: _rate,
        time: _time,
        unit: _unit,
        paymentFrequency: _paymentFrequency,
      );

      final response = await service.calculateEligibility(request);

      setState(() {
        _result = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check eligibility. Please try again.';
        _isLoading = false;
      });
    }
  }

  String format(double value) => "₹${value.toStringAsFixed(0)}";

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

            Text("LOAN", style: AppTheme.headingLarge.copyWith(height: 1.0))
                .animate()
                .fade()
                .slideY(begin: -0.2),

            Text("Eligibility",
                    style: AppTheme.decorative.copyWith(height: 0.8))
                .animate()
                .fade(delay: 150.ms)
                .slideY(begin: -0.2),

            const SizedBox(height: 12),

            Text(
              "CHECK YOUR ELIGIBILITY",
              style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
            ).animate().fade(delay: 300.ms),

            const SizedBox(height: 40),

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
                      "YOUR FINANCIAL DETAILS",
                      style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Monthly Income
                  TextField(
                    controller: monthlyIncomeController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Monthly Income (₹)',
                      helperText: 'Your gross monthly income',
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
                        setState(() => _monthlyIncome = parsed);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Existing EMI
                  TextField(
                    controller: existingEmiController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Existing EMIs (₹)',
                      helperText: 'Total of all current EMI obligations',
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
                        setState(() => _existingEmi = parsed);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // FOIR Limit
                  TextField(
                    controller: foirLimitController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'FOIR Limit (%)',
                      helperText:
                          'Fixed Obligation to Income Ratio (typically 40-50%)',
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
                        setState(() => _foirLimit = parsed);
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      "LOAN PARAMETERS",
                      style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Interest Rate
                  TextField(
                    controller: rateController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Interest Rate (%)',
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
                        setState(() => _rate = parsed);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tenure
                  TextField(
                    controller: timeController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText:
                          'Desired Tenure (${_unit == TimeUnit.months ? 'months' : 'years'})',
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
                      final parsed = int.tryParse(value);
                      if (parsed != null) {
                        setState(() => _time = parsed);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Time Unit and Payment Frequency Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<TimeUnit>(
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
                              borderSide:
                                  BorderSide(color: AppTheme.borderLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide:
                                  BorderSide(color: AppTheme.borderLight),
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
                                      item == TimeUnit.months
                                          ? 'Months'
                                          : 'Years',
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _unit = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<PaymentFrequency>(
                          value: _paymentFrequency,
                          dropdownColor: AppTheme.surface,
                          style: AppTheme.bodyMedium,
                          decoration: InputDecoration(
                            labelText: 'Payment Frequency',
                            labelStyle: AppTheme.bodySmall
                                .copyWith(color: AppTheme.secondary),
                            filled: true,
                            fillColor: AppTheme.background,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide:
                                  BorderSide(color: AppTheme.borderLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide:
                                  BorderSide(color: AppTheme.borderLight),
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Check Eligibility Button
                  SizedBox(
                    width: double.infinity,
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _checkEligibility,
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
                          : const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(
                        _isLoading ? "CHECKING..." : "CHECK ELIGIBILITY",
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
            ).animate().fade().slideY(begin: 0.1),

            // Results
            if (_result != null) ...[
              const SizedBox(height: 24),

              // Eligible Loan Amount Card (Main Result)
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  boxShadow: AppTheme.shadowLarge,
                  border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          "ELIGIBLE",
                          style: AppTheme.labelLarge.copyWith(
                            letterSpacing: 4,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade600],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Maximum Loan Amount',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            format(_result!.data.eligibleLoanAmount),
                            style: AppTheme.headingLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).scale(),

              const SizedBox(height: 16),

              // Details Card
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
                      'ELIGIBILITY DETAILS',
                      style: AppTheme.labelMedium.copyWith(letterSpacing: 2),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      'Monthly Income',
                      format(_result!.data.monthlyIncome),
                      Icons.account_balance_wallet,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Existing EMIs',
                      format(_result!.data.existingEmi),
                      Icons.payment,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'FOIR Limit',
                      '${_result!.data.foirLimit.toStringAsFixed(1)}%',
                      Icons.pie_chart,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Max Affordable EMI',
                      format(_result!.data.maxAffordableEmi),
                      Icons.trending_up,
                      highlight: true,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Interest Rate',
                      '${_result!.data.rate.toStringAsFixed(2)}%',
                      Icons.percent,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Tenure',
                      '${_result!.data.tenure} ${_result!.data.unit == TimeUnit.months ? 'months' : 'years'}',
                      Icons.calendar_today,
                    ),
                  ],
                ),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // Info Card
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is an indicative eligibility. Actual loan approval depends on lender policies and credit score.',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 400.ms),
            ],

            const SizedBox(height: 20),
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

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: highlight ? Colors.green : AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: highlight ? Colors.green : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
