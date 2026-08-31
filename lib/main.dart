import 'core/utils/app_settings_holder.dart';
import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/locale/locale_cubit.dart';
import 'core/notification_services/notification.dart';
import 'firebase_options.dart';
import 'core/utils/app_localizations.dart';
import 'core/utils/cache_helper.dart';
import 'core/utils/colors.dart';
import 'core/utils/constats.dart';
import 'core/utils/functions.dart';
import 'core/utils/routs.dart';
import 'core/utils/services_locater.dart';
import 'core/utils/styles.dart';
import 'features/shared/splash/presentation/view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  setupLocatorServices();
  enableScreenshot();
  // Contact details are only needed once a screen with a WhatsApp or social
  // button is built, so this must not hold up the first frame.
  unawaited(getit<AppSettingsHolder>().load());
  await _initFirebase();
  runApp(const Roboo());
}

/// Notifications must never stop the app from starting: a missing or broken
/// Firebase config degrades to "no push", not a black screen.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Must be registered before the first frame so a notification that wakes
    // the app from terminated state is handled.
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Permission prompt, token fetch and the server sync are not worth blocking
    // the first frame on.
    unawaited(FirebaseApi().initNotifications());
  } catch (error) {
    log('Firebase initialisation failed; push notifications are off: $error');
  }
}

class Roboo extends StatelessWidget {
  const Roboo({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocaleCubit()..getSaveLanguage()),
      ],
      child: BlocBuilder<LocaleCubit, ChangeLocaleState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            locale: state.locale,
            supportedLocales: const [Locale("en"), Locale("ar")],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocal, supportedLocales) {
              for (var locale in supportedLocales) {
                if (deviceLocal != null &&
                    deviceLocal.languageCode == locale.languageCode) {
                  return deviceLocal;
                }
              }
              return supportedLocales.first;
            },
            title: 'Roboo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.backgroundColor,
                scrolledUnderElevation: 0,
                centerTitle: true,
                elevation: 0,
                titleTextStyle: Styles.textStyle18.copyWith(
                  color: AppColors.backgroundColor,
                ),
              ),
              textTheme: GoogleFonts.cairoTextTheme(),
              scaffoldBackgroundColor: AppColors.backgroundColor,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryColors,
              ),
              useMaterial3: true,
            ),
            initialRoute: SplashScreen.routeName,
            routes: Routes.routes,
            builder: (context, child) {
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) return;

                  final navigator = navigatorKey.currentState;
                  if (navigator != null && navigator.canPop()) {
                    navigator.pop();
                    return;
                  }

                  final shouldExit = await _showExitAppDialog(context);
                  if (shouldExit && context.mounted) {
                    SystemNavigator.pop();
                  }
                },
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

Future<bool> _showExitAppDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryColors.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.primaryTwoColors,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'exit_app_title'.tr(dialogContext),
                style: Styles.textStyle18.copyWith(
                  color: AppColors.primaryTwoColors,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'exit_app_message'.tr(dialogContext),
          style: Styles.textStyle15.copyWith(color: AppColors.lightTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.baseShimmerColor,
              textStyle: Styles.textStyle15.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text('stay'.tr(dialogContext)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColors,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: Styles.textStyle15.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text('exit_app'.tr(dialogContext)),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
