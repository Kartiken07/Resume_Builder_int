import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/Daily_Utility_Tool/emi_calculator_model.dart';
import '../../../providers/Daily_Utility_Tool/emi_calculator_provider.dart';
import '../../../theme/app_theme.dart';

class PrepaymentAnalysisTab extends ConsumerStatefulWidget {
  const PrepaymentAnalysisTab({super.key});

  @override
  ConsumerState<PrepaymentAnalysisTab> createState() =>
      _PrepaymentAnalysisTabState();
}

class _PrepaymentAnalysisTabState extends ConsumerState<PrepaymentAnalysisTab> {
  // Local state for this tab's inputs
  final principalController = TextEditingController(text: "500000");
  final rateController = TextEditingController(text: "10");
  final timeController = TextEditingController(text: "24");

  double _principal = 500000;
  double _rate = 10;
  int _time = 24;
  TimeUnit _unit = TimeUnit.months;
  PaymentFrequency _paymentFrequency = PaymentFrequency.monthly;

  // Prepayment scenarios
  final List<PrepaymentScenario> _prepayments = [];

  bool _isLoading = false;
  String? _errorMessage;
  PrepaymentAnalysisResponse? _analysis;

  @override
  void dispose() {
    principalController.dispose();
    rateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> _analyzePrePayments() async {
    if (_prepayments.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one prepayment scenario';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(emiConverterServicesProvider);
      final request = PrepaymentAnalysisRequest(
        principal: _principal,
        rate: _rate,
        time: _time,
        unit: _unit,
        paymentFrequency: _paymentFrequency,
        prepayments: _prepayments,
      );

      final response = await service.prepaymentAnalysis(request);

      setState(() {
        _analysis = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to analyze prepayments. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _addPrepayment() {
    showDialog(
      context: context,
      builder: (context) => _PrepaymentDialog(
        maxMonth: _unit == TimeUnit.months ? _time : _time * 12,
        onAdd: (scenario) {
          setState(() {
            _prepayments.add(scenario);
            _analysis = null; // Clear previous analysis
          });
        },
      ),
    );
  }

  void _removePrepayment(int index) {
    setState(() {
      _prepayments.removeAt(index);
      _analysis = null;
    });
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

            Text("PREPAYMENT",
                    style: AppTheme.headingLarge.copyWith(height: 1.0))
                .animate()
                .fade()
                .slideY(begin: -0.2),

            Text("Analysis", style: AppTheme.decorative.copyWith(height: 0.8))
                .animate()
                .fade(delay: 150.ms)
                .slideY(begin: -0.2),

            const SizedBox(height: 12),

            Text(
              "IMPACT OF EXTRA PAYMENTS",
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
                      "LOAN DETAILS",
                      style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Loan Amount Input
                  TextField(
                    controller: principalController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Loan Amount (₹)',
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
                        setState(() => _principal = parsed);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Interest Rate Input
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

                  // Tenure Input
                  TextField(
                    controller: timeController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText:
                          'Tenure (${_unit == TimeUnit.months ? 'months' : 'years'})',
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

                  const SizedBox(height: 32),

                  // Prepayments Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "PREPAYMENTS",
                        style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
                      ),
                      TextButton.icon(
                        onPressed: _addPrepayment,
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: Text(
                          'ADD',
                          style: AppTheme.labelSmall,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (_prepayments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: AppTheme.borderLight,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'No prepayments added yet',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_prepayments.length, (index) {
                      final prepayment = _prepayments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.payment,
                                color: AppTheme.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    format(prepayment.amount),
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Month ${prepayment.month}',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: AppTheme.error, size: 20),
                              onPressed: () => _removePrepayment(index),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // Analyze Button
                  SizedBox(
                    width: double.infinity,
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _analyzePrePayments,
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
                          : const Icon(Icons.analytics_outlined, size: 18),
                      label: Text(
                        _isLoading ? "ANALYZING..." : "ANALYZE PREPAYMENTS",
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

            // Analysis Results
            if (_analysis != null) ...[
              const SizedBox(height: 24),

              // Original Loan Info Card
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.shadowMedium,
                  border: Border.all(
                      color: AppTheme.secondary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORIGINAL LOAN',
                      style: AppTheme.labelMedium.copyWith(letterSpacing: 2),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'EMI',
                      format(_analysis!.originalEmi),
                      Icons.payments,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Total Interest',
                      format(_analysis!.originalTotalInterest),
                      Icons.trending_up,
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // Impact Cards
              ...List.generate(_analysis!.impacts.length, (index) {
                final impact = _analysis!.impacts[index];
                return Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: AppTheme.shadowMedium,
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.payment,
                                color: AppTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prepayment ${index + 1}',
                                  style: AppTheme.labelMedium,
                                ),
                                Text(
                                  '${format(impact.prepaymentAmount)} at Month ${impact.prepaymentMonth}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildImpactRow(
                        'Tenure Saved',
                        '${impact.monthsSaved} months',
                        '${impact.originalTenureMonths} → ${impact.newTenureMonths}',
                        Icons.calendar_today,
                        AppTheme.primary,
                      ),
                      const SizedBox(height: 12),
                      _buildImpactRow(
                        'Interest Saved',
                        format(impact.interestSaved),
                        '${format(impact.originalTotalInterest)} → ${format(impact.newTotalInterest)}',
                        Icons.savings,
                        Colors.green,
                      ),
                      if (impact.newEmi != null) ...[
                        const SizedBox(height: 12),
                        _buildImpactRow(
                          'New EMI',
                          format(impact.newEmi!),
                          'EMI remains same if tenure reduced',
                          Icons.payments,
                          AppTheme.secondary,
                        ),
                      ],
                    ],
                  ),
                )
                    .animate()
                    .fade(delay: (300 + (index * 100)).ms)
                    .slideY(begin: 0.1);
              }),
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactRow(
    String label,
    String value,
    String detail,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            detail,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textTertiary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// Dialog to add prepayment
class _PrepaymentDialog extends StatefulWidget {
  final int maxMonth;
  final Function(PrepaymentScenario) onAdd;

  const _PrepaymentDialog({
    required this.maxMonth,
    required this.onAdd,
  });

  @override
  State<_PrepaymentDialog> createState() => _PrepaymentDialogState();
}

class _PrepaymentDialogState extends State<_PrepaymentDialog> {
  final amountController = TextEditingController();
  final monthController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    monthController.dispose();
    super.dispose();
  }

  void _add() {
    final amount = double.tryParse(amountController.text);
    final month = int.tryParse(monthController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (month == null || month <= 0 || month > widget.maxMonth) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a month between 1 and ${widget.maxMonth}'),
        ),
      );
      return;
    }

    widget.onAdd(PrepaymentScenario(amount: amount, month: month));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      title: Text('Add Prepayment', style: AppTheme.headingSmall),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Prepayment Amount (₹)',
                labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: monthController,
              keyboardType: TextInputType.number,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'At Month',
                labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                helperText: 'Enter month number (1-${widget.maxMonth})',
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('CANCEL', style: AppTheme.labelSmall),
        ),
        ElevatedButton(
          onPressed: _add,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.background,
          ),
          child: Text('ADD', style: AppTheme.labelSmall),
        ),
      ],
    );
  }
}
