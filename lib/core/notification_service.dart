import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize FlutterLocalNotificationsPlugin
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Method to handle background messages
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Background message: ${message.notification?.title}");
  }
}

// Method to show notifications in the foreground
Future<void> showForegroundNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channelId',
    'channelName',
    channelDescription: 'channelDescription',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title,
    message.notification?.body,
    platformDetails,
    payload: message.data.toString(),
  );
}

// Method to initialize notifications plugin
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Your app icon here

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize the notifications plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
