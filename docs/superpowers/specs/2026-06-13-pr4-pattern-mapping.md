# PR4 — 17종 Flutter Design Pattern 매핑표 (T10/SC7) + 키보드 접근성 감사 (DT4)

_작성: 2026-06-13 · 교본: `D:\workspace\develop-study-documents\Flutter Design Pattern`(01~17) · 설계 SC7 기준_

## 1. 패턴 매핑 — 적용 / 부분 / 비적용 + 사유

| # | 패턴 문서 | 판정 | 어디에 / 왜 아닌가 |
|---|---|---|---|
| 01 | single-screen-scaffold | **적용** | 전 페이지 Scaffold 골격. PR4: AppHeader가 `PreferredSizeWidget`으로 appBar 슬롯 규약 구현, `extendBodyBehindAppBar`+body MediaQuery 인셋(글래스 헤더) |
| 02 | bottom-navigation | 비적용 | 단일 허브(홈)+push 스택 구조. 에디토리얼 사이트에 하단 탭 비목표 |
| 03 | tab-bar | 비적용 | 콘텐츠가 페이지 단위 분리. cert_detail 도메인 아코디언(ExpansionTile)이 역할 대체 |
| 04 | drawer | 비적용 | 디자인 규약상 문서형 햄버거 금지. 홈 compact 내비는 PopupMenu(기존 동작 이식) |
| 05 | master-detail | **부분** | 분해(T8)로 마스터(홈 카드 그리드)→디테일(cert_detail) 라우팅 구조까지. ≥920px 2단 적응형은 OQ1 후속(설계 명시 이연) |
| 06 | onboarding-wizard | 비적용 | 무계정·무온보딩 정체성. plan 생성 폼은 단일 화면 미리보기형 |
| 07 | pull-refresh-infinite-scroll(상태 머신) | **적용(상태 축)** | 비동기 페이지 7종의 로딩/빈/에러/데이터 상태 표준(state_views, PR2)+150ms 유예. 당겨새로고침·무한스크롤 축은 정적 에셋 콘텐츠라 비적용 |
| 08 | theme-i18n | **적용(테마 축)** | AppColors ThemeExtension·ThemeScope·테마 영속화(WS9)·pageTransitionsTheme 6키(PR2)·Wght 가변축 토큰(PR3). i18n 축은 한국어 단일 제품이라 비적용 |
| 09 | network-dio | 비적용 | 콘텐츠는 rootBundle 에셋(네트워크 레이어 부재). Firebase SDK는 자체 채널 |
| 10 | local-storage | **적용** | LocalKV(localStorage)+`KvBackend` 주입 추상화 — ThemePrefStore(PR1)·플랜/체크/열람/이력/세션 스토어 전부 이 위에 |
| 11 | form-validation | 부분 | plan 생성 폼: 날짜 범위 제약(showDatePicker first/last)+미리보기 경고(buildPlan warnings). 텍스트 입력 폼 부재로 validator 축 비적용 |
| 12 | error-handling-logging | **적용** | fatal/optional 분류+ErrorView 복구 2경로(PR2) · **글로벌 핸들러(PR4 T9)**: FlutterError.onError(presentError+로그)/PlatformDispatcher.onError(true, 비정지)/ErrorWidget.builder(절제 박스) · `appLog` 단일 로그 훅(부팅 degrade 경로 공유) |
| 13 | bloc | 비적용 | 상태 규모가 setState+InheritedWidget(ThemeScope)+ValueNotifier(syncController)로 충분. 도입 비용>가치 — 검증된 엔진 불변 제약과도 충돌 |
| 14 | repository | 부분 | 스토어 계층(HistoryStore 등)이 KvBackend 위 레포지토리 역할. 원격 소스 추상화는 cloud_store/sync_service 계층이 수행(이중 소스 단일 인터페이스까지는 안 감 — reconcile-on-trigger 설계) |
| 15 | result-either | 비적용 | 예외+try/catch·nullable degrade 컨벤션 채택. Either 혼입은 일관성 비용 |
| 16 | background-isolate | 비적용 | 웹 타깃(메인 스레드)·무거운 파싱 없음(문항 JSON 소형). ※SC7 본문 "16 적용 최소"는 작업 분해표 참조 패턴(10 Local Storage)의 오기로 판단 — 10으로 충족, 본 표에 정직 기록 |
| 17 | deep-link | **적용** | go_router 해시 라우팅·중첩 라우트(딥링크 시 부모 스택 복원 — back 항상 유효)·redirect 가드. per-route pageBuilder 오버라이드는 전역 fade(PR2) 유지로 미사용 — 필요 시점 참조 |

SC7 대조: 01·07(상태 축)·08(테마 축)·12·10 적용 ✓ · 05 부분(분해만) ✓ · 17 적용+오버라이드 시점 참조 ✓.

## 2. 키보드 접근성 감사 결과 (DT4)

원칙: 모든 인터랙티브는 ①Tab 도달 ②focus-visible 표시 ③Enter/Space 동작. InkWell 기반은 ①③이 내장 — 감사의 실작업은 ②(링)와 비-InkWell 교정.

**신설 토큰 변형:** `InsetFocusRing`(+합성 `FocusTap`) — 카드 그리드·선택지·34px 칩처럼 바깥 4px 확보(기존 FocusRing)가 격자 간격을 바꾸는 표면은 경계 안쪽에 링을 그린다(foregroundDecoration, 레이아웃 영향 0). DESIGN.md Focus 섹션에 등재.

| 표면 | 이전 상태 | 조치 |
|---|---|---|
| 헤더(back·내비·토글·설정·메뉴·초기화) | 내비/메뉴 링 없음 | FocusRing(아웃라인) — S2·S3 |
| 퀴즈 선택지(OptionTile) | 링 없음 | InsetFocusRing |
| 확인/다음/제출(PrimaryButton 전 사용처) | 링 없음 | InsetFocusRing |
| 시험 문항 그리드 칩·플래그/이전 버튼 | 링 없음 | InsetFocusRing |
| 오답 복기 "→ 학습문서" 링크 | 링 없음 | InsetFocusRing |
| **히어로 공식 출처 필** | **GestureDetector — Tab 불가·Enter 불가(조작 결함)** | **InkWell 전환**+InsetFocusRing(호버 강조 보존) |
| 홈 카드(자격증·콘텐츠 진입·약점 행·오늘-할-일 배너) | 링 없음 | FocusTap |
| cert_detail 행(학습문서·일정·리포트·약점·오답노트) | 링 없음 | FocusTap |
| study_doc CTA 2종 | 링 없음 | InsetFocusRing |
| plan 날짜 행·항목 열기·월 셀 | 링 없음 | FocusTap (Checkbox·SegmentedButton·TextButton·IconButton·ExpansionTile은 Material 기본 포커스 보유) |
| 상태뷰 버튼·테마 토글 | PR2 적용 완료 | 유지 |

**비인터랙티브 확인(조치 없음):** 로드맵 단계 노드(_Step — 정적 표시), 히어로 버튼 2종(HomeButton — onTap 없는 정적 장식, 기존 동작 보존), ExplainBox·배지류.

**잠금 상태:** onTap=null인 InkWell(약점 모의고사 잠금·빈 월 셀·비활성 PrimaryButton)은 Tab 순서에서 자동 제외 — 의도된 동작.

검증: 위젯 테스트(헤더 Tab→Enter pop) + dogfood(홈 Tab×3 → FocusRing 점등 스크린샷 → Enter 앵커 스크롤) + 최종 빌드에서 마우스 없는 여정(홈→문서→퀴즈→모의고사 제출) 수행.
