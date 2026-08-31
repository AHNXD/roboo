/// Contact details the admin dashboard owns, so a number or a link can change
/// without an app release. Every field is nullable — the dashboard may not have
/// filled it in yet — and a control whose value is missing stays hidden rather
/// than opening a broken chat.
class AppSettingsModel {
  final String? whatsAppNumber;
  final String? facebookUrl;
  final String? instagramUrl;

  const AppSettingsModel({
    this.whatsAppNumber,
    this.facebookUrl,
    this.instagramUrl,
  });

  static const AppSettingsModel empty = AppSettingsModel();

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      whatsAppNumber: _clean(json['whatsapp_number']),
      facebookUrl: _clean(json['facebook_url']),
      instagramUrl: _clean(json['instagram_url']),
    );
  }

  bool get hasWhatsApp => whatsAppNumber != null;
  bool get hasFacebook => facebookUrl != null;
  bool get hasInstagram => instagramUrl != null;

  /// Treats an empty string the same as a missing value: both mean "not set".
  static String? _clean(dynamic value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty || text == 'null') ? null : text;
  }
}
