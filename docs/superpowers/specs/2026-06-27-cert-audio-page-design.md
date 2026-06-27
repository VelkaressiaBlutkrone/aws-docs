# 설계: 자격증별 오디오 학습 페이지

- 날짜: 2026-06-27
- 상태: 설계 승인됨(brainstorming) → 구현 계획(writing-plans) 대기
- 범위: 학습 문서에 붙어 있던 오디오 강의를 **자격증별로 모아 듣는 전용 페이지** + 상단 메뉴 진입점 + 플레이리스트 트랜스포트.

## 배경

현재 학습 오디오 강의("주머니 라디오")는 각 학습 문서 페이지 하단 미니플레이어로만 재생된다(승인된 CLF-C02 19문서, `audio_lecture` 활성·라이브). 오디오만 이어 듣기에는 문서를 일일이 드나들어야 해 불편하다. 자격증별로 강의 목록을 모아 한 화면에서 재생·이동할 수 있는 전용 페이지를 추가한다.

## 결정사항 (brainstorming)

1. **진입 모델 = 오디오 허브 → 자격증별 페이지.** 상단 "오디오" → 승인 오디오 보유 자격증 목록(현재 CLF 하나) → 각 `/cert/:code/audio`.
2. **재생 흐름 = 수동 전환.** 이전/처음/재생·정지/다음/마지막을 누르면 그 트랙을 바로 재생(사용자 제스처). **트랙이 끝나면 정지**하고 "다음 강의" 안내만 — 자동으로 넘어가지 않는다(iOS 잠금화면 ended-자동전환 함정 회피, 기존 결정 1A와 일치).
3. **연속성 = 전역.** 화면을 옮겨도(특히 "문서 보기"로 학습문서에 가도) 재생이 끊기지 않는다. 플레이리스트 위치도 전역 유지.
4. **레이아웃 = A안(하단 고정 트랜스포트).** 트랙 목록이 주(主), 처음·이전·재생/정지·다음·마지막 컨트롤은 늘 하단 고정. 현재 트랙은 목록에서 하이라이트. 각 트랙은 해당 학습문서로 가는 "문서 보기" 링크 보유.
5. **아키텍처 = 통합 플레이리스트(단일 소스).** 전역 `LecturePlaylist`가 기존 `AudioController`를 감싸 앱 전체 오디오의 단일 소스가 된다. 오디오 페이지와 학습문서 미니플레이어가 같은 플레이리스트의 뷰.

## 컴포넌트

### 1. `LecturePlaylist` (전역 단일 소스) — `lib/data/lecture_playlist.dart`

`AudioController`(주입)를 감싸는 `ChangeNotifier`. 웹은 전역 싱글톤, 테스트는 fake backend를 단 `AudioController`를 주입한다.

- 상태: `List<ContentEntry> queue`, `int index`, `String certCode`. 재생 상태(`PlaybackState`)는 `AudioController.state`에 위임.
- API:
  - `setQueue(String certCode, List<ContentEntry> tracks, {int startIndex = 0})` — 이미 같은 `certCode` 큐면 위치 보존(재설정 안 함), 다르면 새 큐로 교체(자동재생 안 함).
  - `openDoc(String certCode, String taskId)` — 학습문서 진입 시 호출. **비중단 규칙**: 큐를 `certCode`로 맞추고(다른 cert면 교체), **컨트롤러가 idle(아직 아무 것도 로드 안 됨)일 때만** `taskId` 위치로 이동해 `controller.load()`(재생 준비, 자동재생 안 함). **이미 재생 중·일시정지 상태면 컨트롤러를 건드리지 않는다**(연속성 — 흐르던 강의 유지). 즉 문서 직접 진입은 그 문서 오디오를 준비하고, 라디오 재생 중 "문서 보기"로 다른 문서에 가도 재생은 안 끊긴다(미니플레이어는 전역 현재 트랙을 반영).
  - `select(int i)` / `next()` / `prev()` / `first()` / `last()` — **명시적 트랙 변경**(오디오 페이지에서). 인덱스를 `[0, queue.length-1]`로 클램프해 그 트랙을 `controller.load()` 후 `controller.play()`(사용자 제스처 동기 진입). 트랙 변경은 이 메서드들로만 일어난다(문서 내비게이션은 트랙을 바꾸지 않는다).
  - `playPause()` — 현재 트랙 재생/일시정지 토글.
