# SAA-C03 학습문서 선행 생산 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** SAA-C03의 출처 기반 한국어 학습문서(~20~27개)를 생산해 사이트에 노출하되, verified 문항은 CLF 합격 후로 미루고 "문항 0" 상태를 정직하게 표시한다.

**Architecture:** (1) `content_index` 정적 집계로 "학습문서만(문항 0)" 상태를 1급 판정하는 노출 가드를 추가하고, (2) files.zip 자료를 사이트 6섹션 템플릿으로 변환·출처 재검증해 Task당 학습문서 1개씩 등록한다. 엔진(라우팅·렌더·모의고사·약점 루프)은 전부 재사용.

**Tech Stack:** Flutter Web (Dart), go_router(해시), `flutter_test`. 빌드/테스트는 PowerShell에서 `flutter_app` 기준.

---

## 파일 구조 (생성/수정 맵)

**노출 가드 (1회):**
- Modify: `flutter_app/lib/data/content_index.dart` — `certHasVerifiedQuestions` 헬퍼 + 라벨 헬퍼
- Modify: `flutter_app/lib/pages/home_page.dart` — `_StudyDocsSection` 라벨 분기, `_ExamsSection` 문항 보유 기준
- Modify: `flutter_app/lib/pages/cert_detail_page.dart` — `_LearningContent` 문항 0 가드
- Test: `flutter_app/test/content_index_test.dart`(수정), `flutter_app/test/home_sections_test.dart`(수정)

**부트스트랩 (1회):**
- Modify: `flutter_app/pubspec.yaml` — `assets/content/saa/` 등록
- Create: `flutter_app/assets/content/saa/` (디렉터리)
- (확인만) `flutter_app/assets/exam_summaries.json` — `SAA-C03` 요약 이미 존재

**콘텐츠:**
- Create: `docs/plans/saa-c03-task-mapping.md` — Phase/Step→공식 Task→`saa-tX-Y` 매핑 + 진척표
- Create: `flutter_app/assets/content/saa/saa-tX-Y.md` × N — 학습문서
- Modify: `flutter_app/lib/data/content_index.dart` — `kContentIndex['SAA-C03']` 항목 추가(문서당 1줄)

---

## Phase 1 — 매핑 문서

### Task 1: SAA Task 매핑 + files.zip 선별

**Files:**
- Create: `docs/plans/saa-c03-task-mapping.md`
- Read: `D:\Download\files.zip` (압축 풀어 `00-학습가이드-INDEX.md` 등 확인)
- Read: `flutter_app/assets/exam_guides/SAA-C03.json`

- [ ] **Step 1: files.zip 목록·INDEX 확인**

PowerShell에서:
```powershell
Expand-Archive -Path D:\Download\files.zip -DestinationPath D:\Download\saa_src -Force
Get-ChildItem D:\Download\saa_src -Name
```
`00-학습가이드-INDEX.md`를 읽어 Phase-01~11/Step 구조와 학습 순서를 파악한다.

- [ ] **Step 2: 매핑 표 작성**

`docs/plans/saa-c03-task-mapping.md`를 아래 골격으로 작성한다. 식별자는 `saa-t{도메인}-{순번}`, 공식 Task는 `coversTasks`로 앵커(식별자 순번 ≠ 공식 Task no, CLF와 동일 규칙).

