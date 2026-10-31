# 2026-09-22 리뷰 디자인 결정 4건 — 읽기 전용 실측 분석

작성: 세션 `design-decisions-79ee08` · 2026-10-30 · **1단계(승인 전, 편집 0건)**

정본: `docs/audits/2026-09-22-app-code-ux-review.md` (§M-6 · §M-10 · §UX 표 · 부록 A · §V-4)

---

## M-6 — 라이트 테마 대비 미달

### 1. 리뷰 수치는 아직 유효하다 (실측 재계산)

`lib/theme/app_theme.dart:54-101`의 토큰 값이 리뷰 작성 시점과 **동일**하고(light `textFaint #8A93A0`, `correct #1F8A52`, `warning #B7791F` / dark `textFaint #6B7585`), WCAG 2.x 상대 휘도로 직접 재계산한 값이 부록 A와 **소수 둘째 자리까지 일치**한다.

| 조합 | 라이트 | 다크 |
|---|---:|---:|
| text / bg | 15.01 ✅ | 14.76 ✅ |
| textMuted / bg | 5.65 ✅ | 7.06 ✅ |
| textMuted / surface2 | 5.22 ✅ | 5.73 ✅ |
| **textFaint / bg** | **2.98 ❌** | **3.82 ❌** |
| **textFaint / surface** | **3.11 ❌** | **3.47 ❌** |
| **textFaint / surface2** | **2.75 ❌** | **3.10 ❌** |
| accent / surface | 4.76 ✅ | 6.66 ✅ |
| onAccent / accent | 4.76 ✅ | 7.33 ✅ |
| accentStrong / accentWeak | 5.51 ✅ | 7.16 ✅ |
| **correct / correctWeak** | **3.83 ❌** | 6.34 ✅ |
| **correct / surface** | **4.36 ❌** | 6.60 ✅ |
| **correct / bg** | **4.18 ❌** | 7.27 ✅ |
| wrong / wrongWeak | 4.67 ✅ | 5.07 ✅ |
| info / infoWeak | 5.20 ✅ | 5.59 ✅ |
| **warning / bg** | **3.49 ❌** | 7.91 ✅ |
| **warning / surface** | **3.64 ❌** | 7.19 ✅ |
| **warning / warningWeak** | **3.19 ❌** | 7.04 ✅ |

부록 A에 없던 `correct / bg` **4.18 ❌**를 추가로 찾았다(`plan_agenda:497`의 날짜 셀 완료 수치가 이 조합).

### 2. ⚠️ 리뷰가 제안한 값은 `surface2`에서 AA에 못 미친다

| 제안값 | bg | surface | surface2 |
|---|---:|---:|---:|
| light `textFaint #697280` | 4.66 ✅ | 4.86 ✅ | **4.31 ❌** |
| dark `textFaint #808A9B` | 5.11 ✅ | 4.64 ✅ | **4.15 ❌** |

리뷰 부록 A도 "카드 내부 라벨은 textMuted 권장"으로 이 구멍을 인정하고 있다. 즉 **제안값만 넣으면 카드 안 라벨은 여전히 미달**이다. 세 배경 전부 AA를 넘기는 최소 이동값을 같은 색상(hue·saturation 고정, 명도만 이동)으로 탐색했다:

| 토큰 | 리뷰 제안 | 전배경 통과 최소값 | bg / surface / surface2 |
|---|---|---|---|
| light textFaint | `#697280` | **`#656F7D`** | 4.88 / 5.09 / 4.51 |
| dark textFaint | `#808A9B` | **`#88919F`** | 5.59 / 5.08 / 4.54 |
| light correct | `#1B7A48` | **`#1C7D4A`** | correctWeak 4.52 / surface 5.14 / bg 4.93 |
| light warning(텍스트) | `#8F5E14` | **`#956319`** | bg 4.94 / surface 5.15 / warningWeak 4.51 |

### 3. 사용처 실측 — `textFaint` 참조 26건(테마 정의 11건 제외 15곳)

