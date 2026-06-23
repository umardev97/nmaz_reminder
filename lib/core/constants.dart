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
  static const int prayerApiTimeout = 10;
  static const int prayerApiMethod = 2;

  // App info
  static const String appVersion = '1.0.0';
  static const String appName = 'Nmaz Reminder';

  // Prayer defaults
  static const String defaultPrayerCity = 'Lahore';
  static const String defaultPrayerCountry = 'Pakistan';
  static const String defaultPrayerLocation = 'Lahore, Pakistan';
  static const String defaultCalculationMethod = 'ISNA';
  static const String defaultNotificationSound = 'Azan';
  static const int followUpMinutes = 30;
  static const String followUpDisplay = '30 min after prayer';

  // Privacy
  static const String privacyNote =
      'Your prayer activity, reflections, and daily intentions are stored securely and linked only to your account. We never share your data with third parties.';
}
