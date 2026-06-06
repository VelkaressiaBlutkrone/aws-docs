# Session Handoff — 2026-06-06 (START HERE 다음 세션)

> 한 줄 상태: **🏁 Spec 1(IA 재조정 + go_router 라우팅) + Spec 2(cert-wide 통합 모의고사) 배포 완료. CLF 검증 문항 118 → 130(드래프트 12 flip). 통합 모의고사 라이브: `/cert/CLF-C02/exam` → 시작화면 → 도메인 가중 65문항 샘플·채점·복원. analyze 무결·41 테스트·web 빌드·opus 리뷰 APPROVE·실브라우저 headless dogfood 통과·origin/main push(`d00f656`). 다음 = 학습 루프 하위 프로젝트 #3(E1 오답노트·E2 약점 리포트) 또는 비-CLF 콘텐츠.**

> 갱신: 2026-06-06 — "3-2-1" 세션 종료(문서 정리 + 문항 12 flip + Spec 2 통합 모의고사 brainstorm→spec→plan→구현→리뷰→dogfood→배포). 직전: Spec 1(라우팅) 배포(`18322ce`), 그 이전: 세션 11 CLF 콘텐츠 19/19 완주.

## ⚠️ 환경 (먼저 읽기 — 매 세션 함정)
- **이중 폴더:** 작업 루트는 `D:\workspace\awc-docs`이고, 실제 저장소·코드는 그 안의 **`aws-docs\`** 하위에 있다. 즉 코드 = `D:\workspace\awc-docs\aws-docs\flutter_app`. **상대경로에 `aws-docs\` 접두사를 빼면 파일을 못 찾는다.**
- **작업 디렉터리:** flutter/test/analyze는 `aws-docs\flutter_app`에서, git은 `aws-docs`에서(`git -C "D:\workspace\awc-docs\aws-docs" …`).
- **flutter 명령은 PowerShell로** 실행(Git Bash는 `--base-href` 경로를 망가뜨림). PowerShell `Set-Location`은 이후 파일 도구의 상대경로 베이스도 바꾸니 주의 → 절대경로 권장.
- **커밋:** 사용자 선택으로 `main` 직접 커밋·push(피처 브랜치 아님).

## 지금 어디에 있나
- **라이브:** https://velkaressiablutkrone.github.io/aws-docs/ (GitHub Pages, `main` push 시 자동 배포)
- **저장소:** VelkaressiaBlutkrone/aws-docs · 브랜치 `main` (origin과 동기, 최신 `d00f656`)
- **스택:** Flutter Web (Dart, `flutter_app/`) + go_router(해시 라우팅). 옛 Vite/바닐라-TS는 철거됨. (CLAUDE.md/DESIGN.md 표기도 이번에 정정.)
- **콘텐츠:** CLF-C02 19/19 Task, **검증 130문항**(도메인별 풀 D1 27 · D2 31 · D3 51 · D4 21). 나머지 11개 자격증은 "준비 중".
- **라우트:** `/`, `/cert/:code`, `/cert/:code/study/:taskId`, `…/quiz`, `…/exam`(Task별 시험), `/cert/:code/exam`(통합 모의고사 — 이번에 구현).

## 이번 세션에서 한 것 ("3-2-1")
1. **문서 정리**(`4d7e66e`) — `CLAUDE.md`/`DESIGN.md` 스택 표기 "Vite + 바닐라 TS" → "Flutter Web (Dart) + go_router". (DESIGN.md 폰트 CDN 섹션은 실제 번들 OTF/TTF와 어긋남 — 미정리, 플래그만.)
2. **문항 12 flip**(`e4701a6`) — `t1-3·t2-1·t4-3`의 `verified:false` 드래프트 4개씩 정독·검토 후 flip. `content_index.dart` 카운트(5→9)와 t2-1 하드코딩 테스트(5→9) 동기화. 검증 118 → **130**.
3. **Spec 2 — cert-wide 통합 모의고사**(`7bc37b6`…`51de965`,`d00f656`):
   - `lib/data/mock_exam.dart`(신규, 순수 Dart): `allocateByWeight`(largest-remainder, 합=N) · `buildMockExam`(도메인 가중 샘플·rng 주입·풀부족 보충) · `groupByDomain`/`indexById`/`restoreOrdered`.
   - `ExamSession.questionIds`(신규 필드) + `ExamView._session()` 1줄 → 출제 ID 순서 보존(복원용).
   - `CertExamPage` 재작성(placeholder→실구현): 19개 뱅크 로드·병합 → 시작화면(문항수·시간·도메인비중·합격선, '시작'/'이어서 풀기'/'새로 시작') → `buildMockExam` → 기존 `ExamView` 재사용(합성 `QuestionBank` 주입, examId `exam:<code>-mock`). 라우터 무변경.
   - 검증: analyze 무결 · **41 테스트** green · 릴리스 web 빌드 · **opus 코드리뷰 APPROVE**(allocateByWeight 2만 케이스 스트레스) · **실브라우저 headless dogfood**(gstack browse) 시작화면·'시작'→65문항 가중 출제·타이머 90:00 확인.
   - Spec: `docs/superpowers/specs/2026-06-06-cert-wide-exam-design.md` · Plan: `docs/superpowers/plans/2026-06-06-cert-wide-exam.md`.

## ▶ 다음 행동 후보 (우선순위 제안)
**1순위 — 학습 루프 하위 프로젝트 #3 (E1 오답노트 + E2 약점 리포트).**
- 데이터 준비됨: 시험/퀴즈가 `AttemptRecord`(D14)에 `wrongQuestionIds`·`flaggedQuestionIds`·`durationSpentSec` 기록 중(`HistoryStore.add`). 단, **현재 이력을 표시하는 화면이 없음**(기록만) → #3가 첫 소비자.
- 흐름: brainstorm → spec → plan → subagent-driven (이번 세션과 동일).
- 설계 참고: `docs/designs/clf-learning-loop.md`, `docs/designs/2026-06-06-clf-learning-loop-subproject-2-spec.md`.

**2순위 — 비-CLF 자격증 콘텐츠.** 통합 모의고사·라우팅·렌더러는 이미 자격증 일반으로 작성됨 → `content_index.dart`에 Task 등록 + `tX-Y.md`/`tX-Y.questions.json` 채우면 즉시 동작. (콘텐츠는 CLF 합격 후 권장.)

**스트레치/정리(비차단):** Spec 2 리뷰 Minor — `_MockLoad`의 `existing`/`restoredQuestions` 상관 nullability를 단일 레코드로 하드닝(선택). CLF 약점 Task 문항 보강(~목표 상향).

## 통합 모의고사 (Spec 2) 빠른 참조
- 진입: 랜딩 "모의고사" 섹션 / cert 상세 → `/cert/CLF-C02/exam`.
- 복원: 진행 중(미제출) 세션은 `questionIds`로 동일 문항·순서·진행 복원. 콘텐츠 개정으로 ID 하나라도 사라지면 전량 폐기 후 새 시험(안전).
- 세션 키: `exam:<code>-mock`(Task 시험 `exam:clf-tX-Y`와 분리). 점수는 정답률 표시(1000점 환산은 범위 밖).

## 열린 항목 / 주의
- **테스트 함정(중요, 확장됨):** `SelectionArea`+비동기 페이지(CertDetail/StudyDoc/Quiz/Exam)는 위젯 테스트 렌더 시 "RenderBox was not laid out" 크래시. **자식 라우트 `/cert/:code/exam`도 go_router가 부모 CertDetailPage를 스택에 빌드하므로 렌더 불가** → 렌더 스모크 금지. 순수 로직 단위테스트 + `ExamView` 모델주입 테스트 + analyze + 수동/headless dogfood로 커버. (헤드리스 dogfood는 CanvasKit라 'Enable accessibility'를 JS click해 시맨틱 켠 뒤 @ref 구동.)
- **기존 #2 시험모드 후속(비차단):** ① `QuizPage`도 "로드 에러 vs 빈 bank" 메시지 혼동(`ExamPage`엔 `snap.hasError` 분기 있음 — 동일 적용 권장) · ② `quiz_widgets` 매직넘버 토큰화 · ③ `AttemptRecord.mode`/`flaggedQuestionIds`는 #3까지 write-only(의도된 선행 계약).
- **DESIGN.md 폰트 CDN 섹션:** "로딩(CDN, SRI 고정)"이라 돼 있으나 실제는 pubspec 번들 OTF/TTF. 정리하려면 사용자 확인 후.
- **SEO:** Flutter 캔버스라 한국어 검색 노출 약함. 콘텐츠 안정화 후 보완(메타/프리렌더) — 지금 불필요.
- **SAA 자료(`D:\Download\files.zip`):** 본인 제작 SAA 코퍼스(27 문서 + Mock ~110 + 종합 325 + HTML). **템플릿만 차용, 콘텐츠는 CLF 합격 후.** 325 문항은 비검증 초안 → 출처 앵커 재검증 필수.
- **게이트:** 한 번에 한 자격증. 12개 동시 진행 금지(메타데이터 수정은 예외).

## 생산 규율 (콘텐츠 작업 시)
- **verified = 출처 URL 필수**(없으면 `QuestionBank.fromJson`이 빌드에서 제외 = 해자). 새 문항은 `verified:false` 드래프트로 넣고 검토 후 flip; flip 시 `content_index` `questionCount`와 (있다면) 하드코딩 테스트 동기화.
- 모든 verified 문항 **AI 역대조** 2차 점검(공식 문서 페치 대조). options 정확히 4개·모든 오답에 wrongExplanations·skill/difficulty 채움.
- 학습문서 척추 = 공식 Task(`examGuideTaskId`).

## 실행 명령 (PowerShell, in `aws-docs\flutter_app`)
```powershell
flutter run -d chrome                                  # 개발
flutter analyze ; flutter test                         # 검증(현재 41 테스트)
flutter build web --release --base-href /aws-docs/     # 배포 빌드(배포는 main push 시 CI 자동)
# headless dogfood: flutter build web --base-href / → py -m http.server 5151 --directory build\web
#   → gstack browse: goto http://localhost:5151/#/cert/CLF-C02/exam (CanvasKit라 'Enable accessibility' JS click 후 @ref)
```

## 참고 문서
- 전략: `docs/plans/2026-06-05-design-aws-cert-site.md` (APPROVED)
- 라우팅(Spec 1): `docs/superpowers/specs/2026-06-06-ia-reconcile-routing-design.md` · `docs/superpowers/plans/2026-06-06-ia-reconcile-routing.md`
- 통합 모의고사(Spec 2): `docs/superpowers/specs/2026-06-06-cert-wide-exam-design.md` · `docs/superpowers/plans/2026-06-06-cert-wide-exam.md`
- 학습 루프(E1~E6): `docs/designs/clf-learning-loop.md`
- CLF Task 매핑(19): `docs/plans/clf-c02-task-mapping.md`
- 콘텐츠 플레이북: `docs/plans/2026-06-06-content-production-playbook.md`

> 참고: 크로스세션 메모리(`~/.claude/projects/D--workspace-awc-docs/memory/`)도 현행화됨 — `MEMORY.md` 인덱스 + `ia-routing-shipped-next-cert-exam`(Spec 2 배포), `question-bank-verified-workflow`(검증 130), `flutter-selectionarea-widget-test-pitfall`(자식 라우트 확장), `flutter-build-web-powershell`.
