import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/cache_helper.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings android = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );
  const DarwinInitializationSettings ios = DarwinInitializationSettings();
  const InitializationSettings settings = InitializationSettings(
    android: android,
    iOS: ios,
  );
  await localNotifications.initialize(settings);

  final notification = message.notification;
  if (notification != null) {
    localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Highly Important Notifications',
          channelDescription:
              'This Channel is used for important notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'Highly Important Notifications',
    description: 'This Channel is used for important notifications',
    importance: Importance.max,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    log("Notification clicked with data: ${message.data}");
    // Handle navigation or action based on message data
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(settings);
    final platform = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initPushNotifications() async {
    // Display notification in foreground
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final android = message.notification?.android;
      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(message);
    });

    // Handle initial message when app is launched from terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Save the FCM token
    await saveToken();
  }

  Future<void> saveToken() async {
    final bool hasFCMToken =
        await CacheHelper.getData(key: "hasFCMToken") ?? false;
    log("hasFCMToken: ${hasFCMToken.toString()}");
    final String? token = await CacheHelper.getData(key: "token");
    log("token: ${token.toString()}");

    if (!hasFCMToken) {
      final String? fcmToken = Platform.isAndroid
          ? await _firebaseMessaging.getToken()
          : await _firebaseMessaging.getAPNSToken();
      log("fCMToken: ${fcmToken.toString()}");

      if (fcmToken != null) {
        await CacheHelper.setBool(key: "hasFCMToken", value: true);
        await CacheHelper.setString(key: "fcm_token", value: fcmToken);
      } else {
        log("Failed to retrieve FCM token");
      }
    }
    final String fcmToken = CacheHelper.getData(key: 'fcm_token');
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await CacheHelper.setString(key: "fcm_token", value: newToken);
      // send it to server
    });
    log("fCMToken: ${fcmToken.toString()}");
  }

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log("Notification permission denied");
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log("Notification permission granted");
    } else {
      log("Notification permission granted provisionally");
    }
  }

  Future<void> initNotifications() async {
    await requestNotificationPermission();
    await initPushNotifications();
    await initLocalNotifications();
  }
}
