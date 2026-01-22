class Urls {
  //base urls
  static String ip = "192.168.1.142:8000";
  static String baseUrl = "http://$ip/api/";

  //assets urls
  static String assetsBaseUrl = "http://$ip/storage/app/public/";

  //auth endpoint
  static String login = "login";
  static String logout = "logout";
  static String register = "register";
  static String verifiPhoneNum = "verify-account";
  static String forgetPassword = "forget-password";
  static String verfiResetPassword = "verify-reset-password";
  static String resendCode = "resend-code";

  //profile endpoint
  static String getProfile = "get_profile";
  static String updateProfile = "update_profile";
  static String deleteProfile = "delete_account";

  //Specialists endpoint
  static const String specialists = "get_all_specialties";

  //Doctors endpoint
  static const String doctors = "get_all_doctors";

  //Centers endpoint
  static const String centers = "get_all_clinic_centers";

  //Home endpoint
  static const String home = "home";

  //Diagnose endpoints
  static const String categories = "v1/categories";
  static String questions(int categoryId) =>
      "v1/categories/$categoryId/questions";
  static const String diagnose = "v1/diagnose";
}
