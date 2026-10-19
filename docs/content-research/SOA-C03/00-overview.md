---
cert: SOA-C03
doc: 00-overview
retrieved: 2026-10-17
guideVersion: "1.1 (2026-06-01)"
---

# 00 — SOA-C03 시험 개요 (공식 실측)

> 이 문서의 표 중 **「원문 인용」 칸이 있는 행**은 URL 페이지 원문과 기계 대조해 검증했다(조회일 2026-10-17). 인용은 영어 원문 그대로(≤15단어)이며, 한국어 문장은 사실의 요약이다.
> 공식명이 바뀐 시험이다: **AWS Certified CloudOps Engineer - Associate** (구 SysOps Administrator). 공식 가이드는 **v1.1(2026-06-01)** 이 현행이다. 상세한 v1.0→v1.1 변경은 `97-guide-v11-diff.md`.

## 0. 한눈에 보기

| 항목 | 실측값 |
|---|---|
| 공식 자격증명 | **AWS Certified CloudOps Engineer - Associate** (구 AWS Certified SysOps Administrator - Associate) |
| 시험 코드 | **SOA-C03** (SOA-C02는 2025-09-29 종료, SOA-C03는 2025-09-30 시작) |
| 문항 | 65문항 = **채점 50 + 비채점 15** (비채점 문항은 시험 중 구분 불가). 객관식(정답 1) · 복수 선택(정답 2개 이상, 보기 5개 이상) |
| 시간 | **130분** |
| 합격선 | **720** (100–1,000 환산 점수). 보상식(compensatory) 채점 — 도메인별 과락 없음, 전체 점수만 통과하면 됨 |
| 오답 처리 | 무응답은 오답 처리, 오답 감점 없음(찍기 불이익 없음) |
| 도메인 | 5개 — 22 / 22 / 22 / 16 / 18 (%) · Task 13개 · Skill 53개 (Knowledge 항목 없음) |
| 응시료 | 150 USD |
| 응시 방식 | Pearson VUE 시험장 또는 온라인 감독 |
| 언어 | English · Japanese · Korean · Simplified Chinese — **Korean·Simplified Chinese 버전은 2026-11-19 이후 종료 예정** (§5 ⚠️) |
| 자격 유효기간 | 3년 (최신 버전 재응시 또는 AWS Certified DevOps Engineer - Professional 취득 시 자동 갱신) |
| 공식 가이드 | v1.0 (2025-09-30) → **v1.1 (2026-06-01, 현행)**. 개정은 시험 반영 최소 1개월 전에 공표 |

## 1. 공식 자격증명 — 개명 확인

| # | 사실 | 원문 인용 | URL | 조회일 |
|---|---|---|---|---|
| 1 | 현재 공식명은 CloudOps Engineer이고, 구명칭은 SysOps Administrator이다. | "(formerly known as AWS Certified SysOps Administrator - Associate)" | https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 2026-10-17 |
| 2 | 개명은 새 버전(SOA-C03)에 합격한 사람에게만 적용되고, 기존 SysOps 보유자의 명칭은 소급 변경되지 않는다. | "will only apply to those who pass the latest exam version (SOA-C03)" | https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 2026-10-17 |
| 3 | 기존 SysOps 자격 보유자는 CloudOps 시험을 다시 볼 필요가 없다(3년 유효). | "are not required to take the AWS Certified CloudOps Engineer - Associate exam" | https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 2026-10-17 |
| 4 | SOA-C02 마지막 응시일은 2025-09-29이다. | "September 29, 2025: Last day to take AWS Certified SysOps Administrator - Associate (SOA-C02) exam" | https://aws.amazon.com/certification/coming-soon/ | 2026-10-17 |
| 5 | SOA-C03 첫 응시일은 2025-09-30이다. | "September 30, 2025: First day to take AWS Certified CloudOps Engineer - Associate (SOA-C03) exam" | https://aws.amazon.com/certification/coming-soon/ | 2026-10-17 |
| 6 | SOA-C03 가이드 페이지 제목에 신명칭과 코드가 함께 표기된다(가이드 문서 제목 = 「AWS Certified CloudOps Engineer - Associate (SOA-C03)」). | "The AWS Certified CloudOps Engineer - Associate (SOA-C03) exam is intended for CloudOps engineers." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |

- **슬러그 주의**: docs 사이트 URL 경로는 여전히 구명 기반(`sysops-administrator-associate-03`)이다. 레포 `SOA-C03.json`의 `slug`/`sourceUrl`이 이 경로를 쓰는 것은 정상이다(내부 식별자로 유효).

