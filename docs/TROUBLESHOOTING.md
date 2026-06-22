# AWS Docs Roadmap 트러블슈팅

작성: 2026-06-22  
범위: `D:\workspace\awc-docs` 레포 전체 작업 중 반복해서 부딪힌 개발, 빌드, 배포, 모바일 확인 이슈

## 빠른 진단 순서

1. 현재 브랜치와 추적 상태를 먼저 확인한다.

   ```powershell
   git branch --show-current
   git status --short --branch --untracked-files=all
   ```

2. Flutter 앱 작업은 항상 `flutter_app/`에서 실행한다.

   ```powershell
   cd D:\workspace\awc-docs\flutter_app
   flutter analyze
   flutter test
   ```

3. GitHub Pages용 빌드는 PowerShell에서 실행한다.

   ```powershell
   cd D:\workspace\awc-docs\flutter_app
   flutter build web --release --base-href /aws-docs/
   ```

4. 로컬 모바일 프리뷰는 Pages 배포 조건과 다르다. PWA 설치성은 최종적으로 배포 HTTPS URL에서 확인한다.

## Git과 작업 문서

### HEAD 또는 브랜치가 예상과 다름

증상:

- 작업 중 브랜치가 바뀌어 있거나, 커밋 직전 의도와 다른 브랜치에 있다.
- 공유 워킹트리에서 다른 작업의 흔적이 보인다.

조치:

```powershell
git branch --show-current
git status --short --branch --untracked-files=all
git log --oneline -5
```

- 커밋 직전에는 반드시 현재 브랜치를 다시 확인한다.
- 관련 없는 untracked 파일은 함께 staging하지 않는다.
- 이 레포의 일반 흐름은 `feat/*`에서 작업하고 `develop`으로 PR, `main` 배포다. `main` 직접 작업은 피한다.

### Git 경고: `.config/git/ignore` 접근 거부

증상:

```text
warning: unable to access 'C:\Users\deepe/.config/git/ignore': Permission denied
```

판정:

- 레포 내부 변경이나 커밋 실패 원인이 아니라 사용자 홈 전역 Git ignore 접근 경고다.
- `git status`, `git diff`, `git add`, `git commit` 자체가 정상 동작하면 작업은 계속해도 된다.

조치:

- 필요하면 사용자 홈의 `C:\Users\deepe\.config\git\ignore` 권한을 별도로 정리한다.
- 레포 작업 중에는 경고를 이유로 추적 파일을 되돌리지 않는다.

### 커밋하면 안 되는 로컬 파일

현재 오디오 M1 작업 기준으로 아래 파일은 검수 전 로컬 픽스처 또는 개인 설정이다.

```text
.claude/settings.local.json
flutter_app/assets/audio/clf/clf-t1-1/audio_meta.json
flutter_app/assets/audio/clf/clf-t1-1/lecture.mp3
```

원칙:

- `lecture.mp3`와 `audio_meta.json`은 `reviewStatus=approved` 전까지 커밋하지 않는다.
- `pubspec.yaml`에 `assets/audio/`를 등록하지 않는다.
- 문서, 도구, 테스트만 선택 staging한다.

## Flutter 분석과 테스트

### `flutter analyze`가 기존 이슈로 실패

최근 확인된 기존 이슈:

```text
flutter_app/lib/pages/plan/plan_agenda.dart:226:15
  deprecated member: cacheExtent

flutter_app/test/cloud/sync_controller_test.dart:4:8
  fake_async dependency warning

flutter_app/test/cloud/sync_controller_test.dart:51:11
  unused optional parameter: onAppResume
```

판정:

- 오디오 M1 작업에서 새로 만든 analyze 회귀는 없었다.
- 위 3건은 별도 정리 대상이다. 문서만 수정한 커밋에서는 Flutter 분석을 다시 막는 원인으로 보지 않는다.

조치:

- 기능 변경 커밋에서는 신규 analyze 경고가 생겼는지 diff 범위와 함께 본다.
- 문서 전용 커밋은 `git diff --check`로 공백 오류를 우선 확인한다.

### PowerShell 프로필 경고

증상:

```text
Set-PSReadLineOption: ... The handle is invalid.
```

판정:

- 명령 실행 후 PowerShell 프로필에서 출력되는 환경 잡음이다.
- Flutter, Git 명령의 exit code와 본문 결과가 더 중요하다.

조치:

- 실제 명령이 성공했으면 무시해도 된다.
- 반복 출력이 거슬리면 PowerShell 프로필에서 PSReadLine 설정을 조건부로 감싼다.

