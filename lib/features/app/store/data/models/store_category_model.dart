class StoreCategoryModel {
  final int? id;
  final String? name;
  final String? nameAr;
  final String? createdAt;
  final String? updatedAt;

  const StoreCategoryModel({
    this.id,
    this.name,
    this.nameAr,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreCategoryModel.fromJson(Map<String, dynamic> json) {
    return StoreCategoryModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  String nameFor(String languageCode) {
    if (languageCode == 'ar' && nameAr?.isNotEmpty == true) {
      return nameAr!;
    }
    return name?.isNotEmpty == true ? name! : nameAr ?? '';
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
