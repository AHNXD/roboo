// ignore_for_file: strict_top_level_inference

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import '../widgets/cutom_dialog.dart';
import 'app_localizations.dart';
import 'constats.dart';

Future<void> toggleScreenshot() async {
  if (isSecureMode) {
    await enableScreenshot();
  } else {
    await disableScreenshot();
  }
}

Future<void> enableScreenshot() async {
  await noScreenshot.screenshotOn();
  isSecureMode = false;
}

Future<void> disableScreenshot() async {
  await noScreenshot.screenshotOff();
  isSecureMode = true;
}

//navigators
Route goRoute({required var x}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => x,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.fastEaseInToSlowEaseOut;

      final tween = Tween(begin: begin, end: end);
      final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
      return SlideTransition(
        position: tween.animate(curvedAnimation),
        child: child,
      );
    },
  );
}

//messages
void messages(BuildContext context, String error, Color c, {int msgTime = 2}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: c,
      content: Text(error),
      duration: Duration(seconds: msgTime),
    ),
  );
}

void showCustomDialog({
  required BuildContext context,
  required String title,
  required String description,
  required String primaryButtonText,
  String? secondaryButtonText,
  Color? primaryButtonColor,
  Color? secondaryButtonColor,
  IconData? icon,
  bool? oneButton,
  required void Function() onPrimaryAction,
  void Function()? onSecondaryAction,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CustomDialog(
        title: title,
        oneButton: oneButton,
        description: description,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText ?? "cancel".tr(context),
        primaryButtonColor: primaryButtonColor,
        secondaryButtonColor: secondaryButtonColor,
        icon: icon ?? Icons.lock,
        onPrimaryAction: onPrimaryAction,
        onSecondaryAction: onSecondaryAction ?? () => Navigator.pop(context),
      );
    },
  );
}

void showAwesomeDialog({
  required BuildContext context,
  required DialogType dialogType,
  required String title,
  required String desc,
  required void Function() btnOk,
  required void Function() btnCancel,
}) async {
  await AwesomeDialog(
    descTextStyle: TextStyle(fontSize: 16),
    btnOkText: "yes".tr(context),
    btnCancelText: "no".tr(context),
    context: context,
    dialogType: dialogType,
    animType: AnimType.scale,
    title: title,
    desc: desc,
    btnCancelOnPress: btnCancel,
    btnOkOnPress: btnOk,
  ).show();
}

//reset home
resetHomeCubits(BuildContext context) {}
