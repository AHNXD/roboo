import '../../features/app/notifications/presentation/view-model/notifications_badge_cubit/notifications_badge_cubit.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/services_locater.dart';
import 'fcm_token_sync.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings android = AndroidInitializationSettings(
    '@mipmap/launcher_icon',
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
          // `ic_launcher` is Flutter's default logo, left over from project
          // creation — flutter_launcher_icons writes the real app icon to
          // mipmap one does and matches the initialisation default.
          icon: '@mipmap/launcher_icon',
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

  StreamSubscription<String>? _tokenRefreshSubscription;

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
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
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
      // Arrived while the app is open, so it is unread — bump the bell without
      // a round trip. The count is corrected from the server the next time the
      // notifications screen or the top bar fetches.
      if (getit.isRegistered<NotificationsBadgeCubit>()) {
        getit.get<NotificationsBadgeCubit>().increment();
      }

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
              icon: '@mipmap/launcher_icon',
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

  /// Fetches the FCM registration token, stores it, and pushes it to the
  /// backend when the backend does not have this one yet.
  ///
  /// Both platforms need `getToken()` — that is the FCM registration token the
  /// server sends to. On iOS it only becomes available once APNS has handed the
  /// app its own token, so that is awaited first; a simulator or a device that
  /// refused notifications simply never returns one, which is not an error.
  Future<void> saveToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          log('APNS token not available yet; FCM token deferred to refresh');
          _listenForTokenRefresh();
          return;
        }
      }

      final fcmToken = await _firebaseMessaging.getToken();
      log('FCM token: $fcmToken');

      final tokenSync = getit.get<FcmTokenSync>();
      await tokenSync.saveToken(fcmToken);
      await tokenSync.syncIfNeeded();
    } catch (error) {
      // Never let a messaging failure take the app down at startup.
      log('Failed to obtain the FCM token: $error');
    }

    _listenForTokenRefresh();
  }

  void _listenForTokenRefresh() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen((
      newToken,
    ) async {
      log('FCM token refreshed');
      await getit.get<FcmTokenSync>().onTokenRefreshed(newToken);
    });
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
