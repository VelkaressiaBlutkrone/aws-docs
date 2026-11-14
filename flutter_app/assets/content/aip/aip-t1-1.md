---
examGuideTaskId: aip-t1-1
certCode: AIP-C01
domain: 1
domainName: 파운데이션 모델 통합, 데이터 관리 및 규정 준수
domainWeightPct: 31
title: 요구 사항 분석과 GenAI 솔루션 설계 (아키텍처 설계·개념 증명·표준화된 구성 요소)
coversTasks:
  - "1.1"
sources:
  - title: AWS Well-Architected Framework
    url: https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html
  - title: Generative AI Lens - AWS Well-Architected Framework
    url: https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/generative-ai-lens.html
  - title: Performance efficiency (Generative AI Lens)
    url: https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/performance-efficiency.html
  - title: GENPERF01 Establish performance evaluation processes
    url: https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/genperf01.html
  - title: GENPERF01-BP02 Collect performance metrics from generative AI workloads
    url: https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/genperf01-bp02.html
  - title: Lens Catalog for AWS WA Tool
    url: https://docs.aws.amazon.com/wellarchitected/latest/userguide/lens-catalog.html
  - title: What is AWS Well-Architected?
    url: https://docs.aws.amazon.com/wellarchitected/latest/userguide/well-architected.html
  - title: Choosing models for generative AI applications
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-lifecycle-operational-excellence/dev-experimenting-model-selection.html
lastVerified: 2026-11-14
---

# 요구 사항 분석과 GenAI 솔루션 설계 (아키텍처 설계·개념 증명·표준화된 구성 요소)

