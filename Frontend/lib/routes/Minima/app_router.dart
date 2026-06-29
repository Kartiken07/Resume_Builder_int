import 'package:go_router/go_router.dart';

import '../../screens/Minima/landing_screen.dart';
import '../../screens/Minima/dashboard_screen.dart';
import '../../screens/Minima/login_screen.dart';
import 'app_pages.dart';

/// All routes for the Minima (URL Shortener) project.
/// Consumed by the top-level AppRouter via spread: [...minimaRoutes]
final List<RouteBase> minimaRoutes = [
  GoRoute(
    path: MinimaRoutes.home,
    name: 'minima-home',
    builder: (context, state) => const LandingScreen(),
  ),
  GoRoute(
    path: MinimaRoutes.dashboard,
    name: 'minima-dashboard',
    builder: (context, state) => const DashboardScreen(),
  ),
  GoRoute(
    path: MinimaRoutes.login,
    name: 'minima-login',
    builder: (context, state) => const LoginScreen(),
  ),
];
