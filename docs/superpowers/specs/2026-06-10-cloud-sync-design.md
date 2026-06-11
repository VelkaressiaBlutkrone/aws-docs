# 클라우드 동기 (Phase 1) — 설계 스펙

작성일: 2026-06-10
상태: 설계 승인됨(브레인스토밍) → 구현 플랜 대기
브랜치: `feat/cloud-sync`
배경 문서: `docs/plans/2026-06-10-firebase-fcm-feasibility.md` (Phase 1 지향·푸시 보류 결정)

Google 로그인 시 학습 데이터(일정·응시이력·열람·체크)를 **기기 간 동기·백업**한다.
비로그인은 지금처럼 **로컬-only**(무계정). 로컬-퍼스트 + 그 위의 SyncService.

---

## 1. 확정된 결정 (브레인스토밍)
| # | 결정 | 값 |
|---|---|---|
| D1 | 인증·브랜드 | **로컬-퍼스트 + 선택적 Google 로그인**(opt-in). 기본 무계정 로컬, "기기 간 동기 켜기 → Google 로그인". |
| D2 | 충돌 해소 | **엔티티별 병합**(최대 정확): history=레코드 union(무손실), viewed=set union, plan·checks=LWW. |
| D3 | 접근 | **로컬-퍼스트 + SyncService**: 로컬 `KvBackend`가 읽기/쓰기 단일 경로, SyncService가 Firestore와 엔티티 단위 화해. |

## 2. 범위 · 전제

### 범위(MVP)
- Google 로그인/로그아웃 + 인증 상태.
- 4종 데이터 동기: `plan`·`history`·`viewed`·`checks`.
- 로그인 시 초기 양방향 화해 + 이후 로컬 쓰기 푸시 + 클라우드 변경 수신.
- **graceful degrade**: Firebase 미설정/미로그인 → 동기 전부 off, 앱은 현재와 동일하게 로컬-only 동작.

### 🚧 전제 (정직)
**Firebase 프로젝트 생성·`flutterfire configure`·Firestore/Auth 활성화·보안 규칙·authorized domains는 사용자만 가능**(에이전트는 크레덴셜 발급 불가).
- *동기 로직·UI·테스트(가짜 CloudStore)는 지금 빌드·검증 가능.*
- **라이브 Firebase 연동(실제 Google 로그인·Firestore 왕복·규칙·2기기)은 사용자 프로젝트 전까지 end-to-end 미검증** — §8·§9에 명시.

### 비범위
푸시(Phase 2), 익명→계정 연결, 실시간 협업/공유, 수동 충돌 머지 UI(자동 병합만).

## 3. 아키텍처

```
앱(기존 스토어들) ── 읽기/쓰기 ──▶ KvBackend (로컬, 단일 경로)
                                      ▲
                                      │ (동기 켜짐일 때만 래핑)
                              SyncedKvBackend ──▶ SyncService ──▶ CloudStore(인터페이스)
                                                      │                ├ FirestoreCloudStore (실연동)
                                                  AuthService          └ FakeCloudStore (테스트·메모리)
                                                      │
                                                  Firebase (선택적 init)
```

- **`CloudStore`**(추상 인터페이스): 엔티티별 push/pull/listen. 구현 = `FirestoreCloudStore` · `FakeCloudStore`(메모리). → **Firebase 없이 SyncService 단위 테스트.**
- **`AuthService`**(추상): `signInWithGoogle()`·`signOut()`·`Stream<AuthUser?>`. 구현 = `FirebaseAuthService` · `FakeAuthService`.
- **`SyncService`**: 인증 상태 구독. 로그인 시 화해 시작, 로그아웃 시 정지. CloudStore와 로컬 KvBackend 사이 엔티티 병합.
- **`SyncController`**(앱 전역 1개, reconcile-on-trigger): 인증 상태 구독 → 로그인 시 `SyncService.reconcileAll` + Firestore watch 시작; **변경 수신·앱 복귀·주기** 트리거에 reconcile 재실행(멱등). `SyncNotifier`로 UI 통지. **스토어·`defaultBackend()` 불변** — SyncService가 스토어와 같은 localStorage(WebBackend)를 읽고/써서 reconcile 결과가 다음 읽기에 자동 반영(가로채기 불필요).
- **Firebase 초기화 선택적**: `firebase_bootstrap.dart`가 설정 여부 확인 후 init. 미설정이면 cloud 기능 전부 off.

## 4. Firebase 설정 게이트 (컴파일·배포 안전)
- 커밋: **스텁 `firebase_options.dart`**(placeholder, `projectId = 'REPLACE_ME'`) — 앱이 지금도 컴파일·배포되게.
- `firebase_bootstrap.dart`: `if (DefaultFirebaseOptions.currentPlatform.projectId == 'REPLACE_ME') return false;`(미설정 → cloud off). 실 설정이면 `Firebase.initializeApp(...)` 후 true.
- 사용자가 `flutterfire configure` 실행 시 스텁이 실 설정으로 덮여 cloud 활성. (웹 Firebase config는 비밀 아님 — 보안은 규칙+authorized domains.)

## 5. 데이터 모델 (Firestore, `users/{uid}/…`)
- **`attempts/{key}`** — `AttemptRecord` 1건=1문서. key = 안정적 합성 `sanitize("{certId}|{examId}|{date}")`(응시당 유일; Firestore 금지문자 `/` 등 치환). **union·무손실**(append-only, 수정 안 함). 로컬은 기존 `awsdocs.history.v1` 블롭 유지.
- **`viewed/{certCode}`** — `{ taskIds: [...] }`. **set union** 병합(arrayUnion).
- **`plans/{certCode}`** — `StudyPlan.toJson()` + `updatedAt`(ms). **LWW**.
- **`checks/{certCode}`** — `{itemId:bool}` 맵 + top-level `updatedAt`(평탄 — `map` 래퍼 없음). **LWW**(저빈도). (itemId는 `cert:type:refId:i` 콜론 구분이라 `updatedAt`과 충돌 불가.)

