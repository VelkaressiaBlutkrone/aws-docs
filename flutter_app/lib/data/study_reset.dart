import 'cloud/sync_meta.dart';
import 'content_index.dart';
import 'exam_session_store.dart';
import 'history_store.dart';
import 'plan_check_store.dart';
import 'plan_progress_store.dart';
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

int _utcNowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

/// 한 자격증의 모든 학습 기록을 삭제한다(다른 자격증은 보존).
/// 로그인 상태면 다음 동기가 이 표식으로 클라우드·다른 기기까지 정리한다.
void resetCert(String certCode, {KvBackend? backend, int Function()? nowMs}) {
  final b = backend ?? defaultBackend();
  HistoryStore(backend: b).clearCert(certCode);
  ViewedDocsStore(backend: b).clearCert(certCode);
  final planStore = StudyPlanStore(backend: b);
  final progress = PlanProgressStore(backend: b);
  for (final p in planStore.plansFor(certCode)) {
    progress.clearPlan(p.id);
  }
  planStore.clearCert(certCode);
  PlanCheckStore(backend: b).clearCert(certCode);
  final sessions = ExamSessionStore(backend: b);
  for (final id in examIdsForCert(certCode)) {
    sessions.clear(id);
  }
  SyncMeta(b).markReset(certCode, (nowMs ?? _utcNowMs)());
}

/// 모든 자격증의 모든 학습 기록을 삭제한다(공장 초기화).
/// 사이드카는 지우지 않는다 — 삭제 표식을 보존해야 부활을 막는다.
void resetAll({KvBackend? backend, int Function()? nowMs}) {
  final b = backend ?? defaultBackend();
  HistoryStore(backend: b).clearAll();
  ViewedDocsStore(backend: b).clearAll();
  StudyPlanStore(backend: b).clearAll();
  PlanCheckStore(backend: b).clearAll();
  PlanProgressStore(backend: b).clearAll();
  ExamSessionStore(backend: b).clearAll();
  SyncMeta(b).markReset(SyncMeta.allCerts, (nowMs ?? _utcNowMs)());
}
