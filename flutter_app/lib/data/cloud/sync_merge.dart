import '../../models/attempt_record.dart';

/// Firestore 문서 ID 금지문자 치환.
String _sanitize(String s) => s.replaceAll(RegExp(r'[/.#\$\[\]]'), '_');

/// 응시 1건의 안정적 클라우드 키(certId|examId|date — 응시당 유일).
String attemptKey(AttemptRecord r) =>
    _sanitize('${r.certId}|${r.examId}|${r.date}');

/// attempts union(무손실): 로컬 리스트 + 클라우드(키→json)
/// → 병합 리스트 + 클라우드에 없던 로컬만 toCloud(키→json).
({List<AttemptRecord> merged, Map<String, Map<String, dynamic>> toCloud})
    mergeAttempts(
        List<AttemptRecord> local, Map<String, Map<String, dynamic>> cloud) {
  final byKey = <String, AttemptRecord>{};
  for (final r in local) {
    byKey[attemptKey(r)] = r;
  }
  for (final e in cloud.entries) {
    byKey.putIfAbsent(e.key, () => AttemptRecord.fromJson(e.value));
  }
  final toCloud = <String, Map<String, dynamic>>{};
  for (final r in local) {
    final k = attemptKey(r);
    if (!cloud.containsKey(k)) toCloud[k] = r.toJson();
  }
  return (merged: byKey.values.toList(), toCloud: toCloud);
}
