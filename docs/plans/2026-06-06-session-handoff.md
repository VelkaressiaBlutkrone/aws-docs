# Session Handoff — 2026-06-07 (START HERE 다음 세션)

> 한 줄 상태: **🏁 Spec 1·Spec 2 + 우선순위 로드맵 + Phase 0(정리) + Phase 1 전체(E1 오답노트 + E2 약점리포트) 완료. E2 라이브: cert 상세 "약점 리포트" 진입 → `/cert/:code/report` → 요약(전체 정답률) + Task별 정답률 표(문항별 최신결과, 복습 제외), weak(<70%)은 wrong 톤 + 학습문서 "처방" 링크, 미응시 구분. 순수 `TaskScoreReport`로 파생, E1의 출제해석은 `attempt_presented` 공유 헬퍼로 추출. analyze 무결·63 테스트·릴리스 빌드·실브라우저 dogfood(요약 50%·weak 33% 처방링크 동작·미응시) 통과. E1은 origin push 완료, E2는 로컬 커밋(push 전이면 다음 세션). 다음 = Phase 2(E5 진행률 + E6 가중 모의고사). 계획: `2026-06-07-phase1-e2-weakness-report.md`(완료).**

> 갱신: 2026-06-07 — 브레인스토밍으로 우선순위 로드맵 작성 → Phase 0 구현 계획 → executing-plans로 Phase 0 4개 Task 완료(로컬 커밋 `debd590`·`44d1bc9`·`4ce5124`, 아직 origin push 전이면 다음 세션에서 push). 직전 세션: Spec 2 통합 모의고사 배포(`d00f656`).

