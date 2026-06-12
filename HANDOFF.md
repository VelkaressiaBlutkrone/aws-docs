# HANDOFF — 다음 세션 이관

_갱신: 2026-06-12 · 다음 작업자(사람 또는 새 세션)가 이 문서만 읽고 이어받을 수 있도록._

🔗 라이브: https://velkaressiablutkrone.github.io/aws-docs/

---

## 0. 지금: 학습문서 고도화 배치 B(SAA) — **24/24 + 검수 피드백 1차 반영 완료, 확인 대기**

**브랜치 `feat/content-enrichment-saa` (origin 푸시됨, main 미병합).** 구조 테스트 `+129: All passed`, 전체 스위트 `+391: All passed`, `flutter analyze lib` 무이슈.

- **완료 24개:** saa-t1-1~t1-5, t2-1~t2-5 (전 세션), saa-t3-1~t3-9, t4-1~t4-5 (2026-06-12, +902줄). 문서별 ①구현(sonnet) → ②통합 리뷰+수정(sonnet) → ③컨트롤러 tail 실측. `lastVerified` 전부 불변.
- **검수 피드백 1차(2026-06-12, 7건) 반영 완료** — 각 수정 에이전트가 인용된 공식 문서를 WebFetch로 대조 후 교정. 커밋 6개:
  - [High] t4-2 스팟 "경매" 근거 5개 위치 제거 → EC2 설정·수요공급 추세 조정 모델로(기존 본문 포함, 게이트 지시로 불가침 해제). sp-ris.html 출처 추가. (4234810)
  - [High] t3-8 TGW 중복 CIDR — "라우팅 테이블로 관리 가능"(비교표 행)·"신중 설계" 서술 → 공식 미지원·경로 미전파 사실로. tgw-vpc-attachments.html 출처 추가. (c618972)
  - [Med] t3-3 T 패밀리 standard/unlimited 모드 구분 정확화(unlimited 기본·surplus 과금), "유휴 CPU 공유 풀" 추론 제거, 함정#5 포인터를 §5 본문 제약 사실로, SR-IOV "VF 직접 DMA" 제거. 버스트 출처 2건 추가. (c6537cc)
  - [Med] t3-6 LSI "내부 스토리지 레이아웃" 단정 → 공식 표현(파티션 키 공유=생성 시점 제약 / GSI=자체 파티션 공간) 수준으로, 함정#1 포인터 동기 교정. (6607d5f)
  - [Med] t4-5 "소급 불가/컬럼 자체가 없다" 절대 단정 완화 → 기본 미반영 + **backfill 요청 최대 12개월 소급**(CE·Data Exports·CUR 갱신) 반영, 함정#5·Q5 동기 교정. backfill·activating-tags 출처 추가. (4ed7367)
  - [Low] t3-4 "공식 문서가 명시하지 않지만" 스타일 잔존분 제거. (4fa9ae0)
- **잔존 1건(사용자 결정 대기):** t3-3 시험 포인트 241행 "크레딧 소진 후 성능이 기준선으로 제한됩니다" — 지적과 같은 결(standard-모드 한정 서술)이지만 **지적 명시 범위(107·110·261행) 밖의 기존 본문**이라 미수정. 교정 지시 시 1줄 수정.
- **미지적 존치 플래그(검수에서 언급 없음 → 존치):** t1-2 '권한 세트' 행 · t3-6 RCU/WCU 행 · t3-8 '비전이' 행 · t3-9 Kinesis 설계 의도 · t4-4 '캐시 히트율' 행.
- **다음 첫 수: 사용자 "검수 완료" 확인 → Step 3:** 24개 lastVerified 갱신(+출처 줄 `· 고도화 검수: 날짜` 병기) → main 병합(`--no-ff`) → 머지본 전체 테스트 → push(=배포) → 배치 C(SOA 20).
- **이번 세션 리뷰 실적(14문서):** 사실 오류 1건 교정(t4-3 "RDS RI=물리 인프라 사전 확보"→청구 할인 약정; 배치 통산 4건) · 출처 밖 단정/내부 구현 추론 보수화 ~20건 · 포인터 실재성 교정 ~15건(최빈 잔여 결함) · 용어 행 삭제/교체 ~10건 · 수치/수식 재인용 제거 다수("RCU 2배"·"N(N-1)/2"·신규 수치 예시) · 컨트롤러 직접 교정 2건(t3-1·t3-3 포인터 — 리뷰어가 블록 수정 후 포인터 재검을 놓친 케이스).
- **배치 C(SOA)용 루프 노트(검증된 개선):** 절제 규칙은 전 세션 기록 그대로 + ⓐ구현 템플릿에 "블록 `>` 줄 수 직접 세기"·"포인터별 블록 1:1 대조"·"본문 표 셀/details/코드 블록 등장은 용어 미등장으로 침" 명시 ⓑ리뷰 템플릿에 "포인터 실재성 전수 검사표를 보고에 강제"·"블록 수정 후 그 §를 가리키는 포인터 재검(교차 정합)"·"출처 밖 단정·재포장·실재성 위반은 플래그가 아닌 수정 대상" 명시 ⓒ컨트롤러는 tail 실측 + fix 디프 스팟 체크(포인터↔블록)를 매 문서 수행 ⓓSOA 사전 점검 필수: 코드 펜스 안 `### ` 카운트 오염(Plan 2 Task 7).
- **테스트 카운팅(이 브랜치에서 변경됨, faa16d9):** `^### `만 카운트(#### 제외) + 하한 캡 8.

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

**다음 세션 첫 수: §0 배치 B 검수 게이트(사용자). 그 외 대기: §0-b 선택 항목(2기기 pull·개인정보 고지).**
