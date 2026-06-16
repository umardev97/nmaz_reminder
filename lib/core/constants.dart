class AppConstants {
  // Asset paths
  static const String azanSoundPath = 'azan';
  static const String azanSoundFileName = 'azan.mp3';

  // Notification Channel IDs
  static const String prayerNotificationChannelId = 'prayer_chan';
  static const String prayerNotificationChannelName = 'Prayer Notifications';
  static const String prayerNotificationChannelDescription =
      'Prayer time reminders';

  // Android Launcher Icon
  static const String androidLauncherIcon = '@mipmap/ic_launcher';

  // Aladhan API
  static const String aladhanApiBaseUrl = 'https://api.aladhan.com/v1';
  static const int prayerApiTimeout = 10; // seconds
  static const int prayerApiMethod = 2; // Calculation method
}
