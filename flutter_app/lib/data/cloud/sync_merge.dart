import '../../models/attempt_record.dart';
import 'sync_meta.dart';

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

/// 클라우드 열람 문서에서 {taskId: 시각}을 읽는다. 레거시 `taskIds` 배열은 시각 0.
Map<String, int> viewedItemsOf(Map<String, dynamic> doc) {
  final items = doc['items'];
  if (items is Map) {
    return {
      for (final e in items.entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
  }
  final legacy = doc['taskIds'];
  if (legacy is List) return {for (final x in legacy) x.toString(): 0};
  return {};
}

/// viewed 합집합 + 삭제 표식 적용. 같은 taskId가 양쪽에 있으면 늦은 시각을 남긴다.
/// 표식보다 이른 열람은 양쪽에서 버리고, 비게 된 자격증 문서는 toDelete로 알린다.
({
  Map<String, Map<String, int>> merged,
  Map<String, Map<String, dynamic>> toCloud,
  List<String> toDelete,
}) mergeViewed(
  Map<String, Map<String, int>> local,
  Map<String, Map<String, dynamic>> cloud, {
  Map<String, int> resetAt = const {},
}) {
  final merged = <String, Map<String, int>>{};
  final toCloud = <String, Map<String, dynamic>>{};
  final toDelete = <String>[];
  final certs = {...local.keys, ...cloud.keys};
  for (final cert in certs) {
    final cut = mergedEffectiveResetAt(resetAt, cert);
    final l = local[cert] ?? const <String, int>{};
    final c = cloud[cert] == null
        ? const <String, int>{}
        : viewedItemsOf(cloud[cert]!);
    final union = <String, int>{};
    for (final e in [...l.entries, ...c.entries]) {
      if (e.value >= (union[e.key] ?? 0)) union[e.key] = e.value;
    }
    union.removeWhere((_, ms) => ms < cut);
    merged[cert] = union;
    if (union.isEmpty) {
      if (cloud.containsKey(cert)) toDelete.add(cert);
      continue;
    }
    final sameAsCloud = union.length == c.length &&
        union.entries.every((e) => c[e.key] == e.value);
    if (!sameAsCloud) toCloud[cert] = {'items': union};
  }
  return (merged: merged, toCloud: toCloud, toDelete: toDelete);
}

/// plan·checks LWW: 로컬 {cert:json} + 사이드카 localMeta{cert:ms}
/// + 클라우드 {cert:json+updatedAt} → 병합 doc/메타 + 로컬이 최신/단독인 cert만 toCloud(+updatedAt).
/// 동률·클라우드 우선은 클라우드 채택. 로컬 doc은 updatedAt 미포함(청결).
({
  Map<String, Map<String, dynamic>> merged,
  Map<String, int> mergedMeta,
  Map<String, Map<String, dynamic>> toCloud,
}) mergeLww(
    Map<String, Map<String, dynamic>> local,
    Map<String, int> localMeta,
    Map<String, Map<String, dynamic>> cloud) {
  final merged = <String, Map<String, dynamic>>{};
  final mergedMeta = <String, int>{};
  final toCloud = <String, Map<String, dynamic>>{};
  final certs = {...local.keys, ...cloud.keys};
  for (final cert in certs) {
    final localMs = localMeta[cert] ?? 0;
    final c = cloud[cert];
    final cloudMs = (c?['updatedAt'] as num?)?.toInt() ?? -1;
    if (c != null && cloudMs >= localMs && cloudMs >= 0) {
      final data = Map<String, dynamic>.from(c)..remove('updatedAt');
      merged[cert] = data;
      mergedMeta[cert] = cloudMs;
    } else if (local.containsKey(cert)) {
      merged[cert] = Map<String, dynamic>.from(local[cert]!); // 방어적 복사(순수 계약)
      mergedMeta[cert] = localMs;
      toCloud[cert] = {...local[cert]!, 'updatedAt': localMs};
    }
  }
  return (merged: merged, mergedMeta: mergedMeta, toCloud: toCloud);
}
