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

/// viewed set union: 로컬 {cert:set} + 클라우드 {cert:{taskIds:[]}}
/// → 병합 {cert:set} + 클라우드와 달라진 cert만 toCloud {cert:{taskIds:[]}}.
({Map<String, Set<String>> merged, Map<String, Map<String, dynamic>> toCloud})
    mergeViewed(Map<String, Set<String>> local,
        Map<String, Map<String, dynamic>> cloud) {
  final merged = <String, Set<String>>{};
  final toCloud = <String, Map<String, dynamic>>{};
  final certs = {...local.keys, ...cloud.keys};
  for (final cert in certs) {
    final l = local[cert] ?? const <String>{};
    final cRaw = (cloud[cert]?['taskIds'] as List?)?.cast<String>() ?? const [];
    final c = cRaw.toSet();
    final union = {...l, ...c};
    merged[cert] = union;
    // 클라우드 집합과 다르면(로컬이 더한 게 있으면) push
    if (union.length != c.length) {
      toCloud[cert] = {'taskIds': union.toList()};
    }
  }
  return (merged: merged, toCloud: toCloud);
}
