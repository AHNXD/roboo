class CoursePlaceModel {
  final int? id;
  final String? name;
  final String? nameAr;
  final String? city;
  final String? cityAr;
  final String? latitude;
  final String? longitude;

  const CoursePlaceModel({
    this.id,
    this.name,
    this.nameAr,
    this.city,
    this.cityAr,
    this.latitude,
    this.longitude,
  });

  factory CoursePlaceModel.fromJson(Map<String, dynamic> json) {
    return CoursePlaceModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      city: json['city']?.toString(),
      cityAr: json['city_ar']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  String nameFor(String languageCode) => _localized(languageCode, name, nameAr);

  String cityFor(String languageCode) => _localized(languageCode, city, cityAr);

  /// "Name - City", skipping whichever half the backend left empty.
  String labelFor(String languageCode) {
    final placeName = nameFor(languageCode);
    final placeCity = cityFor(languageCode);
    if (placeName.isEmpty) return placeCity;
    if (placeCity.isEmpty) return placeName;
    return '$placeName - $placeCity';
  }

  static String _localized(
    String languageCode,
    String? value,
    String? valueAr,
  ) {
    if (languageCode == 'ar' && valueAr?.isNotEmpty == true) return valueAr!;
    return value?.isNotEmpty == true ? value! : valueAr ?? '';
  }
}
