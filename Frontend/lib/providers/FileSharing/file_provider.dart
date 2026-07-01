import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../api_services/FileSharing/api_service.dart';

const int minLinkExpiryMinutes = 10;
const int maxLinkExpiryMinutes = 60;
const int defaultLinkExpiryMinutes = 30;

// ── State ─────────────────────────────────────────────────────────────────────

class FileSharingState {
  final PlatformFile? file;
  final bool loading;
  final String? link;
  final int expiryMinutes;
  final String? errorMessage;

  const FileSharingState({
    this.file,
    this.loading = false,
    this.link,
    this.expiryMinutes = defaultLinkExpiryMinutes,
    this.errorMessage,
  });

  FileSharingState copyWith({
    PlatformFile? file,
    bool? loading,
    String? link,
    int? expiryMinutes,
    String? errorMessage,
    bool clearLink = false,
    bool clearError = false,
  }) {
    return FileSharingState(
      file: file ?? this.file,
      loading: loading ?? this.loading,
      link: clearLink ? null : (link ?? this.link),
      expiryMinutes: expiryMinutes ?? this.expiryMinutes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class FileSharingNotifier extends StateNotifier<FileSharingState> {
  FileSharingNotifier() : super(const FileSharingState());

  final _api = FileSharingApiService();

  void setFile(PlatformFile newFile) {
    state = state.copyWith(file: newFile, clearLink: true, clearError: true);
  }

  void setExpiryMinutes(int minutes) {
    final bounded = minutes.clamp(minLinkExpiryMinutes, maxLinkExpiryMinutes);
    if (bounded == state.expiryMinutes) return;
    state = state.copyWith(expiryMinutes: bounded, clearLink: true);
  }

  Future<void> upload() async {
    if (state.file == null) return;

    state = state.copyWith(loading: true, clearLink: true, clearError: true);

    try {
      final link = await _api.uploadFile(
        path: kIsWeb ? null : state.file!.path,
        bytes: state.file!.bytes,
        filename: state.file!.name,
        expiryMinutes: state.expiryMinutes,
      );
      state = state.copyWith(loading: false, link: link);
    } on Exception catch (e) {
      final raw = e.toString();
      final msg = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
      state = state.copyWith(loading: false, errorMessage: msg);
      debugPrint('FileSharing upload failed: $e');
    } catch (e) {
      state = state.copyWith(
          loading: false, errorMessage: 'Unexpected error: $e');
      debugPrint('FileSharing upload failed (unknown): $e');
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final fileSharingProvider =
    StateNotifierProvider<FileSharingNotifier, FileSharingState>(
  (ref) => FileSharingNotifier(),
);
