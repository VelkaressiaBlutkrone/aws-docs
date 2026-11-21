# Play 업로드용 릴리스 AAB 빌드 (D1-b, 2026-11-21).
#
# 왜 스크립트인가: `audio_lecture` 는 **빌드 시점** 상수(`bool.fromEnvironment`)라 켜는 곳이
# 빌드 명령뿐이다. 웹은 `.github/workflows/pages.yml` 이 켜고 `release_flag_sync_test.dart` 가
# CI 동기를 지키는데, Android 에는 워크플로가 없어 **플래그를 켤 자리가 없었다**. 그래서 릴리스
# 명령을 여기 커밋해 단일 출처로 두고, 웹 릴리스가 켜는 dart-define 을 전부 켜는지
# `test/android_audio_service_manifest_test.dart` 가 pages.yml 과 맞댄다.
#
# ⚠️ Git Bash(MSYS)가 아니라 **PowerShell 에서 실행한다** — 레포 관례이고, MSYS 는 슬래시로
# 시작하는 인자를 Windows 경로로 변형한다(`flutter build web --base-href /aws-docs/` 사고).
#
# ⚠️ 서명: `android/key.properties` 가 있으면 업로드 키로, 없으면 **디버그 키로 폴백**한다
# (`android/app/build.gradle.kts`). 디버그 키로 서명된 AAB 는 Play 에 올릴 수 없으므로,
# 업로드할 빌드는 키가 있는 환경에서 만들고 이 스크립트가 그것을 먼저 확인한다.
#
# 사용: pwsh -File tool/build_android_release.ps1   (flutter_app 디렉터리에서)

$ErrorActionPreference = 'Stop'

$keyProps = Join-Path $PSScriptRoot '..\android\key.properties'
if (-not (Test-Path $keyProps)) {
    Write-Warning 'android/key.properties 가 없다 — 디버그 키로 서명된다. 이 AAB 는 Play 에 업로드할 수 없다.'
}

flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# dart-define 은 웹 릴리스(pages.yml)와 같은 집합이어야 한다.
flutter build appbundle --release --dart-define=audio_lecture=true
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$aab = Join-Path $PSScriptRoot '..\build\app\outputs\bundle\release\app-release.aab'
if (Test-Path $aab) {
    $size = (Get-Item $aab).Length
    Write-Host "AAB: $aab ($size bytes)"
} else {
    Write-Error "AAB 가 만들어지지 않았다: $aab"
}
