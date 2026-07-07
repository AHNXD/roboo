class ProfileModel {
  final String message;
  final ProfileUserModel user;

  const ProfileModel({required this.message, required this.user});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final userJson = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    return ProfileModel(
      message: json['message']?.toString() ?? '',
      user: ProfileUserModel.fromJson(userJson),
    );
  }
}

class ProfileUserModel {
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
  final bool hasHeardAbout;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  const ProfileUserModel({
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
    this.hasHeardAbout = false,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: _intFromJson(json['id']),
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      email: json['email']?.toString(),
      googleId: json['google_id']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      birthdate: json['birthdate']?.toString(),
      gender: json['gender']?.toString(),
      roleId: _intFromJson(json['role_id']),
      points: _intFromJson(json['points']),
      language: json['language']?.toString(),
      heardAbout: _stringListFromJson(json['heard_about']),
      hasHeardAbout: json.containsKey('heard_about'),
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

  ProfileUserModel mergeMissingFrom(ProfileUserModel fallback) {
    return ProfileUserModel(
      id: id ?? fallback.id,
      name: name ?? fallback.name,
      nameAr: nameAr ?? fallback.nameAr,
      email: email ?? fallback.email,
      googleId: googleId ?? fallback.googleId,
      fcmToken: fcmToken ?? fallback.fcmToken,
      emailVerifiedAt: emailVerifiedAt ?? fallback.emailVerifiedAt,
      birthdate: birthdate ?? fallback.birthdate,
      gender: gender ?? fallback.gender,
      roleId: roleId ?? fallback.roleId,
      points: points ?? fallback.points,
      language: language ?? fallback.language,
      heardAbout: hasHeardAbout ? heardAbout : fallback.heardAbout,
      hasHeardAbout: hasHeardAbout || fallback.hasHeardAbout,
      image: image ?? fallback.image,
      createdAt: createdAt ?? fallback.createdAt,
      updatedAt: updatedAt ?? fallback.updatedAt,
    );
  }

  static int? _intFromJson(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static List<String> _stringListFromJson(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.map((item) => item.toString()).toList();
  }
}
