# 작업 우선순위 로드맵 — 2026-06-07

- **상태:** 설계 승인됨 (2026-06-07, 브레인스토밍). 각 Phase는 차후 개별 spec→plan→구현.
- **목적:** Spec 1(라우팅)·Spec 2(통합 모의고사) 배포 후 남은 작업의 **단계별 순서와 완료 게이트**를 확정. 이 문서는 단일 기능 설계가 아니라 **순서·게이트만 정의하는 로드맵**이다. 각 기능 단계는 진입 시점에 자체 spec→plan→구현 사이클을 갖는다(이번 세션과 동일한 흐름).
- **대상 코드베이스:** `aws-docs/flutter_app` (Flutter Web, go_router 해시 라우팅, GitHub Pages 배포).
- **브랜드 제약:** `DESIGN.md` "조용한 레퍼런스 + 정직함". 새 디자인 언어 금지, 기존 테마 토큰·위젯 재사용.

## 1. 우선순위 결정 (브레인스토밍 2026-06-07)

사용자 확정 순서: **정리/부채 → 학습 루프 완결 → 콘텐츠**. (본인 CLF 학습은 별도 트랙으로 분리.)

| 결정 | 선택 | 근거 |
|---|---|---|
| 최우선 기준 | ① 정리 → ② 루프 완결 → ③ 콘텐츠 | 부채를 먼저 털고, 학습 루프 엔진(E1~E6)을 끝까지 완성한 뒤 콘텐츠 확장 |
| Phase 1 진입 구조 | 공통 집계 레이어(`WrongAnswerIndex`) + cert 상세 진입 (승인된 E1 설계 준수) | 기능별 화면 중복 방지. 새 "결과 화면" 추가 없이 기존 cert 상세에 얹음 |
| 산출물 형태 | 로드맵 문서(단계별 게이트) | 각 기능은 진입 시 개별 spec→plan |
| 정리 범위 | 4건 전부(아래 Phase 0) | 작고 독립적, 한 배치로 처리 |

## 2. 단계 개요

| Phase | 내용 | 의존성 | 완료 게이트 |
|---|---|---|---|
| **0. 정리/부채 상환** | 코드/문서 부채 4건 | 없음 | `flutter analyze` 무결 + 전체 테스트 green + 릴리스 web 빌드 |
| **1. 학습 루프 완결 ① (E1 + E2)** | `WrongAnswerIndex` 집계 → E1 오답노트·재응시 → E2 약점 리포트 | Phase 0 권장(부채 없는 상태에서 신규 화면) | 제출→오답 재응시(2연속 졸업)·Task별 약점표(70%↓ 학습문서 앵커) 동작 + 실브라우저 dogfood |
| **2. 학습 루프 완결 ② (E5 + E6)** | E5 진행률 카드 → E6 약점 가중 모의고사 | Phase 1(`WrongAnswerIndex`/Task 오답률 데이터 의존, 특히 E6) | 진행률 정직 표시 + 가중 출제(이력 3회+ 게이트) 동작 + dogfood |
| **3. 비-CLF 콘텐츠** | `content_index` 등록 + `tX-Y.md`/`.questions.json` | 엔진은 일반화 완료 | (게이트: 본인 CLF 합격 후 권장 — 한 번에 한 자격증 규칙) |

## 3. Phase 0 — 정리/부채 상환

독립적 4건. 한 배치(또는 원자적 커밋 4개)로 처리. **신규 기능 없음, 회귀 0 목표.**

1. **`_MockLoad` nullability 하드닝** (Spec 2 리뷰 Minor)
   - `CertExamPage`의 `_MockLoad`에서 `existing`/`restoredQuestions` 상관 nullability를 단일 레코드(둘 다 있거나 둘 다 없음)로 표현해 불변식을 타입으로 강제.
2. **`QuizPage` 로드 에러 vs 빈 bank 분기**
   - `ExamPage`의 `snap.hasError` 분기 패턴을 `QuizPage`에도 적용. "로드 실패"와 "검증 문항 0개"를 다른 메시지로.
3. **`quiz_widgets` 매직넘버 토큰화**
   - 하드코딩된 간격/크기 값을 `DESIGN.md` 토큰(테마 스페이싱)으로 교체. 시각 변화 없이 동일 렌더.
4. **`DESIGN.md` 폰트 표기 정정**
   - "CDN 로딩(SRI 고정)" → 실제 pubspec 번들 OTF/TTF 사실에 맞게 문서만 정정(코드 무변경).

**게이트:** `flutter analyze` 무결 + 전체 테스트 green(현재 41) + 릴리스 web 빌드. 항목 1~3은 테스트 회귀 확인 필수, 4는 문서.

## 4. Phase 1 — 학습 루프 완결 ① (E1 오답노트 + E2 약점 리포트)

> 하위 프로젝트 #3. **E1은 이미 설계 승인됨**: `docs/superpowers/specs/2026-06-06-learning-loop-e1-design.md`. 이 로드맵은 그 설계를 준수하며, E2를 같은 기반 위에 얹는다.

