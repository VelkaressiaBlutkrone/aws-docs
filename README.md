# AWS Docs Roadmap

AWS 자격증을 **한국어로, 이해 중심으로** 공부하는 통합 학습 로드맵 + 모의고사 정적 사이트.
덤프 암기가 아니라 "왜"를 가르치는 것이 목표입니다. Flutter Web으로 구현하고 GitHub Pages에 배포합니다.

> 비공식 학습 사이트입니다. 응시 전 반드시 AWS 공식 시험 가이드를 단일 진실 공급원으로 확인하세요.

## 구성

- **자격증 맵** — 입문~전문 단계별 12개 자격증, 목표별 추천 순서, 자격증별 학습 로드맵
- **공식 시험 가이드 본문** — 도메인·Task·세부 항목을 한국어로 (12개 자격증, 런타임 로드)
- **한국어 학습 요약본** — 자격증별 우선 학습 포인트·시험 범위 밖 항목·활용법
- **검증된 학습 콘텐츠**
  - **CLF-C02** — 19개 학습문서 + 19개 Task 검증 문항 총 301개(Task당 15~19). 문항·모의고사까지 완성된 유일한 자격증
  - **SAA-C03** — 24개 학습문서(4개 도메인 전부, 공식 Task 앵커, AWS 공식 문서 출처 대조). 검증 문항은 준비 중이라 모의고사·약점 루프는 아직 비활성
- **출제 방식** — 선택지 순서를 응시마다 셔플하고(정답 위치 쏠림 방지), Task 연습/시험은 풀에서 5문항을 무작위 차출해 매번 다른 조합을 낸다
- **모의고사** — 학습 문서 기반 통합 모의고사 + 약점 집중 모의고사(검증 문항 보유 자격증에서 활성)
- **반응형** — 데스크톱은 상단 메뉴, 모바일(폭 768px 미만)은 햄버거 드롭다운

### 학습 루프

응시 이력은 브라우저 로컬에 저장되며(서버 없음), 이를 기반으로 한 학습 루프가 동작합니다.

- **오답노트** — 틀린 문항만 모아 다시 풀기 (`/cert/:code/review`)
- **약점 리포트** — Task별 정답률 (`/cert/:code/report`)
- **학습 진행률** — 문서 열람률 · 최고 정답률 · 마지막 응시일
- **약점 집중 모의고사** — 자주 틀린 Task를 가중 출제. 비-review 응시 3회 누적 시 잠금 해제 (`/cert/:code/exam/weak`)

## 기술 스택

- **Flutter Web (Dart)** — 앱 코드는 `flutter_app/`, 라우팅은 `go_router` 해시 전략
- **디자인 시스템** — `DESIGN.md`가 단일 진실 공급원, `flutter_app/lib/theme/app_theme.dart`가 구현
  (Pretendard + JetBrains Mono, 액센트 = verified 틸 `#0E8175`, 라이트 기본 + 다크)
- **자격증 데이터** — `flutter_app/lib/data/site_data.dart`
- **공식 시험 가이드** — `flutter_app/assets/exam_guides/{code}.json` (런타임 로드)
- **학습 콘텐츠 인덱스** — `flutter_app/lib/data/content_index.dart` + `assets/content/{cert}/`
- **상태 저장** — 응시 이력·열람 기록은 `local_kv` → 웹 백엔드(localStorage)

## 디렉터리

```
flutter_app/
  lib/
    app_router.dart        # go_router 라우트 정의 (해시 라우팅)
    data/                  # 자격증/콘텐츠 데이터 + 학습 루프 엔진
                           #   site_data, content_index, history_store,
                           #   wrong_answer_index, task_score_report,
                           #   study_progress, weighted_exam, mock_exam …
    models/                # Certification, ExamGuide, Question, ExamSession …
    pages/                 # Home, CertDetail, StudyDoc, Quiz, Exam,
                           #   CertExam, Review, Report
    content/               # markdown_parser, study_markdown_view, quiz_widgets
    theme/                 # app_theme (DESIGN.md 구현), theme_scope
  assets/
    exam_guides/           # 12개 자격증 공식 가이드 JSON
    content/clf/           # CLF-C02 학습문서(.md) + 문항(.questions.json)
    content/saa/           # SAA-C03 학습문서(.md) — 문항은 게이트 후
    exam_summaries.json    # 한국어 학습 요약본
    fonts/                 # Pretendard, JetBrains Mono
  test/                    # 25개 테스트 파일
DESIGN.md                  # 디자인 시스템 (시각 결정 전 필독)
docs/                      # 설계 스펙·플랜·핸드오프·트러블슈팅
```

## 개발

```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

테스트:

```bash
cd flutter_app
flutter analyze
flutter test
```

문제 해결:

- 레포 전체 작업 중 반복되는 빌드, 배포, 로컬 모바일 확인, 오디오 게이트 이슈는 `docs/TROUBLESHOOTING.md`를 참고하세요.

## 빌드

> Windows에서는 `--base-href` 경로가 Git Bash(MSYS) 경로 변환으로 깨질 수 있으므로 **PowerShell에서 실행**하세요.

```bash
cd flutter_app
flutter build web --release --base-href /aws-docs/
```

산출물: `flutter_app/build/web`

## 배포

GitHub Pages 프로젝트 페이지 기준으로 자동 배포됩니다.

- Repository: `https://github.com/VelkaressiaBlutkrone/aws-docs`
- Pages URL: `https://velkaressiablutkrone.github.io/aws-docs/`
- Base href: `/aws-docs/`
- Workflow: `.github/workflows/pages.yml` (Flutter web 빌드 → Pages 배포)

저장소 Settings → Pages에서 Source를 **GitHub Actions**로 설정한 뒤 `main` 브랜치에 push하면 자동 배포됩니다.

## 콘텐츠 추가

새 학습 문서/문항을 추가할 때는 `flutter_app/lib/data/content_index.dart`에 `ContentEntry`를 한 줄 등록합니다.
문항은 `verified: false` 드래프트로 작성한 뒤 검증이 끝나면 `verified: true`로 전환하며, 노출은 `verified: true`인 문항만 됩니다.
자세한 작성 컨벤션은 `docs/plans/2026-06-06-content-production-playbook.md`를 참고하세요.
