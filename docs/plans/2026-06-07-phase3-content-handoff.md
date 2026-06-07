# Phase 3 Handoff — 비-CLF 콘텐츠 생산 (다음 세션 이관)

> 한 줄 상태: **엔진(Phase 0~2, 학습 루프 E1~E6) 전부 완료·배포. 남은 건 콘텐츠뿐.** Phase 3 = 비-CLF 자격증의 검증 학습문서 + verified 문항 생산. **그릇은 완성됐고, 자격증 일반 엔진이라 콘텐츠를 채우면 즉시 사이트에 노출된다.**

> ⚠️ **HARD GATE (타협 불가): 비-CLF 콘텐츠는 본인 CLF 합격 후 시작.** 현 단계에서 다음 세션이 할 일은 "Phase 3를 당장 실행"이 아니라 "게이트가 풀리면 어떻게 복제하는지"를 알고 대기하는 것. 게이트 전이라도 가능한 것: 메타데이터 정정, 엔진 버그 수정, 잔여 결정(아래 §7). 콘텐츠 생산은 게이트 후.

## 0. 지금 어디인가 (2026-06-07 기준)

- **라이브:** https://velkaressiablutkrone.github.io/aws-docs/ · 저장소 `VelkaressiaBlutkrone/aws-docs` · 브랜치 `main`(직접 커밋·push, 최신 `c5662fe`).
- **스택:** Flutter Web (Dart, `flutter_app/`) + go_router(해시 라우팅), GitHub Pages 자동 배포(main push 시).
- **엔진 완료:** Spec 1(IA/라우팅) · Spec 2(통합 모의고사) · Phase 0(정리) · Phase 1(E1 오답노트·E2 약점리포트) · Phase 2(E5 진행률·E6 약점 가중 모의고사). **학습 루프 E1~E6 전부 라이브.** 78 테스트 green.
- **CLF 콘텐츠 완주:** CLF-C02 **19/19 Task, 검증 118문항**(D1 23·D2 27·D3 51·D4 17). 이게 Phase 3의 복제 원본이다.
- **나머지 11개 자격증:** "준비 중"(공식 Exam Guide 구조만 있고 검증 콘텐츠 0). 이게 Phase 3의 작업 대상.

## 1. 핵심 인식 — 엔진은 자격증 일반(general)

학습 루프(렌더러·퀴즈·시험·이력·오답노트·약점리포트·진행률·약점 가중 모의고사)는 **특정 자격증에 묶여 있지 않다.** `examGuideTaskId`(예: `clf-t2-1`)와 `certCode`(예: `CLF-C02`)로 동작하므로, 새 자격증의 콘텐츠를 같은 스키마로 채우고 `content_index.dart`에 등록하면 **그 자격증도 즉시 학습문서·퀴즈·모의고사·약점리포트·가중 모의고사가 전부 작동한다.** Phase 3는 코드 작업이 아니라 **콘텐츠 검수 작업**이다. (진짜 병목은 사람 검수 — 플레이북 §Diagnostic.)

## 2. 절대 잊지 말 환경 (매 세션 함정)

- **폴더:** git 루트 = `D:\workspace\awc-docs`, Flutter 코드 = 그 바로 아래 `flutter_app\`(중간 `aws-docs\` 폴더 없음). 콘텐츠 에셋 = `flutter_app\assets\content\<cert>\`, exam guide = `flutter_app\assets\exam_guides\`.
- **명령:** flutter/test/analyze는 **PowerShell**에서 `flutter_app` 기준. git은 **항상** `-C D:/workspace/awc-docs`(PowerShell Set-Location이 Bash 도구 cwd까지 바꿔 상대경로 깨진 사례). Git Bash로 flutter 금지(`--base-href` 망가짐).
- **커밋:** `main` 직접 커밋·push(피처 브랜치 아님, 사용자 선택).
- **검증 명령:**
  ```powershell
  flutter analyze ; flutter test                      # 현재 78 테스트
  flutter build web --release --base-href /aws-docs/  # 배포 빌드(배포는 main push 시 CI 자동)
  ```

## 3. 콘텐츠 생산 메커니즘 (CLF에서 검증된 복제 레시피)

자격증 1개를 끝까지 = **Task당 [학습문서 1개 + verified 문항 ≥5개]** × 그 자격증의 Task 수. CLF는 19 Task였다. 한 번에 **한 자격증만**(게이트).

### 3.1 한 Task = 3개 산출물 + 1줄 등록

1. **학습문서** `flutter_app/assets/content/<cert>/<tX-Y>.md` — YAML 프런트매터 + 마크다운 본문.
2. **문항 뱅크** `flutter_app/assets/content/<cert>/<tX-Y>.questions.json` — `QuestionBank` JSON.
3. **인덱스 등록** `flutter_app/lib/data/content_index.dart` — `kContentIndex`의 해당 자격증 리스트에 `ContentEntry` 1줄.
4. (새 자격증 첫 Task일 때만) **pubspec 에셋 디렉터리 등록** — §4 참조.

### 3.2 학습문서 .md 형식 (프런트매터 필드)

`assets/content/clf/t2-1.md`가 표준 예시. 프런트매터 필수/선택:
```yaml
---
examGuideTaskId: clf-t2-1      # = ContentEntry.taskId, 문항의 examGuideTaskId와 동일
certCode: CLF-C02
domain: 2                       # 도메인 번호(int)
domainName: 보안 및 규정 준수    # 선택(헤더 칩)
domainWeightPct: 30             # 선택(헤더 칩)
title: 공동 책임 모델 (Shared Responsibility Model)
coversTasks:                    # 이 문서가 1:1로 커버하는 공식 Task 번호(들)
  - "2.1"
