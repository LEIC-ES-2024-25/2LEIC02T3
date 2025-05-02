import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = 
      InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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