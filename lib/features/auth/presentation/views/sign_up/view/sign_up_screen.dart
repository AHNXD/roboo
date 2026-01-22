import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/services_locater.dart';
import '../../../../data/repos/register_repo/register_repo.dart';
import '../../../view-model/register_cubit/register_cubit.dart';

class SignUpScreen extends StatelessWidget {
  static const String routeName = "/sign_up";
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) => RegisterCubit(getit.get<RegisterRepo>()),
        child: SafeArea(
          child: BlocBuilder<RegisterCubit, RegisterState>(
            builder: (context, state) {
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
