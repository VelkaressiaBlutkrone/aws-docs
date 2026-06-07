# SAA-C03 학습문서 선행 생산 — 설계 (Design Spec)

> 작성: 2026-06-07 · 브랜치 main · 상태: 설계 확정(사용자 리뷰 대기)
> 한 줄: **CLF에서 검증된 학습문서 제작 방식을 SAA-C03에 복제하되, verified 문항(엄격 게이트)은 CLF 합격 후로 미루고 "출처 기반 학습문서"만 먼저 생산·노출한다.**

## 1. 목적과 동기

엔진(학습 루프 E1~E6)은 자격증 일반(general)으로 완성돼 배포돼 있다. 남은 것은 콘텐츠뿐이다. 본인은 이미 SAA-C03 자료 한 벌(`D:\Download\files.zip`: Phase-01~11 학습문서 ~27개 + Mock + 종합모의고사 + HTML 앱)을 만들어 두었다. 이 설계는 그 자료를 사이트 학습문서로 변환해 **SAA 학습문서 전체(~20~30개)**를 생산하는 것을 목표로 한다.

핸드오프(`docs/plans/2026-06-07-phase3-content-handoff.md`)의 HARD GATE는 "비-CLF 콘텐츠는 CLF 합격 후"였다. 본 설계는 그 게이트를 **학습문서에 한해 명시적으로 예외 처리**한다. 근거:

- 게이트의 핵심 위험은 **verified 문항**의 "틀린 이해 박제"(초보 검수 한계)이고, 그 위험은 문항에 한정된다.
- 학습문서는 `study_content` 모델에 `verified` 빌드 게이트가 없다 — 렌더만 된다. 출처(`sources[]` 프런트매터)는 정직성 규율로 유지하되, 문항만큼 엄격한 차단 장치는 아니다.
- 따라서 "학습문서 먼저 / 문항 추후" 분리는 게이트의 핵심 위험을 건드리지 않으면서 진도를 빼는 합리적 변형이다.

**verified 문항은 전부 CLF 합격 후로 유지된다.** 본 설계 범위에서 SAA의 `questionCount`는 항상 0이다.

## 2. SAA-C03 공식 구조 (기준)

| 도메인 | 비중 | 공식 Task |
|---|---|---|
| D1 보안 아키텍처 설계 | 30% | 1.1, 1.2, 1.3 |
| D2 복원력을 갖춘 아키텍처 | 26% | 2.1, 2.2 |
| D3 고성능 아키텍처 | 24% | 3.1, 3.2, 3.3, 3.4, 3.5 |
| D4 비용에 최적화된 아키텍처 | 20% | 4.1, 4.2, 4.3, 4.4 |

공식 Task는 **14개**. 단, SAA Task는 표면이 매우 넓어(예: "3.2 고성능 컴퓨팅"=EC2+ASG+Lambda+컨테이너) CLF처럼 **학습 주제 단위로 더 잘게 분할**한다. files.zip이 27문서로 나눈 것이 같은 이유다. 최종 문서 수는 §4 매핑에서 확정한다.

## 3. 노출 인프라 (코드 변경 — 1회)

"문항 없는 학습문서만" 상태를 1급으로 지원하는 최소 가드. 판정은 런타임 실제 문항 수가 아니라 **`content_index` 정적 집계**(`certContentSummary(code).questions == 0`)로 한다 — 결정적이고 테스트 가능.

### 3.1 변경 지점

- **`lib/data/content_index.dart`**
  - `ContentEntry(questionCount: 0)` 허용(이미 타입상 가능, 0 의미를 명시).
  - 헬퍼 추가: `bool certHasVerifiedQuestions(String certCode)` = `certContentSummary(certCode).questions > 0`. (이름은 구현 시 확정.)
- **`lib/pages/home_page.dart` · `_StudyDocsSection`**
  - 요약 라벨 분기: 문항 > 0 → `"검증 학습문서 N · 총 M문항"`(현행), 문항 == 0 → `"학습문서 N · 문항 준비 중"`.
- **`lib/pages/home_page.dart` · `_ExamsSection`**
  - `withContent`를 "콘텐츠 보유"가 아니라 **"문항 보유"** 기준으로 좁힌다. 문항 0인 cert는 모의고사 카드와 약점 게이트 줄에서 제외(학습문서 카드에는 계속 노출). 빈 모의고사 카드를 "준비 중"으로 표시하지 않고 **아예 숨긴다**(사용자 결정).
- **`lib/pages/cert_detail_page.dart` · `_LearningContent`**
  - 문항 0이면: ① Task 카드의 "검증 문항 N" 배지 숨김, ② **약점 리포트·약점 집중 모의고사·오답노트 카드 숨김**. ③ 학습문서 링크와 진행률 배너(문서 열람률)는 유지.
  - `_load()`의 문항 뱅크 로드(약점 인덱스용)는 빈 결과를 안전 처리(현재 try/catch로 이미 안전).

### 3.2 안전성 확인 (조사 완료)

- `cert_exam_page.dart:171` — `data.total == 0`이면 크래시 없이 "검증된 문항이 아직 없습니다." 표시. 모의고사 라우트는 직접 진입해도 안전(숨겨도 라우트는 살아있음).
- `mock_exam.dart` 샘플러 — 빈 풀에서 빈 리스트 반환(예외 없음).

### 3.3 테스트

- `test/home_sections_test.dart` 패턴 확장: 문항 0인 cert가 ① 학습문서 섹션엔 노출되고 ② 모의고사 섹션엔 미노출임을 검증.
- `content_index` 헬퍼 단위 테스트: `questionCount: 0` 집계와 `certHasVerifiedQuestions` 판정.
- SelectionArea 위젯 테스트 함정([[flutter-selectionarea-widget-test-pitfall]]) 회피: 라우팅/렌더 통합이 아니라 섹션 빌더·헬퍼 단위로 검증.

