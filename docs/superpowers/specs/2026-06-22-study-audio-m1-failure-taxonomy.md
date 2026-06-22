# 학습 문서 오디오 M1 — Failure Taxonomy

작성: 2026-06-22  
범위: 주머니 라디오 M1(T5~T9) 재생·호스팅·검수 게이트 분기  
관련 문서: `2026-06-20-study-audio-lecture-review.md`, `2026-06-21-study-audio-m1-handoff.md`

## 결론

M1의 실패는 한 덩어리로 보지 않는다. 잠금화면 재생 실패, Media Session 컨트롤 실패,
Range/캐시 실패, 오디오 콘텐츠 검수 실패는 원인과 조치가 다르다.

이번 세션에서는 iOS 실기기가 없어 iOS 수동 게이트를 **통과로 판정하지 않는다**. 사용자의
명시 지시로 iOS 검증만 스킵하고, 자동화 가능한 T7 Range 게이트 도구와 T9 메타 산출을 진행한다.
기본 빌드는 계속 `audio_lecture=false`라 공개 UI에는 노출되지 않는다.

## 게이트 판정 원칙

- **M1 재생 엔진 통과:** iOS standalone PWA에서 단일 합친 오디오가 잠금 상태로 계속 재생되고,
  잠금화면 일시정지/재개와 전화·알람 인터럽션 후 재개가 된다. Android도 같은 happy path를 확인한다.
- **현재 세션 판정:** iOS 실기기가 없으므로 `not-run`이다. `passed`도 `failed`도 아니다.
- **출고 안전:** 재생 게이트가 미완이어도 코드가 `audio_lecture` 플래그 뒤에 있으면 develop 병합은 가능하다.
  공개 빌드나 `pubspec.yaml`의 `assets/audio/` 등록은 콘텐츠 검수 전까지 하지 않는다.
- **콘텐츠 검수 분리:** MP3가 재생돼도 `reviewStatus=approved` 전에는 학습 콘텐츠로 홍보하거나 상시 노출하지 않는다.

## 실패 분류

| 증상 | 원인 후보 | 판정 | 조치 |
|---|---|---|---|
| iOS 탭은 실패, standalone PWA는 통과 | Safari 탭 백그라운드 제약 | 진행 가능 | 설치 필요 UX를 M2에서 추가한다. M1 방향은 유지한다. |
| iOS standalone PWA에서 잠금 중 재생이 끊김 | WebKit/PWA 백그라운드 오디오 제약 또는 인코딩/호스팅 문제 | M1 핵심 실패 | Range·인코딩을 먼저 배제한 뒤 Android 우선 또는 네이티브/다른 접근 재검토. |
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
python tool\check_audio_range.py `
  https://velkaressiablutkrone.github.io/aws-docs/assets/audio/clf/clf-t1-1/lecture.mp3 `
  --expect-sha256 <audio_meta.json의 audio.sha256>
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
|  | iPhone / iOS | Safari tab | 단일 파일 잠금 연속재생 | not-run | iOS 기기 필요 |
|  | iPhone / iOS | standalone PWA | 잠금 일시정지/재개 | not-run | iOS 기기 필요 |
|  | iPhone / iOS | standalone PWA | 전화·알람 인터럽션 후 재개 | not-run | iOS 기기 필요 |
|  | Android | Chrome tab | 단일 파일 잠금 연속재생 | not-run |  |
|  | Android | standalone PWA | 잠금 일시정지/재개 | not-run |  |

## 현재 상태

- `flutter_app/tool/gen_lecture_audio.py --meta-only`로 기존 MP3의 `audio_meta.json`을 생성할 수 있다.
- `flutter_app/tool/check_audio_range.py --self-test`는 네트워크 없이 Range 판정 로직을 검증한다.
- 실제 T7은 MP3가 배포된 뒤에만 의미가 있다. 현재 MP3는 검수 전 미커밋·미배포 픽스처다.
