import 'dart:convert';

import '../models/exam_session.dart';
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
}
