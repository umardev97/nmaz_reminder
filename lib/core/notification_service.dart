import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Call once in main()
  static Future<void> initialize() async {
    if (_initialized) return;

    // Timezone setup (IMPORTANT)
    tzdata.initializeTimeZones();
    final TimezoneInfo currentTimeZone =
        await FlutterTimezone.getLocalTimezone();
    final String localTz = currentTimeZone.identifier;
    tz.setLocalLocation(tz.getLocation(localTz));

    // Android 13+ permission handler
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings: settings);

    _initialized = true;
  }

  /// Common notification details
  static NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      'prayer_chan',
      'Prayer Notifications',
      channelDescription: 'Prayer time reminders',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('assets/sounds/azan.mp3'),
    );

    const ios = DarwinNotificationDetails(
      sound: 'assets/sounds/azan.mp3',
    );

    return const NotificationDetails(
      android: android,
      iOS: ios,
    );
  }

  /// Immediate notification
  static Future<void> showImmediate(
    int id,
    String title,
    String body,
  ) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(),
    );
  }

  /// Scheduled daily notification
  static Future<void> scheduleDaily(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduled,
  ) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: _details(),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancel one notification
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Helper: schedule time today or tomorrow
  static tz.TZDateTime scheduledDailyAt(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
