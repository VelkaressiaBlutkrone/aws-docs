import 'dart:convert';

import '../local_kv.dart';
import '../../models/attempt_record.dart';
import 'cloud_store.dart';
import 'sync_merge.dart';

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

  /// 로그인 직후 4종 양방향 화해.
  Future<void> reconcileAll(String uid) async {
    await _reconcileAttempts(uid);
    await _reconcileViewed(uid);
    await _reconcileLww(uid, _kPlans, 'plans', 'plans');
    await _reconcileLww(uid, _kChecks, 'checks', 'checks');
  }

  // 각 화해는 클라우드 로드(await)를 먼저 끝낸 뒤 로컬을 읽고, 병합·로컬 쓰기까지
  // await 없이 잇는다. 로컬 읽기와 쓰기 사이에 await가 끼면 그 사이의 사용자 쓰기
  // (응시 제출·열람·수동 체크)를 stale 스냅샷이 덮어 유실된다(CODE-D-004).
  // 로컬 쓰기 뒤의 setDoc await는 무해하다 — 이후 로컬을 다시 쓰지 않는다.

  Future<void> _reconcileAttempts(String uid) async {
    final cloud = await _cloud.loadCollection(uid, 'attempts');
    final local = _readJsonList(_kHistory)
        .whereType<Map<String, dynamic>>()
        .map(AttemptRecord.fromJson)
        .toList();
    final r = mergeAttempts(local, cloud);
    _writeIfChanged(
        _kHistory, jsonEncode(r.merged.map((e) => e.toJson()).toList()));
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'attempts', e.key, e.value);
    }
  }

  Future<void> _reconcileViewed(String uid) async {
    final cloud = await _cloud.loadCollection(uid, 'viewed');
    final raw = _readJsonMap(_kViewed);
    final local = <String, Set<String>>{
      for (final e in raw.entries)
        e.key: (e.value is List ? (e.value as List) : const [])
            .map((x) => x.toString())
            .toSet(),
    };
    final r = mergeViewed(local, cloud);
    _writeIfChanged(_kViewed,
        jsonEncode({for (final e in r.merged.entries) e.key: e.value.toList()}));
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'viewed', e.key, e.value);
    }
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
