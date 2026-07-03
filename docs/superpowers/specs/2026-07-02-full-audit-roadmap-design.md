# 전면 감사 → 개선 로드맵 설계 (Full Audit & Improvement Roadmap)

- 날짜: 2026-07-02
- 상태: 사용자 승인된 설계(브레인스토밍 3섹션 승인 완료)
- 다음 단계: writing-plans로 구현 계획 작성

## 1. 배경 (2026-07-02 실측)

- **릴리스 상태 깨끗함**: `origin/develop` == `origin/main`(미릴리스 커밋 0), 오픈 PR 0, 워킹트리 클린.
- **기준선 실측**: `flutter test` **778개 전부 통과**, `flutter analyze` **3건**(전부 기지 잔존: plan_agenda `cacheExtent` deprecated, sync_controller_test `fake_async` 미의존 import, unused parameter). Flutter 3.44.1 / Dart 3.12.1.
- **콘텐츠 현황**:
  - CLF-C02: 19문서 · 검증문항 301개 · 승인 오디오 19개(강의 풍부화 Stage B, 음질 -16 LUFS 정규화, 환각가드 ④까지 전부 출고).
  - SAA-C03: 24문서 · 6문서만 문항 활성(90문항) — 도메인 1이 0이라 통합 모의고사 게이트 잠김.
  - SOA-C03: 20문서 · 문항 0.
- **오디오 자산**: mp3 19개 174MB가 리포·웹 번들에 포함.
- **관리 문서 낡음**: TODOS.md에 완료된 항목 잔존(C-중량 딥링크, wrongSkills — 둘 다 출고됨), CLAUDE.md 테스트 기준선 "499"(실제 778), 원격 stale 브랜치 `feat/concept-deeplink` 잔존.
- **사용자 상황**: CLF-C02 응시 임박(2~4주 내).

## 2. 사용자 결정 (브레인스토밍 Q&A)

| # | 질문 | 결정 |
|---|------|------|
| 1 | 최우선 목표 | **균형 감사 → 통합 로드맵** (전 영역 감사 후 우선순위화) |
| 2 | CLF 응시 상태 | **임박(2~4주)** → 로드맵 Phase A(시험 전)/B(시험 후) 분리, 리스크 변경은 B |
| 3 | 콘텐츠 감사 깊이 | **전체 전수**(CLF+SAA+SOA 문서·문항·대본 전부) |
| 4 | 실행 범위 | **감사 + 로드맵 + 관리위생 수정**까지 이번에. 발견 결함 수정은 로드맵 항목화 |
| 5 | 감사 구조 | **2단 교차검증 파이프라인**(발견 → 반박 검증 → 생존 항목만 사람 확인) |

## 3. 목표

코드·학습문서·오디오(대본+재생)·관리위생을 전수 감사해 결함/개선점을 수집하고, 시험 임박 상황에 맞춘 2단 로드맵(Phase A 시험 전 / Phase B 시험 후)을 만든다. 경계가 명확한 관리위생 수정은 이번 프로젝트에서 실행한다.

## 4. 산출물

1. **차원별 감사 리포트 8건** — `docs/audits/2026-07/01-code-quality.md` ~ `08-hygiene.md` (신규 디렉터리).
2. **사람 확인 목록** — `docs/audits/2026-07/human-review-list.md`. 교차검증(반박)에서 살아남은 콘텐츠 사실 의심 항목만. 우선순위·문서 위치·의심 내용·반박 결과 요약 포함. 우선순위 기준(시험 영향 순): CLF 문항 > CLF 문서 > CLF 오디오 대본 > SAA 활성 문항 > 나머지.
3. **종합 로드맵** — `docs/audits/2026-07/ROADMAP.md` + TODOS.md에 요약 반영.
4. **관리위생 수정 PR 1건** (§8).

## 5. 감사 차원 상세 (8차원)

리포트 공통 항목 형식: `[ID | 위치(file:line 또는 doc#anchor) | 발견 내용 | 심각도(H/M/L) | 확신도 | 권장 조치 | Phase A/B 제안]`

### ① 코드 품질·아키텍처 → 01-code-quality.md
- 입력: `flutter_app/lib` 110파일 (build·.dart_tool 제외).
- 점검: 파일 크기 상위(>250줄)·책임 분리 후보, 중복 패턴, dead code(미참조 심볼), TODO/FIXME/HACK 인벤토리, **DESIGN.md 규율 위반**(GestureDetector 단독 인터랙티브, fontWeight에 Wght 토큰 미병기, 하드코딩 색/간격), analyze 잔존 3건(§8 위생 수정과 연동).
- 분할: lib 하위 디렉터리 기준 3~4 에이전트.

