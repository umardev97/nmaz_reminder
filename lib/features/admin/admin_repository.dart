import 'package:cloud_firestore/cloud_firestore.dart';

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
}
