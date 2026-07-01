/// Represents the status of an asynchronous backend task.
///
/// Used for tracking file upload + processing jobs via polling.
class TaskStatus {
  const TaskStatus({
    required this.taskId,
    required this.status,
    this.downloadUrl,
    this.aiSummary,
    this.errorMessage,
    this.progress,
  });

  final String taskId;
  final TaskState status;
  final String? downloadUrl;
  final String? aiSummary;
  final String? errorMessage;
  final double? progress; // 0.0 to 1.0

  /// Whether the task is still running and requires further polling.
  bool get isPending =>
      status == TaskState.pending || status == TaskState.processing;

  /// Whether the task finished successfully.
  bool get isCompleted => status == TaskState.completed;

  /// Whether the task failed.
  bool get isFailed => status == TaskState.failed;

  TaskStatus copyWith({
    String? taskId,
    TaskState? status,
    String? downloadUrl,
    String? aiSummary,
    String? errorMessage,
    double? progress,
  }) {
    return TaskStatus(
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      aiSummary: aiSummary ?? this.aiSummary,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  factory TaskStatus.pending(String taskId) {
    return TaskStatus(taskId: taskId, status: TaskState.pending);
  }

  /// Deserialize from backend JSON response.
  ///
  /// Expected keys: `task_id`, `status`, `progress`, `download_url`,
  /// `ai_summary`, `error_message`.
  factory TaskStatus.fromJson(Map<String, dynamic> json) {
    return TaskStatus(
      taskId: json['task_id'] as String,
      status: TaskState.values.byName(json['status'] as String),
      progress: (json['progress'] as num?)?.toDouble(),
      downloadUrl: json['download_url'] as String?,
      aiSummary: json['ai_summary'] as String?,
      errorMessage: json['error_message'] as String?,
    );
  }

  /// Serialize to JSON for debugging or local caching.
  Map<String, dynamic> toJson() => {
        'task_id': taskId,
        'status': status.name,
        'progress': progress,
        'download_url': downloadUrl,
        'ai_summary': aiSummary,
        'error_message': errorMessage,
      };
}

/// The possible states of a backend processing task.
enum TaskState {
  pending,
  processing,
  completed,
  failed,
}