## 빌드와 배포

### Git Bash에서 `--base-href /aws-docs/`가 깨짐

증상:

- Git Bash 또는 MSYS 계열 셸에서 `/aws-docs/`가 Windows 경로처럼 변환된다.
- GitHub Pages 빌드가 잘못된 base href를 갖는다.

조치:

```powershell
cd D:\workspace\awc-docs\flutter_app
flutter build web --release --base-href /aws-docs/
```

- Windows에서는 Pages 배포 빌드를 PowerShell에서 실행한다.
- 로컬 루트 프리뷰는 별도로 `--base-href /`를 쓴다.

### 로컬 프리뷰와 Pages 배포 URL이 다름

GitHub Pages:

```text
https://velkaressiablutkrone.github.io/aws-docs/
base href: /aws-docs/
```

로컬 루트 프리뷰:

```powershell
flutter build web --release --base-href /
```

주의:

- 로컬 프리뷰에서 잘 보인 라우트가 Pages에서도 보이려면 `/aws-docs/` base href로 다시 확인해야 한다.
- 이 앱은 `go_router` 해시 라우팅을 사용하므로 딥링크는 `/#/...` 형태를 기준으로 본다.

## 오디오 강의 M1

### 오디오 UI가 기본 빌드에 보이지 않음

판정:

- 의도된 동작이다.
- 오디오 기능은 `audio_lecture` dart-define 뒤에 있다.

로컬 오디오 확인 빌드:

```powershell
cd D:\workspace\awc-docs\flutter_app
flutter build web --release --dart-define=audio_lecture=true --base-href /
```

주의:

- 실제 MP3는 검수 전이면 source asset으로 커밋하지 않는다.
- 필요할 때만 `build/web/assets/audio/...` 아래에 복사해 프리뷰한다.

### `play()`가 기기에서만 실패하거나 `NotAllowedError`가 남

원인 후보:

- 사용자 탭 이벤트와 실제 `audio.play()` 사이에 `await`가 끼어 user activation을 잃었다.

조치:

- 버튼 핸들러에서 `controller.play()`가 동기적으로 호출되는지 확인한다.
- asset 확인, 메타 로드, analytics 같은 비동기 작업은 `play()` 앞에 두지 않는다.
- Web DOM 코드는 `package:web` 경계 파일에만 둔다. VM 테스트가 직접 import하면 안 된다.

### Media Session 또는 잠금화면 컨트롤만 불안정

판정:

- 재생 자체와 Media Session 제어는 분리해서 본다.
- Android에서 재생 위치가 이어지면 핵심 재생 상태는 보존된 것으로 볼 수 있다.

조치:

- `AudioController` 상태 변화와 `MediaSessionBinder`의 action handler 연결을 확인한다.
- 터치 판정이 특정 휴대폰 잠금화면에서만 불안정하면 기기/OS UI 이슈로 기록하고, 다른 기기 또는 배포 PWA에서 재검증한다.

### Range 또는 MIME이 맞는지 확인해야 함

배포된 MP3 URL이 있을 때 실행한다.

```powershell
cd D:\workspace\awc-docs\flutter_app
$py = "C:\Users\deepe\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
$expectedSha256 = "audio_meta.json의 audio.sha256 값"
& $py tool\check_audio_range.py `
  https://velkaressiablutkrone.github.io/aws-docs/assets/audio/clf/clf-t1-1/lecture.mp3 `
  --expect-sha256 $expectedSha256
```

통과 기준:

- HEAD가 2xx 또는 3xx다.
- `Content-Type`이 `audio/mpeg`다.
- `Accept-Ranges: bytes`가 있다.
- `Range: bytes=0-1` 요청이 `206`과 `Content-Range`를 돌려준다.
- 캐시 validator가 있다.
- 기대 SHA-256을 넣은 경우 실제 파일 해시가 일치한다.

## TTS와 메타 생성

### Python 실행기가 없거나 `py`가 동작하지 않음

증상:

- Windows `py` 런처가 없다.
- `python`이 Microsoft Store alias로 연결된다.

조치:

- Codex 번들 Python을 사용할 수 있다.

```powershell
C:\Users\deepe\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe --version
```

- `boto3`가 필요한 Polly 합성은 boto3가 설치된 Python 환경에서 실행한다.
- `--self-test`, `--dry-run`, `--meta-only`는 실제 합성 없이 문제를 좁히는 데 먼저 쓴다.
- 시스템 `python`이 정상 등록되어 있으면 아래 예시의 `$py` 대신 `python`을 써도 된다.

### 메타만 다시 만들기

```powershell
cd D:\workspace\awc-docs\flutter_app
$py = "C:\Users\deepe\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $py tool\gen_lecture_audio.py `
  --md assets\content\clf\t1-1.md `
  --out assets\audio\clf\clf-t1-1\lecture.mp3 `
  --doc-id clf-t1-1 `
  --meta-only
```

