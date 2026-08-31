import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_localizations.dart';
import 'colors.dart';
import 'functions.dart';

/// Every outbound link the app opens. Kept in one place so a failure to launch
/// is always reported the same way instead of failing silently — on a device
/// with no browser, no WhatsApp or no maps app, `launchUrl` simply returns
/// false, and a button that does nothing reads as a broken app.
class ExternalLinks {
  const ExternalLinks._();

  /// Opens any absolute http(s) url. Returns false if it could not be opened.
  static Future<bool> openUrl(BuildContext context, String? rawUrl) async {
    final url = rawUrl?.trim();
    if (url == null || url.isEmpty) {
      _report(context, "link_unavailable");
      return false;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      _report(context, "link_unavailable");
      return false;
    }

    return _launch(context, uri, LaunchMode.externalApplication);
  }

  /// Opens a WhatsApp chat. `phone` may be written with spaces, dashes or a
  /// leading `+`; wa.me wants digits only.
  static Future<bool> openWhatsApp(
    BuildContext context, {
    required String phone,
    String? message,
  }) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _report(context, "link_unavailable");
      return false;
    }

    final uri = Uri.https('wa.me', '/$digits', {
      if (message != null && message.trim().isNotEmpty) 'text': message,
    });

    return _launch(context, uri, LaunchMode.externalApplication);
  }

  /// Opens a coordinate in whatever map app the device has. `geo:` is the
  /// Android intent; iOS has no handler for it, so both platforms fall back to
  /// a Google Maps web url, which Maps itself claims when installed.
  static Future<bool> openMap(
    BuildContext context, {
    required String? latitude,
    required String? longitude,
    String? label,
  }) async {
    final lat = double.tryParse(latitude?.trim() ?? '');
    final lng = double.tryParse(longitude?.trim() ?? '');
    if (lat == null || lng == null) {
      _report(context, "location_unavailable");
      return false;
    }

    final webUri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$lat,$lng',
    });

    final canOpenWeb = await canLaunchUrl(webUri);
    if (!context.mounted) return false;

    if (canOpenWeb) {
      return _launch(context, webUri, LaunchMode.externalApplication);
    }

    final geoUri = Uri.parse(
      'geo:$lat,$lng?q=$lat,$lng'
      '${label != null && label.isNotEmpty ? '(${Uri.encodeComponent(label)})' : ''}',
    );
    return _launch(context, geoUri, LaunchMode.externalApplication);
  }

  static Future<bool> _launch(
    BuildContext context,
    Uri uri,
    LaunchMode mode,
  ) async {
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: mode);
    } catch (_) {
      launched = false;
    }

    if (!launched && context.mounted) _report(context, "link_open_failed");
    return launched;
  }

  static void _report(BuildContext context, String messageKey) {
    if (!context.mounted) return;
    messages(context, messageKey.tr(context), AppColors.red);
  }
}
