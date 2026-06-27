import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/main_screen.dart';
import 'package:roboo/features/auth/presentation/view-model/token_cubit/token_cubit.dart';

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
  late TokenCubit _tokenCubit;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
    _tokenCubit = TokenCubit(getit.get());

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _tokenCubit.cheackToken();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tokenCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _tokenCubit,
      child: BlocListener<TokenCubit, TokenState>(
        listener: (context, state) {
          if (state is IsVaildToken) {
            Navigator.pushReplacementNamed(context, MainScreen.routeName);
          } else if (state is IsNotVaildToken || state is TokenErrorState) {
            Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.primaryColors,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Lottie.asset(
                AssetsData.loadingAnimation,
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
