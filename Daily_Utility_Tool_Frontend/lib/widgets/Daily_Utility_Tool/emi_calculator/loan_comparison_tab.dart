import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/Daily_Utility_Tool/emi_calculator_model.dart';
import '../../../providers/Daily_Utility_Tool/emi_calculator_provider.dart';
import '../../../theme/app_theme.dart';

class LoanComparisonTab extends ConsumerStatefulWidget {
  const LoanComparisonTab({super.key});

  @override
  ConsumerState<LoanComparisonTab> createState() =>
      _LoanComparisonTabState();
}

class _LoanComparisonTabState extends ConsumerState<LoanComparisonTab> {
  final List<LoanComparisonItem> _loans = [];

  bool _isLoading = false;
  String? _errorMessage;
  LoanComparisonResponse? _result;

  Future<void> _compareLoans() async {
    if (_loans.length < 2) {
      setState(() {
        _errorMessage = 'Please add at least 2 loans to compare';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(emiConverterServicesProvider);
      final request = LoanComparisonRequest(loans: _loans);

      final response = await service.compareLoans(request);

      setState(() {
        _result = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to compare loans. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _addLoan() {
    showDialog(
      context: context,
      builder: (context) => _AddLoanDialog(
        onAdd: (loan) {
          setState(() {
            _loans.add(loan);
            _result = null; // Clear previous comparison
          });
        },
      ),
    );
  }

  void _removeLoan(int index) {
    setState(() {
      _loans.removeAt(index);
      _result = null;
    });
  }

  String format(double value) => "₹${value.toStringAsFixed(0)}";

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.star;
      case 3:
        return Icons.star_half;
      default:
        return Icons.circle;
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

            Text("LOAN", style: AppTheme.headingLarge.copyWith(height: 1.0))
                .animate()
                .fade()
                .slideY(begin: -0.2),

            Text("Comparison",
                    style: AppTheme.decorative.copyWith(height: 0.8))
                .animate()
                .fade(delay: 150.ms)
                .slideY(begin: -0.2),

            const SizedBox(height: 12),

            Text(
              "SIDE-BY-SIDE COMPARISON",
              style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
            ).animate().fade(delay: 300.ms),

            const SizedBox(height: 40),

            // Loans List Card
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.shadowMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "LOAN OPTIONS",
                        style: AppTheme.labelMedium.copyWith(letterSpacing: 4),
                      ),
                      TextButton.icon(
                        onPressed: _addLoan,
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: Text(
                          'ADD LOAN',
                          style: AppTheme.labelSmall,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (_loans.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
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
                        child: Column(
                          children: [
                            Icon(Icons.compare_arrows,
                                size: 48, color: AppTheme.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              'No loans added yet',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add at least 2 loans to compare',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...List.generate(_loans.length, (index) {
                      final loan = _loans[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Loan ${index + 1}',
                                    style: AppTheme.labelSmall.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: AppTheme.error, size: 20),
                                  onPressed: () => _removeLoan(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLoanDetail(
                                    'Amount',
                                    format(loan.principal),
                                  ),
                                ),
                                Expanded(
                                  child: _buildLoanDetail(
                                    'Rate',
                                    '${loan.rate}%',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLoanDetail(
                                    'Tenure',
                                    '${loan.tenureMonths} months',
                                  ),
                                ),
                                Expanded(
                                  child: _buildLoanDetail(
                                    'Frequency',
                                    loan.paymentFrequency.label,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 16),

                  // Compare Button
                  SizedBox(
                    width: double.infinity,
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _compareLoans,
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
                          : const Icon(Icons.compare_arrows, size: 18),
                      label: Text(
                        _isLoading ? "COMPARING..." : "COMPARE LOANS",
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

            // Comparison Results
            if (_result != null) ...[
              const SizedBox(height: 24),

              // Best Deal Banner
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.shadowMedium,
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BEST DEAL',
                            style: AppTheme.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Loan ${_result!.loans.first.rank} - Lowest Total Cost',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).scale(),

              const SizedBox(height: 16),

              // Comparison Cards
              ...List.generate(_result!.loans.length, (index) {
                final loan = _result!.loans[index];
                final rankColor = _getRankColor(loan.rank);
                final rankIcon = _getRankIcon(loan.rank);

                return Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: AppTheme.shadowMedium,
                    border: Border.all(
                      color: loan.rank == 1
                          ? Colors.green.withValues(alpha: 0.5)
                          : AppTheme.borderLight,
                      width: loan.rank == 1 ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Rank
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: rankColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(rankIcon, color: rankColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Loan ${loan.rank}',
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  loan.rank == 1
                                      ? 'Most Affordable'
                                      : 'Rank #${loan.rank}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: rankColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (loan.rank == 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'BEST',
                                style: AppTheme.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const Divider(height: 24),

                      // Loan Details
                      Row(
                        children: [
                          Expanded(
                            child: _buildComparisonDetail(
                              'Principal',
                              format(loan.principal),
                              Icons.account_balance_wallet,
                            ),
                          ),
                          Expanded(
                            child: _buildComparisonDetail(
                              'Rate',
                              '${loan.rate.toStringAsFixed(2)}%',
                              Icons.percent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildComparisonDetail(
                              'Tenure',
                              '${loan.tenureMonths} months',
                              Icons.calendar_today,
                            ),
                          ),
                          Expanded(
                            child: _buildComparisonDetail(
                              'EMI',
                              format(loan.emi),
                              Icons.payment,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24),

                      // Cost Summary
                      _buildCostRow(
                        'Total Interest',
                        format(loan.totalInterest),
                        Icons.trending_up,
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildCostRow(
                        'Total Payment',
                        format(loan.totalPayment),
                        Icons.account_balance,
                        AppTheme.primary,
                      ),

                      if (loan.costDifferenceFromCheapest > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${format(loan.costDifferenceFromCheapest)} more than cheapest option',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildLoanDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textTertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
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
            color: color,
          ),
        ),
      ],
    );
  }
}

// Dialog to add loan
class _AddLoanDialog extends StatefulWidget {
  final Function(LoanComparisonItem) onAdd;

  const _AddLoanDialog({required this.onAdd});

  @override
  State<_AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends State<_AddLoanDialog> {
  final principalController = TextEditingController();
  final rateController = TextEditingController();
  final tenureController = TextEditingController();
  PaymentFrequency _paymentFrequency = PaymentFrequency.monthly;

  @override
  void dispose() {
    principalController.dispose();
    rateController.dispose();
    tenureController.dispose();
    super.dispose();
  }

  void _add() {
    final principal = double.tryParse(principalController.text);
    final rate = double.tryParse(rateController.text);
    final tenure = int.tryParse(tenureController.text);

    if (principal == null || principal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid loan amount')),
      );
      return;
    }

    if (rate == null || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid interest rate')),
      );
      return;
    }

    if (tenure == null || tenure <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid tenure')),
      );
      return;
    }

    widget.onAdd(LoanComparisonItem(
      principal: principal,
      rate: rate,
      tenureMonths: tenure,
      paymentFrequency: _paymentFrequency,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      title: Text('Add Loan Option', style: AppTheme.headingSmall),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tenureController,
              keyboardType: TextInputType.number,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Tenure (months)',
                labelStyle:
                    AppTheme.bodySmall.copyWith(color: AppTheme.secondary),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
