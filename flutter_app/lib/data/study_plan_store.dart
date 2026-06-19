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

  void clearAll() => _b.write(_key, '');
}
