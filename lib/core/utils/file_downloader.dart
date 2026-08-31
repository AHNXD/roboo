import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../errors/error_handler.dart';
import '../errors/failuer.dart';

/// Downloads a course attachment and keeps it on the device.
///
/// Uses its own `Dio` rather than `ApiServices`: attachment files are public
/// static storage, and routing them through the shared client would attach the
/// auth interceptor — a 401 from the file host would then bounce the student
/// out to the login screen over a failed download.
class FileDownloader {
  final Dio _dio;

  FileDownloader({Dio? dio}) : _dio = dio ?? Dio();

  /// Downloads live in the app's documents directory, so neither platform needs
  /// a storage permission.
  static const String _folderName = 'attachments';

  Future<Directory> _downloadsDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory('${base.path}/$_folderName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// The already-downloaded file for [url], or null if it is not on the device.
  Future<File?> existingFile(String url) async {
    try {
      final directory = await _downloadsDirectory();
      final file = File('${directory.path}/${fileNameFor(url)}');
      return await file.exists() ? file : null;
    } catch (_) {
      return null;
    }
  }

  Future<Either<Failure, File>> download({
    required String url,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final directory = await _downloadsDirectory();
      final target = '${directory.path}/${fileNameFor(url)}';

      // Written to a `.part` file and renamed only once complete, so an
      // interrupted download never leaves something that looks finished.
      final partialPath = '$target.part';

      await _dio.download(
        url,
        partialPath,
        onReceiveProgress: onProgress,
        deleteOnError: true,
      );

      final file = await File(partialPath).rename(target);
      return right(file);
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  /// Derives a filename from the url path — the server sends no
  /// `content-disposition`. Anything unusable falls back to a generic name.
  static String fileNameFor(String url) {
    // `pathSegments` is percent-decoded, unlike `path` — otherwise a space in
    // the name arrives as `%20` and gets mangled into `_20` by the sanitiser.
    final segments = (Uri.tryParse(url)?.pathSegments ?? const <String>[])
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (segments.isEmpty) return 'attachment';

    // Strips only what a filesystem cannot take. An allow-list of ASCII would
    // reduce an Arabic filename to underscores, and the titles here are often
    // Arabic.
    final name = segments.last
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
        .trim();
    return name.isEmpty ? 'attachment' : name;
  }
}
