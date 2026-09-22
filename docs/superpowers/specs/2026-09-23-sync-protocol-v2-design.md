# 동기 프로토콜 v2 — 설계 스펙

작성일: 2026-09-23
상태: 설계 승인됨(브레인스토밍) → 구현 플랜 대기
배경: `docs/audits/2026-09-22-app-code-ux-review.md` 부록 V(C-2/CODE-D-003, M-9/CODE-D-001, PR-m3, PR-m10) · `docs/superpowers/specs/2026-06-10-cloud-sync-design.md`(Phase 1 원 설계) · `docs/audits/2026-07/01-code-quality.md`(CODE-D-002)

Phase 1 동기는 **삭제를 표현할 수단이 없다.** 합집합과 LWW로 합치기만 하므로, 한 기기에서 지워도 다른 기기의 오래된 사본이 다시 올라와 되살아난다. 이 스펙은 삭제를 1급 개념으로 넣고, 그 위에서 현행 일정(v2)과 일정 진행까지 동기 대상으로 되돌린다.

---

## 1. 확정된 결정 (브레인스토밍 2026-09-23)

| # | 결정 | 값 |
|---|---|---|
| D1 | 초기화 범위 | **모든 기기와 클라우드에서 삭제.** 삭제 표식으로 오래된 사본의 부활을 막는다. "되돌릴 수 없습니다"가 다시 사실이 된다. |
| D2 | 동기 대상 | 응시 기록·열람 기록 + **일정(v2)·일정 진행**. 진행 중 시험 세션은 로컬 전용(비범위). |
| D3 | 삭제 표현 | **삭제 시각 표식**(자격증별) + **일정별 tombstone**. 세대 번호안·문서별 tombstone안은 기각(§1.1). |
| D4 | 로컬 변경 감지 | **마지막 동기 시점의 내용(base) 비교.** 스토어에 쓰기 시각 스탬프를 심지 않는다. |

### 1.1 기각한 대안

- **세대 번호(epoch)**: 자격증마다 번호를 올려 옛 세대를 무시하는 방식. 시계에 의존하지 않는 장점이 있으나, **오프라인 기기가 초기화 이후 만든 기록까지 옛 세대라는 이유로 잃는다.** 이번 작업의 목적(지울 수 있게 하되 잃지 않기)과 어긋난다.
- **문서마다 삭제 표시만**: 개념은 가장 단순하지만 초기화 한 번이 응시 기록 수만큼 쓰기가 되고(수백 건), 삭제 표시가 영구히 쌓여 30초마다 도는 전체 로드가 계속 무거워진다.

---

## 2. 현행 결함 (이 스펙이 닫는 것)

| ID | 결함 | 현행 동작 |
|---|---|---|
| C-2 / CODE-D-003 | 초기화가 다음 동기에서 부활 | 로컬만 지우고 클라우드는 그대로 → ≤30초 뒤 복구 (재현 완료) |
| M-9 / CODE-D-001 | 현행 일정(v2)이 백업되지 않음 | 동기가 레거시 `awsdocs.plan.v1`만 화해 |
| CODE-D-002 | 일정 진행이 기기별로 갈림 | `awsdocs.plan.progress.v1`이 동기 대상 밖 |
| PR-m3 | 로컬 수정이 되돌아감(잠복) | LWW 사이드카 stamp를 로컬 쓰기 때 갱신하지 않아 동률 → 클라우드 채택 |
| PR-m10 | 손상 레코드 1건이 동기 전체를 멈춤 | `_readJsonList` 뒤 `.map(fromJson)`이 던지면 `reconcileAll`이 attempts 단계에서 중단 |
| — | 일정 개별 삭제가 전파되지 않음 | `removePlan`이 로컬 전용 |

---

## 3. 데이터 모델

### 3.1 클라우드 (`users/{uid}/…`)

| 문서 | 형태 | 병합 |
|---|---|---|
| `meta/deletions` | `{ resetAt: {certCode 또는 "*": ms}, plans: {planId: ms} }` | 필드별 늦은 시각 채택(§4.4) |
| `attempts/{key}` | 기존 `AttemptRecord` JSON + `createdAtMs` | 합집합 + 표식 필터 |
| `viewed/{certCode}` | `{ items: {taskId: ms} }` (레거시 `taskIds: [...]`는 읽기 폴백) | 합집합 + 표식 필터 |
| `plans/{planId}` | `StudyPlan.toJson()` + `updatedAtMs` | 3-way + tombstone |
| `progress/{planId}` | `{ certCode, itemIds: [...], updatedAtMs }` | 3-way 집합 병합 + tombstone |
| ~~`checks/{certCode}`~~ | 동기 제외 | 쓰는 코드가 없는 레거시(§6.3) |

