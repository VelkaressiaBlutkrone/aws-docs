/// 일정 항목 종류. finalReview = 마지막 '최종 점검'(앱 history 'review' 모드와 구분).
enum PlanItemType { doc, quiz, mockExam, weakExam, finalReview }

/// 단계형 분배의 단계.
enum PlanPhase { learn, practice, mock, reinforce }

/// 종료 정의 방식.
enum PlanMode { examDate, period }

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
  final String dateIso; // 'YYYY-MM-DD'
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
  });

  final String certCode;
  final String startIso; // 'YYYY-MM-DD'
  final String endIso; // examDate=시험일, period=학습 종료일
  final PlanMode mode;
  final String createdIso;
  final List<PlanItem> items;

  Map<String, dynamic> toJson() => {
        'certCode': certCode,
        'startIso': startIso,
        'endIso': endIso,
        'mode': mode.name,
        'createdIso': createdIso,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory StudyPlan.fromJson(Map<String, dynamic> j) => StudyPlan(
        certCode: (j['certCode'] ?? '').toString(),
        startIso: (j['startIso'] ?? '').toString(),
        endIso: (j['endIso'] ?? '').toString(),
        mode: _enumByName(PlanMode.values, j['mode'], PlanMode.period),
        createdIso: (j['createdIso'] ?? '').toString(),
        items: ((j['items'] as List?) ?? const [])
            .map((e) => PlanItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
