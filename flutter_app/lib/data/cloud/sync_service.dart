import 'dart:convert';

import '../viewed_docs_store.dart'; // KvBackend도 함께 re-export 한다
import '../../models/attempt_record.dart';
import 'cloud_store.dart';
import 'sync_merge.dart';
import 'sync_meta.dart';

/// 로컬 KvBackend 블롭 ↔ CloudStore 엔티티 화해. 시각은 주입(테스트 결정적).
class SyncService {
  SyncService({
    required KvBackend local,
    required CloudStore cloud,
    int Function()? nowMs,
  })  : _local = local,
        _cloud = cloud,
        _now = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final KvBackend _local;
  final CloudStore _cloud;
  final int Function() _now;

  static const _kHistory = 'awsdocs.history.v1';
  static const _kViewed = 'awsdocs.viewed.v1';
  static const _kPlans = 'awsdocs.plan.v1';
  static const _kChecks = 'awsdocs.plan.checks.v1';
  static const _kMeta = 'awsdocs.sync.v1';

  Map<String, dynamic> _readJsonMap(String key) {
    final raw = _local.read(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  List<dynamic> _readJsonList(String key) {
    final raw = _local.read(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return jsonDecode(raw) as List;
    } catch (_) {
      return [];
    }
  }

  Map<String, int> _meta(String section) {
    final m = _readJsonMap(_kMeta)[section];
    if (m is! Map) return {};
    final out = <String, int>{};
    for (final e in m.entries) {
      final v = e.value;
      if (v is num) out[e.key.toString()] = v.toInt(); // 손상 stamp는 무시(미스탬프로 강등)
    }
    return out;
  }

  /// 값이 달라졌을 때만 쓴다 — 무변경 reconcile(주기 틱)이 로컬을 매번 재기록하지 않게.
  void _writeIfChanged(String key, String value) {
    if (_local.read(key) != value) _local.write(key, value);
  }

  void _writeMeta(String section, Map<String, int> data) {
    final all = _readJsonMap(_kMeta);
    all[section] = data;
    _writeIfChanged(_kMeta, jsonEncode(all));
  }

  /// 한 회차에서 지우는 클라우드 문서 수 상한(초기화 직후 동기가 길어지지 않게).
  static const maxDeletesPerRound = 50;

  /// 로그인 직후·트리거 시 양방향 화해. 삭제 표식을 먼저 화해해 이번 회차 기준으로 쓴다.
  Future<void> reconcileAll(String uid) async {
    final marks = await _reconcileDeletions(uid);
    await _reconcileAttempts(uid, marks);
    await _reconcileViewed(uid, marks);
    await _reconcileLww(uid, _kPlans, 'plans', 'plans'); // 레거시(PR2에서 교체)
    await _reconcileLww(uid, _kChecks, 'checks', 'checks');
  }

  /// meta/deletions 화해: 로컬·클라우드 표식을 필드별 늦은 시각으로 합쳐 양쪽에
  /// 반영하고, 이번 회차에 적용할 표식을 돌려준다.
  Future<Map<String, int>> _reconcileDeletions(String uid) async {
    final doc = (await _cloud.loadCollection(uid, 'meta'))['deletions'] ??
        const <String, dynamic>{};
    final cloudMarks = <String, int>{
      for (final e in ((doc['resetAt'] as Map?) ?? const {}).entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
    final meta = SyncMeta(_local);
    final merged = mergeResetMarks(meta.resetAt, cloudMarks);
    if (!_sameMarks(merged, meta.resetAt)) meta.resetAt = merged;
    if (!_sameMarks(merged, cloudMarks)) {
      await _cloud.setDoc(uid, 'meta', 'deletions', {...doc, 'resetAt': merged});
    }
    return merged;
  }

  bool _sameMarks(Map<String, int> a, Map<String, int> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);

  Future<void> _deleteUpTo(
      String uid, String collection, List<String> ids) async {
    for (final id in ids.take(maxDeletesPerRound)) {
      await _cloud.deleteDoc(uid, collection, id);
    }
  }

  // 각 화해는 클라우드 로드(await)를 먼저 끝낸 뒤 로컬을 읽고, 병합·로컬 쓰기까지
  // await 없이 잇는다. 로컬 읽기와 쓰기 사이에 await가 끼면 그 사이의 사용자 쓰기
  // (응시 제출·열람·수동 체크)를 stale 스냅샷이 덮어 유실된다(CODE-D-004).
  // 로컬 쓰기 뒤의 setDoc await는 무해하다 — 이후 로컬을 다시 쓰지 않는다.

  Future<void> _reconcileAttempts(String uid, Map<String, int> marks) async {
    final cloud = await _cloud.loadCollection(uid, 'attempts');
    final local = _readJsonList(_kHistory)
        .whereType<Map<String, dynamic>>()
        .map(AttemptRecord.fromJson)
        .toList();
    final r = mergeAttempts(local, cloud, resetAt: marks);
    _writeIfChanged(
        _kHistory, jsonEncode(r.merged.map((e) => e.toJson()).toList()));
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'attempts', e.key, e.value);
    }
    await _deleteUpTo(uid, 'attempts', r.toDelete);
  }

  Future<void> _reconcileViewed(String uid, Map<String, int> marks) async {
    final cloud = await _cloud.loadCollection(uid, 'viewed');
    // 스토어를 통해 읽는다 — 값 형태(맵/레거시 배열) 해석을 한 곳에 둔다.
    final local = ViewedDocsStore(backend: _local).readAll();
    final r = mergeViewed(local, cloud, resetAt: marks);
    _writeIfChanged(_kViewed, jsonEncode(r.merged));
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'viewed', e.key, e.value);
    }
    await _deleteUpTo(uid, 'viewed', r.toDelete);
  }

  Future<void> _reconcileLww(
      String uid, String localKey, String collection, String metaSection) async {
    final cloud = await _cloud.loadCollection(uid, collection);
    final rawLocal = _readJsonMap(localKey);
    final local = <String, Map<String, dynamic>>{
      for (final e in rawLocal.entries)
        if (e.value is Map) e.key: Map<String, dynamic>.from(e.value as Map),
    };
    var meta = _meta(metaSection);
    // 사이드카 없는 기존 로컬 엔티티는 now로 스탬프(클라우드 stale가 덮지 않게).
    final now = _now();
    for (final cert in local.keys) {
      meta.putIfAbsent(cert, () => now);
    }
    final r = mergeLww(local, meta, cloud);
    _writeIfChanged(localKey, jsonEncode(r.merged));
    _writeMeta(metaSection, r.mergedMeta);
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, collection, e.key, e.value);
    }
  }
}
