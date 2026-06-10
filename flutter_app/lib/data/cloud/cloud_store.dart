import 'dart:async';
import 'dart:convert';

/// 키드-문서 클라우드 저장소 추상화. 병합 의미는 SyncService가 담당.
abstract interface class CloudStore {
  Future<void> setDoc(
      String uid, String collection, String docId, Map<String, dynamic> data);
  Future<Map<String, Map<String, dynamic>>> loadCollection(
      String uid, String collection);
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
      String uid, String collection);
}

/// 메모리 구현(테스트). uid→collection→docId→data.
class FakeCloudStore implements CloudStore {
  final _d = <String, Map<String, Map<String, Map<String, dynamic>>>>{};
  final _ctrls =
      <String, StreamController<Map<String, Map<String, dynamic>>>>{};

  @override
  Future<void> setDoc(String uid, String collection, String docId,
      Map<String, dynamic> data) async {
    final coll = ((_d[uid] ??= {})[collection] ??= {});
    coll[docId] = _deepCopy(data);
    _emit(uid, collection);
  }

  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
      String uid, String collection) async {
    final coll = _d[uid]?[collection] ?? const {};
    return {
      for (final e in coll.entries) e.key: _deepCopy(e.value),
    };
  }

  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
          String uid, String collection) =>
      (_ctrls['$uid/$collection'] ??=
              StreamController<Map<String, Map<String, dynamic>>>.broadcast())
          .stream;

  void _emit(String uid, String collection) {
    final c = _ctrls['$uid/$collection'];
    if (c == null) return;
    final coll = _d[uid]?[collection] ?? const {};
    c.add({
      for (final e in coll.entries) e.key: _deepCopy(e.value),
    });
  }

  /// 중첩 List/Map까지 깊은 복사(JSON 직렬화 가능 데이터 전제) — 테스트 격리.
  static Map<String, dynamic> _deepCopy(Map<String, dynamic> m) =>
      jsonDecode(jsonEncode(m)) as Map<String, dynamic>;
}
