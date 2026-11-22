import 'dart:io';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // INITIALIZE
  Future<void> initNotification() async {
    if (_isInitialized) return;
    const initSettingAndroid = AndroidInitializationSettings("@mipmap/ic_launcher");
    const initSettingIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initWindows = WindowsInitializationSettings(
      appName: "banaa",
      appUserModelId:
          "com"
          ".hodhdsoft.banaa",
      guid: "ce08530a-2b91-42e2-8aae-984baef597ec",
    );
    const initSettings = InitializationSettings(
      android: initSettingAndroid,
      iOS: initSettingIOS,
      windows: initWindows,
    );
    await notificationsPlugin.initialize(settings: initSettings);
    const androidChannel = AndroidNotificationChannel(
      'background_channel_id',
      'Background Notifications',
      description: 'Used for background local notifications',
      importance: Importance.high,
    );

    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(androidChannel);
    _isInitialized = true;
  }

  //NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'background_channel_id',
        'Background Notifications',
        channelDescription: 'Used for background FCM notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );
  }

  //SHOW NOTIFICATION
  Future<void> showNotification({String? title, String? body}) async {
    final id = Random().nextInt(100000);
    notificationsPlugin.show(id:id,title:  title,body:  body,notificationDetails: notificationDetails());
  }

  Future<void> requestNotificationPermission() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      final granted = await androidPlugin?.requestNotificationsPermission();
      if (granted == true) {
      } else {}
    } else if (Platform.isIOS) {
      final iosPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }
}
