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

  Future<void> deleteUserData(String uid) async {
    await _deleteCollection(_db.collection('users').doc(uid).collection('fcm'));
    await _deleteCollection(
      _db.collection('users').doc(uid).collection('settings'),
    );
    await _deleteCollection(
      _db.collection('users').doc(uid).collection('followups'),
    );
    await _deleteCollection(
      _db.collection('users').doc(uid).collection('intentions'),
    );
    await _deleteCollection(
      _db.collection('prayers').doc(uid).collection('dates'),
    );
    await _deleteCollection(
      _db.collection('reports').doc(uid).collection('dates'),
    );

    final batch = _db.batch();
    batch.delete(_db.collection('users').doc(uid));
    await batch.commit();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    const pageSize = 300;
    while (true) {
      final snapshot = await collection.limit(pageSize).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
