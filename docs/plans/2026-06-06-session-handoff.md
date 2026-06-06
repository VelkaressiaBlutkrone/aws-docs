# Session Handoff — 2026-06-06 (START HERE 다음 세션)

> 한 줄 상태: **clf-t3-7(AI/ML·분석, 7문항) + clf-t3-8(기타 서비스, 6문항) 콘텐츠 완성 → 🎉 도메인 3(34%) 8/8 완성. 커버리지 12/19 Task·검증 78문항. analyze 무이슈·test 21·build web green·main 커밋·push·배포 완료. 도메인 2+3 = 시험 비중 64% 완성. 다음 = (1순위) 도메인 1(24%, 4 Task) 또는 도메인 4(12%, 3 Task) → (2순위) 하위 프로젝트 #3(오답노트·약점리포트).**

> 갱신: 2026-06-06 세션 8 종료 (clf-t3-7 + clf-t3-8 콘텐츠 완성·커밋·배포 시점. 도메인 3 완성 8/8, 커버리지 12/19·검증 78문항)

## 지금 어디에 있나
- **라이브:** https://velkaressiablutkrone.github.io/aws-docs/ (GitHub Pages, `main` push 시 자동 배포)
- **저장소:** VelkaressiaBlutkrone/aws-docs · 브랜치 `main`
- **스택:** Flutter Web. 앱 코드 `flutter_app/`. (옛 Vite/바닐라-TS는 철거됨)
- **상태:** 렌더러·퀴즈·시험모드 그릇 완성. 콘텐츠 CLF **12/19 Task**(도메인 2: t2-1~t2-4 4개 / 도메인 3: t3-1~t3-8 8개 = **검증 78문항**). **도메인 2(30%) + 도메인 3(34%) 모두 완성 → 시험 비중 64% 커버.** 남은 = 도메인 1(24%·4 Task)·도메인 4(12%·3 Task). 렌더러 완성 → 콘텐츠 추가 즉시 노출.

## 이번 세션(들)에서 한 것
1. **디자인 시스템** — `DESIGN.md` ("조용한 레퍼런스", verified 틸 `#0E8175`, Pretendard+JetBrains Mono, 라이트/다크). 구현: `flutter_app/lib/theme/app_theme.dart`.
2. **Flutter Web 마이그레이션** — 홈/자격증 카드/로드맵/상세. 12개 자격증 데이터 `lib/data/site_data.dart`. (SCS-C02→**C03** 정정 포함)
3. **12개 자격증 공식 시험 가이드** — `flutter_app/assets/exam_guides/{code}.json` (193 Task) + 한국어 요약본 `assets/exam_summaries.json`. 상세 페이지 `lib/pages/cert_detail_page.dart`가 공식 가이드 본문 + 요약본을 별도로 렌더.
4. **배포** — `.github/workflows/pages.yml` = Flutter web 빌드(`--base-href /aws-docs/`). CI success 확인.
5. **콘텐츠 플레이북** — `docs/plans/2026-06-06-content-production-playbook.md` (이번 office-hours 산출물).

## ▶ 다음 행동 (다음 세션 — 순서대로)

> 직전 세션(8) 완료: **clf-t3-7 콘텐츠(AI/ML·분석, 검증 7문항)** + **clf-t3-8 콘텐츠(기타 서비스, 검증 6문항)** → **🎉 도메인 3 완성(8/8)**. 공식 AWS 문서 12종 실페치 대조, 독립 서브에이전트 역대조 **t3-7 7/7 + t3-8 6/6 CORRECT**(SageMaker→SageMaker AI, QuickSight→Amazon Quick 리네이밍 병기·출처 표기 보정). analyze 무이슈·test 21·`build web --release` green·main 커밋·push·배포 완료. 직전 세션(7): clf-t3-5 + clf-t3-1 → 도메인 3 6/8(커밋 `44ddd28`).
> 설계/계획: `docs/designs/2026-06-06-clf-learning-loop-subproject-2-spec.md`, `docs/plans/2026-06-06-clf-learning-loop-subproject-2-plan.md`.