```markdown
# SAA-C03 Task 매핑 + 학습문서 진척

> 식별자 saa-t{도메인}-{순번}. coversTasks=공식 Task 앵커. files.zip 출처는 본문 초안용(사실은 공식 재검증).

## 도메인 (SAA-C03 공식)
| D | 이름 | 비중 | 공식 Task |
|---|---|---|---|
| 1 | 보안 아키텍처 설계 | 30% | 1.1 1.2 1.3 |
| 2 | 복원력 아키텍처 | 26% | 2.1 2.2 |
| 3 | 고성능 아키텍처 | 24% | 3.1 3.2 3.3 3.4 3.5 |
| 4 | 비용 최적화 | 20% | 4.1 4.2 4.3 4.4 |

## 학습문서 (진척: ☐ 미작성 / ☑ 작성·배포)
| taskId | 제목 | domain | coversTasks | files.zip 출처 | 상태 |
|---|---|---|---|---|---|
| saa-t1-1 | (예: IAM·보안 액세스) | 1 | 1.1 | Mock-Phase-02-IAM…, Phase-05-Step-1-암호화 | ☐ |
| …      | … | … | … | … | ☐ |

## 제외 (학습문서 아님)
- DIO-면접-1페이지-요약(개인 취업 맥락) · 종합모의고사 N회분·Mock-Phase(문항→CLF 합격 후) · SAA-모의고사-앱.html · shuffle_md.py
```

Phase/Step을 4개 도메인 아래로 재배치해 ~20~27개 행을 채운다. 표면 넓은 Task는 주제별로 복수 문서로 분할(CLF의 도메인3=8문서 패턴).

- [ ] **Step 3: 커밋**

```bash
git -C D:/workspace/awc-docs add docs/plans/saa-c03-task-mapping.md
git -C D:/workspace/awc-docs commit -m "docs: SAA-C03 Task 매핑·학습문서 진척표 — files.zip 선별"
```

---

## Phase 2 — 노출 가드 (코드, 문항 0 상태 1급화)

이 Phase 동안 SAA는 아직 `content_index`에 없으므로 가드는 누구에게도 영향이 없다 → 기존 테스트 전부 green 유지.

### Task 2: `certHasVerifiedQuestions` 헬퍼

**Files:**
- Modify: `flutter_app/lib/data/content_index.dart` (끝부분, `certContentSummary` 뒤)
- Test: `flutter_app/test/content_index_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`test/content_index_test.dart`에 추가:
```dart
  test('certHasVerifiedQuestions: 문항 있으면 true, 없으면 false', () {
    expect(certHasVerifiedQuestions('CLF-C02'), isTrue);
    expect(certHasVerifiedQuestions('NOPE'), isFalse);
  });
```

- [ ] **Step 2: 실패 확인**

PowerShell:
```powershell
cd D:\workspace\awc-docs\flutter_app ; flutter test test/content_index_test.dart
```
Expected: FAIL — `certHasVerifiedQuestions` 미정의(컴파일 에러).

- [ ] **Step 3: 헬퍼 구현**

`lib/data/content_index.dart` 끝에 추가:
```dart
/// 해당 자격증에 노출 가능한(verified) 문항이 1개 이상 있는가.
/// "학습문서만(문항 0)" 상태를 모의고사·리포트 노출에서 가르는 정적 판정.
bool certHasVerifiedQuestions(String certCode) =>
    certContentSummary(certCode).questions > 0;
```

- [ ] **Step 4: 통과 확인**

```powershell
cd D:\workspace\awc-docs\flutter_app ; flutter test test/content_index_test.dart
```
Expected: PASS.

- [ ] **Step 5: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/data/content_index.dart flutter_app/test/content_index_test.dart
git -C D:/workspace/awc-docs commit -m "feat: certHasVerifiedQuestions — 문항 0 학습문서 상태 판정 헬퍼"
```

### Task 3: 홈 학습문서 섹션 라벨 분기

**Files:**
- Modify: `flutter_app/lib/pages/home_page.dart` · `_StudyDocsSection` (현재 `summaryLabel` 생성부)

- [ ] **Step 1: 라벨 분기 구현**

`_StudyDocsSection`의 `summaryLabel` 클로저(현재 `'검증 학습문서 ${s.docs} · 총 ${s.questions}문항'` 반환)를 아래로 교체:
```dart
                  summaryLabel: () {
                    final s = certContentSummary(cert.code);
                    return s.questions > 0
                        ? '검증 학습문서 ${s.docs} · 총 ${s.questions}문항'
                        : '학습문서 ${s.docs} · 문항 준비 중';
                  }(),
```

- [ ] **Step 2: 분석 확인**

