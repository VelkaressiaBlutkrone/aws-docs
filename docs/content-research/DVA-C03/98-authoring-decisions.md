# 98 — 저작 결정 기록 (Phase 3 착수 전 판정)

> 조회일 **2026-11-01**. [`99-gaps.md`](99-gaps.md)의 「판정 필요」 항목을 닫은 기록이다.
> **사실이 아니라 판정을 담는다** — 각 항목은 〈쟁점 → 공식 실측 → 판정 → 저작 규칙〉 순이고, 저작 규칙은 학습문서 12편과 문항 전체에 그대로 적용한다.
> 공식 문서를 **다시 읽어** 결정했다(조사 노트를 근거로 재인용하지 않았다). 인용은 모두 한국어 가이드 본문이다.

---

## D-01 (G-09) — 도메인 이름의 한국어 표기

### 쟁점

도메인 1의 공식 한국어 표기가 **같은 가이드 안에서 갈린다.** `exam_guides/DVA-C03.json`과 학습문서 머리말에 어느 쪽을 쓸지 정해야 한다.

### 공식 실측

| 공식 위치 | 도메인 1 표기 |
|---|---|
| 도메인 1 **페이지 제목(H1)** — `developer-associate-03-domain1.html` | AWS 서비스를 **통한** 개발 |
| 랜딩 페이지 **Topics** 목록 | AWS 서비스를 **통한** 개발 |
| 랜딩 페이지 **「내용 개요」** 절 | AWS 서비스를 **사용한** 개발(채점 대상 콘텐츠의 30%) |

⚠️ **이 분기는 C03에서 생긴 것이 아니다.** C02 가이드도 똑같이 Topics·도메인 페이지는 "통한", 「내용 개요」는 "**사용한** 개발(32%)"로 적는다. 즉 "사용한"은 **공식 개정이 아니라 두 가이드에 공통인 번역 불일치**다. 레포 `assets/exam_guides/DVA-C02.json`은 이미 "AWS 서비스를 통한 개발"을 쓰고 있다.

### 판정

**`AWS 서비스를 통한 개발`을 쓴다.** 그리고 표기 하나를 고르는 대신 **규칙**으로 둔다:

> **도메인 이름은 그 도메인 페이지의 H1에서 가져오고, 비중(%)은 「내용 개요」 절에서 가져온다.**

근거 셋 — ① H1은 그 도메인 페이지 자신의 제목이고, 「내용 개요」의 문구는 비중을 나열하는 요약 목록의 일부다 ② 레포 `DVA-C02.json`이 이미 그 구조로 만들어져 있어(이름은 도메인 페이지, 비중은 내용 개요) C02↔C03 연속성이 유지된다 ③ 다른 자격증에서 같은 분기를 만나도 판정이 자동이다.

### 저작 규칙

- 학습문서 프런트매터 `domainName`과 가이드 JSON `domains[].name`은 **도메인 페이지 H1**을 그대로 쓴다.
- C02→C03에서 **도메인 1 이름은 바뀌지 않는다**(학습자 화면에 불필요한 개명이 생기지 않는다). 실제로 개명된 것은 **도메인 3뿐**이다 — `배포` → **`테스트 및 배포`**(양쪽 표기 일치).
- 공식 한국어 용어를 따른다: Task = **작업**, Skill = **기술**.

**출처**
- https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain1.html
- https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03.html
- https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-02/developer-associate-02.html

---

## D-02 (G-08) — `AWS Copilot`

### 쟁점

기술 3.2.4의 공식 예시에 `AWS Copilot 환경`이 들어 있는데, **범위 내 서비스 목록에는 Copilot이 없고** CLI는 지원이 끝났다. 문항·학습문서에 쓸지 정해야 한다.

### 공식 실측

