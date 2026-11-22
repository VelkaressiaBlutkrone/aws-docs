# Design System — 구름사다리

> "조용한 레퍼런스" — 파는 곳이 아니라 공부하는 곳처럼.
> 이 문서는 시각/UI 결정의 단일 진실 공급원입니다. 코드의 색·폰트·간격·움직임은 모두 여기서 옵니다.
> 프리뷰: `~/.gstack/projects/VelkaressiaBlutkrone-aws-docs/designs/design-system-preview.html`
> 생성: /design-consultation, 2026-06-05 (경쟁 리서치 + HTML 프리뷰 검증 기반)
> 구현: Flutter Web — 이 토큰들은 `flutter_app/lib/theme/app_theme.dart`의 `AppColors`(ThemeExtension) + `ThemeData`로 이식됨. 폰트는 OTF/TTF 에셋 번들. UI 작업 시 하드코딩 대신 `context.c`/테마 토큰을 사용할 것.

## Product Context
- **무엇:** AWS 자격증을 한국어로, 이해 중심으로 공부하는 통합 학습 로드맵 + 모의고사 정적 사이트
- **누구:** 한국어로 AWS 자격증을 준비하는 사람 (첫 사용자 = 제작자 본인)
- **공간/업계:** 클라우드 자격증 학습 (peers: Tutorials Dojo, AWS Skill Builder, Maarek, roadmap.sh)
- **차별화:** 한국어 · 이해 중심(왜를 가르침) · 통합 로드맵 · 무료/최신
- **핵심 가치:** 정직함. 가짜 문제 폐기, verified 문항만 노출, "준비 중"을 정직하게 표기
- **프로젝트 타입:** 정적 웹앱 + 에디토리얼(학습 문서) 하이브리드. Flutter Web (Dart), GitHub Pages
- **메모러블 (작업 가설, 사용자 확정 대기):** "덤프랑 다르게, 여기선 진짜 이해됐다"

## Aesthetic Direction
- **방향:** 에디토리얼 / 레퍼런스급 — 잘 조판된 기술서적과 집중형 IDE 문서의 교집합
- **장식 수준:** intentional (절제+). 헤어라인 룰, 넉넉한 여백. 스톡 사진·그라데이션 블롭·히어로 과장 없음
- **무드:** 차분하고 신뢰가 가며 집중을 방해하지 않는다. 아무도 나에게 무언가를 팔지 않는다는 느낌
- **리서치 근거:** 경쟁자는 상업적(Tutorials Dojo의 마케팅 과잉)이거나 제네릭 엔터프라이즈(Skill Builder의 보라 그라데이션). 이 제품은 차분함과 신뢰도로 경쟁한다 — 어수선함의 반대편
- **금지(AI 슬롭):** 보라/바이올렛 그라데이션, 3단 아이콘 카드 그리드, 전체 중앙정렬, 모든 요소 동일 둥근 모서리, 그라데이션 CTA, 스톡 사진 히어로, "Built for X" 마케팅 카피

## Typography
한국어 우선 2폰트 시스템. 한글 렌더링이 약한 Inter를 교체하는 것이 단일 최대 개선점이다.

- **Display / Hero:** Pretendard 800 — 한글+라틴을 한 가족으로 처리, 중성-모던. `clamp(34px, 5vw, 52px)`
- **본문 / UI:** Pretendard 400–500 — 학습 문서 17px / line-height 1.8 (한글 가독), UI 텍스트 15–16px / 1.6
- **제목:** Pretendard 700, letter-spacing -0.01~-0.02em
- **데이터 / 표 / 숫자:** Pretendard + `font-variant-numeric: tabular-nums` (점수·문항번호·진도 정렬)
- **코드 / 식별자:** JetBrains Mono — ARN, CLI, `s3://`, IAM 정책 등 AWS 콘텐츠에 필수. 14px / 1.7
- **로딩 (로컬 번들 — 오프라인·무추적):** 폰트는 외부 CDN이 아니라 앱에 번들된 에셋으로 로드한다.
  - **Pretendard = Variable 단일 파일** `PretendardVariable.woff2`(~2.0MB — 정적 4 OTF 6.3MB 대체, 2026-06-13 PR3) · JetBrainsMono(Regular/Medium/Bold TTF, 0.83MB) 정적 유지: `flutter_app/assets/fonts/` + `pubspec.yaml`의 `fonts:`. 폰트 합계 6.9MB → **2.75MB**.
  - **가변 굵기 규율:** Flutter는 `FontWeight`를 가변 `wght` 축에 자동 매핑하지 않는다 — fontWeight를 쓰는 모든 TextStyle에 `Wght` 토큰(`app_theme.dart`)을 병기한다. 게이트: lib 전체 `fontWeight:` ↔ `fontVariations:` 1:1(누락 시 해당 텍스트가 400으로 균일화). fontWeight 자체는 폴백 폰트(한자 Noto)의 합성 굵기를 위해 유지.
  - woff2 번들 가능 근거: canvaskit의 FreeType이 woff2를 직접 디코드한다(엔진 Noto 폴백과 같은 `Typeface.MakeFreeTypeFaceFromData` 경로). Flutter 마이너 업그레이드 시 이 전제 재확인.
  - 근거: GitHub Pages 정적 배포 + 한국어 학습 제품 — CDN 의존·외부 추적·SRI 관리 비용을 피하고 오프라인에서도 렌더. (번들 목록의 단일 진실은 pubspec.)
- **font stack:**
  - sans: `"Pretendard Variable", Pretendard, -apple-system, BlinkMacSystemFont, system-ui, "Segoe UI", sans-serif`
  - mono: `"JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, monospace`
- **스케일 (px):** 13(small) · 15(ui) · 16(base) · 17(body) · 20(h3) · 28(h2) · clamp(34–52)(display)
- **한국어 줄바꿈 = 어절 단위(keep-all):** 글자 단위로 끊지 않는다(「덤|프」 금지). 정적 HTML 은 CSS `word-break: keep-all`, Flutter 는 설정이 없어(3.47.2 `ParagraphStyle` 실측) `lib/widgets/text.dart` 의 `Text` 가 한글이 낀 글자 쌍 사이에 폭 없는 문자(U+2060)를 넣는다. 가운뎃점 `·` 은 앞에서 끊지 않고 뒤에서 끊는다. lib 의 모든 화면 글자가 이 `Text` 를 쓰고(Flutter import 에서 `Text` 를 숨긴다) `korean_line_break_survey_test.dart` 가 주요 10개 화면을 폰 폭으로 렌더해 어절 중간 줄바꿈 0건을 지킨다.

