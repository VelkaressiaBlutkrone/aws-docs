// flutter_app/lib/data/cloud/firestore_cloud_store.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloud_store.dart';

/// CloudStore의 Firestore 구현. users/{uid}/{collection}/{docId} = data.
/// 라이브 검증은 사용자 Firebase 설정 후(수동).
class FirestoreCloudStore implements CloudStore {
  FirestoreCloudStore([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid, String collection) =>
      _db.collection('users').doc(uid).collection(collection);

  @override
  Future<void> setDoc(String uid, String collection, String docId,
          Map<String, dynamic> data) =>
      _col(uid, collection).doc(docId).set(data);

  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
      String uid, String collection) async {
    final snap = await _col(uid, collection).get();
    return {for (final d in snap.docs) d.id: d.data()};
  }

  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
          String uid, String collection) =>
      _col(uid, collection).snapshots().map(
          (qs) => {for (final d in qs.docs) d.id: d.data()});
}
