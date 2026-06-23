import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notification_ids.dart';
import '../../../core/notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/settings_repository.dart';
import '../default_location.dart';
import '../prayer_time_service.dart';

final prayerTimeServiceProvider = Provider((ref) => PrayerTimeService());
final settingsRepositoryProvider =
    Provider<ReminderSettingsStore>((ref) => SettingsRepository());
final _autoScheduledPrayerKeysProvider = Provider((ref) => <String>{});

final prayerNotificationController = Provider((ref) {
  final pts = ref.watch(prayerTimeServiceProvider);

  /// schedule notifications for a user (uid) at a given lat/lon
  Future<void> scheduleForLocation(
    String uid,
    double lat,
    double lon, {
    int followupMinutes = 30,
  }) async {
    final times = await pts.fetchTodayTimes(lat, lon);
    final mapping = <String, String>{
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
    };

    for (final key in mapping.keys) {
      final raw = times[key]?.split(' ')[0] ?? '';

      debugPrint('[$key] Raw prayer time from API: $raw');

      final parts = raw.split(':');
      if (parts.length < 2) {
        debugPrint('[$key] Invalid time format. Skipping.');
        continue;
      }

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final scheduled = NotificationService.scheduledDailyAt(hour, minute);

      final mainId = makeNotificationId(uid, key, followup: false);
      final followId = makeNotificationId(uid, key, followup: true);

      debugPrint('Scheduling ${mapping[key]} main notification');
      debugPrint('Main ID: $mainId');
      debugPrint('Main scheduled time: $scheduled');

      await NotificationService.scheduleDaily(
        mainId,
        '${mapping[key]} Prayer',
        "It's time for ${mapping[key]}",
        scheduled,
      );

      debugPrint('${mapping[key]} main notification scheduled successfully');

      final followScheduled = scheduled.add(Duration(minutes: followupMinutes));

      debugPrint('Scheduling ${mapping[key]} follow-up notification');
      debugPrint('Follow-up ID: $followId');
      debugPrint('Follow-up scheduled time: $followScheduled');

      await NotificationService.scheduleDaily(
        followId,
        '${mapping[key]} Reminder',
        "Reminder: ${mapping[key]} not marked yet.",
        followScheduled,
      );

      debugPrint(
          '${mapping[key]} follow-up notification scheduled successfully');
    }
  }

  return scheduleForLocation;
});

/// Helper provider to schedule using the app default location (Lahore).
final defaultPrayerScheduler = Provider((ref) {
  final schedule = ref.watch(prayerNotificationController);
  return () async {
    final user = ref.watch(firebaseUserProvider).asData?.value;
    if (user == null) return;
    await schedule(
      user.uid,
      DefaultLocation.latitude,
      DefaultLocation.longitude,
    );
  };
});

final autoSchedulePrayerRemindersProvider = Provider((ref) {
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  final scheduleDefaultPrayers = ref.watch(defaultPrayerScheduler);

  return (String uid) async {
    final today = DateTime.now();
    final scheduleKey =
        '$uid-${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final scheduledKeys = ref.read(_autoScheduledPrayerKeysProvider);
    if (scheduledKeys.contains(scheduleKey)) return;

    final remindersEnabled = await settingsRepository.getReminderEnabled(uid);
    if (!remindersEnabled) return;

    scheduledKeys.add(scheduleKey);
    try {
      await scheduleDefaultPrayers();
    } catch (_) {
      scheduledKeys.remove(scheduleKey);
      rethrow;
    }
  };
});
