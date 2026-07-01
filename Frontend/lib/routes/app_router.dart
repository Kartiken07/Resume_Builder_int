import 'package:go_router/go_router.dart';

import '../screens/main_home_screen.dart';
import 'Daily_Utility_Tool/app_router.dart';
import 'Minima/app_router.dart';
import 'FileSharing/app_router.dart';

/// Top-level router for the multi-project hub.
///
/// Each project registers its own routes in its own folder:
///   lib/routes/<ProjectName>/app_router.dart  →  exports a List<RouteBase>
///
/// Add new project route lists by spreading them into [routes] below.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // ── Main Hub ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'main-home',
        builder: (context, state) => const MainHomeScreen(),
      ),

      // ── Projects ──────────────────────────────────────────────────────────
      ...dailyUtilityToolRoutes,
      ...minimaRoutes,
      ...fileSharingRoutes,

      // Add future project routes here:
      // ...anotherProjectRoutes,
    ],
  );
}
