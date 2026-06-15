class DailyReport {
  final String date; // yyyy-MM-dd
  final String visitedPlaces;
  final String workDone;
  final String islamicActivities;
  final String notes;
  final String mood; // Excellent / Good / Average / Poor

  DailyReport({
    required this.date,
    required this.visitedPlaces,
    required this.workDone,
    required this.islamicActivities,
    required this.notes,
    required this.mood,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'visitedPlaces': visitedPlaces,
        'workDone': workDone,
        'islamicActivities': islamicActivities,
        'notes': notes,
        'mood': mood,
      };

  factory DailyReport.fromMap(Map<String, dynamic> m) => DailyReport(
        date: m['date'] as String,
        visitedPlaces: m['visitedPlaces'] ?? '',
        workDone: m['workDone'] ?? '',
        islamicActivities: m['islamicActivities'] ?? '',
        notes: m['notes'] ?? '',
        mood: m['mood'] ?? 'Average',
      );
}