```powershell
cd D:\workspace\awc-docs\flutter_app ; flutter analyze lib/pages/home_page.dart
```
Expected: No issues.

- [ ] **Step 3: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/pages/home_page.dart
git -C D:/workspace/awc-docs commit -m "feat: 학습문서 섹션 — 문항 0이면 '문항 준비 중' 라벨"
```

### Task 4: 홈 모의고사 섹션 — 문항 보유 기준으로 제한

**Files:**
- Modify: `flutter_app/lib/pages/home_page.dart` · `_ExamsSection`

- [ ] **Step 1: 필터 교체**

`_ExamsSection.build`의 두 줄을 교체한다. 현재:
```dart
    final withContent =
        certifications.where((cert) => certHasContent(cert.code)).toList();
    final pending =
        certifications.where((cert) => !certHasContent(cert.code)).toList();
```
교체 후 (문항 보유 cert만 모의고사 카드/약점 줄에; 콘텐츠 전무 cert만 "준비 중"; 학습문서만 cert는 양쪽 모두 미노출):
```dart
    final withContent =
        certifications.where((cert) => certHasVerifiedQuestions(cert.code)).toList();
    final pending =
        certifications.where((cert) => !certHasContent(cert.code)).toList();
```

- [ ] **Step 2: 분석 확인**

```powershell
cd D:\workspace\awc-docs\flutter_app ; flutter analyze lib/pages/home_page.dart
```
Expected: No issues.

- [ ] **Step 3: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/pages/home_page.dart
git -C D:/workspace/awc-docs commit -m "feat: 모의고사 섹션 — 문항 보유 cert만 노출(학습문서만 cert 제외)"
```

### Task 5: cert 상세 `_LearningContent` 문항 0 가드

**Files:**
- Modify: `flutter_app/lib/pages/cert_detail_page.dart` · `_LearningContent`

- [ ] **Step 1: hasQuestions 도입 + 배지 가드**

`_LearningContent.build` 상단(`final c = context.c;` 다음 줄)에 추가:
```dart
    final hasQuestions = entries.any((e) => e.questionCount > 0);
```
Task 카드의 "검증 문항 N" 배지를 감싼다. 현재:
```dart
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: c.correctWeak,
                                      borderRadius:
                                          BorderRadius.circular(Radii.full)),
                                  child: Text('검증 문항 ${e.questionCount}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: c.correct)),
                                ),
```
을 `if (e.questionCount > 0) ...[ ... ],` 로 감싼다:
```dart
                                if (e.questionCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: c.correctWeak,
                                        borderRadius:
                                            BorderRadius.circular(Radii.full)),
                                    child: Text('검증 문항 ${e.questionCount}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: c.correct)),
                                  ),
```

- [ ] **Step 2: 약점 리포트 카드 가드**

"약점 리포트 · Task별 정답률 보기" 카드(`context.push('/cert/${entries.first.certCode}/report')` InkWell을 감싼 `Padding`)를 `if (hasQuestions) ...[ ]`로 감싼다:
```dart
          if (hasQuestions)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: InkWell(
                onTap: () =>
                    context.push('/cert/${entries.first.certCode}/report'),
                // ...(기존 내용 그대로)
              ),
            ),
```

- [ ] **Step 3: 약점 집중 모의고사 카드 가드**

`final unlocked = attemptCount >= kWeightedExamMinAttempts;` 를 포함한 약점 모의고사 `Padding`(클로저 `() { ... }()`) 전체를 `if (hasQuestions)`로 감싼다:
```dart
          if (hasQuestions)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: () {
                final unlocked = attemptCount >= kWeightedExamMinAttempts;
                // ...(기존 내용 그대로)
              }(),
            ),
```

- [ ] **Step 4: 오답노트 카드는 이미 안전 확인**

오답노트 카드는 이미 `if (weakByTask.values.fold(0, (a, b) => a + b) > 0)`로 가드됨 — 문항 0이면 오답도 0이라 자동 미노출. 변경 불필요(확인만).

