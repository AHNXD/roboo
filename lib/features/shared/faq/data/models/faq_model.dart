class FaqModel {
  final int? id;
  final String? title;
  final String? titleAr;
  final String? description;
  final String? descriptionAr;
  final String? createdAt;
  final String? updatedAt;

  const FaqModel({
    this.id,
    this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    this.createdAt,
    this.updatedAt,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      title: json['title']?.toString(),
      titleAr: json['title_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  String titleFor(String languageCode) {
    if (languageCode == 'ar' && titleAr?.isNotEmpty == true) {
      return titleAr!;
    }
    return title?.isNotEmpty == true ? title! : titleAr ?? '';
  }

  String descriptionFor(String languageCode) {
    if (languageCode == 'ar' && descriptionAr?.isNotEmpty == true) {
      return descriptionAr!;
    }
    return description?.isNotEmpty == true ? description! : descriptionAr ?? '';
  }
}
