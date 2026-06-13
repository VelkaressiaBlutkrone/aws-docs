# PR4 — AppBar 인벤토리 + AppHeader 슬롯 매핑 (T12 선행 산출물)

_작성: 2026-06-13 · 설계 정본: `~/.gstack/projects/VelkaressiaBlutkrone-aws-docs/deepe-main-design-20260612-200051.md` (디자인 리뷰 1A)_
_목적: AppHeader 롤아웃 후 **AppBar 기능 손실 0** 게이트의 대조 기준. 와이어프레임 정답지 2번 섹션 기준._

## 1. 현재 인벤토리 (9페이지 전수)

모든 AppBar 공통 시각: `backgroundColor: c.bg` · `elevation 0` · 하단 1px `c.border` · 타이틀 16px w700. 표준 높이 56px(home만 커스텀 60px).

| # | 페이지 | leading(back) | title | actions | 특이 사항 |
|---|---|---|---|---|---|
| 1 | home | — (브랜드) | 내비 6링크(단계·추천 순서·로드맵·학습 문서·모의고사·일정 — 스크롤 앵커) | 와이드: 토글+설정(동기 시트·전체 초기화) / compact(<768): 햄버거(내비6+동기+초기화)+토글 | 커스텀 `_Header` 60px·bg 90% 불투명·blur 없음. 햄버거는 **기존 동작**(문서형 신규 도입만 금지) |
| 2 | cert_detail | auto back | `_CodePill(code)` + cert.title(ellipsis) | — | SelectionArea 본문 |
| 3 | study_doc | auto back | entry.title | — | 검수 메타(✓ 검증됨·검수일)는 현재 본문 `_DocHeader`에만 존재 |
| 4 | quiz | auto back | `{entry.title} · 연습 문제` | — | 세션 UI는 전부 본문(QuizView) |
| 5 | exam | auto back | `{entry.title} · 시험 모드` | — | 타이머·플래그·그리드 전부 본문(ExamView) — AppBar에 세션 액션 없음 |
| 6 | cert_exam | auto back | `{code} · 통합/약점 집중 모의고사` | — | 〃 (ExamView 재사용) |
| 7 | review | auto back | `{code} · 오답노트` | 초기화 IconButton(delete_outline·muted·확인 다이얼로그) | — |
| 8 | report | auto back | `{code} · 약점 리포트` | 초기화 IconButton(〃) | — |
| 9 | plan | auto back | `{code} · 학습 일정` | — | 본문에 별도 SliverAppBar(88px·D-day/진행/토글) — **페이지 헤더와 무관, 보존** |

back 동작: 전 라우트가 중첩 GoRoute → 딥링크에서도 부모 스택이 빌드되어 `Navigator.canPop()` 항상 유효. 현재 AppBar 기본 back = `Navigator.maybePop` — AppHeader도 동일 메커니즘 사용(동작 불변).

## 2. OQ2 해소 — 세션형 3페이지(exam·quiz·cert_exam)

**결정: 세션 액션(타이머·플래그·문항 그리드)은 본문 유지, AppHeader는 시각 셸+back+브레드크럼만.**
근거: 인벤토리 결과 세션 액션은 이미 전부 본문(ExamView/QuizView)에 있고 AppBar에는 타이틀뿐 → 셸 공통화만으로 PR4 완료 조건("세션형 3페이지도 시각 셸 공통") 충족, 검증 완료된 시험 러너 로직 무접촉(학습 엔진 불변 제약).

## 3. 새 슬롯 매핑 (문서형: ‹뒤로[+라벨] + 브레드크럼 "섹션 라벨 / 제목" + 우측 메타→액션→토글)

| 페이지 | backLabel | sectionLabel | title | titleLeading | meta | actions(토글 제외) |
|---|---|---|---|---|---|---|
| cert_detail | — | — | cert.title | `_CodePill(code)` | — | — |
| study_doc | entry.certCode | 학습 문서 | entry.title | — | ✓ 검증됨 · {lastVerified} (로드 후 표시) | — |
| quiz | — | entry.title | 연습 문제 | — | — | — |
| exam | — | entry.title | 시험 모드 | — | — | — |
| cert_exam | — | cert.code | 통합 모의고사 / 약점 집중 모의고사 | — | — | — |
| review | — | cert.code | 오답노트 | — | — | 초기화(muted+확인 다이얼로그 유지) |
| report | — | cert.code | 약점 리포트 | — | — | 초기화(〃) |
| plan | — | cert.code | 학습 일정 | — | — | — |

