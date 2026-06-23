class QuranReading {
  final String date; // yyyy-MM-dd
  final bool read;
  final String? timestamp; // ISO when marked

  const QuranReading({
    required this.date,
    required this.read,
    this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'read': read,
        'timestamp': timestamp,
      };

  factory QuranReading.fromMap(Map<String, dynamic> m) => QuranReading(
        date: m['date'] as String? ?? '',
        read: m['read'] as bool? ?? false,
        timestamp: m['timestamp'] as String?,
      );
}
