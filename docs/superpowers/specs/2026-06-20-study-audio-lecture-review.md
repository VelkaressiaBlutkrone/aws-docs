# 학습 문서 오디오 강의 설계 수정/보강 정리

작성일: 2026-06-20  
대상 초안: `~/.gstack/projects/VelkaressiaBlutkrone-aws-docs/deepe-develop-design-20260620-164123.md`  
관련 원칙: `DESIGN.md` "조용한 레퍼런스", 정직함의 시각화, 합니다체, FocusRing, State Views

## 결론

원 초안의 큰 방향은 유지한다. **수직 슬라이스(Approach C)로 3개 문서만 끝까지 만들고, UI나 생성 파이프라인에 투자하기 전에 iOS/Android 잠금화면 재생 Spike를 먼저 통과**시키는 전략이 맞다.

다만 구현 전에 아래 전제 보정이 필요하다.

1. repo 실제 경로는 `web/...`가 아니라 `flutter_app/web/...`이다.
2. `sectionId = H2 anchor` 전제는 현재 콘텐츠와 맞지 않는다. H2 442개 중 앵커가 있는 항목은 20개뿐이다.
3. `assets/audio/`는 아직 `pubspec.yaml`에 등록돼 있지 않다.
4. `sourceBlockRange`의 인덱스 규약과 `MdDetails` 처리 규칙이 명시돼야 한다.
5. 미니 플레이어는 아직 `DESIGN.md`에 없는 신규 컴포넌트이므로 구현 시 디자인 결정 로그를 보강해야 한다.

## 확인된 사실

### 맞는 전제

- 콘텐츠 모델은 `flutter_app/lib/models/study_content.dart`의 sealed `MdBlock` 10타입이다.
- 파서는 `flutter_app/lib/content/markdown_parser.dart`의 `parseStudyDoc`이다.
- 렌더러는 `flutter_app/lib/content/study_markdown_view.dart`이다.
- 문서 페이지 진입점은 `flutter_app/lib/pages/study_doc_page.dart`이다.
- `package:web` 의존성은 이미 `flutter_app/pubspec.yaml`에 있다.
- PWA 기반은 존재한다.
  - `flutter_app/web/index.html`에 `apple-mobile-web-app-capable`이 있다.
  - `flutter_app/web/manifest.json`에 `display: "standalone"`, `start_url: "."`가 있다.
- GitHub Pages workflow는 `.github/workflows/pages.yml`이며 `flutter_app` 기준으로 `flutter build web --release --base-href /aws-docs/`를 실행한다.
- 기존 node tool 선례는 `flutter_app/tool/saa_prescreen.mjs`, `flutter_app/tool/saa_review.mjs`이다.

### 보정해야 하는 전제

- 초안의 `web/index.html`, `web/manifest.json` 경로는 실제 repo에서 존재하지 않는다. 올바른 경로는 `flutter_app/web/index.html`, `flutter_app/web/manifest.json`이다.
- 현재 오디오/Media Session 구현은 없다.
- 현재 `flutter_app/pubspec.yaml`의 assets 목록에는 `assets/audio/`가 없다.
- H2 앵커는 대부분 없다.
  - 학습 문서: 63개
  - H2 총계: 442개
  - 앵커 있는 H2: 20개
  - 앵커 없는 H2: 422개

## 원 초안에 반영할 수정 사항

### 1. 경로 표기 수정

원 초안의 경로 표기는 다음처럼 바꾼다.

| 초안 표기 | 실제 경로 |
|---|---|
| `web/index.html` | `flutter_app/web/index.html` |
| `web/manifest.json` | `flutter_app/web/manifest.json` |
| `tool/*.mjs` | `flutter_app/tool/*.mjs` |
| `assets/audio/{cert}/{taskId}/` | `flutter_app/assets/audio/{cert}/{taskId}/` |
| `pubspec.yaml` | `flutter_app/pubspec.yaml` |

배포 URL은 빌드 후 base-href 아래에 놓인다. 1차 Spike에서 최종 오디오 URL이 `https://velkaressiablutkrone.github.io/aws-docs/assets/audio/...` 형태로 resolve되는지 확인한다.

