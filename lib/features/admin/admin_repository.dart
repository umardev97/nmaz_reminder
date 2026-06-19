import 'package:cloud_firestore/cloud_firestore.dart';

import '../intention/models/daily_intention.dart';
import '../prayer/models/prayer_model.dart';
import '../report/models/report_model.dart';

class AdminUserActivity {
  const AdminUserActivity({
    required this.date,
    required this.prayer,
    required this.report,
    required this.intentionCompletion,
    required this.completedIntentions,
  });

  final String date;
  final PrayerEntry? prayer;
  final DailyReport? report;
  final IntentionCompletion? intentionCompletion;
  final List<IntentionCompletion> completedIntentions;
}

class AdminRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamAllUsers() {
    return _db.collection('users').snapshots().map(
        (snap) => snap.docs.map((d) => {...d.data(), 'uid': d.id}).toList());
  }

  Future<Map<String, dynamic>?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return {...doc.data()!, 'uid': doc.id};
  }

  Future<AdminUserActivity> fetchUserActivity(String uid, String date) async {
    final prayerFuture =
        _db.collection('prayers').doc(uid).collection('dates').doc(date).get();
    final reportFuture =
        _db.collection('reports').doc(uid).collection('dates').doc(date).get();
    final intentionFuture = _db
        .collection('users')
        .doc(uid)
        .collection('intentions')
        .doc(date)
        .get();
    final completedIntentionsFuture = _db
        .collection('users')
        .doc(uid)
        .collection('intentions')
        .where('completed', isEqualTo: true)
        .get();

    final prayerDoc = await prayerFuture;
    final reportDoc = await reportFuture;
    final intentionDoc = await intentionFuture;
    final completedIntentionsSnap = await completedIntentionsFuture;
    final completedIntentions = completedIntentionsSnap.docs
        .map((doc) =>
            IntentionCompletion.fromMap({...doc.data(), 'date': doc.id}))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return AdminUserActivity(
      date: date,
      prayer: prayerDoc.exists ? PrayerEntry.fromMap(prayerDoc.data()!) : null,
      report: reportDoc.exists ? DailyReport.fromMap(reportDoc.data()!) : null,
      intentionCompletion: intentionDoc.exists
          ? IntentionCompletion.fromMap(intentionDoc.data()!)
          : null,
      completedIntentions: completedIntentions,
    );
  }
}
