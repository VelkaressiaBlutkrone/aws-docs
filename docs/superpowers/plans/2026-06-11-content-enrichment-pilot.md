# 학습문서 고도화 — Plan 1: CLF 파일럿 (t1-1 + t3-1)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 스펙(`docs/superpowers/specs/2026-06-11-content-enrichment-design.md`)의 고도화 템플릿을 유형이 다른 CLF 문서 2개(t1-1 기초 개념형, t3-1 서비스 각론형)에 적용해 **본인 검수 게이트에서 템플릿을 확정**한다. 롤아웃(나머지 61개)은 게이트 통과 후 Plan 2로 작성한다.

**Architecture:** 순수 콘텐츠 작업(앱 코드 변경 0). 구조 테스트(`content_enrichment_test.dart`)를 먼저 RED로 깔고(기존 `soa_content_structure_test.dart` 패턴), 문서를 고도화해 GREEN. `lastVerified` 갱신은 **사용자 검수 후에만**(철칙: verified=사람 검수만).

**Tech Stack:** Markdown (flutter_markdown 렌더 — 표·인용·`<details>`만 사용), flutter_test(dart:io 파일 검사).

**전제:** 워킹트리 깨끗, main에 스펙 커밋(f7aeba3) 존재. 검증 명령은 모두 `flutter_app/`에서 실행.

---

### Task 1: 브랜치 생성 + 고도화 구조 테스트 (RED)

**Files:**
- Create: `flutter_app/test/content_enrichment_test.dart`

- [ ] **Step 1: 브랜치 생성**

```bash
git checkout -b feat/content-enrichment
```

- [ ] **Step 2: 실패하는 구조 테스트 작성**

`flutter_app/test/content_enrichment_test.dart` 생성:

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// 고도화 템플릿(스펙 2026-06-11-content-enrichment-design.md §4) 마커 검증.
/// 고도화 완료 문서만 목록에 올린다(점진적 롤아웃 지원 — soa_content_structure_test 패턴).
void main() {
  const enriched = <String>[
    'assets/content/clf/t1-1.md',
    'assets/content/clf/t3-1.md',
  ];

  for (final path in enriched) {
    final name = path.split('/').last;
    final body = File(path).readAsStringSync();

    test('$name: 🔤 용어 섹션이 🎯와 📖 사이에 존재', () {
      final terms = body.indexOf('## 🔤 먼저 알아야 할 용어');
      final why = body.indexOf('## 🎯 왜 중요한가');
      final concepts = body.indexOf('## 📖 핵심 개념');
      expect(terms, greaterThan(-1), reason: '$name 용어 섹션 누락');
      expect(terms, greaterThan(why), reason: '$name 용어 섹션은 🎯 뒤');
      expect(terms, lessThan(concepts), reason: '$name 용어 섹션은 📖 앞');
    });

    test('$name: 모든 개념 서브섹션에 🧠 원리 블록 ≥1', () {
      final concepts = body.substring(body.indexOf('## 📖 핵심 개념'),
          body.indexOf('## ✍️ 시험 포인트'));
      final subsections = '### '.allMatches(concepts).length;
      final principles = '> 🧠 원리:'.allMatches(concepts).length;
      expect(subsections, greaterThan(0), reason: '$name 서브섹션 파싱 실패');
      expect(principles, greaterThanOrEqualTo(subsections),
          reason: '$name 서브섹션 $subsections개 중 원리 블록 $principles개');
    });

    test('$name: 자가 점검에 원리형(왜) 문항 존재', () {
      final selfCheck = body.substring(body.indexOf('## 🧪 자가 점검'));
      final whyQ = RegExp(r'^\*\*Q\d+.*왜', multiLine: true);
      expect(whyQ.hasMatch(selfCheck), isTrue,
          reason: '$name 자가 점검에 "왜 ~인가" 원리형 문항 필요');
    });
  }
}
```

- [ ] **Step 3: RED 확인**

Run: `flutter test test/content_enrichment_test.dart -r compact`
Expected: **6개 테스트 전부 FAIL** (양 문서에 🔤 섹션·🧠 블록·원리형 문항이 아직 없음). 실패 사유가 "용어 섹션 누락" 류인지 확인 — 파싱 오류면 테스트를 고친다.

- [ ] **Step 4: 테스트만 커밋**

```bash
git add flutter_app/test/content_enrichment_test.dart
git commit -m "test(content): 고도화 템플릿 구조 테스트 (파일럿 2개, RED)"
```

---

### Task 2: t1-1 고도화 (기초 개념형 파일럿)

**Files:**
- Modify: `flutter_app/assets/content/clf/t1-1.md` (148줄 → 목표 220~260줄)

규칙(스펙 §4): 기존 내용 삭제 금지(보강만), 표는 유지, ② 원리는 산문 3~8줄, `lastVerified`는 **건드리지 않는다**(게이트 후 갱신).

- [ ] **Step 1: 🔤 용어 섹션 삽입** (`## 🎯 왜 중요한가` 섹션 끝의 `---` 다음)

