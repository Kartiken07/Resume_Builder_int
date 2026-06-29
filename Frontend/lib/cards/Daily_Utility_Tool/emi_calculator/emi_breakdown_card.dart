import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class EmiBreakdownCard extends StatelessWidget {
  const EmiBreakdownCard({
    required this.principal,
    required this.interest,
    super.key,
  });

  final double principal;
  final double interest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.cardPaddingH),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Text('PAYMENT BREAKDOWN', style: AppTheme.breakdownLabel),
          const SizedBox(height: AppTheme.spacingLarge),
          SizedBox(
            height: AppTheme.chartHeight,
            child: PieChart(
              PieChartData(
                sectionsSpace: AppTheme.chartSectionsSpace,
                centerSpaceRadius: AppTheme.chartCenterRadius,
                sections: [
                  PieChartSectionData(
                    value: principal,
                    color: AppTheme.chartPrincipal,
                    title: 'Principal',
                    titleStyle: AppTheme.labelSmall.copyWith(color: AppTheme.background),
                    radius: AppTheme.chartRadius,
                  ),
                  PieChartSectionData(
                    value: interest,
                    color: AppTheme.chartInterest,
                    title: 'Interest',
                    titleStyle: AppTheme.labelSmall.copyWith(color: AppTheme.primaryLight),
                    radius: AppTheme.chartRadius,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(AppTheme.chartPrincipal, 'Principal'),
              const SizedBox(width: AppTheme.legendSpacing),
              _legend(AppTheme.chartInterest, 'Interest'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppTheme.legendDotSize,
          height: AppTheme.legendDotSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppTheme.spacingSmall - 2),
        Text(label, style: AppTheme.breakdownLegend),
      ],
    );
  }
}
