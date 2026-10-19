# MLA-C01 원자료 개요 (00-overview)

- **조회일**: 2026-10-17
- **성격**: 원자료 수집 노트(학습문서·문항 아님). 취합 세션이 읽고 저작하며, 문항의 `verified` 판정은 사람 검수 몫이다.
- **범위**: AWS Certified Machine Learning Engineer - Associate **MLA-C01** 공식 Task 12개(`tasks/1-1.md` … `tasks/4-3.md`). 미해결·상충 항목은 `99-gaps.md`.
- **인용 규칙**: 사실 행은 `| ID | 항목 | 값 | "인용(15단어 이하)" | URL | 조회일 |` 형식이다. 인용은 출처 URL의 실제 페이지 텍스트와 자동 대조했다(대조 결과는 §10). `[수동]` 은 PDF·동적 페이지라 자동 대조가 불가능해 사람이 직접 확인한 행이다.

---

## 0. 결정이 필요한 핵심 발견 (먼저 읽을 것)

### 0-1. ⚠️ MLA-C02로 개정 중 — 저작 대상 결정이 필요하다 (최우선)

- 영문 MLA-C01은 **2026-09-28에 종료**됐다(오늘 기준 이미 지남). **한국어·일본어·중국어 간체 MLA-C01은 C02 GA까지** 응시할 수 있고, 공식 블로그는 **GA 2027-01-14(전 언어)에 모든 언어의 MLA-C01이 종료**된다고 적었다. 〔M11, C1~C4〕
- **C02 가이드 문서는 영문·한국어 모두 이미 docs에 공개**돼 있고(2026-10-17 HTTP 200 확인, §3) C01↔C02 비교 페이지도 영문·한국어가 있다. 반면 **시험 응시 언어**는 다르다 — C02 베타는 영문만이고 "일본어·한국어·중국어(간체)는 GA 시점에 제공"된다(〔C18〕). 한국어 응시자는 C01 종료(2027-01-14) 이후 C02만 볼 수 있다.
- C02는 도메인 **구성(4개)** 은 같지만 **비중이 28/26/22/24 → 28/24/24/24** (D2 −2%p · D3 +2%p)로 바뀌고, 생성형 AI·RAG·에이전트·Bedrock·책임 있는 AI가 들어오며, C01의 일부 내용(SageMaker Neo, BYOC, 모델 크기 축소, 사용자 지정 데이터로 파인튜닝, EFS/FSx 로드 등)이 **삭제**된다(§5).
- 이 노트는 지시대로 **C01 12개 Task 기준**이다. 각 Task 파일의 섹션 8에 C02 변경점을 공식 비교 페이지에서 옮겨 붙였다. **C01로 갈지 C02로 갈지는 컨트롤러가 정해야 한다**(C02 Task 노트가 필요하면 별도 위임).

### 0-2. ⚠️ C01 가이드가 가리키는 서비스·기능 상당수가 이미 신규 고객 중단/종료다

- SageMaker AI의 **Clarify·Model Monitor·Debugger·Role Manager·Ground Truth·A2I·Profiler** 등은 2026-07-30부터 신규 고객 불가, **Mechanical Turk는 폐쇄**, **Ground Truth Plus는 지원 종료**다(§7). 이들은 C01 Skill에 **직접 등장**한다(예: "SageMaker Clarify", "Model Debugger", "Model Monitor", "Role Manager", "Ground Truth, Mechanical Turk").
- 시험 범위에는 그대로 남아 있으므로 **학습문서에서 빼지 말고**, 서비스 상태를 ⚠️로 병기하는 편이 정직성 원칙에 맞다. 문항 저작 시에는 "지금 새로 도입하라"는 정답을 피한다.
- 반대로 SageMaker AI의 나머지 기능(Feature Store, Pipelines, Model Registry, JumpStart, Canvas, Training, Inference 등)은 이 중단 공지의 대상이 **아니다**(공식 페이지가 명시). 〔L0〕

### 0-3. 레포 `MLA-C01.json` 은 공식 ko 가이드와 글자 단위로 일치한다

- 도메인 4개(이름·비중), Task 12개(제목), 지식 63개, 기술 70개를 **공식 ko_kr 가이드 `.md` 렌디션과 문자열 완전 일치 비교**한 결과 **불일치 0건**이었다(§4). 수정할 본문은 없다. 다만 JSON에는 문항 유형·응시료·유효기간·응시 언어·개정 공지가 없다(§4의 제안).

### 0-4. 공식 가이드 판본이 둘이고 서로 다르다

- 영문 PDF는 **Version 1.0**, 한국어 HTML 가이드는 버전 표기가 없으며 **문항 유형(Case study 유무)·서비스 표기(SageMaker vs SageMaker AI, QuickSight vs Quick)** 가 PDF와 다르다. 영문 HTML 가이드(C01)는 **404**다(§2).

### 0-5. 한국어 가이드에는 번역 어색함이 있다 (§8)

- "quantizing"이 "정량화"로, 3.2의 "스팟 인스턴스 동적 추가" 문구가 합쳐진 한 문장으로 옮겨져 의미가 흐려졌다. 문항의 `skill` 필드에는 **한국어 원문 그대로** 쓰고, 영문 의미는 §8을 참고한다.

---

## 1. 시험 메타 (MLA-C01, 실측)

