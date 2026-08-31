/// `GET enrollment`. A student who has not redeemed a coupon comes back with
/// `is_enrolled: false` and every relation null.
class EnrollmentModel {
  final bool isEnrolled;
  final SchoolModel? school;
  final SchoolClassModel? schoolClass;
  final SectionModel? section;

  const EnrollmentModel({
    required this.isEnrolled,
    this.school,
    this.schoolClass,
    this.section,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    final school = json['school'];
    final schoolClass = json['school_class'];
    final section = json['section'];

    return EnrollmentModel(
      isEnrolled: json['is_enrolled'] == true,
      school: school is Map<String, dynamic>
          ? SchoolModel.fromJson(school)
          : null,
      schoolClass: schoolClass is Map<String, dynamic>
          ? SchoolClassModel.fromJson(schoolClass)
          : null,
      section: section is Map<String, dynamic>
          ? SectionModel.fromJson(section)
          : null,
    );
  }
}

class SchoolModel {
  final int? id;
  final String? name;
  final String? nameAr;
  final String? address;
  final String? phone;

  const SchoolModel({
    this.id,
    this.name,
    this.nameAr,
    this.address,
    this.phone,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: localizedInt(json['id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  String nameFor(String languageCode) =>
      localizedText(languageCode, name, nameAr);
}

class SchoolClassModel {
  final int? id;
  final String? name;
  final String? nameAr;
  final int? gradeLevel;

  const SchoolClassModel({this.id, this.name, this.nameAr, this.gradeLevel});

  factory SchoolClassModel.fromJson(Map<String, dynamic> json) {
    return SchoolClassModel(
      id: localizedInt(json['id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      gradeLevel: localizedInt(json['grade_level']),
    );
  }

  String nameFor(String languageCode) =>
      localizedText(languageCode, name, nameAr);
}

class SectionModel {
  final int? id;
  final String? name;
  final String? nameAr;

  const SectionModel({this.id, this.name, this.nameAr});

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: localizedInt(json['id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
    );
  }

  String nameFor(String languageCode) =>
      localizedText(languageCode, name, nameAr);
}

int? localizedInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String localizedText(String languageCode, String? value, String? valueAr) {
  if (languageCode == 'ar' && valueAr?.isNotEmpty == true) return valueAr!;
  return value?.isNotEmpty == true ? value! : valueAr ?? '';
}