**1순위 — 다음 CLF Task 콘텐츠 생산 (진짜 병목)** — **도메인 2·3 완성(12/19). 남은 = 도메인 1(24%, 4 Task: t1-1~t1-4) + 도메인 4(12%, 3 Task: t4-1~t4-3).**
- 추천: **도메인 1(클라우드 개념)** 먼저 — `clf-t1-1` 클라우드 이점(규모의 경제·민첩성·탄력성), `clf-t1-2` Well-Architected 6개 기둥, `clf-t1-3` 마이그레이션·AWS CAF, `clf-t1-4` 클라우드 경제학(고정비 vs 변동비·관리형 서비스). 4개로 도메인 통째 완성. 이후 도메인 4(요금 모델·결제·Support 플랜).
- `t2-1`~`t3-3` 템플릿 복제. 복제 경로 3단계: ① `tX-Y.md`(목표→🎯왜→📖핵심→✍️시험포인트→⚠️함정→🧪자가점검→📌출처) ② `tX-Y.questions.json`(검증 ≥5, sources[]+verified:true) ③ `content_index.dart` 한 줄(에셋 폴더는 pubspec에 디렉터리 통째 등록돼 자동 번들).
- 규율 유지: **verified 게이트(출처 URL 필수) + AI 역대조** 2차 점검(실제 공식 문서 페치 대조). 취업/DIO 제외. 커밋 방식: 이 세션은 main 직접 커밋·push(사용자 선택).

**2순위 — 학습 루프 하위 프로젝트 #3**
- E1 오답노트(틀린 문항 재응시) + E2 약점 리포트. 이력 D14의 `wrongQuestionIds`·`flaggedQuestionIds`(이제 시험 모드가 기록 중) + `durationSpentSec`가 데이터 기반. 같은 흐름(brainstorm → spec → plan → subagent-driven).

> 게이트 유지: CLF 콘텐츠 커버리지(현재 **12/19**)를 늘리는 게 여전히 진짜 병목. **도메인 2(30%)+3(34%) 완성(비중 64%).** 남은 = 도메인 1(24%)·4(12%) = 7 Task·비중 36%.

## 생산 규율 (플레이북 합의)
- 문항 = **A+B 혼합** (Task 직렬 척추 + 약점 우선, C(AI 소크라테스)는 어려운 Task 옵션)
- **verified = 출처 URL 기록이 필수** (출처 없으면 빌드 제외 = 해자의 작동 원리)
- 모든 verified 문항 **AI 역대조** 2차 점검 (초보 검수의 "틀린 이해 박제" 방지)
- 학습문서 척추 = **공식 Task** (`examGuideTaskId`), Phase/Step은 "추천 학습 순서" 로드맵 오버레이로만
- 커버리지 목표: CLF 19 Task × ≥5 = **≥95 verified** (스트레치 ~130)

## 열린 항목 / 주의
- **#2 시험 모드 후속(비차단 · 리뷰 지적):** ① `QuizPage`도 "로드 에러 vs 빈 bank" 메시지 혼동(`ExamPage`엔 `snap.hasError` 분기 넣음 — 동일 적용 권장) · ② `quiz_widgets`의 기존 매직넘버(width:3·height:4·bottom:2) 토큰화 · ③ `ExamPage._load()` 복원/clear 분기는 페이지 레벨 테스트 없음(자산 결합 — 순수 로직 추출 시 가능) · ④ `AttemptRecord.mode`/`flaggedQuestionIds`는 #3까지 write-only(의도된 선행 계약, #3에서 소비).
- **수동 스모크 미실행:** #2는 자동 테스트(21)·web build로만 검증. 권장: `flutter run -d chrome`로 시험 모드 직접 확인(타이머·새로고침 복원·자동제출·플래그 점프).
- **SEO:** Flutter 캔버스라 한국어 검색 노출 약함. CLF 콘텐츠 완성 후 보완(메타/프리렌더/핵심 HTML 병행) — 지금은 불필요.
- **SAA 자료(`D:\Download\files.zip`):** 본인이 만든 완성 SAA 코퍼스(27 학습문서 + Mock ~110 + 종합 325 + HTML 앱). **템플릿만 지금 차용, 콘텐츠는 CLF 합격 후.** 그 325 문항은 출처 기록 없는 비검증 초안 → SAA 단계에서 출처 앵커 재검증 필수.
- **게이트:** CLF 1개 완성 우선. 12개 동시 진행 금지(메타데이터 수정은 예외).

## 실행 명령
```bash
cd flutter_app
flutter run -d chrome                              # 개발
flutter analyze && flutter test                    # 검증
flutter build web --release --base-href /aws-docs/ # 빌드(배포는 main push 시 CI 자동)
```

## 참고 문서
- 전략: `docs/plans/2026-06-05-design-aws-cert-site.md` (APPROVED)
- 학습 루프(E1~E6): `docs/designs/clf-learning-loop.md`
- CLF Task 매핑(19): `docs/plans/clf-c02-task-mapping.md`
- 콘텐츠 플레이북: `docs/plans/2026-06-06-content-production-playbook.md`
