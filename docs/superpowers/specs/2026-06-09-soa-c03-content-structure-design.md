# SOA-C03 학습 콘텐츠 구성 설계

작성: 2026-06-09 · 브랜치: main · 상태: 설계 승인(브레인스토밍)

## 목적

SOA-C03(AWS Certified SysOps Administrator – Associate) 학습 콘텐츠를 기존
CLF-C02·SAA-C03와 **같은 방식**으로 구성한다. 이번 산출물은 **학습문서 전부 집필 + 등록**까지이며,
검증 문항(verified)은 범위 밖(CLF 합격 후 단계)이다.

### 확정된 선택 (브레인스토밍)

- **SAA 패턴**: 학습문서 본문을 전부 집필하되 `questionCount: 0`으로 등록한다.
  모의고사·오답노트·약점 리포트는 게이트(잠금)를 유지한다. verified 문항은 CLF 합격 후.
- **Task 세분화**: 공식 13 Task를 서비스 단위로 쪼개 **20개 학습문서**로 구성한다
  (SAA가 4도메인을 24문서로 쪼갠 것과 같은 밀도).
- **CLF 게이트 유지**: SOA는 구조·문서만. 문항은 CLF 합격 이후로 미룬다.

### SAA와의 핵심 차이 — files.zip 없음

SAA는 본인이 이미 만든 `files.zip`(27 상세문서)을 본문 초안 원재료로 썼다.
**SOA에는 그런 사전 자료가 없다.** 모든 문서는 공식 Exam Guide의 `skills[]` 항목 +
AWS 공식 문서를 1차 출처로 새로 집필한다. 문항이 게이트 상태여도 **문서 본문의
`📌 출처` 섹션에는 실제 AWS 공식 문서 URL을 기록**한다(SAA 문서와 동일 규율).

## 대상 시험 (SOA-C03 공식)

- 레벨 Associate · 합격 720/1000 · 채점 50문항(+비채점 15) = 65문항.
- 도메인 5개 / 공식 Task 13개:

| D | 이름 | 비중 | 공식 Task |
|---|---|---|---|
| 1 | 모니터링, 로깅, 분석, 문제 해결 및 성능 최적화 | 22% | 1.1 · 1.2 · 1.3 |
| 2 | 신뢰성 및 비즈니스 연속성 | 22% | 2.1 · 2.2 · 2.3 |
| 3 | 배포, 프로비저닝 및 자동화 | 22% | 3.1 · 3.2 |
| 4 | 보안 및 규정 준수 | 16% | 4.1 · 4.2 |
| 5 | 네트워킹 및 콘텐츠 전송 | 18% | 5.1 · 5.2 · 5.3 |

출처: `flutter_app/assets/exam_guides/SOA-C03.json`.

## 문서 분할안 (20문서 → 13 Task 매핑)

식별자 `soa-t{도메인}-{순번}`. 파일 `assets/content/soa/soa-t{d}-{n}.md`(SAA 네이밍 그대로).
`coversTasks`는 공식 Task 앵커(1:1 또는 복수).

| # | taskId | 제목 | domain | coversTasks |
|---|---|---|---|---|
| 1 | soa-t1-1 | CloudWatch 지표·경보·대시보드 | 1 | 1.1 |
| 2 | soa-t1-2 | CloudWatch Logs·Logs Insights·구독 필터·에이전트 | 1 | 1.1 |
| 3 | soa-t1-3 | CloudTrail·EventBridge·X-Ray (감사·이벤트·추적) | 1 | 1.1 |
| 4 | soa-t1-4 | 가용성 지표 기반 문제 식별·해결 (Health Dashboard) | 1 | 1.2 |
| 5 | soa-t1-5 | 컴퓨팅·스토리지·DB 성능 최적화 (EC2·EBS·RDS·ElastiCache) | 1 | 1.3 |
| 6 | soa-t2-1 | Auto Scaling·ELB로 확장성·탄력성 구현 | 2 | 2.1 |
| 7 | soa-t2-2 | Multi-AZ·고가용성·복원력 설계 | 2 | 2.2 |
| 8 | soa-t2-3 | 백업·복원 전략 (AWS Backup·스냅샷·수명주기) | 2 | 2.3 |
| 9 | soa-t2-4 | DR·데이터 복원력 (RTO/RPO·S3 복제) | 2 | 2.3 |
| 10 | soa-t3-1 | CloudFormation 프로비저닝 (템플릿·스택·StackSets·드리프트) | 3 | 3.1 |
| 11 | soa-t3-2 | AMI·리소스 배포·유지 관리·패치 전략 | 3 | 3.1 |
| 12 | soa-t3-3 | Systems Manager 운영 자동화 (Run Command·Patch·State Manager·Parameter Store) | 3 | 3.2 |
| 13 | soa-t3-4 | 자동화 패턴 (EventBridge·Lambda·자동 복구) | 3 | 3.2 |
| 14 | soa-t4-1 | IAM·계정 보안 운영 (정책·역할·MFA·자격증명 보고서) | 4 | 4.1 |
| 15 | soa-t4-2 | 규정 준수·거버넌스 (Config·Security Hub·GuardDuty·Inspector) | 4 | 4.1 |
| 16 | soa-t4-3 | 데이터·인프라 보호 (KMS·암호화·Secrets Manager·ACM) | 4 | 4.2 |
| 17 | soa-t5-1 | VPC 네트워킹 구현 (서브넷·라우팅·SG·NACL·NAT) | 5 | 5.1 |
| 18 | soa-t5-2 | 하이브리드·연결 (피어링·TGW·VPN·Direct Connect·엔드포인트) | 5 | 5.1 |
| 19 | soa-t5-3 | Route 53 DNS·CloudFront 콘텐츠 전송 | 5 | 5.2 |
| 20 | soa-t5-4 | 네트워크 문제 해결 (Flow Logs·Reachability Analyzer) | 5 | 5.3 |

