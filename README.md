# AWS Docs Roadmap

AWS Certification official exam guide 기준으로 구성한 학습 로드맵 정적 사이트입니다.

## 구성

- 단계별 자격증 맵
- 목표별 추천 순서
- 자격증별 학습 로드맵
- 상세 학습 문서
- 학습 문서 기반 모의고사 6회차

## 개발

```bash
npm install
npm run dev
```

로컬 확인 주소:

```text
http://localhost:5173/aws-docs/
```

## 빌드

```bash
npm run build
```

## 배포

GitHub Pages 프로젝트 페이지 기준입니다.

- Repository: `https://github.com/VelkaressiaBlutkrone/aws-docs`
- Pages URL: `https://velkaressiablutkrone.github.io/aws-docs/`
- Vite base path: `/aws-docs/`
- Workflow: `.github/workflows/pages.yml`

GitHub 저장소 Settings -> Pages에서 Source를 GitHub Actions로 설정한 뒤 `main` 브랜치에 push하면 배포됩니다.