> **커버하는 공식 Task** — AIP-C01 · 도메인 1 「파운데이션 모델 통합, 데이터 관리 및 규정 준수」(31%) · **작업 1.1 요구 사항을 분석하고 GenAI 솔루션 설계** (`aip-t1-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 3개(1.1.1~1.1.3)를 모두 덮습니다. 이 작업은 **코드를 쓰기 전에 하는 판단**을 묻습니다. 서비스 이름보다 **무엇을 먼저 좁히고 무엇을 나중에 최적화하는가**의 순서가 점수로 이어집니다.

> ⭐ **먼저 알아야 할 것** — 이 시험은 **`GenAI`·`FM`**이라는 약어를 씁니다. 공식 한국어 가이드 본문이 `GenAI` 34회 · `FM` 95회를 쓰고 「생성형」은 **0회**입니다. 이 사이트도 같은 표기를 따릅니다(파운데이션 모델 = **FM**).

---

## 🧭 시험 형식 (20편 중 여기서 한 번만 정리합니다)

AIP-C01은 **Professional** 등급입니다. 공식 인증 페이지와 시험 가이드를 실측한 값입니다.

| 항목 | 값 |
|---|---|
| 문항 | **채점 65 + 비채점 10 = 75문항** |
| 시간 | **180분** (⚠️ 가이드 본문에는 없고 **인증 페이지**에 있습니다) |
| 합격 | **1,000점 만점에 750점** |
| 도메인 비중 | 1 **31%** · 2 26% · 3 20% · 4 12% · 5 11% |
| 문항 유형 | **선다형**(4개 보기 중 1개 정답) · **복수 응답형**(5개 이상 보기 중 2개 이상 정답) |
| 언어 | 한국어 응시 가능 |

- ⚠️ **비채점 10문항은 어느 것인지 알려 주지 않습니다.** 「이상하게 쉬운 문항」을 만나도 그냥 풀고 넘어갑니다.
- ⚠️⚠️ **이 사이트의 모의고사는 단일 정답 4지선다만 출제합니다.** 실제 시험의 **복수 응답형은 여기서 연습할 수 없으니**, 공식 연습 문제로 따로 감을 잡으세요. 복수 응답형은 **부분 점수가 없습니다** — 2개를 고르라면 둘 다 맞아야 득점입니다.
- ⚠️ 도메인 1이 **31%**로 가장 큽니다. 그런데 **Task는 6개**(1.1~1.6)라 한 Task가 얇게 출제되고, 반대로 도메인 5는 11%인데 **Task가 2개**라 한 Task가 깊게 출제됩니다. **비중만 보고 공부 시간을 나누면 틀립니다.**

---

## ✅ 학습 목표 체크리스트

- [ ] 요구 사항을 **FM 선택 · 통합 패턴 · 배포 전략** 세 축으로 번역할 수 있다
- [ ] Generative AI Lens의 **여섯 기둥**이 GenAI에서 무엇을 뜻하는지 말할 수 있다
- [ ] GenAI 수명 주기 **여섯 단계**를 순서대로 댈 수 있다
- [ ] 책임의 **세 주체**(모델 생산자·제공자·소비자)를 구분할 수 있다
- [ ] PoC에서 모델을 고르는 **세 기준**과 피해야 할 **세 함정**을 말할 수 있다
- [ ] Well-Architected Framework 검토가 **감사가 아니라는 것**과 WA Tool이 **무료**인 것을 안다
- [ ] Lens Catalog에서 렌즈를 쓰려면 **설치가 필요 없다**는 것을 안다
- [ ] 성능을 **다섯 지표**로 나눠 요구 사항에 적을 수 있다

---

## 🎯 왜 중요한가

GenAI 프로젝트가 실패하는 지점은 대개 모델이 아니라 **설계 이전의 판단**입니다. 「무엇을 증명할 것인가」를 정하지 않고 PoC를 시작하면 성능이 좋아도 비즈니스 가치를 설명할 수 없고, 「어느 축에서 좋아야 하는가」를 정하지 않고 모델을 고르면 **요약은 잘하는데 질의응답은 못하는 모델**을 고르게 됩니다.

이 작업은 그 판단을 **공식 문서가 제공하는 틀**로 하게 만듭니다. AWS는 그 틀을 두 겹으로 줍니다 — 모든 워크로드에 공통인 **Well-Architected Framework**와, GenAI 전용으로 확장한 **Generative AI Lens**입니다. 시험은 「렌즈가 몇 개인가」를 묻지 않고 **「이 요구 사항이면 어느 기둥의 어느 결정을 먼저 보아야 하는가」**를 묻습니다.

---

## ⚡ 시험 직전 요약

- **FM 선택 · 통합 패턴 · 배포 전략** — 요구 사항을 이 세 축으로 번역한다.
- Generative AI Lens는 **2025-11-19 발행**이고 여섯 기둥(운영 우수성·보안·안정성·성능 효율성·비용 최적화·지속 가능성)을 **GenAI 표현으로 다시 쓴다**.
- ⚠️⚠️ 렌즈의 범위는 **Bedrock의 FM과 SageMaker AI의 고객 관리형 모델**이고 **모델 훈련·고급 사용자 지정은 명시적으로 제외**된다 — 시험 가이드의 「범위에 해당하지 않는 작업」과 같은 선이다.
- GenAI 수명 주기 **여섯 단계**: 범위 설정 → 모델 선택 → 사용자 지정 → 개발 → 배포 → 지속적 개선.
- 책임은 **모델 생산자 · 제공자 · 소비자** 셋이 나눠 진다.
- 성능은 다섯 지표로 본다 — **추론 지연 · 처리량 · 응답 품질 · 리소스 사용률 · 가용성**.
- ⚠️ **한 작업에서 성능이 좋다는 것이 다른 작업에서도 좋다는 뜻이 아니다**(요약 ≠ 질의응답).
- PoC 모델 선택 셋: **기능 요구 매핑 · 성능과 비용 절충 · 지연 허용치**. 함정 셋: **조기 과최적화 · 전문 모델 무시 · 「큰 모델이 낫다」는 가정**.
- Well-Architected **검토는 감사가 아니라 건설적 대화**이고 **WA Tool은 무료**다. Lens Catalog의 렌즈는 **설치 없이** 쓴다.
- ⚠️ **WA Tool의 `Well-Architected Agent`는 프리뷰 릴리스**다 — 시험이 묻는 쪽은 Tool이다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **FM**(파운데이션 모델) | 넓은 범위의 작업을 충분히 잘 수행하도록 만들어진 모델. 공식 가이드의 기본 표기다 |
| **GenAI** | 영문 `Generative AI`의 공식 가이드 약어 표기. 이 사이트도 이 표기를 쓴다 |
| **렌즈(Lens)** | Well-Architected Framework를 특정 기술·산업에 맞춰 확장한 모범 사례 묶음 |
| **PoC**(개념 증명) | 전체 규모 배포 **전에** 실현 가능성·성능 특성·비즈니스 가치를 검증하는 구현 |
| **그라운드 트루스** | 성능을 재는 기준이 되는 프롬프트·응답 데이터세트 |
| **모델 생산자·제공자·소비자** | 모델을 만드는 쪽 · 서비스로 제공하는 쪽 · 애플리케이션에 쓰는 쪽. 책임이 다르다 |

---

## 📖 핵심 개념

### 1) 요구 사항을 아키텍처로 번역한다 (기술 1.1.1) {#architecture}

> 🧠 원리: 요구 사항은 문장으로 오지만 아키텍처는 **선택의 묶음**입니다. 공식 기술이 드는 예시가 그 묶음의 이름입니다 — **적절한 FM · 통합 패턴 · 배포 전략**. 요구 사항 한 줄을 받으면 이 셋 중 **무엇이 결정되고 무엇이 아직 열려 있는지**를 먼저 가릅니다.

**Generative AI Lens**가 그 틀을 줍니다. 공식 문서가 적는 여섯 기둥의 GenAI 표현은 이렇습니다.

| 기둥 | GenAI에서 보는 것 |
|---|---|
| **운영 우수성** | 일관된 모델 출력 품질 · 운영 상태 모니터링 · **추적성 유지** · 수명 주기 자동화 · **언제 모델 사용자 지정을 할지 판단** |
| **보안** | GenAI 엔드포인트 보호 · 유해 출력과 **과도한 대행** 위험 완화 · 이벤트 모니터링과 감사 · 프롬프트 보호와 **모델 포이즈닝** 위험 교정 |
| **안정성** | 처리량 요구 처리 · 구성 요소 간 통신 · 관찰성 · **우아한 실패 처리** · 아티팩트 버전 관리 · 추론 분산 · 분산 계산 작업의 **완료 확인** |
| **성능 효율성** | 모델 성능 포착과 개선 · 허용 가능한 성능 유지 · 계산 리소스 최적화 · **데이터 검색 성능 개선** |
| **비용 최적화** | 비용 최적 모델 선택 · 추론의 비용·성능 균형 · **비용을 위한 프롬프트 엔지니어링** · 벡터 저장소와 에이전트 워크플로 최적화 |
| **지속 가능성** | 훈련·사용자 지정·호스팅·데이터 처리·스토리지의 계산 리소스 최소화 · 모델 효율 기법과 **서버리스 아키텍처 활용** |

그리고 렌즈는 **GenAI 수명 주기 여섯 단계**에 걸쳐 지침을 줍니다 — **범위 설정 → 모델 선택 → 사용자 지정 → 개발 → 배포 → 지속적 개선**. 책임 있는 AI 관행은 **모델 생산자 · 제공자 · 소비자**가 책임을 나눠 진다는 전제 아래 다룹니다.

⚠️⚠️ **렌즈의 범위를 외우는 것이 아니라 「무엇이 빠져 있는가」를 아는 것이 시험에 쓰입니다.** 공식 범위 문장은 **Bedrock의 FM 또는 SageMaker AI의 고객 관리형 모델**을 쓰는 GenAI 애플리케이션이고, **모델 훈련과 고급 모델 사용자 지정 기법의 모범 사례는 명시적으로 제외**합니다. 전통적인 ML 애플리케이션은 **Machine Learning Lens**가 봅니다. ⭐ 이 선은 시험 가이드가 「범위에 해당하지 않는 작업」으로 적는 **모델 개발·훈련 / 고급 ML 기술 / 데이터 엔지니어링·특성 추출**과 같은 방향입니다.

### 2) PoC로 먼저 증명한다 (기술 1.1.2) {#poc}

> 🧠 원리: PoC의 목적은 **완벽한 최적화가 아니라 실현 가능성 증명**입니다. 공식 처방전이 그 문장을 그대로 적습니다 — `The PoC phase is about proving feasibility, not achieving perfect optimization.` 그래서 PoC에서 고르는 모델은 「최고의 모델」이 아니라 **「이 사용 사례와 제약에 맞는 출발점」**입니다.

공식이 적는 **모델 선택의 세 차원**:

1. **기능 요구 매핑** — 타협할 수 없는 역량을 먼저 찾습니다. 문서 **이미지**를 분석해야 하면 멀티모달 지원이 필요하고, 여러 API 호출을 오케스트레이션해야 하면 **함수 호출** 역량이 필수입니다. 의료·법률·비영어권 같은 전문 영역이면 **관련 데이터로 사전 훈련된 모델**을 고려해 프롬프트 엔지니어링 부담을 줄입니다. 이 단계에서 후보가 즉시 좁아집니다.
2. **성능과 비용 절충** — 능력 있는 모델로 품질 기준선을 세우면서 **동시에 작은 변형을 시험**해 품질 저하 곡선을 파악합니다. 공식 예시: 고객 지원 봇이 큰 모델로 대화당 $0.50에 95% 정확도를 내는데, 어떤 비즈니스는 **작은 모델로 $0.05에 90%**를 택합니다.
3. **지연 허용치** — 자동 완성·음성 상호 작용은 **1초 미만** 응답이 필요하고, 보고서 생성·조사 같은 분석 작업은 수 초 이상을 감당합니다. **네트워크 오버헤드와 전·후처리까지 포함해** 일찍 재 봅니다. ⭐ **더 작고 빠른 모델이 전체 사용자 경험에서 더 나을 수 있습니다.**

공식이 적는 **피해야 할 세 함정**:

- ⚠️ **조기 과최적화** — PoC 단계는 실현 가능성을 증명하는 자리입니다.
- ⚠️ **전문 모델 무시** — 특정 도메인에서 일한다면 도메인 특화 모델을 **일찍** 시험합니다.
- ⚠️⚠️ **「큰 모델이 더 낫다」는 가정** — 잘 만든 프롬프트를 쓴 작고 빠른 모델이 특정 작업에서 더 큰 모델을 **능가할 수 있습니다**.

### 3) 표준화된 구성 요소로 일관성을 만든다 (기술 1.1.3) {#standardize}

> 🧠 원리: 배포 시나리오가 여러 개면 **같은 질문을 같은 순서로 묻는 장치**가 필요합니다. 그것이 Framework와 렌즈이고, 그 질문을 워크로드에 적용해 기록하는 도구가 **WA Tool**입니다.

**AWS Well-Architected Framework**(발행 2024-11-06)가 적는 성질:

- 시스템을 만들며 하는 결정의 **장단점을 이해하게** 돕고, 아키텍처를 모범 사례에 **일관되게 측정**하는 방법을 준다.
- **기초가 되는 질문 묶음**을 문서화한다 — 특정 아키텍처가 클라우드 모범 사례에 맞는지 가늠하는 질문들이다.
- ⚠️⚠️ **아키텍처 검토는 아키텍처 결정에 관한 「건설적 대화」이고 감사 메커니즘이 아니다**(공식 문장). 시험 보기에서 「검토로 규정 준수를 감사한다」는 식의 서술은 이 문장과 어긋납니다.
- 대상 독자는 CTO·아키텍트·개발자·운영 팀이다.
- ⭐ **AWS는 워크로드 검토 서비스를 무료로 제공한다** — **AWS Well-Architected Tool(AWS WA Tool)**이다.

**Lens Catalog**(WA Tool):

- 공식 AWS 렌즈 모음이고 **모든 사용자가 쓸 수 있으며 추가 설치가 필요하지 않다**.
- `AWS Well-Architected Framework` 렌즈는 **모든 워크로드에 기본으로 적용**된다.
- 목록에 **`Generative AI`** 렌즈가 있고 설명이 「AWS에서 GenAI 워크로드를 아키텍처링하는 모범 사례」다. `Machine Learning` 렌즈도 **따로** 있다.
- ⚠️ 렌즈 **개수나 목록 전체를 외우지 않습니다.** 묻는 것은 「GenAI 워크로드면 어느 렌즈인가」와 「설치가 필요한가」입니다.

⚠️⚠️ **`Well-Architected Agent`는 프리뷰 릴리스입니다.** 공식 what-is 페이지가 `AWS Well-Architected Agent is in preview release and is subject to change.`라고 적습니다. 시험이 묻는 쪽은 **Tool**(워크로드·렌즈·마일스톤)입니다.

### 4) 성능 요구 사항을 지표로 적는다 (기술 1.1.1·1.1.3과 함께) {#performance}

> 🧠 원리: 「빨라야 한다」는 요구 사항이 아니라 **바람**입니다. 렌즈는 GenAI 시스템의 성능을 **다섯 지표**로 쪼개 적습니다 — 요구 사항을 이 다섯 칸에 넣을 수 있으면 설계가 측정 가능해집니다.

| 지표 | 공식 정의 |
|---|---|
| **추론 지연** | 주어진 프롬프트에 응답을 생성하는 데 걸리는 시간. **실시간 애플리케이션에 결정적** |
| **처리량** | 성능 저하 없이 처리할 수 있는 **동시 요청 수**. 확장성과 용량을 재는 값 |
| **응답 품질** | 생성된 응답의 정확성·관련성·일관성 — **정의된 그라운드 트루스 데이터세트** 또는 사용자 기대에 대비해 측정 |
| **리소스 사용률** | CPU·메모리·GPU 사용량 |
| **가용성** | 시스템이 응답하고 요청을 처리할 수 있는 시간의 비율 |

그리고 `GENPERF01`이 모델 선택과 직결되는 사실을 적습니다:

- FM은 **넓은 범위의 작업을 충분히 잘** 수행하도록 만들어졌고, 작업별 성능은 **리더보드와 공개 지표 추적**으로 관리된다.
- ⚠️⚠️ **한 작업(예: 요약)에서 강한 성능이 다른 작업(예: 질의응답)에서 강하다는 뜻이 아니다**(공식 문장).
- 작업 성능은 **그라운드 트루스 데이터로 만든 벤치마크**로 평가하고, 그 테스트 묶음에 대한 성능이 **워크로드용 모델 선택을 돕는다**.
- 이 새 지표들은 지연·처리량 같은 **고전적 성능 고려를 대체하지 않고 확장**한다.
- `GENPERF01-BP02`: 성능 지표 식별과 평가는 **추론뿐 아니라 훈련·사용자 지정 워크로드에도** 적용된다.

---

## ✍️ 시험 포인트

- 요구 사항 문장이 나오면 **FM 선택 · 통합 패턴 · 배포 전략** 중 무엇을 묻는지 먼저 가릅니다.
- 「전체 배포 전에 검증」이라는 말이 나오면 **PoC**이고, 그 단계의 목표는 **실현 가능성·성능 특성·비즈니스 가치**입니다.
- 「여러 배포 시나리오에서 일관성」이라는 말이 나오면 **Framework + 렌즈 + WA Tool** 조합입니다.
- GenAI 워크로드 검토면 **Generative AI Lens**, 전통적 ML이면 **Machine Learning Lens**입니다.
- 모델 **훈련**이나 **고급 사용자 지정** 이야기가 보기에 나오면 그것은 **렌즈와 이 시험의 범위 밖**입니다.
- 성능 요구 사항은 **다섯 지표** 중 어디에 걸리는지로 답이 갈립니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ⚠️ **「검토 = 감사」로 읽기.** Framework 검토는 건설적 대화입니다.
- ⚠️ **WA Tool이 유료라고 생각하기.** 공식은 **무료(at no charge)**로 적습니다.
- ⚠️ **렌즈를 쓰려면 설치가 필요하다고 생각하기.** Lens Catalog의 렌즈는 **설치 없이** 모든 사용자가 씁니다.
- ⚠️⚠️ **벤치마크 1위 모델을 고르면 된다고 생각하기.** 작업이 다르면 순위가 뒤집힙니다.
- ⚠️⚠️ **PoC에서 비용·지연을 나중 문제로 미루기.** 공식은 **1일차부터** 지능과 운영 비용을 균형 맞추라고 적습니다.
- ⚠️ **큰 모델 = 좋은 선택이라는 가정.** 공식이 명시적으로 함정으로 듭니다.
- ⚠️ **도메인 비중만 보고 공부 시간 배분하기.** 도메인 1은 31%지만 Task가 6개입니다.

---

## 🧪 자가 점검

**Q1.** GenAI 워크로드의 Well-Architected 검토를 하려고 합니다. 어느 렌즈를 쓰고, 그 렌즈를 쓰기 위해 먼저 무엇을 설치해야 합니까?

<details><summary>정답 보기</summary>

**Generative AI Lens**를 쓰고, **설치할 것은 없습니다.** Lens Catalog의 공식 렌즈는 모든 사용자가 쓸 수 있고 추가 설치가 필요하지 않습니다. 전통적 ML 워크로드라면 Machine Learning Lens입니다.
</details>

**Q2.** 「요약 벤치마크에서 1위인 모델을 골랐으니 질의응답에서도 가장 좋을 것이다」는 왜 틀립니까?

<details><summary>정답 보기</summary>

공식 `GENPERF01`이 **한 작업에서 강한 성능이 다른 작업에서 강하다는 것을 뜻하지 않는다**고 명시합니다. 작업 성능은 **그라운드 트루스 데이터로 만든 벤치마크**로 그 작업에서 직접 평가해야 합니다.
</details>

**Q3.** PoC 단계에서 모델을 고를 때 공식이 드는 세 차원은 무엇입니까?

<details><summary>정답 보기</summary>

**① 기능 요구 매핑**(멀티모달·함수 호출처럼 타협 불가 역량) **② 성능과 비용 절충**(큰 모델로 기준선을 세우면서 작은 변형을 동시에 시험) **③ 지연 허용치**(네트워크 오버헤드와 전·후처리 포함). 이 셋으로 후보가 즉시 좁아집니다.
</details>

**Q4.** 모델 **훈련** 모범 사례를 Generative AI Lens에서 찾으려 합니다. 무엇이 문제입니까?

<details><summary>정답 보기</summary>

렌즈의 범위가 **모델 훈련과 고급 모델 사용자 지정 기법을 명시적으로 제외**합니다. 렌즈는 Bedrock의 FM 또는 SageMaker AI의 고객 관리형 모델을 **쓰는** 애플리케이션을 봅니다. ⭐ 이 시험 가이드도 모델 개발·훈련을 「범위에 해당하지 않는 작업」으로 적습니다.
</details>

**Q5.** 「응답이 빨라야 한다」는 요구 사항을 측정 가능하게 적으려면 렌즈의 어느 지표들을 쓰면 됩니까?

<details><summary>정답 보기</summary>

**추론 지연**(프롬프트 → 응답 생성 시간)과 **처리량**(성능 저하 없는 동시 요청 수)입니다. 여기에 **응답 품질**(그라운드 트루스 대비) · **리소스 사용률** · **가용성**을 더해 다섯 지표로 적습니다. 「빠르다」만으로는 설계가 측정되지 않습니다.
</details>

**Q6.** 조직이 Well-Architected 검토 결과를 근거로 팀을 평가하려 합니다. 공식 서술과 어떻게 어긋납니까?

<details><summary>정답 보기</summary>

공식은 아키텍처 검토를 **아키텍처 결정에 관한 건설적 대화이고 감사 메커니즘이 아니다**라고 적습니다. 평가·감사 도구로 쓰면 그 전제가 깨집니다. 참고로 **WA Tool 자체는 무료**입니다.
</details>

---

### 📌 출처

1. AWS Well-Architected Framework (기초 질문 · 검토는 감사가 아니다 · WA Tool 무료) — `docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html` (2026-11-14 확인)
2. Generative AI Lens (2025-11-19 발행 · 여섯 기둥 · 수명 주기 여섯 단계 · 범위와 제외) — `docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/generative-ai-lens.html` (2026-11-14 확인)
3. Performance efficiency (Generative AI Lens) (성능 다섯 지표) — `docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/performance-efficiency.html` (2026-11-14 확인)
4. GENPERF01 (작업별 성능은 전이되지 않는다) — `docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/genperf01.html` (2026-11-14 확인)
5. GENPERF01-BP02 (추론뿐 아니라 훈련·사용자 지정도) — `docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/genperf01-bp02.html` (2026-11-14 확인)
6. Lens Catalog for AWS WA Tool (설치 불필요 · Framework 렌즈는 기본 적용) — `docs.aws.amazon.com/wellarchitected/latest/userguide/lens-catalog.html` (2026-11-14 확인)
7. What is AWS Well-Architected? (`Well-Architected Agent`는 프리뷰) — `docs.aws.amazon.com/wellarchitected/latest/userguide/well-architected.html` (2026-11-14 확인)
8. Choosing models for generative AI applications (PoC 모델 선택 세 차원과 함정 셋) — `docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-lifecycle-operational-excellence/dev-experimenting-model-selection.html` (2026-11-14 확인)
