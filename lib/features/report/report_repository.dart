import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/report_model.dart';

class ReportRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userReports(String uid) =>
      _db.collection('reports').doc(uid).collection('dates');

  Future<void> saveReport(String uid, DailyReport report) async {
    await _userReports(
      uid,
    ).doc(report.date).set(report.toMap(), SetOptions(merge: true));
  }

  Future<DailyReport?> fetchReport(String uid, String date) async {
    final doc = await _userReports(uid).doc(date).get();
    if (!doc.exists) return null;
    return DailyReport.fromMap(doc.data()!);
  }

  Stream<List<DailyReport>> streamReports(String uid) {
    return _userReports(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => DailyReport.fromMap(d.data())).toList());
  }
}
