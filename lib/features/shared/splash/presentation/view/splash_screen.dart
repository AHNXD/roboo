import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/utils/assets_data.dart';
import '../../../../../core/utils/colors.dart';
import '../../../on-boarding/presentation/view/on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = "/splash";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Timer(const Duration(seconds: 1), _splashLogic);
      }
    });

    _controller.forward();
  }

  // bool _checkToken() {
  //   String token = CacheHelper.getData(key: 'token') ?? '';
  //   return token.isNotEmpty;
  // }

  // String _getRole() {
  //   String role = CacheHelper.getData(key: 'role') ?? '';
  //   return role;
  // }

  void _splashLogic() {
    Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    // bool trueToken = _checkToken();
    // if (trueToken) {
    //   String role = _getRole();

    //   if (role == "patient") {
    //     context.read<UserCubit>().getProfile();
    //     Navigator.pushReplacementNamed(context, MainScreen.routeName);
    //   } else if (role == "doctor") {
    //     context.read<UserCubit>().getProfile();
    //     Navigator.pushReplacementNamed(
    //       context,
    //       DoctorDashboardScreen.routeName,
    //     );
    //   } else {
    //     Navigator.pushReplacementNamed(context, WelcomeScreen.routeName);
    //   }
    // } else {
    //   Navigator.pushReplacementNamed(context, WelcomeScreen.routeName);
    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Hero(tag: 'app-logo', child: Image.asset(AssetsData.logo)),
            ),
          ),
        ),
      ),
    );
  }
}
