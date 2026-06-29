import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/Daily_Utility_Tool/emi_calculator/basic_emi_tab.dart';
import '../../widgets/Daily_Utility_Tool/emi_calculator/amortization_schedule_tab.dart';
import '../../widgets/Daily_Utility_Tool/emi_calculator/prepayment_analysis_tab.dart';
import '../../widgets/Daily_Utility_Tool/emi_calculator/reverse_calculation_tab.dart';
import '../../widgets/Daily_Utility_Tool/emi_calculator/loan_eligibility_tab.dart';
import '../../widgets/Daily_Utility_Tool/emi_calculator/loan_comparison_tab.dart';

class EmiCalculatorScreenNew extends ConsumerStatefulWidget {
  const EmiCalculatorScreenNew({super.key});

  @override
  ConsumerState<EmiCalculatorScreenNew> createState() =>
      _EmiCalculatorScreenNewState();
}

class _EmiCalculatorScreenNewState
    extends ConsumerState<EmiCalculatorScreenNew>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Curved background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: ClipPath(
              clipper: _CurveClipper(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.curvedBackgroundGradient,
                ),
              ),
            ),
          ),

          // Content with fixed tab bar
          Column(
            children: [
              // Fixed Tab Bar at top
              SafeArea(
                bottom: false,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.shadowMedium,
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primary,
                    indicatorWeight: 3,
                    labelStyle: AppTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                    unselectedLabelStyle: AppTheme.labelSmall,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'BASIC EMI'),
                      Tab(text: 'SCHEDULE'),
                      Tab(text: 'PREPAYMENT'),
                      Tab(text: 'REVERSE CALC'),
                      Tab(text: 'ELIGIBILITY'),
                      Tab(text: 'COMPARE'),
                    ],
                  ),
                ),
              ),

              // Scrollable Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const BasicEmiTab(),
                    const AmortizationScheduleTab(),
                    const PrepaymentAnalysisTab(),
                    const ReverseCalculationTab(),
                    const LoanEligibilityTab(),
                    const LoanComparisonTab(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Back button
          Positioned(
            top: 32,
            left: 32,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
              onPressed: () => context.go('/daily-utility-tool'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width / 2,
      -size.height * 0.1,
      size.width,
      size.height * 0.2,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