## 2. 시험 형식·채점 (공식 가이드 v1.1 본문 = v1.0 PDF 본문과 동일 문구)

| # | 사실 | 원문 인용 | URL | 조회일 |
|---|---|---|---|---|
| 1 | 채점 대상 문항은 50개이다. | "The exam includes 50 questions that affect your score." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 2 | 비채점 문항 15개가 별도로 포함되며 시험 중 식별되지 않는다. | "The exam includes 15 unscored questions that do not affect your score." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 3 | 최소 합격 점수는 720이다. | "The minimum passing score is 720." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 4 | 결과는 100–1,000 환산 점수로 보고된다. | "reported as a scaled score of 100–1,000" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 5 | 보상식 채점이라 도메인별로 합격점을 넘길 필요가 없다. | "The exam uses a compensatory scoring model" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 6 | 무응답은 오답 처리되고 찍기에 감점은 없다. | "There is no penalty for guessing." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 7 | 객관식은 정답 1개 + 오답 3개이다. | "Has one correct response and three incorrect responses (distractors)" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 8 | 복수 선택은 보기 5개 이상 중 정답이 2개 이상이다. | "Has two or more correct responses out of five or more response options" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 9 | 자격증 페이지의 시험 시간은 130분이다. | "130 minutes" | https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 2026-10-17 |
| 10 | 자격증 페이지의 문항 구성(총 65문항, 객관식 또는 복수 선택). | "65 questions; either multiple choice or multiple response" | https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 2026-10-17 |
| 11 | 응시료는 150 USD이다(환율·추가 비용은 요금 페이지 참조). | "150 USD. Visit Exam pricing for additional cost information" | https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 2026-10-17 |
| 12 | 응시 방식은 시험장 또는 온라인 감독이다. | "Pearson VUE testing center or online proctored exam" | https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 2026-10-17 |
| 13 | 자격 유효기간은 3년이다. | "This certification is valid for 3 years." | https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 2026-10-17 |

## 3. 도메인·비중 (v1.0 = v1.1 동일)

| D | 영문 도메인명 | 한국어(공식 ko_kr) | 비중 | Task | Skill 수 |
|---|---|---|---|---|---|
| 1 | Monitoring, Logging, Analysis, Remediation, and Performance Optimization | 모니터링, 로깅, 분석, 문제 해결 및 성능 최적화 | 22% | 1.1 · 1.2 · 1.3 (3) | 14 |
| 2 | Reliability and Business Continuity | 신뢰성 및 비즈니스 연속성 | 22% | 2.1 · 2.2 · 2.3 (3) | 9 |
| 3 | Deployment, Provisioning, and Automation | 배포, 프로비저닝 및 자동화 | 22% | 3.1 · 3.2 (2) | 8 |
| 4 | Security and Compliance | 보안 및 규정 준수 | 16% | 4.1 · 4.2 (2) | 10 |
| 5 | Networking and Content Delivery | 네트워킹 및 콘텐츠 전송 | 18% | 5.1 · 5.2 · 5.3 (3) | 12 |
| 합계 | | | 100% | 13 | 53 |

- **Task 단위 비중은 공식 미공개**다(도메인 단위만 공개). 도메인 간 합산이 곧 문항 비율이며, 같은 도메인 내 Task 배분은 알 수 없다.
- Skill 번호(예: 1.1.1)는 공식 가이드의 식별자이며 Knowledge 항목은 없다(Task → Skill 2단 구조).

