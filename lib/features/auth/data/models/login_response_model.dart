class LoginResponseModel {
  final String message;
  final String token;
  final LoginUserModel user;

  const LoginResponseModel({
    required this.message,
    required this.token,
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
      user: LoginUserModel.fromJson(userJson),
    );
  }
}

class LoginUserModel {
  final int? id;
  final String? name;
  final String? nameAr;
  final String? email;
  final int? roleId;
  final String? language;
  final String? image;

  const LoginUserModel({
    this.id,
    this.name,
    this.nameAr,
    this.email,
    this.roleId,
    this.language,
    this.image,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      nameAr: json['name_ar']?.toString(),
      email: json['email']?.toString(),
      roleId: json['role_id'] as int?,
      language: json['language']?.toString(),
      image: json['image']?.toString(),
    );
  }
}
