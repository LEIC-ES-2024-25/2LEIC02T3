import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create notification channel explicitly
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'step_count_channel',
            'Step Count',
            description: 'Shows the current step count in a persistent notification',
            importance: Importance.max,
          ),
        );
      }
    }

    // For Android 13 and newer, request the POST_NOTIFICATIONS permission at runtime.
    if (Platform.isAndroid) {
      // In a real app, consider using permission_handler package to request permission.
      // This example uses the local notifications plugin's requestPermission.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> showStepCountNotification(int stepCount) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'step_count_channel',
      'Step Count',
      channelDescription: 'Shows the current step count in a persistent notification',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // Makes the notification persistent
      showWhen: false,
      playSound: false,     // Disable sound
      enableVibration: false, // Disable vibration
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification id
      'Current Steps',
      'You have taken $stepCount steps today',
      platformDetails,
    );
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
}