### 2. 섹션 앵커를 선행 작업으로 추가

원 초안은 `sectionId`를 "H2 anchor, 순번 폴백 금지"로 잡았다. 이 원칙은 좋지만 현재 콘텐츠 상태에서는 바로 적용하기 어렵다.

수정 권장:

- 오디오 작업 전 선행 조건으로 **오디오 대상 문서의 모든 H2에 안정 앵커를 추가**한다.
- 순번 기반 sectionId는 쓰지 않는다.
- 자동 생성 slug도 초안 생성 시점의 임시값으로만 쓰고, 커밋되는 Markdown에는 `{#...}` 앵커를 명시한다.
- 기존 `docs/superpowers/specs/2026-06-20-section-anchors-design.md`와 충돌하지 않게 같은 앵커 규칙을 재사용한다.

1차 대상 문서가 3개라면 전체 442개를 한 번에 처리하지 말고, 대상 3개 문서의 H2 앵커만 먼저 보강해도 된다.

### 3. Script Schema 보강

원 초안의 스키마는 유지하되 `sourceBlockRange` 규약을 명시한다.

권장 규약:

```json
{
  "sourceBlockRange": [12, 18]
}
```

- 0-based top-level `MdBlock` index를 사용한다.
- end는 exclusive이다. 즉 `[12, 18]`은 12, 13, 14, 15, 16, 17번 블록을 뜻한다.
- range는 원본 `.md`를 `parseStudyDoc`으로 파싱한 뒤의 `StudyContent.blocks` 기준이다.
- `MdDetails`는 1차에서 top-level block 하나로 취급한다.
- `MdDetails.body` 내부까지 정밀 추적하는 `nestedSourceRange`는 1차 범위에서 제외한다.
- 생성 스크립트는 manifest에 `parserVersion` 또는 `schemaVersion`을 같이 기록한다. 파서가 바뀌면 stale 판정이 가능해야 한다.

보강 스키마:

```json
{
  "schemaVersion": 1,
  "docId": "saa-t1-1",
  "sourceHash": "<원문 .md 바이트 sha256>",
  "parserVersion": "study-md-v1",
  "generatedAt": "<ISO8601>",
  "tracks": [
    {
      "trackId": "saa-t1-1__core-concepts__001",
      "sectionId": "core-concepts",
      "sourceBlockRange": [12, 18],
      "scriptText": "강사 대본 평문",
      "ssml": null,
      "audio": {
        "src": "assets/audio/saa/saa-t1-1/core-concepts-001.mp3",
        "durationMs": null,
        "contentType": "audio/mpeg"
      },
      "skip": false,
      "skipReason": null
    }
  ]
}
```

### 4. stale 판정 경로 명확화

원 초안의 `sourceHash` 방향은 맞다. 다만 런타임에서 앱이 원본 `.md` 바이트를 직접 해시하려면 asset 로드가 필요하므로 구현 경로를 명시한다.

권장:

- 생성 스크립트가 `.md` 바이트 sha256을 계산한다.
- 앱에도 같은 `.md` asset이 이미 포함돼 있으므로, 런타임은 `rootBundle.loadString(entry.mdAsset)`로 원문을 읽고 sha256을 계산해 manifest와 비교한다.
- sha256 라이브러리 추가가 부담이면, 초기 1차는 build-time 생성된 `audio_manifest.json`의 `sourceHash`와 별도 `content_hashes.json`을 비교해도 된다.
- 불일치 시 재생은 막지 않고 "이 오디오는 이전 문서 기준입니다" 메타를 표시한다. 검증정책 B에서는 stale 오디오를 `검수됨`으로 표시하지 않는다.

### 5. 환각 가드 범위 조정

원 초안의 "고유명사, AWS 서비스명, 수치 토큰" 보존 검사는 1차 가드로 적절하다. 다만 누락과 추가의 severity를 나눠야 한다.

권장:

