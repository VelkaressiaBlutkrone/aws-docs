# 학습 문서 오디오 M1 — Failure Taxonomy

작성: 2026-06-22  
범위: 주머니 라디오 M1(T5~T9) 재생·호스팅·검수 게이트 분기  
관련 문서: `2026-06-20-study-audio-lecture-review.md`, `2026-06-21-study-audio-m1-handoff.md`

## 결론

M1의 실패는 한 덩어리로 보지 않는다. 잠금화면 재생 실패, Media Session 컨트롤 실패,
Range/캐시 실패, 오디오 콘텐츠 검수 실패는 원인과 조치가 다르다.

이번 세션에서는 iOS 실기기가 없어 iOS 수동 게이트를 **통과로 판정하지 않는다**. 사용자 결정으로
현 M1의 수동 게이트는 Android로 대체한다. iOS 특이 WebKit/PWA 리스크는 `deferred`로 남기고,
자동화 가능한 T7 Range 게이트 도구와 T9 메타 산출을 진행한다. 기본 빌드는 계속
`audio_lecture=false`라 공개 UI에는 노출되지 않는다.

## 게이트 판정 원칙

- **현 M1 재생 엔진 통과(사용자 결정):** Android Chrome 탭에서 단일 합친 오디오가 잠금 상태로
  계속 재생되고, 잠금화면 일시정지/재개와 전화·알람 등 인터럽션 후 재개가 된다.
- **standalone PWA 판정:** 로컬 LAN 프리뷰는 설치 조건을 만족하지 못해 `blocked-local`이다.
  standalone PWA 오디오 게이트는 배포 HTTPS 또는 공인 인증서가 붙은 임시 호스팅에서만 통과/실패를 판정한다.
- **iOS 판정:** iOS 실기기가 없으므로 `not-run/deferred`다. Android 통과가 iOS 통과 기록을 만들지는 않는다.
- **출고 안전:** 재생 게이트가 미완이어도 코드가 `audio_lecture` 플래그 뒤에 있으면 develop 병합은 가능하다.
  공개 빌드나 `pubspec.yaml`의 `assets/audio/` 등록은 콘텐츠 검수 전까지 하지 않는다.
- **콘텐츠 검수 분리:** MP3가 재생돼도 `reviewStatus=approved` 전에는 학습 콘텐츠로 홍보하거나 상시 노출하지 않는다.

## 실패 분류

| 증상 | 원인 후보 | 판정 | 조치 |
|---|---|---|---|
| iOS 탭은 실패, standalone PWA는 통과 | Safari 탭 백그라운드 제약 | 진행 가능 | 설치 필요 UX를 M2에서 추가한다. M1 방향은 유지한다. |
| iOS standalone PWA에서 잠금 중 재생이 끊김 | WebKit/PWA 백그라운드 오디오 제약 또는 인코딩/호스팅 문제 | iOS deferred 리스크 | 현 M1은 Android 대체 게이트로 진행하되, iOS 지원을 다시 목표로 삼는 시점에 재평가한다. |
| Android Chrome 탭 또는 standalone PWA에서 잠금 중 재생이 끊김 | user activation, 브라우저 백그라운드 제약, 인코딩/호스팅 문제 | 현 M1 핵심 실패 | Range·인코딩을 먼저 배제한 뒤 `AudioController`/Media Session 경로를 수정한다. |
| 잠금화면 재생은 되지만 play/pause가 안 됨 | Media Session handler 또는 playbackState 동기화 문제 | 제품 피벗 아님 | `MediaSessionBinder`/`WebMediaSessionBackend`만 수정한다. |
| 앱 버튼 재생이 `NotAllowedError`로 실패 | `play()` 앞에 await가 끼어 user activation 상실 | 코드 결함 | 사용자 제스처 동기 진입에서 `controller.play()`가 바로 호출되도록 되돌린다. |
| 재생 시작이 매우 느림 | Range 미지원 또는 전체 MP3 다운로드 | 배포층 결함 | `tool/check_audio_range.py`로 HEAD/Range/Content-Type/캐시를 확인하고 호스팅을 수정한다. |
| Range GET이 200 전체 본문을 반환 | 서버가 Range를 무시 | 배포층 결함 | `Accept-Ranges: bytes`와 `206 Content-Range`가 되는 호스팅으로 바꾼다. |
| `Content-Type`이 `text/plain`/`application/octet-stream` | MIME 설정 누락 | 배포층 결함 | MP3가 `audio/mpeg`로 서빙되도록 설정한다. |
| `--expect-sha256`가 불일치 | stale 캐시, 다른 파일 배포, 잘못된 URL | 배포/캐시 결함 | 새 배포 완료 대기, URL 확인, 캐시 validator 확인. |
| `audio_meta.json`의 `source.sha256`가 현재 문서와 다름 | 문서 변경 후 오디오 미재생성 | 콘텐츠 stale | 재생은 막지 않되 "이전 문서 기준" 메타로 취급한다. approved 표시 금지. |
| `audio_meta.json`의 `containerChecks.ok=false` | 중간 ID3 등 컨테이너 이상 | 픽스처 품질 결함 | PCM/재인코딩 또는 ID3 strip 보정 후 재생 게이트를 다시 해석한다. |
| 음성 내용이 부정확하거나 어색함 | 자동 정제 한계, 표/URL/정답 보기 처리 미흡 | 콘텐츠 검수 실패 | `reviewStatus=needs_human_review` 유지. 공개 노출 금지. M2 script.json 검수로 넘긴다. |

