# 학습 문서 오디오 강의("주머니 라디오") M1 — 세션 핸드오프

작성: 2026-06-21
브랜치: `feat/study-audio-m1` (develop에서 분기)

## 한 줄 요약
M1 재생 엔진(AudioController 상태머신 + Media Session 바인딩 + WebAudioBackend DOM 어댑터)을
TDD로 완성·커밋했다. **다음 시작점 = T4(미니 플레이어 진입점 연결).**

## 브랜치 / 커밋
- `662dfd6` — T5: AudioController 상태 머신 + 단위테스트
- `ba7cbd5` — T2: Media Session 바인딩 + AudioController ChangeNotifier
- `6a25975` — T1: WebAudioBackend + WebMediaSessionBackend (DOM 어댑터)
- 검증: **21 단위 테스트 + 712 전체 그린, analyze 신규 0, `build web` 성공(회귀 0)**

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

## 다음 시작점: T4 (미니 플레이어 진입점)
1. **합친 오디오 샘플 1개 준비** — 한국어 TTS, 프로덕션 형태(현실 길이/비트레이트/경로/캐시).
   대본 생성(M2 파이프라인)은 아직이라 임시 샘플 1개면 됨. **공개 재배포 허용 엔진**으로(정적 사이트=배포).
2. `flutter_app/lib/pages/study_doc_page.dart`에 미니 플레이어 진입점 + `WebAudioBackend`/
   `WebMediaSessionBackend` 실연결 + `MediaSessionBinder` 배선.
   - **전역 싱글톤**으로(위젯 트리 밖, 라우팅 전환에도 재생 유지).
   - 미니 플레이어 = DESIGN.md **신규 컴포넌트**(토큰·InkWell+FocusRing·State Views·합니다체).
   - **여기서 web_audio_backend가 실제 빌드에 포함 → `build web`으로 웹 컴파일 검증**
     (현재는 미연결이라 회귀만 확인됨).
3. 이어서: **T6**(실기기 수동 게이트), **T7**(Range 실배포 게이트), **T8**(failure taxonomy), **T9**(hash 메타).

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
- **T4까지 묶어 `feat/study-audio-m1` → `develop` PR 권장**(지금은 재생 진입점이 없어 사용자가 들을 수
  없는 상태). origin에 푸시됨.
