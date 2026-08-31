import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';

import '../../features/shared/settings/data/models/app_settings_model.dart';
import 'app_settings_holder.dart';
import 'cache_helper.dart';
import 'services_locater.dart';

final noScreenshot = NoScreenshot.instance;
bool isSecureMode = false;

const double kBorderRadius = 15;
const double kSizedBoxHeight = 25;
const double kVerticalPadding = 15;
const double kHorizontalPadding = 10;

bool isGuest = CacheHelper.getData(key: "token") == null ? true : false;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Contact details, served by `GET settings` so the dashboard can change them
/// without an app release. Anything the dashboard has not filled in stays null,
/// and the control that needs it stays hidden.
class AppContact {
  const AppContact._();

  static AppSettingsModel get _settings => getit<AppSettingsHolder>().current;

  static String get whatsAppNumber => _settings.whatsAppNumber ?? '';
  static String get facebookUrl => _settings.facebookUrl ?? '';
  static String get instagramUrl => _settings.instagramUrl ?? '';

  static bool get hasWhatsApp => _settings.hasWhatsApp;
}
