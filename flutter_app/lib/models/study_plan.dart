/// 일정 항목 종류. finalReview = 마지막 '최종 점검'(앱 history 'review' 모드와 구분).
enum PlanItemType { doc, quiz, mockExam, weakExam, finalReview }

/// 단계형 분배의 단계.
enum PlanPhase { learn, practice, mock, reinforce }

/// 종료 정의 방식.
enum PlanMode { examDate, period }

/// 일정 생성 방식 — auto(자동 분배) / manual(유형+범위 수동).
enum PlanSource { auto, manual }

/// 결정적 planId: certCode·생성일·순번.
String planIdOf(String certCode, String createdIso, int seq) =>
    '$certCode:$createdIso:$seq';

/// 결정적 itemId: planId 포함(일정 간 충돌 방지).
String planItemId(String planId, PlanItemType type, String? refId, int i) =>
    '$planId#${type.name}:${refId ?? ''}:$i';

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

/// 달력의 한 항목. id는 결정적(수동 체크 오버라이드 키로 안정적).
class PlanItem {
  const PlanItem({
    required this.id,
    required this.dateIso,
    required this.type,
    required this.phase,
    this.refId,
  });

  final String id;
  final String dateIso; // 'YYYY-MM-DD'; fromJson fallback은 '' — 파싱 전 검증 필요
  final PlanItemType type;
  final PlanPhase phase;
  final String? refId; // doc/quiz=taskId, 시험류=null

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'type': type.name,
        'phase': phase.name,
        'refId': refId,
      };

  factory PlanItem.fromJson(Map<String, dynamic> j) => PlanItem(
        id: (j['id'] ?? '').toString(),
        dateIso: (j['dateIso'] ?? '').toString(),
        type: _enumByName(PlanItemType.values, j['type'], PlanItemType.doc),
        phase: _enumByName(PlanPhase.values, j['phase'], PlanPhase.learn),
        refId: j['refId']?.toString(),
      );
}

/// 자격증별 단일 학습 플랜.
class StudyPlan {
  const StudyPlan({
    required this.certCode,
    required this.startIso,
    required this.endIso,
    required this.mode,
    required this.createdIso,
    required this.items,
    this.id = '',
    this.label = '',
    this.source = PlanSource.auto,
    this.planType,
    this.taskIds = const [],
  });

  final String id; // 일정 고유 ID(진행 스코프 키). 저장 시 store가 부여(planIdOf).
  final String label; // 표시명 (예: "1주차 문서")
  final String certCode;
  final String startIso; // 'YYYY-MM-DD'
  final String endIso; // examDate=시험일, period=학습 종료일
  final PlanMode mode;
  final String createdIso;
  final PlanSource source; // auto/manual — 편집 UI 분기
  final PlanItemType? planType; // manual 전용: 일정 유형
  final List<String> taskIds; // manual docs/practice 전용: 선택 Task
  final List<PlanItem> items;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'certCode': certCode,
        'startIso': startIso,
        'endIso': endIso,
        'mode': mode.name,
        'createdIso': createdIso,
        'source': source.name,
        'planType': planType?.name,
        'taskIds': taskIds,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory StudyPlan.fromJson(Map<String, dynamic> j) => StudyPlan(
        id: (j['id'] ?? '').toString(),
        label: (j['label'] ?? '').toString(),
        certCode: (j['certCode'] ?? '').toString(),
        startIso: (j['startIso'] ?? '').toString(),
        endIso: (j['endIso'] ?? '').toString(),
        mode: _enumByName(PlanMode.values, j['mode'], PlanMode.period),
        createdIso: (j['createdIso'] ?? '').toString(),
        source: _enumByName(PlanSource.values, j['source'], PlanSource.auto),
        planType: j['planType'] == null
            ? null
            : _enumByName(PlanItemType.values, j['planType'], PlanItemType.doc),
        taskIds: ((j['taskIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        items: ((j['items'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PlanItem.fromJson)
            .toList(),
      );
}