- 시각은 모두 **UTC epoch ms 정수**다.
- `key`(attempts)는 현행 `sanitize("{certId}|{examId}|{date}")`를 유지한다.
- `planId`는 현행 `planIdOf` 규칙(`{certCode}:{createdIso}:{seq}`)을 그대로 쓴다. 콜론이 있어 레거시 `plans/{certCode}` 문서와 구분된다.

### 3.2 로컬

기존 스토어 키는 유지한다. 바뀌는 것은 두 가지다.

- **`awsdocs.viewed.v1`**: 값 형태를 `{cert: [taskId,...]}` → `{cert: {taskId: ms}}`로 옮긴다. **키는 그대로 두고 두 형태를 모두 읽는다**(배열이면 시각 0). 새 키를 만들면 "빈 새 키 → 옛 키 재이관"이라는 함정(2026-09-22 v1 플랜 부활 사고, PR #122)을 다시 만든다.
- **`awsdocs.sync.v2`**(신규 사이드카, v1은 삭제):

```jsonc
{
  "base":      { "plans": {"planId": {...}}, "progress": {"planId": [...]} }, // 마지막 동기 시점의 내용
  "updatedAt": { "plans": {"planId": 0}, "progress": {"planId": 0} },         // 그 시점의 클라우드 updatedAtMs
  "dirtyAt":   { "plans": {"planId": 0}, "progress": {"planId": 0} },         // 로컬 변경을 처음 감지한 시각
  "resetAt":   { "certCode 또는 *": 0 }                                       // 삭제 표식(클라우드 사본 + 로컬 발생분)
}
```

`base`는 해시가 아니라 **내용**을 담는다. 일정 진행(집합)을 손실 없이 3-way로 합치려면 마지막 동기 시점의 내용이 필요하기 때문이다. 크기는 일정 수 × 수백 바이트 수준이다.

### 3.3 `AttemptRecord`

`createdAtMs`(UTC ms) 필드를 추가한다. 새 응시부터 기록하고, 없는 레코드는 `date`(시간대 없는 로컬 ISO 문자열)를 해석해 폴백한다. 이 폴백은 기기 시간대가 다르면 그 차이만큼 오차가 난다 — 그래서 새 기록은 UTC로 남긴다.

---

## 4. 병합 규칙

### 4.1 유효 삭제 시각

```
effectiveResetAt(cert) = max(resetAt[cert] ?? 0, resetAt["*"] ?? 0)
```

`resetAll`은 자격증을 열거하지 않고 `resetAt["*"]`에 지금 시각을 적는다.

### 4.2 응시 기록·열람 기록 (합집합 + 표식 필터)

```
createdAtMs(record) = record.createdAtMs ?? parse(record.date) ?? 0
keep(record) = createdAtMs(record) >= effectiveResetAt(record.certId)
keep(viewed item) = items[taskId] >= effectiveResetAt(cert)
```

- 버려진 레코드는 로컬에서 제거하고, 클라우드 문서도 삭제한다(정리). 삭제가 실패해도 표식이 남아 있으므로 부활하지 않는다.
- 오래된 사본을 가진 기기도 같은 규칙으로 걸러지므로 다시 올리지 않는다.
- 정리는 **표식을 아는 기기라면 어느 쪽이 해도 된다**(결과가 같음). 한 번의 reconcile에서 삭제는 최대 50건까지만 하고 남은 건 다음 트리거로 미룬다 — 초기화 직후 한 번의 동기가 수백 건 삭제로 길어지지 않게 한다.

### 4.3 일정·진행 (3-way)

문서(`planId`)마다 세 값을 비교한다: `base`(마지막 동기 내용) · 로컬 현재 · 클라우드 현재.

| 로컬 | 클라우드 | 처리 |
|---|---|---|
| 그대로 | 바뀜 | 클라우드 채택 |
| 바뀜 | 그대로 | 로컬 push (`updatedAtMs` = 지금) |
| 둘 다 바뀜 (일정) | | `dirtyAt[id]` vs 클라우드 `updatedAtMs` 비교, 늦은 쪽. 동률이면 클라우드(현행 규칙 유지) |
| 둘 다 바뀜 (진행) | | **집합 3-way 병합**: `(base ∪ 로컬추가 ∪ 클라우드추가) − 로컬제거 − 클라우드제거` — 손실 없음 |
| 로컬에서 사라짐(`base`엔 있음) | 있음 | 삭제로 판정 → `deletions.plans[id] = 지금` → 클라우드 문서 삭제 |
| 있음 | `deletions.plans[id] > 로컬 updatedAtMs` | 로컬에서 제거 |

- `dirtyAt`은 로컬 변경을 **처음 감지한 시각**이다. reconcile이 로컬 변경을 발견했는데 `dirtyAt[id]`가 없으면 그때 지금 시각을 적고, push나 클라우드 채택으로 그 문서가 정리되면 지운다. 주기 동기가 30초라 실제 편집 시각과 최대 30초 차이가 난다. 본인 기기 두 대가 같은 일정을 30초 안에 서로 고치는 경우에만 영향이 있다.
- `base`가 없는데 양쪽에 같은 `planId`가 있으면(두 기기에서 각각 만든 첫 동기) 둘 다 바뀐 것으로 보고 같은 규칙을 적용한다.
- 진행 문서는 자격증 초기화 표식도 함께 적용한다(`certCode` 필드로 판정).
- 일정이 삭제되면 같은 `planId`의 진행 문서도 함께 삭제한다.

### 4.4 삭제 표식 문서

`meta/deletions`는 통째로 덮지 않는다. 읽은 값과 병합해 **필드별로 늦은 시각**을 채택한 뒤 쓴다. 두 기기가 서로 다른 자격증을 동시에 초기화해도 표식이 서로를 지우지 않는다.

### 4.5 base 갱신 시점

`base`·`updatedAt`은 **클라우드 반영이 성공한 뒤에만** 갱신한다. 중간에 끊기면 다음 트리거가 같은 일을 다시 한다(현행 멱등 계약 유지).

---

## 5. 초기화·삭제 흐름

**로그인 상태에서 초기화**
1. 로컬을 즉시 비우고 사이드카에 `resetAt[cert] = 지금`(또는 `*`)을 적는다.
2. 다음 reconcile이 표식을 `meta/deletions`에 병합해 올리고, 표식보다 오래된 클라우드 문서를 삭제한다.
3. 다른 기기는 표식을 받아 자기 로컬을 같은 규칙으로 정리한다.
4. 확인창 문구는 "이 작업은 되돌릴 수 없습니다"로 되돌린다(2026-09-22 임시 조치 해제).

**비로그인 초기화**: 표식은 로컬에만 남는다. 나중에 로그인하면 그 표식이 함께 올라가 클라우드의 옛 기록도 그때 정리된다. 확인창에는 과거 동기 흔적(`awsdocs.sync.v2`의 `base`가 비어 있지 않음)이 있으면 그 사실을 알린다(리뷰 PR-m1).

**일정 개별 삭제**: 로컬에서 지우면 다음 reconcile이 `base`와 비교해 삭제로 판정하고 표식을 남긴다. 다른 기기는 그 표식으로 같은 일정을 지운다.

---

## 6. 마이그레이션

### 6.1 클라우드 일정 문서 (v1 → v2)

`plans/{certCode}`(레거시, `id` 필드 없음)를 `plans/{planId}`로 옮긴다.

```
planId = planIdOf(certCode, createdIso, 0)   // 로컬 v1→v2 이관과 같은 규칙
label  = '기존 일정'                          // 로컬 이관과 동일
source = auto
```

두 기기가 각자 변환해도 같은 문서가 나온다(결정적). 변환 후 레거시 문서는 삭제한다. 같은 `planId`가 이미 있으면 일반 3-way 규칙으로 합친다.

### 6.2 열람 기록 형태

`{cert: [taskId,...]}` → `{cert: {taskId: ms}}`. 읽기는 두 형태를 모두 받아들이고(배열은 시각 0), 쓰기는 새 형태로만 한다. 새로 기록하는 열람 시각은 UTC epoch ms다. 시각 0은 "초기화 이전"으로 취급되므로, 초기화가 있었던 자격증에서는 정리된다.

### 6.3 checks 정리

`checks`는 동기 대상에서 뺀다. 클라우드 `checks/*` 문서는 1회 삭제한다. 로컬 `awsdocs.plan.checks.v1`은 초기화가 계속 지우므로 그대로 둔다. `PlanCheckStore` 자체의 제거는 별도 정리 과제로 남긴다(현재 쓰는 화면 없음 — 완료 체크는 `PlanProgressStore`).

### 6.4 사이드카

`awsdocs.sync.v1`은 옛 프로토콜의 파생 데이터라 버리고 `awsdocs.sync.v2`를 새로 만든다. 잃을 데이터가 없다.

---

## 7. 실패와 경계

| 상황 | 처리 |
|---|---|
| 동기 도중 끊김 | `base`를 성공 후에만 갱신 → 다음 트리거가 재시도(멱등) |
| 두 기기 동시 초기화 | `meta/deletions` 필드별 늦은 시각 채택(§4.4) |
| 기기 시계 차이 | 새 기록은 UTC ms → 시간대 문제 없음. 남는 건 기기 간 시계 오차만큼의 경계 오차(본인 기기이므로 수용) |
| 삭제 정리 실패 | 표식이 남아 부활하지 않음. 다음 동기에서 재시도 |
| 손상 레코드 | 동기 경로도 레코드 단위로 건너뛰고, 버린 부분이 있으면 원문 보존 후 진행(리뷰 PR-m10, `HistoryStore._parse`와 같은 규칙 공유) |
| 멀티탭 | localStorage의 탭 간 전파는 비동기라 완전 차단은 불가. 현행 한계를 유지하되, 무변경 시 쓰기 생략(PR #122)으로 창은 이미 크게 줄었다 |

---

## 8. 보안 규칙

새로 쓰는 `meta`·`progress`도 `users/{uid}/**` 아래라 현행 규칙이 그대로 덮는다.

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

이 규칙을 `firestore.rules`로 레포에 넣고 `firebase.json`에 연결한다. 에뮬레이터 테스트 1건(타인 uid 읽기 거부)을 추가한다. 콘솔에 배포된 실제 규칙과 일치시키는 것은 사용자 작업이다.

---

## 9. 테스트

**두 기기 시나리오**(로컬 저장소 2개 + 같은 `FakeCloudStore`)로 검증한다.

1. A에서 초기화 → B 동기 → B도 비워지고, 어느 쪽에서도 되살아나지 않는다
2. B가 오프라인일 때 만든 새 응시 → A에서 초기화 → B 동기 → **B의 새 기록은 살아남는다**
3. A에서 일정 삭제 → B에서도 사라진다
4. B에서 완료 체크 해제 → A에 반영된다(집합 3-way, 다른 항목 추가와 동시에도 손실 없음)
5. 로컬에서 고친 값이 다음 동기에 되돌아가지 않는다(PR-m3 회귀 가드)
6. 비로그인 초기화 → 로그인 시 클라우드의 옛 기록도 정리된다
7. 클라우드 레거시 일정 문서 변환의 결정성, 열람 배열 형태 폴백
8. 손상 레코드가 있어도 `reconcileAll`이 끝까지 돈다(PR-m10)
9. 경합 회귀: 클라우드 로드 대기 중 사용자 쓰기 보존(PR #122의 게이트 CloudStore 재사용)

순수 함수(`sync_merge.dart`)에 표식 필터·3-way 판정·집합 병합을 넣고 단위 테스트로 덮는다. 라이브 2기기 확인은 사용자 수동 작업으로 남는다.

---

## 10. 구현 순서

각 PR은 실패 테스트 선작성, `flutter analyze` 0건, `flutter test` 전부 통과, CI 녹색을 게이트로 한다.

| PR | 범위 | 주요 파일 |
|---|---|---|
| **PR1 — 삭제 표식 기반** | 사이드카 v2, 표식 필터·유효 시각, `CloudStore.deleteDoc`, 응시·열람에 적용, 초기화 흐름 연결, `AttemptRecord.createdAtMs`, 열람 형태 이관 | `cloud_store.dart`, `firestore_cloud_store.dart`, `sync_merge.dart`, `sync_service.dart`, `study_reset.dart`, `viewed_docs_store.dart`, `models/attempt_record.dart` |
| **PR2 — 일정·진행 동기** | `plans/{planId}`·`progress/{planId}`, 3-way 판정과 집합 병합, 레거시 클라우드 문서 변환, 개별 삭제 전파, watch 대상 추가 | `sync_merge.dart`, `sync_service.dart`, `sync_controller.dart` |
| **PR3 — 정리** | checks 동기 제외·클라우드 1회 정리, 동기 경로 관용 파싱, 확인창 문구 복귀와 비로그인 안내, `firestore.rules`·에뮬레이터 테스트 | `sync_service.dart`, `history_store.dart`(파서 공유), `content/reset_dialog.dart`, `firestore.rules`, `firebase.json` |

---

## 11. 비범위 (YAGNI)

- 진행 중 시험 세션 동기(D2) — 타이머 기준 시각·중복 제출·한쪽 제출 후 처리까지 필요한데 실익은 "시험 도중 기기 변경"뿐
- 계정 탈퇴 전용 UI — 로그인 상태의 전체 초기화가 같은 일을 한다
- 실시간 협업·수동 충돌 병합 UI(원 설계의 비범위 유지)
- `PlanCheckStore` 코드 제거(별도 정리 과제)
- 주기 동기의 dirty 플래그 최적화(리뷰 M-8 — watch 구독에 오류 처리가 없는 동안은 주기 틱이 pull 안전망이라 보류)