- 기술 3.2.4 원문(한국어): "애플리케이션 환경을 만들고 구성합니다(예: Lambda 별칭, 컨테이너 이미지 태그, AWS Amplify 브랜치, **AWS Copilot 환경**, API Gateway API)."
- **범위 내 「개발자 도구」**: AWS Amplify · AWS CloudShell · AWS CodeArtifact · AWS CodeBuild · AWS CodeDeploy · AWS CodePipeline · AWS X-Ray. **Copilot은 없다.**
- **범위 외 목록에도 없다** → "범위 밖"으로 단정하지 않는다(목록은 공식적으로 non-exhaustive다. D-03·G-01과 같은 규율).
- ⚠️ **지원 종료일이 공식 페이지 두 곳에서 엇갈린다**: ECS 개발자 가이드 본문과 종료 공지 블로그는 **2026-06-12**("업데이트·보안 패치·기술 지원 없음. 기존 배포는 계속 동작"), 2020년 소개 블로그의 배너만 **2026-05-22**. 이 폴더의 출처 등급 규율(동작·수치는 `docs.aws.amazon.com` 본문)에 따라 **2026-06-12를 정본**으로 쓴다.
- 공식 이전 경로: **Amazon ECS Express Mode** 또는 **AWS CDK L3 constructs**.

### 판정

**학습문서에서 한 줄로 설명하고, 문항의 정답·오답 근거로는 쓰지 않는다.**

기술 3.2.4의 나머지 예시 네 개(**Lambda 별칭 · 컨테이너 이미지 태그 · Amplify 브랜치 · API Gateway API**)는 전부 범위 내 서비스이므로, 그 Task의 문항은 이 넷으로 충분히 쓸 수 있다. Copilot 동작 지식을 알아야 풀리는 문항은 **지원이 끝난 도구를 외우게 만드는 것**이라 쓰지 않는다.

### 저작 규칙

- `dva-t3-2.md`에 한 줄: "가이드 예시에는 `AWS Copilot 환경`이 남아 있지만 **범위 내 서비스 목록에는 없고** CLI는 **2026-06-12** 지원이 끝났다(기존 배포는 계속 동작). 공식 이전 경로는 **ECS Express Mode** 또는 **CDK L3 constructs**다."
- 문항의 지문·보기·해설에서 Copilot을 **정답이나 오답의 판단 근거로 쓰지 않는다**. 이름을 언급하는 것까지는 허용한다(가이드에 있는 단어라 완전히 지우면 가이드와 어긋난다).

**출처**
- https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain3.html
- https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
- https://docs.aws.amazon.com/AmazonECS/latest/developerguide/copilot-deploy.html (종료일 정본)
- https://aws.amazon.com/blogs/containers/announcing-the-end-of-support-for-the-aws-copilot-cli/ (이전 경로)

---

## D-03 (G-07) — `Amazon Quick`

### 쟁점

`Amazon Quick`이 범위 내 「기계 학습 및 인공 지능」에 있는데 개발 도구가 아니고, 그 BI 구성 요소인 `Amazon Quick Sight`는 **범위 외**다. AI 보조 개발 6 Skill에서 Quick을 어떻게 다룰지 정해야 한다.

### 공식 실측

- 공식 정의: "Amazon Quick은 **작업 자동화·데이터 분석·웹 애플리케이션 구축·리서치**를 위한 AI 기반 서비스다. 자연어 채팅으로 상호 작용하며, 연결된 데이터 소스와 애플리케이션에 대해 AI 에이전트가 요청을 처리한다."
- 구성 기능: **Quick Sight**(BI) · **Quick Flows**(반복 작업 자동화) · **Quick Automate**(업무 프로세스 자동화) · **Quick Index**(문서·데이터 연결) · **Quick Research**(인용 보고서) · **Apps in Amazon Quick**(자연어로 대화형 웹 앱 구축). 공식 각주: "Amazon Quick은 Amazon QuickSight에서 발전했고, 기존 QuickSight API·SDK·통합은 변경 없이 계속 동작한다."
- 범위: **범위 내 ML/AI = Bedrock · Bedrock AgentCore · Amazon Quick · Kiro** 넷 / **범위 외 「분석」에 Amazon Quick Sight**. 상위 제품은 범위 내, 그 기능 하나는 범위 밖이다.
- ⚠️ **기술 1.1.9 원문은 서비스 이름을 하나도 적지 않는다** — "**AI 지원 개발 도구**를 사용하여 코드를 생성, 검토 및 최적화합니다(예: 사양 기반 코드 생성, 자동화된 코드 검토, 지능형 코드 완성, 리팩터링 제안, 보안 스캐닝)."

### 판정

**기술 1.1.9(AI 보조 개발)에서는 Quick을 쓰지 않고, 기술 1.1.10(관리형 AI 서비스 통합)의 재료로만 쓴다.**