주의:

- `audio_meta.json`의 `source.sha256`이 현재 문서와 다르면 오디오가 stale이다.
- `containerChecks.ok=false`면 ID3 또는 컨테이너 문제부터 고친다.
- `reviewStatus=needs_human_review`는 공개 승인 상태가 아니다.

## 로컬 모바일 확인

### PC에서는 열리는데 휴대폰에서 접속 안 됨

원인 후보:

- 서버가 `127.0.0.1`에만 바인딩되어 있다.
- Windows 방화벽 인바운드가 막고 있다.
- 휴대폰과 PC가 같은 네트워크가 아니다.

진단:

```powershell
ipconfig
netstat -ano | Select-String ':8125'
Test-NetConnection 127.0.0.1 -Port 8125
```

조치:

- 서버는 `0.0.0.0:8125`로 연다.
- 휴대폰에서는 PC LAN IP를 쓴다. 예: `http://192.168.0.5:8125/#/cert/CLF-C02/study/clf-t1-1`
- `http://127.0.0.1:8125/`는 휴대폰 자기 자신을 가리킨다. Android에서 PC localhost를 쓰려면 `adb reverse`가 필요하다.

### Windows 방화벽 때문에 LAN 접속이 막힘

임시 허용 규칙:

```powershell
New-NetFirewallRule `
  -DisplayName "AWC Docs Android Audio Preview 8125 TEMP" `
  -Direction Inbound `
  -Action Allow `
  -Protocol TCP `
  -LocalPort 8125 `
  -RemoteAddress LocalSubnet
```

정리:

```powershell
Remove-NetFirewallRule -DisplayName "AWC Docs Android Audio Preview 8125 TEMP"
```

주의:

- 이 규칙은 로컬 Android 프리뷰용 임시 규칙이다.
- 서버를 끈 뒤에도 방화벽 규칙은 별도로 제거해야 한다.

### HTTPS로 접속하면 안전하지 않다는 경고가 뜸

판정:

- 자체 서명 인증서는 Android Chrome/PWA 설치 검증에 안정적이지 않다.
- Windows에서 되더라도 Android 신뢰 저장소와 Chrome 정책에서 막힐 수 있다.

조치:

- 로컬 LAN에서는 HTTP 탭 재생 확인까지만 신뢰한다.
- PWA 설치, standalone 실행, 보안 컨텍스트 의존 기능은 배포 HTTPS URL에서 확인한다.

### "앱 설치" 또는 "홈 화면에 추가"가 보이지 않음

판정:

- 배포 버전에서 설치가 되는데 로컬 LAN에서만 안 되면 앱 구조보다 origin/secure context 조건 문제일 가능성이 높다.

조치:

- 최종 PWA 설치성은 `https://velkaressiablutkrone.github.io/aws-docs/`에서 확인한다.
- 로컬 LAN 결과는 `blocked-local`로 기록한다.
- Android Chrome 플래그 `unsafely-treat-insecure-origin-as-secure`는 보조 수단일 뿐, 게이트 통과 근거로 삼지 않는다.

## 브라우저 자동화와 네트워크 도구

### Playwright 또는 브라우저 플러그인이 바로 안 됨

증상:

- 로컬 번들 Playwright가 `playwright-core`를 찾지 못한다.
- 브라우저 플러그인이 현재 세션에 노출되지 않는다.

조치:

- 브라우저 자동화가 막히면 Flutter 테스트, 직접 HTTP probe, 모바일 수동 확인으로 우회한다.
- 자동화 도구 문제를 제품 결함으로 기록하지 않는다.

### `Get-NetIPAddress`가 거부됨

증상:

- 네트워크 인터페이스 조회가 권한 문제로 실패한다.

조치:

```powershell
ipconfig
```

- IPv4 주소만 필요하면 `ipconfig`가 충분하다.

## 작업 종료 체크리스트

- `git status --short --branch --untracked-files=all`로 의도한 파일만 변경됐는지 확인한다.
- 문서 전용 변경은 `git diff --check`를 통과시킨다.
- 로컬 서버가 있으면 중지한다.
- 임시 방화벽 규칙이 있으면 제거한다.
- 검수 전 MP3, 메타, 개인 설정은 커밋하지 않는다.