- 원문에 없는 AWS 서비스명 또는 숫자가 scriptText에 새로 나오면 `fatal`.
- 원문에 있던 AWS 서비스명 또는 숫자가 scriptText에서 빠지면 `warning`.
- 일반 고유명사 누락은 `warning`부터 시작한다.
- `warning`은 사람 검토 큐에 넣고, `fatal`은 오디오 생성 전 중단한다.
- 품질 검토와 사실성 검토를 분리한다. 사람이 "듣기 좋다"고 판단해도 factual guard를 통과하지 못하면 발행하지 않는다.

### 6. 오디오 asset 등록 추가

1차에서 repo 직접 커밋을 선택하면 `flutter_app/pubspec.yaml`에 asset 경로를 추가해야 한다.

권장:

```yaml
flutter:
  assets:
    - assets/audio/
```

manifest 파일 위치도 같이 정한다.

권장 위치:

- `flutter_app/assets/audio/audio_manifest.json`
- `flutter_app/assets/audio/{cert}/{taskId}/{trackId}.mp3`
- `flutter_app/assets/audio/{cert}/{taskId}/script.json`

### 7. Media Session Spike 범위 고정

Spike는 UI 구현보다 먼저 한다. 통과 기준은 play/pause가 아니라 **상태 왕복이 포함된 트랙 전환**이다.

필수 확인:

- iOS Safari 탭 실행: 단일 트랙 지속 재생
- iOS Safari 탭 실행: 트랙 자동 전환
- iOS standalone PWA 실행: 단일 트랙 지속 재생
- iOS standalone PWA 실행: 트랙 자동 전환
- Android Chrome 탭 실행: 단일 트랙 지속 재생
- Android Chrome 탭 실행: 트랙 자동 전환
- Android standalone PWA 실행: 단일 트랙 지속 재생
- Android standalone PWA 실행: 트랙 자동 전환
- 잠금화면 next action: Media Session action handler -> JS bridge -> Flutter playlist state -> 다음 track src 주입

게이트 판정:

- iOS standalone에서 단일 트랙과 자동 전환이 모두 되면 1차 진행 가능.
- iOS 탭에서만 실패하면 "설치 필요" UX를 명시하고 진행 가능.
- iOS standalone에서도 실패하면 Android 우선 또는 Approach 재선정.

### 8. 미니 플레이어 디자인 보강

미니 플레이어는 `DESIGN.md`에 아직 사양이 없다. 구현 시 Decisions Log에 추가한다.

초기 사양:

- 문서 페이지 하단 고정 미니 플레이어.
- 색은 `context.c` 토큰만 사용한다.
- 주요 액션은 아이콘 버튼을 우선한다.
- 모든 인터랙티브는 `InkWell` + `FocusRing` 또는 `FocusTap`을 사용한다.
- 로딩/빈/에러는 `state_views.dart`의 보이스와 패턴을 따른다.
- 카피는 합니다체를 유지한다.
- stale 메타는 조용한 텍스트로 표시한다. wrong 색은 fatal error에만 쓴다.
- 검증 메타와 오디오 메타를 섞지 않는다. "문서 검증됨"과 "오디오 검수됨"은 별도 상태다.

권장 상태 카피:

- 로딩: `오디오를 준비하고 있습니다…`
- 오디오 없음: `이 섹션은 오디오가 없습니다. 표나 코드는 화면에서 확인해야 합니다.`
- stale: `이 오디오는 이전 문서 기준입니다.`
- 에러: `오디오를 재생하지 못했습니다.`

## 수정된 실행 순서

원 초안의 Next Steps는 아래 순서로 보강한다.

1. **대상 3개 문서 선정**
   - 가능하면 SAA 문서 3개로 시작한다.
   - 선정한 문서의 H2 앵커 현황을 먼저 확인한다.

2. **대상 문서 H2 앵커 보강**
   - 오디오 대상 문서의 모든 H2에 `{#...}` 앵커를 추가한다.
   - sectionId 순번 폴백은 금지한다.

3. **Media Session Spike**
   - 샘플 오디오 2개를 사용한다.
   - 전역 `<audio>` 싱글톤과 Media Session next action까지 검증한다.
   - UI는 최소 버튼만 둔다.

4. **Script Schema 테스트**
   - `schemaVersion`, `sourceHash`, `parserVersion`, `trackId`, `sourceBlockRange`를 검증하는 node 테스트를 먼저 작성한다.
   - range는 0-based, end-exclusive로 고정한다.

