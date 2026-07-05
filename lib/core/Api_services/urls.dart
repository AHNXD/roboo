class Urls {
  //base urls
  static String ip = "192.168.1.2:8000";
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
}
