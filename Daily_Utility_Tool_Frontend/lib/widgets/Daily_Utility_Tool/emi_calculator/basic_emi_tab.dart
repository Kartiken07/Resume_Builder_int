import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cards/Daily_Utility_Tool/emi_calculator/emi_breakdown_card.dart';
import '../../../cards/Daily_Utility_Tool/emi_calculator/emi_value_card.dart';
import '../../../models/Daily_Utility_Tool/emi_calculator_model.dart';
import '../../../providers/Daily_Utility_Tool/emi_calculator_provider.dart';
import '../../../theme/app_theme.dart';

class BasicEmiTab extends ConsumerStatefulWidget {
  const BasicEmiTab({super.key});

  @override
  ConsumerState<BasicEmiTab> createState() => _BasicEmiTabState();
}

class _BasicEmiTabState extends ConsumerState<BasicEmiTab> {
  final principalController = TextEditingController(text: "500000");
  final rateController = TextEditingController(text: "10");
  final timeController = TextEditingController(text: "24");

  @override
  void dispose() {
    principalController.dispose();
    rateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void _setControllerValue(TextEditingController controller, String text) {
    if (controller.text == text) return;
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String format(double value) => "₹${value.toStringAsFixed(0)}";

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emiCalculatorProvider);
    final notifier = ref.read(emiCalculatorProvider.notifier);

    _setControllerValue(principalController, state.principal.toInt().toString());
    _setControllerValue(rateController, state.rate.toStringAsFixed(1));
    _setControllerValue(timeController, state.time.toString());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),

            _buildDecorativeLine(),
            const SizedBox(height: 20),

            Text("EMI", style: AppTheme.headingLarge.copyWith(height: 1.0))
                .animate()
                .fade()
                .slideY(begin: -0.2),

            Text("Calculator", style: AppTheme.decorative.copyWith(height: 0.8))
                .animate()
                .fade(delay: 150.ms)
                .slideY(begin: -0.2),

            const SizedBox(height: 12),

            Text(
              "CALCULATE YOUR MONTHLY PAYMENT",
              style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
            ).animate().fade(delay: 300.ms),

            const SizedBox(height: 40),
            // Input card
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                boxShadow: AppTheme.shadowLarge,
                border: Border.all(color: AppTheme.borderLight, width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    "LOAN DETAILS",
                    style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
                  ),
                  const SizedBox(height: 24),

                  // Principal
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
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) notifier.updatePrincipal(parsed);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Rate
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
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) notifier.updateRate(parsed);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Time
                  TextField(
                    controller: timeController,
                    keyboardType: TextInputType.number,
                    style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Tenure (${state.unit == TimeUnit.months ? 'months' : 'years'})',
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
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null) notifier.updateTime(parsed);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Time Unit dropdown
                  DropdownButtonFormField<TimeUnit>(
                    value: state.unit,
                    dropdownColor: AppTheme.surface,
                    decoration: InputDecoration(
                      labelText: 'Time Unit',
                      labelStyle:
                          AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                    ),
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                    items: TimeUnit.values
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                  item == TimeUnit.months ? 'Months' : 'Years'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) notifier.updateUnit(value);
                    },
                  ),

                  const SizedBox(height: 12),

                  // Payment Frequency dropdown
                  DropdownButtonFormField<PaymentFrequency>(
                    value: state.paymentFrequency,
                    dropdownColor: AppTheme.surface,
                    decoration: InputDecoration(
                      labelText: 'Payment Frequency',
                      labelStyle:
                          AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.borderLight),
                      ),
                    ),
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                    items: PaymentFrequency.values
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) notifier.updatePaymentFrequency(value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Calculate button
                  SizedBox(
                    width: double.infinity,
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: state.isLoading ? null : notifier.calculateEmi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.background,
                        padding: AppTheme.buttonPadding,
                        disabledBackgroundColor: AppTheme.textTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.calculate_outlined, size: 18),
                      label: Text(
                        state.isLoading ? "CALCULATING..." : "CALCULATE EMI",
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.background,
                        ),
                      ),
                    ),
                  ),

                  // Error
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border:
                            Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fade().scale(),

            // Result card
            if (state.result != null) ...[
              const SizedBox(height: 24),
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  boxShadow: AppTheme.shadowLarge,
                  border: Border.all(color: AppTheme.borderLight, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      "RESULTS",
                      style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
                    ),
                    const SizedBox(height: 20),
                    EmiValueCard(
                      title: '${state.result!.paymentFrequency.label} EMI',
                      value: format(state.result!.emi),
                    ),
                    EmiValueCard(
                      title: 'Total Payment',
                      value: format(state.result!.totalPayment),
                    ),
                    EmiValueCard(
                      title: 'Total Interest',
                      value: format(state.result!.totalInterest),
                    ),
                    if (state.result!.totalPayment > 0) ...[
                      const SizedBox(height: 8),
                      EmiBreakdownCard(
                        principal: state.principal,
                        interest: state.result!.totalInterest,
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
