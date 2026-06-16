import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../intention_repository.dart';
import '../models/daily_intention.dart';

final intentionRepositoryProvider = Provider((ref) => IntentionRepository());

String todayDateId() => DateFormat('yyyy-MM-dd').format(DateTime.now());

final todayIntentionProvider = StreamProvider.autoDispose<DailyIntention?>((
  ref,
) {
  final repo = ref.watch(intentionRepositoryProvider);
  return repo.streamIntention(todayDateId());
});

final todayIntentionCompletionProvider =
    StreamProvider.autoDispose.family<IntentionCompletion?, String>((ref, uid) {
  final repo = ref.watch(intentionRepositoryProvider);
  return repo.streamCompletion(uid, todayDateId());
});

final saveIntentionProvider = Provider((ref) {
  final repo = ref.watch(intentionRepositoryProvider);
  return (DailyIntention intention) => repo.saveIntention(intention);
});

final setIntentionCompletionProvider = Provider((ref) {
  final repo = ref.watch(intentionRepositoryProvider);
  return (String uid, bool completed) => repo.setCompletion(
        uid,
        todayDateId(),
        completed: completed,
      );
});
