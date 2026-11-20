// flutter_app/lib/data/cloud/synced_collections.dart

/// 동기가 쓰는 Firestore 컬렉션 전체 — `users/{uid}/{collection}/{docId}`.
/// 계정 삭제(A7)가 지울 범위의 **단일 정의**다.
///
/// ⚠️⚠️ **Firestore 클라이언트 SDK 는 서브컬렉션을 나열할 수 없다** —
/// `listCollections` 는 서버 SDK(Admin)에만 있다. 그래서 계정 삭제는 이 목록을 돌며
/// `loadCollection` → `deleteDoc` 할 수밖에 없고, **목록이 낡으면 지워지지 않은 데이터가
/// 조용히 남는다**(사용자는 지워졌다고 믿는다).
///
/// 그 드리프트를 막으려고 `test/account_deletion_test.dart` 가 `sync_service.dart`
/// 소스의 컬렉션 리터럴 집합과 이 목록이 **같은지** 단정한다 — 동기가 새 컬렉션을 쓰기
/// 시작하면 그 가드가 먼저 깨져 여기에 더하라고 알린다.
///
/// ⚠️ 이름을 여기로 모아 `sync_service.dart` 의 리터럴을 치환하지는 않았다. 그 파일은
/// 컬렉션마다 화해 로직이 달라(엔티티·블롭·표식) 상수로 바꿔도 읽기 쉬워지지 않고,
/// 가드가 둘을 묶어 주므로 드리프트 위험도 없다.
const List<String> kSyncedCollections = <String>[
  'attempts',
  'checks',
  'meta',
  'plans',
  'progress',
  'viewed',
];
