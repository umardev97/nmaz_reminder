import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.initialize();
  final title = message.notification?.title ?? 'Prayer Reminder';
  final body = message.notification?.body ?? '';
  await NotificationService.showImmediate(message.hashCode, title, body);
}

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await NotificationService.initialize();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (Platform.isIOS) {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      final title = msg.notification?.title ?? 'Prayer Reminder';
      final body = msg.notification?.body ?? '';
      await NotificationService.showImmediate(msg.hashCode, title, body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      // handle navigation if needed
    });
  }

  Future<String?> getToken() async {
    return _messaging.getToken();
  }
}
