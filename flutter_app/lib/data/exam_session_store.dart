import 'dart:convert';

import '../models/exam_session.dart';
import '../models/exam_snapshot.dart';
import 'local_kv.dart';

/// 활성 시험 세션 1건을 examId별 키로 영속화(스펙 §7).
class ExamSessionStore {
  ExamSessionStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static String _key(String examId) => 'awsdocs.examSession.v1:$examId';

  ExamSession? load(String examId) {
    final raw = _b.read(_key(examId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return ExamSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // 손상 데이터 무시
    }
  }

  void save(ExamSession session) =>
      _b.write(_key(session.examId), jsonEncode(session.toJson()));

  /// 빈 문자열 기록 = load에서 null 처리(KvBackend에 삭제 API 없음).
  void clear(String examId) => _b.write(_key(examId), '');

  /// 자격증 통합/약점 모의고사 진행 세션을 함께 폐기한다.
  void clearCertExamSessions(String certCode) {
    clear('exam:$certCode-mock');
    clear('exam:$certCode-weak');
  }

  /// 진행 중인 모든 시험 세션 삭제(키 접두사 일괄 정리).
  void clearAll() {
    for (final prefix in const [
      'awsdocs.examSession.v1:',
      _snapshotPrefix,
      _progressPrefix,
    ]) {
      for (final k in _b.keys()) {
        if (k.startsWith(prefix)) _b.write(k, '');
      }
    }
  }

  // ---------------------------------------------------------------------
  // 스냅샷 2키 체제(설계 2026-10-24 §4.4) — 불변부는 시작 시 1회, 가변부는 매 탭.
  // ---------------------------------------------------------------------

  static const _snapshotPrefix = 'awsdocs.examSnapshot.v1:';
  static const _progressPrefix = 'awsdocs.examProgress.v1:';

  static String _snapshotKey(String examId) => '$_snapshotPrefix$examId';
  static String _progressKey(String examId) => '$_progressPrefix$examId';

  void saveSnapshot(ExamSnapshot s) =>
      _b.write(_snapshotKey(s.examId), jsonEncode(s.toJson()));

  ExamSnapshot? loadSnapshot(String examId) {
    final raw = _b.read(_snapshotKey(examId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final s = ExamSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      // ⚠️ 파싱되는 **퇴화** 스냅샷도 거른다. `fromJson`이 누락 필드를 기본값으로
      // 메우므로 `{"examId":"x"}` 같은 레코드도 통과하는데, 그대로 복원하면
      // 문항 0개는 `_qs[_index]`에서 RangeError(릴리스 웹에서 화면 파손)를 내고
      // `durationSec <= 0`은 복원 직후 자동 제출돼 이력을 오염시킨다.
      if (s.questions.isEmpty || s.durationSec <= 0) return null;
      return s;
    } catch (_) {
      return null; // 손상 데이터 무시 → 새 시험
    }
  }

  void saveProgress(ExamProgress p) =>
      _b.write(_progressKey(p.examId), jsonEncode(p.toJson()));

  ExamProgress? loadProgress(String examId) {
    final raw = _b.read(_progressKey(examId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return ExamProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// 복원 결과. 스냅샷이 없거나 손상됐으면 `null`(= 새 시험).
  ///
  /// 진행 키가 없거나 **nonce가 다르면** 진행만 버리고 index 0·무선택으로 복원한다
  /// (§4.4.1) — 세션 자체는 살린다. 만료 여부로는 거르지 않는다: 만료 세션은 복원
  /// 직후 `ExamView`가 자동 제출해 사용자가 결과를 본다.
  ({ExamSnapshot snapshot, ExamProgress progress})? loadRun(
    String examId, {
    DateTime Function()? now,
  }) {
    final snapshot = loadSnapshot(examId);
    if (snapshot == null) return null;
    final stored = loadProgress(examId);
    final progress = (stored != null && stored.nonce == snapshot.nonce)
        ? sanitizeProgress(stored, snapshot.questions)
        : ExamProgress(
            examId: examId,
            nonce: snapshot.nonce,
            index: 0,
            picked: const {},
            flagged: const [],
          );
    return (snapshot: snapshot, progress: progress);
  }

  void clearRun(String examId) {
    _b.write(_snapshotKey(examId), '');
    _b.write(_progressKey(examId), '');
  }

  /// 제한 시간이 이미 지난 세션만 정리한다(§4.6). 지운 수를 돌려준다.
  ///
  /// ⚠️ 살아 있는 시험은 건드리지 않는다. 시작 시각을 파싱할 수 없으면 **판단 불가**로
  /// 보고 남긴다 — 판단 불가를 삭제 근거로 쓰면 반목표("오히려 세션을 잃는 것")다.
  int clearExpired({DateTime Function()? now}) {
    final clock = (now ?? DateTime.now)();
    var removed = 0;
    for (final k in _b.keys().toList()) {
      if (!k.startsWith(_snapshotPrefix)) continue;
      final examId = k.substring(_snapshotPrefix.length);
      final snapshot = loadSnapshot(examId);
      if (snapshot == null) continue;
      final startedAt = DateTime.tryParse(snapshot.startedAtIso);
      if (startedAt == null) continue; // 판단 불가 → 보존
      if (clock.isAfter(startedAt.add(Duration(seconds: snapshot.durationSec)))) {
        clearRun(examId);
        removed++;
      }
    }
    return removed;
  }
}
