class TopicModel {
  final int? id;
  final String? name;
  final String? nameAr;

  const TopicModel({this.id, this.name, this.nameAr});

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
    );
  }

  String nameFor(String languageCode) {
    if (languageCode == 'ar' && nameAr?.isNotEmpty == true) {
      return nameAr!;
    }

    return name?.isNotEmpty == true ? name! : nameAr ?? '';
  }
}