- **수동 전환**: `AudioController`가 ended를 발화해도 `index`를 바꾸지 않는다(자동 전환 없음). 상태는 ended로 두고, 트랜스포트의 "다음" 버튼이 다음 강의로의 사용자 액션.
- 인덱스 수학(next/prev/first/last/select 클램프, openDoc 위치 계산)은 순수 로직 → 단위 테스트 대상.

### 2. 기존 미니플레이어 정합 — `lib/pages/study_doc_page.dart`(소폭 수정)

학습문서 진입 시 오디오 배선을 `controller.load(doc.lectureAudioSrc)` → **`playlist.openDoc(certCode, taskId)`** 로 교체한다. `StudyAudioPlayer` 위젯은 그대로 두되 현재 플레이리스트 트랙(=이 문서)의 재생/정지를 반영한다. 오디오 페이지에서 "문서 보기"로 그 트랙의 문서에 가면 같은 트랙이 그대로 재생(끊김 없음). 문서에 직접 들어오면 그 cert·문서로 플레이리스트 위치가 잡힌다.

### 3. `CertAudioPage` — `lib/pages/cert_audio_page.dart`

라우트 `/cert/:code/audio`. `AppHeader.document`(backLabel=cert 코드, title="오디오 강의"). body = `Column[ Expanded(트랙 ListView), LectureTransportBar ]`.

- 진입 시 플레이리스트가 이 cert 큐가 아니면 `setQueue(code, approvedAudioEntries(code))`(자동재생 안 함).
- 트랙 행: 번호 + 제목 + "문서 보기"(→ `context.go('/cert/$code/study/$taskId')`). 행 본문 탭 → `playlist.select(i)`(그 트랙 재생). 현재 트랙은 accent 틴트 하이라이트(플레이리스트 구독).

### 4. `LectureTransportBar` — `lib/widgets/lecture_transport_bar.dart`

하단 고정 바. 좌→우: **처음(skip-back)·이전(track-prev)·재생/정지(accent 원형)·다음(track-next)·마지막(skip-forward)** + 현재 트랙 제목·상태 텍스트(State Views 보이스·합니다체). 플레이리스트 구독.

- 경계 처리: 첫 트랙에서 처음·이전, 마지막 트랙에서 다음·마지막은 muted+no-op(클램프). DESIGN.md "disabled 회피"에 따라 비활성 대신 muted 표시.
- 재생/정지 버튼은 기존 `StudyAudioPlayer`의 accent 원형 버튼 어휘 재사용(InkWell+FocusRing).
- 상태 라인: loading="오디오를 준비하고 있습니다…", playing="재생 중입니다.", paused="일시정지했습니다.", ended="재생을 마쳤습니다.", error="오디오를 재생하지 못했습니다." (기존 `_statusLine`과 일관).

### 5. `AudioHubPage` — `lib/pages/audio_hub_page.dart`

라우트 `/audio`. `certsWithApprovedAudio()`로 승인 오디오 보유 자격증 카드 목록을 그리고 각각 `/cert/:code/audio`로 이동. 항목이 없으면(게이트 off 등) `/`로 redirect.

### 6. 상단 메뉴 진입점 — `lib/pages/home_page.dart`

`HomeHeader.onNav`에 `'오디오': () => context.go('/audio')` 추가. **`audioLectureEnabled && certsWithApprovedAudio().isNotEmpty`일 때만** 이 항목을 넣는다(없으면 메뉴에 미표시).

### 7. 데이터·게이트 헬퍼 (순수 함수) — `lib/data/content_index.dart`