- [ ] **Step 5: 분석 확인**

```powershell
cd D:\workspace\awc-docs\flutter_app ; flutter analyze lib/pages/cert_detail_page.dart
```
Expected: No issues.

- [ ] **Step 6: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/pages/cert_detail_page.dart
git -C D:/workspace/awc-docs commit -m "feat: cert 상세 — 문항 0이면 문항 배지·약점 리포트·약점 모의고사 숨김"
```

### Task 6: 전체 회귀 확인

- [ ] **Step 1: 전체 테스트·분석**

```powershell
cd D:\workspace\awc-docs\flutter_app ; flutter analyze ; flutter test
```
Expected: analyze 무이슈, 전체 테스트 green(가드는 SAA 미등록이라 영향 없음).

---

## Phase 3 — 부트스트랩 + 첫 학습문서 + 노출 활성

첫 문서를 등록하는 순간 SAA가 "학습문서만" 상태가 되어 가드가 실제로 작동한다. 기존 SAA-하드코딩 테스트도 여기서 동기화한다.

### Task 7: 첫 학습문서 작성 (saa-t1-1)

> **성격:** 이 태스크의 산출물(한국어 본문)은 files.zip 초안 + AWS 공식 문서 대조로 *실행 중* 생성한다. 플랜은 파일 경로·프런트매터 스키마·섹션 골격·출처 규율을 고정한다. 본문 산문을 발명하지 않는다.

**Files:**
- Create: `flutter_app/assets/content/saa/saa-t1-1.md`
- Read: `D:\Download\saa_src\` 해당 Phase/Step(매핑에서 확정), AWS 공식 문서

- [ ] **Step 1: saa/ 디렉터리 + 첫 문서 작성**

`assets/content/saa/saa-t1-1.md`를 표준 템플릿(`assets/content/clf/t1-1.md` 정본)으로 작성. 프런트매터(매핑에서 확정한 제목·Task로 채움):
```yaml
---
examGuideTaskId: saa-t1-1
certCode: SAA-C03
domain: 1
domainName: 보안 아키텍처 설계
domainWeightPct: 30
title: (매핑에서 확정한 제목 — 예: IAM과 보안 액세스 설계)
coversTasks:
  - "1.1"
sources:
  - title: (공식 문서 제목)
    url: https://docs.aws.amazon.com/...
lastVerified: 2026-06-07
---
```
본문 6섹션: `✅ 학습 목표 체크리스트 → 🎯 왜 중요한가 → 📖 핵심 개념(표/코드) → ✍️ 시험 포인트 → ⚠️ 흔한 함정 → 🧪 자가 점검(<details> 토글) → 📌 출처`. 마크다운 파서 지원 블록만 사용(heading 1~3·문단·불릿·번호·체크리스트·표·인용·코드·`<details>`·구분선). **DIO 면접 등 개인 취업 맥락 섹션 제외.** 사실 진술은 공식 문서로 대조하고 `sources[]`에 URL 기록.

- [ ] **Step 2: 커밋(문서 단독)**

```bash
git -C D:/workspace/awc-docs add flutter_app/assets/content/saa/saa-t1-1.md
git -C D:/workspace/awc-docs commit -m "content: SAA-C03 학습문서 saa-t1-1 — (제목)"
```

### Task 8: 부트스트랩 + content_index 등록 (노출 활성)

**Files:**
- Modify: `flutter_app/pubspec.yaml` (`assets:` 섹션)
- Modify: `flutter_app/lib/data/content_index.dart` (`kContentIndex`)

- [ ] **Step 1: pubspec 에셋 디렉터리 등록**

`flutter_app/pubspec.yaml`의 `assets:` 블록(현재 `- assets/content/clf/` 포함)에 한 줄 추가:
```yaml
  assets:
    - assets/exam_guides/
    - assets/exam_summaries.json
    - assets/content/clf/
    - assets/content/saa/
