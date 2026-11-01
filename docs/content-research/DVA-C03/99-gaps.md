# 99 — DVA-C03 확인 필요 (Phase 2 집계)

> 조회일 **2026-11-01**. 각 노트의 `## 확인 필요`를 한곳에 모았다. **여기 있는 항목은 학습문서·문항에 쓰지 않는다** — 공식 문서로 확인된 뒤에 쓴다.
> ID는 Phase 3에서 참조하기 위한 것이다.

## 차단급 — 이것이 열리기 전에는 그 Skill 문항을 쓸 수 없다

| ID | 항목 | 출처 노트 | 상태 |
|---|---|---|---|
| **G-03** | **`exam_guides/DVA-C03.json`의 시험 시간** — 가이드 본문(영문·한국어 양쪽)에 없다 | [00](00-overview.md) §1·§8 | **열림.** JSON을 만들 수 없다. 인증 페이지 등 별도 공식 출처 필요 — 12월 작업에서 닫는다 |

### ✅ 닫힌 차단급 (2026-11-01)

| ID | 항목 | 판정 |
|---|---|---|
| **G-01** | Skill 4.3.6에 대응하는 AWS AI 도구 | **단일 서비스는 없는 것이 답이다.** Compute Optimizer·CodeGuru Profiler는 **in-scope 목록에 없고**(단, out-of-scope 목록에도 없으므로 "범위 밖"으로 단정하지 않는다), Lambda Power Tuning은 **오픈 소스 도구**다. 받칠 수 있는 in-scope AI 기능은 **CloudWatch 자연어 쿼리 생성·결과 요약**과 **Kiro**뿐이다. 저작 규칙: **단일 서비스를 고르게 하는 문항을 쓰지 않고**, `cloudwatch:GenerateQuery` 같은 확인된 사실을 묻는다 → [96](96-ai-assisted-dev.md) §2-b |
| **G-02** | EKS 매니페스트 배포 절차 | **조사 완료.** `kubectl apply -f`로 `Deployment`·`Service` 매니페스트 적용, `Service` 주석으로 AWS 로드 밸런서 지정, CDK는 `KubernetesManifest`. ⚠️ **EKS의 Fargate는 ECS와 지정 방식이 다르다** — 시작 유형이 아니라 **네임스페이스로 선택하는 Fargate 프로필**이고, Load Balancer Controller 사용 시 Fargate 대상은 **`IP` 유형**이어야 한다 → [95](95-containers.md) §3-b. 남은 것은 `kubectl` 예시 출처가 처방적 지침이라는 점(사용자 가이드 대응 페이지 재확인) |

## 정본 보강 — 사실은 확보했으나 출처가 약하다

| ID | 항목 | 출처 노트 |
|---|---|---|
| **G-04** | **Kiro 공식 문서가 `docs.aws.amazon.com`에 있는지** 확인하지 못했다. 현재 근거는 AWS 블로그·repost이고 세부는 `kiro.dev`를 가리킨다. CLI 플래그·`ksk_` 키 형식을 학습문서에 쓰려면 정본을 찾는다 | [96](96-ai-assisted-dev.md) |
| ~~**G-05**~~ | ✅ **닫혔다 — 아래 「닫힌 판정」 표의 G-05 참조.** 정본에서 확인했고 ⚠️ **옛 서술이 과도한 일반화였다** | [98](98-authoring-decisions.md) |
| **G-06** | **AgentCore Identity 개발자 가이드 정본** — 현재 출처가 콘솔 도움말 패널 경로다 | [2-3](tasks/2-3.md) |

## 판정 필요 — 사실은 확인됐으나 어떻게 쓸지 정해야 한다

**남은 항목이 없다** — 저작 전에 정해야 했던 판정은 2026-11-01에 모두 닫혔다(아래 표).

### ✅ 닫힌 판정 (2026-11-01 — 정본은 [98-authoring-decisions.md](98-authoring-decisions.md))