| # | 사실 | 원문 인용 | URL | 조회일 |
|---|---|---|---|---|
| 1 | 도메인 1의 비중 | "Content Domain 1: Monitoring, Logging, Analysis, Remediation, and Performance Optimization (22% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 2 | 도메인 2의 비중 | "Content Domain 2: Reliability and Business Continuity (22% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 3 | 도메인 3의 비중 | "Content Domain 3: Deployment, Provisioning, and Automation (22% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 4 | 도메인 4의 비중 | "Content Domain 4: Security and Compliance (16% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 5 | 도메인 5의 비중 | "Content Domain 5: Networking and Content Delivery (18% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |

### 3.1 SOA-C02 → SOA-C03 구조 변화 (공식 비교 페이지)

| C02 도메인(비중) | C03 도메인(비중) |
|---|---|
| D1 Monitoring, Logging, and Remediation (20%) | D1 Monitoring, Logging, Analysis, Remediation, and Performance Optimization (22%) |
| D2 Reliability and Business Continuity (16%) | D2 Reliability and Business Continuity (22%) |
| D3 Deployment, Provisioning, and Automation (18%) | D3 Deployment, Provisioning, and Automation (22%) |
| D4 Security and Compliance (16%) | D4 Security and Compliance (16%) |
| D5 Networking and Content Delivery (18%) | D5 Networking and Content Delivery (18%) |
| D6 Cost and Performance Optimization (12%) | **폐지** — Task 6.1·6.2가 C03의 Task 1.3으로 이동 |

| # | 사실 | 원문 인용 | URL | 조회일 |
|---|---|---|---|---|
| 1 | C02에는 비용·성능 최적화 도메인(12%)이 따로 있었다. | "Domain 6: Cost and Performance Optimization (12%)" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-comparison.html | 2026-10-17 |
| 2 | C02의 Task 6.1·6.2는 C03의 Task 1.3으로 옮겨졌다. | "Tasks 6.1 and 6.2 in SOA-C02 were moved to Task 1.3 in SOA-C03." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-comparison.html | 2026-10-17 |
| 3 | C02의 Task 4.2에 있던 VPN은 C03의 Task 5.1로 이동했다. | "In Task 4.2, VPNs were moved to Task 5.1." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-comparison.html | 2026-10-17 |
| 4 | C03에서 삭제된 내용: S3 정적 웹 호스팅 구성(Task 5.2). | "Configure S3 static website hosting." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-comparison.html | 2026-10-17 |
| 5 | C03에서 추가된 내용: CloudWatch 에이전트 구성·관리(Task 1.1). | "Configure and manage the CloudWatch agent to collect metrics and logs from EC2 instances" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-comparison.html | 2026-10-17 |
| 6 | C03에서 추가된 내용: CloudWatch 네트워크 모니터링(Task 5.3). | "Configure and analyze CloudWatch network monitoring services" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-comparison.html | 2026-10-17 |

## 4. 대상 응시자·범위 밖 직무 (v1.0 = v1.1 동일 문구)

| # | 사실 | 원문 인용 | URL | 조회일 |
|---|---|---|---|---|
| 1 | 대상 응시자는 AWS에서 배포·관리·문제 해결·네트워킹·보안 경력 1년 이상이다. | "should have 1 year of experience with deployment, management, troubleshooting, networking, and security on AWS" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 2 | 범위 밖 직무: 분산 아키텍처 설계. | "Design distributed architectures." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 3 | 범위 밖 직무: CI/CD 파이프라인 설계. | "Design CI/CD pipelines." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 4 | 범위 밖 직무: 하이브리드·멀티 VPC 네트워킹 설계. | "Design hybrid and multi-VPC networking." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 5 | 범위 밖 직무: 보안·규정 준수·거버넌스 요구 사항 정의. | "Define security, compliance, and governance requirements." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 6 | 범위 밖 직무: 리소스 용량 평가·계획. | "Assess and plan resource capacity." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 7 | 범위 밖 직무: 비용·TCO 분석. | "Analyze costs and total cost of ownership." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |
| 8 | 범위 밖 직무 목록은 비망라적이다. | "This list is non-exhaustive." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 2026-10-17 |

- 학습문서 저작 시 함의: **설계·계획·비용 분석**은 범위 밖이므로, 해당 주제(예: Skill 5.1.4 네트워크 비용 최적화)는 「운영자가 비용 요소를 식별하고 줄이는 조치」 수준으로 다루고 TCO 분석으로 깊게 들어가지 않는다(범위 해석은 `99-gaps.md` 참조).

## 5. 시험 서비스명 표기 · 반영 시점 · ⚠️ 주의 사항

| # | 사실 | 원문 인용 | URL | 조회일 |
|---|---|---|---|---|
| 1 | 시험은 읽기 부담을 줄이려고 서비스의 공식 짧은 이름을 쓴다(예: Amazon SNS). v1.1 Skill 문구의 약칭화(예: Amazon Elastic Block Store → Amazon EBS)는 이 정책의 결과로 보인다(이 정책 페이지는 v1.1 이전의 docs 목차에는 없었다 — `97-guide-v11-diff.md` §3). | "AWS Certification is reducing the reading load on this exam by using official short names" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-service-mentions.html | 2026-10-17 |
| 2 | 개정된 가이드는 시험 반영 최소 1개월 전에 공표된다. v1.1 공표일(2026-06-01)을 적용하면 시험 반영은 2026-07-01 이후이며, 정확한 시행일은 공식 페이지에 명시되어 있지 않다. | "published at least 1 month before changes are reflected on your exam" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 3 | 가이드 버전 이력: v1.0은 2025-09-30에 발행되었다. | "September 30, 2025" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 4 | 가이드 버전 이력: v1.1은 2026-06-01에 발행되었다. | "June 1, 2026" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 5 | **한국어(및 중국어 간체) 시험 버전은 2026-11-19 이후 종료 예정이다.** | "in Simplified Chinese and Korean will be retired after November 19, 2026" | https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 2026-10-17 |
| 6 | 현재 제공 언어(종료 공지와 함께 표기됨). | "English, Japanese, Korean, and Simplified Chinese" | https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 2026-10-17 |

### ⚠️ 5.1 한국어 시험 종료 예정 — 학습 계획에 직접 영향
- 2026-10-17 기준 **약 33일 남았다**(2026-11-19 이후 종료). 한국어로 응시하려면 그 전에 예약·응시해야 하고, 이후에는 English/Japanese 중 선택해야 한다.
- 이 사이트의 학습 대상이 한국어 응시자라면 일정 판단이 필요한 사항이다(사람 결정). 시험 가이드의 한국어 번역(ko_kr 페이지)은 별개 문서라 가이드 자체가 사라지는지는 공식 공지에 없다.

### ⚠️ 5.2 공식 PDF 가이드는 v1.1 미반영 (stale) — 가이드 정본은 docs 사이트(HTML)
- 직접 내려받아 확인(2026-10-17): `https://d1.awsstatic.com/onedam/marketing-channels/website/aws/en_US/certification/approved/pdfs/docs-cloudops-associate/AWS-Certified-CloudOps-Engineer-Associate_Exam-Guide.pdf` — `Last-Modified: 2026-09-01`, md5 `3a8cf01660cf7002a14979a85afd8319`.
- 이 PDF의 본문은 **v1.0 문구**다(예: Skill 2.3.4 = 「Follow disaster recovery procedures.」 한 줄, Kiro·AWS DevOps Agent·Amazon S3 Files 등 v1.1 신규 용어 없음). 그런데 푸터는 **「Version 1.1 SOA-C03」** 으로 표기되어 있어 **docs 사이트의 v1.1(2026-06-01)과 혼동하기 쉽다.**
- Wayback Machine 캡처로 확인: 2025-09-10 · 2025-12-01 · 2026-07-11 캡처 모두 같은 본문·같은 푸터(「Version 1.1」). 즉 PDF 푸터의 「1.1」은 PDF 자체의 번호일 뿐 docs 사이트 개정 이력(1.0=2025-09-30, 1.1=2026-06-01)과 무관하다.
- 자격증 페이지의 가이드 링크는 docs 사이트(`.../sysops-administrator-associate-03.html`)를 가리킨다. **PDF를 근거로 쓰지 말고 docs 사이트를 정본으로 삼는다.**
- 증거 파일 위치: Wayback `https://web.archive.org/web/20251201150423id_/https://d1.awsstatic.com/onedam/marketing-channels/website/aws/en_US/certification/approved/pdfs/docs-cloudops-associate/AWS-Certified-CloudOps-Engineer-Associate_Exam-Guide.pdf` (3자 아카이브가 보관한 공식 PDF 사본, `[3자-아카이브]`).

## 6. 서비스 범위 목록 규모 (v1.1)
- in-scope 서비스·기능 **87개**(v1.0 PDF 82개 + 신규 5), out-of-scope **52개**(v1.0 PDF 57개 − 6 + 1). 변경 내역은 `97-guide-v11-diff.md` §4.
- 두 목록 모두 비망라적이다 — 어느 목록에도 없는 서비스(예: AWS Direct Connect, AWS CodeDeploy, AWS User Notifications)는 **출제 범위 불명**으로 취급한다(`99-gaps.md`의 범위해석 항목).

| # | 사실 | 원문 인용 | URL | 조회일 |
|---|---|---|---|---|
| 1 | in-scope 목록은 비망라적이며 변경될 수 있다. | "This list is non-exhaustive and is subject to change." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-in-scope-services.html | 2026-10-17 |
| 2 | out-of-scope 목록은 직무와 무관한 제품을 아예 제외한다. | "entirely unrelated to the target job roles for the exam are excluded from this list" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-out-of-scope-services.html | 2026-10-17 |

## 7. 레포 `flutter_app/assets/exam_guides/SOA-C03.json` 과의 불일치 목록

대조 기준: 레포 JSON(읽기 전용) vs 공식 v1.1 (EN/KO 도메인 페이지, 2026-10-17). 기계 비교(53 Skill 전수).

| # | 항목 | JSON 현재 값 | 공식 v1.1 | 판정 |
|---|---|---|---|---|
| 1 | `overview.passingScore` | 720 | 720 | 일치 |
| 2 | `overview.scoredQuestions` / `unscoredQuestions` | 50 / 15 | 50 / 15 | 일치 |
| 3 | `overview.durationMinutes` | 130 | 130분 | 일치 |
| 4 | 도메인 5개 이름·비중 | 22/22/22/16/18, KO 도메인명 | 동일(ko_kr 공식 도메인명과 일치) | 일치 |
| 5 | Task 13개 번호·한국어 제목 | 13개 | 13개 모두 제목 동일(기계 비교) | 일치 |
| 6 | Skill 개수 | 53개 | 53개(번호 체계 불변) | 일치 |
| 7 | `knowledge` 배열 | 전부 빈 배열 | 공식 가이드에 Knowledge 항목 없음 | 일치(정상) |
| 8 | Skill 문구 — 공식 개정 10건(1.1.1 · 1.2.1 · 1.3.4 · 2.3.4 · 3.1.2 · 3.2.2 · 4.1.3 · 4.1.5 · 4.2.5 · 5.1.2) | v1.0 문구 | v1.1 문구 | **불일치 → 갱신 필요** (`97` §2, `99`) |
| 9 | Skill 문구 — 표기만 달라진 20건(1.1.2 · 1.1.5 · 1.3.2 · 1.3.3 · 2.1.3 · 2.3.1 · 2.3.3 · 3.1.1 · 3.1.3 · 3.1.4 · 3.1.6 · 3.2.1 · 4.1.1 · 4.1.2 · 4.2.2 · 4.2.3 · 5.1.3 · 5.2.3 · 5.3.2 · 5.3.5) | v1.0 KO 번역 | v1.1 KO 번역(서비스 짧은 이름·어순) | 불일치(의미 변화 없음) → 선택적 갱신 (`97` §3.2) |
| 10 | 메타데이터 | 가이드 버전·발행일·표시명 필드 없음 | v1.1 (2026-06-01) / 신명칭 | 부재 — 필드 추가 제안(`99`) |
| 11 | `slug` / `sourceUrl` | `sysops-administrator-associate-03` / ko_kr docs URL | docs 경로가 아직 구명 기반 | 일치(정상). 영문 URL 병기는 선택 |
| 12 | 앱 표시명 (`flutter_app/lib/data/site_data.dart:72`) | 'AWS Certified CloudOps Engineer - Associate' | 신명칭 | **이미 신명칭 사용** — 감사 GUIDE-002는 앱 쪽에서 해소 상태(읽기 확인) |
| 13 | 감사 GUIDE-001의 「스킬 11건 변경」 | — | 공식 Revisions 표는 **10건** | 감사 문서 오기(건수) — `99` 참조 |

## 8. 조회한 URL 목록 (HTTP 200 확인, 2026-10-17)

| URL | 용도 |
|---|---|
| https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html | 가이드 메인(소개·형식·채점·도메인 비중) |
| https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html ~ `-domain5.html` | 도메인별 Task·Skill 원문(EN). 한국어는 `/ko_kr/` 경로 |
| https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | v1.0→v1.1 개정 이력·Skill 변경표·범위 목록 변경 |
| https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-comparison.html | SOA-C02 vs C03 비교 |
| https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-in-scope-services.html | in-scope 서비스 목록 |
| https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-out-of-scope-services.html | out-of-scope 서비스 목록 |
| https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-service-mentions.html | 시험의 서비스 짧은 이름 정책 |
| https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ | 시험 개요(시간·문항·비용·언어·유효기간·개명 FAQ) |
| https://aws.amazon.com/certification/coming-soon/ | SOA-C02 종료 / SOA-C03 시작 일정 |
| https://d1.awsstatic.com/onedam/marketing-channels/website/aws/en_US/certification/approved/pdfs/docs-cloudops-associate/AWS-Certified-CloudOps-Engineer-Associate_Exam-Guide.pdf | 공식 PDF(stale 확인용) |
