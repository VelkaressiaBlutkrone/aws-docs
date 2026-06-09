# SOA-C03 학습 콘텐츠 구성 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** SOA-C03 학습문서 20개를 SAA 패턴(문항 게이트, `questionCount:0`)으로 집필·등록해, 배포 사이트의 SOA-C03 상세 페이지에 도메인별 학습문서가 노출되게 한다.

**Architecture:** 데이터만 추가하면 기존 게이트·UI 로직이 그대로 동작한다. `content_index.dart`에 `'SOA-C03'` 20 엔트리(`questionCount:0`)를 등록하고, `assets/content/soa/`에 20개 `.md`를 SAA 템플릿으로 집필한다. 검증은 두 층 — (1) 인덱스/게이트 단위 테스트, (2) 문서 구조(7개 섹션 + Task 앵커 + 출처) 검증 테스트.

**Tech Stack:** Flutter Web (Dart), `flutter_test`, Markdown 콘텐츠, GitHub Pages.

**스펙:** `docs/superpowers/specs/2026-06-09-soa-c03-content-structure-design.md`

---

## File Structure

생성/수정 파일과 책임:

- **수정** `flutter_app/lib/data/content_index.dart` — `kContentIndex`에 `'SOA-C03'` 키 + 20 `ContentEntry`(모두 `questionCount:0`). 신규 로직 없음, 데이터만.
- **수정** `flutter_app/pubspec.yaml:65-66` 근처 — assets 목록에 `assets/content/soa/` 한 줄 추가.
- **생성** `flutter_app/assets/content/soa/soa-tN-n.md` × 20 — 학습문서 본문.
- **수정** `flutter_app/test/content_index_test.dart` — SOA 게이트 불변식 테스트 추가.
- **생성** `flutter_app/test/soa_content_structure_test.dart` — `assets/content/soa/*.md` 구조 검증.
- **생성** `docs/plans/soa-c03-task-mapping.md` — 진척표 + 분할 근거.

각 도메인 묶음이 하나의 자족적 커밋이 된다(문서 N개 + 인덱스 등록 + 구조 테스트 green).

---

## Task 1: SOA-C03 인덱스 등록 + 게이트 테스트

**Files:**
- Modify: `flutter_app/lib/data/content_index.dart`
- Modify: `flutter_app/pubspec.yaml`
- Test: `flutter_app/test/content_index_test.dart`

이 Task는 문서 파일 없이도 통과한다(인덱스만 테스트). 게이트가 SAA와 동일하게 잠기는지 고정한다.

- [ ] **Step 1: 게이트 불변식 테스트 추가 (실패 예정)**

`test/content_index_test.dart`의 `main()` 안에 추가:

