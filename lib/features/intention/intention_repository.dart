import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/daily_intention.dart';

class IntentionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _intentionRef(String date) =>
      _db.collection('dailyIntentions').doc(date);

  DocumentReference<Map<String, dynamic>> _completionRef(
    String uid,
    String date,
  ) =>
      _db.collection('users').doc(uid).collection('intentions').doc(date);

  Stream<DailyIntention?> streamIntention(String date) {
    return _intentionRef(date).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DailyIntention.fromMap(doc.data()!);
    });
  }

  Stream<IntentionCompletion?> streamCompletion(String uid, String date) {
    return _completionRef(uid, date).snapshots().map((doc) {
      if (!doc.exists) return null;
      return IntentionCompletion.fromMap(doc.data()!);
    });
  }

  Future<void> saveIntention(DailyIntention intention) async {
    await _intentionRef(intention.date).set(intention.toMap());
  }

  Future<void> setCompletion(
    String uid,
    String date, {
    required bool completed,
  }) async {
    await _completionRef(uid, date).set(
      IntentionCompletion(date: date, completed: completed).toMap(),
      SetOptions(merge: true),
    );
  }
}
