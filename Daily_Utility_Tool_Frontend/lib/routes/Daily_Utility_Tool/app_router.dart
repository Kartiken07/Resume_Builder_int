import 'package:go_router/go_router.dart';

import '../../screens/Daily_Utility_Tool/age_calculator_screen.dart';
import '../../screens/Daily_Utility_Tool/dashboard_screen.dart';
import '../../screens/Daily_Utility_Tool/barcode_generator_screen.dart';
import '../../screens/Daily_Utility_Tool/emi_calculator_screen_new.dart';
import '../../screens/Daily_Utility_Tool/qr_generator_screen.dart';
import '../../screens/Daily_Utility_Tool/unit_converter_screen.dart';
import '../../widgets/Daily_Utility_Tool/app_shell.dart';
import 'app_pages.dart';

/// All routes for the Daily Utility Tool project.
/// Consumed by the top-level AppRouter via spread: [...dailyUtilityToolRoutes]
final List<RouteBase> dailyUtilityToolRoutes = [
  ShellRoute(
    builder: (context, state, child) => AppShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dut-dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.qrGenerator,
        name: 'qr-generator',
        builder: (context, state) => const QrGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.barcodeGenerator,
        name: 'barcode-generator',
        builder: (context, state) => const BarcodeGeneratorScreen(),
      ),
      GoRoute(
        path: AppRoutes.unitConverter,
        name: 'unit-converter',
        builder: (context, state) => const UnitConverterScreen(),
      ),
      GoRoute(
        path: AppRoutes.ageCalculator,
        name: 'age-calculator',
        builder: (context, state) => const AgeCalculatorScreen(),
      ),
      GoRoute(
        path: AppRoutes.emiCalculator,
        name: 'emi-calculator',
        builder: (context, state) => const EmiCalculatorScreenNew(),
      ),
    ],
  ),
];
