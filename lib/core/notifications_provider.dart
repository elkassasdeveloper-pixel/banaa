// // import 'dart:math';
// // import 'package:educ_core/utils/logger.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// //
// // class NotificationsProvider {
// //   NotificationsProvider._instance();
// //
// //   static final NotificationsProvider instance = NotificationsProvider._instance();
// //
// //   factory NotificationsProvider() => instance;
// //
// //   final plugin = FlutterLocalNotificationsPlugin();
// //
// //   Future<void> initialize() async {
// //     final androidImplementation = plugin
// //         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
// //
// //     try {
// //       var requestNotificationsPermission = await androidImplementation
// //           ?.requestNotificationsPermission();
// //
// //       if (requestNotificationsPermission != null && requestNotificationsPermission) {
// //         Logger.data("Notifications Permission", "Granted ✅");
// //       } else {
// //         Logger.data("Notifications Permission", "Denied ❌");
// //       }
// //     } catch (e) {
// //       Logger.Red(e, name: "NotificationsProvider");
// //     }
// //
// //     // Initialize the plugin
// //     const androidSettings = AndroidInitializationSettings('ic_stat_notify');
// //     final iosSettings = DarwinInitializationSettings();
// //
// //     final initializationSettings = InitializationSettings(
// //       android: androidSettings,
// //       iOS: iosSettings,
// //     );
// //
// //     try {
// //       await plugin.initialize(
// //         initializationSettings,
// //         onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
// //       );
// //     } catch (e) {
// //       Logger.Red(e, name: "NotificationsProvider");
// //     }
// //   }
// //
// //   void _onDidReceiveNotificationResponse(NotificationResponse response) async {
// //     final payload = response.payload;
// //     if (payload != null) {
// //       Logger.data("notification payload", payload);
// //     }
// //   }
// //
// //   Future<void> showNotification({String? title, String? body}) async {
// //     const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
// //       "0",
// //       "Test",
// //       channelDescription: "Test",
// //       icon: 'ic_stat_notify',
// //     );
// //     const NotificationDetails notificationDetails = NotificationDetails(
// //       android: androidNotificationDetails,
// //     );
// //     await plugin.show(Random().nextInt(100), title, body, notificationDetails);
// //   }
// // }
//
// import 'dart:math';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/foundation.dart';
//
// class NotificationService {
//   // Singleton
//   NotificationService._internal();
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//   bool _isInitialized = false;
//
//   bool get isInitialized => _isInitialized;
//
//   // INITIALIZE
//   Future<void> initNotification() async {
//     if (_isInitialized) return;
//
//     // Android settings
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     // iOS settings
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     // Initialize plugin
//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     try {
//       final androidImplementation = notificationsPlugin
//           .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>();
//
//       final permissionGranted =
//       await androidImplementation?.requestNotificationsPermission();
//
//       if (permissionGranted != null && permissionGranted) {
//         debugPrint("✅ Notifications permission granted");
//       } else {
//         debugPrint("❌ Notifications permission denied");
//       }
//     } catch (e) {
//       debugPrint("⚠ Error requesting notifications permission: $e");
//     }
//
//     await notificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
//     );
//
//     _isInitialized = true;
//   }
//
//   // تعامل مع الضغط على الإشعار
//   void _onDidReceiveNotificationResponse(NotificationResponse response) {
//     if (response.payload != null) {
//       debugPrint("📩 Notification payload: ${response.payload}");
//     }
//   }
//
//   // Notification details
//   NotificationDetails notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'default_channel_id',
//         'General Notifications',
//         channelDescription: 'General notification channel',
//         importance: Importance.max,
//         priority: Priority.high,
//         icon: '@mipmap/ic_launcher',
//       ),
//       iOS: DarwinNotificationDetails(),
//     );
//   }
//
//   // Show notification
//   Future<void> showNotification({
//     String? title,
//     String? body,
//     String? payload,
//   }) async {
//     final id = Random().nextInt(100000);
//     await notificationsPlugin.show(
//       id,
//       title,
//       body,
//       notificationDetails(),
//       payload: payload,
//     );
//   }
// }