- `List<ContentEntry> approvedAudioEntries(String certCode)` — `kContentIndex[certCode]`에서 `audioApproved==true`인 엔트리를 **선언 순서대로** 반환(없으면 빈 리스트).
- `List<String> certsWithApprovedAudio()` — 승인 오디오 ≥1 자격증 코드 목록(선언 순서).
- 게이트는 `audioLectureEnabled`(const, dart-define)라 **로직은 `enabled` 인자를 받는 순수 함수**로 두고 라우트/헤더에서 const를 주입한다(기존 `shouldShowLecturePlayer` 패턴 일관). 예: `bool shouldShowAudioMenu({required bool enabled, required bool hasAudio})`.

## 라우팅·게이트

- `/audio` (top-level, `/`의 형제) → `AudioHubPage`. `audioLectureEnabled==false`거나 `certsWithApprovedAudio().isEmpty`면 `/`로 redirect.
- `/cert/:code/audio` (기존 `cert/:code` 하위, exam/review/report/plan의 형제) → `CertAudioPage`. cert가 없거나 `audioLectureEnabled==false`거나 `approvedAudioEntries(code).isEmpty`면 `/cert/:code`(cert 없으면 `/`)로 redirect.

## 테스트 전략 (TDD)

- **단위 테스트**:
  - `LecturePlaylist` 인덱스 전이: `setQueue` 위치·같은 cert 큐 보존, `next`/`prev`/`first`/`last`/`select` 클램프(경계 no-op)와 올바른 `lectureAudioSrc` `load`(fake backend로 확인), ended 시 인덱스 불변(자동전환 없음).
  - `openDoc` 비중단 규칙: idle일 때 taskId 위치로 `load`(준비), **재생/일시정지 중이면 컨트롤러 미변경**(현재 트랙·src 유지)·큐 cert만 정합. 다른 cert 진입 시 큐 교체.
  - `approvedAudioEntries`/`certsWithApprovedAudio`(content_index 순수 함수, 선언 순서·필터), 게이트 순수 함수(`shouldShowAudioMenu` 등).
- **위젯 테스트**: `LectureTransportBar`(상태별 렌더·각 버튼 탭이 플레이리스트의 해당 메서드 호출, 주입된 fake 플레이리스트/컨트롤러), 트랙 행 "문서 보기" 링크 존재.
- **라우팅**: `/audio`·`/cert/:code/audio` 해석; 승인 오디오 0 cert·미존재 cert는 redirect. (SelectionArea 위젯테스트 함정 회피 — 오디오 페이지는 content_index 동기 데이터라 비동기 렌더 크래시 위험이 낮으나, 풀 페이지 위젯 렌더 대신 로직은 단위로 검증.)
- 기준선: `flutter test` 전부 통과, `flutter analyze` 신규 0(기존 잔존 3).

## DESIGN.md 준수

`context.c` 토큰만, InkWell+FocusRing(+FocusRing) 인터랙티브, 합니다체, 비-fatal 오디오 실패에 wrong색 금지(부분 degrade), 반마케팅 절제. 트랜스포트·목록은 기존 헤더/미니플레이어 어휘 재사용(새 시각 결정 없음).

## 범위 / 비목표

- 범위: `LecturePlaylist`(+정합), `CertAudioPage`·`AudioHubPage`·`LectureTransportBar`, content_index 헬퍼, 라우트 2개, 상단 메뉴 항목, 게이트. Dart/Flutter만(파이썬 도구·오디오 자산 무변경).
- 비목표(YAGNI): 연속(자동)재생·재생속도 조절·탐색바(seek)·진행률 바·다운로드·다중 cert 정렬/필터·잠금화면 트랜스포트 버튼 확장(기존 `nowPlaying(title)`만 유지)·오디오 진행 이력 저장.

## 정본·관련

- 런타임 게이트(①+②): `docs/superpowers/specs/2026-06-26-audio-runtime-review-gate-design.md`
- M1 핸드오프: `docs/superpowers/specs/2026-06-21-study-audio-m1-handoff.md`
- 콘텐츠 검수 가이드: `docs/audio-content-review-guide.md`
- 코드: `lib/data/{audio_controller,audio_runtime,content_index}.dart`, `lib/widgets/{study_audio_player,app_header}.dart`, `lib/pages/{home_page,study_doc_page}.dart`, `lib/app_router.dart`