| # | 항목 | 값/내용 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| M1 | 공식 자격증명·코드·수준 | AWS Certified Machine Learning Engineer - Associate · 시험 코드 MLA-C01 · 수준 Associate | "AWS Certified Machine Learning Engineer - Associate(MLA-C01)" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M2 | 채점 문항 수 | 50 | "시험에는 점수에 반영되는 50개의 문항이 포함되어 있습니다" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M3 | 비채점 문항 수 | 15 (시험 중 식별되지 않음) | "시험에는 점수에 영향을 주지 않는 15개의 채점되지 않는 문제가 포함됩니다" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M4 | 총 문항 수·형식 | 65문항(= 50 + 15) | "65 questions; multiple choice and multiple response" | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| M5 | 시험 시간 | 130분 (표에서 C02 베타 170분 / C01 130분 순) | "Exam duration 170 minutes 130 minutes" | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| M6 | 합격 최소 점수 | 720 | "합격 최소 점수는 720점입니다" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M7 | 점수 척도 | 100~1,000 환산 점수 | "시험 결과는 100~1,000점의 변환 점수로 보고됩니다" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M8 | 채점 모델 | 보상(compensatory) 모델 — 섹션별 합격 불필요, 전체 합격만 필요 | "시험은 보상 점수 모델을 사용하므로 각 섹션에서 합격 점수를 얻을 필요는 없으며" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M9 | 오답 감점 | 없음. 무응답은 오답 처리 | "추측에 따른 불이익은 없습니다" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M10 | 응시료 | 150 USD | "$150 USD" | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| M11 | 응시 언어(C01) | 영문(2026-09-28까지)·일본어·한국어·중국어 간체 | "English (available through September 28, 2026), Japanese, Korean, and Simplified Chinese" | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| M12 | 자격 유효 기간 | 3년 | "This certification is valid for 3 years." | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| M13 | 문항 유형(ko 가이드) | 선다형·복수 응답형·순서 배열·매칭형 4종 | "시험에는 다음 문항 유형 중 1개 이상이 포함됩니다" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M14 | 문항 유형(영문 PDF v1.0) | 위 4종 + **Case study**(총 5종). ko 가이드에는 Case study가 없음 | [수동]"Case study: Has one scenario with two or more questions about the scenario." | https://d1.awsstatic.com/training-and-certification/docs-machine-learning-engineer-associate/AWS-Certified-Machine-Learning-Engineer-Associate_Exam-Guide.pdf | 2026-10-17 |
| M15 | 도메인 1 비중 | 28% | "콘텐츠 도메인 1: 기계 학습(ML)을 위한 데이터 준비(채점되는 콘텐츠의 28%)" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M16 | 도메인 2 비중 | 26% | "콘텐츠 도메인 2: ML 모델 개발(채점되는 콘텐츠의 26%)" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M17 | 도메인 3 비중 | 22% | "콘텐츠 도메인 3: ML 워크플로의 배포 및 오케스트레이션(채점되는 콘텐츠의 22%)" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M18 | 도메인 4 비중 | 24% | "콘텐츠 도메인 4: ML 솔루션 모니터링, 유지 관리 및 보안(채점되는 콘텐츠의 24%)" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |
| M19 | 대상 응시자 | SageMaker 등 ML 엔지니어링 AWS 서비스 경력 1년+, 관련 직군(백엔드·DevOps·데이터 엔지니어·데이터 과학자) 경력 1년+ | "최소 1년 이상의 경력을 보유하고 있어야 합니다" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 2026-10-17 |

도메인 요약: D1 데이터 준비 28%(Task 3개) · D2 모델 개발 26%(3개) · D3 배포·오케스트레이션 22%(3개) · D4 모니터링·유지 관리·보안 24%(3개). 가이드 항목 수 — 지식 63개, 기술 70개(Task별 개수는 §9).

> 참고: 레포 JSON의 `durationMinutes: 130` 은 시험 **가이드 페이지에는 없고** 자격증 소개 페이지(M5)에만 있다. JSON의 `sourceUrl` 은 가이드 페이지이므로 130분의 출처는 별도로 기록해야 한다.

---

## 2. 공식 가이드 — 판본·발행일·개정 상태

| # | 항목 | 값/내용 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| V1 | 영문 PDF 가이드 버전 | **Version 1.0** (모든 쪽 푸터에 'Version 1.0 MLA-C01') | [수동]"Version 1.0 MLA-C01" | https://d1.awsstatic.com/training-and-certification/docs-machine-learning-engineer-associate/AWS-Certified-Machine-Learning-Engineer-Associate_Exam-Guide.pdf | 2026-10-17 |
| V2 | C01↔C02 비교 페이지(영문)의 C01 사용 기간 표현 | 'C01은 2026-09-28까지 사용'이라고만 적음 — **언어 구분 없음**(한·일·중 C01이 C02 GA까지 남는다는 블로그·자격증 페이지와 표면상 불일치) | "the MLA-C01 exam (in use until September 28, 2026)" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html | 2026-10-17 |
| V3 | 같은 비교 페이지(한국어)의 표현 | 'C01은 2026-09-28까지, C02는 2026-09-29부터'로 동일하게 언어 구분 없음 | "MLA-C01 시험(2026년 9월 28일까지 사용)" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html | 2026-10-17 |

- **발행일**: 영문 PDF 본문에는 발행일이 **적혀 있지 않다**. 참고로 PDF 파일의 HTTP `Last-Modified` 헤더는 **2025-02-13**(2026-10-17 `curl -I` 결과)이며 공식 '발행일'이 아니다.
- **영문 HTML 가이드(C01)**: `https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html` 는 2026-10-17 현재 **404**(AWS 문서 MCP·WebFetch 모두). 반면 **ko_kr·ja_jp·zh_cn C01 페이지는 존재**한다. 영문 C01이 종료된 날(2026-09-28)과 관련 있는지는 **확인되지 않았다**(gaps).
- **ko HTML 가이드에는 버전·개정일이 없다.** 그러나 PDF v1.0과 **내용이 다르다**: ① 문항 유형 — PDF는 5종(Case study 포함), ko HTML은 4종(M13·M14). ② 서비스 표기 — PDF는 "SageMaker"·"Amazon QuickSight", ko HTML은 "SageMaker AI"·범위 내 목록의 "Amazon Quick"(〔N1, N6〕). 따라서 **ko HTML이 PDF v1.0 이후 갱신된 판본일 가능성**이 있으나, 공식 버전 번호가 없어 확정할 수 없다(gaps).
- **개정 여부 결론**: C01 가이드 자체의 'v1.1' 같은 개정 표기는 **발견되지 않았다**. 그러나 **시험 자체가 C02로 개정**되고 있다(§0-1, §5). 이 레포에서 SOA-C03 v1.1을 놓친 사례가 있었으므로, 이번에는 개정 공지를 공식 블로그·자격증 페이지·docs 비교 페이지 3곳에서 교차 확인했다.