도메인별 문서 수: **D1: 5 · D2: 4 · D3: 4 · D4: 3 · D5: 4** (비중 22/22/22/16/18%에 대체로 비례).

## 문서 템플릿 (SAA와 동일 + 운영 강조 변형)

기존 SAA 문서 구조를 그대로 채택한다:

```
# 제목
> 커버하는 공식 Task — SOA-C03 · 도메인 N 「…」(비중%) · Task X.Y … (`soa-tN-n`)
## ✅ 학습 목표 체크리스트
## 🎯 왜 중요한가
## 📖 핵심 개념        (### 소제목 + 표 + 공식 인용 blockquote)
## ✍️ 시험 포인트
## ⚠️ 흔한 함정
## 🧪 자가 점검        (정답 토글, "정식 검증 문항은 별도" 주석)
### 📌 출처 (verified)  (실제 AWS 공식 문서 URL)
```

**SOA 변형**: 운영 자격증이므로 `📖 핵심 개념`에서 SAA의 "어떤 것을 **선택**하는가"보다
**"어떻게 구성/운영/문제 해결하는가"** 절차·진단 흐름을 강조한다(예: 경보 임계값 설정 절차,
패치 베이스라인 구성 단계, Flow Logs로 연결 실패 추적하는 순서).

## 등록·산출물

1. **`flutter_app/lib/data/content_index.dart`** — `kContentIndex`에 `'SOA-C03': [...]`
   20개 `ContentEntry` 추가. 각 엔트리 `questionCount: 0`,
   `questionsAsset: 'assets/content/soa/soa-tN-n.questions.json'`(파일은 아직 없어도 됨 —
   `questionCount:0`이면 런타임이 로드를 생략).
2. **`flutter_app/assets/content/soa/`** — 20개 `soa-tN-n.md` 학습문서.
3. **`flutter_app/pubspec.yaml`** — assets에 `assets/content/soa/` 경로 등록(누락 시 추가).
4. **`docs/plans/soa-c03-task-mapping.md`** — 진척 추적표 + 분할 근거(SAA 매핑 문서와 동일 양식),
   "files.zip 출처" 열 대신 "1차 출처(AWS 공식 문서)" 열.

### 게이트 동작 확인 (기존 코드 재사용, 신규 분기 없음)

- `certHasVerifiedQuestions('SOA-C03')` → `questionCount` 합이 0이므로 `false` →
  모의고사·약점 리포트·오답노트는 자동으로 잠금 유지(SAA와 동일 경로).
- `certHasContent('SOA-C03')` → `true` → 자격증 상세 페이지에 학습문서 목록 노출.
- 즉, **콘텐츠 데이터만 추가하면 UI/게이트는 기존 로직으로 올바르게 동작**한다.

## 생산 순서

**D1 → D5 → D2 → D3 → D4**

- **D1 먼저**: 모니터링·로깅·성능은 SOA의 정체성이자 최빈출(22%). 여기서 첫 배치를 측정한다.
- **D5 다음**: 네트워킹은 SAA 자산(VPC·Route 53·CloudFront·하이브리드)과 겹쳐 재활용·속도 우위.
- **D2 → D3**: 신뢰성·자동화는 SOA 고유 운영 영역(CloudFormation·Systems Manager 신규 집필).
- **D4 마지막**: 보안·규정은 CLF·SAA와 개념 중복이 커서 마지막에 빠르게.

문서당 작업 단위: ①공식 Task `skills[]` + AWS 공식 문서로 학습 → ②템플릿대로 본문 집필 →
③`📌 출처`에 실제 URL 기록 → ④`content_index.dart` 한 줄 등록 → ⑤매핑 문서 진척표 갱신.

## 범위 밖 (명시)

- **verified 문항 제작** — CLF 합격 후 단계. 이번에는 `questionCount:0` 게이트만 건다.
- **모의고사/리포트 활성화** — 문항이 생기기 전까지 잠금 유지(코드 변경 없음).
- **공식 가이드 JSON 수정** — `SOA-C03.json`은 이미 존재. 손대지 않는다.

## 성공 기준

- `assets/content/soa/`에 20개 학습문서 존재, 각 문서가 템플릿 7개 섹션 + 공식 Task 앵커 +
  `📌 출처` 실제 URL을 갖춘다.
- `content_index.dart`에 `'SOA-C03'` 20 엔트리 등록, `flutter analyze` 통과.
- 배포 후 SOA-C03 상세 페이지에 학습문서 20개가 도메인별로 노출되고,
  모의고사·리포트는 잠금 상태(문항 0)임이 확인된다.
- `docs/plans/soa-c03-task-mapping.md`로 진척이 추적된다.
