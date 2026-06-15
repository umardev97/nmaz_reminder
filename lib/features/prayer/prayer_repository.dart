import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/prayer_model.dart';

class PrayerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userPrayers(String uid) =>
      _db.collection('prayers').doc(uid).collection('dates');

  Future<void> savePrayerEntry(String uid, PrayerEntry entry) async {
    await _userPrayers(
      uid,
    ).doc(entry.date).set(entry.toMap(), SetOptions(merge: true));
  }

  Future<PrayerEntry?> fetchPrayer(String uid, String date) async {
    final doc = await _userPrayers(uid).doc(date).get();
    if (!doc.exists) return null;
    return PrayerEntry.fromMap(doc.data()!);
  }

  Stream<List<PrayerEntry>> streamMonth(
    String uid,
    String startDate,
    String endDate,
  ) {
    return _userPrayers(uid)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date')
        .snapshots()
        .map((s) => s.docs.map((d) => PrayerEntry.fromMap(d.data())).toList());
  }

  Future<void> markPrayer(
    String uid,
    String date,
    String prayerName, {
    String? note,
  }) async {
    final docRef = _userPrayers(uid).doc(date);
    final tsKey = 'timestamps.$prayerName';
    final noteKey = 'notes.$prayerName';
    final updates = <String, dynamic>{
      prayerName: true,
      tsKey: DateTime.now().toIso8601String(),
    };
    if (note != null) updates[noteKey] = note;
    await docRef.set({'date': date}, SetOptions(merge: true));
    await docRef.update(updates);
  }
}