**⚠️ 가장 중요한 발견: `labelSmall`의 기본 색이 `textFaint`다**(`app_theme.dart:354-359`, 12px w700 letterSpacing .4). 그래서 `t.labelSmall`을 그냥 쓰는 모든 화면이 자동으로 미달에 걸린다 — 호출부를 세는 것만으로는 범위가 안 잡힌다.

- **본문 텍스트(AA 필요) 10곳**
  - `home/footer_section.dart:21` — 13px 면책 문구("비공식 학습 사이트 · …")
  - `cert_detail/summary_section.dart:57` — 12px 면책
  - `widgets/app_header.dart:84` — 13px 검수일
  - `cert_detail/cert_detail_bits.dart:52` — 11px
  - `cert_detail/official_guide_section.dart:37` — 11px
  - `home/home_bits.dart:39` — 13px
  - `report_page.dart:240`·`:259` — labelSmall("놓친 개념" 등)
  - `cert_detail/learning_content_section.dart:326` — labelSmall
  - `plan/plan_agenda.dart:438` — labelSmall(요일)
  - 그 외 `t.labelSmall` 기본색 사용 전부(예: `exam/exam_view.dart:278` "12 / 65")
- **비활성 상태 5곳 — WCAG 1.4.3 면제**("inactive user interface component ... have no contrast requirement")
  - `quiz_widgets.dart:127`(비활성 버튼) · `learning_content_section.dart:215`(잠금) · `home/exams_section.dart:85`(잠금) · `lecture_transport_bar.dart:211`(비활성) · `plan_agenda.dart:490`(범위 밖 날짜)
- **장식 1곳** — `app_header.dart:73` 브레드크럼 슬래시

**`warning`** — 텍스트 4곳: `exam_view.dart:274`(타이머 임박 16px w700)·`exam_bits.dart:117`(플래그 라벨 13px w700)·`home_page.dart:154`("지난 일정 N개")·`exam_view.dart:264`+`exam_bits.dart:109`(아이콘). 아이콘·테두리 8곳은 **비텍스트 3:1 기준이라 3.49로 통과**한다 — 그래서 `warning` 값을 그대로 두고 텍스트 전용 토큰을 더하는 리뷰 제안이 성립한다.

**`correct`** — 텍스트 5곳: `quiz_widgets.dart:243`("정답" 라벨 12px w800 **on surface** = 4.36)·`study_doc_page.dart:268`(배지 fg on correctWeak = 3.83)·`learning_content_section.dart:81`(배지 "검증 문항 N" on correctWeak = 3.83)·`plan_agenda.dart:497`(10px on surface/surface2)·`report_page.dart:206`(상태 톤). ⚠️ "검증 문항 N" 배지는 `DESIGN.md:153` **브랜드 규칙**(correct-weak/correct)이라 토큰을 바꾸면 그 줄도 같이 고쳐야 한다.

### 4. 선택지

| 안 | 내용 | 영향 | 대가 |
|---|---|---|---|
| **A** 값 상향 | 토큰 4개 값만 교체(`textFaint` 라이트·다크, `correct` 라이트, `warningText` 신설) | `app_theme.dart` + `DESIGN.md` 컬러 표. 호출부 변경 = warning 텍스트 4곳만 | **3단 위계가 눌린다** — `textFaint #656F7D`(4.88)와 `textMuted #5C6573`(5.65)이 거의 같은 색이 된다. "흐린 텍스트" 단이 사실상 사라짐 |
| **B** 역할 재정의 | 토큰 값 **불변**. `textFaint`를 텍스트에서 추방(구분선·아이콘·플레이스홀더·비활성 전용)하고 텍스트는 `textMuted`로. `labelSmall` 기본색을 `textMuted`로 | 호출부 10곳 + `labelSmall` 기본색 + `DESIGN.md`에 원칙 명문화 | 위계가 2단(text/textMuted)으로 줄지만 각 단은 뚜렷하다. **`correct`·`warning`은 별도로 해결해야 한다**(B만으로는 미해결) |
| **A+B** | `labelSmall`·본문 텍스트는 `textMuted`로 옮기고(B), 남는 `textFaint`는 비활성·장식 전용이므로 값을 **올리지 않는다**. `correct`·`warning`은 A의 값 교체 | 가장 넓음 | 작업량 최대. 대신 "14px 이하 텍스트에 textFaint 금지"가 구조적으로 보장됨 — 리뷰가 원칙으로 적은 바로 그것 |
| **보류** | — | — | 남은 일 목록에 그대로 |

