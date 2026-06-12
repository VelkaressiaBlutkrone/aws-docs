# Design System — AWS Docs Roadmap

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
- **로딩 (로컬 번들 — 오프라인·무추적):** 폰트는 외부 CDN이 아니라 앱에 번들된 OTF/TTF 에셋으로 로드한다.
  - Pretendard(Regular/Medium/Bold/ExtraBold OTF) · JetBrainsMono(Regular/Medium/Bold TTF): `flutter_app/assets/fonts/`에 두고 `flutter_app/pubspec.yaml`의 `fonts:`로 등록. `app_theme.dart`가 `Pretendard`/`JetBrainsMono` 패밀리로 참조.
  - 근거: GitHub Pages 정적 배포 + 한국어 학습 제품 — CDN 의존·외부 추적·SRI 관리 비용을 피하고 오프라인에서도 렌더. (번들 목록의 단일 진실은 pubspec.)
- **font stack:**
  - sans: `"Pretendard Variable", Pretendard, -apple-system, BlinkMacSystemFont, system-ui, "Segoe UI", sans-serif`
  - mono: `"JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, monospace`
- **스케일 (px):** 13(small) · 15(ui) · 16(base) · 17(body) · 20(h3) · 28(h2) · clamp(34–52)(display)

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
| 흐린 텍스트 | `#8A93A0` | `--text-faint` |
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
| 흐린 텍스트 | `#6B7585` | `--text-faint` |
| 구조 다크 | `#0F131A` / on `#E8EAED` | `--ink` / `--on-ink` |

### Semantic (퀴즈 도구 필수)
| 의미 | Light (색 / weak) | Dark (색 / weak) |
|---|---|---|
| 정답 correct | `#1F8A52` / `#E5F4EA` | `#3DBB78` / `#15281D` |
| 오답 wrong | `#C0392B` / `#FBEAE7` | `#E06A5C` / `#2E1816` |
| 정보 info | `#2563B0` / `#E8EFF8` | `#5B9BE0` / `#15212E` |
| 주의 warning | `#B7791F` / `#F8EFDD` | `#D9A441` / `#2A2113` |

- **다크 모드 전략:** 표면을 재설계(단순 반전 금지). 액센트·시맨틱은 어두운 배경에서 대비 확보 위해 채도/명도 조정한 별도 값 사용. 라이트가 기본, 다크는 토글(`html[data-theme="dark"]`). 토글은 영속화된다 — localStorage `awsdocs.theme.v1`('dark'|'light', 평문), 키 없음/파손 시 라이트 폴백. 같은 키를 스플래시 JS(`web/index.html`)와 Flutter(`lib/data/theme_pref_store.dart`)가 공유해 첫 페인트부터 색이 일치한다
- **그림자:** sm `0 1px 2px rgba(27,36,48,.05)` (dark: `0 1px 2px rgba(0,0,0,.3)`), md `0 6px 24px -10px rgba(27,36,48,.18)` (dark: `0 10px 30px -12px rgba(0,0,0,.6)`)

## Spacing
- **베이스 단위:** 8px
- **밀도:** comfortable → spacious (학습 독해는 공기가 필요)
- **스케일:** 2 · 4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 (CSS: `--s2`…`--s64`)

## Layout
- **접근:** 하이브리드 — 학습 문서는 에디토리얼, 대시보드·로드맵은 그리드
- **최대 콘텐츠 폭:** `1180px` (`--content`)
- **독서 측정 폭:** `42rem` (`--measure`) — 학습 문서 본문. 한글 한 줄이 너무 길지 않게
- **모의고사 카드 폭:** `48rem`
- **그리드:** 카드 `repeat(auto-fill, minmax(230px, 1fr))`, 컴포넌트 `repeat(auto-fit, minmax(280px, 1fr))`
- **로드맵 뷰:** roadmap.sh식 수직 단계 경로 — 연결선 + 노드(done/current/locked). current 노드는 액센트 + 4px weak 글로우
- **Border radius (계층):** sm `6px` · md `10px` · lg `16px` · full `999px` (모든 요소 동일 반경 금지 — 칩/배지만 full)
- **헤더:** sticky, `backdrop-filter: blur(14px)`, 배경 88% 불투명, 하단 1px border

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

## Focus — focus-visible 토큰 (2026-06-12 디자인 리뷰 7A)
- 키보드 포커스 표시: **액센트 2px 아웃라인 + 2px 오프셋** (`lib/widgets/focus_ring.dart`의 `FocusRing`)
- 링 공간(2+2px)은 평시에도 투명하게 확보 — 포커스 이동 시 레이아웃 시프트 없음
- 적용 표면: 상태뷰 버튼·테마 토글(PR2 적용 완료) · 헤더 내비(PR4 예정)

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
- **구성:** 워드마크("AWS Docs " text + "Roadmap" 액센트, weight 800) + 펄스 도트(1.2s 무한) + 단계 문구 + 하단 헤어라인 진행. 그 외 부가 텍스트 없음(절제 — 검증 통계 한 줄도 기각, 2026-06-12 8A)
- **단계 문구(합니다체, 3종):** "학습 환경을 준비하고 있습니다…" → "거의 다 됐습니다…" → "시작합니다…" — 부트스트랩 실제 이벤트(엔트리포인트 로드→엔진 초기화→앱 시작)에 매핑
- **헤어라인 = 진짜 진행률:** 단계 이벤트에 33%→66%→100% fill 매핑, 전이 200ms ease-out. 가짜/시간 기반 진행바 금지. 트랙=border, fill=text
- **테마 일치:** localStorage `awsdocs.theme.v1`을 읽어 다크 사용자에겐 다크 스플래시(#14181F), 키 없음/파손 시 웜 페이퍼(#FBFAF8) — 스플래시와 첫 프레임 색 항상 일치
- **stall 워치독:** 단계 전이 후 20초 무진행 시 비차단 안내 한 줄 추가(진행 UI 유지, 실패 선언 아님): "로딩이 길어지고 있습니다 — <u>새로고침</u>하거나 잠시 기다려 주세요." (text-faint, 새로고침은 액센트 링크)
- **제거:** `flutter-first-frame` 이벤트(첫 프레임 렌더 — runApp 해소 시점 아님)에 페이드아웃 250ms ease-in 후 DOM 제거
- **reduced-motion:** `prefers-reduced-motion: reduce`에서 펄스 정지, 페이드아웃은 즉시 제거로 대체
- **검증:** `flutter_app/tool/verify_splash.mjs` — 존재→소멸 DOM 어서션 + 스크린샷 + 네트워크 타이밍 기록

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
