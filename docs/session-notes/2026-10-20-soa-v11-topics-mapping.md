# SOA-C03 v1.1 신규 주제 → 기존 학습문서 매핑 (1단계 산출물)

작성 세션: agitated-leakey-da4c55 (feat/2026-10-20-soa-v11-topics 예정)
작성일: 2026-10-20

## 범위 판정 근거 (실측)

핸드오프가 예시로 든 6개(S3 Files·DR 4전략·Organizations/SCP·Config 적합성 팩·VPC 엔드포인트·EventBridge)는
**불완전**했다. 갭 노트·diff 노트를 실측한 결과 「v1.1 신규 주제」의 정본은 두 갈래다.

- `97-guide-v11-diff.md` §0 — **공식 Revisions 표의 Skill 변경 10건**:
  1.1.1 · 1.2.1 · 1.3.4 · 2.3.4 · 3.1.2 · 3.2.2 · 4.1.3 · 4.1.5 · 4.2.5 · 5.1.2
  (기계 비교로 "표 밖의 숨은 실질 변경은 없다"고 확인됨)
- `97-guide-v11-diff.md` §4.1 — **in-scope 서비스 추가 5건**:
  Amazon Bedrock · AWS DevOps Agent · AWS Health Dashboard · Kiro · AWS Security Agent

`98-existing-gap.md` §4가 각 항목의 기존 문서 커버 상태를 판정해 둔다. 그 판정에서
「없음 / 부분 / 구식」인 것만 이번 작업 대상이다.

## 매핑 표 (13항목 · 10문서)

| # | v1.1 근거 | 신규 주제 | 갭 판정 | 대상 문서 | 위치 |
|---|---|---|---|---|---|
| 1 | Skill 1.1.1 | 서버리스(Lambda)·AI(Bedrock) **지표** | 부분/없음 | soa-t1-1 | `### 2)` 뒤 신설 |
| 2 | Skill 1.1.1 | 서버리스(Lambda)·AI(Bedrock) **로깅** | 부분/없음 | soa-t1-2 | `### 7) EMF` 뒤 신설 |
| 3 | Skill 1.2.1 | Kiro · AWS DevOps Agent | 없음 | soa-t1-4 | `### 6)` 뒤 신설 |
| 4 | Skill 1.3.4 | Amazon S3 Files (EFS·FSx 비교축) | 없음 | soa-t1-5 | `### 4)` 뒤 신설 |
| 5 | Skill 2.3.4 | DR 모범 사례 ①IaC 재배포 ②data plane ③정기 테스트 | ①②없음 ③부분 | soa-t2-4 | `### 7)` 뒤 신설 |
| 6 | Skill 3.1.2 | AWS CDK (synth·bootstrap·diff) | 없음 | soa-t3-1 | `### 7)` 뒤 신설 |
| 7 | Skill 3.2.2 | EventBridge 보강(예약규칙 legacy·Scheduler·대상 5개) | 부분/구식 | soa-t3-4 | `### 1)`·`### 2)` 보강 |
| 8 | Skill 3.2.2 | AWS DevOps Agent 이벤트 연동 | 없음 | soa-t3-4 | `### 7)` 뒤 신설 |
| 9 | Skill 4.1.3 | Organizations·SCP 평가모델·IAM Identity Center | 부분/이름만 | soa-t4-1 | `### 7)` 뒤 신설 |
| 10 | Skill 4.1.5 | AWS Config 규정 준수 팩(KO 공식명)·집계자·트리거 | 있음(명칭상이) | soa-t4-2 | `### 1)` 보강 + 신설 |
| 11 | Skill 4.1.5 | 리전·서비스 선택(aws:RequestedRegion) | 거의 없음 | soa-t4-2 | #10 신설 절 안 |
| 12 | Skill 4.2.5 | AWS Security Agent | 없음 | soa-t4-2 | 신설 |
| 13 | Skill 5.1.2 | VPC 엔드포인트 보강·PrivateLink 제공자측·피어링 | 부분 | soa-t5-2 | `### 5)` 보강 + 신설 |

in-scope 신규 5건 커버: Bedrock→#1·#2 / DevOps Agent→#3·#8 / Kiro→#3 / Security Agent→#12 /
Health Dashboard→**이미 있음**(soa-t1-4 §1·§2, 갭노트 P2 B3 「있음」).

## 제외 항목과 사유

- **AWS Health Dashboard 명칭 보정**(C25·C26·C28) — 신규 주제가 아니라 구식 사실 정정. 별 트랙.
- **1.2.1 삭제분**(AWS User Notifications·auto scaling) — 삭제는 신규 주제 아님. auto scaling 내용은
  2.1·3.2 맥락에서 그대로 유효(갭노트 P2 B6).
- **2.3.4 DR 전략 4종 본체** — 갭노트 P3 B1~B5가 「충분」 판정(soa-t2-4 L85-120에 4전략 표·Pilot vs Warm 구분
  이미 있음). 부족한 쪽은 '모범 사례'뿐 → #5만.