### ② 테스트 갭 → 02-test-gaps.md
- 입력: lib 110파일 vs test 77파일.
- 점검: lib 파일별 대응 테스트 유무 맵, 위험 경로(오디오 재생 상태기계·sync 병합·plan 스케줄러·문항 샘플링) 커버리지 질, SelectionArea 함정으로 위젯테스트 불가한 영역의 단위테스트 대체 여부 명시.
- 분할: 1~2 에이전트.

### ③ 학습문서 사실 정확성 → 03-docs-facts.md
- 입력: 63문서(clf 19 · saa 24 · soa 20).
- 점검: AWS 사실 오류(서비스 설명·수치·요금 모델·시험 범위), **현행 시험 가이드 웹 대조**(CLF-C02·SAA-C03·SOA-C03이 여전히 현행 버전인지, `assets/exam_guides/`와 불일치 여부), 문서 내·문서 간 상호모순.
- 분할: 문서 4~5개/에이전트(≈13~16 에이전트). 의심 항목은 2단 검증행.

### ④ 문항 품질 → 04-questions.md
- 입력: 활성 검증문항 391개(CLF 301 + SAA 90) 전수 + 미활성 문항은 구조만.
- 점검: 정답 유일성(복수 정답 소지), 해설-정답 일치, 오답해설(wrongExplanations) 논리, `section` 앵커가 실제 문서 헤딩 `{#id}`에 실존, skill/difficulty 태그 일관성, questionCount 정합(기존 테스트 게이트 확인).
- 분할: 문서 단위(문항 15~19개)/에이전트. 의심 항목은 2단 검증행.

### ⑤ 오디오 대본 → 05-audio-scripts.md
- 입력: 19개 script.json(enrichedScriptText) + 원문 md + audioSummary.
- 점검: enrichment가 **추가한** 문장의 사실성('추가 환각' — 토큰보존 가드는 원문 누락만 잡고 추가는 못 잡는 사각), 원문 대비 의미 왜곡, 발음 병기 일관성(lexicon), audioSummary 정합.
- 분할: 대본 3~4개/에이전트. 의심 항목은 2단 검증행.

### ⑥ 오디오 재생 코드 → 06-audio-playback.md
- 입력: `audio_runtime*`, `audio_nav`, `media_session_binder`, `audio_asset_url`, `lecture_transport_bar`, `lecture_playlist`, `cert_audio_page`, `audio_hub_page`, `study_audio_player` 등 재생 경로 전체.
- 점검: 상태기계 엣지(문서 전환 중 재생, 시크 경계, 연속재생, 다중 탭), 오류 복구(404·네트워크 끊김), media session 통합, 174MB 자산 전송 방식 평가(Range·캐시 정책·초기 로드 영향 — 코드/설정 수준), 기지 iOS 함정(play() await 금지 등) 준수 재확인.
- 분할: 1~2 에이전트.

### ⑦ 의존성·플랫폼 → 07-deps.md
- 입력: pubspec.yaml + `flutter pub outdated` 실행 결과.
- 점검: 안전(패치·마이너) vs 메이저(go_router 16→17) vs Flutter 자체 업그레이드 분류, 각 메이저의 브레이킹 체인지 요약(웹 확인), **전부 Phase B 배치**(시험 전 업그레이드 금지).
- 분할: 1 에이전트.

### ⑧ 관리위생·문서 → 08-hygiene.md
- 입력: TODOS.md · CLAUDE.md · AGENTS.md · DESIGN.md · docs/ 트리 · git 브랜치 · 메모리 인덱스.
- 점검: 문서 간 불일치(기준선·완료항목·경로), docs/superpowers 스펙·플랜 아카이브 정리 필요성, .gitignore 정합, stale 브랜치, pubspec 오디오 에셋 수동 나열(19문서×4줄)의 자동화 여지.
- 분할: 1 에이전트.

## 6. 실행 구조 — 2단 교차검증 파이프라인

### 1단(발견)
- 차원별 서브에이전트 팬아웃. 문서·문항은 묶음 분할(문서 4~5개/에이전트 등).
- 각 에이전트는 **읽기 전용**(코드·콘텐츠 편집 금지) + **리포트를 파일로 직접 작성**(empty-output 함정 대응) + **scope-lock 문구**("이 작업만 수행, 끝나면 보고 후 정지, 즉흥 구현 금지, 부족하면 NEEDS_CONTEXT") + **절대경로 강제**(cwd 리셋 함정).

