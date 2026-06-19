import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import 'constants.dart';

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

    final androidInit =
        AndroidInitializationSettings(AppConstants.androidLauncherIcon);

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings: settings);

    _initialized = true;
  }

  /// Common notification details
  static NotificationDetails _details() {
    final android = AndroidNotificationDetails(
      AppConstants.prayerNotificationChannelId,
      AppConstants.prayerNotificationChannelName,
      channelDescription: AppConstants.prayerNotificationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(AppConstants.azanSoundPath),
    );

    final ios = DarwinNotificationDetails(
      sound: AppConstants.azanSoundFileName,
    );

    return NotificationDetails(
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
