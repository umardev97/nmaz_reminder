import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quran_reading.dart';
import '../quran_repository.dart';

final quranRepositoryProvider = Provider((ref) => QuranRepository());

String _today() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

final todayQuranReadingProvider =
    FutureProvider.family<QuranReading?, String>((ref, uid) async {
  return ref.read(quranRepositoryProvider).fetchReading(uid, _today());
});

final setQuranReadingProvider = Provider((ref) {
  final repo = ref.read(quranRepositoryProvider);
  return (String uid, bool read) async {
    await repo.setReading(uid, _today(), read);
    ref.invalidate(todayQuranReadingProvider(uid));
  };
});