### 2단(검증)
- ③④⑤의 '사실 의심' 항목만 독립 검증자에게 **"반박하라"** 프롬프트로 재검(발견자와 다른 컨텍스트).
- 검증자 판정은 3값 고정: `REFUTED`(오탐 — 근거 제시, 목록 제외) / `CONFIRMED`(의심 유지 — 등재) / `UNCERTAIN`(비결정 — 등재하되 표기). 등재 대상 = CONFIRMED + UNCERTAIN.
- **반박은 항목당 1회만** — 경계부연 무한추적 금지(과거 enrich verify 함정).

### 컨트롤러(메인 세션) 검증
- 각 리포트 파일 실재·형식·표본 항목 재확인.
- 인접 레포·타 브랜치 오염 스팟체크(`git branch`/`git log`).

### 기타 규율
- 커밋 전 `git branch --show-current` 검증(CLAUDE.md §5).
- 감사 단계에서 코드 편집 금지 — 위생 수정은 별도 단계로 분리.
- 웹 확인(현행 시험 가이드·브레이킹 체인지)은 해당 차원(③⑦) 담당 에이전트가 수행.

## 7. 로드맵 형식

- **Phase A (시험 전 ~4주, 안정성 우선)**: 학습을 방해하는 결함만 — 콘텐츠 사실 오류 수정, 학습 플로우·오디오 재생 버그 수정, 사람 확인 목록 처리. 리스크 낮은 변경만.
- **Phase B (시험 후)**: 리팩토링(큰 파일 분해 등), 의존성 메이저·Flutter 업그레이드, 174MB 오디오 자산 전략, SAA/SOA 콘텐츠 확장 준비, 기계 게이트 스크립트화(앵커·링크·메타 동기화 검증 자동화), TODOS의 외부 검증자 테스트·유입 채널.
- 항목 형식: `[항목 | 발견 근거(리포트 링크) | 크기 S/M/L | 리스크 | 권장 시점]`.

## 8. 관리위생 수정 (이번 실행, 경계 고정 — 5건)

1. **TODOS.md**: 완료 항목 2건 정리(C-중량 딥링크, wrongSkills — 완료 표기 또는 제거), stale 경로 주석 갱신.
2. **CLAUDE.md**: 테스트 기준선 499→778 갱신(analyze 문구는 3번 반영과 함께).
3. **analyze 잔존 3건 해소**: `cacheExtent`→`scrollCacheExtent` 교체, `fake_async`를 dev_dependencies에 추가, unused parameter 제거 → **analyze 0 달성**, CLAUDE.md 잔존 문구 삭제.
4. **stale 원격 브랜치 삭제**: `feat/concept-deeplink` — 삭제 전 미머지 커밋 없음을 git으로 선검증.
5. **메모리 파일 갱신**: PR#78 머지됨, 음질③·환각가드④ 완료 등 낡은 메모리 반영(리포 외부).

## 9. 검증·게이트

- 위생 수정 3(코드 변경): 전체 테스트 778 통과 + `flutter analyze` 0건 확인으로 게이트.
- 문서·git 작업(1·2·4·5): 테스트 비대상, 내용 검증만.
- git 흐름: develop에서 chore 브랜치 분기 → PR → develop 머지. main 릴리스는 로드맵 실행과 함께 후속.
- 감사 리포트: 컨트롤러 표본 재확인(§6).

## 10. 함정 대응 요약

| 함정 | 대응 |
|------|------|
| 서브에이전트 리포트 유실(empty-output) | 리포트를 파일로 직접 쓰게 하고 컨트롤러가 읽음 |
| 공유 워킹트리 브랜치 오염 | 커밋 직전 브랜치 재검증, 타 브랜치 reset 금지 |
| 에이전트 cwd 리셋 | 모든 명령 절대경로 강제 |
| LLM 검증 무한추적 | 반박 1회 규율, 비결정 항목은 사람 목록으로 |
| 재합성 부작용 | 감사는 읽기 전용 — script.json·audio_meta.json·reviewStatus 불변 |

## 11. 성공 기준

- 8개 차원 리포트 전부 산출, 컨트롤러 검증 통과.
- 사람 확인 목록이 교차검증을 거쳐 오탐 제어된 상태로 산출.
- ROADMAP.md(Phase A/B) 작성 + TODOS.md 반영.
- 위생 수정 PR 머지(테스트 778 그린 + analyze 0).

## 12. 비범위 (Non-goals)

- 감사에서 발견된 콘텐츠·코드 결함의 **수정**(로드맵 항목으로만 편성).
- 의존성·Flutter 업그레이드 실행.
- 오디오 재합성·reviewStatus 변경.
- SAA/SOA 신규 콘텐츠 제작·문항 flip.