- **1.1.1 컴퓨팅(EC2)** — 「충분」(soa-t1-1 L127-134).
- **표기만 바뀐 Skill 7건 + KO 번역 20건** — 가이드 JSON 문구이고 PR#136에서 이미 반영. 본문 주제 아님.
- **갭노트 §5 구식 36건·의심 48건** — v1.1 신규 주제가 아닌 별 트랙. `[의심]`은 공식 확인 없으면 손대지 않음.

## 공식 출처 사전 확인 (신규 제품 4종, 2026-10-20 조회)

갭 노트가 「출제 형태 불명」으로 남긴 제품들이 공식 문서로 실재하는지 먼저 확인했다.

- **Amazon S3 Files** — https://aws.amazon.com/s3/features/files/ ·
  https://docs.aws.amazon.com/help-panel/AmazonS3/latest/console/hp-s3-files-page.html
  (NFSv4.x, S3 Versioning 필수, 충돌 시 버킷이 source of truth, 미사용 데이터 제거)
- **AWS DevOps Agent** — https://docs.aws.amazon.com/devopsagent/latest/userguide/about-aws-devops-agent.html
  (Agent Space, 토폴로지 지식 그래프, 릴리스 준비성 검토·사고 조사)
- **Kiro** — https://aws.amazon.com/q/developer/faqs/ (Q Developer 기술 기반 spec-driven 개발 경험)
- **AWS Security Agent** — https://aws.amazon.com/security-agent/ ·
  https://docs.aws.amazon.com/securityagent/latest/userguide/
  공식 제목에 **"(now part of AWS Continuum)"** 병기 — 갭노트 P5-G08 확인됨.

## 테스트 가드 설계

새 파일 `flutter_app/test/soa_v11_topics_test.dart`.
`soa_facts_test.dart`의 idiom 그대로: `doc(id)` 헬퍼 + 근거 주석(공식 영문 ≤15단어) +
「구식 서술 없다(isFalse) + 공식 사실 있다(isTrue)」 쌍 단정. 그룹 접두는 `V-N`.

주의: `soa_facts_test.dart` 마지막 그룹이 soa-t1-5·t2-4·t4-2·t4-3·t5-4의
`lastVerified: 2026-10-19`를 고정한다. 이번에 t1-5·t2-4·t4-2를 건드리므로 lastVerified를
2026-10-20으로 올리면 그 테스트가 깨진다 → 같은 PR에서 그 단정을 문서별로 갱신해야 한다.

## 비범위 (건드리지 않음)

`.questions.json` 300개 드래프트(전부 verified:false) · content_index의 questionCount: 0.

---

## 결과 (2026-10-20 완료)

**PR #159** — https://github.com/VelkaressiaBlutkrone/aws-docs/pull/159
브랜치 `feat/2026-10-20-soa-v11-topics` → base `develop` (커밋 0780406). 머지 안 함(사용자 몫).

- 13항목 전부 반영, **10문서 + 신설 절 11개**. 매핑표 그대로.
- **설계 조정**: 문서 내부 `(원리: §N — …)` 참조 때문에 중간 삽입 대신 **핵심 개념 맨 끝에 다음 번호로** 추가.
- 신규 가드 `flutter_app/test/soa_v11_topics_test.dart` (V-1~V-15, 35 테스트).
- 게이트 실측: **flutter test 1,170 그린** (base develop 기준선 1,135 + 35) · **analyze 0건**.

### 다음 세션이 알아야 할 함정 3건

1. **부분 문자열 가드가 부정형을 잡는다.** `contains('X는 Y를 대체')`는 본문의 "대체하지 않습니다"까지
   true로 만든다. 긍정 오류문(`'…대체합니다'`)만 막고, 올바른 부정형이 있는지를 isTrue로 따로 단정해야 한다.
2. **`content_enrichment_test.dart`가 핵심 개념 서브섹션마다 `> 🧠 원리:` 블록을 요구한다**
   (하한 = min(서브섹션, 8)). 절을 신설하면 이 가드가 깨진다 — 관례대로 원리 블록을 같이 써야 한다.
3. **`적합성 팩` → `규정 준수 팩` 정정은 .md에만 적용했다.** `soa-t4-2.questions.json`·
   `soa-t5-4.questions.json`의 드래프트 문항은 여전히 구 명칭이다(전부 verified:false, 노출 0).
   사람 검수·flip 시점에 함께 정리할 항목 — PR #159 본문에도 적어 뒀다.

### 본문에 쓰지 않은 주장 (공식 근거 미확보)

CDK `CDKToolkit` 스택 이름 · `cdk drift` · DevOps Agent 이벤트 소스 문자열 `aws.aidevops` ·
Kiro 3형태(IDE/CLI/Crew, 블로그만) · IAM Identity Center SCIM. 전부 PR 본문 "확인 못 한 주장"에 기록.

### 기준선 주의

이 PR의 1,135는 **base develop 실측**이다. 병렬 PR #158(게이트 dead code 제거, 1,129)이 먼저
머지되면 그만큼 내려간다. 게이트는 숫자가 아니라 "전부 그린 + analyze 0".