## T7 Range 게이트 실행

실제 배포 URL이 생긴 뒤 실행한다.

```powershell
cd D:\workspace\awc-docs\flutter_app
$py = "C:\Users\deepe\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
$expectedSha256 = "audio_meta.json의 audio.sha256 값"
& $py tool\check_audio_range.py `
  https://velkaressiablutkrone.github.io/aws-docs/assets/audio/clf/clf-t1-1/lecture.mp3 `
  --expect-sha256 $expectedSha256
```

통과 조건:

- HEAD가 2xx/3xx다.
- `Content-Type`이 `audio/mpeg`다.
- `Accept-Ranges`가 `bytes`다.
- `Range: bytes=0-1` 요청이 `206`과 `Content-Range: bytes 0-1/...`를 돌려준다.
- 캐시 validator(`Cache-Control`, `ETag`, `Last-Modified` 중 하나)가 있다.
- 기대 SHA-256을 넣은 경우 실제 파일 해시가 일치한다.

## 수동 게이트 기록 양식

| 날짜 | 기기/OS | 브라우저/모드 | 시나리오 | 결과 | 메모 |
|---|---|---|---|---|---|
| 2026-06-22 | Android / 상세 미기록 | Chrome tab | 단일 파일 잠금 연속재생 | pass | 사용자 확인: 휴대폰 화면 꺼진 상태에서도 재생 진행 |
| 2026-06-22 | Android / 상세 미기록 | Chrome tab | 잠금 일시정지/재개 | pass-with-concern | 사용자 확인: 재생 위치는 이어짐. 잠금화면 미디어 컨트롤 터치 판정이 불안정해 기기/OS UI 이슈 가능성 기록 |
| 2026-06-22 | Android / 상세 미기록 | Chrome tab | 인터럽션 후 재개 | pass | 사용자 확인: 오디오 재개. 인터럽션 종류는 상세 미기록 |
| 2026-06-22 | Android / 상세 미기록 | standalone PWA | 설치/실행 가능성 | blocked-local | 사용자 확인: 배포 버전은 문제없으나 로컬 LAN 프리뷰는 설치 메뉴가 뜨지 않음. 앱 구조 결함보다 로컬 origin/secure context 한계로 판단 |
|  | Android | standalone PWA | 단일 파일 잠금 연속재생 | blocked-local | 배포 또는 공인 HTTPS 프리뷰 필요 |
|  | Android | standalone PWA | 잠금 일시정지/재개 | not-run | 배포 또는 공인 HTTPS 프리뷰에서 재시도 |
|  | Android | standalone PWA | 전화·알람 인터럽션 후 재개 | not-run | 배포 또는 공인 HTTPS 프리뷰에서 재시도 |
|  | iPhone / iOS | Safari tab | 단일 파일 잠금 연속재생 | deferred | iOS 기기 생기면 별도 확인 |
|  | iPhone / iOS | standalone PWA | 전화·알람 인터럽션 후 재개 | deferred | iOS 기기 생기면 별도 확인 |

## 현재 상태

- `flutter_app/tool/gen_lecture_audio.py --meta-only`로 기존 MP3의 `audio_meta.json`을 생성할 수 있다.
- `flutter_app/tool/check_audio_range.py --self-test`는 네트워크 없이 Range 판정 로직을 검증한다.
- 실제 T7은 MP3가 배포된 뒤에만 의미가 있다. 현재 MP3는 검수 전 미커밋·미배포 픽스처다.
- Android Chrome 탭 M1 대체 게이트는 통과했다. standalone PWA 오디오 게이트는 로컬 LAN 프리뷰가 설치
  조건을 만족하지 못해 막혔고, 배포/공인 HTTPS 프리뷰에서만 의미 있게 재시도한다.
