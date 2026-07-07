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

  // current auth endpoints
  static const String authLogin = "auth/login";
  static const String authRegister = "auth/register";
  static const String authLogout = "auth/logout";
  static const String authMe = "auth/me";
  static const String authVerifyCode = "auth/verify-code";
  static const String authResendVerification = "auth/resend-verification";
  static const String authForgotPassword = "auth/forgot-password";
  static const String authResetPassword = "auth/reset-password";

  // current profile endpoints
  static const String authProfile = "auth/profile";
  static const String authRequestPasswordUpdate =
      "auth/request-password-update";
  static const String authUpdatePassword = "auth/update-password";

  // public exploration endpoints
  static const String categories = "categories";
  static const String topics = "topics";
  static const String products = "products";
  static String productDetails(int productId) => "products/$productId";
  static const String faqs = "faqs";
  static const String galleries = "galleries";
  static const String privacyPolicy = "privacy-policy";
  static const String termsOfUse = "terms-of-use";

  // protected shop endpoints
  static const String cart = "cart";
  static const String cartItems = "cart/items";
  static const String cartItemsUpdate = "cart/items/update";
  static const String cartItemsRemove = "cart/items/remove";
  static const String cartClear = "cart/clear";
  static const String orders = "orders";
  static String orderDetails(int orderId) => "orders/$orderId";
  static const String favorites = "favorites";
  static const String productFavorite = "products/favorite";

  // social and meta endpoints
  static const String leaderboard = "leaderboard";
  static const String feedbacks = "feedbacks";
}