리뷰 본문은 A의 값과 B의 원칙을 **둘 다** 적었다(= A+B). 다만 리뷰가 적은 A의 값이 `surface2`를 놓쳤으므로, A를 고르면 값은 위 표의 "전배경 통과 최소값"을 써야 한다.

---

## UX-1 — 모바일 문항 그리드

### 실측

- 위치: `lib/pages/exam/exam_view.dart:292-305` — `Wrap(spacing: Gap.xs=4, runSpacing: 4)` × `GridChip` 34×34(`exam_bits.dart:36-37`). 복원 안내 아래, **지문(`:307`) 위**.
- 폭 계산: `ExamView`는 네 호출부 전부 `ConstrainedBox(maxWidth: Layout.exam = 768)` 안에 있다(`exam_page.dart:201` · `cert_exam_page.dart:365` · `quiz_page.dart:88` · `review_page.dart:167` — 뒤 둘은 그리드를 그리지 않는다). 본문 패딩은 `Gap.xl = 24` 좌우.
  - 360px 화면 → 내부 폭 312 → 한 줄 `floor((312+4)/38) = 8`칩 → 65문항 **9줄 = 338px**(리뷰가 적은 "~8줄 ≈300px"과 같은 규모).
- 브레이크포인트: `ExamView` 안의 `LayoutBuilder`는 데스크톱에서 정확히 768, 그 아래에서는 실제 폭을 본다 → `< 768` 판정이 안전하다. 선례: `home/home_header.dart:27` `_navBreakpoint = 768.0`.
- ⚠️ 상단 행(`:278`)이 이미 `'${_index + 1} / ${_qs.length}'`를 표시한다 → 리뷰가 제안한 요약 칩 "12 / 65 · 미답 8 · 플래그 3"과 **중복**이다. 요약 칩으로 합치고 상단은 타이머만 둘지 결정이 필요하다.

### 선택지

| 안 | 내용 | 비고 |
|---|---|---|
| **접이식** | 요약 칩을 탭하면 그리드가 제자리에서 펼쳐짐. `DESIGN.md` 모션 규약(short 150–250ms ease)·`disableAnimations` 존중 | 리뷰 1순위. 구조 변경 최소, 위젯 테스트 쉬움 |
| **바텀시트** | 요약 칩 탭 → `showModalBottomSheet`에 그리드. 65칩을 넓게 볼 수 있음 | 모달이라 지문이 가려짐. "제자리 복귀" 동작이 하나 더 생김 |
| **보류** | — | — |

데스크톱(≥768)은 두 안 모두 **현행 유지**가 리뷰 권고다.

---

## UX-2 — 상시 제출 + 점프

### 실측

`exam_view.dart:335-343` — 하단 기본 버튼 라벨이 `_index < _qs.length - 1 ? '다음' : '제출'`이라 **마지막 문항에서만** 제출이 보인다. 제출 확인 다이얼로그(`_onSubmitPressed`, `:211-237`)는 이미 있고 플래그가 남으면 경고한다.

미답·플래그 집합은 이미 상태로 있다(`_picked`·`_flagged`) → 점프 계산은 순수 함수로 분리 가능(테스트 용이).

⚠️ 공간: 360px에서 상단 행은 타이머(mono 16px) + "12 / 65"로 이미 차 있다. 제출 버튼을 그 행에 더하면 좁다 → UX-1의 요약 칩 행에 점프 버튼을 함께 두는 쪽이 자연스럽다(두 건이 같은 영역을 건드린다는 뜻 = 순차 작업 필요).

### 선택지