초안(실행 시 다듬되 선정 기준 유지 — *전제* 용어만, 본문이 *가르치는* 리전/AZ·탄력성 등은 제외):

```markdown
## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **온프레미스** | on-premises | 회사가 *자기 건물·데이터센터*에 서버를 직접 사서 두고 운영하는 방식 |
| **프로비저닝** | provisioning | 서버·스토리지 같은 IT 자원을 *쓸 수 있게 준비·배치*하는 일 |
| **온디맨드** | on-demand | *필요한 그 순간에* 바로 받아 쓰는 방식 (수도꼭지처럼 틀면 나옴) |
| **종량 과금** | pay-as-you-go | *쓴 만큼만* 요금을 내는 과금 방식 (전기요금처럼) |
| **자본 지출** | CapEx | 서버 구매처럼 *미리 크게 한 번* 쓰는 고정 투자 비용 |
| **운영 지출** | OpEx | 매달 쓴 만큼 내는 *변동* 비용 — 클라우드 요금이 여기 속함 |
| **워크로드** | workload | 클라우드에서 돌리는 *애플리케이션·작업 덩어리*를 묶어 부르는 말 |
```

- [ ] **Step 2: 📖 핵심 개념 4개 서브섹션에 ② `> 🧠 원리:` 블록 추가** (각 서브섹션의 정의·표 **뒤**, 시험 키워드 언급 **앞**)

서브섹션별 원리 주제(초안 — 산문 3~8줄로 집필, 사실 진술은 기존 출처 범위 내):

1. **§1 클라우드 컴퓨팅이란** → 왜 "빌려 쓰기"가 가능한가: **가상화**(물리 서버 1대를 여러 가상 서버로 분할)와 **자원 풀링**이 토대 — AWS가 미리 대규모로 구축한 용량을 수많은 고객이 나눠 쓰고, 남는 용량이 다음 고객에게 재배치되는 구조라 "필요한 만큼만"이 성립.
2. **§2 핵심 이점** → 규모의 경제의 작동 원리: 고객 *개별*로는 각자 피크에 맞춰 과대 구매해야 하지만, *수많은 고객의 피크는 서로 겹치지 않아* 수요를 통합하면 평균 가동률이 올라가고 단가가 내려간다.
3. **§3 탄력성·고가용성·민첩성** → 왜 셋이 헷갈리나: 결과("좋아진다")는 같지만 **작동 축**이 다르다 — 용량 축(탄력성)·장애 축(고가용성)·시간 축(민첩성). 시나리오에서 어느 축이 문제인지 먼저 찾으면 답이 갈린다.
4. **§4 글로벌 인프라** → 왜 리전은 여러 AZ로 구성되나: AZ는 전력·냉각·네트워크가 **물리적으로 독립**된 위치라, 한 AZ의 정전·화재가 다른 AZ로 **번지지 않는다**(상관 장애 차단). 그래서 멀티 AZ 분산이 곧 고가용성이 된다.

- [ ] **Step 3: ⚠️ 흔한 함정 — 각 항목에 원리 연결**

각 함정 항목 끝에 `(원리: …)` 한 줄 연결. 예시(함정 1):

```markdown
1. **"탄력성과 고가용성은 같은 말이다."** → ❌. **탄력성 = 용량을 늘리고 줄이는 것**, **고가용성 = 장애가 나도 계속 작동하는 것**(멀티 AZ). 서로 다른 이점입니다. *(원리: §3 — 용량 축 vs 장애 축, 작동 축이 다르다.)*
```

나머지 4개 항목도 같은 형식으로 해당 🧠 원리를 가리킨다.

- [ ] **Step 4: 🧪 자가 점검에 원리형 문항 추가** (Q4 뒤)

```markdown
**Q5 (원리).** 왜 수많은 고객이 한 클라우드에 모이면 개별 구매보다 단가가 낮아질 수 있나요?

<details><summary>정답 보기</summary>

**규모의 경제** 때문입니다. 고객 각자는 자기 피크에 맞춰 용량을 과대 구매해야 하지만, 수많은 고객의 피크는 서로 겹치지 않으므로 AWS가 수요를 통합하면 같은 인프라의 평균 가동률이 올라가고, 그만큼 단위 비용이 내려갑니다.
</details>
```

