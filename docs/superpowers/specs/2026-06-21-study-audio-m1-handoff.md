# 학습 문서 오디오 강의("주머니 라디오") M1 — 세션 핸드오프

작성: 2026-06-21
브랜치: `feat/study-audio-m1` (develop에서 분기)

## 한 줄 요약
M1 재생 엔진(AudioController 상태머신 + Media Session 바인딩 + WebAudioBackend DOM 어댑터)에
**T4 미니 플레이어 진입점**까지 TDD로 완성·커밋했다. **다음 시작점 = T6(iOS 실기기 수동 게이트 — Windows/CI 불가, 사용자만).**

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

## 다음 시작점: T6 (iOS 실기기 수동 게이트) — Windows/CI 불가, 사용자만
1. **합친 오디오 샘플(placeholder→실물) 준비** — 한국어 TTS, 프로덕션 형태(현실 길이/비트레이트/경로/캐시).
   **공개 재배포 허용 엔진**으로(정적 사이트=배포). `assets/audio/{family}/{taskId}/lecture.mp3`에 두고
   `pubspec.yaml`에 `assets/audio/` 등록(T4는 placeholder 경로만 배선, 실파일·등록 미완).
2. `--dart-define=audio_lecture=true`로 빌드·배포 후 **iOS 실기기 수동 게이트**:
   standalone 잠금 연속재생 + 일시정지/재개 + 전화·알람 인터럽션 후 재개 + Android. 기기·iOS버전 표.
3. 이어서: **T7**(Range 실배포 게이트), **T8**(failure taxonomy 문서), **T9**({docId,sourceHash} 메타).

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
