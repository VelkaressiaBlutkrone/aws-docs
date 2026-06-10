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
    return {for (final e in m.entries) e.key.toString(): (e.value as num).toInt()};
  }

  void _writeMeta(String section, Map<String, int> data) {
    final all = _readJsonMap(_kMeta);
    all[section] = data;
    _local.write(_kMeta, jsonEncode(all));
  }

  /// 로그인 직후 4종 양방향 화해.
  Future<void> reconcileAll(String uid) async {
    await _reconcileAttempts(uid);
    await _reconcileViewed(uid);
    await _reconcileLww(uid, _kPlans, 'plans', 'plans');
    await _reconcileLww(uid, _kChecks, 'checks', 'checks');
  }

  Future<void> _reconcileAttempts(String uid) async {
    final local = _readJsonList(_kHistory)
        .map((e) => AttemptRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    final cloud = await _cloud.loadCollection(uid, 'attempts');
    final r = mergeAttempts(local, cloud);
    _local.write(_kHistory, jsonEncode(r.merged.map((e) => e.toJson()).toList()));
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'attempts', e.key, e.value);
    }
  }

  Future<void> _reconcileViewed(String uid) async {
    final raw = _readJsonMap(_kViewed);
    final local = <String, Set<String>>{
      for (final e in raw.entries)
        e.key: ((e.value as List?) ?? const []).map((x) => x.toString()).toSet(),
    };
    final cloud = await _cloud.loadCollection(uid, 'viewed');
    final r = mergeViewed(local, cloud);
    _local.write(_kViewed,
        jsonEncode({for (final e in r.merged.entries) e.key: e.value.toList()}));
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'viewed', e.key, e.value);
    }
  }

  Future<void> _reconcileLww(
      String uid, String localKey, String collection, String metaSection) async {
    final rawLocal = _readJsonMap(localKey);
    final local = <String, Map<String, dynamic>>{
      for (final e in rawLocal.entries)
        e.key: Map<String, dynamic>.from(e.value as Map),
    };
    var meta = _meta(metaSection);
    // 사이드카 없는 기존 로컬 엔티티는 now로 스탬프(클라우드 stale가 덮지 않게).
    final now = _now();
    for (final cert in local.keys) {
      meta.putIfAbsent(cert, () => now);
    }
    final cloud = await _cloud.loadCollection(uid, collection);
    final r = mergeLww(local, meta, cloud);
    _local.write(localKey, jsonEncode(r.merged));
    _writeMeta(metaSection, r.mergedMeta);
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, collection, e.key, e.value);
    }
  }
}
