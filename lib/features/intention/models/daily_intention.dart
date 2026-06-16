class DailyIntention {
  const DailyIntention({
    required this.date,
    required this.quote,
    required this.message,
  });

  final String date;
  final String quote;
  final String message;

  Map<String, dynamic> toMap() => {
        'date': date,
        'quote': quote,
        'message': message,
      };

  factory DailyIntention.fromMap(Map<String, dynamic> map) => DailyIntention(
        date: map['date'] as String? ?? '',
        quote: map['quote'] as String? ?? '',
        message: map['message'] as String? ?? '',
      );
}

class IntentionCompletion {
  const IntentionCompletion({
    required this.date,
    required this.completed,
  });

  final String date;
  final bool completed;

  Map<String, dynamic> toMap() => {
        'date': date,
        'completed': completed,
        'updatedAt': DateTime.now().toIso8601String(),
      };

  factory IntentionCompletion.fromMap(Map<String, dynamic> map) =>
      IntentionCompletion(
        date: map['date'] as String? ?? '',
        completed: map['completed'] as bool? ?? false,
      );
}
