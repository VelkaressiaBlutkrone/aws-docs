# AWS Docs Roadmap

AWS Certification 공식 시험 가이드 기준으로 구성한 한국어 학습 로드맵 사이트입니다.
Flutter Web으로 구현하며, GitHub Pages에 배포합니다.

## 구성

- 단계별 자격증 맵 (12개 자격증)
- 목표별 추천 순서
- 자격증별 학습 로드맵
- 자격증별 **공식 시험 가이드 본문** (도메인·Task·세부 항목, 한국어) + 한국어 학습 요약본
- 학습 문서 기반 모의고사 6회차

## 기술 스택

- Flutter Web (Dart) — 앱 코드는 `flutter_app/`
- 디자인 시스템은 `DESIGN.md`를 단일 진실 공급원으로, `flutter_app/lib/theme/app_theme.dart`가 구현
- 자격증 데이터: `flutter_app/lib/data/site_data.dart`
- 공식 시험 가이드: `flutter_app/assets/exam_guides/{code}.json` (런타임 로드)

## 개발

```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

## 빌드

```bash
cd flutter_app
flutter build web --release --base-href /aws-docs/
```

산출물: `flutter_app/build/web`

## 배포

GitHub Pages 프로젝트 페이지 기준입니다.

- Repository: `https://github.com/VelkaressiaBlutkrone/aws-docs`
- Pages URL: `https://velkaressiablutkrone.github.io/aws-docs/`
- Base href: `/aws-docs/`
- Workflow: `.github/workflows/pages.yml` (Flutter web 빌드 → Pages 배포)

GitHub 저장소 Settings → Pages에서 Source를 **GitHub Actions**로 설정한 뒤 `main` 브랜치에 push하면 자동 배포됩니다.