- [ ] **Step 5: 부분 GREEN 확인**

Run: `flutter test test/content_enrichment_test.dart -r compact`
Expected: t1-1 3개 테스트 **PASS**, t3-1 3개 테스트 여전히 FAIL.

- [ ] **Step 6: 분량·전체 회귀 확인**

Run: `wc -l assets/content/clf/t1-1.md` → 220~260줄 범위.
Run: `flutter test -r compact` (전체) → t3-1 구조 3건 외 실패 없음.

- [ ] **Step 7: 커밋**

```bash
git add flutter_app/assets/content/clf/t1-1.md
git commit -m "feat(content): t1-1 고도화 — 용어 7개 + 원리 4블록 + 원리형 Q5 (AI 초안, 검수 전)"
```

---

### Task 3: t3-1 고도화 (서비스 각론형 파일럿)

**Files:**
- Modify: `flutter_app/assets/content/clf/t3-1.md` (169줄 → 목표 240~280줄)

규칙은 Task 2와 동일. `lastVerified` 불변.

- [ ] **Step 1: 🔤 용어 섹션 삽입** (위치 동일)

초안(t3-1이 *전제*하는 용어 — IaC·CloudFormation·하이브리드 등 본문이 *가르치는* 개념 제외):

```markdown
## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **GUI** | Graphical UI | 마우스로 클릭하는 *그래픽 화면* 인터페이스 — AWS 콘솔이 GUI |
| **API** | Application Programming Interface | 프로그램끼리 기능을 주고받는 *정해진 호출 규약* — AWS의 모든 조작이 결국 API 호출 |
| **템플릿** | template | 만들 것들을 미리 적어 둔 *설계 문서* — CloudFormation은 JSON/YAML 텍스트 |
| **리소스** | resource | EC2 인스턴스·DB처럼 AWS에 만들어지는 *개별 구성 요소* |
| **IPsec** | IP Security | 인터넷 위에서 패킷을 *암호화해 터널처럼* 보내는 표준 — Site-to-Site VPN의 기반 |
| **전용 회선** | dedicated line | 공용 인터넷과 *물리적으로 분리된* 나만 쓰는 네트워크 선 |
| **버전 관리** | version control | 텍스트의 *변경 이력*을 기록·비교·되돌리기 하는 것 (git처럼) |
```

- [ ] **Step 2: 📖 핵심 개념 5개 서브섹션에 `> 🧠 원리:` 블록 추가**

1. **§1 네 가지 방법** → 넷은 결국 **같은 API의 다른 껍데기**: 콘솔 클릭도, CLI 명령도, SDK 호출도 내부적으로는 동일한 AWS 서비스 API를 부른다 — 그래서 "CLI는 콘솔과 동등한 기능"이 성립하고, 어느 방법을 써도 같은 일을 할 수 있다.
2. **§2 IaC/CloudFormation** → **선언형**의 원리: 절차("어떻게")가 아니라 최종 상태("무엇")를 템플릿에 선언하면, CloudFormation이 현재 상태와의 차이를 계산해 실행한다 — 그래서 같은 템플릿을 반복 실행해도 같은 결과가 나오고(일관성), 텍스트라서 이력·롤백이 가능하다.
3. **§3 일회성 vs 반복** → 왜 손작업이 위험한가: 수작업은 *기록이 남지 않고 재현되지 않아* 환경마다 조금씩 달라지는 **구성 표류(drift)**가 생긴다 — 코드는 리뷰·이력·재현이 되므로 반복 작업의 기본값이 된다.
4. **§4 배포 모델** → 하이브리드가 존재하는 이유: 레거시 시스템·규제(데이터 위치)·지연 요구 때문에 *전부를 한 번에 클라우드로* 옮길 수 없는 현실 — 그래서 "둘을 어떻게 안전하게 잇나(연결)"가 하이브리드의 핵심 문제가 된다.
5. **§5 연결 옵션** → VPN vs Direct Connect 트레이드오프의 원리: VPN은 *공용 인터넷 경로*를 그대로 쓰므로 혼잡에 따라 성능이 출렁이고 암호화로 보안을 보완한다 — Direct Connect는 *경로 자체가 전용*이라 일관되지만 물리 회선 구축에 시간·비용이 든다. "빠르게·저렴하게 = VPN, 일관되게 = DX"는 이 구조의 귀결.

- [ ] **Step 3: ⚠️ 흔한 함정 — 각 항목에 `(원리: …)` 연결** (Task 2 Step 3과 동일 형식, 5개 항목)

- [ ] **Step 4: 🧪 자가 점검에 원리형 문항 추가**