sources:                        # 출처(검증 근거) — 학습문서 하단 📌에도 표기
  - title: AWS 공동 책임 모델 (공식, 한국어)
    url: https://aws.amazon.com/ko/compliance/shared-responsibility-model/
lastVerified: 2026-06-06        # 선택(검수일 칩)
---
```
본문 섹션 컨벤션(files.zip 템플릿 채택): `✅ 학습 목표 체크리스트 → 🎯 왜 중요한가 → 📖 핵심 개념(표/다이어그램/코드블록) → ✍️ 시험 포인트 → ⚠️ 흔한 함정 → 🧪 자가 점검(<details> 정답 토글) → 📌 출처`. 마크다운 파서가 지원하는 블록: heading(1~3)·문단·불릿·번호·체크리스트·표·인용·코드·`<details>`(접기)·구분선. **개인 취업 맥락 섹션(예: DIO Implant 실무·면접)은 공개 사이트 미게재.**

### 3.3 문항 뱅크 .questions.json 형식

`assets/content/clf/t2-1.questions.json`이 표준 예시. 구조:
```json
{
  "examGuideTaskId": "clf-t2-1",
  "taskTitle": "공동 책임 모델",
  "domain": 2,
  "certCode": "CLF-C02",
  "questions": [
    {
      "id": "clf-t2-1-q1",            // 고유. <taskId>-q<n> 컨벤션
      "examGuideTaskId": "clf-t2-1",
      "skill": "서비스에 따른 책임 이동(...)",  // 공식 가이드 Skill 항목
      "difficulty": "foundational",
      "stem": "문제 본문 ...",
      "options": ["...","...","...","..."],   // 정확히 4개
      "correct": 1,                    // 0-base 정답 인덱스
      "explanation": "정답 해설 ...",
      "wrongExplanations": {           // 모든 오답 인덱스에 해설(정답 인덱스 제외)
        "0": "...", "2": "...", "3": "..."
      },
      "sources": [                     // ★ verified 게이트: ≥1개 공식 출처 필수
        { "title": "...", "url": "https://..." }
      ],
      "verified": true                 // 출처·검수 끝나면 true. false면 빌드에서 제외
    }
  ]
}
```
**런타임 게이트(`QuestionBank.fromJson`):** `verified != true` 문항은 로드 시 자동 제외(`question.dart:81`). 즉 출처 없는/미검수 문항은 사이트에 절대 노출되지 않는다 — 이게 "정직성" 해자의 작동 원리.

### 3.4 content_index.dart 등록 (1줄)

`kContentIndex` 맵에 자격증 키(예: `'SAA-C03'`) 리스트를 만들고 Task마다 `ContentEntry` 추가:
```dart
ContentEntry(
  certCode: 'SAA-C03',
  taskId: 'saa-t1-1',                       // = 파일명 stem, 문항 examGuideTaskId
  title: '...',
  domain: 1,
  mdAsset: 'assets/content/saa/t1-1.md',
  questionsAsset: 'assets/content/saa/t1-1.questions.json',
  questionCount: 5,                         // ★ 실제 verified 문항 수와 일치시킬 것
),
```
- `questionCount`는 랜딩 요약·학습문서 카드 라벨에 쓰인다. **실제 verified 문항 수와 반드시 동기화**(flip/추가 시 갱신). 자격증이 `certHasContent`=true가 되면 자동으로 "준비 중"에서 학습문서/모의고사 카드로 승격.

### 3.5 생산 루프 (Task 1개당, 플레이북 §생산 루프)

1. 약한 Task부터 선택(B 정신) → 공식 ko_kr Exam Guide(`assets/exam_guides/<cert>.json`에 이미 있음) + AWS 공식 문서로 공부.
2. 학습문서 1개 작성(§3.2 템플릿, 공식 Task에 1:1 앵커).
3. 문항 ≥5개: **AI 초안 → 본인이 공식 문서 열어 정답+오답근거 대조 + 출처 URL 기록(verified 게이트) → 독립 서브에이전트 AI 역대조("정답/오답해설이 공식 가이드와 어긋나는가?") → 수정 → `verified:true`.**
4. 본인이 직접 풀고 헷갈린 지점을 `wrongExplanations`에 반영.
5. `flutter analyze` 무이슈 / `flutter test` green / `build web --release` 성공 확인 후 main push(즉시 배포).

### 3.6 verified 품질 규율 (타협 불가)

- **출처 URL 없음 → verified 불가 → 빌드 제외.** 기억으로 도장 금지(링크를 붙이려면 공식 문서를 열 수밖에 없게).
- `options` 정확히 4개, 모든 오답에 `wrongExplanations`, `skill`/`difficulty` 채움.
- 모든 verified 문항 **AI 역대조 2차 점검**(공식 문서 페치 대조). 학습문서 척추 = 공식 Task(`examGuideTaskId`).
- 신규 문항은 `verified:false` 드래프트로 넣고 검토 후 flip; flip 시 `content_index`의 `questionCount`와 (있다면) 하드코딩 테스트 동기화([[question-bank-verified-workflow]]).

## 4. 새 자격증 부트스트랩 체크리스트 (CLF에 이미 있던 것 = 새 cert에 필요한 것)

| 항목 | CLF 상태 | 새 cert(예: SAA) 필요 작업 |
|---|---|---|
| 공식 Exam Guide JSON | ✅ `assets/exam_guides/CLF-C02.json` | ✅ **이미 12개 전부 존재**(`SAA-C03.json` 등). 추가 작업 없음. |
| Task/Skill 매핑 문서 | `docs/plans/clf-c02-task-mapping.md` | 권장: `docs/plans/<cert>-task-mapping.md` 새로 작성(진척 0/N 표). Exam Guide JSON에서 Task·도메인 가중 추출. |
| 콘텐츠 에셋 디렉터리 | `assets/content/clf/` | **신규 디렉터리** `assets/content/<cert>/` + **pubspec.yaml 등록** — `flutter_app/pubspec.yaml`의 `assets:` 섹션에 `- assets/content/<cert>/` 한 줄 추가(현재 `assets/content/clf/`만 등록됨, 줄 65). 누락 시 런타임 에셋 로드 실패. |
| content_index 등록 | `kContentIndex['CLF-C02']` | `kContentIndex`에 자격증 키 + Task별 `ContentEntry`(Task 진행하며 1줄씩). |
| 한국어 요약(선택) | `assets/exam_summaries.json`의 `CLF-C02` | 선택: cert 상세 상단 한국어 요약 블록. 없어도 동작. |
| 도메인 가중(모의고사·E6) | Exam Guide JSON `domains[].weightPct` | Exam Guide JSON에 이미 있음 → 통합/약점 모의고사 자동 동작. 문항 뱅크의 `domain` 필드만 정확히 채우면 됨. |

**즉, 새 cert에서 실제 신규 작업 = (1) pubspec 에셋 디렉터리 1줄 + (2) content_index 자격증 키 + (3) Task별 콘텐츠 3종.** 나머지(Exam Guide·라우팅·엔진·모의고사·약점리포트)는 전부 재사용.

## 5. 추천 다음 자격증 — SAA-C03 (사용자 결정 대기)

- **근거:** 본인이 이미 SAA-C03 자료 한 벌(`D:\Download\files.zip`: 27 상세문서 + Mock ~110 + 종합 325 + HTML 앱)을 만들어 둠 → **문서 내부 템플릿만 차용**해 빠르게 첫 사이클.
- **게이트 경고(중요):** files.zip의 325 SAA 문항은 **출처 기록 없는 비검증 초안** → 그대로 `verified` 불가. SAA 단계에서 **출처 앵커 재검증 필수**(verified 게이트가 이미 차단하므로 안전). 템플릿(틀)만 빌려오고 사실 진술은 공식 문서로 새로 대조.
- **SAA는 CLF보다 표면이 넓다** — Task당 문항이 5개보다 많아질 수 있고(CLF에서도 표면 넓은 Task는 7~9문항), 시간 단가가 더 든다. 단위 시간은 첫 배치로 측정.
- 단, **어떤 자격증을 다음으로 할지는 사용자(본인 진로/시험 일정)의 결정.** 게이트 풀린 뒤 첫 세션에서 한 자격증을 확정하고 그 매핑 문서부터 작성.

## 6. 커버리지 목표 패턴 (CLF 기준 복제)

- Task당 verified 문항 **≥5개**(표면 넓은 Task는 더). 자격증 전체 = Task 수 × ≥5.
- Task별 진척을 `<cert>-task-mapping.md`에 0/N 표로 추적(CLF처럼 세션마다 진척 로그).
- **성공 기준(CLF에서 입증된 루프):** 사이트만으로 모의고사 정답률 ≥70% 안정 → 실제 응시·합격이 최종 제품 증명.

## 7. 게이트 전에도 가능한 일 (콘텐츠 아님)

- **보류 결정:** `quiz_widgets` 폰트 크기 토큰화 — DESIGN.md 타입스케일(13·15·16·17·20·28)이 코드 실제값(12·14)과 어긋남 → "코드 유지 vs 문서 정렬(소폭 시각 변화)" 사용자 결정 필요. 테두리 두께 토큰도 DESIGN.md 미정의.
- **E5 알려진 한계(허용):** 같은 SPA 세션에서 학습문서 읽고 뒤로가면 랜딩 "열람 N/총" 배지가 즉시 갱신 안 됨(스택 보존, 재방문/리로드 시 정확). cert 상세 배너는 FutureBuilder라 신선. 반응형 스토어·멀티탭 동기화는 의도적 비목표(YAGNI). 필요해지면 별도 작업.
- **SEO:** Flutter 캔버스라 한국어 검색 노출 약함 — 콘텐츠 안정화 후 보완(메타/프리렌더). 지금 불필요.
- **`flaggedQuestionIds` 복습:** E1은 오답(wrong)만 복습 큐로 사용. 플래그 문항 복습은 후속(E1 설계 §9).

## 8. 참고 문서

- **콘텐츠 플레이북(필독):** `docs/plans/2026-06-06-content-production-playbook.md` — A+B 혼합 루프, verified=출처 게이트 EUREKA, files.zip 템플릿 결정.
- **CLF Task 매핑(복제 원본):** `docs/plans/clf-c02-task-mapping.md` — 19 Task 0/N 표 + 세션별 진척 로그(생산 페이스 실측치 포함).
- **표준 콘텐츠 예시:** `flutter_app/assets/content/clf/t2-1.md` + `t2-1.questions.json`(학습문서·문항 뱅크 형식의 정본).
- **모델:** `lib/models/study_content.dart`(블록·프런트매터) · `lib/models/question.dart`(문항·뱅크·verified 게이트).
- **우선순위 로드맵:** `docs/superpowers/specs/2026-06-07-work-priority-roadmap-design.md`(정리→루프완결→콘텐츠, Phase 0~2 ✅).
- **직전 세션 핸드오프:** `docs/plans/2026-06-06-session-handoff.md`(엔진 전체 현황·라우트·테스트 함정).
- **학습 루프 원안:** `docs/designs/clf-learning-loop.md`.

## 9. 한 줄 요약 (다음 작업자에게)

> 엔진은 끝났다. **그릇(자격증 일반 학습 루프)이 완성돼 있고, 콘텐츠를 부으면 그 자격증이 통째로 살아난다.** Phase 3는 "한 번에 한 자격증을, Task당 [학습문서 + verified 문항 ≥5] + content_index 1줄 + (신규 cert면) pubspec 1줄"로 CLF 레시피를 복제하는 일. **단, 본인 CLF 합격이 게이트.** 합격 전엔 콘텐츠를 만들지 말고, 이 문서로 복제법만 숙지한 채 대기하라. 첫 후보는 SAA-C03(템플릿은 files.zip, 사실은 출처 재검증).
