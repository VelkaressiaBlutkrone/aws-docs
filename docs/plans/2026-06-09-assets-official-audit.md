# AWS 공식 기준 에셋 정합성 감사 리포트

작성일: 2026-06-09  
대상: `flutter_app/assets` 전체 에셋 감사 (`.omc` 제외)  
기준: AWS 공식 시험 안내서 목록, 각 자격증별 공식 시험 안내서, 에셋에 기록된 AWS 공식 출처 URL

## 판정 요약

| 영역 | 판정 | 요약 |
|---|---|---|
| 에셋 인벤토리 | PASS | Markdown 63개, CLF 문항 JSON 19개, 시험 가이드 JSON 12개, 요약 JSON 1개 확인. `.omc` 제외. |
| 공식 시험 안내서 목록 | PASS | AWS 공식 목록의 12개 자격증과 로컬 `exam_guides` 12개 코드가 일치. |
| 시험 가이드 메타 | PASS | 12개 자격증의 합격 점수, 채점/비채점 문항 수, 도메인 가중치가 공식 Markdown 안내서와 일치. |
| CLF/SAA/SOA Task 구조 | PASS | 콘텐츠 보유 자격증 3개(`CLF-C02`, `SAA-C03`, `SOA-C03`)의 공식 도메인/Task 개수와 제목이 로컬 JSON과 일치. |
| Markdown frontmatter | PASS | 63개 문서 모두 `examGuideTaskId`, `certCode`, `domain`, `domainName`, `domainWeightPct`, `title`, `sources`, `lastVerified` 보유. |
| CLF 문항 스키마 | PASS | 228개 문항 모두 `verified:true`, 출처 있음, `correct` 범위 정상, `wrongExplanations` 키 정상. |
| 문서/메타 불일치 | NEEDS_CORRECTION | `README.md`가 CLF 문항 수를 190/각 10문항으로 설명하지만 실제는 228/각 12문항. |
| Support 플랜 최신성 | OUTDATED | 일부 CLF Support 문항/문서가 `Business Support` 중심으로 작성됨. 2026년 공식 문서는 `Business Support+`와 2027-01-01 단종 공지를 전면 표기. |
| 시험 시간 메타 | NEEDS_SOURCE | `durationMinutes`가 `CLF-C02` 외 11개 시험 가이드 JSON에서 비어 있음. 시험 시간 비교를 완료하려면 공식 시험별 시간 출처 보강 필요. |
| 출처 도메인 정책 | NEEDS_SOURCE | 260개 고유 출처 중 1개가 계획상 허용 도메인 목록 밖(`https://calculator.aws/`). AWS 서비스 도메인이지만 정책상 예외 승인 또는 대체 출처 필요. |

## 감사 방법

- `flutter_app/assets/content/**`에서 `.omc` 경로를 제외하고 Markdown/JSON 파일을 집계했다.
- AWS 공식 시험 안내서 목록 페이지에서 12개 자격증 코드와 로컬 `exam_guides/*.json` 코드를 대조했다.
- 각 로컬 `sourceUrl`의 `.md` 버전을 열어 합격 점수, 채점 문항 수, 비채점 문항 수, 도메인 가중치를 대조했다.
- `CLF-C02`, `SAA-C03`, `SOA-C03`는 공식 도메인 Markdown(`*-domainN.md`)을 열어 도메인별 Task 개수와 Task 제목까지 대조했다.
- Markdown frontmatter 필수 필드와 source 개수를 자동 확인했다.
- CLF 문항 JSON 19개는 전체 228문항에 대해 `verified`, `sources`, `correct`, `wrongExplanations` 구조를 자동 확인했다.
- 에셋에 기록된 고유 URL 260개를 도메인별로 분류했다. 대량 HTTP 상태 확인은 AWS Docs가 자동 `HttpClient` 요청에 403을 반환해 링크 생존성 판정 자료로 사용하지 않았다.

## 파일별 수정목록

