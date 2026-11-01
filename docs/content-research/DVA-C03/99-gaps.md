# 99 — DVA-C03 확인 필요 (Phase 2 집계)

> 조회일 **2026-11-01**. 각 노트의 `## 확인 필요`를 한곳에 모았다. **여기 있는 항목은 학습문서·문항에 쓰지 않는다** — 공식 문서로 확인된 뒤에 쓴다.
> ID는 Phase 3에서 참조하기 위한 것이다.

## 차단급 — 이것이 열리기 전에는 그 Skill 문항을 쓸 수 없다

| ID | 항목 | 출처 노트 | 왜 차단인가 |
|---|---|---|---|
| **G-01** | **Skill 4.3.6(AI로 최적화 기회 식별)에 대응하는 AWS 도구를 특정하지 못했다.** CloudWatch investigations는 문제 해결(4.1.5) 쪽이고, Compute Optimizer는 **in-scope 목록에 없다** | [96](96-ai-assisted-dev.md) | 도구를 모르면 문항의 정답 보기를 만들 수 없다 |
| **G-02** | **EKS 매니페스트 배포 절차**를 조사하지 못했다 | [95](95-containers.md) | Skill 3.3.2가 예시로 드는데 노트는 ECS 쪽만 담았다 |
| **G-03** | **`exam_guides/DVA-C03.json`의 시험 시간** — 가이드 본문(영문·한국어 양쪽)에 없다 | [00](00-overview.md) §1·§8 | JSON을 만들 수 없다. 인증 페이지 등 별도 공식 출처 필요 |

## 정본 보강 — 사실은 확보했으나 출처가 약하다

| ID | 항목 | 출처 노트 |
|---|---|---|
| **G-04** | **Kiro 공식 문서가 `docs.aws.amazon.com`에 있는지** 확인하지 못했다. 현재 근거는 AWS 블로그·repost이고 세부는 `kiro.dev`를 가리킨다. CLI 플래그·`ksk_` 키 형식을 학습문서에 쓰려면 정본을 찾는다 | [96](96-ai-assisted-dev.md) |
| **G-05** | **`minimumHealthyPercent`가 Fargate에서 쓰이지 않는다**는 서술의 근거가 Security Hub 모델의 SDK 레퍼런스다. **ECS 개발자 가이드 본문**에서 다시 확인한다 | [95](95-containers.md) |
| **G-06** | **AgentCore Identity 개발자 가이드 정본** — 현재 출처가 콘솔 도움말 패널 경로다 | [2-3](tasks/2-3.md) |

## 판정 필요 — 사실은 확인됐으나 어떻게 쓸지 정해야 한다

| ID | 항목 | 출처 노트 |
|---|---|---|
| **G-07** | **`Amazon Quick`이 DVA 문항에 어떤 모습으로 나올지** 단정할 수 없다. 개발 도구가 아닌데 ML/AI in-scope에 있고, 그 BI 구성 요소인 **Quick Sight는 out-of-scope**다 | [96](96-ai-assisted-dev.md) §0 |
| **G-08** | **`AWS Copilot`이 Skill 3.2.4 예시에 그대로 남아 있다.** in-scope 서비스 목록에는 **없고** CLI는 2026-06-12 지원 종료다. 문항에 쓸지 말지 | [97](97-c02-c03-remap.md) §4 |
| **G-09** | **도메인 1의 공식 한국어 표기가 한 페이지 안에서 갈린다** — Topics는 "AWS 서비스를 **통한** 개발", 내용 개요는 "AWS 서비스를 **사용한** 개발". JSON·학습문서에 넣기 전에 한쪽으로 정한다 | [00](00-overview.md) §2 |
| **G-10** | **Skill 3.1.2의 "Docker files"** — AWS 공식 문서 기준의 Dockerfile 모범 사례를 찾지 못했다. 일반 Docker 지식과 AWS 고유 사실의 경계를 정해야 한다 | [95](95-containers.md) |

## 세부 미확인 — 문항 품질에 영향

| ID | 항목 | 출처 노트 |
|---|---|---|
| **G-11** | **`InvokeGuardrailChecks` API** — Bedrock FAQ만 언급하고 사용자 가이드에서 확인하지 못했다. 그때까지는 **`ApplyGuardrail`만** 쓴다 | [2-3](tasks/2-3.md) |
| **G-12** | **Guardrails Classic/Standard 티어 선택 기준**(가격·가용성) | [2-3](tasks/2-3.md) |
| **G-13** | Skill 문구의 ***session isolation*** 이 AgentCore의 세션 기반 정책·WIC를 가리키는지 Runtime 세션 분리를 가리키는지 | [2-3](tasks/2-3.md) |
| **G-14** | **AgentCore 로그의 민감 콘텐츠 보호** — 2.3.5를 Bedrock 모델 호출 로깅 기준으로 정리했다. AgentCore 쪽에 같은 통제가 있는지 | [2-3](tasks/2-3.md) |
| **G-15** | ⚠️ **"IAM 인스턴스 프로파일 6시간 / STS 36시간"은 S3 on Outposts 문서의 수치다** — 표준 S3에 옮겨 쓰지 않는다. 표준 S3 기준 상한을 따로 확인한다 | [94](94-presigned-and-privatelink.md) |
| **G-16** | **CloudFront 서명 URL의 만료 상한**을 공식 수치로 확인하지 못했다 | [94](94-presigned-and-privatelink.md) |
| **G-17** | **Kiro Crew·Powers의 공식 정의** — 블로그 수준 서술만 확보했다 | [96](96-ai-assisted-dev.md) |
| **G-18** | CloudFront **키 페어 교체 절차** — 목차만 확인했다 | [94](94-presigned-and-privatelink.md) |

---

## 출처 등급 규율 (이 폴더 공통)

- **동작·수치 단정은 `docs.aws.amazon.com` 본문**에서만 가져왔다.
- **AWS 블로그·repost**는 제품 구성·날짜·권장값 서술에만 썼고, 쓴 자리마다 노트에 표시했다.
- 그 밖의 출처는 쓰지 않았다.
