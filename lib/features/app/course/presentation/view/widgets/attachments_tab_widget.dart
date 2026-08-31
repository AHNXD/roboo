import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/external_links.dart';
import 'package:roboo/core/utils/file_downloader.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/course/data/models/course_attachment_model.dart';
import 'package:roboo/features/app/course/presentation/view-model/attachments_cubit/attachments_cubit.dart';

class CourseAttachmentsTab extends StatelessWidget {
  final List<CourseAttachmentModel> attachments;

  const CourseAttachmentsTab({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return StatusDisplayWidget(
        message: "no_attachments_available".tr(context),
      );
    }

    return BlocProvider(
      create: (_) =>
          AttachmentsCubit(FileDownloader())..restoreExisting(attachments),
      child: _AttachmentsList(attachments: attachments),
    );
  }
}

class _AttachmentsList extends StatelessWidget {
  final List<CourseAttachmentModel> attachments;

  const _AttachmentsList({required this.attachments});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final links = attachments.where((item) => item.isLink).toList();
    final files = attachments.where((item) => !item.isLink).toList();

    return BlocConsumer<AttachmentsCubit, AttachmentsState>(
      listenWhen: (previous, current) =>
          previous.downloads != current.downloads,
      listener: (context, state) {
        for (final download in state.downloads.values) {
          final errorMsg = download.errorMsg;
          if (errorMsg != null) {
            messages(context, errorMsg.tr(context), AppColors.red);
            return;
          }
        }
      },
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (links.isNotEmpty) ...[
              _SectionTitle(text: "links".tr(context)),
              ...links.map(
                (item) =>
                    _LinkRow(attachment: item, languageCode: languageCode),
              ),
            ],
            if (links.isNotEmpty && files.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
            if (files.isNotEmpty) ...[
              _SectionTitle(text: "files".tr(context)),
              ...files.map(
                (item) => _FileRow(
                  attachment: item,
                  languageCode: languageCode,
                  download: state.downloadFor(item.id),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
    );
  }
}

/// A link opens in the browser. The address itself is not shown — the title is
/// what the student chose to read, and a raw storage url is noise.
class _LinkRow extends StatelessWidget {
  final CourseAttachmentModel attachment;
  final String languageCode;

  const _LinkRow({required this.attachment, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    final url = attachment.url;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        attachment.titleFor(languageCode),
        style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
      ),
      leading: const Icon(Icons.link, color: AppColors.primaryColors),
      trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
      onTap: url.isEmpty ? null : () => ExternalLinks.openUrl(context, url),
    );
  }
}

/// A file downloads to the device and then opens. Tapping again after that
/// opens the copy already downloaded rather than fetching it twice.
class _FileRow extends StatelessWidget {
  final CourseAttachmentModel attachment;
  final String languageCode;
  final AttachmentDownload download;

  const _FileRow({
    required this.attachment,
    required this.languageCode,
    required this.download,
  });

  @override
  Widget build(BuildContext context) {
    final isDownloading = download.status == AttachmentStatus.downloading;
    final isDownloaded = download.status == AttachmentStatus.downloaded;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(
        Icons.insert_drive_file_outlined,
        color: AppColors.primaryColors,
      ),
      title: Text(
        attachment.titleFor(languageCode),
        style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
      ),
      subtitle: isDownloading
          ? Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(
                value: download.progress,
                minHeight: 4,
                backgroundColor: Colors.grey.withValues(alpha: 0.25),
                color: AppColors.primaryColors,
              ),
            )
          : Text(
              isDownloaded
                  ? "attachment_downloaded".tr(context)
                  : "attachment_tap_to_download".tr(context),
              style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
            ),
      trailing: _buildTrailing(),
      onTap: isDownloading
          ? null
          : () => context.read<AttachmentsCubit>().downloadOrOpen(attachment),
    );
  }

  Widget _buildTrailing() {
    if (download.status == AttachmentStatus.downloading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: download.progress,
          color: AppColors.primaryColors,
        ),
      );
    }

    if (download.status == AttachmentStatus.downloaded) {
      return const Icon(Icons.folder_open, color: AppColors.green);
    }

    if (download.status == AttachmentStatus.failed) {
      return const Icon(Icons.refresh, color: AppColors.red);
    }

    return const Icon(Icons.download_rounded, color: AppColors.primaryColors);
  }
}
