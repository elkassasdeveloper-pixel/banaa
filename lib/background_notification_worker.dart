import 'dart:io';

import 'package:educ_core/services/cache_helper.dart';
import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/utils/logger.dart';
import 'package:educ_student/notification_service.dart';
import 'package:material_ui/material_ui.dart';
import  'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

const workManagerTaskKey = "fetch_new_notifications_task";

/// ✅ تكتب لوج في ملف داخل Documents
Future<void> writeLog(String message) async {
  try {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      // على iOS نحفظ في Documents العادي
      directory = await getApplicationDocumentsDirectory();
    }

    final file = File('${directory.path}/ahmed_mostafa.txt');
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message\n';
    await file.writeAsString(logMessage, mode: FileMode.append);

    debugPrint("Log written to: ${file.path}");
  } catch (e) {
    debugPrint("Failed to write log: $e");
  }
}

@pragma('vm:entry-point')
void backgroundNotificationDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    int retryCount = inputData?['retryCount'] ?? 0;
    await writeLog("=== Workmanager started ===");
    WidgetsFlutterBinding.ensureInitialized();
    await writeLog("Widgets initialized");

    if (task == workManagerTaskKey) {
      await writeLog("Task = workManagerTaskKey");

      try {
        await CacheHelper.init();
        await writeLog("CacheHelper initialized");

        final token = CacheHelper.getToken();
        if (token == null) {
          await writeLog("No token found — skipping notification check");
          return await Future.value(true);
        }

        final lastNotificationMessageId = CacheHelper.getData('last_notifi_message_id') ?? 0;
        await writeLog("Last notification ID: $lastNotificationMessageId");

        DioHelper.init();
        DioHelper.setToken(token);
        debugPrint('token: $token');
        await writeLog("DioHelper initialized and token set");

        final response = await DioHelper.dio.get(
          '/api/NotifiMessage/GetUserNotificationList',
          queryParameters: {"last_notifi_message_id": /*0*/ lastNotificationMessageId},
        );

        await writeLog("Response received: ${response.statusMessage}");
        await writeLog("Response statusCode: ${response.statusCode}");
        final result = response.data['data'] as List;
        debugPrint('result: $result');
        if (result.isNotEmpty) {
          final notifications = List<Map<String, dynamic>>.from(result);
          await writeLog("Received ${notifications.length} notifications");

          final notificationService = NotificationService();
          await notificationService.initNotification();
          await writeLog("NotificationService initialized");
          for (var notification in notifications) {
            await notificationService.showNotification(
              title: notification['title'] ?? 'New Notification',
              body: notification['message'] ?? '',
            );
          }

          await CacheHelper.saveData(
            key: 'last_notifi_message_id',
            value: notifications.first['notifi_message_id'],
          );

          await writeLog("Notifications processed and cache updated");
        } else {
          if (result.isEmpty) {
            await writeLog("result is empty");
          }
          await writeLog("No new notifications found");
        }
      } catch (e, st) {
        await writeLog("Error: $e\nStack: $st");
        if (retryCount < 3) {
          Logger.Red("Background WorkManager error: $e\n$st");
          return Future.value(false);
        } else {
          await writeLog('Task failed permanently after 3 retries');
          return Future.value(true);
        }
      }
    }

    await writeLog("=== Workmanager finished ===");
    return Future.value(true);
  });
}