| 심각도 | 파일 | 항목 | 공식 출처 | 판정 | 문제 문장/상태 | 권장 수정 |
|---|---|---|---|---|---|---|
| P1 | `README.md` | CLF 문항 수 | 로컬 `content_index.dart`, CLF question banks | NEEDS_CORRECTION | `19개 Task 전부 각 10문항(총 190 검증 문항)` | `19개 Task 전부 각 12문항(총 228 검증 문항)`으로 수정. |
| P1 | `flutter_app/assets/content/clf/t4-3.md` | Support 플랜 명칭/응답시간 | AWS Support Plans, AWS Support plan comparison | OUTDATED | 본문 표와 시험 포인트가 `Business`를 최소 24x7 플랜으로 둠. 별도 메모는 있으나 표/시험 포인트와 분리되어 혼선 가능. | 시험 대비 전통 분류와 현재 공식 명칭을 한 표 안에서 병기: `Business Support(기존, 2027-01-01 단종 예정) / Business Support+(현재 권장 생산 워크로드 최소 플랜)`. 응답 시간은 현재 공식 비교표 기준 `< 30 mins`(business-critical system down), `< 1 hour`(production system down)를 분리. |
| P1 | `flutter_app/assets/content/clf/t4-3.questions.json` | Support 플랜 문항 q2/q7/q11 | AWS Support Plans, AWS Support plan comparison | OUTDATED | q2, q7은 정답을 `Business Support`로만 표기. q11은 `Business Support(현 Business Support+)`로 병기되어 비교적 양호. | q2/q7도 q11처럼 현재 명칭을 병기하거나, 문제 stem에 `시험 전통 분류 기준`을 명시. 해설에는 2027-01-01 Developer/Business 단종 및 Business Support+ 전환 공지를 짧게 반영. |
| P2 | `flutter_app/assets/exam_guides/*.json` | `durationMinutes` | 각 시험별 AWS Certification 공식 시험 페이지 또는 PDF | NEEDS_SOURCE | `CLF-C02`만 90분이고 나머지 11개는 비어 있음. | 시험 시간은 공식 시험 안내서 HTML/Markdown에서 안정적으로 노출되지 않으므로, AWS Certification 시험별 공식 페이지/PDF를 별도 출처로 삼아 11개 값을 채우거나 `durationMinutes`를 의도적 nullable로 문서화. |
| P2 | `flutter_app/assets/content/clf/t1-4.questions.json` | 출처 도메인 정책 | AWS Pricing Calculator | NEEDS_SOURCE | `https://calculator.aws/` 1개가 계획의 허용 도메인(`docs.aws.amazon.com`, `aws.amazon.com`, `skillbuilder.aws`) 밖. | AWS 소유 서비스 도메인으로 예외 허용할지 결정. 보수적으로는 `https://calculator.aws/#/` 대신 `docs.aws.amazon.com/pricing-calculator/...` 계열 공식 문서 출처를 추가/대체. |

## 검증 세부 결과

### 에셋 인벤토리

| 구분 | 수량 |
|---|---:|
| Markdown 학습문서 | 63 |
| CLF question bank JSON | 19 |
| CLF verified 문항 | 228 |
| 비검증 문항 | 0 |
| 출처 없는 문항 | 0 |
| 시험 가이드 JSON | 12 |
| 요약 JSON | 1 |
| 폰트 파일 | 7 |

### 콘텐츠 보유 자격증 공식 Task 대조

| 자격증 | 로컬 문서 수 | 공식 도메인/Task 대조 | 비고 |
|---|---:|---|---|
| `CLF-C02` | 19 | PASS | 공식 19 Task와 1:1 매핑. |
| `SAA-C03` | 24 | PASS | 공식 14 Task를 세부 문서 24개로 분할. `coversTasks`가 공식 Task 번호를 보존. |
| `SOA-C03` | 20 | PASS | 공식 13 Task를 세부 문서 20개로 분할. `coversTasks`가 공식 Task 번호를 보존. |

### 12개 시험 가이드 메타 대조

| 코드 | 합격점 | 채점+비채점 | 도메인 가중치 | 판정 |
|---|---:|---:|---|---|
| `AIF-C01` | 700 | 50+15 | 20/24/28/14/14 | PASS |
| `AIP-C01` | 750 | 65+10 | 31/26/20/12/11 | PASS |
| `ANS-C01` | 700 | 50+15 | 30/26/20/24 | PASS |
| `CLF-C02` | 700 | 50+15 | 24/30/34/12 | PASS |
| `DEA-C01` | 720 | 50+15 | 34/26/22/18 | PASS |
| `DOP-C02` | 750 | 65+10 | 22/17/15/15/14/17 | PASS |
| `DVA-C02` | 720 | 50+15 | 32/26/24/18 | PASS |
| `MLA-C01` | 720 | 50+15 | 28/26/22/24 | PASS |
| `SAA-C03` | 720 | 50+15 | 30/26/24/20 | PASS |
| `SAP-C02` | 750 | 65+10 | 26/29/25/20 | PASS |
| `SCS-C03` | 750 | 50+15 | 16/14/18/20/18/14 | PASS |
| `SOA-C03` | 720 | 50+15 | 22/22/22/16/18 | PASS |

## 수정 전 반드시 확인할 공식 링크

- AWS Certification 시험 안내서 목록: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/examguides/aws-certification-exam-guides.html
- CLF-C02 공식 시험 안내서: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/cloud-practitioner-02.html
- SAA-C03 공식 시험 안내서: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
- SOA-C03 공식 시험 안내서: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html
- AWS Support Plans: https://docs.aws.amazon.com/awssupport/latest/user/aws-support-plans.html
- AWS Support plan comparison: https://aws.amazon.com/premiumsupport/plans/
- AWS Trusted Advisor: https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html
- AWS Pricing Calculator 문서 대체 출처 후보: https://docs.aws.amazon.com/pricing-calculator/latest/userguide/what-is-pricing-calculator.html

## 결론

현재 에셋의 핵심 시험 구조와 콘텐츠 매핑은 공식 시험 안내서와 크게 어긋나지 않는다. 즉시 수정해야 하는 P0 정답/Task 매핑 충돌은 발견하지 못했다.

다만 제품의 "정직함" 기준으로는 다음 세 가지를 먼저 고치는 것이 좋다.

1. `README.md`의 CLF 문항 수를 228개로 현행화.
2. CLF Support 플랜 문서/문항에서 현재 공식 플랜명(`Business Support+`, `Unified Operations`)과 2027-01-01 단종 공지를 더 일관되게 병기.
3. `durationMinutes` 누락 11개와 `calculator.aws` 출처 정책 예외를 명시적으로 결정.