**공통 기반 (중복 방지의 핵심):**
- 현재 `AttemptRecord` 이력의 **소비자(표시 화면)가 없음** → Phase 1이 첫 소비자.
- 새 "결과 화면"을 만들지 않는다. 대신 **순수 집계 레이어 `WrongAnswerIndex`**(`lib/data/wrong_answer_index.dart`)가 단일 소비 기반이 되고, **cert 상세 페이지**가 단일 진입점이 된다. E1·E2 모두 이 둘을 공유한다.
- `AttemptRecord`에 `presentedQuestionIds` 추가(하위호환: 누락 시 `const []`, 레거시는 현재 뱅크=출제로 폴백). 정답 ID = `presentedQuestionIds − wrongQuestionIds`.

**E1 오답노트 (승인된 설계대로):**
- cert 상세 Task 행에 "오답 N" 배지 → `ReviewListPage`(Task별 묶음) → `ReviewView`(연습형 즉시 피드백 러너).
- 마스터 규칙: 서로 다른 응시에서 **연속 2회 정답 → 졸업**(노트에서 제외, history는 보존).
- 정직함: 복습은 `mode:'review'`로 기록, 헤드라인 연습/시험 정답률엔 미반영.

**E2 약점 리포트 (E1 기반 위에 추가):**
- 같은 `WrongAnswerIndex`/이력에서 **Task별 누적 정답률 표** 파생.
- "처방" = 정답률 **70% 미만 Task**에 해당 학습문서(`examGuideTaskId`) 앵커 링크.
- Task 매핑 없는 자격증은 전체/회차 점수로 **강등**(Task 리포트 비노출) — 현재 CLF만 매핑 보유.
- 빈 상태: 이력 0건 → "모의고사를 풀면 Task별 약점이 여기 표시됩니다".

**게이트:** 순수 집계/파생 단위 테스트 + `ReviewView` 모델주입/위젯 테스트 + analyze + 실브라우저 dogfood(제출→오답노트→2연속 졸업, 약점표 70%↓ 앵커). 페이지 위젯 렌더 테스트는 SelectionArea 함정으로 금지 — 단위/모델주입/dogfood로 커버.

## 5. Phase 2 — 학습 루프 완결 ② (E5 진행률 + E6 가중 모의고사)

> 하위 프로젝트 #4. 설계 참조: `docs/designs/clf-learning-loop.md` E5/E6 절.

**E5 진행률:**
- `문서 진도 = 열람 문서 수 / 현재 문서 총수`(열람 = `<details>`/섹션 펼침) + `최고 점수`·`마지막 응시일`.
- 정직함: 콘텐츠 증가로 분모가 커지면 진도율이 내려갈 수 있음 — 그대로 표시(툴팁 안내). 기록 0이면 배지 없이 기존 카드.

**E6 약점 가중 모의고사:**
- 가중치 = Task별 누적 오답률 비례(최소 가중치 보장으로 전 Task 출제 유지). **Phase 1의 `WrongAnswerIndex` 데이터에 의존.**
- 게이트: 이력 3회 미만이면 버튼 비활성("응시 기록이 쌓이면 열립니다") + T3 시작 게이트(verified < 65 비활성) 동일 적용.
- 구현 기반: Spec 2의 `buildMockExam`(도메인 가중 샘플러)를 오답률 가중으로 확장/재사용.

**게이트:** 가중 분배 단위 테스트(분포·최소가중·합=N) + analyze + dogfood(진행률 정직 표시, 3회 게이트, 가중 출제 분포).

## 6. Phase 3 — 비-CLF 콘텐츠

- 통합 모의고사·라우팅·렌더러는 이미 자격증 일반으로 작성됨 → `content_index.dart`에 Task 등록 + `tX-Y.md`/`tX-Y.questions.json` 채우면 즉시 동작.
- **게이트(프로세스):** "한 번에 한 자격증" 규칙 + 본인 CLF 합격 후 권장. verified = 출처 URL 필수, `verified:false` 드래프트 후 검토 flip(`content_index` 카운트·하드코딩 테스트 동기화).

## 7. 범위 밖 / 비차단

- SAA 코퍼스(`D:\Download\files.zip`) 차용 — 콘텐츠는 CLF 합격 후, 325 문항 출처 재검증 필수.
- SEO 보완(메타/프리렌더) — 콘텐츠 안정화 후.
- 간격 반복(spaced repetition), 다중 cert 통합 복습 — 후속(E1 설계 §9).
- `AttemptRecord.mode`/`flaggedQuestionIds`는 Phase 1까지 write-only(의도된 선행 계약).

## 8. 횡단 제약 (모든 Phase)

- **이중 폴더:** 코드 = `D:\workspace\awc-docs\aws-docs\flutter_app`. flutter/test/analyze는 거기서, git은 `aws-docs`에서.
- **flutter 명령은 PowerShell로**(Git Bash가 `--base-href` 망가뜨림).
- **테스트 함정:** SelectionArea+비동기 페이지(자식 라우트 포함) 위젯 렌더 테스트 금지 → 순수 로직 단위 + 모델주입 + dogfood.
- **커밋:** `main` 직접 커밋·push.
- 매 Phase 완료 시 세션 핸드오프(`docs/plans/2026-06-06-session-handoff.md`)·크로스세션 메모리 현행화.
