# HANDOFF — 다음 세션 이관

_갱신: 2026-06-12 · 다음 작업자(사람 또는 새 세션)가 이 문서만 읽고 이어받을 수 있도록._

🔗 라이브: https://velkaressiablutkrone.github.io/aws-docs/

---

## 0. 다음: 모의고사 중량·증가 검토 브레인스토밍 (사용자 지시 순서)

**학습문서 고도화 롤아웃 63/63 완료·전량 라이브(2026-06-12).** 배치 A(CLF 19, 06-11) · 배치 B(SAA 24, 06-12) · 배치 C(SOA 20, 06-12) 전부 검수 게이트 통과 → lastVerified 갱신 → main 병합·배포. 전 문서 = 🔤 용어 표 + 서브섹션별 `> 🧠 원리:` 블록 + 함정 원리 포인터 + 원리형 Q. 전체 스위트 451 테스트 그린. 스펙 상태 갱신됨(`docs/superpowers/specs/2026-06-11-content-enrichment-design.md`).

- **다음 첫 수:** 모의고사 **중량·증가 검토 브레인스토밍** — §2 콘텐츠 백로그(①CLF ≥15 심화 ②SAA-C03 문항 착수 ③C-중량)의 연기 조건("고도화 완료 이후")이 충족됨. 우선순위 재검토부터 시작(superpowers:brainstorming).
- **잔여 존치 항목(필요 시 재론):** 배치 B 검수-미지적 플래그 5건(§0-z) · 배치 C 검수 판정 중 [유지] t2-3 "참조 구조".

## 0-y. 완료: 배치 C(SOA 20) — main 배포됨 (2026-06-12)

검수 게이트 판정 5건 반영(필수 2: t2-4 §4 버전 ID 인과·t4-2 §3 "반드시" 단정 / 권장 2: t2-1 "비례 응답"·t4-2 Q5 관리형 Automation 문서 용어 / 유지 1) → 20개 lastVerified=2026-06-12(+출처 줄 병기) → main 병합·배포·브랜치 삭제. 리뷰 실적: 단정·내부 구현 보수화 ~25건, SAA 동주제 표절 블록 5건 재작성, 무출처 수치 4건 제거, T 패밀리 모드 일반화 선제 교정, 포인터 라벨·길이 교정 ~27건.

## 0-z. 완료: 배치 B(SAA 24) — main 배포됨 (2026-06-12)

검수 피드백 8건(공식 문서 WebFetch 대조) 반영 → 24개 lastVerified=2026-06-12 → main 병합(681b193)·배포·브랜치 삭제. 핵심 교정: 스팟 '경매' 모델(기존 본문 포함)·TGW 중복 CIDR 미지원·T 패밀리 모드 구분·SR-IOV DMA 제거·LSI 보수화·CUR backfill. **검수-존치 플래그(미지적 — 필요 시 재론):** t1-2 '권한 세트' 행 · t3-6 RCU/WCU 행 · t3-8 '비전이' 행 · t3-9 Kinesis 설계 의도 · t4-4 '캐시 히트율' 행.

- **배치 C 준비·실행 기록:** 사전 점검 결과 SOA 코드 펜스 오염 0건(테스트 보강 불필요), `####` 0건, 캡 케이스 없음(서브섹션 5~8), 기존 왜-Q 4개 문서(t2-2·t3-2·t3-4·t5-1)는 Q 생략(t1-5 전례). RED 29e7c67(+133 -56) → 문서별 루프(배치 B 검증 패턴 + 개선: 블록 줄 수 직접 세기·포인터 1:1 대조·실재성 전수 검사표 강제·교차 정합 재검·컨트롤러 tail 실측+스팟 체크) → 전체 그린.
- **테스트 카운팅(main 반영됨, faa16d9):** `^### `만 카운트(#### 제외) + 하한 캡 8.

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

**다음 세션 첫 수: §0 모의고사 중량·증가 검토 브레인스토밍. 그 외 대기: §0-b 선택 항목(2기기 pull·개인정보 고지).**