- **전부**: 상단 상시 제출 + "다음 미답으로" + "다음 플래그로"
- **제출만**: 상시 제출 버튼만(점프는 그리드로 충분하다는 판단)
- **점프만**: 제출은 현행(마지막 문항) 유지
- **보류**

---

## UX-4 — "이어서 풀기" 진입점

### 실측

- 조회 경로는 결정적이다: `ExamSessionStore.loadSnapshot(examId)`(`exam_session_store.dart:71-85`)가 `startedAtIso`·`durationSec`를 주므로 **남은 시간을 계산할 수 있다**. 퇴화 스냅샷(문항 0 / duration ≤ 0)은 이 함수가 이미 걸러낸다.
- `examIdsForCert(code)`(`data/study_reset.dart:16-24`)는 `exam:{CODE}-mock`·`exam:{CODE}-weak` **+ Task별 `exam:`/`practice:`/`review:`**를 전부 yield한다.
- ⚠️ **만료 세션 정리는 시험 페이지 진입에서만 돈다**(`cert_exam_page.dart:68` `_store.clearExpired()`). 홈·상세는 그 경로를 타지 않으므로 **직접 남은 시간 > 0을 확인해야** "남은 00:00" 카드를 띄우지 않는다.
- ⚠️ **홈은 자격증 12개를 돈다**(`home_page.dart:100`). `examIdsForCert`를 전 자격증에 돌리면 Task까지 포함해 localStorage read가 수백 건이다. mock·weak 2키만 보면 24건 — 홈 배치 시 범위를 통합/약점으로 제한할 근거.
- 배치 지점: 홈은 `home_page.dart:218`의 `?dueBanner` 슬롯(배너는 할 일이 없으면 `null`이라 **독립 카드**여야 한다) / 상세는 `cert_detail_page.dart:152` `CertHeaderSection` 바로 아래.

### 선택지

| 축 | 선택지 |
|---|---|
| 위치 | `cert_detail`만 / 홈만 / **둘 다** |
| 범위 | 통합(`-mock`)만 / 통합+약점(`-weak`) / Task 단위까지 |

리뷰 문구 예시는 "진행 중인 통합 모의고사 이어서 풀기 · 남은 42:10"이고 통합만 언급한다. 약점 모의고사도 같은 2키 체제라 비용 차이가 없다.

---

## UX-5 / M-10 — 결과 화면

### 실측

- `ResultsView`(`lib/content/quiz_widgets.dart:135-183`)가 `Column` 안에서 `for (var k…) ResultCard(…)`로 전량 빌드한다. `ResultCard`는 지문+내 답+정답+해설+오답 근거+개념 칩(`:186-269`).
- ⚠️ **공유 위젯이다**: `exam/exam_view.dart:358`(모의고사 65문항)과 `quiz_page.dart:195`(Task 단위 퀴즈 ~15문항) **둘 다** 쓴다. `review_page.dart`는 자체 렌더다. → 필터를 `ResultsView`에 넣으면 Task 퀴즈에도 나타난다(의도적 공통 적용인지 결정 필요).
- ⚠️ **M-10의 지연 빌드는 호출부 구조 변경을 요구한다**: `ResultsView`는 호출부의 `SingleChildScrollView > Column` 안에 들어가므로(`exam_view.dart:353-357`) 그 자리에서 `ListView.builder`로 바꿀 수 없다. Sliver로 전환하려면 호출부 2곳을 `CustomScrollView`로 바꿔야 한다.
- 기존 가드: `test/results_view_test.dart`(2건).

### 선택지

| 안 | 내용 | 비고 |
|---|---|---|
| **필터만** | 상단 필터 칩 "전체 / 오답만(기본, 오답 있을 때) / 플래그만". 구조 변경 0 | 기본값이 오답만이라 제출 직후 보통 12장만 빌드 → 정지 체감 해소. "전체"를 고르면 65장은 그대로 |
| **필터 + 정답 카드 접힘** | 위 + "전체"에서 정답 카드는 머리글만 | 65장 중 53장이 가벼워져 "전체"도 빨라짐 |
| **필터 + Sliver 전환(M-10 완전)** | 위 + 호출부 2곳 `CustomScrollView`화 | 지연 빌드 보장. 변경 범위·회귀 위험 최대(`headerScrollInset` 인셋·`SelectionArea` 상호작용) |
| **보류** | — | — |