```

- [ ] **Step 2: content_index에 SAA 키 + 첫 항목 등록**

`lib/data/content_index.dart`의 `kContentIndex` 맵에 CLF 리스트 뒤로 추가:
```dart
  'SAA-C03': [
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t1-1',
      title: '(saa-t1-1.md의 title과 동일)',
      domain: 1,
      mdAsset: 'assets/content/saa/saa-t1-1.md',
      questionsAsset: 'assets/content/saa/saa-t1-1.questions.json',
      questionCount: 0,
    ),
  ],
```
`questionsAsset`은 아직 파일이 없어도 무방(런타임 로드 실패는 try/catch로 흡수, 문항 0). `questionCount: 0`이 노출 가드의 신호.

- [ ] **Step 3: pub get + 빌드 확인**

```powershell
cd D:\workspace\awc-docs\flutter_app ; flutter pub get ; flutter analyze
```
Expected: 무이슈.

- [ ] **Step 4: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/pubspec.yaml flutter_app/lib/data/content_index.dart
git -C D:/workspace/awc-docs commit -m "feat: SAA-C03 부트스트랩 — pubspec 에셋·content_index 등록(문항 0)"
```

### Task 9: 기존 SAA-하드코딩 테스트 동기화

**Files:**
- Modify: `flutter_app/test/content_index_test.dart`
- Modify: `flutter_app/test/home_sections_test.dart`

- [ ] **Step 1: content_index_test 수정**

SAA가 이제 콘텐츠 보유이므로 "빈 cert" 예시를 미등록 코드로 교체한다. 현재:
```dart
  test('certHasContent: CLF-C02 true, 미보유/미지정 false', () {
    expect(certHasContent('CLF-C02'), isTrue);
    expect(certHasContent('SAA-C03'), isFalse);
    expect(certHasContent('NOPE'), isFalse);
  });
```
교체:
```dart
  test('certHasContent: 콘텐츠 보유 true, 미보유/미지정 false', () {
    expect(certHasContent('CLF-C02'), isTrue);
    expect(certHasContent('DVA-C02'), isFalse);
    expect(certHasContent('NOPE'), isFalse);
  });

  test('SAA-C03: 학습문서 보유하나 문항은 0(학습문서만 상태)', () {
    expect(certHasContent('SAA-C03'), isTrue);
    expect(certHasVerifiedQuestions('SAA-C03'), isFalse);
    expect(certContentSummary('SAA-C03').questions, 0);
    expect(certContentSummary('SAA-C03').docs, greaterThan(0));
  });
```
그리고 기존 `'certContentSummary: 콘텐츠 없는 cert는 0'` 테스트의 `'SAA-C03'`을 `'DVA-C02'`로 교체:
```dart
  test('certContentSummary: 콘텐츠 없는 cert는 0', () {
    final s = certContentSummary('DVA-C02');
    expect(s.docs, 0);
    expect(s.questions, 0);
  });
```

- [ ] **Step 2: home_sections_test 수정**

SAA는 더 이상 "준비 중"이 아니다. 현재:
```dart
    expect(find.text('SAA-C03'), findsWidgets);
```
을 미등록 코드로 교체(여전히 "준비 중" 그룹에 있는 자격증):
```dart
    expect(find.text('DVA-C02'), findsWidgets);
```

- [ ] **Step 3: 학습문서만 노출 위젯 테스트 추가**

`test/home_sections_test.dart`의 `main()`에 테스트 추가(SelectionArea 함정 회피 위해 홈만 렌더, 라우팅 진입 안 함):
```dart
  testWidgets('학습문서만 cert(SAA): 학습 섹션 노출 + 문항 준비 중 라벨', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();

    // 문항 0 cert는 '문항 준비 중' 라벨로 학습문서 섹션에 노출.
    expect(find.textContaining('문항 준비 중'), findsWidgets);
  });
```

- [ ] **Step 4: 전체 테스트 통과 확인**

```powershell
cd D:\workspace\awc-docs\flutter_app ; flutter analyze ; flutter test
```
Expected: analyze 무이슈, 전체 green.

