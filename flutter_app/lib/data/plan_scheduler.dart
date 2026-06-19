import 'content_index.dart';
import '../models/study_plan.dart';

// --- 날짜 헬퍼: UTC 기반(DST 무관·결정적), 'YYYY-MM-DD' 문자열만 다룬다 ---
DateTime _d(String iso) {
  final p = iso.split('-');
  return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String _isoOf(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// iso에 n일 더한 'YYYY-MM-DD'.
String addDays(String iso, int n) => _isoOf(_d(iso).add(Duration(days: n)));

/// b - a (일수). 같은 날=0.
int daysBetween(String a, String b) => _d(b).difference(_d(a)).inDays;

class PlanBuildResult {
  const PlanBuildResult({required this.items, required this.warnings});
  final List<PlanItem> items;
  final List<String> warnings;
}

/// 미완 항목만 [today, lastDay] 창에 단계 순서 유지한 채 재배치.
/// 완료 항목은 날짜를 보존한다. 사용자 명시 동작(자동 호출 금지).
PlanBuildResult redistribute(
  StudyPlan plan,
  String todayIso,
  Set<String> doneItemIds,
) {
  final lastDay = plan.mode == PlanMode.examDate
      ? addDays(plan.endIso, -1)
      : plan.endIso;
  final winStart =
      daysBetween(plan.startIso, todayIso) > 0 ? todayIso : plan.startIso;
  if (daysBetween(winStart, lastDay) < 0) {
    return PlanBuildResult(
        items: [...plan.items], warnings: ['남은 기간이 없어 재분배할 수 없습니다.']);
  }
  final windowDays = daysBetween(winStart, lastDay) + 1;

  final done = plan.items.where((i) => doneItemIds.contains(i.id)).toList();
  // plan.items는 이미 단계 순서 → todo도 그 순서 보존.
  final todo = plan.items.where((i) => !doneItemIds.contains(i.id)).toList();

  final out = <PlanItem>[...done];
  final k = todo.length;
  // k==0(전부 완료)이면 루프는 건너뛰고 out은 완료 항목(복사본)만 — 정상.
  for (var i = 0; i < k; i++) {
    var off = windowDays <= 1 ? 0 : (i * windowDays ~/ k);
    if (off > windowDays - 1) off = windowDays - 1;
    out.add(PlanItem(
      id: todo[i].id,
      dateIso: addDays(winStart, off),
      type: todo[i].type,
      phase: todo[i].phase,
      refId: todo[i].refId,
    ));
  }
  out.sort((a, b) => a.dateIso.compareTo(b.dateIso));

  final warnings = <String>[];
  if (k > windowDays) {
    warnings.add('남은 $k개를 $windowDays일에 재배치 — 하루 평균 약 ${(k / windowDays).ceil()}개.');
  }
  return PlanBuildResult(items: out, warnings: warnings);
}

/// 단계형 분배(순수·결정적). 부작용 없음.
PlanBuildResult buildPlan({
  required String planId,
  required List<ContentEntry> content,
  required String startIso,
  required String endIso,
  required PlanMode mode,
}) {
  if (content.isEmpty) {
    return PlanBuildResult(
        items: [], warnings: ['이 자격증에는 학습 콘텐츠가 없습니다.']);
  }
  final lastDay = mode == PlanMode.examDate ? addDays(endIso, -1) : endIso;
  if (daysBetween(startIso, lastDay) < 0) {
    return PlanBuildResult(
        items: [], warnings: ['기간이 올바르지 않습니다(종료일이 시작일보다 빠릅니다).']);
  }
  final windowDays = daysBetween(startIso, lastDay) + 1; // inclusive, >=1
  final hasQ = content.any((e) => e.hasQuestions);
  final warnings = <String>[];
  if (!hasQ) {
    warnings.add('이 자격증은 아직 검증 문항이 없어 문서 읽기 일정만 생성됩니다(퀴즈·모의고사 제외).');
  }

  final segs = _segmentDays(windowDays, hasQ); // [learn, practice, mock, reinforce]
  final starts = <int>[
    0,
    segs[0],
    segs[0] + segs[1],
    segs[0] + segs[1] + segs[2],
  ];

  final items = <PlanItem>[];

  _spread(items, planId, PlanItemType.doc, PlanPhase.learn,
      [for (final e in content) e.taskId],
      starts[0], segs[0], windowDays, startIso);

  if (hasQ) {
    _spread(items, planId, PlanItemType.quiz, PlanPhase.practice,
        [for (final e in content) if (e.hasQuestions) e.taskId],
        starts[1], segs[1], windowDays, startIso);

    _spread(items, planId, PlanItemType.mockExam, PlanPhase.mock,
        List<String?>.filled(_mockCount(segs[2]), null),
        starts[2], segs[2], windowDays, startIso);

    _spread(items, planId, PlanItemType.weakExam, PlanPhase.reinforce,
        <String?>[null], starts[3], segs[3], windowDays, startIso);

    _spread(items, planId, PlanItemType.finalReview, PlanPhase.reinforce,
        <String?>[null], starts[3], segs[3], windowDays, startIso,
        placeAtEnd: true);
  }

  if (items.length > windowDays) {
    final perDay = (items.length / windowDays).ceil();
    warnings.add('하루 평균 약 $perDay개 — 일정이 빡빡합니다. 기간을 늘리거나 항목을 줄이세요.');
  }
  return PlanBuildResult(items: items, warnings: warnings);
}

/// 단계 일수 분할(45/20/20/15). 합 = windowDays 보존. docs-only면 learn에 전부.
List<int> _segmentDays(int windowDays, bool hasQ) {
  if (!hasQ) return [windowDays, 0, 0, 0];
  final learn = (windowDays * 0.45).round();
  final practice = (windowDays * 0.20).round();
  final mock = (windowDays * 0.20).round();
  final reinforce = windowDays - learn - practice - mock;
  // reinforce ≥ 0 by construction (잔여 = n - round(0.85n) ≥ 0; n<10 열거 확인, n≥10 0.15n-1.5≥0)
  assert(reinforce >= 0);
  return [learn, practice, mock, reinforce];
}

/// 통합 모의고사 횟수: 최소 3(약점 게이트), 최대 6.
int _mockCount(int mockSpan) {
  final n = (mockSpan / 2).floor();
  return n.clamp(3, 6);
}

/// refs(K개)를 [phaseStart, phaseStart+phaseSpan) 일수에 균등 배치.
/// placeAtEnd=true면 단계 마지막 날에. off는 [0, windowDays-1]로 clamp.
void _spread(
  List<PlanItem> out,
  String planId,
  PlanItemType type,
  PlanPhase phase,
  List<String?> refs,
  int phaseStart,
  int phaseSpan,
  int windowDays,
  String startIso, {
  bool placeAtEnd = false,
}) {
  final k = refs.length;
  if (k == 0) return;
  for (var i = 0; i < k; i++) {
    int off;
    if (placeAtEnd) {
      off = phaseStart + (phaseSpan <= 0 ? 0 : phaseSpan - 1);
    } else if (phaseSpan <= 1) {
      off = phaseStart;
    } else {
      off = phaseStart + (i * phaseSpan ~/ k);
    }
    if (off > windowDays - 1) off = windowDays - 1;
    final refId = refs[i];
    out.add(PlanItem(
      id: planItemId(planId, type, refId, i),
      dateIso: addDays(startIso, off),
      type: type,
      phase: phase,
      refId: refId,
    ));
  }
}

/// 수동 일정의 items 생성(순수). docs/practice는 taskIds를 기간에 균등 분배,
/// 시험류(mock/weak/review)는 refId 없는 단일 항목.
List<PlanItem> buildManualPlanItems({
  required String planId,
  required PlanItemType planType,
  required List<String> taskIds,
  required String startIso,
  required String endIso,
}) {
  final windowDays = daysBetween(startIso, endIso) + 1; // inclusive, >=1
  final phase = switch (planType) {
    PlanItemType.doc => PlanPhase.learn,
    PlanItemType.quiz => PlanPhase.practice,
    PlanItemType.mockExam => PlanPhase.mock,
    _ => PlanPhase.reinforce,
  };
  final List<String?> refs =
      (planType == PlanItemType.doc || planType == PlanItemType.quiz)
          ? taskIds
          : <String?>[null];
  final out = <PlanItem>[];
  final k = refs.length;
  for (var i = 0; i < k; i++) {
    var off = (windowDays <= 1 || k <= 1) ? 0 : (i * windowDays ~/ k);
    if (off > windowDays - 1) off = windowDays - 1;
    out.add(PlanItem(
      id: planItemId(planId, planType, refs[i], i),
      dateIso: addDays(startIso, off),
      type: planType,
      phase: phase,
      refId: refs[i],
    ));
  }
  return out;
}