적용 범위: `ResultsView` 공통(모의고사+Task 퀴즈) / 모의고사만(파라미터로 분기)

---

## 작업 순서·충돌 (승인 후 2단계)

리뷰 권장 순서는 **UX-1 → UX-4 → UX-2**이고 M-6·UX-5/M-10이 뒤따른다.

- **UX-1 · UX-2 · UX-5/M-10은 전부 시험 러너 파일**(`exam/exam_view.dart`, `content/quiz_widgets.dart`)을 건드린다 → **순차**, 각각 독립 커밋.
- **UX-4**는 `home_page.dart`·`cert_detail_page.dart`(+ 새 위젯)이라 겹치지 않는다.
- **M-6**은 `theme/app_theme.dart` + `DESIGN.md` + 안에 따라 호출부 10곳. `exam_view.dart:278`·`exam_bits.dart:117`을 건드리므로 러너 건들과 **같은 파일에 닿을 수 있다** → 러너 3건 뒤에 두는 것이 안전.
- 테스트: `ExamView`는 `MaterialApp + Scaffold`로 **직접 렌더된다**(`test/exam_view_test.dart:40` `_host`) — `SelectionArea` 함정 없음. 반응형 분기는 `tester.view.physicalSize`로 폭을 바꿔 검증.
- 게이트: `flutter test`(기준선 2,466) · `flutter analyze` 0건 · `node tool/review.test.mjs` · `node tool/prescreen.test.mjs`.

---

# 결과 (2026-10-30 종료)

