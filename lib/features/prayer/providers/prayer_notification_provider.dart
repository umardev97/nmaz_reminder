import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/notification_ids.dart';
import '../../../core/notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../default_location.dart';
import '../prayer_time_service.dart';

final prayerTimeServiceProvider = Provider((ref) => PrayerTimeService());

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

    final today = DateTime.now();
    final date =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    for (final key in mapping.keys) {
      final raw = times[key]?.split(' ')[0] ?? '';
      final parts = raw.split(':');
      if (parts.length < 2) continue;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final scheduled = tz.TZDateTime(
        tz.local,
        today.year,
        today.month,
        today.day,
        hour,
        minute,
      );

      final mainId = makeNotificationId(uid, date, key, followup: false);
      final followId = makeNotificationId(uid, date, key, followup: true);

      // schedule main daily notification
      await NotificationService.scheduleDaily(
        mainId,
        '${mapping[key]} Prayer',
        "It's time for ${mapping[key]}",
        scheduled,
      );

      // schedule daily follow-up X minutes after prayer time
      final followScheduled = scheduled.add(Duration(minutes: followupMinutes));
      await NotificationService.scheduleDaily(
        followId,
        '${mapping[key]} Reminder',
        "Reminder: ${mapping[key]} not marked yet.",
        followScheduled,
      );

      // persist follow-up metadata so other devices / server can act accordingly
      try {
        final db = FirebaseFirestore.instance;
        final docId = '${date}_$key';
        await db
            .collection('users')
            .doc(uid)
            .collection('followups')
            .doc(docId)
            .set({
          'mainId': mainId,
          'followId': followId,
          'prayer': key,
          'date': date,
          'scheduledAt': scheduled.toIso8601String(),
          'followScheduledAt': followScheduled.toIso8601String(),
          'cancelled': false,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        // ignore persistence errors locally
      }
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
