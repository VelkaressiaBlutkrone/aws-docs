import 'content_index.dart';
import 'exam_session_store.dart';
import 'history_store.dart';
import 'plan_check_store.dart';
import 'study_plan_store.dart';
import 'viewed_docs_store.dart';

/// 학습 기록 초기화의 단일 진입점. localStorage 3계층(응시 이력·열람·진행 세션)을
/// 함께 정리해 오답노트·약점리포트·진행률·약점모의고사 게이트가 일관되게 리셋된다.
///
/// 한 자격증의 진행 중 시험 세션 examId는 결정적이다(키 열거 불필요):
///   통합/약점  `exam:{CODE}-mock` / `exam:{CODE}-weak`
///   Task 단위  `exam:` / `practice:` / `review:` + `{taskId}`
Iterable<String> examIdsForCert(String certCode) sync* {
  yield 'exam:$certCode-mock';
  yield 'exam:$certCode-weak';
  for (final e in contentFor(certCode)) {
    yield 'exam:${e.taskId}';
    yield 'practice:${e.taskId}';
    yield 'review:${e.taskId}';
  }
}

/// 한 자격증의 모든 학습 기록을 삭제한다(다른 자격증은 보존).
void resetCert(String certCode, {KvBackend? backend}) {
  final b = backend ?? defaultBackend();
  HistoryStore(backend: b).clearCert(certCode);
  ViewedDocsStore(backend: b).clearCert(certCode);
  StudyPlanStore(backend: b).clearCert(certCode);
  PlanCheckStore(backend: b).clearCert(certCode);
  final sessions = ExamSessionStore(backend: b);
  for (final id in examIdsForCert(certCode)) {
    sessions.clear(id);
  }
}

/// 모든 자격증의 모든 학습 기록을 삭제한다(공장 초기화).
void resetAll({KvBackend? backend}) {
  final b = backend ?? defaultBackend();
  HistoryStore(backend: b).clearAll();
  ViewedDocsStore(backend: b).clearAll();
  StudyPlanStore(backend: b).clearAll();
  PlanCheckStore(backend: b).clearAll();
  ExamSessionStore(backend: b).clearAll();
}
