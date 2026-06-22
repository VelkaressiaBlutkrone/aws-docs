# 학습 문서 오디오 강의("주머니 라디오") M1 — 세션 핸드오프

작성: 2026-06-21
브랜치: `feat/study-audio-m1` (develop에서 분기)

## 한 줄 요약
M1 재생 엔진(AudioController 상태머신 + Media Session 바인딩 + WebAudioBackend DOM 어댑터)에
**T4 미니 플레이어 진입점**까지 TDD로 완성·커밋했다. 2026-06-22 세션에서 iOS 실기기는
없어 수동 게이트는 **사용자 결정으로 Android 게이트로 대체**하고, **T7 Range 게이트 도구 ·
T8 failure taxonomy · T9 `{docId,sourceHash}` 메타 산출**을 보강했다.
**다음 시작점 = Android 수동 게이트 또는 실제 배포 URL로 T7 실행.**

## 브랜치 / 커밋
- `2c95dff` — T4: 미니 플레이어 진입점 + 전역 런타임 배선(조건부 import) + ContentEntry.lectureAudioSrc
- `662dfd6` — T5: AudioController 상태 머신 + 단위테스트
- `ba7cbd5` — T2: Media Session 바인딩 + AudioController ChangeNotifier
- `6a25975` — T1: WebAudioBackend + WebMediaSessionBackend (DOM 어댑터)
- 검증: **724 전체 그린(신규 위젯 9·런타임 2·경로 1), analyze 신규 0, `build web --dart-define=audio_lecture=true` 성공(회귀 0)**

## 정본 문서
- **엔지니어링 리뷰 리포트**(결정 근거): `~/.gstack/projects/VelkaressiaBlutkrone-aws-docs/deepe-develop-design-20260620-164123.md` 의 `## GSTACK REVIEW REPORT` (로컬 — 같은 머신에서만)
- **구현 보정 spec**(repo 실측): `docs/superpowers/specs/2026-06-20-study-audio-lecture-review.md`
- **Tasks T1~T9**: `~/.gstack/projects/.../tasks-eng-review-*.jsonl` (로컬)

## 확정 결정 (바꾸지 말 것 — 근거는 리뷰 리포트)
- **1A**: 문서당 **1개 합친 오디오**. iOS 잠금 시 `ended`→다음트랙 자동전환이 막히는 함정 회피.
- **2A**: 상태 로직은 단위테스트, iOS 동작은 **실기기 수동 게이트**.
- **3C**: M1 게이트 = standalone 잠금 연속재생 + 일시정지/재개 + **전화·알람 인터럽션 후 재개**.
  헤드셋·블루투스·Control Center는 M2.
- **4A**: 오디오 산출물 옆 `{docId, sourceHash}` 메타 기록(런타임 stale 비교·UI는 M2).
- 검증정책 **A(충실 변환·무검수) → 사용 후 B(보강+사람 검수)**.

## 완료 (M1 재생 엔진)
- `flutter_app/lib/data/audio_controller.dart` — PlaybackState(idle/loading/playing/paused/ended/error),
  AudioEvent, AudioBackend(주입 경계), AudioController(ChangeNotifier, `_set` 가드).
- `flutter_app/lib/data/media_session_binder.dart` — MediaSessionBackend 경계 + MediaSessionBinder
  (action→controller, state→playbackState, dispose cleanup).
- `flutter_app/lib/data/web_audio_backend.dart` — WebAudioBackend/WebMediaSessionBackend
  (package:web DOM 어댑터, 웹 전용 — VM/테스트 import 금지).
- 테스트: `test/audio_controller_test.dart`(13), `test/media_session_binder_test.dart`(6).

## 완료 (M1 T4 미니 플레이어 진입점, 2c95dff)
- `flutter_app/lib/widgets/study_audio_player.dart` — StudyAudioPlayer(상태별 렌더·재생/일시정지·
  합니다체·context.c·InkWell+FocusRing). controller 주입형(전역 dispose 금지) — 위젯 테스트 9.
- `flutter_app/lib/data/audio_runtime.dart`(+`_stub`/`_web`) — 조건부 import 경계.
  web=WebAudioBackend+WebMediaSessionBackend+MediaSessionBinder 싱글톤(지연 초기화), VM/test=null.
  `audioLectureEnabled = bool.fromEnvironment('audio_lecture')`(기본 false).
