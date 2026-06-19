import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ReminderSettingsStore {
  Future<void> setReminderEnabled(String uid, bool enabled);
  Future<bool> getReminderEnabled(String uid);
}

class SettingsRepository implements ReminderSettingsStore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<void> setReminderEnabled(String uid, bool enabled) async {
    final ref =
        _db.collection('users').doc(uid).collection('settings').doc('prefs');
    await ref.set({'remindersEnabled': enabled}, SetOptions(merge: true));
  }

  @override
  Future<bool> getReminderEnabled(String uid) async {
    final ref =
        _db.collection('users').doc(uid).collection('settings').doc('prefs');
    final doc = await ref.get();
    if (!doc.exists) return true;
    return doc.data()?['remindersEnabled'] ?? true;
  }
}
