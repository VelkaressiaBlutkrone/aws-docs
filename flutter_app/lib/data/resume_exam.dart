import 'content_index.dart' show certHasContent;
import 'site_data.dart';
import 'exam_session_store.dart';
import 'local_kv.dart';

/// 진행 중인 자격증 모의고사 1건(UX-4). 홈·자격증 상세의 "이어서 풀기" 카드가 쓴다.
class ResumableExam {
  const ResumableExam({
    required this.certCode,
    required this.examId,
    required this.weighted,
    required this.remainingSec,
  });

  final String certCode;
  final String examId;

  /// 약점 집중 모의고사(`-weak`)인지. false면 통합(`-mock`).
  final bool weighted;

  /// 남은 초. **시작 시각을 읽을 수 없으면 `null`** — 판단 불가를 "0분"으로 적으면
  /// 거짓말이 되므로 라벨에서 생략한다(`ExamSessionStore.clearExpired`와 같은 규율).
  final int? remainingSec;

  String get route =>
      '/cert/$certCode/exam${weighted ? '/weak' : ''}';

  String get title => weighted ? '약점 집중 모의고사' : '통합 모의고사';
}

/// 남은 시간 라벨. 카드는 흘깃 보는 곳이라 러너의 `mm:ss`를 쓰지 않는다 — 90분
/// 시험의 `89:30`은 시·분으로 잘못 읽힌다. 1분 미만은 숫자로 속이지 않는다.
String remainingExamLabel(int? remainingSec) {
  if (remainingSec == null) return '진행 중';
  if (remainingSec < 60) return '남은 1분 미만';
  final h = remainingSec ~/ 3600;
  final m = (remainingSec % 3600) ~/ 60;
  if (h == 0) return '남은 $m분';
  return m == 0 ? '남은 $h시간' : '남은 $h시간 $m분';
}

/// 한 자격증의 진행 중 통합·약점 모의고사. examId는 결정적이라 키를 열거하지 않는다
/// (`study_reset.examIdsForCert`와 같은 규약). **Task 단위 세션은 보지 않는다** —
/// 홈이 자격증 12개를 돌므로, 2키로 묶어야 조회가 자격증당 2건에 머문다.
///
/// ⚠️ 만료 세션을 걸러 내는 것은 여기 책임이다. `clearExpired`는 시험 페이지 진입에서만
/// 돌고(`cert_exam_page`) 홈·상세는 그 경로를 타지 않으므로, 남은 시간을 직접 본다.
List<ResumableExam> resumableExamsForCert(
  String certCode, {
  KvBackend? backend,
  DateTime Function()? now,
}) {
  final store = ExamSessionStore(backend: backend ?? defaultBackend());
  final clock = (now ?? DateTime.now)();
  final out = <ResumableExam>[];
  for (final weighted in const [false, true]) {
    final examId = 'exam:$certCode-${weighted ? 'weak' : 'mock'}';
    final snapshot = store.loadSnapshot(examId); // 퇴화 스냅샷은 여기서 걸러진다
    if (snapshot == null) continue;
    final startedAt = DateTime.tryParse(snapshot.startedAtIso);
    int? remaining;
    if (startedAt != null) {
      remaining = snapshot.durationSec -
          clock.difference(startedAt).inSeconds;
      if (remaining <= 0) continue; // 만료 — 카드를 띄우지 않는다
    }
    out.add(ResumableExam(
      certCode: certCode,
      examId: examId,
      weighted: weighted,
      remainingSec: remaining,
    ));
  }
  return out;
}

/// 콘텐츠가 있는 전 자격증의 진행 중 모의고사(홈). 콘텐츠가 없는 자격증은 시험 화면을
/// 열 수 없으므로 카드도 만들지 않는다.
List<ResumableExam> resumableExamsAll({
  KvBackend? backend,
  DateTime Function()? now,
}) {
  final b = backend ?? defaultBackend();
  return [
    for (final cert in certifications)
      if (certHasContent(cert.code))
        ...resumableExamsForCert(cert.code, backend: b, now: now),
  ];
}
