import 'package:flutter/material.dart';

import '../data/study_plan_store.dart';
import '../models/certification.dart';
import '../models/study_plan.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'plan/plan_agenda.dart';
import 'plan/plan_create_form.dart';

// 기존 import 경로 보존: planSummary/PlanSummary는 plan_page에서 계속 보인다.
export 'plan/plan_summary.dart' show PlanSummary, planSummary;

/// 학습 일정 화면. 플랜이 없으면 생성 폼, 있으면 어젠다(Task 7).
/// 폼·어젠다 위젯은 `pages/plan/`(PR4 분해), 이 파일은 전환 골격만 가진다.
class PlanPage extends StatefulWidget {
  const PlanPage({super.key, required this.cert, this.backend});
  final Certification cert;
  final KvBackend? backend;

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late final _store = StudyPlanStore(backend: widget.backend);
  StudyPlan? _plan;
  late final String _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now().toIso8601String().substring(0, 10);
    _plan = _store.planFor(widget.cert.code);
  }

  @override
  void didUpdateWidget(covariant PlanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cert.code != widget.cert.code) {
      setState(() => _plan = _store.planFor(widget.cert.code));
    }
  }

  void _onSaved(StudyPlan p) {
    _store.save(p);
    setState(() => _plan = p);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      // extend 없음(인벤토리 §5 재량 결정 3): 본문 NestedScrollView의 내부
      // sticky 헤더(88px)가 글래스 헤더 밑으로 핀 고정되면 겹침 충돌.
      appBar: AppHeader.document(
        sectionLabel: widget.cert.code,
        title: '학습 일정',
      ),
      body: _plan == null
          ? PlanCreateForm(
              cert: widget.cert, today: _today, onSaved: _onSaved)
          : PlanAgenda(
              cert: widget.cert,
              plan: _plan!,
              today: _today,
              onEdit: () => setState(() => _plan = null),
              onChanged: (p) => _onSaved(p),
              backend: widget.backend),
    );
  }
}
