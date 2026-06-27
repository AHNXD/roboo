class LoginResponseModel {
  final String message;
  final String token;
  final bool mustVerify;
  final LoginUserModel user;

  const LoginResponseModel({
    required this.message,
    required this.token,
    required this.mustVerify,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final userJson = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    return LoginResponseModel(
      message: json['message']?.toString() ?? '',
      token: data['token']?.toString() ?? '',
      mustVerify: _boolFromJson(data['must_verify']),
      user: LoginUserModel.fromJson(userJson),
    );
  }

  static bool _boolFromJson(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      return value == 'true' || value == '1';
    }
    return false;
  }
}

class LoginUserModel {
  final int? id;
  final String? name;
  final String? nameAr;
  final String? email;
  final String? googleId;
  final String? fcmToken;
  final String? emailVerifiedAt;
  final String? birthdate;
  final String? gender;
  final int? roleId;
  final int? points;
  final String? language;
  final List<String> heardAbout;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  const LoginUserModel({
    this.id,
    this.name,
    this.nameAr,
    this.email,
    this.googleId,
    this.fcmToken,
    this.emailVerifiedAt,
    this.birthdate,
    this.gender,
    this.roleId,
    this.points,
    this.language,
    this.heardAbout = const [],
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      email: json['email']?.toString(),
      googleId: json['google_id']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      birthdate: json['birthdate']?.toString(),
      gender: json['gender']?.toString(),
      roleId: json['role_id'] as int?,
      points: json['points'] as int?,
      language: json['language']?.toString(),
      heardAbout: _stringListFromJson(json['heard_about']),
      image: json['image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'email': email,
      'google_id': googleId,
      'fcm_token': fcmToken,
      'email_verified_at': emailVerifiedAt,
      'birthdate': birthdate,
      'gender': gender,
      'role_id': roleId,
      'points': points,
      'language': language,
      'heard_about': heardAbout,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<String> _stringListFromJson(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.map((item) => item.toString()).toList();
  }
}
