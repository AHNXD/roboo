class Urls {
  //base urls
  static String ip = "api.robooq.com";
  static String baseUrl = "https://$ip/api/";

  //assets urls
  static String assetsBaseUrl = "https://$ip/storage/app/public/";

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
  static const String authGoogle = "auth/google";
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
  static const String courses = "courses";
  static const String coursesFeatured = "courses/featured";
  static const String coursesFavorite = "courses/favorite";
  static const String coursesFavorites = "courses/favorites";
  static const String myCourses = "my/courses";
  static String courseDetails(int courseId) => "courses/$courseId";
  static String courseReserveClick(int courseId) =>
      "courses/$courseId/reserve-click";
  static String courseMarkWatched(int courseId) =>
      "courses/$courseId/mark-watched";
  static const String couponsApply = "coupons/apply";
  static const String products = "products";
  static String productDetails(int productId) => "products/$productId";
  static const String faqs = "faqs";
  static const String settings = "settings";
  static const String notifications = "notifications";
  static const String notificationsMarkAllRead = "notifications/mark-all-read";
  static String notificationRead(int notificationId) =>
      "notifications/$notificationId/read";
  static const String galleries = "galleries";
  static const String privacyPolicy = "privacy-policy";
  static const String termsOfUse = "terms-of-use";

  // student school endpoints
  static const String enrollment = "enrollment";
  static const String enrollmentRedeem = "enrollment/redeem";
  static const String homework = "homework";
  static String homeworkDetails(int homeworkId) => "homework/$homeworkId";
  static String homeworkSubmit(int homeworkId) => "homework/$homeworkId/submit";

  // protected student learning endpoints
  static const String quizzes = "quizzes";
  static String quizDetails(int quizId) => "quizzes/$quizId";
  static String quizSubmit(int quizId) => "quizzes/$quizId/submit";

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
