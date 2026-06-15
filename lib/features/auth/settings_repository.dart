import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setReminderEnabled(String uid, bool enabled) async {
    final ref =
        _db.collection('users').doc(uid).collection('settings').doc('prefs');
    await ref.set({'remindersEnabled': enabled}, SetOptions(merge: true));
  }

  Future<bool> getReminderEnabled(String uid) async {
    final ref =
        _db.collection('users').doc(uid).collection('settings').doc('prefs');
    final doc = await ref.get();
    if (!doc.exists) return true;
    return doc.data()?['remindersEnabled'] ?? true;
  }
}