> 로컬 스키마·키(`awsdocs.*`)는 불변. SyncService가 로컬 블롭 ↔ 위 클라우드 모델을 변환.

## 6. 동기 흐름
1. **초기 화해(로그인 시):** 각 엔티티에 대해 로컬·클라우드 둘 다 로드 →
   - attempts: 두 집합 union(dedupe by key) → 로컬 블롭 갱신 + 클라우드에 로컬 신규 upsert.
   - viewed: set union → 양쪽 반영.
   - plan/checks: `updatedAt` 큰 쪽 채택(LWW), 동률이면 클라우드 우선 → 반영.
2. **로컬 변경 → 푸시(트리거):** 가로채기 없음. `SyncController`가 **앱 복귀·주기(예: 30s)·라우트 변경** 트리거에 `reconcileAll` 재실행(멱등 → 로컬 신규만 push).
3. **클라우드 변경 수신:** Firestore 리스너 → 로컬 병합 반영 → **`SyncNotifier`(ChangeNotifier)** 통지 → UI 재읽기. (Firestore 오프라인 지속성으로 끊겨도 자동 재동기.)
4. **재진입·루프 가드:** reconcile 진행 중 재트리거는 무시(in-progress 플래그). 클라우드 watch→reconcile→push→watch는 멱등이라 신규 push가 없으면 1~2라운드에 수렴.

## 7. UI (opt-in · 절제, DESIGN.md)
- 진입: 홈 설정(⚙) 메뉴 또는 그 근처 **"기기 간 동기"** 항목.
  - 비로그인: "Google로 동기 켜기".
  - 로그인: "동기 켜짐 · {email}" + "로그아웃".
- 상태: 동기 중/완료/오프라인 최소 표기(`SyncNotifier`). 신규 전체화면 없이 작은 진입점·다이얼로그. 액센트는 동작에만.

## 8. 보안 규칙 (사용자가 배포 — 스펙에 텍스트 수록)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## 9. 테스트
- **단위(지금 가능):** `SyncService` 화해 로직을 `FakeCloudStore` + `FakeAuthService`로 —
  attempts union(무손실)·viewed union·plan/checks LWW(updatedAt)·초기 화해·로컬 쓰기 push·클라우드 수신 병합·루프 가드.
  `SyncedKvBackend`(로컬 위임 + 디스패치) 단위 테스트. `firebase_bootstrap` 스텁 게이트(REPLACE_ME→off) 테스트.
- **라이브(사용자 Firebase 후·수동):** 실제 Google 로그인·Firestore 왕복·규칙 거부·2기기 동기·오프라인 후 재동기. **사용자 프로젝트 전까지 미검증(정직).**
- graceful degrade 회귀: 미설정 시 기존 230 테스트·로컬 동작 불변.

## 10. 의존성 · 사용자 액션
- pubspec: `firebase_core`, `firebase_auth`, `cloud_firestore`(웹 Google 로그인은 `firebase_auth`의 `signInWithPopup(GoogleAuthProvider())` — 별도 `google_sign_in` 불필요).
- **사용자 액션 체크리스트:** Firebase 프로젝트 생성 → 웹 앱 등록 → `flutterfire configure`(→ `firebase_options.dart` 덮어쓰기) → Cloud Firestore·Google Auth 공급자 활성화 → 보안 규칙(§8) 배포 → Auth authorized domains에 `velkaressiablutkrone.github.io` 추가.

## 11. 파일 구조 (구현 플랜 입력)
| 파일 | 책임 |
|---|---|
| `lib/data/cloud/cloud_store.dart` | `CloudStore` 인터페이스 + 엔티티 DTO 경계 |
| `lib/data/cloud/firestore_cloud_store.dart` | Firestore 구현 |
| `lib/data/cloud/fake_cloud_store.dart` | 테스트용 메모리 구현 |
| `lib/data/cloud/auth_service.dart` | `AuthService` 인터페이스 + `FakeAuthService` |
| `lib/data/cloud/firebase_auth_service.dart` | Google 로그인 구현 |
| `lib/data/cloud/sync_service.dart` | 엔티티 화해(reconcileAll) — **완료(Plan 1)** |
| `lib/data/cloud/sync_controller.dart` | 인증·트리거 오케스트레이션 + `SyncNotifier`(reconcile-on-trigger) |
| `lib/data/cloud/firebase_bootstrap.dart` | 선택적 init + 설정 게이트 |
| `lib/firebase_options.dart` | **스텁**(사용자가 flutterfire로 덮음) |
| `lib/pages/…`(수정) | 동기 진입점·상태 UI |
| `test/cloud/*` | 단위 테스트 |

## 12. 구현 증분 순서 (→ 플랜)
1. `CloudStore`/`AuthService` 인터페이스 + `FakeCloudStore`/`FakeAuthService`.
2. `SyncService` 화해 로직(엔티티별 병합) + 단위 테스트(가짜로 무손실·LWW 검증). ← **여기까지 Firebase 없이.**
3. `SyncController`(reconcile-on-trigger: 로그인·watch·복귀/주기) + `SyncNotifier` + 테스트(Fake).
4. `firebase_bootstrap` 스텁 게이트 + graceful degrade.
5. `FirestoreCloudStore`·`FirebaseAuthService`(실연동, 컴파일만·라이브 미검증).
6. UI 진입점·상태.
7. (사용자) Firebase 설정 → 라이브 수동 검증.

각 코드 단계 끝 `flutter analyze lib && flutter test`.
