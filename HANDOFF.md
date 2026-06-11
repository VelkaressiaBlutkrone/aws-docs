# HANDOFF — 다음 세션 이관

_갱신: 2026-06-11(저녁) · 다음 작업자(사람 또는 새 세션)가 이 문서만 읽고 이어받을 수 있도록._

🔗 라이브: https://velkaressiablutkrone.github.io/aws-docs/

---

## 0. 지금 IN-FLIGHT: 학습문서 고도화 배치 B(SAA) — **10/24 완료, 일시 중지**

**브랜치 `feat/content-enrichment-saa` (origin 푸시됨, main 미병합).** 구조 테스트 tail: `+87 -42`.

- **완료 10개 (구현 + 통합 spec·quality 리뷰 + 수정, lastVerified는 게이트 후):** saa-t1-1 ~ t1-5, saa-t2-1 ~ t2-5. 리뷰가 잡은 실질 교정: 사실 오류 3건(rotation 4단계 순서·마이크로초 스케일·AWSPREVIOUS 의미, t1-4) · 부정확 포인터(t2-4 함정#1) · RTT/TPS/1초미만 수치 재인용 제거(t2-1·t2-5) · 재포장 블록·Q 교체 다수 · Stateful/Stateless 행 제거(t1-3, t2-4 전례 적용).
- **남은 14개:** saa-t3-1 ~ t3-9, saa-t4-1 ~ t4-5. 문서당 tail -3씩 감소(남은 문서엔 기존 왜-Q 없음 — t1-5만 있었음), 전부 완료 시 구조 스위트 All passed.
- **다음 첫 수: saa-t3-1 디스패치.** 루프 패턴(이 세션 검증): 문서별 ①구현(sonnet) → ②통합 spec+quality 리뷰+수정 권한(sonnet) → ③컨트롤러가 tail 직접 실측(리뷰어가 test tail과 diff stat을 자주 혼동 — tail은 신뢰하지 말고 직접 `flutter test test/content_enrichment_test.dart -r compact | tail -1`).
- **배치 B 절제 규칙(프롬프트에 주입할 것):** 블록 4~6줄 · 블록 수 = min(^###, 8) · `####`는 부모 커버(블록 금지) · 분량 +50~80 · 포인터 ~60자 요지 · 본문 why 재포장 금지(기존 why-블록 있으면 다른 축) · 수치 ADDED 재인용 금지 · Q답 1~3문장·비공식 추론 금지 · 기존 본문 불가침 · 용어 표는 "시험 구분 양 축" 금지(glossary-레이어: 정의 1줄 vs 본문 상세 분리면 허용).
- **테스트 카운팅(이 브랜치에서 변경됨, faa16d9):** `^### `만 카운트(#### 제외) + 하한 캡 8.
- **게이트 플래그 누적(배치 B 검수 시 제시):** saa-t1-2 용어 표 '권한 세트·전체 기능 모드' 행 — 시험 구분 경계 사례.
- 게이트 절차(배치 A와 동일): 24개 완료 → 검수 STOP → 피드백 반영 → lastVerified(+출처 줄 병기) → main 병합 → push(=배포) → 배치 C.

## 0-a. 완료: 배치 A(CLF) — main 배포됨

**CLF 19/19 고도화 출고(2026-06-11).** 본인 검수 5건 보수화 반영(S3 기본암호화·SecurityHub CSPM·Support 최신성·SP/RI·VPN-DX), lastVerified 갱신, 319 테스트. 배치 C(SOA 20)는 코드 펜스 `###` 오염 사전 점검 필수(Plan 2 Task 7 — 배치 B의 사전 점검에선 SAA 오염 0건이었음).

- 문서: 스펙 `docs/superpowers/specs/2026-06-11-content-enrichment-design.md`(§4.4 freeze) · 플랜 `docs/superpowers/plans/2026-06-11-content-enrichment-rollout.md` · 파일럿 전례 `plans/2026-06-11-content-enrichment-pilot.md`.
- **방향 결정(2026-06-11, 사용자):** 모의고사 중량화·문항 증가보다 학습 내용 고도화 우선. 고도화(배치 B·C) 완료 후 모의고사 중량·증가 검토.

---

## 0-b. 같은 날 완료: 클라우드 동기 Phase 1 — **전체 출고**

Google 로그인 시 학습 데이터(일정·응시이력·열람·체크)를 기기 간 동기. 로컬-퍼스트 + *선택적* 로그인, 미로그인은 로컬-only.

**2026-06-11 세션에서 닫은 것 (모두 main 병합·배포):**
- **라이브 Firebase 연결** — 사용자 프로젝트 `awc-docs-cf67d` 생성, `flutterfire configure`로 `firebase_options.dart` 실값(게이트 ON), Google Auth + Firestore + 보안 규칙(스펙 §8) + authorized domain(`velkaressiablutkrone.github.io`) 설정 완료.
- **로컬→클라우드 트리거 갭 보강** — `SyncController`에 주기 Timer(`defaultSyncInterval` 30s, signed-in 한정) + 앱 복귀(web `visibilitychange`, `app_resume*.dart` 조건부 import) 트리거. 스펙 §6.2 충족.
- **리뷰 후속 하드닝** — 전환 인터리브 시 고아 타이머/스테일 부착 차단(세대 가드 `_gen`), 트리거 해제를 진입 시 **동기** teardown으로(await 뒤로 밀리는 창 제거), dispose 후 notify 가드, signOut 시 `_pending` 클리어.
- **라이브 e2e 검증(실측):** 로그인 → 데이터 생성 → **재로그인 없이** 30s/탭복귀로 Firestore `users/{uid}/*` 반영 확인. 콘솔 에러 0.

**검증:** `cd flutter_app && flutter analyze lib && flutter test` (**262 테스트**). 배포는 main 푸시 시 GitHub Actions(`pages.yml`) 자동.

### 남은 선택 항목 (작음)
1. **2기기 pull 검증(사용자 5분):** 두 번째 기기/브라우저에서 같은 계정 로그인 → 첫 기기 데이터가 내려오는지. push 방향·병합 로직은 검증됨, pull 실기기 확인만 남음.
2. **개인정보 고지:** Google 로그인이 라이브가 됐으므로 "무계정·무추적" 정체성과의 관계 정리(간단 고지 문구). 메모리 [[study-app-cloud-direction]] 하단 주의 참조.
3. **Phase 2(푸시 알림)는 보류** — `docs/plans/2026-06-10-firebase-fcm-feasibility.md`.

---

## 1. 아키텍처 핵심 (이어받기 전 알아야 할 것)
- **reconcile-on-trigger (가로채기 없음):** 스토어와 `SyncService`가 **같은 localStorage**(`defaultBackend()`)를 읽고/써서 reconcile 결과가 스토어 다음 읽기에 자동 반영. 트리거(로그인·cloud watch·주기 30s·앱 복귀)에 **멱등** `reconcileAll` 재실행.
- **graceful degrade 게이트:** `firebase_bootstrap.dart`의 `cloudConfigured()` — `DefaultFirebaseOptions.web.projectId`로 판독(웹 전용 앱; `currentPlatform`은 테스트 VM에서 throw하므로 금지).
- **충돌 해소:** history=레코드 union(무손실), viewed=set union, plan/checks=LWW(사이드카 `awsdocs.sync.v1`). 순수 함수 `sync_merge.dart`.
- **SyncController 동시성:** auth 스트림이 `_onUser`를 await 없이 호출 → 전환 인터리브 가능. 세대 가드(`_gen`)가 스테일 전환의 watch/timer 부착을 차단, teardown은 진입 시 동기 수행(cancel future를 기다리면 해제가 밀림 — 코드 주석 참조).
- **파일:** `lib/data/cloud/{auth_user,auth_service,cloud_store,sync_merge,sync_service,firebase_bootstrap,firestore_cloud_store,firebase_auth_service,sync_controller,app_resume,app_resume_stub,app_resume_web}.dart` · `lib/firebase_options.dart`(실값, 공개 안전) · `lib/pages/sync_entry.dart` · `lib/main.dart` · `lib/pages/home_page.dart`(⚙ + 햄버거 진입점).
- **비용 노트:** 주기 트리거는 변경 없어도 틱마다 4컬렉션 로드(개인 규모 수용). 조정점 = `SyncController.defaultSyncInterval`.

---

## 2. 대기 작업 (콘텐츠 백로그 — **전부 §0 고도화 완료 이후로 연기**, 사용자 지시 2026-06-11)
이전 핸드오프 상세는 git `9c30e72`의 `HANDOFF.md` 참조. 요약:
- **① ≥15 심화:** CLF 각 Task 12→15 verified(+57문항). 워크플로 메모리 [[content-density-loop]]. **고도화 후 재검토.**
- **② SAA-C03 문항 착수:** 현재 문항 0(학습문서만). **고도화 후 재검토.**
- **③ C-중량:** 개념 → 학습문서 *섹션* 앵커 딥링크. 가치 증명 후.
- **철칙:** `verified=사람 검수만`(AI가 true 금지) · 문항 새 개념은 학습문서(`t*.md`)도 보강 · 시각/UI는 `DESIGN.md` 먼저.

---

## 3. 워킹트리 / 메모
- 미커밋: 없음. 시각 QA 레시피: 메모리 [[flutter-web-visual-qa-recipe]]. 방향·결정: [[study-app-cloud-direction]].

**다음 세션 첫 수 후보: §0 선택 항목(2기기 pull·개인정보 고지) 또는 §2 콘텐츠 백로그 ①.**
