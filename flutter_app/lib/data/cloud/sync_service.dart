import 'dart:convert';

import '../viewed_docs_store.dart'; // KvBackend도 함께 re-export 한다
import '../../models/attempt_record.dart';
import '../../models/study_plan.dart';
import '../study_plan_store.dart';
import 'cloud_store.dart';
import 'sync_merge.dart';
import 'sync_meta.dart';
import 'sync_three_way.dart';

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
    var marks = await _reconcileDeletions(uid);
    await _reconcileAttempts(uid, marks.resetAt);
    await _reconcileViewed(uid, marks.resetAt);
    final newlyDeleted = await _reconcilePlans(uid, marks);
    if (newlyDeleted.isNotEmpty) {
      // 이번 회차에 생긴 삭제를 표식으로 올리고, 뒤따르는 화해가 그 표식을 보게 한다.
      marks = await _reconcileDeletions(uid, newPlanMarks: newlyDeleted);
    }
    await _reconcileLww(uid, _kChecks, 'checks', 'checks'); // 레거시(PR3에서 제거)
  }

  /// meta/deletions 화해: 자격증 초기화 표식과 일정 삭제 표식을 필드별 늦은 시각으로
  /// 합쳐 양쪽에 반영하고, 이번 회차에 적용할 표식을 돌려준다.
  /// [newPlanMarks]는 이번 회차에 로컬에서 새로 지운 일정.
  Future<({Map<String, int> resetAt, Map<String, int> plans})>
      _reconcileDeletions(String uid,
          {Map<String, int> newPlanMarks = const {}}) async {
    final doc = (await _cloud.loadCollection(uid, 'meta'))['deletions'] ??
        const <String, dynamic>{};
    final cloudReset = _intMapOf(doc['resetAt']);
    final cloudPlans = _intMapOf(doc['plans']);
    final meta = SyncMeta(_local);

    final mergedReset = mergeResetMarks(meta.resetAt, cloudReset);
    final mergedPlans = mergeResetMarks(
        mergeResetMarks(meta.deletedPlans, cloudPlans), newPlanMarks);

    if (!_sameMarks(mergedReset, meta.resetAt)) meta.resetAt = mergedReset;
    if (!_sameMarks(mergedPlans, meta.deletedPlans)) {
      meta.deletedPlans = mergedPlans;
    }
    if (!_sameMarks(mergedReset, cloudReset) ||
        !_sameMarks(mergedPlans, cloudPlans)) {
      await _cloud.setDoc(uid, 'meta', 'deletions', {
        ...doc,
        'resetAt': mergedReset,
        'plans': mergedPlans,
      });
    }
    return (resetAt: mergedReset, plans: mergedPlans);
  }

  static Map<String, int> _intMapOf(Object? v) {
    if (v is! Map) return {};
    return {
      for (final e in v.entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
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

  /// 일정(v2) 화해. 문서마다 base(마지막 동기 내용)와 비교해 3-way로 판정한다.
  /// 클라우드 쓰기는 로컬 쓰기를 모두 끝낸 뒤에 모아서 한다(위 CODE-D-004 규칙).
  /// 이번 회차에 로컬에서 새로 지운 일정(planId → 시각)을 돌려준다.
  Future<Map<String, int>> _reconcilePlans(String uid,
      ({Map<String, int> resetAt, Map<String, int> plans}) marks) async {
    final cloud = {...await _cloud.loadCollection(uid, 'plans')};

    // 레거시 문서(id 없음, 문서 id가 자격증 코드 — 옛 LWW 경로가 올린 것)를
    // planId 문서로 옮긴다. 클라우드만 건드리므로 로컬 구간보다 앞이다.
    for (final e in cloud.entries.toList()) {
      if (e.value['id'] != null) continue;
      final cert = (e.value['certCode'] ?? e.key).toString();
      final created = (e.value['createdIso'] ?? '').toString();
      final id = planIdOf(cert, created, 0);
      final moved = {
        ...e.value,
        'id': id,
        'label': '기존 일정',
        'source': PlanSource.auto.name,
        'updatedAtMs': (e.value['updatedAtMs'] as num?)?.toInt() ??
            (e.value['updatedAt'] as num?)?.toInt() ??
            0,
      }..remove('updatedAt');
      await _cloud.setDoc(uid, 'plans', id, moved);
      await _cloud.deleteDoc(uid, 'plans', e.key);
      cloud.remove(e.key);
      cloud[id] = moved;
    }

    final store = StudyPlanStore(backend: _local);
    final meta = SyncMeta(_local);
    final em = meta.entity('plans');
    final local = store.byId();

    final base = {...em.base};
    final updatedAt = {...em.updatedAt};
    final dirtyAt = {...em.dirtyAt};
    final toPush = <String, Map<String, dynamic>>{};
    final toDelete = <String>[];
    final newlyDeleted = <String, int>{};
    final now = _now();

    for (final id in {...local.keys, ...cloud.keys}) {
      final localDoc = local[id]?.toJson();
      final cloudRaw = cloud[id];
      final cloudDoc = cloudRaw == null
          ? null
          : (Map<String, dynamic>.from(cloudRaw)..remove('updatedAtMs'));
      final cloudMs = (cloudRaw?['updatedAtMs'] as num?)?.toInt() ?? 0;
      final cert = (localDoc ?? cloudDoc)?['certCode']?.toString() ?? '';
      final cut = mergedEffectiveResetAt(marks.resetAt, cert);
      // 마지막으로 아는 로컬 시각. 한 번도 동기된 적 없는 일정(base에 없음)은
      // 시각을 알 수 없어 표식으로 지우지 않는다 — 미동기 로컬 작업을 잃지 않는 쪽.
      final localTime = dirtyAt[id] ?? updatedAt[id] ?? 0;
      final localStale =
          localDoc != null && base.containsKey(id) && localTime < cut;

      if ((cloudRaw != null && cloudMs < cut) || localStale) {
        if (cloudRaw != null) toDelete.add(id);
        if (localStale) store.removeById(id);
        base.remove(id);
        updatedAt.remove(id);
        dirtyAt.remove(id);
        continue;
      }

      // 일정 삭제 표식: 클라우드 문서도 함께 정리한다(로컬은 판정이 지운다).
      if (marks.plans.containsKey(id) && cloudRaw != null) toDelete.add(id);

      // 로컬 변경을 처음 본 시각을 기록한다(둘 다 바뀐 경우의 비교 기준).
      if (localDoc != null &&
          base.containsKey(id) &&
          jsonEncode(localDoc) != jsonEncode(base[id]) &&
          dirtyAt[id] == null) {
        dirtyAt[id] = now;
      }

      switch (decideDoc(
        base: base[id],
        local: localDoc,
        cloud: cloudDoc,
        cloudUpdatedAtMs: cloudMs,
        localDirtyAtMs: dirtyAt[id] ?? 0,
        cloudDeleted: marks.plans.containsKey(id),
      )) {
        case DocAction.none:
          break;
        case DocAction.adoptCloud:
          store.upsert(StudyPlan.fromJson(cloudDoc!));
          base[id] = cloudDoc;
          updatedAt[id] = cloudMs;
          dirtyAt.remove(id);
          break;
        case DocAction.pushLocal:
          toPush[id] = {...localDoc!, 'updatedAtMs': now};
          base[id] = localDoc;
          updatedAt[id] = now;
          dirtyAt.remove(id);
          break;
        case DocAction.deleteLocal:
          store.removeById(id);
          base.remove(id);
          updatedAt.remove(id);
          dirtyAt.remove(id);
          break;
        case DocAction.deleteCloud:
          toDelete.add(id);
          newlyDeleted[id] = now;
          base.remove(id);
          updatedAt.remove(id);
          dirtyAt.remove(id);
          break;
      }
    }

    meta.setEntity('plans',
        EntityMeta(base: base, updatedAt: updatedAt, dirtyAt: dirtyAt));

    // 로컬 쓰기를 모두 끝낸 뒤 클라우드에 쓴다.
    for (final e in toPush.entries) {
      await _cloud.setDoc(uid, 'plans', e.key, e.value);
    }
    await _deleteUpTo(uid, 'plans', toDelete);
    return newlyDeleted;
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