```dart
  test('SOA-C03: 학습문서 20개·문항 0·게이트 잠금 (SAA와 동일 패턴)', () {
    expect(certHasContent('SOA-C03'), isTrue);
    expect(certHasVerifiedQuestions('SOA-C03'), isFalse);
    final s = certContentSummary('SOA-C03');
    expect(s.docs, 20);
    expect(s.questions, 0);
    expect(contentFor('SOA-C03').any((e) => e.hasQuestions), isFalse);
  });

  test('SOA-C03: 도메인별 문서 수 D1:5 D2:4 D3:4 D4:3 D5:4', () {
    final byDomain = <int, int>{};
    for (final e in contentFor('SOA-C03')) {
      byDomain[e.domain] = (byDomain[e.domain] ?? 0) + 1;
    }
    expect(byDomain, {1: 5, 2: 4, 3: 4, 4: 3, 5: 4});
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `cd flutter_app && flutter test test/content_index_test.dart`
Expected: FAIL — `SOA-C03` 미등록이라 `certHasContent` false, `docs`는 0.

- [ ] **Step 3: content_index.dart에 SOA-C03 20 엔트리 등록**

`kContentIndex` 맵에서 `'SAA-C03': [...]` 리스트 닫힘 `]` 뒤, 맵 닫힘 `}` 앞에 추가:

```dart
  'SOA-C03': [
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t1-1', title: 'CloudWatch 지표·경보·대시보드', domain: 1, mdAsset: 'assets/content/soa/soa-t1-1.md', questionsAsset: 'assets/content/soa/soa-t1-1.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t1-2', title: 'CloudWatch Logs·Logs Insights·구독 필터·에이전트', domain: 1, mdAsset: 'assets/content/soa/soa-t1-2.md', questionsAsset: 'assets/content/soa/soa-t1-2.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t1-3', title: 'CloudTrail·EventBridge·X-Ray (감사·이벤트·추적)', domain: 1, mdAsset: 'assets/content/soa/soa-t1-3.md', questionsAsset: 'assets/content/soa/soa-t1-3.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t1-4', title: '가용성 지표 기반 문제 식별·해결 (Health Dashboard)', domain: 1, mdAsset: 'assets/content/soa/soa-t1-4.md', questionsAsset: 'assets/content/soa/soa-t1-4.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t1-5', title: '컴퓨팅·스토리지·DB 성능 최적화 (EC2·EBS·RDS·ElastiCache)', domain: 1, mdAsset: 'assets/content/soa/soa-t1-5.md', questionsAsset: 'assets/content/soa/soa-t1-5.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t2-1', title: 'Auto Scaling·ELB로 확장성·탄력성 구현', domain: 2, mdAsset: 'assets/content/soa/soa-t2-1.md', questionsAsset: 'assets/content/soa/soa-t2-1.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t2-2', title: 'Multi-AZ·고가용성·복원력 설계', domain: 2, mdAsset: 'assets/content/soa/soa-t2-2.md', questionsAsset: 'assets/content/soa/soa-t2-2.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t2-3', title: '백업·복원 전략 (AWS Backup·스냅샷·수명주기)', domain: 2, mdAsset: 'assets/content/soa/soa-t2-3.md', questionsAsset: 'assets/content/soa/soa-t2-3.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t2-4', title: 'DR·데이터 복원력 (RTO/RPO·S3 복제)', domain: 2, mdAsset: 'assets/content/soa/soa-t2-4.md', questionsAsset: 'assets/content/soa/soa-t2-4.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t3-1', title: 'CloudFormation 프로비저닝 (템플릿·스택·StackSets·드리프트)', domain: 3, mdAsset: 'assets/content/soa/soa-t3-1.md', questionsAsset: 'assets/content/soa/soa-t3-1.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t3-2', title: 'AMI·리소스 배포·유지 관리·패치 전략', domain: 3, mdAsset: 'assets/content/soa/soa-t3-2.md', questionsAsset: 'assets/content/soa/soa-t3-2.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t3-3', title: 'Systems Manager 운영 자동화 (Run Command·Patch·State Manager·Parameter Store)', domain: 3, mdAsset: 'assets/content/soa/soa-t3-3.md', questionsAsset: 'assets/content/soa/soa-t3-3.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t3-4', title: '자동화 패턴 (EventBridge·Lambda·자동 복구)', domain: 3, mdAsset: 'assets/content/soa/soa-t3-4.md', questionsAsset: 'assets/content/soa/soa-t3-4.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t4-1', title: 'IAM·계정 보안 운영 (정책·역할·MFA·자격증명 보고서)', domain: 4, mdAsset: 'assets/content/soa/soa-t4-1.md', questionsAsset: 'assets/content/soa/soa-t4-1.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t4-2', title: '규정 준수·거버넌스 (Config·Security Hub·GuardDuty·Inspector)', domain: 4, mdAsset: 'assets/content/soa/soa-t4-2.md', questionsAsset: 'assets/content/soa/soa-t4-2.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t4-3', title: '데이터·인프라 보호 (KMS·암호화·Secrets Manager·ACM)', domain: 4, mdAsset: 'assets/content/soa/soa-t4-3.md', questionsAsset: 'assets/content/soa/soa-t4-3.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t5-1', title: 'VPC 네트워킹 구현 (서브넷·라우팅·SG·NACL·NAT)', domain: 5, mdAsset: 'assets/content/soa/soa-t5-1.md', questionsAsset: 'assets/content/soa/soa-t5-1.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t5-2', title: '하이브리드·연결 (피어링·TGW·VPN·Direct Connect·엔드포인트)', domain: 5, mdAsset: 'assets/content/soa/soa-t5-2.md', questionsAsset: 'assets/content/soa/soa-t5-2.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t5-3', title: 'Route 53 DNS·CloudFront 콘텐츠 전송', domain: 5, mdAsset: 'assets/content/soa/soa-t5-3.md', questionsAsset: 'assets/content/soa/soa-t5-3.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t5-4', title: '네트워크 문제 해결 (Flow Logs·Reachability Analyzer)', domain: 5, mdAsset: 'assets/content/soa/soa-t5-4.md', questionsAsset: 'assets/content/soa/soa-t5-4.questions.json', questionCount: 0),
  ],
