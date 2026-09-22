import 'dart:convert';

import '../models/study_plan.dart';
import 'local_kv.dart';

export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 자격증별 학습 플랜 '리스트'를 영속한다(v2). v1(단일 plan)을 1회 자동 이관한다.
/// 손상 데이터는 빈 리스트(기존 store 관례).
class StudyPlanStore {
  StudyPlanStore({KvBackend? backend}) : _b = backend ?? defaultBackend() {
    _migrateV1IfNeeded();
  }

  final KvBackend _b;
  static const _key = 'awsdocs.plan.v2';
  static const _keyV1 = 'awsdocs.plan.v1';

  Map<String, dynamic> _read() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  void _write(Map<String, dynamic> m) => _b.write(_key, jsonEncode(m));

  /// v2가 비어있고 v1(단일 plan 맵)이 있으면 리스트 형식으로 1회 이관한다.
  /// 기존 plan에 id/label/source(auto)를 부여한다. 진행은 새 store로 시작한다.
  void _migrateV1IfNeeded() {
    if ((_b.read(_key) ?? '').isNotEmpty) return; // 이미 v2 있음
    final rawV1 = _b.read(_keyV1);
    if (rawV1 == null || rawV1.isEmpty) return;
    try {
      final v1 = jsonDecode(rawV1) as Map<String, dynamic>;
      final out = <String, dynamic>{};
      for (final e in v1.entries) {
        if (e.value is! Map) continue;
        final j = Map<String, dynamic>.from(e.value as Map);
        final created = (j['createdIso'] ?? '').toString();
        j['id'] = planIdOf(e.key, created, 0);
        j['label'] = '기존 일정';
        j['source'] = PlanSource.auto.name;
        out[e.key] = [j];
      }
      _write(out);
    } catch (_) {/* 손상 v1 무시 */}
  }

  List<StudyPlan> plansFor(String certCode) {
    final list = _read()[certCode];
    if (list is! List) return [];
    final out = <StudyPlan>[];
    for (final j in list) {
      if (j is! Map<String, dynamic>) continue;
      try {
        final p = StudyPlan.fromJson(j);
        if (p.startIso.isEmpty || p.endIso.isEmpty) continue; // 손상 plan 무시
        out.add(p);
      } catch (_) {/* 손상 항목 무시 */}
    }
    return out;
  }

  void add(StudyPlan plan) {
    final m = _read();
    final list = (m[plan.certCode] is List)
        ? List<dynamic>.from(m[plan.certCode] as List)
        : <dynamic>[];
    final id = plan.id.isNotEmpty
        ? plan.id
        : planIdOf(plan.certCode, plan.createdIso, list.length);
    // items의 itemId를 최종 planId 기반으로 재매핑(자동·수동 일정 정합).
    final reindexed = [
      for (var i = 0; i < plan.items.length; i++)
        PlanItem(
          id: planItemId(id, plan.items[i].type, plan.items[i].refId, i),
          dateIso: plan.items[i].dateIso,
          type: plan.items[i].type,
          phase: plan.items[i].phase,
          refId: plan.items[i].refId,
        ),
    ];
    final withId = StudyPlan(
      id: id,
      label: plan.label,
      certCode: plan.certCode,
      startIso: plan.startIso,
      endIso: plan.endIso,
      mode: plan.mode,
      createdIso: plan.createdIso,
      source: plan.source,
      planType: plan.planType,
      taskIds: plan.taskIds,
      items: reindexed,
    );
    list.add(withId.toJson());
    m[plan.certCode] = list;
    _write(m);
  }

  void update(StudyPlan plan) {
    final m = _read();
    final list = (m[plan.certCode] is List)
        ? List<dynamic>.from(m[plan.certCode] as List)
        : <dynamic>[];
    for (var i = 0; i < list.length; i++) {
      final j = list[i];
      if (j is Map && j['id'] == plan.id) {
        list[i] = plan.toJson();
        break;
      }
    }
    m[plan.certCode] = list;
    _write(m);
  }

  void removePlan(String certCode, String planId) {
    final m = _read();
    final list = (m[certCode] is List)
        ? List<dynamic>.from(m[certCode] as List)
        : <dynamic>[];
    list.removeWhere((j) => j is Map && j['id'] == planId);
    if (list.isEmpty) {
      m.remove(certCode);
    } else {
      m[certCode] = list;
    }
    _write(m);
  }

  void clearCert(String certCode) {
    final m = _read()..remove(certCode);
    _write(m);
  }

  /// 모든 자격증의 일정을 planId로 색인한다(동기용).
  Map<String, StudyPlan> byId() {
    final out = <String, StudyPlan>{};
    for (final cert in _read().keys) {
      for (final p in plansFor(cert)) {
        out[p.id] = p;
      }
    }
    return out;
  }

  /// planId 기준 추가·갱신(동기 병합 결과 반영). id가 이미 있으면 교체한다.
  /// [add]와 달리 items를 재매핑하지 않는다 — 동기는 내용을 그대로 옮긴다.
  void upsert(StudyPlan plan) {
    final m = _read();
    final list = (m[plan.certCode] is List)
        ? List<dynamic>.from(m[plan.certCode] as List)
        : <dynamic>[];
    final i = list.indexWhere((j) => j is Map && j['id'] == plan.id);
    if (i >= 0) {
      list[i] = plan.toJson();
    } else {
      list.add(plan.toJson());
    }
    m[plan.certCode] = list;
    _write(m);
  }

  /// planId로 삭제한다(자격증 자동 판별).
  void removeById(String planId) {
    final m = _read();
    for (final cert in m.keys.toList()) {
      final list =
          (m[cert] is List) ? List<dynamic>.from(m[cert] as List) : <dynamic>[];
      final before = list.length;
      list.removeWhere((j) => j is Map && j['id'] == planId);
      if (list.length == before) continue;
      if (list.isEmpty) {
        m.remove(cert);
      } else {
        m[cert] = list;
      }
    }
    _write(m);
  }

  /// 전부 삭제. v2는 ''가 아니라 빈 맵으로 남긴다 — v2가 비면 다음 생성 때
  /// [_migrateV1IfNeeded]가 v1(로컬 잔존분 또는 클라우드 plans 동기가 되돌려 놓은 것)을
  /// 다시 이관해 레거시 플랜이 되살아난다. 레거시 v1 원본도 함께 지운다.
  void clearAll() {
    _write(<String, dynamic>{});
    _b.write(_keyV1, '');
  }
}
