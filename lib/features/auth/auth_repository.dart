import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/app_user.dart';

class AuthRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserIfNotExists(AppUser user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set(user.toMap());
    }
  }

  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap({...doc.data()!, 'uid': doc.id});
  }

  Future<void> saveFcmToken(String uid, String token) async {
    final ref = _db.collection('users').doc(uid).collection('fcm').doc(token);
    await ref.set({'token': token, 'createdAt': FieldValue.serverTimestamp()});
  }
}