---

## 3. 가이드 URL

| 구분 | URL | 상태(2026-10-17) |
|---|---|---|
| C01 한국어 가이드(레포 `sourceUrl`) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | 200 (정본) |
| C01 도메인 1~4 (ko) | …/machine-learning-engineer-associate-01-domain1.html ~ -domain4.html | 200 |
| C01 범위 내/외 서비스 (ko) | …/mla-01-in-scope-services.html , …/mla-01-out-of-scope-services.html | 200 |
| C01 영문 HTML 가이드 | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html | **404** |
| C01 영문 PDF (Version 1.0) | https://d1.awsstatic.com/training-and-certification/docs-machine-learning-engineer-associate/AWS-Certified-Machine-Learning-Engineer-Associate_Exam-Guide.pdf | 200 |
| C01 일본어·중국어 가이드 | https://docs.aws.amazon.com/ja_jp/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html , …/zh_cn/… | 200 |
| **C02 영문 가이드** | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 200 |
| **C02 한국어 가이드** | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 200 |
| **C01↔C02 비교(영문)** | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html | 200 |
| 자격증 소개(응시료·시간·언어·일정) | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 200 |
| C02 개정 공지 블로그 2건 | https://aws.amazon.com/blogs/training-and-certification/updates-to-aws-certified-machine-learning-engineer-associate-mla-c02/ , https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 200 |

**공식 자격증명**: "AWS Certified Machine Learning Engineer - Associate". C01과 C02가 **같은 이름**이며 개명은 확인되지 않았다(M1, C10). 자격증 페이지의 표기는 하이픈(-)과 en 대시(–)가 섞여 있다.

---

## 4. 레포 `MLA-C01.json` ↔ 공식 페이지 대조 결과

**방법**: 공식 ko_kr 가이드의 `.md` 렌디션(메인 + 도메인 1~4)을 내려받아 파싱하고, JSON의 모든 문자열과 **공백 정규화 후 완전 일치**로 비교했다(스크립트로 기계 대조, 2026-10-17).

**결과: 본문 불일치 0건.** 도메인 이름·비중 4/4, Task 제목 12/12, 지식 63/63, 기술 70/70 모두 일치.

**`overview` 수치 대조(모두 일치)**:

| JSON 필드 | JSON 값 | 공식 값 | 대조 | 근거 |
|---|---|---|---|---|
| `level` | Associate | Associate | 일치 | 〔M1〕 |
| `scoredQuestions` | 50 | 50 | 일치 | 〔M2〕 |
| `unscoredQuestions` | 15 | 15 | 일치 | 〔M3〕 |
| `passingScore` | 720 | 720 (100~1,000 환산) | 일치 | 〔M6, M7〕 |
| `durationMinutes` | 130 | 130 | 일치 — 단 근거는 가이드가 아니라 자격증 소개 페이지 | 〔M5〕 |
| `domains[].weightPct` | 28 / 26 / 22 / 24 | 28 / 26 / 22 / 24 | 일치 | 〔M15~M18〕 |

**JSON에 없는 항목(수정 제안)** — 상세는 `99-gaps.md` 의 "JSON 수정 제안":
1. `overview` 에 문항 유형(4종, PDF는 5종), 총 문항 65, 응시료 150 USD, 유효 기간 3년, 응시 언어, 시험 코드가 없다.
2. **개정 공지 필드가 없다** — 후속 시험 MLA-C02, 영문 C01 종료일(2026-09-28), C01 전 언어 종료일(2027-01-14).
3. `durationMinutes: 130` 은 가이드가 아니라 자격증 페이지 출처다(출처 URL 분리 필요).
4. 도메인 4 Skill의 "Amazon Quick Sight" 는 공식 ko 가이드 원문 그대로다. 서비스 현재 명칭은 'Amazon Quick'(Quick Sight는 그 안의 BI 기능). **원문은 바꾸지 말고** 표시 시점에 보조 주석으로만 처리하길 권한다.

---

## 5. MLA-C02 개정 요약 (공식 비교 페이지 기준)

비교 페이지: https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html (한국어: …/ko_kr/…/mla-02-comparison.html) — 도메인 구성 동일(비중은 변경), Task 번호 1:1 대응. **추가 스킬 45개 전문(영문+한국어)·삭제 7개·범위 내 서비스 변화·"붙일 C01 Task"는 `97-c02-delta.md`** 에 정리했다.

