import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/Daily_Utility_Tool/emi_calculator_model.dart';
import '../../../providers/Daily_Utility_Tool/emi_calculator_provider.dart';
import '../../../theme/app_theme.dart';

class AmortizationScheduleTab extends ConsumerStatefulWidget {
  const AmortizationScheduleTab({super.key});

  @override
  ConsumerState<AmortizationScheduleTab> createState() =>
      _AmortizationScheduleTabState();
}

class _AmortizationScheduleTabState
    extends ConsumerState<AmortizationScheduleTab> {
  // Local state for this tab's inputs
  final principalController = TextEditingController(text: "500000");
  final rateController = TextEditingController(text: "10");
  final timeController = TextEditingController(text: "24");
  
  double _principal = 500000;
  double _rate = 10;
  int _time = 24;
  TimeUnit _unit = TimeUnit.months;
  PaymentFrequency _paymentFrequency = PaymentFrequency.monthly;
  
  bool _isLoading = false;
  String? _errorMessage;
  AmortizationScheduleResponse? _schedule;
  bool _summaryByYear = false;

  @override
  void dispose() {
    principalController.dispose();
    rateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> _generateSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(emiConverterServicesProvider);
      final request = AmortizationScheduleRequest(
        principal: _principal,
        rate: _rate,
        time: _time,
        unit: _unit,
        paymentFrequency: _paymentFrequency,
        summaryByYear: _summaryByYear,
      );

      final response = await service.amortizationSchedule(request);

      setState(() {
        _schedule = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate schedule. Please try again.';
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

            Text("AMORTIZATION", style: AppTheme.headingLarge.copyWith(height: 1.0))
                .animate()
                .fade()
                .slideY(begin: -0.2),

            Text("Schedule", style: AppTheme.decorative.copyWith(height: 0.8))
                .animate()
                .fade(delay: 150.ms)
                .slideY(begin: -0.2),

            const SizedBox(height: 12),

            Text(
              "MONTH-BY-MONTH BREAKDOWN",
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
                      labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.primary, width: 2),
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
                      labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.primary, width: 2),
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
                      labelText: 'Tenure (${_unit == TimeUnit.months ? 'months' : 'years'})',
                      labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.primary, width: 2),
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
                            labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                            filled: true,
                            fillColor: AppTheme.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide: BorderSide(color: AppTheme.borderLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide: BorderSide(color: AppTheme.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide: BorderSide(color: AppTheme.primary, width: 2),
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<PaymentFrequency>(
                          value: _paymentFrequency,
                          dropdownColor: AppTheme.surface,
                          style: AppTheme.bodyMedium,
                          decoration: InputDecoration(
                            labelText: 'Payment Frequency',
                            labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                            filled: true,
                            fillColor: AppTheme.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide: BorderSide(color: AppTheme.borderLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide: BorderSide(color: AppTheme.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide: BorderSide(color: AppTheme.primary, width: 2),
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

                  const SizedBox(height: 20),

                  // Summary by Year toggle
                  Row(
                    children: [
                      Checkbox(
                        value: _summaryByYear,
                        onChanged: (value) {
                          setState(() {
                            _summaryByYear = value ?? false;
                            _schedule = null;
                          });
                        },
                      ),
                      Text(
                        'Group by Year',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.background,
                        padding: AppTheme.buttonPadding,
                        disabledBackgroundColor: AppTheme.textTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.table_chart, size: 18),
                      label: Text(
                        _isLoading ? "GENERATING..." : "GENERATE SCHEDULE",
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
                        border:
                            Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
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

            // Schedule Table
            if (_schedule != null) ...[
              const SizedBox(height: 24),

              // Summary Card
              Container(
                constraints: const BoxConstraints(maxWidth: 900),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.shadowMedium,
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUMMARY',
                      style: AppTheme.labelMedium.copyWith(letterSpacing: 2),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Total EMI Paid',
                            format(_schedule!.summary.totalEmiPaid),
                            Icons.payments,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Principal',
                            format(_schedule!.summary.totalPrincipalPaid),
                            Icons.account_balance_wallet,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Interest',
                            format(_schedule!.summary.totalInterestPaid),
                            Icons.trending_up,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            'Final Balance',
                            format(_schedule!.summary.finalBalance),
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // Schedule Table
              Container(
                constraints: const BoxConstraints(maxWidth: 900),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.shadowMedium,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppTheme.primary.withValues(alpha: 0.1),
                    ),
                    columns: [
                      DataColumn(
                        label: Text('Period',
                            style: AppTheme.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      DataColumn(
                        label: Text('Payment',
                            style: AppTheme.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Principal',
                            style: AppTheme.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Interest',
                            style: AppTheme.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Balance',
                            style: AppTheme.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        numeric: true,
                      ),
                    ],
                    rows: _schedule!.schedule.map((row) {
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            '${row.period}',
                            style: AppTheme.bodySmall,
                          )),
                          DataCell(Text(
                            format(row.payment),
                            style: AppTheme.bodySmall,
                          )),
                          DataCell(Text(
                            format(row.principalPortion),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primary,
                            ),
                          )),
                          DataCell(Text(
                            format(row.interestPortion),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.secondary,
                            ),
                          )),
                          DataCell(Text(
                            format(row.remainingBalance),
                            style: AppTheme.bodySmall,
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
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

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
