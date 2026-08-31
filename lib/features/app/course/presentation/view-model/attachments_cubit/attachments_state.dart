part of 'attachments_cubit.dart';

enum AttachmentStatus { idle, downloading, downloaded, failed }

class AttachmentDownload extends Equatable {
  final AttachmentStatus status;

  /// 0..1, or null while the server has not said how big the file is.
  final double? progress;

  final String? filePath;
  final String? errorMsg;

  const AttachmentDownload({
    this.status = AttachmentStatus.idle,
    this.progress,
    this.filePath,
    this.errorMsg,
  });

  static const AttachmentDownload idle = AttachmentDownload();

  @override
  List<Object?> get props => [status, progress, filePath, errorMsg];
}

final class AttachmentsState extends Equatable {
  /// Keyed by attachment id.
  final Map<int, AttachmentDownload> downloads;

  const AttachmentsState({this.downloads = const {}});

  AttachmentDownload downloadFor(int? id) => id == null
      ? AttachmentDownload.idle
      : (downloads[id] ?? AttachmentDownload.idle);

  AttachmentsState copyWith({Map<int, AttachmentDownload>? downloads}) =>
      AttachmentsState(downloads: downloads ?? this.downloads);

  @override
  List<Object?> get props => [downloads];
}
