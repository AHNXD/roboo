import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:roboo/core/utils/assets_data.dart';

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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _splashLogic();
      }
    });
  }

  void _splashLogic() {
    // Navigate to Onboarding
    Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);

    // --- Restored your commented logic for reference ---
    // bool trueToken = _checkToken();
    // if (trueToken) {
    //   String role = _getRole();
    //   if (role == "patient") {
    //      ...
    //   }
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
      backgroundColor: AppColors.primaryColors,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          // Load the Lottie asset
          child: Lottie.asset(
            AssetsData.loadingAnimation,

            controller: _controller,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..forward();
            },
            // Optional: If you want to fit it specifically
            // fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
