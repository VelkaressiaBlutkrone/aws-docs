# 오디오 자산 R2 분리 호스팅 — 설계 (2026-09-03)

감사 ROADMAP B-4 "174MB 오디오 자산 전략"의 결정본. 강의 mp3를 GitHub Pages 번들·git에서 분리해 Cloudflare R2 공개 버킷(커스텀 도메인)에서 서빙한다.

## 배경·동기 (실측)

- 2026-09-03 SAA 20문서 승인 릴리스(PR#118) 후 `build/web` **493MB**(오디오 mp3 39개 ≈ 434MB). GitHub Pages 권장 사이트 크기 1GB, 월 전송 100GB 소프트 한도. SOA 오디오(약 20문서)까지 가면 약 700MB.
- git 팩 385MB. 재합성마다 13MB 급 바이너리가 이력에 누적된다.
- 앱에서 mp3 URL을 만드는 지점은 `web_audio_backend.setSrc → webAudioAssetUrl(src)` 하나이며, 플레이어는 `<audio preload="metadata">`만 쓰고 fetch/XHR을 하지 않는다. 메타(`audio_meta.json`)·대본(`script.json`)은 `rootBundle`로 읽는다.
- 사용자 결정(2026-09-03): 호스팅 **Cloudflare R2**, 도메인 **`aws-audio.leva.ai.kr`**(zone `leva.ai.kr` Free·full setup, zone id `22159344c213567f683ccf83c0d22780`), **mp3는 git에서 제거하고 로컬 도구로 발행**.
- 제약: `r2.dev` 개발 URL은 프로덕션 부적합(가변 속도제한·스로틀). 2단계 서브도메인(`aws.audio.leva.ai.kr`)은 Free 플랜 Universal SSL 미커버라 1단계 서브도메인으로 확정.

## 목표 / 비목표

**목표**
1. 사이트 번들에서 mp3를 제거해 Pages 한도와 무관하게 자격증 오디오를 확장할 수 있게 한다.
2. 재생 UX 무변화: 같은 미니플레이어·챕터·Range 시크가 그대로 동작한다.
3. 재합성 시 캐시 무효화가 자동(불변 키)이며, 라이브 노출 게이트(`audioApproved` SSOT)가 유지된다.
4. CI 변경·시크릿 없음. 발행은 사람/AI가 로컬 wrangler로 수행한다.

**비목표**
- git 이력 재작성(385MB 이력은 그대로 둔다).
- 메타·대본 json의 외부 이동(작아서 번들 유지).
- 서비스 워커·오프라인 캐시(별도 과제).
- 인증·서명 URL(공개 강의).

## 아키텍처

```
[repo] audio_meta.json(sha256) ──┐            [R2 bucket aws-docs-audio]
[repo] content_index audioSha8 ──┤ 동기화 테스트   {family}/{taskId}/{sha8}/lecture.mp3
[app]  lectureAudioSrc ──────────┘                        ▲
        = https://aws-audio.leva.ai.kr/{family}/{taskId}/{sha8}/lecture.mp3
                                                          │
[local] tool/publish_audio.py ── wrangler r2 object put ──┘  (immutable, audio/mpeg)
        --verify(-all) ── check_audio_range.py(HEAD·Range 206·캐시 헤더)
```

### 1. URL 규약
- `https://aws-audio.leva.ai.kr/{family}/{taskId}/{sha8}/lecture.mp3`
  - `family` = taskId 접두어(`clf`·`saa`·`soa`), 기존 `lectureAudioSrc` 규약과 동일.
  - `sha8` = `audio_meta.json`의 `audio.sha256` 앞 8자리(소문자 hex).
- 키는 **불변**: 재합성 → sha 변경 → 새 키. 이전 키는 삭제하지 않는다(롤백·구버전 캐시 무해).
- 업로드 헤더: `Content-Type: audio/mpeg`, `Cache-Control: public, max-age=31536000, immutable`.

### 2. 앱 변경 (`flutter_app/lib`)
- `lib/data/audio_asset_url.dart`
  - `const String kAudioBaseUrl = String.fromEnvironment('audio_base_url', defaultValue: 'https://aws-audio.leva.ai.kr');`
  - `webAudioAssetUrl(src)`: `src`가 `http://`/`https://`로 시작하면 그대로 반환, 아니면 기존대로 `assets/$src`.
- `lib/data/content_index.dart`
  - `ContentEntry`에 `final String? audioSha8` 추가(기본 null). `audioApproved: true`인 엔트리(CLF 19 + SAA 20)에 값 기재.
  - `lectureAudioSrc` → `audioSha8 != null ? '$kAudioBaseUrl/$family/$taskId/$audioSha8/lecture.mp3' : 'assets/audio/$family/$taskId/lecture.mp3'`(sha 없는 미승인 엔트리는 기존 placeholder 경로 유지 — 노출 게이트가 막고 있어 실제 로드되지 않음).
  - `lectureAudioMetaSrc` 무변경.
- 플레이리스트·플레이어·study_doc_page 무변경(문자열 src를 그대로 `setSrc`).

### 3. 발행 도구 (`flutter_app/tool/publish_audio.py`)
- 입력: docId 목록 또는 `--all-approved`(content_index에서 approved 엔트리 파싱하지 않고 `audio_meta.json`의 `reviewStatus=approved` 전수 스캔).
- 동작(문서당):
  1. `audio_meta.json` 읽어 `audio.sha256`·`sizeBytes` 확보.
  2. 로컬 `lecture.mp3` 실측 sha256·크기가 메타와 일치하는지 검사(불일치 → 실패, 업로드 안 함).
  3. 키 `{family}/{taskId}/{sha8}/lecture.mp3`가 이미 있으면 건너뜀(`wrangler r2 object get --file NUL` 대신 공개 URL HEAD 200으로 판정).
  4. `npx wrangler r2 object put aws-docs-audio/{key} --file ... --content-type audio/mpeg --cache-control "public, max-age=31536000, immutable" --remote`.
  5. `--verify`: 공개 URL에 `check_audio_range.py` 검사(HEAD 2xx·`audio/mpeg`·`Accept-Ranges`·Range 206·캐시 헤더) + `--expect-sha256`은 선택(전체 다운로드라 기본 off).
- `--verify-all`: approved 전수(현재 39)를 HEAD/Range만 검사해 릴리스 전 게이트로 쓴다. 실패 1건이라도 있으면 exit 1.
- `--self-test`: 키 생성·sha8·URL 조립 순수 함수 단위 테스트(기존 도구 관례).
- 의존: `npx wrangler@latest`(OAuth 로그인 상태), Python 표준 라이브러리만.

### 4. 인프라 (1회, wrangler CLI)
- 버킷 `aws-docs-audio` 생성(`wrangler r2 bucket create aws-docs-audio`).
- 커스텀 도메인 `aws-audio.leva.ai.kr` 연결(`wrangler r2 bucket domain add aws-docs-audio --domain aws-audio.leva.ai.kr --zone-id 22159344c213567f683ccf83c0d22780 --min-tls 1.2`). DNS는 Cloudflare가 자동 생성.
- r2.dev 개발 URL은 비활성 유지.
- CORS(`wrangler r2 bucket cors set aws-docs-audio --file tool/r2_cors.json`): `AllowedOrigins`=[`https://velkaressiablutkrone.github.io`, `http://localhost:8124`], `AllowedMethods`=[`GET`,`HEAD`], `AllowedHeaders`=[`Range`], `ExposeHeaders`=[`Content-Length`,`Content-Range`,`Accept-Ranges`,`ETag`], `MaxAgeSeconds`=86400. (재생 자체엔 CORS 불요 — 향후 fetch 기반 기능 대비.)
- **선행(사람 전용):** 현 wrangler OAuth 토큰에 R2 스코프 없음 → 사용자가 `npx wrangler@latest login --scopes account:read user:read zone:read r2:write workers:write` 실행(브라우저 동의).

### 5. 저장소·번들 정리
- `pubspec.yaml`: `lecture.mp3` 39항목 제거(script.json·audio_meta.json·review_checklist.md는 유지).
- `git rm --cached flutter_app/assets/audio/*/*/lecture.mp3` + `.gitignore`에 `flutter_app/assets/audio/*/*/lecture.mp3` 추가. 로컬 파일은 발행 원본·백업으로 남긴다(정본은 R2 + 메타 sha).
- 예상 번들: 493MB → 약 60MB.

### 6. 게이트·테스트
- `test/content_index_test.dart` 동기화 테스트 재정의: `audioApproved == (meta.reviewStatus == approved && meta.script.reviewStatus == approved && audioSha8 == meta.audio.sha256[:8])`. 로컬 mp3 존재 검사는 제거(`mp3.existsSync()` 삭제).
- `lectureAudioSrc` 규약 테스트: approved 엔트리는 `https://aws-audio.leva.ai.kr/clf/clf-t1-1/<sha8>/lecture.mp3` 형식, 미승인 엔트리는 기존 `assets/...`.
- `audio_asset_url_test`: http(s) 통과·상대 키 접두어 유지.
- `publish_audio.py --self-test` 그린.
- 릴리스 전: `publish_audio.py --verify-all` 39/39 PASS, `flutter build web`에 `assets/assets/audio/*/lecture.mp3` 부재 확인, 로컬 dogfood(base-href 루트 재빌드 + node 서버)에서 CLF·SAA 1문서씩 재생·시크 확인.

### 7. 오류 처리·롤백
- R2 응답 실패·404: 기존 플레이어 Error 상태(재시도·홈) 그대로. 별도 폴백 URL 없음(YAGNI).
- 롤백: PR revert 1회(mp3는 로컬·git 이력에 잔존, pubspec 복원 시 즉시 번들 복귀). 긴급 시 `--dart-define=audio_base_url=`로 다른 오리진 지정 가능.
- 발행 누락 방지: 동기화 테스트가 `audioSha8`을 강제하고, `--verify-all` 게이트가 실제 URL을 실측한다. `synthesize`가 reviewStatus를 리셋하므로 재합성 문서는 [재합성 → 승인 → audioSha8 갱신 → publish → verify] 순서를 핸드오프에 기록한다.

## 실행 순서
1. 사용자: wrangler 재로그인(R2 스코프).
2. 인프라: 버킷·도메인·CORS 생성, DNS Active 확인, 테스트 객체 1개로 Range 206 실측 후 삭제.
3. 도구: `publish_audio.py`(self-test) → 39개 업로드 → `--verify-all` 39/39.
4. 앱: 실패 테스트 선작성 → `audioSha8`·URL·pubspec·gitignore 구현 → 794+ 테스트·analyze 0 → 웹 빌드 부재 확인 → 로컬 dogfood.
5. 문서: 오디오 핸드오프·CLAUDE.md 빌드 절에 발행 절차 추가, WORKLIST·ROADMAP B-4 완료 기록.
6. PR → develop → main 릴리스 → 라이브 `check_audio_range.py` 재실측.