## 4. 콘텐츠 조직 (매핑)

CLF 방식 복제: **도메인-순번 식별자 + 공식 Task 앵커.**

- **식별자**: `saa-t{도메인}-{순번}`(예: `saa-t1-1`, `saa-t3-4`). 파일명 stem = taskId = 문항의 `examGuideTaskId`(문항은 추후).
- **공식 Task 매핑**: 각 학습문서 프런트매터 `coversTasks: ["1.1"]`로 1:1(또는 명시적 N개) 앵커. 식별자 순번은 학습 주제 순번이지 공식 Task no가 아니다(CLF와 동일).
- **매핑 산출물**: `docs/plans/saa-c03-task-mapping.md` 신규 — files.zip Phase/Step → 공식 Task → `saa-tX-Y` → 진척 0/N 표. `clf-c02-task-mapping.md` 패턴 복제.
- **files.zip 선별**: Phase-XX-Step 학습문서만 대상. **제외**: DIO 면접 요약(개인 취업 맥락), 종합모의고사·Mock-Phase(문항 → CLF 합격 후 verified 단계), HTML 앱, `shuffle_md.py`. 최종 문서 수는 `00-학습가이드-INDEX.md`를 읽어 ~20~27개로 확정.

## 5. 콘텐츠 생산 루프 (학습문서 한정)

핸드오프 §3.5에서 **문항 단계를 제거**한 축약 루프. Task 1개당:

1. files.zip 해당 문서 → 사이트 템플릿 6섹션으로 변환:
   `✅ 학습 목표 체크리스트 → 🎯 왜 중요한가 → 📖 핵심 개념(표/다이어그램/코드) → ✍️ 시험 포인트 → ⚠️ 흔한 함정 → 🧪 자가 점검(<details> 토글) → 📌 출처`.
   + YAML 프런트매터(`examGuideTaskId`, `certCode: SAA-C03`, `domain`, `domainName`, `domainWeightPct`, `title`, `coversTasks`, `sources`, `lastVerified`).
2. 사실 진술을 AWS 공식 문서로 대조 → `sources[]`에 공식 URL 기록(학습문서 정직성 규율).
3. `🧪 자가 점검`은 학습용 `<details>` 토글로 유지 — **검증 문항이 아니므로 게이트 무관.**
4. `content_index`에 `ContentEntry(questionCount: 0)` 1줄 등록 → 즉시 사이트 노출.
5. `flutter analyze` 무이슈 / `flutter test` green / `flutter build web --release --base-href /aws-docs/` 성공 확인 후 `main` push(점진 배포).

**개인 취업 맥락 섹션(DIO Implant 실무·면접)은 공개 사이트 미게재.**

## 6. 부트스트랩 (신규 cert 1회 작업)

핸드오프 §4 체크리스트:

- `flutter_app/pubspec.yaml` `assets:` 섹션에 `- assets/content/saa/` 1줄 추가(누락 시 런타임 에셋 로드 실패).
- `lib/data/content_index.dart` `kContentIndex`에 `'SAA-C03'` 키 + Task별 `ContentEntry`(작업하며 1줄씩).
- `assets/content/saa/` 디렉터리 신규.
- `assets/exam_summaries.json`에 `SAA-C03` 한국어 요약 블록 추가(목적·대상·우선 학습 포인트·시험 범위 밖 항목) — **포함(CLF와 동일 UX)**.
- 공식 Exam Guide(`assets/exam_guides/SAA-C03.json`)·라우팅·엔진·도메인 가중은 전부 재사용(작업 없음).

## 7. 게이트 유지 (타협 불가)

- **verified 문항은 전부 CLF 합격 후.** 본 범위에서 SAA `questionCount` = 0 유지.
- 게이트가 풀리면 같은 학습문서에 `.questions.json`을 채우고 `content_index`의 `questionCount`만 갱신 → 모의고사·약점 리포트·약점 가중 모의고사·오답노트 루프가 **자동 활성**(코드 변경 불필요, §3 가드가 문항 보유로 판정 전환).
- 학습문서 출처 기록은 본 범위에서도 지킨다(정직성 규율). 단 빌드 차단 게이트는 문항에만 존재.

## 8. 비목표 (YAGNI)

- SAA verified 문항·모의고사·약점 루프(CLF 합격 후).
- SEO/프리렌더(콘텐츠 안정화 후).
- files.zip의 종합모의고사 325문항 이식(비검증 초안 → verified 단계에서 출처 앵커 재검증).
- 폰트 크기 토큰화 등 DESIGN.md 정렬 보류 항목(별개 결정).

## 9. 완료 기준

- 노출 가드(§3) 구현 + 테스트 green. 문항 0인 SAA가 학습문서만 정직하게 노출(모의고사·리포트 카드 미노출).
- `saa-c03-task-mapping.md` 작성(진척 표) + files.zip 선별 확정.
- SAA 학습문서 전체(매핑에서 확정한 N개) 생산·출처 기록·점진 배포.
- `flutter analyze`/`test`/`build web` 통과. `main` push로 라이브 반영.

## 10. 참고

- 콘텐츠 플레이북: `docs/plans/2026-06-06-content-production-playbook.md`
- Phase 3 핸드오프(복제 레시피·부트스트랩): `docs/plans/2026-06-07-phase3-content-handoff.md`
- 표준 콘텐츠 예시: `flutter_app/assets/content/clf/t1-1.md`(학습문서 형식 정본)
- CLF 매핑 원본: `docs/plans/clf-c02-task-mapping.md`
- 모델: `lib/models/study_content.dart`(블록·프런트매터, verified 게이트 없음)
