class LegalContentModel {
  final String? slug;
  final String? bodyEn;
  final String? bodyAr;
  final String? updatedAt;

  const LegalContentModel({
    this.slug,
    this.bodyEn,
    this.bodyAr,
    this.updatedAt,
  });

  factory LegalContentModel.fromJson(Map<String, dynamic> json) {
    return LegalContentModel(
      slug: json['slug']?.toString(),
      bodyEn: json['body_en']?.toString(),
      bodyAr: json['body_ar']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  String bodyFor(String languageCode) {
    if (languageCode == 'ar' && bodyAr?.trim().isNotEmpty == true) {
      return bodyAr!;
    }

    if (bodyEn?.trim().isNotEmpty == true) return bodyEn!;

    return bodyAr ?? '';
  }
}