**PR [#294](https://github.com/VelkaressiaBlutkrone/aws-docs/pull/294) → `develop`** · 브랜치 `feat/2026-09-22-review-design-decisions` · 커밋 6개(건별 독립 5 + docs 1).

사용자 승인: M-6 **A+B 혼합** · UX-1 **접이식** · UX-2 **제출+점프** · UX-4 **홈+상세 · 통합+약점** · UX-5 **필터+정답 접힘**. M-10 Sliver 전환은 사용자가 범위에서 제외.

게이트 실측: `flutter test` **2,568 그린**(2,466 + 102) · `flutter analyze` **0건** · `review.test.mjs` 32 pass · `prescreen.test.mjs` 12 pass.

## 다음 세션이 알아야 할 것

- ⚠️ **이 레포의 `claude/*` 워크트리 브랜치는 `main` 계열에서 갈라져 있다**(HEAD가 develop에 없는 커밋 39개 = main 머지 이력). 작업 브랜치는 `origin/develop`에서 다시 끊어야 한다.
- ⚠️ **`dart format` 금지.** 레포가 format 게이트를 쓰지 않아 한 파일만 돌려도 서식 churn 87줄이 끼어 리뷰 불가 diff가 된다. 손으로 편집한다.
- ⚠️ **node 도구 테스트는 `flutter_app/tool/`에 있다**(레포 루트 `tool/`에는 `firestore_rules_test/`뿐). `cd flutter_app && node tool/*.test.mjs`.
- ⚠️ **`cert_detail_sections_test.dart`의 "페이지 전체는 위젯 테스트 렌더 불가" 단정은 틀렸다** — `ThemeScope`로 감싸면 `HomePage`·`CertDetailPage` 둘 다 직접 렌더된다(이 PR에서 주석 정정).
- ⚠️ **`find.byType(InkWell).first`로 "첫 선택지"를 집는 테스트는 깨진다** — 러너에 컨트롤이 하나 늘면 그 탭이 다른 곳으로 간다(`exam_page_snapshot_test` 3건 실제 발생).
- **남은 후속:** `accent/surface2`(4.21, AA 미달) 전수 감사 — surface2 패널 29곳 중 **7곳만** 중첩 확인해 `accentStrong`으로 옮겼다. 토큰 가드가 조합 자체는 막지만 중첩은 텍스트로 판정 불가.
- **남은 후속:** M-10 Sliver 지연 빌드 — 전수 만점 65문항만 65장을 펼쳐 그리는 잔여 경로.
- **범위 밖(미승인):** UX-3(칩 hit area 44px) · M-7(Semantics) · M-4 · 리뷰 원문 Minor m-1~m-5.

## 머지 완료 (2026-10-30 08:24 UTC)

PR #294 → `develop` **머지 commit `2667dab`** (기본 merge commit). CI는 푸시 SHA `6b330d8`에서 완전 녹색이었다 — node 44 pass·0 fail · analyze 0건 · flutter test **2568** · `conclusion=success`.

`develop` c5239ce → 2667dab, 31파일 1,746+/93−. **미릴리스** — `develop`→`main` 릴리스 PR은 아직 없다(학습자 화면 미반영).

⚠️ `gh pr merge 294 --merge`는 **출력 없이** 끝난다 — 성공 판정은 `gh pr view --json state,mergedAt,mergeCommit` + **fetch 뒤** `git merge-base --is-ancestor`로 한다(fetch 전 로컬 `origin/develop`은 머지 전 상태라 "NO"가 나온다. 실제로 한 번 오판했다). ⚠️ `gh pr view --json merged`는 **없는 필드**다(`state`·`mergedAt`을 쓴다) — `&&` 체인에서 쓰면 뒤 명령 전부가 안 돈다.

## 릴리스 PR (2026-10-30)

**PR #295 `develop` → `main`** — 4 PR(#291~#294) 13커밋, 33파일 1,785+/101−. **머지 전**(CI 생성 대기).

릴리스 전 게이트 전부 실측 녹색: flutter test **2,568** · analyze **0건** · node 도구 **44 pass** · `flutter build web --release --base-href /aws-docs/` **성공**(81.4s) · audio **39/39 PASS**.

⚠️ **콘텐츠 에셋 변경 0건이라 에셋 md5 대조가 성립하지 않는다** — 이전 릴리스들의 `assets/assets/content/…` 추적 대상이 없다. 산출물이 컴파일 번들이라 **배포 전 라이브 번들 md5를 대조군으로** 잡았다:

| 파일 | 배포 전 라이브 md5 | bytes |
|---|---|---:|
| `main.dart.js` | `e236f04adb0b9c033978b882abed4a85` | 3,233,696 |
| `flutter_bootstrap.js` | `eabdbfe7fbf658fc4d068e638d11a6c3` | 13,094 |

`Last-Modified: Fri, 30 Oct 2026 01:08:19 GMT`. 배포 후 **md5가 바뀌면** 전파됐다는 증거다. 로컬 빌드값(`e50e4cbd…` / `659f39c2…`)은 **참고값**이고 CI 빌드와 바이트 일치를 보장하지 않는다.

⚠️ `flutter build web`은 **CI(`test` 체크)가 돌지 않는다** — `pages.yml`이 `main` 푸시에서만 돈다. 그래서 릴리스 PR 전에 로컬(PowerShell)에서 미리 돌렸다. Git Bash 금지(MSYS가 `/aws-docs/`를 변형).

## 릴리스 완료·라이브 (2026-10-30 12:27 UTC)

PR #295 머지 commit **`ba55157`**, `main` 8edb264 → ba55157. Pages 런 **`41055467664` success**.

**전파 확인 — 배포 전 대조군 대비 번들 md5 둘 다 변경:**

| 파일 | before | after | bytes |
|---|---|---|---:|
| `main.dart.js` | `e236f04a…` | `94335fb9…` ✅ | 3,241,690 |
| `flutter_bootstrap.js` | `eabdbfe7…` | `352a38a2…` ✅ | 13,093 |

⚠️ **`pages.yml`은 `--dart-define=audio_lecture=true`를 더 넘긴다** — 그래서 로컬 `flutter build web --release --base-href /aws-docs/` 산출물과 **바이트가 다르다**(이번에 3,920바이트 차이). 배포 산출물을 재현하려면 그 플래그를 같이 줘야 한다. 로컬 빌드는 "트리가 컴파일되는지"까지만 증명한다.

⚠️ **번들 grep으로 한글 UI 문구를 확인할 수 없다** — `main.dart.js`(116,314줄)에 **원시 한글도, `\uXXXX` 이스케이프도 0건**이다(`결과`·`플래그 해제` 같은 **릴리스 전부터 있던** 문구를 대조군으로 넣어 확인). 반면 `aws-audio.leva.ai.kr` 같은 ASCII 문자열은 잡힌다 — 한글이 어떤 형태로 들어가는지는 규명하지 못했다. **대조군 없이 "0건"을 보면 "배포 안 됨"으로 오판한다.**

→ 라이브 **화면** 확인(접이식 그리드·이어서 풀기 카드·결과 필터·대비)은 사람이 직접 봐야 한다(canvaskit: `get_page_text` 빈 값, 스크린샷 반복 타임아웃).

⚠️ `gh pr merge 295 --merge`가 **`! was already merged`에 exit 0**을 돌려줬다 — 내가 머지한 것인지 다른 경로인지 메시지로는 구분이 안 된다. `mergedBy`·`mergedAt`·`mergeCommit`로 실측해 확인했다.

## 후속 종료 — accent/surface2 감사 (2026-10-30)

**PR [#296](https://github.com/VelkaressiaBlutkrone/aws-docs/pull/296) → `develop`** · 브랜치 `fix/2026-10-30-accent-surface2-scan` · 커밋 1개. 기준선 2,568 → **2,583**.

**결과: 실제 위반 0건** — 1차(#294)의 7곳 수정이 충분했음을 증거로 확인했다.

### 왜 눈으로 훑지 않았나

"이 accent 텍스트가 어느 배경 위인가"는 **소스에 없다.** grep도, 부록 A처럼 색 쌍을 적는 표도 이 종류를 놓친다(부록 A가 `accent/surface2`를 빠뜨린 이유). 그래서 `test/contrast_scan.dart`가 렌더된 트리에서 `RichText`의 **해결된 색**을 읽고 조상 중 **가장 가까운 불투명 배경**을 찾아 짝짓는다.

- `Text.style`은 null일 수 있다(색이 DefaultTextStyle·테마에서 온다) → `RichText`를 본다.
- 바깥 surface2 · 안쪽 surface면 **안쪽이 배경**이다 → 첫 불투명 배경에서 멈춘다.
- 반투명(alpha<1)은 배경으로 치지 않고 계속 올라간다.
- `Text.rich`는 스팬마다 색이 달라 전부 본다.

### 다음 세션이 알아야 할 함정 2건

⚠️ **`Icon`은 `RichText`로 렌더되고 글리프가 스팬 텍스트로 들어온다.** 안 걸러내면 아이콘 색이 전부 "텍스트"로 잡혀 `Icon(..., color: c.accent)` 전부가 거짓 양성이 된다. **대조군이 첫 실행에서 이걸 잡았다.** 폰트 이름과 유니코드 PUA를 양쪽으로 본다(폰트만 → `packages/…` 아이콘 폰트 누락, PUA만 → 본문 PUA 문자 누락).

⚠️ **`HomePage.backend`가 due 배너에 연결돼 있지 않았다.** #294(UX-4)가 resume 조회에만 넘겨서 `_dueBanner`의 세 스토어는 `defaultBackend()`를 썼다 → 테스트가 심은 일정을 배너가 못 보고 "배너가 그려졌는가" 전제가 **거짓 통과**. 전제를 넣어 뒀기에 발견됐다(`오늘 학습할 항목` 0건으로 먼저 실패). 세 스토어에 주입구 연결로 해소(앱 동작 불변).

### 규율로 승격

`DESIGN.md` `## Contrast`: **새 대비 규칙은 토큰 쌍 표가 아니라 렌더 결과로 건다.**
