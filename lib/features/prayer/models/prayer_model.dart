class PrayerEntry {
  final String date; // yyyy-MM-dd
  final bool fajr;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;
  final Map<String, String>? timestamps; // prayer -> iso timestamp
  final Map<String, String>? notes; // prayer -> note

  PrayerEntry({
    required this.date,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
    this.timestamps,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
        'timestamps': timestamps ?? {},
        'notes': notes ?? {},
      };

  factory PrayerEntry.fromMap(Map<String, dynamic> m) => PrayerEntry(
        date: m['date'] as String,
        fajr: m['fajr'] ?? false,
        dhuhr: m['dhuhr'] ?? false,
        asr: m['asr'] ?? false,
        maghrib: m['maghrib'] ?? false,
        isha: m['isha'] ?? false,
        timestamps: Map<String, String>.from(m['timestamps'] ?? {}),
        notes: Map<String, String>.from(m['notes'] ?? {}),
      );
}