## Color
- **접근:** restrained — 중성색이 대부분을 하고, 액센트는 진도·활성·핵심 동작에만 드물게
- **액센트(verified 틸):** light `#0E8175` (hover `#0B6B61`, weak `#E0F2EF`) / dark `#3FB8AA` (hover `#5ECABD`, weak `#13302D`). on-accent: light `#FFFFFF`, dark `#14181F`
  - 선택 근거: "검증/신뢰"를 상징해 verified 브랜드와 의미 일치. 현재 사이트의 링크 틸(#0f766e)과도 연속

### Light (기본)
| 역할 | 값 | CSS var |
|---|---|---|
| 배경 | `#FBFAF8` (웜 페이퍼) | `--bg` |
| 표면 | `#FFFFFF` | `--surface` |
| 표면 2 | `#F3F1EC` | `--surface-2` |
| 경계선 | `#E7E4DD` | `--border` |
| 경계선(강) | `#D6D1C7` | `--border-strong` |
| 본문 텍스트 | `#1B2430` (잉크) | `--text` |
| 보조 텍스트 | `#5C6573` | `--text-muted` |
| 흐린 텍스트 **(비활성·장식 전용 — 텍스트 금지)** | `#8A93A0` | `--text-faint` |
| 구조 다크(헤더/푸터) | `#1B2430` / on `#EFEDE7` | `--ink` / `--on-ink` |

### Dark
| 역할 | 값 | CSS var |
|---|---|---|
| 배경 | `#14181F` | `--bg` |
| 표면 | `#1B212B` | `--surface` |
| 표면 2 | `#222A36` | `--surface-2` |
| 경계선 | `#2A323F` | `--border` |
| 경계선(강) | `#3A4350` | `--border-strong` |
| 본문 텍스트 | `#E8EAED` | `--text` |
| 보조 텍스트 | `#9AA4B2` | `--text-muted` |
| 흐린 텍스트 **(비활성·장식 전용 — 텍스트 금지)** | `#6B7585` | `--text-faint` |
| 구조 다크 | `#0F131A` / on `#E8EAED` | `--ink` / `--on-ink` |

### Semantic (퀴즈 도구 필수)
| 의미 | Light (색 / weak) | Dark (색 / weak) |
|---|---|---|
| 정답 correct | `#1C7D4A` / `#E5F4EA` | `#3DBB78` / `#15281D` |
| 오답 wrong | `#C0392B` / `#FBEAE7` | `#E06A5C` / `#2E1816` |
| 정보 info | `#2563B0` / `#E8EFF8` | `#5B9BE0` / `#15212E` |
| 주의 warning (아이콘·테두리·배경) | `#B7791F` / `#F8EFDD` | `#D9A441` / `#2A2113` |
| 주의 warning **텍스트** | `#956319` | `#D9A441` |

- **다크 모드 전략:** 표면을 재설계(단순 반전 금지). 액센트·시맨틱은 어두운 배경에서 대비 확보 위해 채도/명도 조정한 별도 값 사용. 라이트가 기본, 다크는 토글(`html[data-theme="dark"]`). 토글은 영속화된다 — localStorage `awsdocs.theme.v1`('dark'|'light', 평문), 키 없음/파손 시 라이트 폴백. 같은 키를 스플래시 JS(`web/index.html`)와 Flutter(`lib/data/theme_pref_store.dart`)가 공유해 첫 페인트부터 색이 일치한다
- **그림자:** sm `0 1px 2px rgba(27,36,48,.05)` (dark: `0 1px 2px rgba(0,0,0,.3)`), md `0 6px 24px -10px rgba(27,36,48,.18)` (dark: `0 10px 30px -12px rgba(0,0,0,.6)`)

## Contrast — WCAG AA (2026-10-30, 리뷰 M-6)
**텍스트로 쓰는 모든 전경/배경 쌍은 AA 4.5:1을 넘긴다.** 숫자는 문서가 아니라
`flutter_app/test/theme_contrast_test.dart`가 지킨다 — 상대 휘도를 직접 계산해 전 조합을
단정하므로, 토큰 값을 되돌리면 테스트가 먼저 깨진다.

- **`--text-faint`는 텍스트에 쓰지 않는다.** 구분선·아이콘·플레이스홀더, 그리고 WCAG 1.4.3이
  대비 요건에서 제외하는 **비활성 컴포넌트**(잠긴 Task·비활성 버튼·플랜 범위 밖 날짜)만
  faint를 쓴다. **텍스트의 하한은 `--text-muted`다.** `labelSmall`(12px)의 기본색도
  muted다 — 전에는 faint여서 그 스타일을 쓰는 모든 화면이 미달을 상속했다.
- **`warning`은 아이콘·테두리·배경 전용이고 텍스트는 `--warning-text`다.** 라이트
  `#B7791F`는 비텍스트 3:1(3.49)은 넘지만 텍스트 4.5:1에는 미달이고, 색을 통째로
  올리면 플래그 아이콘·테두리 톤까지 어두워진다. 다크는 warning이 이미 7.91이라 같은 값.
- **`surface2` 패널 위의 액센트 텍스트는 `accentStrong`을 쓴다.** 라이트 `accent`는
  surface2에서 4.21로 미달이다(`accentStrong` 5.65 / 다크 7.34). 아이콘·점·진행 바로는
  accent를 그대로 쓸 수 있다(비텍스트 3:1). **브랜드 액센트 값은 바꾸지 않는다.**
- ⚠️ **"어느 배경 위인가"는 토큰 쌍으로 판정할 수 없다.** 소스에는 중첩이 안 적혀 있어
  grep도, 색 쌍 표도 이 종류를 놓친다(리뷰 부록 A가 `accent/surface2`를 빠뜨린 이유).
  그래서 **렌더된 트리를 걷는** 스캐너로 검증한다 — `flutter_app/test/contrast_scan.dart`가
  `RichText`의 해결된 색과 조상 중 **가장 가까운 불투명 배경**을 짝짓고,
  `accent_on_surface2_test.dart`가 실제 화면들을 돌며 0건을 고정한다. 새 대비 규칙을
  더할 때도 쌍 표가 아니라 이 방식으로 건다.
- 대형 텍스트 완화(≥18.66px 볼드 / ≥24px는 3:1)에 **의존하지 않는다** — 토큰 단위로
  4.5:1을 맞춰 두면 글자 크기를 줄이는 변경이 조용히 접근성을 깨뜨리지 않는다.

## Spacing
- **베이스 단위:** 8px
- **밀도:** comfortable → spacious (학습 독해는 공기가 필요)
- **스케일:** 2 · 4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 (CSS: `--s2`…`--s64`)

## Layout
- **접근:** 하이브리드 — 학습 문서는 에디토리얼, 대시보드·로드맵은 그리드
- **최대 콘텐츠 폭:** `1180px` (`--content`)
- **독서 측정 폭:** `67.5rem`(1080px, `Layout.measure`) — 학습 문서 본문(웹). 본문 좌우 여백 과다(720/1180) 개선·표/코드 혼재 가독을 위해 720→1080 확대(2026-06-18). 모바일은 화면폭이 상한이라 영향 없음
- **모의고사 카드 폭:** `48rem`
- **그리드:** 카드 `repeat(auto-fill, minmax(230px, 1fr))`, 컴포넌트 `repeat(auto-fit, minmax(280px, 1fr))`
- **로드맵 뷰:** roadmap.sh식 수직 단계 경로 — 연결선 + 노드(done/current/locked). current 노드는 액센트 + 4px weak 글로우
- **Border radius (계층):** sm `6px` · md `10px` · lg `16px` · full `999px` (모든 요소 동일 반경 금지 — 칩/배지만 full)
- **헤더:** sticky, `backdrop-filter: blur(14px)`, 배경 88% 불투명, 하단 1px border — 상세 규약은 아래 Header 섹션

## Header — AppHeader 2변형 (2026-06-13 PR4, 디자인 리뷰 1A)
두 변형 모두 **56px · blur 14 · bg 88% 불투명 · 하단 1px border · 콘텐츠 폭 1180 정렬**. 셸은 `lib/widgets/app_header.dart`의 `AppHeaderShell`.
- **홈형**(`lib/pages/home/home_header.dart` — 홈 전용 구성이라 페이지 폴더): 브랜드 + 내비 앵커 + 테마 토글 + 설정. compact(<768px)에선 내비·설정을 햄버거 메뉴로 통합(기존 동작 이식 — 문서형의 햄버거 신설 금지와 별개). 내비 활성탭 2px 틸 언더라인은 허브형 라우팅 도입 시 적용(홈은 단일 스크롤 페이지라 활성 개념 없음).
- **문서형**(`AppHeader.document`, 나머지 8페이지): ‹뒤로[+맥락 라벨] + 브레드크럼 "섹션 라벨 / **제목**(w700·ellipsis)" + 우측 **메타 텍스트 → 페이지 액션 → 테마 토글**(슬롯 순서 고정). back은 `Navigator.maybePop`(AppBar 기본과 동일 — 스택 루트에선 숨김). 파괴적 액션(기록 초기화)은 muted 아이콘+확인 다이얼로그, wrong 색 상시 사용 금지.
- **collapse 우선순위**(좁아질 때, TextPainter 실측 기반 — 제목 최소 가시 12자 확보까지 순서대로 드롭): 검수 날짜 → '✓ 검증됨' 배지 → 섹션 라벨 → 제목 ellipsis → (최후) back 맥락 라벨 텍스트(셰브론 유지). **햄버거 도입 금지.**
- **글래스 실재 조건:** 페이지가 `extendBodyBehindAppBar: true` + 스크롤 상단 인셋(`headerScrollInset`)으로 콘텐츠를 헤더 밑에 흘릴 때. 예외: plan(본문 NestedScrollView의 내부 sticky 헤더와 겹침 충돌 — 불투명 폴백).
- 검수 메타: study_doc 헤더 우측에 `✓ 검증됨 · 검수일`(textMuted/textFaint, 본문 검수 배지의 절제된 에코 — 로드 후 표시).

## Touch targets — 탭 영역 48dp (2026-11-19 A6-1)
- **최소:** 모든 인터랙티브의 탭 영역은 **48dp 이상**(`Touch.min`, Material 권장). 간격 스케일에 48은 있고 **44는 없다**.
- **도색은 그대로 둔다.** 48은 **탭 영역의 하한이고 보이는 크기의 규정이 아니다** — Material 3 자신의 방식(도색 40dp + 타깃 48dp)을 따른다. 수단은 `lib/widgets/touch_target.dart`의 `TouchTarget`: 자기가 48dp를 차지하고 그 안의 빈 띠에 들어온 포인터를 자식 중앙으로 돌려보낸다. 잉크(ripple·hover)는 보이는 버튼에 딱 맞게 남는다.
- **현재 도색:** 버튼·칩 44 · 헤더 아이콘 36 · 출처 칩 43 · 필터 칩 36 — **전부 유지**(웹 시각 변화 0).
- **공통 위젯만으로는 부족하다(2026-11-20 A6-5~7).** 페이지가 **직접 만든 표면**은 A6-1의 9종 목록 밖이라 그대로 남아 있었다 — 아젠다 체크박스 32dp·텍스트 버튼 21dp·아이콘 버튼 40dp, 리포트 학습문서 링크 21.7dp·개념 칩 30dp, 결과 복기 링크 46.1dp. 전부 `TouchTarget`으로 감쌌다. **Material 기본 48dp를 끄는 세 설정**(`MaterialTapTargetSize.shrinkWrap` · `minimumSize: Size.zero` · `VisualDensity.compact`)은 도색을 줄이려는 것이므로 **그대로 두되 래퍼를 씌운다**. 새 인터랙티브를 페이지에 직접 만들 때 이 세 가지를 쓰면 탭 영역을 함께 확인한다.
- **간격은 쌍으로 줄인다.** 래퍼가 요소마다 2px/side를 더하므로, 인접 간격 토큰을 한 단 내려 **도색 사이 간격을 보존**한다(헤더 액션 `Gap.sm`→`Gap.xs` = 도색 사이 16px 그대로). 헤더 collapse 예산도 같이 바꾼다(`48 + Gap.xs == 44 + Gap.sm`이라 값은 불변).
- **배치:** `TouchTarget`은 `FocusRing` **바깥**(링은 도색 경계에 붙어야 한다). 48 + 링 4 = 52 < 56이라 헤더 셸에 들어간다.
- **예외 — 문항 번호 그리드 칩 34dp:** 2026-10-30 결정이 65칩을 360px 9행에 맞춰 설계했다. 키우지 않고 **간격을 8dp**로 둬 Material의 완화 조건(48 미만이면 최소 8dp 간격)을 맞춘다.
- 가드: `test/touch_target_test.dart` — 탭 영역 ≥48 **과 도색 불변을 함께** 단정한다(한쪽만 보면 반대 방향으로 망가진다).

## System bars — 스크롤 인셋 (2026-11-19 A6-2)
- **상단** `headerScrollInset(context, {gap})` — 글래스 헤더 높이 + 여백. **하단** `scrollBottomInset(context, {gap})` — 시스템 내비게이션 바 인셋 + 여백. 둘 다 `lib/widgets/app_header.dart`, **반드시 Scaffold body 아래 컨텍스트로** 호출한다.
- **스크롤 콘텐츠는 바 밑으로 흐르게 두고(edge-to-edge) 패딩으로 끝 여백만 확보한다.** `SafeArea`로 스크롤 영역을 자르지 않는다 — 스크롤 가능 높이가 줄고 바 위에 죽은 띠가 생긴다. `SafeArea`는 **고정** 하단 요소(트랜스포트 바)에만 쓴다.
- **기준은 제스처 24dp가 아니라 3버튼 내비 48dp다** — 제스처 바는 반투명 핸들이고 탭도 통과하지만(실측), 3버튼은 **실제 바가 화면을 가린다**(실측 inset 126px). `padding.bottom`이 모드에 맞는 값을 주므로 코드에서 분기하지 않는다.
- `bottomNavigationBar`가 있는 페이지는 Scaffold가 `padding.bottom`을 소비하므로 **더하지 않는다**(이중 여백). 그래서 `viewPadding`이 아니라 `padding`을 쓴다.
- 스크롤 중간에 요소가 바 영역을 지나는 것은 **정상**이다(뷰포트 바닥까지 그린다). 고칠 것은 **스크롤 끝의 여백**이다.
- 웹은 인셋이 0이라 시각 변화 없음. 가드: `test/scroll_bottom_inset_test.dart`(라우트별 적용 수를 고정한다 — 스크롤 뷰를 새로 만들면 그 표에 더한다).

## Motion
- **접근:** minimal-functional — 이해를 돕지 않는 모션은 집중 도구에선 방해
- **Easing:** enter `ease-out` · exit `ease-in` · move/일반 `ease` (.15s 기본 전환)
- **Duration:** micro 50–120ms · short 150–250ms · medium 250–400ms
- **사용처:** 정답/오답 공개 페이드, 카드 hover(translateY -2px + border 액센트), 테마 전환(.25s), 부드러운 스크롤. **스크롤 안무/시차 효과 금지**
- **모션 확정값 (2026-06-12 디자인 리뷰 5A):**
  - 라우트 전환: 순수 fade — **enter 200ms ease-out / exit 150ms ease-in**. `app_theme.dart`의 `AppFadePageTransitionsBuilder`가 `pageTransitionsTheme`에 **TargetPlatform 6키 전부** 등록(웹은 호스트 OS를 platform으로 보고 — 누락 시 해당 OS 방문자가 스톡 전환을 봄). 슬라이드/줌 전환 금지
  - 스플래시 페이드아웃 250ms ease-in 후 DOM 제거 · 헤어라인 전이 200ms ease-out
  - 로딩 상태 등장 페이드인 80ms ease-out (150ms 유예 후) · 스플래시 펄스 1.2s 무한
  - **접근성:** Flutter 측은 `MediaQuery.disableAnimations` 존중(전환·페이드 생략, 7A), 스플래시는 `prefers-reduced-motion` 존중

## Focus — focus-visible 토큰 (2026-06-12 디자인 리뷰 7A · 2026-06-13 PR4 확장)
- 키보드 포커스 표시: **액센트 2px 아웃라인 + 2px 오프셋** (`lib/widgets/focus_ring.dart`의 `FocusRing`)
- 링 공간(2+2px)은 평시에도 투명하게 확보 — 포커스 이동 시 레이아웃 시프트 없음
- **인셋 변형 `InsetFocusRing`/합성 `FocusTap`(PR4 DT4):** 카드 그리드·퀴즈 선택지·34px 문항 칩처럼 바깥 4px 확보가 격자 간격을 바꾸는 표면은 경계 **안쪽**에 액센트 2px 링(foregroundDecoration, 레이아웃 영향 0)
- 적용 표면: 상태뷰 버튼·테마 토글(PR2) · 헤더 전체(back·내비·토글·설정·메뉴·초기화) + 퀴즈 선택지·버튼·문항 그리드·플래그·카드·CTA·출처 필·플랜 행/월 셀(PR4 — 감사표: docs/superpowers/specs/2026-06-13-pr4-pattern-mapping.md §2)
- 규칙: 모든 인터랙티브는 ①Tab 도달 ②링 표시 ③Enter/Space 동작. GestureDetector 단독 인터랙티브 금지(InkWell 계열 사용)

## State Views — 비동기 페이지 공용 상태 뷰 (lib/widgets/state_views.dart)
비동기 페이지 7종(StudyDoc/Quiz/Exam/CertExam/CertDetail/Review/Report)의 로딩/빈/에러 표시 표준.
페이지별 임의 로딩 표시 금지 — 전부 이 3종을 쓴다. 모두 surface가 아닌 bg 위, 콘텐츠 블록 중앙 정렬.
- **Loading:** 표시 전 **150ms 유예**(그 안에 해소되면 한 번도 그리지 않음 — 깜빡임 방지) + 등장 80ms ease-out 페이드인. 28px 틸 링(트랙 accent-weak / 진행 accent, 3px) + "무엇을 불러오는지" 한 줄(text-muted)
- **Empty:** **아이콘 없음** — 텍스트(+선택 CTA)만 (2A, 에디토리얼 절제). 빈 이유와 다음 행동을 정직하게 설명. CTA는 ghost 버튼(액센트 텍스트 + border-strong)
- **Error (fatal):** wrong 시맨틱 — 40px 원형 `!` 아이콘(wrong-weak 배경/wrong 전경) + 메시지 + 보조 설명 + 복구 경로 2개: [다시 시도] FilledButton + 홈으로 밑줄 링크
- **fatal/optional 분류:** 페이지의 주된 콘텐츠 실패 = fatal → ErrorView. 부가 메타 실패 = optional → 의도적 부분 degrade 유지(주석 보존). 페이지별 분류표·빈 상태 매핑: `docs/superpowers/specs/2026-06-13-pr2-state-views-copy-matrix.md`

## Voice — 제품 카피 보이스
- **전 제품 카피는 합니다체** — 해요체 금지. 기존 제품 카피(시험·퀴즈·오답노트)와 정합 (2026-06-12 디자인 리뷰 3A)
- 개발자 어휘를 사용자에게 노출하지 않는다 — '엔진', '엔트리포인트', '런타임' 등 금지. 사용자 언어로 치환("학습 환경을 준비하고 있습니다…")
- **상태 카피 패턴(PR2 편입):** 로딩 "〈무엇〉을 불러오고/준비하고/계산하고 있습니다…" · 빈 "검증된 〈무엇〉이 아직 없습니다" / "아직 〈무엇〉이 없습니다"(+빈 이유·다음 행동) · 에러 "〈무엇〉을 불러오지/준비하지 못했습니다."(+공통 보조 "네트워크가 잠시 불안정했을 수 있습니다. 다시 시도하면 대부분 해결됩니다.")
- 페이지(7)×상태(로딩/빈/에러) 전체 카피 매트릭스 정본: `docs/superpowers/specs/2026-06-13-pr2-state-views-copy-matrix.md` — 카피 변경 시 이 표와 코드를 함께 갱신

## Splash — 부팅 스플래시 (web/index.html)
첫 페인트부터 브랜드 — 흰 화면 대신 웜 페이퍼/다크 스플래시. 외부 CSS·폰트 로드 전에 떠야 하므로 토큰을 인라인하고 시스템 폰트 폴백으로 렌더한다. 로딩조차 이 문서의 일부다.
- **구성:** 워드마크("구름" text + "사다리" 액센트, weight 800 — 헤더 워드마크도 같은 두 톤이다) + 펄스 도트(1.2s 무한) + 단계 문구 + 하단 헤어라인 진행. 그 외 부가 텍스트 없음(절제 — 검증 통계 한 줄도 기각, 2026-06-12 8A)
- **단계 문구(합니다체, 3종):** "학습 환경을 준비하고 있습니다…" → "거의 다 됐습니다…" → "시작합니다…" — 부트스트랩 실제 이벤트(엔트리포인트 로드→엔진 초기화→앱 시작)에 매핑
- **헤어라인 = 진짜 진행률:** 단계 이벤트에 33%→66%→100% fill 매핑, 전이 200ms ease-out. 가짜/시간 기반 진행바 금지. 트랙=border, fill=text
- **테마 일치:** localStorage `awsdocs.theme.v1`을 읽어 다크 사용자에겐 다크 스플래시(#14181F), 키 없음/파손 시 웜 페이퍼(#FBFAF8) — 스플래시와 첫 프레임 색 항상 일치
- **stall 워치독:** 단계 전이 후 20초 무진행 시 비차단 안내 한 줄 추가(진행 UI 유지, 실패 선언 아님): "로딩이 길어지고 있습니다 — <u>새로고침</u>하거나 잠시 기다려 주세요." (text-faint, 새로고침은 액센트 링크)
- **제거:** `flutter-first-frame` 이벤트(첫 프레임 렌더 — runApp 해소 시점 아님)에 페이드아웃 250ms ease-in 후 DOM 제거
- **reduced-motion:** `prefers-reduced-motion: reduce`에서 펄스 정지, 페이드아웃은 즉시 제거로 대체
- **검증:** `flutter_app/tool/verify_splash.mjs` — 존재→소멸 DOM 어서션 + 스크린샷 + 네트워크 타이밍 기록

### Android 스플래시 (시스템이 그린다)
워드마크·진행 헤어라인이 없다 — 시스템 스플래시는 **배경색과 런처 아이콘**만 그린다. 디자인 결정은 「색이 앱 배경과 같아야 한다」 하나다.
- **색:** `splash_background_light` `#FBFAF8` · `splash_background_dark` `#14181F` — 웹 `theme-color` 와 같은 값이고 `test/splash_theme_sync_test.dart` 가 웹에서 읽어 비교한다
- **테마 일치:** `MainActivity` 가 `ThemePrefStore` 의 **저장 파일을 직접 읽어** `setSplashScreenTheme` 으로 라이트·다크 테마를 지정한다 — 웹의 스플래시 JS 와 같은 수준이다(둘 다 같은 키 `awsdocs.theme.v1` 을 본다)
- ⚠️ **이번 실행의 스플래시는 바꿀 수 없다.** 프로세스가 시작되기 전에 WindowManager 가 그리므로 그 지정은 **다음** 콜드 스타트부터 유효하다(공식 javadoc: "overrides and **persists**"). 그래서 **설치 직후 첫 실행 한 번**과 **API 31 미만**은 시스템 테마를 따른다 — 고칠 수 없는 한계다
- ⚠️ 테마 이름(`SplashThemeLight`·`SplashThemeDark`)을 **바꾸면 이미 설치된 기기**가 업데이트 후 스플래시를 못 찾는다(같은 javadoc). 가드가 두 이름을 고정한다
- **측정:** `tool/android_splash_trace.py` — `screenrecord` + ffmpeg 로 30fps 프레임의 색 전환을 본다. ⚠️ `screencap` 루프는 캡처당 ~800ms 라 2초 안에 끝나는 전환을 놓친다

### Android 미디어 알림·잠금화면 (2026-11-21 D1-b)
강의 재생 중 잠금화면·알림에 뜨는 카드. 시스템이 레이아웃을 그리므로 우리가 정하는 것은 **배지 아이콘·제목·버튼 구성** 셋이다.
- **배지(small icon):** `drawable/ic_stat_lecture` — **배경 없는 흰 'A'** 만 그린다(`tool/make_app_icon.py --notification`, 5개 밀도). ⚠️⚠️ **런처 아이콘을 쓰면 안 된다** — 안드로이드는 small icon 의 **알파 채널만** 쓰고 강조색으로 칠하는데, 런처 아이콘은 사각형 전체가 불투명해 **글리프 없는 단색 원**이 된다(실측). 글자 비율은 헤더 마크와 같다(`MARK_GLYPH` 53.8%) — 시스템이 그리는 원이 헤더의 둥근 사각형 자리를 대신한다
- **제목·부제:** 재생 중인 **강의 제목** + `kAppDisplayName`(「구름사다리」). 부제를 비우면 「무엇을 재생하는지」가 반쪽만 보인다
- **버튼:** 재생 중 `일시정지 + 정지` · 일시정지 중 `재생 + 정지` · 정지(idle) 중 버튼 없음(알림이 내려간다). ⚠️ **탐색 바(`seek`)는 두지 않는다** — 세션 경계에 위치를 싣는 길이 없어 켜면 **먹지 않는 조작과 0 에 멈춘 위치**를 보여 준다
- ⚠️ 아이콘은 전부 **런타임 이름 조회**로 찾으므로 `res/raw/keep.xml` 이 지켜야 릴리스에서 지워지지 않는다(아래 Decisions Log)

## Brand Rules — 정직함의 시각화 (제품 고유)
- 검증되지 않은(생성) 문항은 노출하지 않는다. UI에서도 "준비 중 · 검증 N"을 정직하게 표기
- 배지 체계: `검증 문항 N`(correct-weak/correct), `준비 중 · 검증 N`(surface-2/muted), 레벨(info-weak/info), 학습 중(accent-weak/accent)
- 검증 문항 수가 임계치 미만이면 모의고사 시작 버튼 비활성 + 사유 표기 (가짜 자신감 방지)
- 학습 문서엔 검수 메타 노출: `✓ 검증됨` 배지 + 최종 검수일 + 출처(공식 Exam Guide)
- "이해 중심"의 시각적 구현: 학습 문서는 조판된 책처럼(42rem, line-height 1.8), 핵심 판단 기준은 액센트 콜아웃(`.why`), 오답해설은 wrong 시맨틱으로 "왜 아닌가"를 채움

## Decisions Log
| 날짜 | 결정 | 근거 |
|---|---|---|
| 2026-06-05 | 디자인 시스템 신규 생성 "조용한 레퍼런스" | /design-consultation. 경쟁 리서치(Tutorials Dojo/Skill Builder/roadmap.sh) + HTML 프리뷰 검증 |
| 2026-06-05 | 액센트 = verified 틸 `#0E8175` (앰버/인디고 대신) | 검증·정직함 가치와 색 의미 일치, 현재 사이트 틸 계열과 연속성, 이행 비용 최저 |
| 2026-06-05 | 기본 테마 = 라이트 (+ 다크 토글) | 긴 학습 문서 독해엔 밝은 배경이 눈 피로 적음. 다크는 야간용 토글 |
| 2026-06-05 | 폰트 = Pretendard + JetBrains Mono (Inter 교체) | 한국어 우선 제품에 한글 렌더링이 약한 Inter는 부적합. 단일 최대 개선점 |
| 2026-06-05 | 미감 = 반(反)마케팅 에디토리얼 | EUREKA: AWS 학습 사이트는 더 시끄러운 마케팅으로 경쟁하지만, 신뢰하는 공부 도구는 레퍼런스 책처럼 생긴다. 절제가 곧 브랜드 |
| 2026-06-13 | 스플래시 + 보이스(합니다체) + 테마 영속화 (PR1) | 백색 화면 제거(시각 리펙토링 B안 WS1·WS2·WS9). 2026-06-12 디자인 리뷰 8건 결정 반영 — 헤어라인 진짜 진행률, 워치독 비차단, 워드마크만(통계 기각), reduced-motion |
| 2026-06-13 | 라우트 fade 전환(6키) + 상태뷰 3종 + focus-visible 토큰 (PR2) | 시각 리펙토링 B안 WS3·WS4. 전환 enter 200/exit 150ms, Loading 150ms 유예, Empty 아이콘 없음(2A), Error wrong 시맨틱+복구 2경로, 카피 매트릭스 합니다체(3A), disableAnimations 존중(7A) |
| 2026-06-13 | Pretendard Variable(woff2) 전환 + Wght 토큰 (PR3) | 시각 리펙토링 B안 WS5. 폰트 6.9→2.75MB(임계 경로 단축), 모든 weight 정확 렌더(디퍼럴 스와프 문제 없음), fontWeight↔fontVariations 1:1 게이트 |
| 2026-06-13 | AppHeader 2변형 롤아웃(9페이지) + collapse 규약 + 글래스(extend) + focus 인셋 변형 + 키보드 감사 (PR4) | 시각 리펙토링 B안 WS6·7·8 + DT4. 헤더 셸 56px 통일(홈 60→56), 브레드크럼 분해(정보 손실 0 — 인벤토리 대조), 세션 액션은 본문 유지(OQ2), plan만 비확장(NestedScrollView 충돌), GestureDetector 인터랙티브 0건화 |
| 2026-06-18 | 학습 문서 독서 측정 폭 720→1080px (`Layout.measure`) | 웹에서 본문 좌우 여백 과다(본문 720 / 콘텐츠 1180 → 여백 각 ~230px). 표·코드 혼재 학습문서 가독 위해 1.5배 확대. 모바일은 화면폭이 상한이라 영향 없음. 사용자 승인하 measure 원칙 완화 |
| 2026-06-30 | 홈 상단 due 배너 색 시맨틱(today=accent·overdue=warning)·상태 아이콘 + 출처 칩 full radius·외부 ↗·w500 | 밀린 일정을 긍정 신호(accent+완료 아이콘)로 가리던 것을 정직하게 분리(warning; 빨강은 압박이라 배제). 출처 칩을 L97 "칩=full" 정책에 정합 + 외부 새 탭 단서(↗) 명시 |
| 2026-10-30 | **대비(M-6): faint는 텍스트 금지 · warning 텍스트는 별 토큰 · correct 상향 · surface2 액센트 텍스트는 accentStrong** | 2026-09-22 리뷰 부록 A 실측(라이트 faint 2.98 · warning 텍스트 3.49 · correct 라벨 3.83)을 재계산해 전건 재확인. 값만 올리면 faint(4.88)가 muted(5.65)와 겹쳐 3단 위계가 눌리므로, **텍스트를 muted로 옮기고 faint는 비활성·장식으로 격하**(= 리뷰가 원칙으로 적은 쪽). 리뷰 제안값은 `surface2`에서 미달이었다(faint 4.31 · 다크 4.15). `accent/surface2` 4.21은 부록 A에 없던 발견 — surface2 패널 7곳이 accent 텍스트였다. 2026-06-30의 색 시맨틱(today=accent)은 같은 틸 계열의 강 변형이라 유지된다 |
| 2026-10-30 | **시험 러너 모바일: 768px 미만 문항 그리드 접이식 + 상시 제출 + 미답·플래그 점프**(리뷰 UX-1·UX-2) | 65칩 `Wrap`이 360px에서 9줄(≈338px)로 첫 뷰포트를 지배해 "지금 풀 문항"이 위계 3순위로 밀렸다. 요약 칩("12 / 65 · 미답 8 · 플래그 3")이 그 자리를 대신하고, 중복이던 상단 진행 표시는 좁은 폭에서 접는다. 제출은 어느 문항에서든 **정확히 한 곳**에만 둔다(마지막 문항은 하단 기본 버튼). 갈 곳이 없는 점프 버튼은 그리지 않는다 |
| 2026-10-30 | **진행 중 모의고사 "이어서 풀기" 카드**(홈·자격증 상세, 리뷰 UX-4) | 세션 복원이 이미 있는데도 발견되지 않던 문제. 남은 시간은 `남은 1시간 29분` 꼴 — 러너의 `mm:ss`를 카드에 쓰면 90분 시험의 `89:30`이 시·분으로 잘못 읽힌다(카드는 흘깃 보는 곳). 만료 세션과 "시작 시각 판단 불가"를 가른다 — 후자를 숨기면 세션을 잃는 반목표가 된다 |
| 2026-10-30 | **결과 화면 오답 우선 필터 + 정답 카드 접힘**(리뷰 UX-5·M-10) | 65장을 구분 없이 나열해 "오답 12개"를 찾으려면 전부 스크롤해야 했다. 기본 필터를 오답으로 두고 칩에 개수를 적는다. **전부 정답이면 접지 않는다** — 그때 화면의 할 일은 분류가 아니라 복기이고, 연습 퀴즈 스펙 §9.3이 결과 화면에 "정답 라벨 + 해설 재표시"를 약속한다. 필터가 집합을 가르지 못하면 칩 자체를 그리지 않는다 |
| 2026-11-19 | **터치 타깃 48dp — 도색은 불변**(A6-1, 제품화 로드맵) | Android 점검이 공통 위젯의 미달을 찾았다. 다만 그 수치는 접근성 노드라 **실제 탭 영역이 아니었다** — 위젯 테스트로 재니 헤더 아이콘 36dp·뒤로 버튼 30x34dp로 8px 더 작았다(FocusRing의 4px 패딩은 InkWell 밖이라 눌리지 않는다). 처방은 **Material 3 자신의 방식**: 도색 40dp + 타깃 48dp. 보이는 크기를 48로 올리는 쪽은 택하지 않았다 — 정답 보기처럼 **정확하려고 길어진** 텍스트가 든 버튼이 많아 일률 확대가 웹 레이아웃을 흔든다. 간격 토큰을 한 단 내려 도색 사이 간격을 보존했고(헤더 16px 그대로) collapse 예산은 `48 + Gap.xs == 44 + Gap.sm`이라 값이 변하지 않았다. 문항 그리드 칩 34dp는 2026-10-30 밀도 결정을 되돌리지 않으려 유지하고 간격을 8dp로 올려 Material 완화 조건을 맞췄다 |
| 2026-11-19 | **스크롤 끝 시스템 바 인셋 — `scrollBottomInset`**(A6-2) | 상단 인셋은 `headerScrollInset`으로 여덟 파일에서 일관되게 처리하는데 **하단 짝이 없었다** — 끝까지 스크롤해도 마지막 요소가 내비게이션 바 밑에 깔린다. 실측이 점검 문서의 판정을 둘 바로잡았다: 침범은 **기본 글자 크기에서도 스크롤 중간이면** 생기고(문서는 최상단 한 위치만 봤다), 침범량이 늘 inset 전체인 것은 **뷰포트 바닥까지 그리는 정상 동작**이며 **제스처 바 안쪽을 눌러도 탭이 먹는다**(시스템은 스와이프만 가로챈다). 그래서 목표를 「침범 0건」에서 **「스크롤 끝 여백」**으로 바꿨고 기준은 제스처 24dp가 아니라 **3버튼 내비 48dp**다(실제 바가 화면을 가린다). `SafeArea`로 스크롤 영역을 자르지 않은 이유는 스크롤 높이가 줄고 바 위에 죽은 띠가 생기기 때문이고, `viewPadding`이 아니라 `padding`을 쓴 이유는 `bottomNavigationBar`가 있는 페이지에서 Scaffold가 이미 소비해 이중 여백을 막아 주기 때문이다. 웹은 인셋이 0이라 시각 변화가 없다 |
| 2026-11-20 | **제품 이름 「구름사다리」 — 워드마크 「구름」 본문색 + 「사다리」 액센트**(사용자 확정) | 옛 이름 「AWS Docs Roadmap」은 「AWS Docs」가 아마존 공식 문서의 이름이라 Play 사칭 정책 위험이 있었다(로드맵 A0). Play 등록명은 「구름사다리 — AWS 자격증 학습·모의고사」(30자 한도 안), 런처·PWA `short_name`·헤더는 「구름사다리」다. 스플래시가 이미 쓰던 **앞 단어 본문색 + 뒤 단어 액센트** 구조를 그대로 옮겼고, 단색이던 헤더 워드마크도 같은 두 톤으로 맞췄다(액센트/bg 대비는 `theme_contrast_test` 가 AA 로 단정하는 쌍이다). 공유 미리보기 `og-image.png` 는 생성기 없이 손으로 만든 이미지였어서 `tool/make_og_image.py` 로 **같은 배치·같은 문구**에 워드마크만 바꿔 다시 그렸다. 가드: `brand_name_test.dart` |
| 2026-11-20 | **한국어 어절 단위 줄바꿈(keep-all) — 앱 전체**(사용자 지적) | 홈 소개 「…덤|프 암기…」처럼 앱 전체가 한국어를 **글자 단위로** 끊었다. 웹은 CSS 한 줄이지만 Flutter 3.47.2 에는 그 설정이 없어 한글이 낀 글자 쌍 사이에 U+2060(WORD JOINER)을 넣는다. lib 의 `Text(` 가 42개 파일 205곳이라 호출부를 바꾸지 않고 **같은 이름의 `Text` 위젯**(lib/widgets/text.dart)으로 import 만 바꿨다. 실측이 세 번 설계를 고쳤다 — ① 모든 비공백 쌍을 막으면 URL 「/」 뒤 같은 원래 끊을 자리까지 막혀 긴 덩어리가 엉뚱한 곳에서 잘렸다 → **CSS keep-all 과 같이 한글이 낀 글자·숫자 쌍만** 막는다 ② 「A · B」 구분자에서 다음 줄이 「·」 로 시작했다 → 앞 공백을 U+00A0 으로 ③ **넣은 문자도 자간을 받아** 음수 자간인 제목이 글자마다 당겨지고 끝 쉼표가 잘렸다(에뮬레이터 「자격증,」) → 자간이 0이 아니면 넣은 문자만 자간 0 조각으로 뗀다(본문은 자간 0이라 해당 없음). 대가: 선택·복사한 글에 보이지 않는 문자가 섞인다(낭독 라벨은 원문으로 둔다) |
| 2026-11-20 | **페이지가 직접 만든 표면도 48dp**(A6-5~7, A6 체크리스트 순회) | A6-1 이 공통 위젯 9종을 고쳤지만 **페이지 안에서 만든 표면**은 그 목록 밖이라 그대로였다 — 에뮬레이터 16화면 순회가 여섯을 찾았다(아젠다 체크박스 **32dp**·텍스트 버튼 21dp·아이콘 버튼 40dp, 리포트 학습문서 링크 21.7dp·개념 칩 30dp, 결과 복기 링크 46.1dp). 체크박스는 **노드가 아니라 손가락으로 확정**했다 — 중심 탭은 먹고 **32dp 밖·48dp 안은 먹지 않았다**(29개 항목을 지워 나가는 화면에서 가장 자주 눌리는 요소다). 전수 grep 으로 Material 기본 48dp 를 끄는 세 설정(`shrinkWrap`·`Size.zero`·`VisualDensity.compact`)이 **`plan_agenda.dart` 한 파일**에만 있음을 확인했고, 그 설정은 도색을 줄이려는 것이므로 **그대로 두고 `TouchTarget` 래퍼만** 씌웠다. 판정 도구를 `tool/android_ui_audit.py` 로 커밋해 재점검이 가능해졌다(가드 9건·self-test 17묶음) — 측정 도구는 커밋하거나, 커밋하지 않았다고 적는다 |
| 2026-11-20 | **Android 스플래시가 시스템 테마가 아니라 저장 테마를 따른다**(A6-4 잔여) | A6-4 1차가 색을 앱 배경에 맞췄지만 그 색이 `values-night/` 한정자로 **시스템** 다크를 따라서, 「시스템 다크 + 앱 라이트」에서 **`#14181F` 가 1,867ms** 보인 뒤 `#FBFAF8` 로 튀었다(30fps 녹화 실측 — `screencap` 루프로는 세 점만 찍혀 안 보인다). `MainActivity` 가 저장 파일을 직접 읽어 `setSplashScreenTheme` 으로 고정색 테마를 지정한다. **측정이 수정 범위를 줄였다** — `NormalTheme`(흰색·검정) 구간이 전 프레임에서 **관측되지 않아**(시스템 스플래시가 Flutter 첫 프레임까지 유지) `window.setBackgroundDrawable` 을 넣지 않았다. ⚠️ **1차 구현이 틀린 디렉터리를 봤고 가드가 그것을 굳히고 있었다** — grep 결과의 줄 번호(52·58)로 두 메서드를 하나로 읽어 `app_flutter`(= documents)를 봤는데 Dart 가 쓰는 것은 `files`(= support)다. 가드를 먼저 뒤집고 구현을 고쳤다. 다섯 조합 실측 OK이고 가장 강한 증거는 **「시스템 라이트 + 앱 다크 → 스플래시 다크」**(리소스 한정자만으로는 불가능). 가드: `splash_theme_sync_test.dart` 9건, 측정: `tool/android_splash_trace.py` |
| 2026-11-21 | **미디어 알림 아이콘을 런처 아이콘과 분리하고, 리소스 축소기에서 지킨다**(D1-b) | 잠금화면 미디어 카드의 앱 배지가 **글리프 없는 단색 원**이었다 — 안드로이드는 small icon 의 **알파 채널만** 쓰고 그것을 강조색으로 칠하는데 런처 아이콘은 사각형 전체가 불투명하다(에뮬레이터 실측). 배경 없는 흰 'A' 를 `tool/make_app_icon.py --notification` 으로 5개 밀도에 생성했다 — 적응형 foreground 와 같은 그림이고 캔버스만 작다. ⚠️⚠️ **그보다 먼저, 릴리스 빌드에서는 잠금화면이 통째로 없었다** — Flutter 가 릴리스에 리소스 축소를 켜는데 audio_service 는 버튼 아이콘을 **런타임 이름 조회**(`getIdentifier`)로 찾아 드로어블 7개가 지워졌고, SDK 33+ 의 `MediaControl.stop` 은 CustomAction 이라 `IllegalArgumentException` 이 `setState` 전체를 중단시켰다. `res/raw/keep.xml` 로 고정한다(우리 알림 아이콘도 같은 경로라 함께 넣는다). ⚠️ **파일 이름으로는 가를 수 없다**(축소기가 경로를 `res/-B.png` 로 줄인다) — 판정은 `aapt2 dump resources` 의 자원 테이블 + 대조군(0 → 7, `ic_launcher` 3 불변)이고, **디버그 빌드에는 축소가 없어 보이지 않는다.** 가드: `android_audio_service_manifest_test.dart` 가 **내보내는 모든 `MediaControl.androidIcon` + 알림 아이콘이 keep 규칙에 덮이는지** 기계로 맞댄다 |
| 2026-11-22 | **시험 결과 도메인별 정답률 — 합불 색 없음**(A1, 외부 리뷰 후속 §5-3) | AWS 실제 점수는 환산 점수라 정답률로 합불을 판정할 수 없다. 그래서 `correct`·`wrong`·액센트를 쓰지 않고 본문색으로 수치만 보여 준다. 도메인을 모르는 문항이 섞이면 합계가 총점과 어긋나므로 절 전체를 숨긴다. |