`Apps in Amazon Quick`이 "자연어로 대화형 웹 앱을 만든다"는 점에서 유일하게 '개발'에 걸치지만, 1.1.9가 요구하는 **코드 생성·자동 코드 리뷰·지능형 코드 완성·리팩터링 제안·보안 스캐닝**은 코드베이스를 다루는 일이고 Quick의 공식 정의에 없다.

⚠️ **Kiro도 "가이드가 지정한 도구"로 적지 않는다.** 가이드가 1.1.9에 서비스를 명시하지 않으므로, Kiro는 **"범위 내 목록 중 이 기술에 해당하는 유일한 개발 도구"**로서 쓴다. "가이드가 Kiro를 쓰라고 한다"고 적으면 거짓이 된다.

### 저작 규칙

- Quick은 **① 범위 내 목록에 있다는 사실과 ② Quick Sight가 범위 밖이라는 구분**만 가르친다. Quick의 기능(Flows·Automate·Index·Research) 중 하나를 고르게 하는 문항은 쓰지 않는다 — G-01의 "단일 서비스를 고르게 하지 않는다"와 같은 처리다.
- 1.1.10의 "관리형 AWS AI 서비스"는 **Bedrock·AgentCore**를 중심으로 쓰고 Quick을 보기에 넣을 수 있다.
- ⚠️ Quick과 Quick Sight를 **같은 것으로 묶어 서술하지 않는다**(범위가 반대다). 학습문서에 이 모순을 명시한다 — 시험에서 "Quick Sight"가 보이면 범위 외 신호다.

**출처**
- https://docs.aws.amazon.com/quick/latest/userguide/what-is.html
- https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
- https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-out-of-scope-services.html
- https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain1.html

---

## D-04 (G-10) — Skill 3.1.2의 "Docker 파일" 경계

### 쟁점

기술 3.1.2가 공식 예시에 **"Docker 파일"**을 넣었는데, 조사 단계에서 **AWS 공식 문서 기준의 Dockerfile 모범 사례를 찾지 못했다**고 남겼다. 일반 Docker 지식(문법·명령 레퍼런스)과 AWS 고유 사실의 경계를 정해야 한다.

### 공식 실측 — **AWS 문서에 Dockerfile 지침이 있다**

조사 노트의 "찾지 못했다"는 **검색 범위 문제였다.** `docs.aws.amazon.com` 본문에 두 곳이 있다.

| 정본 | 담고 있는 Dockerfile 사실 |
|---|---|
| **ECR 성능 최적화**(`AmazonECR/latest/userguide/performance.html`) | ① **각 줄이 레이어를 만든다** ② 더 작은 **베이스 이미지**를 쓴다 ③ ⭐ **변경이 가장 적은 의존성을 Dockerfile 앞쪽에** 둔다(레이어 캐시 — 한 레이어가 바뀌면 **그 뒤 레이어가 모두 재컴파일**된다) ④ ⭐ **명령을 체이닝**한다(중간 파일은 뒤 레이어에서 지워도 **그 레이어에 남는다**) ⑤ Docker 1.10+는 **레이어를 동시 업로드**한다 |
| **Well-Architected Container Build Lens** | ① **멀티스테이지 빌드**로 빌드 도구를 최종 이미지에서 분리(크기·공격 표면 감소, 재현성) ② **Dockerfile 린팅(hadolint)**을 보안 모범 사례로 둔다 ③ **골든 부모 이미지** 패턴(⚠️ 부모가 바뀌면 **자식 이미지를 다시 빌드**해야 반영된다) |

### 판정

**AWS 문서가 적는 Dockerfile 사실만 쓴다.** 경계는 **"그 사실이 AWS 서비스의 동작·비용·보안과 묶이는가"**다.

- ✅ **쓴다**: 레이어 캐시 순서 · 명령 체이닝 · 베이스 이미지 크기 · 멀티스테이지 · 린팅 · 골든 이미지 — 모두 **ECR 업로드 시간·이미지 크기·공격 표면**과 묶인다.
- ❌ **쓰지 않는다**: `COPY` vs `ADD`의 일반 차이, `ENTRYPOINT` vs `CMD` 문법, `HEALTHCHECK`·`ARG`·`ONBUILD` 같은 **Docker 문법 레퍼런스**. AWS 문서가 자기 사실로 적지 않으므로 **문항의 정답·오답 근거로 쓰지 않는다**(설명에 필요하면 쓰되 묻지 않는다).