```

- [ ] **Step 4: pubspec.yaml에 soa 에셋 경로 추가**

`pubspec.yaml`의 `assets:` 목록에서 `- assets/content/saa/` 다음 줄에 추가:

```yaml
    - assets/content/soa/
```

- [ ] **Step 5: soa 디렉터리 생성 (빈 빌드 깨짐 방지용 .gitkeep)**

```bash
mkdir -p flutter_app/assets/content/soa
```

> 주의: pubspec에 등록한 디렉터리가 비어 있으면 `flutter` 빌드가 경고/실패할 수 있다. Task 2에서 첫 문서를 넣기 전까지는 `flutter test`로만 검증한다(테스트는 에셋 디렉터리 비어도 통과).

- [ ] **Step 6: 테스트 통과 확인 + analyze**

Run: `cd flutter_app && flutter test test/content_index_test.dart && flutter analyze`
Expected: 모든 content_index 테스트 PASS, analyze 무경고.

- [ ] **Step 7: 커밋**

```bash
git add flutter_app/lib/data/content_index.dart flutter_app/pubspec.yaml flutter_app/test/content_index_test.dart
git commit -m "feat: SOA-C03 학습문서 20개 인덱스 등록(questionCount:0 게이트)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: 구조 검증 테스트 + 레퍼런스 문서 (soa-t1-1)

**Files:**
- Create: `flutter_app/test/soa_content_structure_test.dart`
- Create: `flutter_app/assets/content/soa/soa-t1-1.md`

첫 문서를 완성해 템플릿을 못 박고, 이후 모든 문서가 통과해야 할 구조 테스트를 만든다. 구조 테스트는 `assets/content/soa/`에 **존재하는** `.md`만 검사하므로 문서가 쌓일수록 커버리지가 는다(부분 진행도 green).

- [ ] **Step 1: 구조 검증 테스트 작성 (실패 예정 — 문서 0개라 빈 검사)**

