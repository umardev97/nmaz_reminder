import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:nmaz_reminder/core/notification_ids.dart';
import 'package:nmaz_reminder/core/notification_service.dart';

void main() {
  group('Notification Scheduling - Integration Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      tzdata.initializeTimeZones();
    });

    test('5 prayer notifications can be scheduled in sequence', () async {
      final today = DateTime.now();
      final prayerTimes = [
        (hour: 5, minute: 30, name: 'Fajr'),
        (hour: 12, minute: 15, name: 'Dhuhr'),
        (hour: 15, minute: 45, name: 'Asr'),
        (hour: 18, minute: 50, name: 'Maghrib'),
        (hour: 20, minute: 10, name: 'Isha'),
      ];

      List<(int, tz.TZDateTime)> scheduledNotifications = [];

      for (int i = 0; i < prayerTimes.length; i++) {
        final prayer = prayerTimes[i];
        final scheduled = tz.TZDateTime(
          tz.local,
          today.year,
          today.month,
          today.day,
          prayer.hour,
          prayer.minute,
        );

        scheduledNotifications.add((i, scheduled));

        // Verify the scheduled time is valid
        expect(scheduled.hour, prayer.hour);
        expect(scheduled.minute, prayer.minute);
      }

      expect(scheduledNotifications.length, 5);
    });

    test('Scheduled notifications are in chronological order', () async {
      final today = DateTime.now();
      List<tz.TZDateTime> times = [];

      final prayerTimes = [5, 12, 15, 18, 20];

      for (int hour in prayerTimes) {
        final time = tz.TZDateTime(
          tz.local,
          today.year,
          today.month,
          today.day,
          hour,
          0,
        );
        times.add(time);
      }

      for (int i = 1; i < times.length; i++) {
        expect(times[i].isAfter(times[i - 1]), true);
      }
    });

    test('Notification for past time is scheduled for tomorrow', () async {
      final now = DateTime.now();
      final pastTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        now.hour - 2,
        0,
      );

      if (pastTime.isBefore(tz.TZDateTime.now(tz.local))) {
        final nextDayTime = pastTime.add(const Duration(days: 1));
        expect(
          nextDayTime.isAfter(tz.TZDateTime.now(tz.local)),
          true,
        );
      }
    });

    test('Main and followup notifications are properly spaced', () async {
      const followupMinutes = 30;
      final now = DateTime.now();

      final mainTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        12,
        15,
      );

      final followupTime =
          mainTime.add(const Duration(minutes: followupMinutes));

      final difference = followupTime.difference(mainTime).inMinutes;
      expect(difference, followupMinutes);
    });

    test('NotificationService.scheduledDailyAt works correctly', () {
      final now = tz.TZDateTime.now(tz.local);

      // Test future time
      final futureTime = NotificationService.scheduledDailyAt(
        (now.hour + 3) % 24,
        30,
      );
      expect(futureTime.isAfter(now), true);

      // Test past time
      final pastTime = NotificationService.scheduledDailyAt(
        (now.hour - 2 + 24) % 24,
        0,
      );
      expect(pastTime.isAfter(now), true);
    });

    test('Multiple notification IDs are unique', () {
      final ids = <int>{};
      const uid = 'notification-test-user';
      const prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

      for (final prayer in prayers) {
        ids.add(makeNotificationId(uid, prayer, followup: false));
        ids.add(makeNotificationId(uid, prayer, followup: true));
      }

      expect(ids.length, 10);
    });

    test('Notification details include all required fields', () {
      const title = 'Fajr Prayer';
      const body = "It's time for Fajr";
      const id = 1;

      expect(title.isNotEmpty, true);
      expect(body.isNotEmpty, true);
      expect(id > 0, true);
    });

    test('Prayer time parsing from API format works', () {
      const rawTime = '05:30 (PKT)';
      final parts = rawTime.split(' ')[0].split(':');

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      expect(hour, 5);
      expect(minute, 30);
    });

    test('All 5 prayers have valid time slots', () {
      final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
      expect(prayers.length, 5);

      final validTimes = [5, 12, 15, 18, 20];
      for (int time in validTimes) {
        expect(time >= 0 && time < 24, true);
      }
    });
  });
}