5. **대본 생성 스크립트**
   - `flutter_app/tool/audio_script.mjs` 계열로 작성한다.
   - 원문 `.md` -> `parseStudyDoc`과 동등한 block segmentation -> script JSON을 생성한다.
   - 환각 가드 fatal 0건일 때만 TTS 단계로 넘긴다.

6. **TTS 생성**
   - 공개 재배포 허용 여부를 먼저 확인한다.
   - 1개 엔진만 선택한다.
   - 오디오와 script JSON을 repo asset으로 커밋한다.

7. **미니 플레이어 UI**
   - `study_doc_page`에 진입점을 추가한다.
   - 하단 미니 플레이어는 신규 컴포넌트로 분리한다.
   - `DESIGN.md` Decisions Log에 미니 플레이어 규칙을 추가한다.

8. **3개 문서 수직 슬라이스 완료**
   - 한 문서 내 섹션 연속 재생까지만 1차 목표로 한다.
   - 문서 간 자동 재생은 확장 단계로 미룬다.

## 1차 완료 기준

- 대상 문서 H2 앵커 100%.
- `sourceBlockRange` 테스트 통과.
- 환각 가드 fatal 0건.
- iOS standalone PWA에서 잠금화면 단일 재생과 트랙 전환이 가능함.
- Android에서도 같은 시나리오가 가능함.
- stale 오디오 메타가 표시됨.
- 미니 플레이어가 DESIGN.md 토큰, FocusRing, State Views, 합니다체를 지킴.
- `flutter test`와 `flutter analyze`에서 신규 이슈 없음.
- `flutter build web --release --base-href /aws-docs/` 성공.

## 원 초안에 남겨도 되는 판단

- Approach C 선택.
- Web Speech 런타임을 1차 핵심 경로에서 제외.
- LFS 회피.
- repo 직접 커밋으로 3문서 오디오 asset을 먼저 검증.
- 검증정책 A -> 사용 후 B 승급.
- UI보다 잠금화면 재생 Spike를 먼저 하는 순서.

## 주의할 점

- "문서 검증됨"은 원문 학습 문서의 검증 상태다. LLM으로 만든 오디오 대본에는 별도 검수 상태가 필요하다.
- "무검수 충실 변환"도 공개 노출 전에는 환각 가드를 통과해야 한다.
- iOS 백그라운드 오디오는 문서나 설정값만으로 확정할 수 없다. 실제 기기에서만 판정한다.
- `just_audio` 도입 여부는 Spike 결과로 결정한다. 1차 디폴트는 `package:web` 직접 interop이다.
- Flutter Web CanvasKit에서는 DOM `<audio>`를 위젯 생명주기에 묶지 않는다. 라우팅 전환에도 유지되는 전역 싱글톤으로 둔다.

---

## M1 Plan-Eng-Review 결정 (2026-06-20, /plan-eng-review)

대상: 위 설계의 M1(Spike 게이트). 리뷰가 구현을 M1/M2 2단계 출고로 분리하고 M1을 잠갔다.