`test/soa_content_structure_test.dart` 생성:

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SOA 학습문서가 SAA 템플릿 7개 섹션 + Task 앵커 + 출처를 갖췄는지 검증.
/// assets/content/soa/ 에 존재하는 .md 만 검사한다(점진적 집필 지원).
void main() {
  final dir = Directory('assets/content/soa');
  final mdFiles = dir.existsSync()
      ? dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .toList()
      : <File>[];

  const requiredMarkers = <String>[
    '커버하는 공식 Task',
    '## ✅ 학습 목표 체크리스트',
    '## 🎯 왜 중요한가',
    '## 📖 핵심 개념',
    '## ✍️ 시험 포인트',
    '## ⚠️ 흔한 함정',
    '## 🧪 자가 점검',
    '### 📌 출처',
  ];

  test('SOA 문서 디렉터리에 .md가 1개 이상 존재', () {
    expect(mdFiles, isNotEmpty,
        reason: 'soa-t1-1.md 부터 집필되어야 한다');
  });

  for (final f in mdFiles) {
    final name = f.uri.pathSegments.last;
    final body = f.readAsStringSync();
    test('$name: 템플릿 7개 섹션 + Task 앵커 + 출처', () {
      for (final marker in requiredMarkers) {
        expect(body.contains(marker), isTrue,
            reason: '$name 에 "$marker" 누락');
      }
    });
    test('$name: SOA-C03 Task 앵커 명시', () {
      expect(body.contains('SOA-C03'), isTrue,
          reason: '$name 머리말에 SOA-C03 Task 앵커 필요');
    });
    test('$name: 출처에 실제 AWS URL 기록', () {
      final sourceIdx = body.indexOf('### 📌 출처');
      expect(sourceIdx, greaterThan(-1));
      final sourceSection = body.substring(sourceIdx);
      expect(sourceSection.contains('https://'), isTrue,
          reason: '$name 출처 섹션에 https:// URL 필요(게이트 규율)');
    });
  }
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `cd flutter_app && flutter test test/soa_content_structure_test.dart`
Expected: FAIL — `SOA 문서 디렉터리에 .md가 1개 이상 존재`가 빈 리스트로 실패.

- [ ] **Step 3: soa-t1-1.md 집필 (레퍼런스 exemplar)**

`assets/content/soa/soa-t1-1.md` 생성. 아래 골격을 따르되, 본문은 **AWS CloudWatch 공식 문서를 열어** 정확히 채운다. `📌 출처`에는 실제로 연 문서 URL을 넣는다(예: `https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/...`).

> **컨벤션(SAA 동일, 전 SOA 문서 공통):** ① 머리말 블록쿼트는 `> **커버하는 공식 Task** — …` 굵게 형식. 구조 테스트 마커는 `커버하는 공식 Task` 문구만 보므로 굵게/일반 무관하지만 SAA와 맞춰 굵게 쓴다. ② 본문 H1 위에 SAA 프런트매터(`examGuideTaskId·certCode·domain·domainName·domainWeightPct·title·coversTasks·sources[]·lastVerified`)를 둔다. SAA 문서 `assets/content/saa/saa-t3-1.md`를 형식 기준으로 연다.

```markdown
# CloudWatch 지표·경보·대시보드

> **커버하는 공식 Task** — SOA-C03 · 도메인 1 「모니터링, 로깅, 분석, 문제 해결 및 성능 최적화」(22%) · **Task 1.1 AWS 모니터링 및 로깅 서비스를 사용하여 지표, 경보 및 필터 구현** (`soa-t1-1`)
> 이 문서는 CloudWatch의 지표·경보·대시보드에 집중합니다. 로그/감사/추적은 `soa-t1-2`, `soa-t1-3`에서 다룹니다.

## ✅ 학습 목표 체크리스트

- [ ] **지표(Metric)** — 네임스페이스·차원(Dimension)·기간(Period)·통계(Statistic)를 설명할 수 있다
- [ ] **표준 vs 고해상도 지표** — 1분/1초 해상도와 보존 기간을 구분한다
- [ ] **사용자 지정 지표** — PutMetricData로 커스텀 지표를 게시하는 경우를 안다
- [ ] **경보(Alarm)** — 임계값·평가 기간·데이터 부족(INSUFFICIENT_DATA) 처리·복합 경보를 구성할 수 있다
- [ ] **경보 작업** — SNS·Auto Scaling·EC2 작업·EventBridge 연동 대상을 안다
- [ ] **대시보드** — 교차 리전/계정 위젯과 자동 새로 고침 용도를 안다

## 🎯 왜 중요한가

(SOA 운영자가 지표·경보로 무엇을 탐지/대응하는지, 시험에서 왜 최빈출인지 2~3문단. CloudWatch가 D1의 출발점임을 명시.)

## 📖 핵심 개념

### 1) 지표의 구조 — 네임스페이스·차원·기간·통계

(공식 정의 blockquote + 표. EC2/EBS/RDS 기본 지표 예. **운영 강조**: "특정 지표를 어떻게 찾아 경보를 거는가" 절차.)

### 2) 표준 vs 고해상도 지표와 보존

(표: 해상도 → 보존 기간. 1초 고해상도 경보의 비용/용도.)

### 3) 경보 — 임계값·평가·상태 전이

(상태 OK/ALARM/INSUFFICIENT_DATA, 평가 기간 M of N, missing data 처리.
**운영 강조 절차**: 경보 생성 → 작업 연결 → 테스트 순서.)

### 4) 복합 경보와 경보 작업 대상

(복합 경보 AND/OR, SNS/Auto Scaling/EC2 복구 작업 연결.)

### 5) 대시보드

(위젯 종류, 교차 계정·리전, 자동 새로 고침.)

## ✍️ 시험 포인트

- (자주 나오는 판별 포인트들. 예: "데이터 부족 시 경보 동작", "고해상도 경보 최소 10초")

## ⚠️ 흔한 함정

- (예: 차원이 다르면 다른 지표다 / 사용자 지정 지표 게시 비용 / 경보는 리전 단위)

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

1. **Q.** EC2 기본 모니터링과 세부 모니터링의 지표 전송 주기 차이는?
   <details><summary>정답</summary>기본 5분, 세부 1분.</details>
2. **Q.** 경보가 데이터를 받지 못할 때 기본 상태는?
   <details><summary>정답</summary>INSUFFICIENT_DATA(설정에 따라 처리 방식 지정 가능).</details>

### 📌 출처 (verified)

- Amazon CloudWatch User Guide — Using metrics: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html
- Using alarms: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html
- (집필 시 실제로 연 공식 문서 URL을 추가)
```

> 괄호 `()` 안내문은 **실제 본문으로 교체**해 집필한다. 빈 괄호 안내문을 그대로 두지 말 것. SAA 문서(`assets/content/saa/saa-t3-1.md`, ~280줄)를 분량·밀도 기준으로 삼는다.

- [ ] **Step 4: 구조 테스트 통과 확인**

Run: `cd flutter_app && flutter test test/soa_content_structure_test.dart`
Expected: PASS — `soa-t1-1.md`가 8개 마커 + SOA-C03 + https URL 모두 포함.

- [ ] **Step 5: 첫 문서 렌더 확인(선택, 권장)**

`flutter run -d chrome` 후 `#/cert/SOA-C03` 진입 → 학습문서 목록에 soa-t1-1 노출, 클릭 시 마크다운 렌더 확인.

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/test/soa_content_structure_test.dart flutter_app/assets/content/soa/soa-t1-1.md
git commit -m "feat: SOA-C03 레퍼런스 학습문서(soa-t1-1) + 구조 검증 테스트

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: D1 나머지 문서 (soa-t1-2 ~ soa-t1-5)

**Files:**
- Create: `flutter_app/assets/content/soa/soa-t1-2.md`
- Create: `flutter_app/assets/content/soa/soa-t1-3.md`
- Create: `flutter_app/assets/content/soa/soa-t1-4.md`
- Create: `flutter_app/assets/content/soa/soa-t1-5.md`

Task 2의 `soa-t1-1.md` 구조를 **그대로** 따른다(7개 섹션 + Task 앵커 + 출처). 각 문서가 다룰 범위:

- **soa-t1-2** (Task 1.1) — CloudWatch Logs: 로그 그룹/스트림, 보존, 지표 필터(Metric Filter), 구독 필터, Logs Insights 쿼리, **CloudWatch agent**(EC2/ECS/EKS 설치·구성). 운영 강조: 에이전트 구성 파일 작성 순서.
- **soa-t1-3** (Task 1.1) — CloudTrail(관리/데이터 이벤트, 다중 리전 추적, Insights), EventBridge(규칙·대상·스케줄), X-Ray(분산 추적·서비스 맵). 감사·이벤트·추적 묶음.
- **soa-t1-4** (Task 1.2) — 가용성 지표 기반 문제 식별·해결: AWS Health Dashboard(서비스/계정), 경보 기반 대응 흐름, 상태 점검(EC2 status checks·ELB health). 운영 강조: 장애 탐지→격리 절차.
- **soa-t1-5** (Task 1.3) — 성능 최적화: EC2(인스턴스 타입·크레딧), EBS(볼륨 타입·IOPS/처리량·버스트), RDS(파라미터·읽기 전용 복제본), ElastiCache(캐싱 전략). 컴퓨팅·스토리지·DB 묶음.

- [ ] **Step 1: 4개 문서 집필**

각 문서를 위 범위로 집필. SAA 밀도(~200~280줄), `📌 출처`에 실제 AWS 공식 문서 URL. soa-t1-1.md를 형식 참조로 연다.

- [ ] **Step 2: 구조 테스트 통과 확인**

Run: `cd flutter_app && flutter test test/soa_content_structure_test.dart`
Expected: PASS — 이제 5개 문서(soa-t1-1~5) 각각에 대해 마커/앵커/URL 테스트 통과.

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/assets/content/soa/soa-t1-2.md flutter_app/assets/content/soa/soa-t1-3.md flutter_app/assets/content/soa/soa-t1-4.md flutter_app/assets/content/soa/soa-t1-5.md
git commit -m "content: SOA-C03 도메인1 학습문서 4개(모니터링·로깅·성능)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: D5 네트워킹 문서 (soa-t5-1 ~ soa-t5-4)

**Files:**
- Create: `flutter_app/assets/content/soa/soa-t5-1.md` ~ `soa-t5-4.md`

생산 순서상 D5를 먼저(SAA 네트워킹 자산과 겹쳐 빠름). 각 문서 범위:

- **soa-t5-1** (Task 5.1) — VPC 구현: 서브넷(퍼블릭/프라이빗), 라우팅 테이블, 보안 그룹 vs NACL(stateful/stateless), NAT Gateway/Instance, 인터넷 게이트웨이.
- **soa-t5-2** (Task 5.1) — 하이브리드·연결: VPC 피어링, Transit Gateway, Site-to-Site VPN, Direct Connect, VPC 엔드포인트(Gateway/Interface·PrivateLink).
- **soa-t5-3** (Task 5.2) — Route 53(호스팅 영역, 레코드, 라우팅 정책 7종, 상태 확인), CloudFront(배포·오리진·캐시 동작·OAC), S3 정적 호스팅.
- **soa-t5-4** (Task 5.3) — 네트워크 문제 해결: VPC Flow Logs(필드 해석), Reachability Analyzer, 연결 실패 진단 순서(SG→NACL→라우팅→DNS). 운영 강조 진단 흐름.

- [ ] **Step 1: 4개 문서 집필** (soa-t1-1.md 형식, SAA 밀도, 실제 출처 URL)

- [ ] **Step 2: 구조 테스트 통과 확인**

Run: `cd flutter_app && flutter test test/soa_content_structure_test.dart`
Expected: PASS — 9개 문서 통과.

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/assets/content/soa/soa-t5-1.md flutter_app/assets/content/soa/soa-t5-2.md flutter_app/assets/content/soa/soa-t5-3.md flutter_app/assets/content/soa/soa-t5-4.md
git commit -m "content: SOA-C03 도메인5 학습문서 4개(네트워킹·콘텐츠 전송)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: D2 신뢰성 문서 (soa-t2-1 ~ soa-t2-4)

**Files:**
- Create: `flutter_app/assets/content/soa/soa-t2-1.md` ~ `soa-t2-4.md`

- **soa-t2-1** (Task 2.1) — Auto Scaling 그룹(시작 템플릿, 스케일링 정책: 타깃 추적/단계/예약, 쿨다운, 수명 주기 후크), ELB(ALB/NLB/GLB 선택, 대상 그룹, 상태 확인) 연동.
- **soa-t2-2** (Task 2.2) — 고가용성: Multi-AZ 배포(RDS·ELB·NAT), 단일 실패점 제거, Route 53 장애 조치 라우팅, 가용성 설계 원칙.
- **soa-t2-3** (Task 2.3) — 백업: AWS Backup(백업 계획·볼트·교차 리전/계정), EBS 스냅샷(DLM 수명 주기), RDS 자동/수동 백업, S3 버전 관리·수명 주기.
- **soa-t2-4** (Task 2.3) — DR·복원력: RTO/RPO 정의, DR 전략 4종(Backup&Restore·Pilot Light·Warm Standby·Multi-Site), S3 교차 리전 복제(CRR). 운영 강조: 복원 절차·검증.

- [ ] **Step 1: 4개 문서 집필**

- [ ] **Step 2: 구조 테스트 통과 확인**

Run: `cd flutter_app && flutter test test/soa_content_structure_test.dart`
Expected: PASS — 13개 문서 통과.

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/assets/content/soa/soa-t2-1.md flutter_app/assets/content/soa/soa-t2-2.md flutter_app/assets/content/soa/soa-t2-3.md flutter_app/assets/content/soa/soa-t2-4.md
git commit -m "content: SOA-C03 도메인2 학습문서 4개(신뢰성·비즈니스 연속성)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: D3 배포·자동화 문서 (soa-t3-1 ~ soa-t3-4)

**Files:**
- Create: `flutter_app/assets/content/soa/soa-t3-1.md` ~ `soa-t3-4.md`

- **soa-t3-1** (Task 3.1) — CloudFormation: 템플릿 구조(Resources·Parameters·Mappings·Outputs), 스택/중첩 스택, StackSets(다중 계정/리전), 변경 세트, 드리프트 감지.
- **soa-t3-2** (Task 3.1) — AMI(생성·공유·암호화·EC2 Image Builder), 리소스 배포·유지 관리, 패치 전략 개요(Patch Manager 베이스라인).
- **soa-t3-3** (Task 3.2) — Systems Manager: Run Command, Patch Manager, State Manager, Parameter Store(vs Secrets Manager), Session Manager, Automation 런북.
- **soa-t3-4** (Task 3.2) — 자동화 패턴: EventBridge 규칙→Lambda 자동 복구, Auto Scaling 자동 교체, 이벤트 기반 운영 자동화. 운영 강조: 자동 교정 파이프라인.

- [ ] **Step 1: 4개 문서 집필**

- [ ] **Step 2: 구조 테스트 통과 확인**

Run: `cd flutter_app && flutter test test/soa_content_structure_test.dart`
Expected: PASS — 17개 문서 통과.

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/assets/content/soa/soa-t3-1.md flutter_app/assets/content/soa/soa-t3-2.md flutter_app/assets/content/soa/soa-t3-3.md flutter_app/assets/content/soa/soa-t3-4.md
git commit -m "content: SOA-C03 도메인3 학습문서 4개(배포·프로비저닝·자동화)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: D4 보안 문서 (soa-t4-1 ~ soa-t4-3)

**Files:**
- Create: `flutter_app/assets/content/soa/soa-t4-1.md` ~ `soa-t4-3.md`

- **soa-t4-1** (Task 4.1) — IAM 운영: 정책 유형(관리형/인라인/권한 경계), 역할·교차 계정, MFA, 자격 증명 보고서·액세스 분석기, Organizations·SCP 개요.
- **soa-t4-2** (Task 4.1) — 규정 준수·거버넌스: AWS Config(규칙·교정), Security Hub(표준·점수), GuardDuty(위협 탐지), Inspector(취약점), Trusted Advisor.
- **soa-t4-3** (Task 4.2) — 데이터·인프라 보호: KMS(키 유형·교체·정책), 암호화(저장/전송), Secrets Manager(교체), ACM(인증서), S3 암호화·SG/NACL 보호.

- [ ] **Step 1: 3개 문서 집필**

- [ ] **Step 2: 구조 테스트 통과 확인**

Run: `cd flutter_app && flutter test test/soa_content_structure_test.dart`
Expected: PASS — 20개 문서 전부 통과.

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/assets/content/soa/soa-t4-1.md flutter_app/assets/content/soa/soa-t4-2.md flutter_app/assets/content/soa/soa-t4-3.md
git commit -m "content: SOA-C03 도메인4 학습문서 3개(보안·규정 준수)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: 최종 인수 검증 + 매핑 문서

**Files:**
- Modify: `flutter_app/test/soa_content_structure_test.dart`
- Create: `docs/plans/soa-c03-task-mapping.md`

20개 문서가 모두 존재하고 인덱스와 1:1로 맞는지 고정하고, 진척 문서를 남긴다.

- [ ] **Step 1: 인덱스↔파일 1:1 인수 테스트 추가**

`test/soa_content_structure_test.dart`의 `main()` 끝에 추가:

```dart
  test('인수: 인덱스 20 엔트리의 mdAsset 파일이 모두 존재', () {
    // content_index의 SOA 엔트리 경로가 실제 파일과 일치하는지.
    final expected = List.generate(5, (d) => d + 1)
        .expand((d) {
          const counts = {1: 5, 2: 4, 3: 4, 4: 3, 5: 4};
          return List.generate(
              counts[d]!, (i) => 'assets/content/soa/soa-t$d-${i + 1}.md');
        })
        .toList();
    for (final path in expected) {
      expect(File(path).existsSync(), isTrue, reason: '$path 누락');
    }
    expect(expected.length, 20);
  });
```

- [ ] **Step 2: 전체 테스트 + analyze**

Run: `cd flutter_app && flutter test && flutter analyze`
Expected: 전체 PASS, analyze 무경고.

- [ ] **Step 3: 매핑 문서 작성**

`docs/plans/soa-c03-task-mapping.md` 생성. `docs/plans/saa-c03-task-mapping.md`와 동일 양식:
- 머리말(식별자 규칙 `soa-t{D}-{n}`, `coversTasks` 정의, 문항은 CLF 후 단계, `questionCount:0` 등록)
- 도메인 표(D1~D5, 비중, 공식 Task)
- 학습문서 진척표 20행(taskId·제목·domain·coversTasks·**1차 출처(AWS 공식 문서)**·상태 ☑)
- 생산 순서 기록(D1→D5→D2→D3→D4)
- "files.zip 없음 — 전부 공식 문서 신규 집필" 명시

- [ ] **Step 4: 배포 전 로컬 렌더 확인**

`flutter run -d chrome` → `#/cert/SOA-C03`:
- 학습문서 20개가 도메인별로 노출되는가
- 모의고사/약점 리포트 진입 시 잠금(문항 0)인가
- 임의 문서 클릭 시 마크다운 정상 렌더 + 출처 링크

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/test/soa_content_structure_test.dart docs/plans/soa-c03-task-mapping.md
git commit -m "test+docs: SOA-C03 인덱스↔파일 인수 검증 + Task 매핑 진척 문서

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Self-Review (작성자 체크)

**Spec coverage:**
- 20문서 분할안 → Task 1(등록) + Task 2~7(집필). ✅
- SAA 패턴 `questionCount:0` 게이트 → Task 1 테스트로 고정. ✅
- 템플릿 7개 섹션 + 운영 강조 → Task 2 exemplar + Task 3~7 범위. ✅
- files.zip 없음·출처 URL 규율 → 구조 테스트의 `https://` 검사(Task 2) + 매핑 문서(Task 8). ✅
- content_index/pubspec/매핑 문서 산출물 → Task 1·8. ✅
- 생산 순서 D1→D5→D2→D3→D4 → Task 3~7 순서. ✅
- 게이트 동작(기존 로직 재사용) → Task 1·8 테스트. ✅
- 성공 기준(20문서·analyze·노출·잠금·매핑) → Task 8. ✅

**Placeholder scan:** 문서 본문은 집필 작업이라 골격+범위로 지정(괄호 안내문은 "실제 본문으로 교체" 명시). 코드/테스트/명령은 전부 실제 내용. ✅

**Type consistency:** `ContentEntry`/`certHasContent`/`certHasVerifiedQuestions`/`certContentSummary`/`hasQuestions`·`questionCount`·`domain` — 기존 소스(`content_index.dart`)와 일치. 파일 경로 `assets/content/soa/soa-tN-n.md` 전 Task 동일. ✅
