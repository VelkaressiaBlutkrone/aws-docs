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

- **다크 모드 전략:** 표면을 재설계(단순 반전 금지). 액센트·시맨틱은 어두운 배경에서 대비 확보 위해 채도/명도 조정한 별도 값 사용. 라이트가 기본, 다크는 토글(`html[data-theme="dark"]`)
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
