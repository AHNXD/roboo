import 'package:flutter/material.dart';
import 'package:roboo/features/app/courses/presentation/view/courses_screen.dart';
import 'package:roboo/features/app/home/presentation/view/home_screen.dart';
import 'package:roboo/features/app/news/presentation/view/news_screen.dart';
import 'package:roboo/features/app/store/presentation/view/store_screen.dart';

import '../../features/app/cart/presentation/view/cart_screen.dart';
import '../../features/app/product-details/presentation/view/product_details_screen.dart';
import '../../features/auth/presentation/views/login/view/login_screen.dart';
import '../../features/auth/presentation/views/sign_up/view/sign_up_screen.dart';
import '../../features/shared/about_us/presentation/view/about_us_screen.dart';
import '../../features/shared/contact_us/presentation/view/contact_us_screen.dart';
import '../../features/shared/privacy_policy/presentation/view/privacy_policy_screen.dart';
import '../../features/shared/settings/view/settings_screen.dart';
import '../../features/shared/splash/presentation/view/splash_screen.dart';
import '../../features/shared/terms_and_condition/presentation/view/terms_and_conditions_screen.dart';
import '../../features/shared/welcome/view/welcome_screen.dart';
import '../widgets/main_screen.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    //auth
    LoginScreen.routeName: (context) => LoginScreen(),
    SignUpScreen.routeName: (context) => SignUpScreen(),

    //user
    MainScreen.routeName: (context) => MainScreen(),

    //shared
    SettingsScreen.routeName: (context) => SettingsScreen(),
    WelcomeScreen.routeName: (context) => WelcomeScreen(),
    SplashScreen.routeName: (context) => SplashScreen(),
    PrivacyPolicyScreen.routeName: (context) => PrivacyPolicyScreen(),
    TermsAndConditionsScreen.routeName: (context) => TermsAndConditionsScreen(),
    ContactUsScreen.routeName: (context) => ContactUsScreen(),
    AboutUsScreen.routeName: (context) => AboutUsScreen(),

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
  };
}
