import 'package:flutter/material.dart';
import 'package:roboo/features/app/course/presentation/view/course_details_screen_screen.dart';
import 'package:roboo/features/app/courses/presentation/view/courses_screen.dart';
import 'package:roboo/features/app/games/presentation/view/games_screen.dart';
import 'package:roboo/features/app/home/presentation/view/home_screen.dart';
import 'package:roboo/features/app/news/presentation/view/news_screen.dart';
import 'package:roboo/features/app/profile/presentation/view/edit_profile_screen.dart';
import 'package:roboo/features/app/profile/presentation/view/profile_menu_screen.dart';
import 'package:roboo/features/app/quizes/presentation/view/quizes_screen.dart';
import 'package:roboo/features/app/store/presentation/view/store_screen.dart';
import 'package:roboo/features/auth/presentation/views/forget-password/presentation/view/forget_password_screen.dart';
import 'package:roboo/features/shared/faq/presentation/view/faq_screen.dart';

import '../../features/app/cart/presentation/view/cart_screen.dart';
import '../../features/app/leaderboard/presentation/view/leaderboard_screen.dart';
import '../../features/app/product-details/presentation/view/product_details_screen.dart';
import '../../features/app/my-courses/presentation/view/my_courses_screen.dart';
import '../../features/app/quizes/presentation/view/quiz_screen.dart';
import '../../features/app/roboo-ai/presentation/view/roboo_ai_screen.dart';
import '../../features/auth/presentation/views/login/view/login_screen.dart';
import '../../features/auth/presentation/views/register/view/register_screen.dart';
import '../../features/shared/complaints/presentation/view/complaints_screen.dart';
import '../../features/shared/on-boarding/presentation/view/on_boarding_screen.dart';
import '../../features/shared/privacy_policy/presentation/view/privacy_policy_screen.dart';
import '../../features/shared/settings/view/settings_screen.dart';
import '../../features/shared/splash/presentation/view/splash_screen.dart';
import '../widgets/main_screen.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    //auth
    LoginScreen.routeName: (context) => LoginScreen(),
    RegisterScreen.routeName: (context) => RegisterScreen(),
    ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),

    //user
    MainScreen.routeName: (context) => MainScreen(),

    //shared
    SettingsScreen.routeName: (context) => SettingsScreen(),
    SplashScreen.routeName: (context) => SplashScreen(),
    PrivacyPolicyScreen.routeName: (context) => PrivacyPolicyScreen(),
    FaqScreen.routeName: (context) => FaqScreen(),
    ComplaintsScreen.routeName: (context) => ComplaintsScreen(),

    //home
    HomeScreen.routeName: (context) => HomeScreen(),
    CoursesScreen.routeName: (context) => CoursesScreen(),
    NewsScreen.routeName: (context) => NewsScreen(),
    StoreScreen.routeName: (context) => StoreScreen(),

    //product details
    ProductDetailsScreen.routeName: (context) =>
        ProductDetailsScreen(title: '', price: '', imagePath: ''),

    //cart
    CartScreen.routeName: (context) => CartScreen(),

    //onboarding
    OnboardingScreen.routeName: (context) => OnboardingScreen(),

    //roboo ai
    RobooAiScreen.routeName: (context) => RobooAiScreen(),

    //leaderboard
    LeaderboardScreen.routeName: (context) => LeaderboardScreen(),

    //games
    GamesScreen.routeName: (context) => GamesScreen(),

    //quizes
    QuizesScreen.routeName: (context) => QuizesScreen(),
    QuizScreen.routeName: (context) => QuizScreen(),

    //profile
    MyCoursesScreen.routeName: (context) => MyCoursesScreen(),
    ProfileMenuScreen.routeName: (context) => ProfileMenuScreen(),
    EditProfileScreen.routeName: (context) => EditProfileScreen(),

    //course details
    CourseDetailsScreen.routeName: (context) =>
        CourseDetailsScreen(isOnline: false, title: ''),
  };
}