공식 문서를 **다시 읽어** 판정했다. 각 항목의 쟁점·실측·판정·저작 규칙은 98이 정본이고, 아래는 결론만이다.

| ID | 판정 | 기록 |
|---|---|---|
| **G-09** | **`AWS 서비스를 통한 개발`** — 규칙: **도메인 이름은 도메인 페이지 H1, 비중(%)은 「내용 개요」**에서 가져온다. ⚠️ 이 분기는 C03에서 생긴 것이 아니라 **C02 가이드에도 똑같이 있고**(Topics "통한" / 내용 개요 "사용한"), 레포 `DVA-C02.json`이 이미 "통한"을 쓴다. 실제로 개명된 도메인은 **3번뿐**(`배포` → `테스트 및 배포`) | [98](98-authoring-decisions.md#d-01-g-09--도메인-이름의-한국어-표기) |
| **G-08** | **학습문서에 한 줄로 설명하고 문항의 정답·오답 근거로는 쓰지 않는다.** 기술 3.2.4의 나머지 예시 네 개(Lambda 별칭·컨테이너 이미지 태그·Amplify 브랜치·API Gateway)가 모두 범위 내라 문항은 그것으로 쓴다. ⚠️ **종료일이 공식 페이지 두 곳에서 엇갈린다** — ECS 개발자 가이드·종료 공지는 **2026-06-12**, 2020년 소개 블로그 배너만 2026-05-22. 출처 등급 규율에 따라 **2026-06-12가 정본**이고, 공식 이전 경로는 **ECS Express Mode·CDK L3** | [98](98-authoring-decisions.md#d-02-g-08--aws-copilot) |
| **G-10** | **AWS 문서에 Dockerfile 지침이 있다 — "찾지 못했다"는 검색 범위 문제였다.** 정본 둘: **ECR 성능 최적화**(각 줄이 레이어 · 변경 적은 의존성을 앞쪽에 · **명령 체이닝**(중간 파일이 레이어에 남는다) · 작은 베이스 이미지 · 동시 업로드)와 **Well-Architected Container Build Lens**(멀티스테이지 · **Dockerfile 린팅**(hadolint) · 골든 부모 이미지). 경계: **그 사실이 AWS의 동작·비용·보안과 묶이면 쓰고**, `COPY` vs `ADD` 같은 **Docker 문법 레퍼런스는 문항 근거로 쓰지 않는다** | [98](98-authoring-decisions.md#d-04-g-10--skill-312의-docker-파일-경계) |
| **G-05** | ⚠️ **조사 노트가 과도하게 일반화했다.** `minimumHealthyPercent` 미사용 조건은 "Fargate"가 아니라 **`CODE_DEPLOY`·`EXTERNAL` 배포 유형 + Fargate**이고, **롤링 업데이트에서는 Fargate에서도 쓰인다**(정본 `AWS::ECS::Service DeploymentConfiguration`). 함께 확보: replica 기본 **100%/200%**, `DAEMON`은 CLI·SDK·API **0%** / 콘솔 **50%**, `CODE_DEPLOY`·`EXTERNAL` + EC2는 **사용자 지정 불가** | [98](98-authoring-decisions.md#d-05-g-05--minimumhealthypercent와-fargate--조사-노트가-과도하게-일반화했다) |
| **G-07** | **기술 1.1.9에서는 쓰지 않고 1.1.10(관리형 AI 서비스 통합)의 재료로만 쓴다.** 공식 정의가 "작업 자동화·데이터 분석·웹 앱 구축·리서치"이고 코드베이스를 다루는 도구가 아니다. ⚠️ **기술 1.1.9 원문은 서비스를 하나도 명시하지 않으므로** Kiro도 "가이드가 지정한 도구"로 적지 않고 "범위 내 목록 중 유일하게 해당하는 개발 도구"로 쓴다 | [98](98-authoring-decisions.md#d-03-g-07--amazon-quick) |

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
