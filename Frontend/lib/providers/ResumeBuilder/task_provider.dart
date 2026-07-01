import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ResumeBuilder/task_status.dart';
import '../../notifiers/ResumeBuilder/task_notifier.dart';

/// The primary provider for file upload & task polling.
///
/// Screens use this to trigger uploads and observe state transitions:
///   null → pending → processing → completed/failed
final taskNotifierProvider =
    AsyncNotifierProvider<TaskNotifier, TaskStatus?>(() {
  return TaskNotifier();
});