### 저작 규칙

- `dva-t3-1.md`의 3.1.2 절은 **ECR 성능 페이지의 네 가지 + Lens의 세 가지**를 축으로 쓴다. 출처는 두 정본을 적는다.
- Lambda 컨테이너 이미지의 Dockerfile(베이스 이미지·`CMD` 핸들러)은 **작업 3.3.1(패키징)** 소재이므로 여기서 다루지 않는다.
- ⚠️ **"AWS가 Dockerfile 모범 사례를 제공하지 않는다"고 적지 않는다** — 이 판정으로 거짓이 됐다.

**출처**
- https://docs.aws.amazon.com/AmazonECR/latest/userguide/performance.html
- https://docs.aws.amazon.com/wellarchitected/latest/container-build-lens/improving-containerized-cicd-pipelines-from-performance-efficiency-and-cost-perspective.html

---

## D-05 (G-05) — `minimumHealthyPercent`와 Fargate ⚠️ **조사 노트가 과도하게 일반화했다**

### 쟁점

`95-containers.md` §3이 **"Fargate 시작 유형에서는 `minimumHealthyPercent`가 쓰이지 않는다"**로 적었고, 근거가 Security Hub 모델의 SDK 레퍼런스라 **정본으로 약하다**고 스스로 남겼다(G-05).

### 공식 실측 — 범위가 더 좁다

정본(`AWS::ECS::Service DeploymentConfiguration`)은 이렇게 적는다.

> 원문: "If a service is using either the blue/green (`CODE_DEPLOY`) or `EXTERNAL` deployment types and is running tasks that use the Fargate launch type, the minimum healthy percent value is not used, although it is returned when describing your service."

- 즉 **미사용 조건은 "Fargate"가 아니라 "`CODE_DEPLOY`·`EXTERNAL` 배포 유형 + Fargate"**다.
- **롤링 업데이트(`ECS`) 배포 유형에서는 Fargate에서도 쓰인다** — 그 단락은 시작 유형을 구분하지 않는다.
- 같은 페이지에서 함께 확보한 사실: 기본값은 replica 서비스 **`minimumHealthyPercent` 100% · `maximumPercent` 200%**이고 **`DAEMON`은 CLI·SDK·API에서 0%, 콘솔에서 50%**다. 최소 정상 작업 수는 **`desiredCount` × 비율/100을 올림**한다. **`CODE_DEPLOY`·`EXTERNAL` + EC2에서는 사용자 지정 값을 지정할 수 없다**(기본값으로 설정되어 `DRAINING` 중 하한으로 쓰인다).

### 판정

**"Fargate에서는 쓰이지 않는다"로 적지 않는다.** 반드시 **배포 유형과 함께** 적는다 — "`CODE_DEPLOY`·`EXTERNAL` 배포 유형에서 Fargate 작업을 돌리면 쓰이지 않는다(describe 응답에는 값이 그대로 돌아온다)".

### 저작 규칙

- `dva-t3-3.md`의 롤링 업데이트 절은 **배포 유형 × 시작 유형 두 축**으로 표를 만든다.
- ⚠️ **문항에서 "Fargate이므로 최소 정상 비율이 무시된다"를 정답 근거로 쓰지 않는다** — 롤링 업데이트라면 거짓이다.
- `95-containers.md` §3의 서술은 이 판정에 맞춰 정정했다(같은 PR).

**출처**
- https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-ecs-service-deploymentconfiguration.html

---

## 이 기록에 넣지 않은 것

- **G-04~G-06 · G-10~G-18**은 판정이 아니라 **"쓰지 않는다"로 운영**한다(사실은 확보했으나 출처가 약하거나 세부가 미확인). 쓰게 되면 그때 이 파일에 항목을 추가한다.
- ⚠️ **쓰지 않기로 한 주장을 금지 가드로 걸지 않는다** — 뒤에 근거가 확인되면 막히고, "확인되지 않았다"는 **옳은 문장**이 걸린다(SAA 갭 배치의 가드 설계 교훈).