| C01 Task | C02 대응 Task (공식 영문 제목) |
|---|---|
| 1.1 데이터를 수집 및 저장 | 1.1 Collect and store data. |
| 1.2 데이터 변환 및 특성 추출 수행 | 1.2 Perform data transformation, feature engineering, and pre-processing. |
| 1.3 데이터 무결성을 보장하고 모델링을 위한 데이터 준비 | 1.3 Validate data quality and manage bias. |
| 2.1 모델링 접근 방식 선택 | 2.1 Choose appropriate modeling approaches for ML and AI solutions. |
| 2.2 모델 훈련 및 개선 | 2.2 Train, fine-tune, and customize models for ML and AI solutions. |
| 2.3 모델 성능 분석 | 2.3 Analyze and evaluate the performance of ML and AI systems. |
| 3.1 배포 인프라 선택 | 3.1 Manage deployment infrastructure for ML and AI model types. |
| 3.2 인프라 만들기 및 스크립팅 | 3.2 Provision and configure resources for ML and AI workloads based on existing architecture and requirements. |
| 3.3 CI/CD 파이프라인 설정 | 3.3 Implement automated orchestration and continuous integration and continuous delivery (CI/CD) pipelines for MLOps and AI workloads. |
| 4.1 모델 추론 모니터링 | 4.1 Monitor ML and AI model inference and performance. |
| 4.2 인프라 및 비용 모니터링·최적화 | 4.2 Optimize and manage ML and AI infrastructure costs and performance. |
| 4.3 AWS 리소스 보호 | 4.3 Secure ML and AI workloads and model endpoints. |

**C02에서 삭제되는 C01 내용(공식 비교 페이지 'Deletions')** — C01 학습문서에서 비중을 낮춰도 되는 후보:
- 1.3: 모델 훈련 리소스로 데이터 로드(EFS·FSx)
- 2.2: 사용자 지정 데이터세트로 사전 훈련 모델 미세 조정(Bedrock·JumpStart) · 모델 크기 축소(데이터 형식 변경·가지치기·특성 선택·압축) — 공식 비교 페이지는 이 둘을 '삭제'로 분류하지만, 같은 페이지가 2.1.2(FM 미세 조정 전략 파악)·2.2.8(미세 조정 등 사용자 지정 기법 적용)을 '추가'로 나열한다.
- 3.1: 엣지 디바이스 모델 최적화(SageMaker Neo)
- 3.2: SageMaker BYOC
- 4.2: EventBridge 이벤트로 인프라 모니터링 · 비용·성능 관련 용량 문제 해결(프로비저닝된 동시성·서비스 할당량·오토 스케일링)

**C02에 추가되는 영역**: RAG·벡터 DB(OpenSearch·RDS pgvector·S3), 임베딩, FM 선택·파인튜닝·평가(BLEU·ROUGE·BERTScore·LLM-as-a-judge), Bedrock 지식 기반·프롬프트 관리·가드레일, 에이전트 배포·상태 관리·모니터링, GPU 워크로드 스케일링, FM 추론 비용, CI/CD 취약점 점검(CodeGuru·Inspector), FM 자격 증명 유형(Bedrock API 키·IAM). 항목별 원문은 각 Task 파일의 섹션 8.

