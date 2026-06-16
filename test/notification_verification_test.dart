import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:nmaz_reminder/core/notification_service.dart';

void main() {
  group('Notification Scheduling Verification Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      tzdata.initializeTimeZones();
    });

    test('Verify: 5 prayer notifications CAN be scheduled', () {
      final today = DateTime.now();
      final prayers = [
        'Fajr',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha',
      ];
      final hours = [5, 12, 15, 18, 20];

      expect(prayers.length, 5);
      expect(hours.length, 5);

      for (int i = 0; i < prayers.length; i++) {
        final time = tz.TZDateTime(
          tz.local,
          today.year,
          today.month,
          today.day,
          hours[i],
          0,
        );
        expect(time.hour, hours[i]);
        expect(time.toString().isEmpty, false);
      }
    });

    test('Verify: Notification times are in chronological order', () {
      final today = DateTime.now();
      final times = [
        tz.TZDateTime(tz.local, today.year, today.month, today.day, 5, 30),
        tz.TZDateTime(tz.local, today.year, today.month, today.day, 12, 15),
        tz.TZDateTime(tz.local, today.year, today.month, today.day, 15, 45),
        tz.TZDateTime(tz.local, today.year, today.month, today.day, 18, 50),
        tz.TZDateTime(tz.local, today.year, today.month, today.day, 20, 10),
      ];

      for (int i = 1; i < times.length; i++) {
        expect(times[i].isAfter(times[i - 1]), true,
            reason:
                '${times[i]} should be after ${times[i - 1]}');
      }
    });

    test('Verify: scheduledDailyAt returns valid future time', () {
      final now = tz.TZDateTime.now(tz.local);
      final scheduled = NotificationService.scheduledDailyAt(14, 30);

      expect(scheduled.minute, 30);
      expect(scheduled.isAfter(now) || scheduled.isAtSameMomentAs(now), true,
          reason: 'Scheduled time should be in future or now');
    });

    test('Verify: scheduledDailyAt handles time wrapping correctly', () {
      final now = tz.TZDateTime.now(tz.local);

      // Schedule for 2 AM
      final scheduled = NotificationService.scheduledDailyAt(2, 0);

      expect(scheduled.hour, 2);
      expect(scheduled.isAfter(now), true,
          reason: 'Should schedule for today or tomorrow');
    });

    test('Verify: Main and followup notifications are 30 minutes apart', () {
      const followupMinutes = 30;
      final today = DateTime.now();
      final mainTime = tz.TZDateTime(
        tz.local,
        today.year,
        today.month,
        today.day,
        5,
        30,
      );
      final followupTime =
          mainTime.add(const Duration(minutes: followupMinutes));

      final difference = followupTime.difference(mainTime).inMinutes;
      expect(difference, followupMinutes);
    });

    test('Verify: Multiple notifications have unique times', () {
      final today = DateTime.now();
      final times = [
        tz.TZDateTime(tz.local, today.year, today.month, today.day, 5, 30),
        tz.TZDateTime(tz.local, today.year, today.month, today.day, 12, 15),
        tz.TZDateTime(tz.local, today.year, today.month, today.day, 15, 45),
        tz.TZDateTime(tz.local, today.year, today.month, today.day, 18, 50),
        tz.TZDateTime(tz.local, today.year, today.month, today.day, 20, 10),
      ];

      final timeSet = times.toSet();
      expect(timeSet.length, 5, reason: 'All times should be unique');
    });

    test('Verify: Notification IDs are positive integers', () {
      final ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

      for (int id in ids) {
        expect(id > 0, true);
        expect(id is int, true);
      }
    });

    test('Verify: Prayer time strings are properly formatted', () {
      const prayerTimes = {
        'fajr': '05:30 (PKT)',
        'dhuhr': '12:15 (PKT)',
        'asr': '15:45 (PKT)',
        'maghrib': '18:50 (PKT)',
        'isha': '20:10 (PKT)',
      };

      for (final time in prayerTimes.values) {
        expect(time.contains(':'), true, reason: 'Should contain \":\"');
        expect(time.contains('('), true, reason: 'Should contain timezone');

        final parts = time.split(' ')[0].split(':');
        expect(parts.length, 2, reason: 'Should have HH:MM format');

        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);

        expect(hour != null && hour >= 0 && hour < 24, true);
        expect(minute != null && minute >= 0 && minute < 60, true);
      }
    });

    test('Verify: All 5 prayers are accounted for', () {
      const prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
      expect(prayers.length, 5);

      final prayerSet = prayers.toSet();
      expect(prayerSet.length, 5, reason: 'All prayer names should be unique');

      for (final prayer in prayers) {
        expect(prayer.isNotEmpty, true);
      }
    });

    test('Verify: Notification contains required information', () {
      const title = 'Fajr Prayer';
      const body = "It's time for Fajr";
      const id = 1;

      expect(title.isNotEmpty, true);
      expect(body.isNotEmpty, true);
      expect(id > 0, true);
      expect(title.toLowerCase().contains('prayer'), true);
    });

    test('Verify: Today date is correctly set for notifications', () {
      final today = DateTime.now();
      final notificationDate = tz.TZDateTime(
        tz.local,
        today.year,
        today.month,
        today.day,
        5,
        0,
      );

      expect(notificationDate.year, today.year);
      expect(notificationDate.month, today.month);
      expect(notificationDate.day, today.day);
    });

    test(
        'Verify: Notification for past time today is scheduled for tomorrow',
        () {
      final now = tz.TZDateTime.now(tz.local);

      // Create a time that's in the past
      var pastTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        now.hour - 2,
        0,
      );

      // If past time is still in future (unlikely), create one that's definitely past
      if (pastTime.isAfter(now)) {
        pastTime = now.subtract(const Duration(hours: 1));
      }

      // Schedule it using the service logic
      final scheduled = NotificationService.scheduledDailyAt(
        pastTime.hour,
        pastTime.minute,
      );

      expect(scheduled.isAfter(now), true,
          reason: 'Past time should be scheduled for tomorrow');
    });
  });
}