- `flutter_app/lib/data/content_index.dart` — `ContentEntry.lectureAudioSrc`(placeholder 경로 규약
  `assets/audio/{family}/{taskId}/lecture.mp3`; family=taskId 접두어. mdAsset 규약 cert마다 불규칙해 별도).
- `flutter_app/lib/pages/study_doc_page.dart` — 하단 고정 진입점(`bottomNavigationBar`, dart-define 게이트
  + doc 로드 후 표시; `_onDocReady`에서 `nowPlaying` 잠금화면 메타).
- 테스트: `study_audio_player_test`(9)·`audio_runtime_test`(2)·`content_index_test`(+1 lectureAudioSrc).
- **노출 정책 준수(이슈 5-9)**: 기본 빌드(플래그 off)에선 진입점 미연결 — 검수 전 강의 비공개.
- **함정 회피 확인**: study_doc_page가 package:web을 직접 import하지 않아 app_router_test(VM) 컴파일 유지
  (조건부 import 경계). play()는 onTap 동기 진입(await 금지) 유지.

## TTS 오디오 생성 도구 (`flutter_app/tool/gen_lecture_audio.py`, d7aed33)

학습문서 `.md` → 한국어 강의 mp3. T6 픽스처(실물 오디오) 생성용.
- **엔진: Amazon Polly Seoyeon(neural)** 기본. AWS 자격증명 필요(`aws configure`).
  ⚠️ MeloTTS는 **Windows 한국어 G2P(eunjeon)가 Visual C++ Build Tools를 요구**해 사실상 불가 → Polly로 확정.
- **정제**(보정문서 P0): 출처·자가점검 헤딩 이후 skip, `<details>`(정답 보기) skip,
  기호 변환(`→ = + ≠ ↓ § vs`), 강조 제거 시 `_` 보존(snake_case), 고아 부호 정리.
- **품질 게이트** `quality_issues`(URL·기호·정답보기·링크·고아부호) + **ID3 1개**(첫 청크 외 ID3v2 strip).
  검증 경로: `--self-test`(엔진 불필요)·`--dry-run`(대본 미리보기). Polly neural은 요청당 **3000자 한도**(청크 분할).
- 실행 파이썬: `D:\workspace\MeloTTS\.venv\Scripts\python.exe`(boto3 포함) 또는 `pip install boto3` 환경.
  Windows는 `py` 런처 사용(`python`은 Store alias로 깨짐).
- **보정 정본**: `docs/superpowers/specs/2026-06-21-clf-t1-1-tts-audio-correction.md`.

### 추가 진행 (2026-06-22, iOS 스킵)
- `gen_lecture_audio.py`가 합성 후 자동으로, 또는 `--meta-only`로 기존 MP3에서
  `audio_meta.json`을 생성한다. 메타에는 `docId`, 원문 `source.sha256`, 오디오 `sha256`,
  `Content-Type`, ID3 개수, 정제 대본 품질 이슈, `reviewStatus=needs_human_review`가 들어간다.
- 현재 untracked 픽스처 기준 `flutter_app/assets/audio/clf/clf-t1-1/audio_meta.json` 생성됨:
  `source.sha256=ef8859b790335c06a9b52f900e1881c524b494623eab0bd72a60e224c0e522ee`,
  `audio.sha256=27076bb13457eadb1b75f7efebedc694902eb9299653d30a83afef3bd91217df`,
  `id3Count=1`, `containerChecks.ok=true`. **MP3와 메타는 검수 전 픽스처라 미커밋·미배포 유지.**
- 새 도구 `flutter_app/tool/check_audio_range.py` 추가. 배포 URL에 대해 HEAD, Range
  `bytes=0-1`, `Accept-Ranges`, `Content-Type`, 캐시 validator, 선택 SHA-256을 검증한다.
  실제 T7은 MP3가 배포된 뒤에만 의미가 있다.
- 새 문서 `docs/superpowers/specs/2026-06-22-study-audio-m1-failure-taxonomy.md` 추가.
  iOS unavailable은 `not-run`으로 기록하되, 현재 M1 진행 게이트는 사용자 결정에 따라 Android로 대체한다.