- [ ] **Step 5: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/test/content_index_test.dart flutter_app/test/home_sections_test.dart
git -C D:/workspace/awc-docs commit -m "test: SAA 학습문서만 상태 동기화 — 하드코딩 교체 + 노출 검증"
```

### Task 10: 실브라우저 도그푸드 + 배포

- [ ] **Step 1: 웹 빌드**

```powershell
cd D:\workspace\awc-docs\flutter_app ; flutter build web --release --base-href /aws-docs/
```
Expected: 빌드 성공. (Git Bash 금지 — `--base-href` 망가짐.)

- [ ] **Step 2: 육안 확인 항목**

`flutter run -d chrome`(또는 빌드 산출물)으로:
- 홈 "상세 학습 문서" 섹션에 SAA-C03 카드 + "학습문서 1 · 문항 준비 중" 라벨.
- 홈 "모의고사" 섹션에 SAA **미노출**(약점 게이트 줄도 없음).
- `/cert/SAA-C03` 진입: 학습문서 링크 표시, "검증 문항 N" 배지·약점 리포트·약점 모의고사 카드 **미노출**, 한국어 요약 블록 표시.
- `saa-t1-1` 학습문서 렌더(6섹션·`<details>` 토글) 정상.

- [ ] **Step 3: main push(자동 배포)**

```bash
git -C D:/workspace/awc-docs push origin main
```
GitHub Actions가 Pages로 자동 배포.

---

## Phase 4 — 나머지 학습문서 생산 (반복)

### Task 11: 매핑 표의 각 행을 학습문서로 (Task 7~8 절차 반복)

매핑 표(`saa-c03-task-mapping.md`)의 `saa-t1-1`을 제외한 모든 행에 대해 **Task 7 Step 1(문서 작성) → Task 8 Step 2(content_index 등록, `questionCount: 0`) → 커밋**을 반복한다. 문서 묶음마다 다음을 수행:

- [ ] **Step 1: 도메인 단위로 배치 진행**

권장 순서: D1 보안(30%) → D2 복원력(26%) → D3 고성능(24%) → D4 비용(20%)(비중 큰 순). 한 문서 = Task 7 Step 1 템플릿 + 출처 대조 + content_index 1줄(`questionCount: 0`).

- [ ] **Step 2: 문서 묶음마다 검증**

```powershell
cd D:\workspace\awc-docs\flutter_app ; flutter analyze ; flutter test
```
Expected: 무이슈·green. `content_index`의 `title`이 `.md` 프런트매터 `title`과 일치하는지 확인.

- [ ] **Step 3: 매핑 표 진척 갱신 + 커밋**

각 문서 완료 시 `saa-c03-task-mapping.md`의 상태를 ☑로 갱신. 문서(+등록+진척)를 함께 커밋:
```bash
git -C D:/workspace/awc-docs add flutter_app/assets/content/saa/ flutter_app/lib/data/content_index.dart docs/plans/saa-c03-task-mapping.md
git -C D:/workspace/awc-docs commit -m "content: SAA-C03 학습문서 saa-tX-Y — (제목)"
```

- [ ] **Step 4: 묶음마다 빌드·배포**

도메인 또는 적당한 묶음 단위로 Task 10(빌드→도그푸드→push)을 반복해 점진 배포.

- [ ] **Step 5: 완료 확인**

매핑 표 전 행이 ☑이고, 홈 SAA 라벨이 "학습문서 N · 문항 준비 중"(N=전체), `/cert/SAA-C03`에 전 학습문서 노출, analyze·test·build 통과, 라이브 반영.

---

## 비고 (게이트)

- **verified 문항은 본 플랜 범위 밖** — 전부 CLF 합격 후. SAA `questionCount`는 전 항목 0 유지.
- 게이트 해제 시: 각 학습문서에 `saa-tX-Y.questions.json` 작성·`verified:true` + `content_index`의 `questionCount`만 실제 수로 갱신 → 모의고사·약점 루프가 가드 전환으로 자동 활성(코드 변경 불필요). 그 작업은 별도 플랜.
