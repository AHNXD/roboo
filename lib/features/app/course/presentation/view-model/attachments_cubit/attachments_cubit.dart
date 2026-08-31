import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../../../core/utils/file_downloader.dart';
import '../../../../../../core/utils/safe_emit.dart';
import '../../../data/models/course_attachment_model.dart';

part 'attachments_state.dart';

/// Owns downloading course attachments and handing them to the system viewer.
class AttachmentsCubit extends Cubit<AttachmentsState>
    with SafeEmit<AttachmentsState> {
  final FileDownloader _downloader;

  AttachmentsCubit(this._downloader) : super(const AttachmentsState());

  /// Marks anything already on the device as downloaded, so re-opening the tab
  /// offers "open" rather than downloading the same file again.
  Future<void> restoreExisting(List<CourseAttachmentModel> attachments) async {
    final restored = <int, AttachmentDownload>{};

    for (final attachment in attachments) {
      final id = attachment.id;
      if (id == null || attachment.isLink || attachment.url.isEmpty) continue;

      final file = await _downloader.existingFile(attachment.url);
      if (file == null) continue;

      restored[id] = AttachmentDownload(
        status: AttachmentStatus.downloaded,
        progress: 1,
        filePath: file.path,
      );
    }

    if (restored.isEmpty) return;
    safeEmit(state.copyWith(downloads: {...state.downloads, ...restored}));
  }

  Future<void> downloadOrOpen(CourseAttachmentModel attachment) async {
    final id = attachment.id;
    final url = attachment.url;
    if (id == null || url.isEmpty) return;

    final current = state.downloadFor(id);
    if (current.status == AttachmentStatus.downloading) return;

    if (current.status == AttachmentStatus.downloaded &&
        current.filePath != null) {
      await _open(id, current.filePath!);
      return;
    }

    _set(id, const AttachmentDownload(status: AttachmentStatus.downloading));

    final result = await _downloader.download(
      url: url,
      onProgress: (received, total) {
        // `total` is -1 when the server sends no content-length; the bar then
        // runs indeterminate rather than showing a wrong percentage.
        _set(
          id,
          AttachmentDownload(
            status: AttachmentStatus.downloading,
            progress: total > 0 ? received / total : null,
          ),
        );
      },
    );

    await result.fold(
      (failure) async => _set(
        id,
        AttachmentDownload(
          status: AttachmentStatus.failed,
          errorMsg: failure.message,
        ),
      ),
      (file) async {
        _set(
          id,
          AttachmentDownload(
            status: AttachmentStatus.downloaded,
            progress: 1,
            filePath: file.path,
          ),
        );
        // Opening straight away is the point of tapping download.
        await _open(id, file.path);
      },
    );
  }

  Future<void> _open(int id, String path) async {
    final result = await OpenFilex.open(path);
    if (result.type == ResultType.done) return;

    // The file is on the device either way, so this reports that nothing can
    // open it rather than that the download failed.
    _set(
      id,
      AttachmentDownload(
        status: AttachmentStatus.downloaded,
        progress: 1,
        filePath: path,
        errorMsg: 'attachment_open_failed',
      ),
    );
  }

  void _set(int id, AttachmentDownload download) {
    safeEmit(state.copyWith(downloads: {...state.downloads, id: download}));
  }
}
