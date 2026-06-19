import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmaz_reminder/features/auth/settings_repository.dart';
import 'package:nmaz_reminder/features/prayer/providers/prayer_notification_provider.dart';

class _FakeSettingsRepository implements ReminderSettingsStore {
  _FakeSettingsRepository(this.enabled);

  final bool enabled;

  @override
  Future<bool> getReminderEnabled(String uid) async => enabled;

  @override
  Future<void> setReminderEnabled(String uid, bool enabled) async {}
}

void main() {
  test('auto scheduler schedules prayer reminders once after login', () async {
    var scheduleCount = 0;
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          _FakeSettingsRepository(true),
        ),
        defaultPrayerScheduler.overrideWithValue(() async {
          scheduleCount++;
        }),
      ],
    );
    addTearDown(container.dispose);

    final scheduleAfterLogin =
        container.read(autoSchedulePrayerRemindersProvider);

    await scheduleAfterLogin('uid-login-test');
    await scheduleAfterLogin('uid-login-test');

    expect(scheduleCount, 1);
  });

  test('auto scheduler respects disabled prayer reminders', () async {
    var scheduleCount = 0;
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          _FakeSettingsRepository(false),
        ),
        defaultPrayerScheduler.overrideWithValue(() async {
          scheduleCount++;
        }),
      ],
    );
    addTearDown(container.dispose);

    await container.read(autoSchedulePrayerRemindersProvider)('uid-login-test');

    expect(scheduleCount, 0);
  });
}
