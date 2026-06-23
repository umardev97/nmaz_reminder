import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/quran_reading.dart';

class QuranRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('quran').doc(uid).collection('dates');

  Future<QuranReading?> fetchReading(String uid, String date) async {
    final doc = await _col(uid).doc(date).get();
    if (!doc.exists) return null;
    return QuranReading.fromMap({...doc.data()!, 'date': doc.id});
  }

  Future<void> setReading(String uid, String date, bool read) async {
    await _col(uid).doc(date).set({
      'date': date,
      'read': read,
      'timestamp': read ? DateTime.now().toIso8601String() : null,
    }, SetOptions(merge: true));
  }
}
