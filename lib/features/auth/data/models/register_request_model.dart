class RegisterRequestModel {
  final String name;
  final String nameAr;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String birthdate;
  final String gender;
  final String language;
  final List<String> heardAbout;
  final String fcmToken;

  const RegisterRequestModel({
    required this.name,
    required this.nameAr,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.birthdate,
    required this.gender,
    required this.language,
    required this.heardAbout,
    required this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_ar': nameAr,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'birthdate': birthdate,
      'gender': gender,
      'language': language,
      'heard_about': heardAbout,
      'fcm_token': fcmToken,
    };
  }
}
