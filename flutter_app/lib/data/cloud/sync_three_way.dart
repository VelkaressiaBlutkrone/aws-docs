import 'dart:convert';

/// 문서 하나에 대한 3-way 판정 결과.
enum DocAction { none, adoptCloud, pushLocal, deleteLocal, deleteCloud }

/// 마지막 동기 내용([base])을 기준으로 로컬·클라우드 변화를 비교한다.
///
/// - 둘 다 바뀌었으면 늦은 쪽을 택한다. [localDirtyAtMs]는 로컬 변경을 처음 감지한
///   시각, [cloudUpdatedAtMs]는 클라우드 문서의 갱신 시각이며, 동률이면 클라우드를
///   택한다(기존 LWW 규칙 유지).
/// - [cloudDeleted]는 클라우드 삭제 표식이 이 문서를 지웠다는 뜻이다.
/// - 표식 없이 클라우드 문서만 사라진 경우는 다시 올린다 — 삭제는 항상 표식으로
///   오므로, 문서만 없어진 상황에서 로컬을 지우면 데이터를 잃을 수 있다.
DocAction decideDoc({
  Map<String, dynamic>? base,
  Map<String, dynamic>? local,
  Map<String, dynamic>? cloud,
  int cloudUpdatedAtMs = 0,
  int localDirtyAtMs = 0,
  bool cloudDeleted = false,
}) {
  if (cloudDeleted) {
    return local == null ? DocAction.none : DocAction.deleteLocal;
  }
  if (local == null && cloud == null) return DocAction.none;
  if (local == null) {
    return base != null ? DocAction.deleteCloud : DocAction.adoptCloud;
  }
  if (cloud == null) return DocAction.pushLocal;

  final localChanged = !_same(local, base);
  final cloudChanged = !_same(cloud, base);
  if (!localChanged && !cloudChanged) return DocAction.none;
  if (localChanged && !cloudChanged) return DocAction.pushLocal;
  if (!localChanged && cloudChanged) return DocAction.adoptCloud;
  return localDirtyAtMs > cloudUpdatedAtMs
      ? DocAction.pushLocal
      : DocAction.adoptCloud;
}

bool _same(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (a == null || b == null) return a == null && b == null;
  return jsonEncode(a) == jsonEncode(b);
}

/// 집합 3-way 병합: 양쪽의 추가와 삭제를 모두 반영한다(손실 없음).
Set<String> mergeSets({
  required Set<String> base,
  required Set<String> local,
  required Set<String> cloud,
}) {
  final removed = base.difference(local).union(base.difference(cloud));
  return {...base, ...local, ...cloud}..removeAll(removed);
}
