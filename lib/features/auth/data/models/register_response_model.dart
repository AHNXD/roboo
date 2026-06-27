class RegisterResponseModel {
  final String message;
  final String verificationMessage;
  final RegisterUserModel user;

  const RegisterResponseModel({
    required this.message,
    required this.verificationMessage,
    required this.user,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final userJson = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    return RegisterResponseModel(
      message: json['message']?.toString() ?? '',
      verificationMessage: data['message']?.toString() ?? '',
      user: RegisterUserModel.fromJson(userJson),
    );
  }
}

class RegisterUserModel {
  final int? id;
  final String? name;
  final String? nameAr;
  final String? email;
  final String? birthdate;
  final String? gender;
  final String? language;
  final String? fcmToken;
  final List<String> heardAbout;
  final int? roleId;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  const RegisterUserModel({
    this.id,
    this.name,
    this.nameAr,
    this.email,
    this.birthdate,
    this.gender,
    this.language,
    this.fcmToken,
    this.heardAbout = const [],
    this.roleId,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory RegisterUserModel.fromJson(Map<String, dynamic> json) {
    return RegisterUserModel(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      email: json['email']?.toString(),
      birthdate: json['birthdate']?.toString(),
      gender: json['gender']?.toString(),
      language: json['language']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
      heardAbout: _stringListFromJson(json['heard_about']),
      roleId: json['role_id'] as int?,
      image: json['image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static List<String> _stringListFromJson(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.map((item) => item.toString()).toList();
  }
}
