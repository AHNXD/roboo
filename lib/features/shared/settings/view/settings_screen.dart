import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../../core/utils/services_locater.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../../../auth/data/repos/logout_repo/logout_repo.dart';
import '../../../auth/presentation/view-model/logout_cubit/logout_cubit.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = "/settings";
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "settings".tr(context)),

      body: BlocProvider(
        create: (context) => LogoutCubit(getit<LogoutRepo>()),
        child: Container(),
      ),
    );
  }
}