### 남은 콘텐츠 검수 게이트 (사람·M2 — mp3 공개 전 필수)
- 표 → 음성 요약, 약어 발음사전(AWS·CapEx·AZ 등), `script.json` 문장 단위 사람 보정, 실제 청취 검수표.
- 통과(`reviewStatus=approved`) 전엔 **mp3 공개·repo 포함·pubspec `assets/audio/` 등록 금지**.
- 현재 `clf-t1-1` mp3 1개 생성됨(검수 전, **미커밋·미배포**). 재생 게이트엔 사용 가능, 콘텐츠 게이트는 미통과.

### 임시 자원 (정리 필요)
- `D:\workspace\MeloTTS`(clone+venv, boto3), `D:\workspace\s3_preview_*.py`, S3 버킷 `awsdocs-audio-preview-1782020416`.
- 외부 업로드(익명 호스트·S3 presigned)는 자동 모드 분류기가 차단 → 사용자가 직접 실행해야 함(검수 전 콘텐츠 보호).

## 다음 시작점: 실배포/실기기 게이트
1. **Android 수동 게이트 실행(현재 M1 대체 게이트)** — Android Chrome 탭 + standalone PWA에서
   잠금 연속재생, 일시정지/재개, 알람/전화 등 인터럽션 후 재개를 확인하고 기기·Android 버전·브라우저를 기록.
2. **실제 배포 URL이 생기면 T7 실행**:
   `python tool/check_audio_range.py https://.../lecture.mp3 --expect-sha256 <audio_meta.json의 audio.sha256>`.
   네트워크가 필요한 명령이므로 Codex 샌드박스에선 승인 실행이 필요할 수 있다.
3. **iOS 실기기 수동 게이트는 현 M1 blocking path에서 제외** — 통과로 기록하지 말고 `not-run/deferred`로 남긴다.
   iOS 특이 WebKit/PWA 리스크는 별도 보류 리스크이며, 나중에 기기가 생기면 같은 표로 추가 확인한다.
4. **콘텐츠 공개 전 게이트 유지** — `reviewStatus=approved` 전엔 mp3 repo 포함, `pubspec.yaml`의
   `assets/audio/` 등록, 기본 빌드 `audio_lecture=true` 전환 금지.

## 함정 (반드시 지킬 것)
- **iOS는 Windows 개발/CI로 검증 불가** — 실기기만. (learning: `flutter-web-pagetransitions-6keys`)
- **`play()` 앞에 await 금지** — asset/metadata await가 끼면 iOS user-activation 상실, **기기에서만**
  실패(codex). `'play() 동기 진입'` 테스트가 이를 가드. WebAudioBackend.play()도 await 없이 즉시 진입.
- **WebKit #261858은 1A(단일 파일)와 무관**(트랙 끝 버그). "30초 버그" 인용 금지.
- **package:web `setActionHandler` 콜백은 `(() => handler()).toJS`** — `MediaSessionActionDetails`
  클래스가 package:web에 없음. (learning: `package-web-mediasession-actionhandler`)
- **커밋 직전 `git branch --show-current` 검증** — 공유 워킹트리에서 HEAD가 움직임(§5).
  이번 세션에도 develop↔docs/worklist-release-pr47로 두 번 움직였음.

## M2 (M1 게이트 통과 후 별도 리뷰)
대본 생성 파이프라인 · Script Schema 파서 + 환각 가드(고유명사·서비스명·수치 토큰 보존 검사) ·
미니 플레이어 풀 UI · stale 런타임 비교/UI · H2 앵커 보강(현재 442개 중 20개뿐, SAA/SOA 0) ·
헤드셋/블루투스/Control Center · 문서간 재생 · CI 자동 생성.

## PR
- **PR #53 열림 — `feat/study-audio-m1` → `develop`**(M1 전체: T1·T2·T5·T4 + 핸드오프). origin push 완료.
  기본 빌드는 플래그 off라 사용자에게 미노출(placeholder). 실제 청취는 T6(실물 mp3 + iOS 실기기) 이후.
- 머지는 **CI 녹색 확인 후**(브랜치 전략: feat→develop, main 직접 금지). 머지 시점에 develop 실측 권장.
