# Session Handoff — 2026-06-06 (START HERE 다음 세션)

> 한 줄 상태: **clf-t2-1 검증 콘텐츠 + 학습 루프 기반(#1: 렌더러·퀴즈·이력) 완성·main 병합·배포. 다음 = (1순위) 다음 CLF Task 콘텐츠 → (2순위) 하위 프로젝트 #2(타이머·플래그).**

> 갱신: 2026-06-06 세션 2 (clf-t2-1 콘텐츠 + 학습 루프 #1 구현 완료 시점)

## 지금 어디에 있나
- **라이브:** https://velkaressiablutkrone.github.io/aws-docs/ (GitHub Pages, `main` push 시 자동 배포)
- **저장소:** VelkaressiaBlutkrone/aws-docs · 브랜치 `main`
- **스택:** Flutter Web. 앱 코드 `flutter_app/`. (옛 Vite/바닐라-TS는 철거됨)
- **상태:** clf-t2-1 검증 콘텐츠 완성(학습문서 + 문항 5/5) + 학습 루프 **#1(렌더러·퀴즈·localStorage 이력)** 구현·main 병합. 콘텐츠 CLF **1/19 Task**. 렌더러 완성 → 이후 Task는 콘텐츠만 추가하면 즉시 노출.

## 이번 세션(들)에서 한 것
1. **디자인 시스템** — `DESIGN.md` ("조용한 레퍼런스", verified 틸 `#0E8175`, Pretendard+JetBrains Mono, 라이트/다크). 구현: `flutter_app/lib/theme/app_theme.dart`.
2. **Flutter Web 마이그레이션** — 홈/자격증 카드/로드맵/상세. 12개 자격증 데이터 `lib/data/site_data.dart`. (SCS-C02→**C03** 정정 포함)
3. **12개 자격증 공식 시험 가이드** — `flutter_app/assets/exam_guides/{code}.json` (193 Task) + 한국어 요약본 `assets/exam_summaries.json`. 상세 페이지 `lib/pages/cert_detail_page.dart`가 공식 가이드 본문 + 요약본을 별도로 렌더.
4. **배포** — `.github/workflows/pages.yml` = Flutter web 빌드(`--base-href /aws-docs/`). CI success 확인.
5. **콘텐츠 플레이북** — `docs/plans/2026-06-06-content-production-playbook.md` (이번 office-hours 산출물).

## ▶ 다음 행동 (다음 세션 — 순서대로)

> 직전 세션(2) 완료: clf-t2-1 콘텐츠 + 학습 루프 **하위 프로젝트 #1(기반: 렌더러·퀴즈·이력)** 구현·main 병합·배포.
> 설계/계획: `docs/designs/2026-06-06-clf-learning-loop-foundation-spec.md`(4개 하위 프로젝트 분해), `docs/plans/2026-06-06-clf-learning-loop-foundation-plan.md`.

**1순위 — 다음 CLF Task 콘텐츠 생산**
- `clf-t2-1` 템플릿(`flutter_app/assets/content/clf/t2-1.{md,questions.json}`)을 복제. 추천: 비중 큰 도메인 2의 `clf-t2-3`(접근 관리/IAM) 또는 `clf-t2-2`.
- 복제 경로 3단계: ① `t2-X.md`(YAML 프런트매터 + 섹션: 목표→🎯왜→📖핵심→✍️시험포인트→⚠️함정→🧪자가점검→📌출처) ② `t2-X.questions.json`(검증 문항 ≥5, 각 문항 sources[] + verified) ③ `lib/data/content_index.dart`에 `ContentEntry` 한 줄 추가.
- 규율 유지: **verified 게이트(출처 URL 필수) + AI 역대조** 2차 점검. 렌더러가 이미 있어 추가 즉시 사이트 노출. **취업/DIO 섹션 제외.**

**2순위 — 학습 루프 하위 프로젝트 #2**
- E3 실전 타이머 + 자동 제출 + 세션 복원, E4 문항 플래그. 같은 흐름(spec → plan → subagent-driven).
- 이력 스키마 D14는 이미 `wrongQuestionIds`/`durationSpentSec` 기록 중 → #2뿐 아니라 #3(E1 오답노트/E2 약점리포트)의 데이터 기반도 준비됨.

> 게이트 유지: CLF 1개 완성 우선. 콘텐츠 커버리지(현재 1/19)를 늘리는 게 여전히 진짜 병목.

## 생산 규율 (플레이북 합의)
- 문항 = **A+B 혼합** (Task 직렬 척추 + 약점 우선, C(AI 소크라테스)는 어려운 Task 옵션)
- **verified = 출처 URL 기록이 필수** (출처 없으면 빌드 제외 = 해자의 작동 원리)
- 모든 verified 문항 **AI 역대조** 2차 점검 (초보 검수의 "틀린 이해 박제" 방지)
- 학습문서 척추 = **공식 Task** (`examGuideTaskId`), Phase/Step은 "추천 학습 순서" 로드맵 오버레이로만
- 커버리지 목표: CLF 19 Task × ≥5 = **≥95 verified** (스트레치 ~130)

## 열린 항목 / 주의
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
