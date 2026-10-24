import 'question.dart';

/// 시험 시작 시점의 출제 문항을 통째로 담는 불변 스냅샷(설계 2026-10-24 §4.1).
///
/// 복원이 **현재 에셋을 전혀 읽지 않도록** 문항 전문을 들고 간다. 그래서 진행 중 시험은
/// 콘텐츠 릴리스를 가로질러도 시작 시점 문항·보기·채점·해설 그대로 유지된다.
///
/// 보기는 **이미 표시 순서가 적용된 상태**로 저장한다(`Question.withOptionOrder`의 결과)
/// — 그래서 별도의 `optionOrders`가 필요 없다.
class ExamSnapshot {
  const ExamSnapshot({
    required this.examId,
    required this.certId,
    required this.taskId,
    required this.nonce,
    required this.startedAtIso,
    required this.durationSec,
    required this.questions,
  });

  final String examId;
  final String certId;
  final String taskId;

  /// 세대 식별자. 진행 레코드가 같은 값을 들고 다녀야 짝으로 인정된다(설계 §4.4.1)
  /// — 키를 둘로 나누면서 사라진 원자성을 이 값이 대신한다.
  final String nonce;

  final String startedAtIso;
  final int durationSec;

  /// 출제 문항(표시 순서 적용 완료).
  final List<Question> questions;

  Map<String, dynamic> toJson() => {
        'examId': examId,
        'certId': certId,
        'taskId': taskId,
        'nonce': nonce,
        'startedAtIso': startedAtIso,
        'durationSec': durationSec,
        'questions': [for (final q in questions) q.toJson()],
      };

  /// ⚠️ **`QuestionBank.fromJson`을 쓰지 않는다**(설계 §4.2). 그 생성자는
  /// `.where((q) => q.verified)`로 비검증 문항을 걸러내는데, 스냅샷은 철회된 문항도
  /// 끝까지 출제·채점해야 하므로 여기서 걸리면 세션이 반쪽이 된다.
  factory ExamSnapshot.fromJson(Map<String, dynamic> j) => ExamSnapshot(
        examId: (j['examId'] ?? '').toString(),
        certId: (j['certId'] ?? '').toString(),
        taskId: (j['taskId'] ?? '').toString(),
        nonce: (j['nonce'] ?? '').toString(),
        startedAtIso: (j['startedAtIso'] ?? '').toString(),
        durationSec: (j['durationSec'] as num?)?.toInt() ?? 0,
        questions: [
          for (final e in (j['questions'] as List?) ?? const [])
            Question.fromJson(e as Map<String, dynamic>),
        ],
      );
}

/// 시험 중 매 상호작용마다 갱신되는 가변부(설계 §4.4).
///
/// 스냅샷과 달리 작고 자주 쓰인다 — 그래서 키를 나눴다. `submitted`는 담지 않는다:
/// 앱이 그 값을 저장한 적이 없다(설계 §4.4.2).
class ExamProgress {
  const ExamProgress({
    required this.examId,
    required this.nonce,
    required this.index,
    required this.picked,
    required this.flagged,
  });

  final String examId;
  final String nonce;
  final int index;
  final Map<int, int> picked;
  final List<int> flagged;

  Map<String, dynamic> toJson() => {
        'examId': examId,
        'nonce': nonce,
        'index': index,
        'picked': {
          for (final e in picked.entries) e.key.toString(): e.value,
        },
        'flagged': flagged,
      };

  factory ExamProgress.fromJson(Map<String, dynamic> j) {
    final picked = <int, int>{};
    final rawPicked = j['picked'];
    if (rawPicked is Map) {
      rawPicked.forEach((k, v) {
        final ki = int.tryParse(k.toString());
        final vi = v is num ? v.toInt() : int.tryParse(v.toString());
        if (ki != null && vi != null) picked[ki] = vi; // 손상 항목은 건너뛴다
      });
    }
    return ExamProgress(
      examId: (j['examId'] ?? '').toString(),
      nonce: (j['nonce'] ?? '').toString(),
      index: (j['index'] as num?)?.toInt() ?? 0,
      picked: picked,
      flagged: [
        for (final e in (j['flagged'] as List?) ?? const [])
          if (e is num) e.toInt(),
      ],
    );
  }

  ExamProgress copyWith({int? index, Map<int, int>? picked, List<int>? flagged}) =>
      ExamProgress(
        examId: examId,
        nonce: nonce,
        index: index ?? this.index,
        picked: picked ?? this.picked,
        flagged: flagged ?? this.flagged,
      );
}

/// 복원 직전 진행 기록을 스냅샷 문항에 맞춰 정화한다.
///
/// 손상·개정 잔재로 범위를 벗어난 값이 들어오면 **그 값만 버린다** — 세션 전체를
/// 폐기하지 않는다(반목표: 오히려 세션을 잃는 것). 표시 인덱스가 다른 보기를 가리키는
/// 무성 손상을 막는 마지막 방어선이다.
ExamProgress sanitizeProgress(ExamProgress p, List<Question> questions) {
  final n = questions.length;
  final picked = <int, int>{};
  for (final e in p.picked.entries) {
    if (e.key < 0 || e.key >= n) continue; // 문항 범위 밖
    if (e.value < 0 || e.value >= questions[e.key].options.length) continue;
    picked[e.key] = e.value;
  }
  return p.copyWith(
    index: n == 0 ? 0 : p.index.clamp(0, n - 1),
    picked: picked,
    flagged: [
      for (final i in p.flagged)
        if (i >= 0 && i < n) i,
    ],
  );
}