- 브레드크럼 의미: 좌=상위 맥락, 우=현재 페이지. 기존 타이틀의 정보(`code · 모드`)는 sectionLabel/title로 분해되어 **정보 손실 0**.
- **테마 토글은 전 페이지 헤더 우측 끝에 신설**(액션 슬롯 규약 "메타→페이지 액션→토글", 승인된 시각 변경 ④의 일부). `ThemeToggleButton`은 ThemeScope 셀프서비스로 페이지 배선 불필요.
- 홈형: 기존 `_Header` 동작(내비 앵커·compact 햄버거·설정 메뉴) 그대로 이식, 60→56px·88% 불투명·blur 14px만 셸 정렬. 내비 "활성탭 언더라인"은 홈이 단일 스크롤 페이지라 활성 상태 개념이 없어 **미적용**(스크롤 스파이 신설은 동작 불변 제약 위반 — 어휘만 와이어프레임에 존재, 허브형 라우팅 도입 시 적용).

## 4. collapse 규약 구현 (좁아질 때, 순서 고정)

1. 검수 **날짜** 숨김 → 2. **✓ 검증됨 배지** 숨김 → 3. **섹션 라벨** 숨김 → 4. **제목 ellipsis**(최소 가시 12자)

- 구현: 고정 px 브레이크포인트가 아니라 **TextPainter 실측 폭 기반** — "제목 최소 12자"가 확보될 때까지 우선순위대로 드롭(콘텐츠 적응형, 스펙의 서수 규칙을 직접 구현).
- **재량 결정 1:** 4단계 후에도 12자가 안 나오면 **backLabel 텍스트를 최후 드롭**(‹ 셰브론은 유지). 스펙 목록 밖이지만 "최소 12자" 보장에 필요한 유일한 양보 — 햄버거 금지·액션 보존 준수.
- **재량 결정 2(메타 색):** 헤더 메타는 배지(필)가 아닌 텍스트 — `✓ 검증됨` textMuted w600 / `· 날짜` textFaint(tabular). 본문 `_DocHeader`의 correct 필 배지는 그대로(브랜드 규칙 정본), 헤더는 절제된 에코.

## 5. 셸(blur 14px·88%)과 extendBodyBehindAppBar

blur·반투명이 실재하려면 콘텐츠가 헤더 **밑으로** 스크롤되어야 함 → `extendBodyBehindAppBar: true` + 스크롤 상단 인셋(`MediaQuery.paddingOf(context).top`).

| 페이지 | extend | 근거 |
|---|---|---|
| home·cert_detail·study_doc·quiz·exam·cert_exam·review·report | ✓ | 단순 스크롤 본문 — 인셋 기계적 처리(위젯 테스트에선 MediaQuery padding 반영, 동작 무영향) |
| plan | ✗ (불투명 폴백) | **재량 결정 3:** NestedScrollView+SliverOverlapAbsorber의 내부 sticky 헤더(88px)가 외부 글래스 헤더 밑으로 핀 고정되면 겹침 충돌. 본문을 헤더 아래 배치(현재와 동일) — 셸 시각(56px·border)은 동일, 글래스 효과만 없음 |

## 6. 기능 손실 0 대조 체크리스트 (롤아웃 후 페이지별 체크)

- [ ] home: 내비 앵커 6종 스크롤 · 토글 · 설정(동기 시트/전체 초기화) · compact 햄버거(내비+동기+초기화)
- [ ] cert_detail: back · 코드 필 · 타이틀 ellipsis
- [ ] study_doc: back · 타이틀 (+메타 신설 확인)
- [ ] quiz: back · task 맥락+모드 표기
- [ ] exam: back · task 맥락+모드 표기 · 본문 타이머/플래그/그리드 무변경
- [ ] cert_exam: back · code+모드(통합/약점 둘 다) · 본문 무변경
- [ ] review: back · code+모드 · 초기화(확인 다이얼로그→스낵바)
- [ ] report: back · code+모드 · 초기화(〃)
- [ ] plan: back · code+모드 · 본문 SliverAppBar(D-day/진행/토글) 무변경