### 스코프 결정
- **M1/M2 분리 출고:** M1 = 잠금화면 재생 가능성 검증(가장 위험한 가정만). M2 = 대본 생성·Script Schema 파서·환각가드·미니플레이어 풀 UI·stale 런타임 비교·H2 앵커. **M1 통과 못 하면 전체 방향 재검토** — M2에 투자하기 전 게이트.
- **이슈 1 — 1A 문서당 1개 합친 오디오:** 섹션별 트랙 분리 금지. [검색 근거] iOS는 잠금 중 `ended`→다음 트랙 자동전환이 막힌다([Apple #706499](https://developer.apple.com/forums/thread/706499)). 문서당 1파일은 전환 자체를 없애 회피. best practice = 단일 element + `src` 교체([MDN](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Autoplay)).
- **이슈 2 — 2A 단위테스트 + 수동 체크리스트:** AudioController 상태로직(play/pause/src교체)을 DOM에서 분리해 단위테스트(async 이벤트 mock 포함). iOS 잠금/인터럽션/설치는 실기기 수동(learning `flutter-web-pagetransitions-6keys`: Windows 개발+CI는 iOS 동작 미발견).
- **이슈 3 — 3C 주머니 핵심 게이트:** M1 게이트 = standalone 잠금 연속재생 + 일시정지/재개 + 전화·알람 인터럽션 후 재개. 헤드셋·블루투스·Control Center는 M2. **WebKit #261858 교정:** 이 버그는 "트랙 `ended` 시" 컨트롤 멈춤(30초 일시정지가 아님). 1A는 `ended`가 없어 무관 — 게이트에서 제거.
- **이슈 4 — 4A hash 메타만 M1:** 오디오 옆에 `{docId, sourceHash}` 최소 메타 기록(생성 스크립트가 어차피 만듦). 런타임 stale 비교·UI는 M2. M1 앱 코드는 이 hash를 안 읽어도 됨.
- **이슈 5 — 5A codex 빈틈 9개 전부 반영** (아래).

### codex 외부검증 반영 (이슈 5, 9개)
1. **User activation (P1 최대 함정):** `audio.play()`를 사용자 제스처에 *직접* 묶는다. asset/metadata/`src` 교체를 await한 뒤 play()하면 iOS에서만 실패. onPressed 진입 즉시 play() 또는 동기 경로 보장.
2. **단위 mock async 이벤트:** `play()` rejection·`loadedmetadata`·`canplay`·`stalled`·`waiting`·`error`·`ended`를 mock이 모델링.
3. **최소 UI 상태:** load/error/현재 문서 식별 표시(테스터가 미로드/차단/네트워크/Media Session 깨짐을 구분).
4. **프로덕션형 픽스처:** 한국어 TTS, 현실 길이, 같은 비트레이트/경로/호스팅/캐시. 90초 픽스처 금지.
5. **Range 실배포 게이트:** 배포된 MP3 URL에 HEAD/`Range: bytes=0-1` + `Accept-Ranges`·`Content-Type: audio/mpeg`·캐시 헤더 + 새 배포 후 stale 캐시 HTML이 옛 오디오 가리키는 동작.
6. **Media Session cleanup 확장:** 실제 오디오 이벤트에 `playbackState` 업데이트, stop/src clear 시 metadata clearing, unsupported handler `try/catch`.
7. **failure taxonomy:** 게이트 폴백을 분기별 actionable로 — Safari탭 pass+standalone fail=설치 필요 UX, lock control fail+재생 pass=Media Session만 수정, Range fail=호스팅 수정(제품 피벗 아님).
8. **싱글톤 reset 모델:** 문서 변경·failed load·hard navigation·앱 버전 업데이트 시 무엇이 리셋되는지 command/event 모델 명시(글로벌 상태 누수 방지).
9. **M1 노출 정책:** M1 오디오는 공개 UI 진입점 미연결(dev 플래그/숨김). 환각가드·검수 전 생성 강의를 진짜 학습 콘텐츠로 노출 금지.

### NOT in scope (M1 명시 제외 → M2)
- 대본 생성 파이프라인, Script Schema 파서, 환각 가드 — M2.
- 미니 플레이어 풀 UI, stale 런타임 비교·메타 표시 — M2(M1은 hash 기록만).
- H2 앵커 보강, 섹션 챕터/타임스탬프 내비 — M2.
- 헤드셋·블루투스·Control Center·route 변경 게이트 — M2.
- CI 자동 오디오 생성 — 확장 단계(M1은 로컬 생성·커밋).

### What already exists (재사용 — 평행 구축 회피)
- `study_doc_page` 앵커 스크롤 인프라(concept-deeplink로 구축) — M2 챕터 내비에서 재사용.
- MdBlock 파싱(`study_content`/`markdown_parser`), `tool/*.mjs` 패턴, `package:web ^1.1.0`(pubspec 기존).
- PWA 기반: `flutter_app/web/index.html` apple-mobile-web-app-capable + `manifest.json` display:standalone.
- State Views 3종, FocusRing, 합니다체 — M2 미니플레이어.

### Failure modes (M1 신규 코드패스)
| 코드패스 | 실패 방식 | 테스트 | 에러 처리 | 사용자 가시성 |
|---|---|---|---|---|
| audio.play() user activation | iOS 제스처 분리로 무음 | 수동 기기(자동 불가) | onPressed 동기 play | "재생 차단" 상태 |
| src 교체 중 play | Safari reject/stall, UI playing인데 무음 | 단위 mock(rejection) | play promise catch + 상태 롤백 | error 상태 |
| Media Session handler | 잠금 컨트롤 무반응 | 수동 기기 | try/catch + playbackState | (잠금화면) |
| Range 미지원/캐시 stale | 전체 다운 또는 옛 오디오 | 실배포 게이트 | preload=metadata + hash 메타 | 로딩 지연 |
| 싱글톤 stale on 문서변경 | 옛 오디오/메타 잔존 | 단위(reset) | reset 명령 | 문서 식별 표시 |

→ critical gap 0 (전부 테스트+에러처리 또는 수동 게이트로 커버).

### Implementation Tasks (M1)
- [ ] **T1 (P1)** — AudioController 싱글톤: 전역 top-level, DOM `<audio>` idempotent 생성(getElementById 가드), **play()를 제스처에 직접 묶기**, reset 모델. Verify: 단위테스트 + 핫리스타트 중복 없음.
- [ ] **T2 (P1)** — Media Session: metadata + play/pause handler + cleanup(playbackState·metadata clear·try/catch). Verify: 단위 + 수동 잠금화면.
- [ ] **T3 (P1)** — 단위테스트: 상태로직 + async 이벤트 mock(play거부·stalled·ended·src교체). Verify: `flutter test`.
- [ ] **T4 (P2)** — 최소 UI: play/pause + load/error/문서식별. Verify: 위젯테스트(SelectionArea 함정 회피 — 해석 로직은 단위 분리).
- [ ] **T5 (P1)** — 수동 iOS 체크리스트: standalone 설치 전/후 × 잠금 연속재생·일시정지/재개·전화/알람 인터럽션 후 재개 + Android. 기기·iOS버전 표.
- [ ] **T6 (P2)** — 프로덕션형 한국어 TTS MP3 픽스처 1개 + `{docId,sourceHash}` 메타.
- [ ] **T7 (P2)** — Range 실배포 게이트(HEAD/Range·Accept-Ranges·Content-Type·캐시·stale 캐시).
- [ ] **T8 (P3)** — failure taxonomy 문서(게이트 분기별 결정).

### 병렬화
T1(audio 싱글톤)·T2(Media Session)·T4(UI)·T6(픽스처/스크립트)는 초기 의존이 적어 병렬 가능하나, **M1은 표면이 작고 T1↔T2↔T3가 같은 `AudioController`를 공유**해 사실상 순차가 안전. T5(수동 기기)·T7(Range 게이트)는 코드 무관하게 병렬. 결론: 대부분 순차(공유 모듈), 수동 검증만 병렬.

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 0 | — | — |
| Codex Review | `/codex review` | Independent 2nd opinion | 1 | issues_found | 18 findings, 전부 M1 plan에 반영 |
| Eng Review | `/plan-eng-review` | Architecture & tests (required) | 1 | CLEAR (PLAN) | 5 issues, 0 critical gaps |
| Design Review | `/plan-design-review` | UI/UX gaps | 0 | — | — |
| DX Review | `/plan-devex-review` | Developer experience gaps | 0 | — | — |

- **CODEX:** 18 findings(WebKit 버그 정확화·user activation·src-swap·Range·픽스처·Media Session cleanup·failure taxonomy·싱글톤 reset·stale) — 전부 M1 plan에 반영(1A/3C/4A/5A).
- **CROSS-MODEL:** Claude 리뷰와 codex가 핵심(iOS 자동전환 함정·수동 기기 게이트·1A 단일파일)에서 합의. codex가 Claude의 WebKit #261858 인용 오류를 교정(ended 버그이지 30초 버그 아님).
- **UNRESOLVED:** 0
- **VERDICT:** ENG CLEARED (M1) — M1 구현 착수 가능. M2는 구현 전 별도 `/plan-eng-review` 권장.