| # | 항목 | 값/내용 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| C1 | C02 베타 일정 | 베타 등록 2026-09-01(영문), C01 영문 마지막 응시 2026-09-28, 베타 시험 시작 2026-09-29 | "September 29, 2026 – Beta delivery begins" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |
| C2 | C02 GA 및 C01 전 언어 종료 | **2027-01-14** | "January 14, 2027 – GA delivery begins (all languages); MLA-C01 retired in all languages" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |
| C3 | 다른 공지의 GA 표현 | '2027년 초'(구체 일자 없음) — 위 C2와 모순은 아님 | "will be available in early 2027" | https://aws.amazon.com/blogs/training-and-certification/updates-to-aws-certified-machine-learning-engineer-associate-mla-c02/ | 2026-10-17 |
| C4 | 자격증 페이지의 GA 표현 | GA 일정 'TBD' (C2와 표현 불일치, gaps) | "TBD: GA registration opens" | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| C5 | C02 베타 문항 수 | 85문항 | "Number of questions: 85" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |
| C6 | C02 베타 시험 시간 | 170분 | "Duration: 170 minutes" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |
| C7 | C02 베타 응시료 | 75 USD(베타 가격), 영문만 | "Price: $75 USD" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |
| C8 | C02 사양 공지 상태 | 자격증 페이지 표의 C02 열은 '베타' 사양(170분·85문항·$75)뿐이며 GA 사양은 미공지 | "Registration is now open for the updated exam (MLA-C02) beta." | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| C9 | C02 도메인 2 비중 | 24% (C01은 26%) | "Content Domain 2: ML Model and Foundation Model (FM) Development (24% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| C10 | C02 도메인 3 비중 | 24% (C01은 22%) | "Content Domain 3: Deployment and Orchestration of ML and AI Workflows (24% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| C11 | C02 한국어 가이드 존재 | ko_kr C02 가이드 페이지 열람 가능 | "AWS Certified Machine Learning Engineer - Associate(MLA-C02)" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| C12 | C02 문항 유형 | 가이드에 선다형·복수 응답 2종만 기재(순서 배열·매칭·Case study 없음) | "Multiple response: Has two or more correct responses out of five or more response options." | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| C13 | C02 채점 사양 | 채점 50 + 비채점 15, 합격 720(베타는 합격/불합격 미적용) | "The minimum passing score is 720." | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| C14 | C02 추가 영역 | 에이전트 AI | "Agentic AI: Orchestrating AI agents and complex workflows" | https://aws.amazon.com/blogs/training-and-certification/updates-to-aws-certified-machine-learning-engineer-associate-mla-c02/ | 2026-10-17 |
| C15 | C02의 도메인 **구성** | 도메인 4개 유지(구성 동일). **비중은 다르다** — C01 28/26/22/24 → C02 28/24/24/24 (C9·C10) | "The domain structure of the exam remains the same." | https://aws.amazon.com/blogs/training-and-certification/updates-to-aws-certified-machine-learning-engineer-associate-mla-c02/ | 2026-10-17 |
| C16 | C01 영문 종료 | 2026-09-28 | "MLA-C01 in English is available through September 28, 2026." | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| C17 | C01 한·일·중 | C02 GA까지 응시 가능(C2와 함께 읽을 것) | "MLA-C01 in Korean, Japanese, and Simplified Chinese remains available until general availability of MLA-C02." | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| C18 | C02 시험의 추가 응시 언어 | 한국어 등은 **GA 시점**에 제공(가이드 문서의 한국어판 공개와는 별개) | "Additional languages (Japanese, Korean, and Simplified Chinese) will be available at general availability" | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| C19 | C02 한국어 비교 페이지 존재 | ko_kr 비교 페이지 열람 가능 | "MLA-C01 및 MLA-C02 비교" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html | 2026-10-17 |

> 같은 블로그(September 2026)는 **DVA-C03**(DVA-C02 마지막 응시 2026-11-30, DVA-C03 GA 2026-12-01)와 **SAP-C03**(SAP-C02 마지막 응시 2026-11-16, GA 2026-11-17)도 공지했다. MLA 범위 밖이라 조사하지 않았다(부수 발견).

---

## 6. 구/신 서비스 명칭 대응표

| # | 구 → 신(현재) | 시점·비고 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| N1 | Amazon SageMaker → **Amazon SageMaker AI** | 2024-12-03. API 네임스페이스·CLI·`AmazonSageMaker*` 관리형 정책·`AWS::SageMaker::*`·콘솔/문서 URL의 `sagemaker` 는 그대로 | "On December 03, 2024, Amazon SageMaker was renamed to Amazon SageMaker AI" | https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html | 2026-10-17 |
| N2 | (신) **Amazon SageMaker** = 통합 데이터·분석·AI 플랫폼(SageMaker Unified Studio·Lakehouse 포함) | 구 SageMaker와 이름이 같아 혼동 주의. SageMaker AI는 그 구성요소 | "Amazon SageMaker AI (formerly Amazon SageMaker)" | https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html | 2026-10-17 |
| N3 | SageMaker Data Wrangler(Studio Classic 기능) → **SageMaker Canvas 안으로 통합** | 새 Studio에서는 Canvas로 접근 | "Amazon SageMaker Data Wrangler has been integrated into Amazon SageMaker Canvas" | https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler.html | 2026-10-17 |
| N4 | Kinesis Data Firehose → **Amazon Data Firehose** | 2024-02-09 | "Amazon Data Firehose was previously known as Amazon Kinesis Data Firehose" | https://docs.aws.amazon.com/cli/latest/reference/firehose/index.html | 2026-10-17 |
| N5 | Kinesis Data Analytics → **Amazon Managed Service for Apache Flink** | 2023-08-30 | "the rename of Amazon Kinesis Data Analytics to Amazon Managed Service for Apache Flink" | https://aws.amazon.com/blogs/aws/announcing-amazon-managed-service-for-apache-flink-renamed-from-amazon-kinesis-data-analytics/ | 2026-10-17 |
| N6 | Amazon QuickSight → Amazon Quick Suite(2025-10) → (현재 문서 표기) **Amazon Quick** | QuickSight는 Quick 안의 BI 기능 'Quick Sight'로 존속. 가이드: ko Skill 'Amazon Quick Sight' / ko 범위 내 'Amazon Quick' / 영문 PDF 'Amazon QuickSight'. Quick Suite→Quick **개명 공지 자체는 미확인**(gaps) | "Amazon QuickSight evolves to Amazon Quick Suite" | https://aws.amazon.com/blogs/business-intelligence/reimagine-business-intelligence-amazon-quicksight-evolves-to-amazon-quick-suite/ | 2026-10-17 |
| N7 | AWS Chatbot → **Amazon Q Developer (in chat applications)** | 2025-02-19. 가이드 범위 내 목록은 아직 'AWS Chatbot' | "As of February 19, 2025, AWS Chatbot is now named Amazon Q Developer" | https://aws.amazon.com/q/developer/faqs/ | 2026-10-17 |
| N8 | 이전 SageMaker Studio → **SageMaker Studio Classic**(2023-11-30), 새 Studio가 기본 | Classic은 신규 온보딩 불가 | "Studio Classic is still maintained for existing workloads but is no longer available for onboarding" | https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-resources.html | 2026-10-17 |
| N9 | Amazon Q Business → 후속 **Amazon Quick**(Q Business는 신규 고객 중단) | 가이드 범위 내 'Amazon Q' 항목의 해석 주의 | "Amazon Quick represents the next evolution of Amazon Q Business" | https://docs.aws.amazon.com/amazonq/latest/qbusiness-ug/qbusiness-availability-change.html | 2026-10-17 |

---

## 7. 가이드 범위 내 서비스·기능의 현재 상태 (수명 점검)

AWS 수명 용어(공식): **Maintenance**(신규 온보딩 불가, 기존 고객은 계속 사용) · **Sunset**(종료일 공지) · **Full Shutdown**(완전 제거). 정의: https://docs.aws.amazon.com/general/latest/gr/service-lifecycle.html

| # | 서비스/기능 (C01 가이드 관련 Task) | 상태 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| L0 | **SageMaker AI 기능 묶음**: Mechanical Turk, Ground Truth, Augmented AI, Studio Lab, Model Monitor, Clarify, Debugger, Role Manager, Geospatial, Profiler | **2026-07-30부터 신규 고객 불가**(AWS 공식 'End of Support Notice') | "will no longer be open to new customers starting on July 30, 2026" | https://aws.amazon.com/sagemaker/ai/features/ | 2026-10-17 |
| L0b | 위 묶음 외 SageMaker AI 기능(Feature Store·Pipelines·Model Registry·JumpStart·Canvas·학습·추론 등) | **영향 없음**(공식 명시) | "This does not impact the availability of other Amazon SageMaker AI features" | https://aws.amazon.com/sagemaker/ai/features/ | 2026-10-17 |
| L1 | **Clarify** (1.3, 2.3, 4.1) | 신규 고객 중단. 공지 페이지가 대체 경로 안내 | "Amazon SageMaker Clarify is no longer open to new customers" | https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html | 2026-10-17 |
| L2 | **Model Monitor** (4.1, 3.3) | 신규 고객 중단 | "Amazon SageMaker Model Monitor is no longer open to new customers" | https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-availability-change.html | 2026-10-17 |
| L3 | **Role Manager** (4.3) | 신규 고객 중단 | "Amazon SageMaker Role Manager is no longer open to new customers" | https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager-availability-change.html | 2026-10-17 |
| L4 | **Profiler** (2.2, 2.3) | **2027-06-30 지원 종료 예고**(Sunset) | "On June 30, 2027, AWS will end support for Amazon SageMaker Profiler" | https://docs.aws.amazon.com/sagemaker/latest/dg/profiler-availability-change.html | 2026-10-17 |
| L5 | **Debugger** (2.3) | 신규 고객 중단 | "Amazon SageMaker Debugger is no longer open to new customers" | https://docs.aws.amazon.com/sagemaker/latest/dg/debugger-availability-change.html | 2026-10-17 |
| L6 | **Ground Truth** (1.2) | 신규 고객 중단 | "Amazon SageMaker Ground Truth is no longer open to new customers" | https://docs.aws.amazon.com/sagemaker/latest/dg/sms-streaming-labeling-job.html | 2026-10-17 |
| L7 | **Augmented AI (A2I)** (1.2, 2.1) | 유지보수(2026-07~) | "A2I entered maintenance mode in July 2026 and no longer accepts new customers" | https://docs.aws.amazon.com/textract/latest/APIReference/API_HumanLoopConfig.html | 2026-10-17 |
| L8 | **Ground Truth Plus** (1.2) | **지원 종료 2026-06-30** | "have reached end of support and are no longer available as of June 30, 2026" | https://aws.amazon.com/about-aws/whats-new/2026/06/aws-service-availability/ | 2026-10-17 |
| L9 | **Amazon Mechanical Turk** (1.2) | **폐쇄**. SageMaker 문서는 9/30, What's New는 9/29(하루 차이, gaps) | "Amazon Mechanical Turk will permanently close on September 30, 2026" | https://docs.aws.amazon.com/sagemaker/latest/dg/sms-workforce-management.html | 2026-10-17 |
| L10 | **SageMaker Edge Manager** (3.1) | 2024-04-26 종료. Neo는 별개 | "SageMaker AI Edge Manager was discontinued on April 26th, 2024" | https://docs.aws.amazon.com/greengrass/v2/developerguide/sagemaker-edge-manager-component.html | 2026-10-17 |
| L11 | **Elastic Inference** (3.1) | 종료 | "Amazon Elastic Inference is no longer available" | https://aws.amazon.com/blogs/machine-learning/increasing-performance-and-reducing-the-cost-of-mxnet-inference-using-amazon-sagemaker-neo-and-amazon-elastic-inference/ | 2026-10-17 |
| L12 | **Fraud Detector**, **CodeGuru Reviewer** (2.1, 4.3) | 신규 고객 중단(2025-11-07~) | "will no longer be accessible to new customers starting Nov 7, 2025" | https://aws.amazon.com/about-aws/whats-new/2025/10/aws-service-availability/ | 2026-10-17 |
| L13 | **Lookout for Equipment** (2.1) | 2026-10-07 지원 종료(오늘 기준 이미 종료) | "On October 7, 2026, AWS will discontinue support for Amazon Lookout for Equipment" | https://docs.aws.amazon.com/lookout-for-equipment/latest/ug/the-right-app.html | 2026-10-17 |
| L14 | **Lookout for Vision** (2.1) | 2025-10-31 종료 | "will be discontinuing on October 31, 2025" | https://aws.amazon.com/blogs/machine-learning/exploring-alternatives-and-seamlessly-migrating-data-from-amazon-lookout-for-vision/ | 2026-10-17 |
| L15 | **Lookout for Metrics** (2.1) | 2025-10-10 지원 종료 | "end support for Amazon Lookout for Metrics, effective October 10, 2025" | https://aws.amazon.com/blogs/machine-learning/transitioning-off-amazon-lookout-for-metrics/ | 2026-10-17 |
| L16 | **Amazon Forecast** (2.1; 가이드 범위 내 목록에는 없음) | 신규 고객 불가(2024-07-29~), 대안 SageMaker Canvas | "Amazon Forecast is no longer available to new customers" | https://docs.aws.amazon.com/forecast/latest/dg/tutorials.html | 2026-10-17 |
| L17 | **Kendra**, **Q Business** (2.1) | 신규 고객 중단(2026-07-30~) | "will no longer be accessible to new customers starting July 30, 2026" | https://aws.amazon.com/about-aws/whats-new/2026/06/aws-service-availability/ | 2026-10-17 |
| L18 | **DevOps Guru** (2.1) | Sunset — 지원 종료 2027-09-30 | "Amazon DevOps Guru (end of support September 30, 2027)" | https://aws.amazon.com/about-aws/whats-new/2026/09/aws-service-availability/ | 2026-10-17 |
| L19 | **Comprehend** 일부 기능, **Rekognition** 일부 기능 (2.1) | 신규 고객 중단(2026-04-30~): 토픽 모델링·이벤트 탐지·프롬프트 안전 분류 / 스트리밍 이벤트·배치 이미지 콘텐츠 중재 | "Amazon Comprehend - Topic Modeling, Event Detection, and Prompt Safety Classification Features" | https://aws.amazon.com/about-aws/whats-new/2026/03/aws-service-availability/ | 2026-10-17 |
| L20 | **CloudTrail Lake** (4.2, 4.3) | 신규 고객 중단(2026-05-31~) | "CloudTrail Lake will stop accepting new customers on May 31, 2026" | https://aws.amazon.com/about-aws/whats-new/2026/03/aws-service-availability/ | 2026-10-17 |
| L21 | **CodeCommit** (3.3) | 2024-07-25 신규 중단 → **2025-11-25 신규 고객 재개** | "AWS CodeCommit is now available to new customers" | https://docs.aws.amazon.com/codecommit/latest/userguide/history.html | 2026-10-17 |

- 위 공지 4건(2025-10-13 · 2026-03-31 · 2026-06-30 · 2026-09-29)에 **나타나지 않은** 가이드 범위 내 서비스(예: Lex·Polly·Textract·Transcribe·Translate·Personalize·Comprehend Medical·HealthLake·DataBrew·Glue Data Quality·Lake Formation)는 이 4건 기준으로 상태 변화가 없다. (다른 공지가 있는지는 개별 서비스 페이지로 추가 확인 필요 — gaps)
- 범위 **외** 서비스 목록(GuardDuty·Inspector·Security Hub·WAF·Artifact·Audit Manager·Shield·IoT Greengrass 등)은 시험에서 깊게 묻지 않는다. 보안·배포 Task에서는 '혼동 짝'으로만 쓰인다.

---

## 8. 가이드 문구 주의점 (한국어 번역·표기)

영문 PDF(Version 1.0)와 한국어 가이드를 대조해 확인한 것들이다. 문항 `skill` 필드에는 **한국어 원문 그대로** 쓰고, 의미는 아래를 참고한다.

1. 범위 외 직무 "모델 정량화 및 정확도에 미치는 영향 분석" ← 영문 "Quantizing models and analyzing the impact on accuracy". *quantizing* 은 **양자화**(가중치를 낮은 정밀도로 표현)이며 '정량화'가 아니다.
2. Task 1.2 지식 "레이블이 지정된 고품질 데이터세트를 만들기하는 데이터 주석…" — 문법이 깨진 번역(원문: *services that create high-quality labeled datasets*). 원문 보존.
3. Task 3.2 기술 "…엔드포인트 뒤에서 Lambda 사용으로 스팟 인스턴스 동적 추가" ← 영문은 **나열 형식**: "automatic scaling on SageMaker endpoints, dynamically adding Spot Instances, by using Amazon EC2 instances, by using Lambda behind the endpoints". 한국어는 뒤 항목들을 한 문장으로 합쳐 모호하다. 해당 Task 노트(3-2)에서 근거 문서를 확인.
4. Task 4.2 기술 "SageMaker AI 절감형 플랜" ← 영문 PDF "SageMaker Savings Plans". 이름 표기 차이(개명 반영).
5. 용어: *imputing* → "임퓨팅", *convergence* → "컨버전스", *shadow variant* → "섀도 변형", *ML lens* → "ML 렌즈"(= AWS Well-Architected **Machine Learning Lens**), *binning* → "비닝".
6. Task 3.1 제목이 문장형("…선택합니다.")인 것은 번역 문체 차이일 뿐이다(영문: "Select deployment infrastructure…").
7. 서비스 표기: Task 본문은 'SageMaker AI'인데 **범위 내 서비스 목록은 'Amazon SageMaker'** 로 남아 있다. 영문 PDF는 전체가 'SageMaker'. 이름이 섞여 보여도 같은 서비스다(N1).
8. 가이드의 'AWS 인공 지능 서비스' 예시(Translate·Transcribe·Rekognition·Bedrock)는 그대로 유효하나 같은 범위 목록에 있는 Lookout·Fraud Detector·DevOps Guru·CodeGuru 등은 §7의 상태 변화가 있다.

---

## 9. 산출물 색인

- 이 표는 12개 노트에서 스크립트로 집계했다(수작업 아님). '고유 출처'는 Task별 섹션 7의 고유 URL 수다.
- 별도 산출물: `97-c02-delta.md`(C02 델타), `99-gaps.md`(상충·확인 필요 + JSON 수정 제안).

**노트 읽는 순서 (각 노트가 100KB 안팎이라 처음부터 읽지 말 것)**

1. 섹션 1 — 공식 지식·기술 원문과 K#/SK# 번호(저작 앵커). 이 번호가 섹션 2 커버리지 매트릭스·섹션 6 후보 문항의 `대응 Skill` 과 연결된다.
2. 섹션 2 — 핵심 개념(소절 8~15개, 표 초안·🧠 원리·⚠️ 수명 표시). **학습문서의 본문 재료**다. 소절 번호는 `2.0 커버리지 매트릭스`에서 찾는다.
3. 섹션 3·4 — 출제 패턴(2~4개)과 혼동 짝(8~12개). 문항·'흔한 함정' 절의 재료.
4. 섹션 6 — 자가 점검 후보 5개(4지선다, 정답·근거·오답 근거). **완성 문항이 아니며 `verified` 판정은 사람 몫.**
5. 섹션 9 — 확인 필요 항목. **상충하는 수치·문서 간 불일치가 여기 있다 — 문항 근거로 쓰기 전에 반드시 읽을 것.**
6. 섹션 5(사실·숫자)·섹션 7(출처) — 조회용 참고표다. 수치를 인용할 때 `F#`·`S#` 로 찾아가고, 처음부터 끝까지 읽을 필요는 없다.
7. 섹션 8 — C02 개정 영향(공식 비교 페이지 원문). 부록 작성용.

| Task | 파일 (크기·줄) | 지식 / 기술 | 고유 출처 | 사실 행 (수동) | 후보 문항 | 확인 필요 |
|---|---|---|---:|---:|---:|---:|
| 1.1 데이터를 수집 및 저장 | `tasks/1-1.md` (152KB·915줄) | 4 / 6 | 94 | 171 (0) | 5 | 15 |
| 1.2 데이터 변환 및 특성 추출 수행 | `tasks/1-2.md` (155KB·925줄) | 6 / 3 | 102 | 174 (0) | 5 | 17 |
| 1.3 데이터 무결성을 보장하고 모델링을 위한 데이터 준비 | `tasks/1-3.md` (153KB·859줄) | 5 / 4 | 96 | 206 (0) | 5 | 16 |
| 2.1 모델링 접근 방식 선택 | `tasks/2-1.md` (173KB·939줄) | 4 / 5 | 110 | 204 (4) | 5 | 17 |
| 2.2 모델 훈련 및 개선 | `tasks/2-2.md` (193KB·1061줄) | 8 / 9 | 89 | 203 (0) | 5 | 24 |
| 2.3 모델 성능 분석 | `tasks/2-3.md` (149KB·902줄) | 5 / 6 | 86 | 100 (0) | 5 | 11 |
| 3.1 기존 아키텍처 및 요구 사항에 따라 배포 인프라를  | `tasks/3-1.md` (133KB·874줄) | 7 / 6 | 98 | 208 (0) | 5 | 16 |
| 3.2 기존 아키텍처 및 요구 사항을 기반으로 인프라 만들 | `tasks/3-2.md` (125KB·748줄) | 5 / 6 | 90 | 100 (0) | 5 | 13 |
| 3.3 자동화된 오케스트레이션 도구를 사용하여 지속적 통합 | `tasks/3-3.md` (141KB·1001줄) | 6 / 6 | 81 | 120 (0) | 5 | 15 |
| 4.1 모델 추론 모니터링 | `tasks/4-1.md` (126KB·875줄) | 3 / 4 | 65 | 97 (0) | 5 | 17 |
| 4.2 인프라 및 비용 모니터링 및 최적화 | `tasks/4-2.md` (169KB·869줄) | 6 / 10 | 89 | 212 (0) | 5 | 15 |
| 4.3 AWS 리소스 보호 | `tasks/4-3.md` (139KB·910줄) | 4 / 5 | 96 | 100 (0) | 5 | 15 |
| **합계** | 12개 | 63 / 70 | 1096(Task 간 중복 포함) | 1895 (4) | 60 | 191 |

---

## 10. 검증 기록

**방법**: 모든 사실 행(`| F# | 항목 | 값 | "인용" | URL | 조회일 |`)의 인용문이 출처 URL의 **실제 페이지 텍스트에 존재하는지** 스크립트로 전수 대조했다(출처 URL의 HTML 텍스트에서 부분 문자열 검색, 대소문자·공백·문장부호 무시, 인용은 15단어 이하). 수집은 2026-10-17에 했고, 이 대조는 2026-10-19에 다시 실행했으며 모두 일치했다(10-17 조회분이 10-19에도 유효).

| 산출물 | 사실 행 | 자동 일치 | 수동 | 불일치 | 비고 |
|---|---:|---:|---:|---:|---|
| Task 노트 12개 | 1,895 | 1,891 | 4 | 0 | 수동 4행(2.1 F84~F87)은 AWS 백서 원문을 직접 열어 확인 |
| `00-overview.md` | 72 | 70 | 2 | 0 | 수동 2행(V1, M14)은 영문 PDF를 `pdftotext` 로 직접 확인 |
| `97-c02-delta.md` | 31 | 31 | 0 | 0 | C02 Task 제목·추가 45·삭제 7(영문+한국어 64쌍)은 공식 비교 페이지 원문과 문자열 대조 — 불일치 0 |
| `99-gaps.md` | 5 | 5 | 0 | 0 | |

**보조 점검**
- **값-인용 정합성**: 인용이 맞아도 '값' 칸에 잘못 옮긴 숫자가 있을 수 있어, 값의 숫자가 인용에 없으면 출처 **페이지 전체**에서 다시 찾았다(1차 의심 약 100행 → 2차 약 50행). 남은 행은 사람이 판정했다. 한글 단위("200,000행")·영어 숫자("zero", "one-year")·직접 센 개수("4종")·참조 번호("G-2.2-3")가 만든 오탐이었고 **값이 틀린 행은 없었다.** 값이 중요한 행(2.2 F115·F84·F12, 4.1 오프셋 예시, 4.2 F32·F92 등)은 출처 문장을 직접 열어 일치를 확인했다.
- **후보 문항**: 12개 노트의 후보 60개를 모두 읽어 정답 키와 오답 근거의 정합성을 점검했고 정답 키 오류는 발견하지 못했다. 단 '읽어서 점검'한 것이지 항목마다 공식 문서와 다시 대조한 것은 아니다.
- 골격 자리표시자 잔존 없음, 섹션 1(공식 원문)은 JSON과 일치, 섹션 8(C02 개정 영향) 12/12 채움.
- JSON ↔ 공식 가이드 대조(§4, `compare_json_to_official`): 불일치 0건.
- **수집 경위**: 서브에이전트 12개가 2026-10-17 계정 한도(HTTP 429)로 중단돼 8개를 2026-10-19에 재개했고, 재개 후 12개 모두 위 검증을 통과했다.

**한계**
- 인용이 페이지에 있다는 것은 그 인용을 둘러싼 **서술이 올바르다는 보증이 아니다.** 노트 본문(섹션 2~4)의 서술은 표본 검토만 했다. 확인하지 못한 정의·상충하는 수치는 각 노트 섹션 9와 `99-gaps.md` 에 남겼다.
- 후보 문항은 재료이며 `verified` 판정은 사람이 해야 한다.
- 공식 문서끼리 상충하는 수치(예: 실시간 엔드포인트 페이로드 25 MB vs 6 MB, KDS 레코드 10 MiB vs 1 MB, S3 객체 5 TB vs 50 TB)는 한쪽을 고르지 않고 병기했다. 이런 수치를 문항의 정답 근거로 쓰지 말 것.