## ⚠️ 환경 (먼저 읽기 — 매 세션 함정)
- **폴더 구조(정정 2026-06-07):** git 루트 = `D:\workspace\awc-docs`이고, Flutter 코드는 그 **바로 아래 `flutter_app\`**에 있다(= `D:\workspace\awc-docs\flutter_app`). 과거 핸드오프의 "`aws-docs\` 하위" 표기는 이 체크아웃에선 **틀림** — `aws-docs\` 중간 폴더는 없다. docs는 루트의 `docs\`.
- **작업 디렉터리:** flutter/test/analyze는 `flutter_app`에서, git은 루트에서. **git은 절대 `-C D:/workspace/awc-docs` 사용**(PowerShell Set-Location이 Bash 도구 cwd까지 바꿔 상대경로가 깨진 사례 있음).
- **flutter 명령은 PowerShell로** 실행(Git Bash는 `--base-href` 경로를 망가뜨림). PowerShell `Set-Location`은 이후 파일 도구·Bash 도구의 cwd 베이스도 바꾸니 주의 → 절대경로 권장.
- **커밋:** 사용자 선택으로 `main` 직접 커밋·push(피처 브랜치 아님).

## 지금 어디에 있나
- **라이브:** https://velkaressiablutkrone.github.io/aws-docs/ (GitHub Pages, `main` push 시 자동 배포)
- **저장소:** VelkaressiaBlutkrone/aws-docs · 브랜치 `main` (origin과 동기, 최신 `871d82b`)
- **스택:** Flutter Web (Dart, `flutter_app/`) + go_router(해시 라우팅). 옛 Vite/바닐라-TS 철거됨.
- **테스트:** **63개 green**(순수 단위 + 모델주입 위젯 + 라우팅 redirect). analyze 무결, 릴리스 빌드 OK.
- **콘텐츠:** CLF-C02 19/19 Task, **검증 130문항**(D1 27 · D2 31 · D3 51 · D4 21). 나머지 11개 자격증 "준비 중".
- **라우트:** `/`, `/cert/:code`, `/cert/:code/study/:taskId`, `…/quiz`, `…/exam`(Task별 시험), `/cert/:code/exam`(통합 모의고사), **`/cert/:code/review`(오답노트)**, **`/cert/:code/report`(약점 리포트)**.

## 이번 세션에서 한 것 (2026-06-07 — 로드맵 + Phase 0/1)
모두 brainstorm→spec→plan→TDD 구현→dogfood→배포(origin/main) 사이클. 테스트 41 → **63**.
1. **우선순위 로드맵**(`9000e62`) — `specs/2026-06-07-work-priority-roadmap-design.md`. 정리→루프완결(E1/E2,E5/E6)→콘텐츠 4단계 게이트.
2. **Phase 0 정리/부채**(`debd590`·`44d1bc9`·`4ce5124`) — `CertExamPage._MockLoad`→단일 `_Restorable` 레코드 하드닝(`!` 제거) · `quiz_widgets` 간격 리터럴→`Gap` 토큰 · DESIGN.md 폰트 표기 CDN→로컬 번들 정정. (항목 ② QuizPage 분기는 이미 구현돼 있어 제외.)
3. **Phase 1 E1 오답노트**(`3aef977`·`c55cfe7`·`1c79a2a`·`ce796ae`·`de70280`·`8720305`):
   - `AttemptRecord.presentedQuestionIds`(하위호환) + 연습/시험 작성자 기록(통합 모의고사 자동 포함).
   - `lib/data/wrong_answer_index.dart`(순수: weak/mastered=서로 다른 회차 연속 2회 정답, weakByTask, weakEntries, stale 제외, 레거시 폴백).
   - `QuizView`에 `mode`/`examId` 주입(복습 러너 재사용, 별도 ReviewView 미생성) + `lib/pages/review_page.dart`(`ReviewListPage`) + `/cert/:code/review` + cert 상세 "오답 N" 배지·오답노트 진입.
4. **Phase 1 E2 약점 리포트**(`bac8ceb`·`ac9c4ec`·`f879b51`·`72c1e7a`):
   - `lib/data/attempt_presented.dart`(출제 해석 공유 헬퍼 — E1·E2 공용, 드리프트 방지).
   - `lib/data/task_score_report.dart`(순수: review 제외 문항별 최신결과 평균, `kWeakThreshold=0.7`, 미응시/weak/ok, overallRate/hasAnyAttempt).
   - `lib/pages/report_page.dart`(`/cert/:code/report`: 요약+Task표, weak<70% wrong톤+학습문서 처방 링크, 미응시 muted) + cert 상세 약점 리포트 진입(accent).
   - dogfood: 전체 50%·공동책임모델 33% weak+처방 링크→학습문서 이동·미응시 확인.

## ▶ 다음 행동 (로드맵 기준)
**확정 로드맵:** `docs/superpowers/specs/2026-06-07-work-priority-roadmap-design.md` — 정리(Phase 0 ✅) → 루프완결 Phase 1(E1/E2) → Phase 2(E5/E6) → Phase 3(콘텐츠).

**다음 = Phase 2 (E5 진행률 + E6 가중 모의고사, 별도 brainstorm→spec→plan).** Phase 1 전체(E1 오답노트 + E2 약점리포트) 완료. **Phase 2 범위(로드맵 §5):** E5 진행률(문서 열람률 + 최고점수·마지막 응시일, 정직 표시) · E6 약점 가중 모의고사(Task별 누적 오답률 비례 가중, 이력 3회+ 게이트, `buildMockExam` 확장). E6는 `WrongAnswerIndex`/`TaskScoreReport` 데이터에 의존.
- **E2 구현 노트(다음 작업자용):** `lib/data/attempt_presented.dart`(공유 헬퍼: `resolvePresented`·`taskFromExamId` — E1·E2 공용, "무엇이 출제됐나" 단일 정의). `lib/data/task_score_report.dart`(`TaskScoreReport.build({certId,history,taskByQuestionId,taskOrder})` → tasks/overallRate/hasAnyAttempt; review 제외, 문항별 최신결과, `kWeakThreshold=0.7`). `lib/pages/report_page.dart`(`/cert/:code/report`, 19뱅크 로드→build→표). cert 상세에 약점 리포트 진입(accent) + 오답노트 진입(wrong) 둘 다 존재.
- **Phase 1 누적 구현 노트:** E1 — `QuizView` mode/examId 재사용·`review_page.dart`·`wrong_answer_index.dart`·cert 상세 "오답 N" 배지. 페이지는 SelectionArea라 렌더 테스트 금지 → 순수 모듈 단위 테스트 + 라우팅 redirect + dogfood.
- **Phase 0 잔여(후속 결정):** quiz_widgets **폰트 크기 토큰화**는 보류 — DESIGN.md 타입스케일(13·15·16·17·20·28)이 코드 실제값(12·14)과 어긋나 "코드 유지 vs 문서 정렬(소폭 시각 변화)" 사용자 결정 필요. 테두리 두께 토큰도 DESIGN.md 미정의.

**Phase 2 설계 참고:** `docs/designs/clf-learning-loop.md` E5/E6 절(가중치=Task 누적 오답률 비례, 최소가중 보장, 3회 게이트, T3 시작게이트 동일). E5 진행률 정의(열람=`<details>`/섹션 펼침), 멀티탭 last-write-wins, 빈 상태 명세 포함.

**Phase 3 — 비-CLF 콘텐츠(게이트: 본인 CLF 합격 후).** 엔진은 자격증 일반 → `content_index.dart`에 Task 등록 + `tX-Y.md`/`tX-Y.questions.json` 채우면 즉시 동작.

## 통합 모의고사 (Spec 2) 빠른 참조
- 진입: 랜딩 "모의고사" 섹션 / cert 상세 → `/cert/CLF-C02/exam`.
- 복원: 진행 중(미제출) 세션은 `questionIds`로 동일 문항·순서·진행 복원. 콘텐츠 개정으로 ID 하나라도 사라지면 전량 폐기 후 새 시험(안전).
- 세션 키: `exam:<code>-mock`(Task 시험 `exam:clf-tX-Y`와 분리). 점수는 정답률 표시(1000점 환산은 범위 밖).

## 열린 항목 / 주의
- **테스트 함정(중요):** `SelectionArea`+비동기 로더 페이지(CertDetail/StudyDoc/Quiz/Exam/**Review/Report**)는 위젯 렌더 테스트 시 "RenderBox was not laid out" 크래시. 자식 라우트도 부모가 스택에 빌드돼 렌더 불가 → **렌더 스모크 금지.** 순수 로직 단위테스트 + `QuizView`/`ExamView` 모델주입 테스트 + 라우팅 redirect 테스트 + analyze + headless dogfood로 커버. (dogfood는 CanvasKit라 'Enable accessibility' JS click 후 @ref 구동.)
- **보류(후속 결정):** `quiz_widgets` **폰트 크기 토큰화** — DESIGN.md 타입스케일(13·15·16·17·20·28)이 코드 실제값(12·14)과 어긋나 "코드 유지 vs 문서 정렬(소폭 시각 변화)" 사용자 결정 필요. 테두리 두께 토큰도 DESIGN.md 미정의. (Phase 0에서 간격만 토큰화함.)
- **`flaggedQuestionIds` 복습:** E1은 오답(wrong)만 복습 큐로 사용. 플래그 문항 복습은 후속(E1 설계 §9).
- **SEO:** Flutter 캔버스라 한국어 검색 노출 약함. 콘텐츠 안정화 후 보완(메타/프리렌더) — 지금 불필요.
- **SAA 자료(`D:\Download\files.zip`):** 본인 제작 SAA 코퍼스(27 문서 + Mock ~110 + 종합 325 + HTML). **템플릿만 차용, 콘텐츠는 CLF 합격 후.** 325 문항은 비검증 초안 → 출처 앵커 재검증 필수.
- **게이트:** 한 번에 한 자격증. 12개 동시 진행 금지(메타데이터 수정은 예외).

## 생산 규율 (콘텐츠 작업 시)
- **verified = 출처 URL 필수**(없으면 `QuestionBank.fromJson`이 빌드에서 제외 = 해자). 새 문항은 `verified:false` 드래프트로 넣고 검토 후 flip; flip 시 `content_index` `questionCount`와 (있다면) 하드코딩 테스트 동기화.
- 모든 verified 문항 **AI 역대조** 2차 점검(공식 문서 페치 대조). options 정확히 4개·모든 오답에 wrongExplanations·skill/difficulty 채움.
- 학습문서 척추 = 공식 Task(`examGuideTaskId`).

## 실행 명령 (PowerShell, in `flutter_app` — 루트 바로 아래)
```powershell
flutter run -d chrome                                  # 개발
flutter analyze ; flutter test                         # 검증(현재 63 테스트)
flutter build web --release --base-href /aws-docs/     # 배포 빌드(배포는 main push 시 CI 자동)
# headless dogfood: flutter build web --base-href / → (PowerShell) Start-Process py -ArgumentList '-m','http.server','5151','--directory','D:\workspace\awc-docs\flutter_app\build\web' -WindowStyle Hidden
#   → gstack browse: goto http://localhost:5151/#/cert/CLF-C02/report (CanvasKit라 'Enable accessibility' JS click 후 @ref)
#   주의: Windows에서 'python'은 Store 스텁 → 'py' 사용. git은 절대 -C 또는 'cd /d/workspace/awc-docs'(Bash).
```

## 참고 문서
- 전략: `docs/plans/2026-06-05-design-aws-cert-site.md` (APPROVED)
- 라우팅(Spec 1): `docs/superpowers/specs/2026-06-06-ia-reconcile-routing-design.md` · `docs/superpowers/plans/2026-06-06-ia-reconcile-routing.md`
- 통합 모의고사(Spec 2): `docs/superpowers/specs/2026-06-06-cert-wide-exam-design.md` · `docs/superpowers/plans/2026-06-06-cert-wide-exam.md`
- **우선순위 로드맵:** `docs/superpowers/specs/2026-06-07-work-priority-roadmap-design.md`
- **Phase 0 정리:** `docs/superpowers/plans/2026-06-07-phase0-cleanup.md`
- **Phase 1 E1(오답노트):** spec `docs/superpowers/specs/2026-06-06-learning-loop-e1-design.md` · plan `2026-06-07-phase1-e1a-data-foundation.md`·`2026-06-07-phase1-e1b-review-ui.md`
- **Phase 1 E2(약점 리포트):** spec `docs/superpowers/specs/2026-06-07-learning-loop-e2-design.md` · plan `docs/superpowers/plans/2026-06-07-phase1-e2-weakness-report.md`
- 학습 루프(E1~E6) 원안: `docs/designs/clf-learning-loop.md`
- CLF Task 매핑(19): `docs/plans/clf-c02-task-mapping.md`
- 콘텐츠 플레이북: `docs/plans/2026-06-06-content-production-playbook.md`

> 참고: 크로스세션 메모리(`~/.claude/projects/D--workspace-awc-docs/memory/`)도 현행화됨 — `MEMORY.md` 인덱스 + `work-priority-roadmap-phase0`(로드맵·Phase 0/1 완료), `flutter-selectionarea-widget-test-pitfall`(Review/Report 페이지 추가), `question-bank-verified-workflow`(검증 130), `flutter-build-web-powershell`.