```markdown
**Q5 (원리).** 왜 CloudFormation 템플릿은 여러 번 실행하거나 여러 리전에 적용해도 같은 결과를 내나요?

<details><summary>정답 보기</summary>

템플릿이 **선언형**이기 때문입니다. 절차가 아니라 *최종 상태*를 선언하므로 CloudFormation이 현재 상태와의 차이만 계산해 맞춰 줍니다. 같은 선언은 어디서 실행해도 같은 상태로 수렴하고, 텍스트라서 버전 관리·롤백도 가능합니다.
</details>
```

- [ ] **Step 5: 전체 GREEN 확인**

Run: `flutter test test/content_enrichment_test.dart -r compact`
Expected: **6개 전부 PASS**.

- [ ] **Step 6: 분량·전체 회귀 확인**

Run: `wc -l assets/content/clf/t3-1.md` → 240~280줄.
Run: `flutter test -r compact` (전체) → **All tests passed** (262 + 6 = 268).

- [ ] **Step 7: 커밋**

```bash
git add flutter_app/assets/content/clf/t3-1.md
git commit -m "feat(content): t3-1 고도화 — 용어 7개 + 원리 5블록 + 원리형 Q5 (AI 초안, 검수 전)"
```

---

### Task 4: 파일럿 검증 + 검수 게이트 자료 → **STOP**

**Files:** 없음 (검증·보고만)

- [ ] **Step 1: 최종 검증**

Run: `flutter analyze lib && flutter test -r compact`
Expected: 이슈 0, 268 전부 PASS.

- [ ] **Step 2: 검수 자료 생성**

```bash
git diff main...HEAD --stat
git log --oneline main..HEAD
```

- [ ] **Step 3: 사용자 검수 요청 — 여기서 멈춘다**

사용자에게 보고: 두 문서의 diff 요약 + 확인 포인트(용어 선정이 "전제만" 기준에 맞나, 원리 서술 깊이가 적절한가·과한가, 분량 체감, 함정-원리 연결이 자연스러운가). **사용자 피드백 전까지 Task 5 진행 금지.**

---

### Task 5 (게이트 통과 후): 피드백 반영 + lastVerified 갱신 + 머지

**Files:**
- Modify: `flutter_app/assets/content/clf/t1-1.md`, `t3-1.md` (frontmatter `lastVerified` + 출처 문구 날짜)

- [ ] **Step 1: 검수 피드백 반영** (수정 요청이 있으면 해당 문서 수정 → `flutter test` 재확인 → 수정 커밋)

- [ ] **Step 2: lastVerified 갱신** (사용자가 검수를 마쳤다고 확인한 **후에만**)

두 문서 frontmatter `lastVerified: 2026-06-06` → 검수 완료일로 갱신, 본문 끝 `📌 출처` 섹션의 "(작성·대조: …)" 날짜도 동일 갱신.

```bash
git add flutter_app/assets/content/clf/t1-1.md flutter_app/assets/content/clf/t3-1.md
git commit -m "chore(content): 파일럿 2개 lastVerified 갱신 (본인 검수 완료)"
```

- [ ] **Step 3: 템플릿 확정 기록 + Plan 2 예고**

검수에서 확정된 템플릿 조정 사항(있다면)을 스펙 §4에 반영 커밋. 이후 **Plan 2(롤아웃: CLF 17 → SAA 24 → SOA 20, cert 단위 배치)**를 작성한다 — 확정 템플릿 기준.

- [ ] **Step 4: 브랜치 마무리**

superpowers:finishing-a-development-branch 스킬로 main 병합 여부 결정(파일럿만 먼저 머지·배포해도 무해 — 콘텐츠 개선이 즉시 라이브).

---

## Self-Review 결과

- **스펙 커버리지:** §4.1(용어)=T2/T3 Step 1, §4.2(3단)=T2/T3 Step 2, §4.3(자가점검·함정·분량)=T2/T3 Step 3·4·6, §5(파일럿 게이트)=T4, 검수 루프·lastVerified 철칙=T5. 롤아웃(§5-2)은 의도적으로 Plan 2로 분리(게이트 의존).
- **플레이스홀더:** 용어 표·원리 주제·원리형 Q 모두 실초안 수록. 함정-원리 연결은 형식+완전 예시 1개(나머지는 동일 패턴 — 콘텐츠 품질은 T4 게이트가 검수).
- **타입/마커 일관성:** 테스트 마커 문자열(`## 🔤 먼저 알아야 할 용어`, `> 🧠 원리:`, `**Q\d+.*왜`)과 본문 템플릿 일치 확인.
