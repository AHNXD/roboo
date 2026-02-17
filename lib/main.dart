import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/locale/locale_cubit.dart';
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
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupLocatorServices();
  enableScreenshot();
  // await FirebaseApi().initNotifications();
  runApp(const Roboo());
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
