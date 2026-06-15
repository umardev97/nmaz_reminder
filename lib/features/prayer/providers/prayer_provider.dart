import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notification_ids.dart';
import '../../../core/notification_service.dart';
import '../models/prayer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../prayer_repository.dart';

final prayerRepositoryProvider = Provider((ref) => PrayerRepository());

final todayPrayerProvider = FutureProvider.family<PrayerEntry?, String>((
  ref,
  uid,
) async {
  final repo = ref.watch(prayerRepositoryProvider);
  final today = DateTime.now();
  final date =
      '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  return repo.fetchPrayer(uid, date);
});

final markPrayerProvider = Provider((ref) {
  final repo = ref.watch(prayerRepositoryProvider);
  return (String uid, String date, String prayerName, {String? note}) async {
    await repo.markPrayer(uid, date, prayerName, note: note);
    // cancel follow-up notification for this prayer
    try {
      final followId = makeNotificationId(
        uid,
        date,
        prayerName,
        followup: true,
      );
      await NotificationService.cancel(followId);
    } catch (_) {}
    // mark followup cancelled in Firestore so other devices / server won't send alerts
    try {
      final db = FirebaseFirestore.instance;
      final docId = '${date}_$prayerName';
      final ref =
          db.collection('users').doc(uid).collection('followups').doc(docId);
      await ref.set({
        'cancelled': true,
        'cancelledAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  };
});
