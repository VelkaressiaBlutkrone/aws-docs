import 'package:flutter/material.dart';

import '../data/history_store.dart';
import '../data/plan_progress_store.dart';
import '../data/study_plan_store.dart';
import '../models/certification.dart';
import '../models/study_plan.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'plan/plan_agenda.dart';
import 'plan/plan_create_form.dart';
import 'plan/plan_list_view.dart';

// 기존 import 경로 보존: planSummary/PlanSummary는 plan_page에서 계속 보인다.
export 'plan/plan_summary.dart' show PlanSummary, planSummary;

/// 학습 일정 화면(멀티 일정). 일정 목록 → 선택(어젠다) / 생성(자동·수동) / 삭제.
class PlanPage extends StatefulWidget {
  const PlanPage({super.key, required this.cert, this.backend});
  final Certification cert;
  final KvBackend? backend;

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late final _store = StudyPlanStore(backend: widget.backend);
  late final _progress = PlanProgressStore(backend: widget.backend);
  late final _history = HistoryStore(backend: widget.backend);
  late List<StudyPlan> _plans;
  StudyPlan? _selected;
  bool _creating = false;
  late final String _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now().toIso8601String().substring(0, 10);
    _plans = _store.plansFor(widget.cert.code);
  }

  @override
  void didUpdateWidget(covariant PlanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cert.code != widget.cert.code) {
      setState(() {
        _plans = _store.plansFor(widget.cert.code);
        _selected = null;
        _creating = false;
      });
    }
  }

  void _reload() => _plans = _store.plansFor(widget.cert.code);

  void _onSaved(StudyPlan p) {
    _store.add(p);
    setState(() {
      _reload();
      _creating = false;
    });
  }

  void _delete(StudyPlan p) {
    _store.removePlan(widget.cert.code, p.id);
    _progress.clearPlan(p.id);
    setState(() {
      _reload();
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final Widget body;
    if (_creating) {
      body =
          PlanCreateForm(cert: widget.cert, today: _today, onSaved: _onSaved);
    } else if (_selected != null) {
      body = PlanAgenda(
        cert: widget.cert,
        plan: _selected!,
        today: _today,
        onEdit: () => setState(() => _creating = true),
        onChanged: (p) {
          _store.update(p);
          setState(() {
            _reload();
            _selected =
                _plans.where((x) => x.id == p.id).cast<StudyPlan?>().firstWhere(
                      (x) => true,
                      orElse: () => p,
                    );
          });
        },
        onDelete: () => _delete(_selected!),
        backend: widget.backend,
      );
    } else {
      body = PlanListView(
        plans: _plans,
        progress: _progress,
        history: _history.all(),
        today: _today,
        onOpen: (p) => setState(() => _selected = p),
        onCreate: () => setState(() => _creating = true),
      );
    }
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppHeader.document(
        sectionLabel: widget.cert.code,
        title: '학습 일정',
      ),
      body: body,
    );
  }
}
