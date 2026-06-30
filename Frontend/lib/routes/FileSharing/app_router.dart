import 'package:go_router/go_router.dart';

import '../../screens/FileSharing/upload_screen.dart';
import 'app_pages.dart';

/// All routes for the File Sharing project.
/// Consumed by the top-level AppRouter via spread: [...fileSharingRoutes]
final List<RouteBase> fileSharingRoutes = [
  GoRoute(
    path: FileSharingRoutes.home,
    name: 'file-sharing-home',
    builder: (context, state) => const FileSharingUploadScreen(),
  ),
];
