import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';

import 'cache_helper.dart';

final noScreenshot = NoScreenshot.instance;
bool isSecureMode = false;


const double kBorderRadius = 15;
const double kSizedBoxHeight = 25;
const double kVerticalPadding = 15;
const double kHorizontalPadding = 10;

bool isGuest = CacheHelper.getData(key: "token") == null ? true : false;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
