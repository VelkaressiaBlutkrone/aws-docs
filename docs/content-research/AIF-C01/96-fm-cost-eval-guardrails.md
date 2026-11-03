---
생성: 2026-11-03
목적: AIF-C01 v1.1 신규 「비용·평가·안전」 목표의 공식 근거 수집
대상 목표: 2.1.4 · 2.1.5 · 2.3.4 · 3.1.1 · 3.1.5 · 3.2.5 · 3.4.2 · 3.4.4 · 3.4.5 · 4.1.2 · 4.2.2 · 5.1.5
---

# 96 — FM 비용·평가·가드레일 (AIF-C01)

> 전 항목 AWS 공식에서 2026-11-03 조회. `[n]`은 §9 번호. **수치·한도·기본값만** 공식 영문을 15단어 이내로 인용하고, 서술 사실은 한국어 요약 + 출처 번호로 둔다.
> **단가는 쓰지 않는다** — `aws.amazon.com/*/pricing/` 요율 표는 JS로 그려져 본문에 안 나온다(이 레포 실측). 산문으로 확인된 **비율**(배치 50%)만 썼고 근거가 블로그임을 명시했다.

## 1. 왜 이 노트가 필요한가

v1.1 신규 목표는 "FM이 무엇인가"에서 **운영 축**으로 간다 — 비용(토큰 과금 → 추론 모드·캐싱·사용자 지정 선택), 평가(평가 종류마다 **지표 집합이 다르다** → 기술 지표를 비즈니스 지표로), 안전(가드레일 정책·접지·투명성).

조사 중 **네 가정이 뒤집혔다.** ① 4.2.2의 `SageMaker Cartify`는 공식 서비스가 아니다(§5 판정). ② 그 **Clarify는 신규 고객에게 열려 있지 않고** FM 평가는 Bedrock Evaluations로 대체됐다 `[16]`. ③ **「컨텍스트 엔지니어링」은 서비스 가이드에 없다** — 블로그에만 정의가 있다 `[24]`. ④ **URL 두 개가 리다이렉트였다** — Bedrock 가이드는 없는 슬러그를 404로 주지 않고 `what-is-bedrock.html`로 보낸다(§9 각주).

## 2. 토큰 기반 요금과 비용 절충 (2.1.4 · 2.3.4)

**과금 단위는 토큰이다.** 텍스트 모델은 **입력·출력 양쪽**, 임베딩 모델은 입력 토큰만, 이미지 생성은 이미지당 `[23]`. 긴 시스템 프롬프트·대화 이력·도구 스키마·RAG 검색 결과는 **전부 입력 토큰**이다 `[20]`.

| 모드 | 과금 축 | 인용·근거 |
| --- | --- | --- |
| 온디맨드 | 처리된 입·출력 토큰, 약정 없음 | `[23]` |
| 배치 추론 | 토큰 — *"Batch mode costs 50 percent less than On-Demand mode for select AI models"* | `[23]` |
| 프로비저닝된 처리량(PT) | **모델 단위(MU) × 시간** — *"You're billed hourly for a Provisioned Throughput"* | `[2]` |

**PT** `[2]`: MU 하나가 **1분당 처리 입력 토큰 수와 생성 출력 토큰 수**를 정한다. 약정은 **무약정 / 1개월 / 6개월**이고 길수록 시간당 가격이 할인되며 약정분은 기간 종료 전 삭제 불가. ⚠️ **사용자 지정 모델은 PT 없이 못 쓴다**: *"you must purchase Provisioned Throughput to be able to use it."*

**배치 추론** `[3]`: 값은 절반이지만 **비동기**(프롬프트를 파일로 올리고 응답을 S3에서 받는다). 제약 둘 — *"Batch inference isn't supported for provisioned models."* / `Converse` 호출 유형에서는 **도구 호출 미지원**(`toolConfig` 레코드는 400 실패).

**프롬프트 캐싱** `[1]`: 추론 지연과 **입력 토큰 비용**을 줄이는 선택적 기능이다. **유형 둘** — 암시적은 **요청에 캐시 제어가 없고** Bedrock·모델이 재사용 가능한 접두부를 자동 탐색(최선 노력), 명시적은 **캐시 체크포인트**(`cachePoint`)로 구간을 직접 표시한다. 캐시되는 것은 **프롬프트 접두부**이고 접두부가 바뀌면 캐시 미스여서 **정적 내용 앞, 동적 내용 뒤**가 공식 권고다. 체크포인트 최소 토큰은 모델별 — *"Minimums currently range from 512 to 4,096 tokens per cache checkpoint."* **TTL은 히트마다 리셋**되고 히트 없으면 만료된다(*"Many models support a 5-minute TTL."*). 과금은 캐시 읽기가 **캐시 읽기 요율**, 캐시 **쓰기는 모델에 따라 표준 입력 요율보다 높을 수 있다**. ⚠️ 캐시 히트는 **보장되지 않아** 응답의 캐시 사용 필드로 확인해야 하고, ⚠️ **배치와 함께 못 쓴다**: *"only supported for on-demand inference endpoints. It is not supported with the batch inference API."*

**2.3.4의 나머지 축**: Bedrock은 **Reserved · Priority · Standard · Flex** 네 추론 서비스 계층으로 가용성·지연·비용을 모델·API 변경 없이 바꾼다. 앞의 셋은 온디맨드로 모델당 쿼터를 공유하며 **요청 시점 파라미터**로 고르고, Reserved는 자체 SLA·최소 약정이 있는 별도 풀이다 `[25]`. 리전 적용 범위·중복성은 **교차 리전 추론**이 정본이고 캐싱과 함께 쓸 수 있으나 수요가 높을 때 **캐시 쓰기가 늘 수 있다** `[1]`.

## 3. FM 사용자 지정의 비용 절충 (3.1.1 · 3.1.5 · 3.2.5 · 2.1.5)

**공식 사다리** `[18]` — GENOPS05-BP01이 **가장 자원이 덜 드는 프롬프트 엔지니어링부터 시작해 필요한 만큼 올리라**고 적는다. ① **프롬프트 엔지니어링**(모델을 고치지 않는다) → ② **RAG**(검색으로 외부 지식을 쓰게 해 **코어 모델을 재훈련하지 않고** 도메인에 맞춘다) → ③ **계속 사전 훈련 / 미세 조정**(특정 작업 성능이 필요하고 **레이블 데이터가 있고** 도메인 전문 용어를 이해시켜야 할 때) → ④ **사용자 지정 FM 구축**(자원·비용이 **가장 높은 선택지**. 기존 모델이 요구를 못 맞추고 방대한 독점 데이터가 있고 아키텍처·훈련 과정을 완전히 통제해야 할 때).

**모델 선택 기준(3.1.1)** `[19]`: **모달리티 · 모델 크기(파라미터 수) · 추론 지연 · 컨텍스트 윈도 · 요금 · 미세 조정 가능성 · 데이터 품질·양 · 응답 품질**을 축으로 나열하고, 작고 자원을 덜 쓰는 모델이 예산 친화적 선택지라고 적는다.

**모델 증류(3.1.5 신규)** `[4]`: 더 크고 유능한 **교사(teacher)**의 지식을 더 작고 빠르고 저렴한 **학생(student)**에게 옮긴다. 메커니즘은 교사에서 **합성 데이터(응답)를 생성**해 **학생을 미세 조정**하는 것.

- 선택 기준 `[5]`: 교사는 학생보다 **현저히 크고 유능한** 모델, 학생은 교사보다 **현저히 작고** 지원 조합 표에서 **그 교사와 짝지어진** 모델이어야 한다.
- 데이터 경로 둘 `[4]`: 내가 `.jsonl` 프롬프트 제공 / **호출 로그(invocation logs)**의 기존 교사 응답 재사용.
- ⚠️ **숨은 비용** `[4]`: 데이터 합성 기법이 돌면 **교사 모델 추론 호출이 온디맨드 요율로 추가 과금**되고 데이터셋은 *"a maximum of 15k prompt-response pairs"* 까지 커질 수 있다. 결과물은 사용자 지정 모델이라 **PT 필수** 규칙이 따라붙는다 `[2]`.

**프롬프트 관리의 버전 관리(3.2.5 신규)** `[6]`: 저장하면 **드래프트 버전**이 되고 프로덕션 배포 시 **버전**을 만든다 — 버전은 그 시점 프롬프트의 **스냅샷**이어서 설정 간 전환과 **되돌리기**가 쉬워진다.

**컨텍스트 엔지니어링(2.1.5)** — ⚠️ **이 용어는 AWS 서비스 사용자 가이드에서 확인되지 않았다.** 확인된 공식 정의는 블로그 한 곳 `[24]`: *"carefully selecting the right information to include in the context window at each step"*. 담길 것으로 **사용자 지시(프롬프트·도구 설명) · 이전 메모리 · 외부 지식 · 도구 실행 결과**를 들고, 컨텍스트가 커질수록 **추론 효과가 감쇠한다**고 적는다. docs 정본은 **AGENTPERF03-BP02** `[20]`로 용어는 "context window utilization"이지만 비용 서술이 2.1.4와 이어진다 — 프롬프트의 모든 토큰이 모델의 주의를 다투고 **입력 토큰 비용과 추론 지연을 더한다**. 안티패턴: 전체 대화 이력을 매 프롬프트에 넣기 / **작업과 무관한 전체 도구 카탈로그 주입** / RAG 검색 결과를 필터 없이 통째로 넘기기. → **저작 지침**: 이 이름으로 가르치되 **공식 정의가 블로그**임을 각주로 남기고, 문항에서 공식 **서비스 기능명**처럼 쓰지 않는다.

## 4. 평가 (3.4.2 · 3.4.4 · 3.4.5)

**Bedrock Evaluations는 네 종류다** `[7]` — 프로그래매틱 모델 평가(평가 알고리즘이 채점) · **사람 작업자** 평가(사내 직원 또는 업계 주제 전문가) · **심사 모델 평가**(두 번째 LLM이 채점하고 **점수와 설명을 함께** 준다) · **RAG 평가**(LLM 기반). LLM-as-a-judge는 **생성기 모델**과 **평가자 모델** 둘이 필요하고, 비-Bedrock 모델도 **응답 데이터를 직접 넣으면** 평가된다(그 경우 모델 호출 단계를 건너뛴다).

**지표가 세 집합으로 갈린다 — 혼동 1순위.** 공식 API 레퍼런스가 평가 종류별 유효값을 못박는다 `[10]`.

- **자동(프로그래매틱) 모델 평가**: `Builtin.Accuracy` · `Robustness` · `Toxicity` — **셋뿐이다.**
- **LLM-as-a-judge**: `Correctness` · `Completeness` · `Faithfulness` · `Helpfulness` · `Coherence` · `Relevance` · `FollowingInstructions` · `ProfessionalStyleAndTone` + 책임 있는 AI `Harmfulness` · `Stereotyping` · `Refusal`.
- **RAG 검색 전용**: `ContextRelevance` · `ContextCoverage` — **둘뿐이다.** **검색+생성**은 `Correctness` · `Completeness` · `Helpfulness` · `LogicalCoherence` · `Faithfulness` + 책임 있는 AI 3종.
- `taskType` 유효값: `Summarization | Classification | QuestionAndAnswer | Generation | Custom`.

**같은 "Accuracy"가 작업 유형마다 다른 수식이다 — 혼동 2순위** `[9]`: 일반 텍스트 생성 = **RWK score**(real world knowledge) / 텍스트 **요약 = BERT Score**(BERT 사전 훈련 문맥 임베딩으로 후보·참조 문장을 **코사인 유사도** 매칭) / **질문·답변 = F1 score**(0~1) / 텍스트 분류 = 예측 클래스를 정답 레이블과 비교한 accuracy. **Robustness**는 전 유형 공통 **섭동** 기반(소문자화·키보드 오타·숫자를 단어로·무작위 대문자화·공백 추가·삭제)으로 *"Each prompt in your dataset is perturbed approximately 5 times."* 요약은 `(Delta BERTScore / BERTScore) × 100`, QA는 `(Delta F1 / F1) × 100`이고 **낮을수록 강건하다**. **Toxicity**는 전 유형 공통 **detoxify** 알고리즘.

**ROUGE · BLEU · BERTScore** — ⚠️ 세 지표가 Bedrock 콘솔 보고서에 나란히 나오는 것은 **아니다**. **BERTScore**는 Bedrock 요약 작업의 Accuracy 그 자체 `[9]` · **ROUGE-L·METEOR·BERTScore**는 SageMaker FM 평가(FMEval) 튜토리얼이 요약 정확도에 쓰는 셋 `[17]` · **ROUGE-L**은 생성·참조 텍스트의 **최장 공통 부분수열**을 재며 **정답 데이터가 있을 때** 쓰는 쪽으로 분류된다 `[19b]` · **BLEU**는 docs에서 확인되지 않았다(→ 확인 필요 1). 블로그가 셋을 묶어 **관련성 평가와 할루시네이션 탐지에 한계가 있다**고 적는다 `[26]`. → ROUGE·BLEU는 **겹침 기반**(정답 텍스트 필요, 의미가 달라도 단어가 겹치면 높다), BERTScore는 **임베딩 유사도**, LLM-as-a-judge는 **다차원 질적 평가**.

**RAG 평가(3.4.4)**: 작업이 **두 종류**다 — **Retrieve only**(검색된 데이터만) / **Retrieve and generate**(검색 + 응답 생성 모델의 요약까지). 둘 다 Bedrock Knowledge Base를 쓰거나 **외부 RAG 소스의 추론 응답을 직접 넣어** 평가할 수 있고, 데이터셋은 **ground truth(기대 검색 텍스트·응답)를 포함해야** 기대와 맞는지 검사된다 `[7]`. 검색 전용 지표 `[8]`: **Context relevance** = 청크가 질문과 맥락상 관련 있는가 / **Context coverage**(정답 필요) = 청크가 **정답 텍스트의 정보를 모두 덮는가**.

**비즈니스 목표 조정 지표(3.4.5 신규)** `[19a]`: 문제는 **엔지니어링의 기술 지표와 리더십이 기대하는 비즈니스 가치의 단절**이다. 해법은 PoC의 평가 프레임워크를 **라이브 KPI 모니터링 프레임워크**로 키워 모든 기술 지표가 **의미 있는 비즈니스 성과로 추적되게** 하는 것. **ROI는 정적 계산이 아니라 계속 추적하는 동적 KPI**이고, ROI 대시보드는 재무 지표(**cost per interaction** = 상호 작용당 비용, 총 인프라 지출)와 비즈니스 가치 지표(절약 시간, 매출 증가, **CSAT 점수** 개선)를 섞어야 한다. 비용이 움직이는 이유로 **API 토큰 소비 · 인프라 확장 · 미세 조정 같은 유지 활동의 연산 비용**을 들어 §2와 이어진다. 「작업 완료율」은 일반 KPI로 정의하는 docs 페이지를 찾지 못했다(→ 확인 필요 2).

## 5. 안전·접지·투명성 (4.1.2 · 4.2.2 · 5.1.5)

**Guardrails 정책 여섯 종류** `[11]`. 사용자 입력과 모델 응답 양쪽에 걸리고 **추론 콘텐츠 블록은 제외**된다.

| 정책 | 공식 세부 |
| --- | --- |
| **Content filters** | 유해 텍스트·이미지. 범주 6종 **Hate · Insults · Sexual · Violence · Misconduct · Prompt Attack**, 범주별 강도 설정 |
| **Denied topics** | 바람직하지 않은 주제를 질의·응답 양쪽에서 차단 |
| **Word filters** | 사용자 정의 단어·구. **대소문자 무시 + 전체 단어·구 일치**, 욕설은 기성 옵션 |
| **Sensitive information filters** | PII 차단 또는 **마스킹**(SSN·생년월일·주소 등) + **사용자 정규식** |
| **Contextual grounding checks** | 할루시네이션 탐지(아래) |
| **Automated Reasoning checks** | 논리 규칙으로 응답 검증(아래) |

운영 사실 `[11]`: 만들면 **작업 드래프트**가 자동 생성되고 만족스러우면 **버전**을 만들어 모델과 쓴다 · 추론 시 **가드레일 ID + 버전**을 넘긴다 · ⚠️ **모델을 호출하지 않고** `ApplyGuardrail` API로 직접 쓸 수 있다 · 입력 프롬프트의 **일부만** 평가하는 기능은 **SDK 전용**이고 콘솔(플레이그라운드 포함)에서는 안 된다.

**Contextual grounding check — 5.1.5의 중심** `[12]`. 지원 사용 사례는 **요약 · 패러프레이징 · 질의응답**이고 패러다임이 둘이다 — **Grounding**(소스에 근거하는가. 응답에 **새로 들어온 정보는 전부 미근거**) / **Relevance**(응답이 **사용자 질의와 관련 있는가**). 공식 예시가 둘을 가른다 — 소스 "London is the capital of UK. Tokyo is the capital of Japan", 질의 "What is the capital of Japan?" 일 때 "The capital of Japan is London."은 **ungrounded**(질의에는 맞지만 소스를 잘못 썼다), **"The capital of UK is London."은 irrelevant**(근거 있고 **사실도 맞지만** 질의에 답하지 않았다).

필요한 **입력 셋** = grounding source · query · content to guard(Invoke·Converse에서는 모델 응답). 임계값은 **허용 최소 점수**다 — 둘 다 0.7이면 *"responses with a grounding or relevance score of less than 0.7 ... blocked"*. ⚠️ **유효 범위는 0 ~ 0.99**: *"A threshold of 1 is invalid as that will block all content."* `action`은 `BLOCK` 또는 `NONE`(조치 없이 탐지 정보만). 계층 둘 — **Classic**은 엄격한 접지(합리적 추론·대화체도 점수를 낮춘다)에 영어·프랑스어·스페인어, **Standard**는 추론·대화체 응답을 지원하고 더 일관된 점수를 주지만 **교차 리전 추론 필수**이며 그 사용 사례의 출발점으로 **0.7**을 권한다. ⚠️ **미지정 시 Classic**. 길이 한도 = source **100,000자** / query **1,000자** / response **5,000자**. ⚠️ 관련성은 **청크 단위**로 보고 **한 청크라도 관련 있으면 응답 전체가 관련 있다**고 판정하므로, 스트리밍에서는 무관 응답이 먼저 흘러간 뒤 표시될 수 있다.

**Automated Reasoning checks** `[13]`: **수학적 기법**으로 자연어 내용을 내가 정의한 정책에 대해 검증한다. 정책 규칙과 **모순됨을 증명**해 사실 오류 탐지 / 응답이 정책과 일치하나 관련 규칙을 다 다루지 않는 **진술되지 않은 가정** 지적 / 근거 규칙·변수 할당을 인용한 **검증 가능한 설명** 제공. ⚠️ 콘텐츠 필터·주제 정책은 **이진 게이트**(차단/허용)인데 이것은 **검증 계층**으로 실행 가능한 피드백을 준다. FAQ가 더 선명하다 — Automated Reasoning은 **도메인 전문가가 정책을 먼저 만들어야** 하고 규칙을 정의하는 내용만 지원하는 반면, Contextual grounding은 **사전 작업 없이** ML로 입력 문서 충실도를 본다 `[21]`.

**할루시네이션 감지·접지 기법** `[22]`: 할루시네이션은 모델이 **틀리거나 날조된 정보를 확신에 차서 생성**하는 것이다. 완화책 — **RAG**(권위 있는 출처에 답을 접지) · **제약을 둔 프롬프트 엔지니어링**(근거 없는 가정 대신 **불확실성을 인정**하게) · **자기 일관성 프롬프팅** · **사고의 연쇄** · **도메인 특화 데이터 미세 조정** · **사람 검토 체크포인트**. 5.1.5가 든 **출력 유효성 검사·신뢰도 점수**의 docs 근거는 Well-Architected다 — **RAISP03-BP04**는 사실 오류를 **사용자 도달 전 최종 점검으로 차단**하는 출력 필터링을 두고 **automated reasoning 검사와 사실 검증 시스템을 둘 다** 쓰라고 하며(미확립 시 위험 **High**) `[14]`, **AGENTSEC01-BP03**은 메모리에 저장된 **할루시네이션 하나가 다음 에이전트의 ground truth가 된다**며 **신뢰도 점수**로 낮은 확신 출력을 검증 대상으로 올리고 **모델이 스스로 불확실성을 보고하게 믿는 것**을 안티패턴으로 든다 `[15]`.

**SageMaker Model Cards(4.2.2)** `[27]`: ML 모델의 핵심 세부를 **한곳에 문서화**해 거버넌스·보고에 쓴다. 담는 것: **의도된 사용(intended use)** · **위험 등급(risk rating)** · 훈련 세부·지표 · 평가 결과·관찰 · 고려사항·권고. 용도: 모델 사용법 안내 / 감사 활동 지원 / 모델이 **비즈니스 목표를 어떻게 지원하는지** 전달. PDF 내보내기·공유 가능. ⚠️ **불변성**: 승인 상태 변경을 뺀 **모든 편집이 새 버전을 만든다**. Model Registry와 통합된다.

### ⚠️ `SageMaker Cartify` 판정

**결론: AWS에 `SageMaker Cartify`라는 서비스는 없다. 공식 한국어 개정 표의 표기 오류이고, 실제 서비스는 `Amazon SageMaker Clarify`다.** 근거 셋 — ① `Cartify`로 AWS 문서를 검색하면 그 이름의 서비스·기능·페이지가 **한 건도** 나오지 않는다(2026-11-03 실측). ② 같은 역할(설명 가능성·편향 탐지·FM 평가)의 공식 서비스가 Clarify이고 의사 결정 가이드가 **「Using Amazon SageMaker Clarify」** 절을 따로 둔다 `[19]`. 처방적 지침도 Clarify와 Bedrock을 **모델 평가를 돕는 기능을 가진 둘**로 짝지어 적는다 `[19b]`. ③ 4.2.2의 다른 항목(모델 카드·Amazon 기반 모델 평가·오픈 소스 모델·데이터·라이선스)이 모두 Clarify의 인접 영역이다.

**그런데 Clarify를 그대로 가르치면 안 된다** `[16]`: *"Amazon SageMaker Clarify is no longer open to new customers."* 기존 고객은 그대로 쓸 수 있고 AWS는 보안·가용성 개선은 계속하지만 **신규 기능은 도입하지 않을 계획**이다. 대체 경로는 역할별로 갈린다 — Clarify의 **FM 평가(FMEval)** → **Bedrock Evaluations**와 **Bedrock Guardrails**가 LLM·생성형 AI 평가의 AWS 관리형 경로다. ⚠️ 다만 *"They are not a replacement for predictive (tabular/classical ML) bias detection or explainability."* 편향 지표(DPL·DPPL·DI·CI 등)는 **공표된 업계 표준 수식**이라 pandas·scikit-learn으로 재현하고, 설명 가능성은 **Clarify가 내부적으로 쓰는 엔진이 SHAP**이라 SHAP을 직접 쓴다.

→ **저작 판단**: 이름을 **Amazon SageMaker Clarify**로 바로잡고 「Cartify」는 한국어판 표기 오류로 각주 처리 · **신규 고객에게 열려 있지 않다**는 상태 문장을 함께 적는다 · 4.2.2의 "Amazon 기반 모델 평가"는 **Amazon Bedrock model evaluation**으로 연결한다. 문항에서 Clarify를 "지금 쓰면 되는 FM 평가 도구"로 묻는 것은 **금지**한다.

## 6. 시험에서 묻는 방식

실무자 레벨이라 설정 문법은 묻지 않는다. ① **모드 선택** — "실시간 불필요, 대량" → 배치 / "사용자 지정 모델 서빙" → PT(필수) / "긴 공통 프롬프트 반복" → 캐싱. 함정은 **배치 + 캐싱을 같이 고르게** 유도하는 보기다. ② **사용자 지정 사다리** — "레이블 데이터 없음"이면 미세 조정이 오답, "작은 모델로 큰 모델급 품질"이면 증류. ③ **평가 종류 ↔ 지표** — "정답이 없다"면 프로그래매틱 정확도 계열이 빠지고, "검색 품질만"이면 retrieve only + Context relevance/coverage. 함정은 모델 평가 지표를 RAG 평가 보기에 섞어 두는 것. ④ **안전 도구** — "사전 작업 없이 RAG 응답이 문서를 벗어나는지" → Contextual grounding check / "검증 가능한 논리적 증명" → Automated Reasoning checks / "의도된 용도·위험 등급을 문서로 남겨 감사 대응" → Model Cards(런타임 통제가 아니다).

## 7. 흔한 함정·혼동 짝

| # | 혼동 짝 | 공식 구분점 | 근거 |
| --- | --- | --- | --- |
| 1 | 온디맨드 ↔ PT | 토큰 과금 ↔ **MU × 시간**. 약정분은 기간 중 삭제 불가 | `[2]``[23]` |
| 2 | 배치 ↔ 캐싱 | **같이 못 쓴다**(캐싱은 온디맨드 엔드포인트 전용) | `[1]` |
| 3 | 배치 ↔ 프로비저닝된 모델 | *"Batch inference isn't supported for provisioned models."* | `[3]` |
| 4 | 암시적 ↔ 명시적 캐싱 | 암시적은 **요청에 캐시 제어가 없다** ↔ `cachePoint`를 내가 넣는다 | `[1]` |
| 5 | 캐시 **읽기** ↔ **쓰기** 요율 | 읽기는 할인 ↔ **쓰기는 표준 입력 요율보다 비쌀 수 있다** | `[1]` |
| 6 | 증류 교사 ↔ 학생 | **크고 유능** ↔ **작고 빠르고 저렴**. 지식은 교사 → 학생 | `[4]``[5]` |
| 7 | 증류 = 공짜 절감? | 아니다. **교사 추론이 온디맨드 요율로 추가 과금**된다 | `[4]` |
| 8 | 프롬프트 드래프트 ↔ 버전 | 저장하면 드래프트 ↔ 버전은 **스냅샷**(배포·되돌리기용) | `[6]` |
| 9 | 프로그래매틱 ↔ judge | Accuracy·Robustness·Toxicity **3종뿐** ↔ 다차원 + 책임 있는 AI 3종 | `[10]` |
| 10 | 모델 평가 ↔ RAG 평가 | 유효 지표 집합이 **겹치지 않게** 정의. 검색 전용은 **둘뿐** | `[10]` |
| 11 | Context relevance ↔ coverage | 청크가 **질문과 관련** ↔ **정답 텍스트를 모두 덮는가**(정답 필요) | `[8]` |
| 12 | 요약 ↔ QA Accuracy | **BERT Score**(임베딩 코사인) ↔ **F1 score** | `[9]` |
| 13 | Grounding ↔ Relevance | 소스에 근거하는가 ↔ **질의에 답하는가**("The capital of UK is London"은 **근거 있지만 무관**) | `[12]` |
| 14 | 임계값 0.99 ↔ 1 | 0~0.99만 유효, **1은 무효**(전부 차단). 계층 미지정 시 **Classic** | `[12]` |
| 15 | 접지 검사 ↔ Automated Reasoning | **사전 작업 없이** ML ↔ **전문가가 정책을 먼저** 만들고 논리적 설명을 받는다 | `[21]``[13]` |
| 16 | Guardrails ↔ Model Cards | 런타임 필터링 ↔ **거버넌스 문서화**(요청을 차단하지 않는다) | `[11]``[27]` |
| 17 | Clarify ↔ Bedrock Evaluations | Clarify는 **신규 고객 불가**. FM 평가는 대체되나 **표형 ML 편향·설명은 대체 아님** | `[16]` |

## 8. 자가 점검 후보

정답이 공식 문장으로 **유일하게** 결정되는 것만 골랐다.

**Q1.** 야간 배치로 리뷰 50만 건을 분류하며 긴 공통 시스템 프롬프트를 캐싱해 추가 절감을 노린다. 계획의 문제는?
→ **프롬프트 캐싱은 배치 추론과 함께 쓸 수 없다**(캐싱은 온디맨드 추론 엔드포인트 전용) `[1]`.

**Q2.** 미세 조정한 사용자 지정 모델을 호출량이 적어 온디맨드로 쓰고 싶다. 가능한가?
→ **불가능. PT를 구매해야 쓸 수 있다** — *"you must purchase Provisioned Throughput to be able to use it."* `[2]`

**Q3.** 접지 소스가 "London is the capital of UK. Tokyo is the capital of Japan", 질의가 "What is the capital of Japan?"일 때 응답 "The capital of UK is London."의 판정은?
→ **접지는 되어 있으나 관련성 점수가 낮다**(사실이 맞고 소스를 썼지만 질의에 답하지 않았다) `[12]`.

**Q4.** 지식 기반의 **검색 단계만** 평가하는 RAG 평가에서 쓸 수 있는 내장 지표는?
→ **`Builtin.ContextRelevance`와 `Builtin.ContextCoverage` 둘뿐** `[10]`.

**Q5.** Bedrock Model Distillation의 교사·학생 선택 기준은?
→ **교사는 학생보다 현저히 크고 유능하며, 학생은 현저히 작고 지원 조합 표에서 그 교사와 짝지어진 모델이어야 한다** `[5]`.

## 9. 출처 목록

| # | 제목 | URL | 조회일 |
| --- | --- | --- | --- |
| 1 | Prompt caching | https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-caching.html | 2026-11-03 |
| 2 | Provisioned Throughput | https://docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html | 2026-11-03 |
| 3 | Batch inference | https://docs.aws.amazon.com/bedrock/latest/userguide/batch-inference.html | 2026-11-03 |
| 4 | Model distillation | https://docs.aws.amazon.com/bedrock/latest/userguide/model-distillation.html | 2026-11-03 |
| 5 | Prerequisites for model distillation | https://docs.aws.amazon.com/bedrock/latest/userguide/prequisites-model-distillation.html | 2026-11-03 |
| 6 | Deploy a prompt using versions | https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-management-deploy.html | 2026-11-03 |
| 7 | Evaluate Bedrock resources | https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation.html | 2026-11-03 |
| 8 | RAG evaluation metrics | https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-eval-llm-results.html | 2026-11-03 |
| 9 | Automated model evaluation metrics | https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-report-programmatic.html | 2026-11-03 |
| 10 | EvaluationDatasetMetricConfig (API) | https://docs.aws.amazon.com/bedrock/latest/APIReference/API_EvaluationDatasetMetricConfig.html | 2026-11-03 |
| 11 | Bedrock Guardrails | https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html | 2026-11-03 |
| 12 | Contextual grounding check | https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-contextual-grounding-check.html | 2026-11-03 |
| 13 | Automated Reasoning checks | https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-automated-reasoning-checks.html | 2026-11-03 |
| 14 | RAISP03-BP04 Output filtering | https://docs.aws.amazon.com/wellarchitected/latest/responsible-ai-lens/raisp03-bp04.html | 2026-11-03 |
| 15 | AGENTSEC01-BP03 Hallucination propagation | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentsec01-bp03.html | 2026-11-03 |
| 16 | Clarify availability change | https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html | 2026-11-03 |
| 17 | FMEval summarization accuracy 튜토리얼 | https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-foundation-model-evaluate-auto-tutorial-two.html | 2026-11-03 |
| 18 | GENOPS05-BP01 When to customize models | https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/genops05-bp01.html | 2026-11-03 |
| 19 | Choosing a generative AI service | https://docs.aws.amazon.com/decision-guides/latest/decision-guides/genai-guide.html | 2026-11-03 |
| 19a | Sustaining the value of a gen AI application | https://docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-lifecycle-operational-excellence/prod-value.html | 2026-11-03 |
| 19b | Layer 2: Approved FMs and tools | https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-enterprise-ready-gen-ai-platform/model.html | 2026-11-03 |
| 20 | AGENTPERF03-BP02 Context window | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf03-bp02.html | 2026-11-03 |
| 21 | Amazon Bedrock FAQs | https://aws.amazon.com/bedrock/faqs/ | 2026-11-03 |
| 22 | Security considerations for data in gen AI | https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-data-considerations-gen-ai/security.html | 2026-11-03 |
| 23 | Estimate Bedrock costs (블로그 — 모드별 과금·배치 50%) | https://aws.amazon.com/blogs/publicsector/how-to-estimate-amazon-bedrock-costs-for-public-sector-applications/ | 2026-11-03 |
| 24 | Data-driven agentic AI 구성 요소 (블로그 — 컨텍스트 엔지니어링) | https://aws.amazon.com/blogs/database/key-components-of-a-data-driven-agentic-ai-application/ | 2026-11-03 |
| 25 | Amazon Bedrock (처방적 지침 — 추론 서비스 계층) | https://docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-inference-architecture-and-best-practices-on-aws/amazon-bedrock.html | 2026-11-03 |
| 26 | RAG 평가 with LlamaIndex·RAGAS (블로그 — 지표 한계) | https://aws.amazon.com/blogs/machine-learning/evaluate-rag-responses-with-amazon-bedrock-llamaindex-and-ragas/ | 2026-11-03 |
| 27 | SageMaker Model Cards | https://docs.aws.amazon.com/sagemaker/latest/dg/model-cards.html | 2026-11-03 |
| 28 | Judge 평가자 프롬프트 | https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-type-judge-prompt.html | 2026-11-03 |

### ⚠️ 리다이렉트가 발견된 URL

Bedrock 사용자 가이드는 **없는 슬러그에 404를 주지 않고 `what-is-bedrock.html`로 리다이렉트**한다(작성 중 실측). 추측 슬러그를 출처로 쓰면 조용히 엉뚱한 페이지를 인용한다.

| 시도한 URL | 최종 URL | 실제 정본 |
| --- | --- | --- |
| `…/userguide/automated-reasoning-checks.html` | `…/userguide/what-is-bedrock.html` | `[13]` — `guardrails-` 접두어가 있다 |
| `…/userguide/evaluation-judge-metrics.html` | `…/userguide/what-is-bedrock.html` | `[10]`(지표 이름) · `[28]`(평가자 프롬프트) |

나머지 URL은 조회 시 리다이렉트가 보고되지 않았다. `[5]`의 슬러그 `prequisites-…`는 AWS 쪽 오타지만 **그것이 정본 URL**이고 리다이렉트도 아니다.

## 확인 필요

1. **BLEU의 docs 근거** — 3.4.2가 BLEU를 열거하지만 `docs.aws.amazon.com`에서 BLEU를 정의하거나 평가 지표로 올려 둔 페이지를 찾지 못했다. 확인된 것은 ROUGE-L·METEOR·BERTScore `[17]` · BERTScore `[9]` · ROUGE-L `[19b]`이고 BLEU는 **블로그 묶음으로만** 나온다 `[26]`. → BLEU를 "AWS 관리형 평가 작업이 계산해 주는 지표"로 쓰면 안 되고 일반 NLP 지표로 소개한다. 저작 전 docs 재탐색 1회 권장.
2. **「작업 완료율」의 일반 용어 근거** — `cost per interaction`과 사용자 만족도(**CSAT score improvements**)는 `[19a]`에서 그대로 확인됐다. 그러나 **"task completion rate"을 생성형 AI 애플리케이션의 일반 KPI로 정의하는 docs 페이지는 없다**(가장 가까운 것은 Amazon Connect 전용 지표 `AI_RESPONSE_COMPLETION_RATE`이고, Amazon Q Business 블로그의 **task completion time**은 **완료율과 다른 지표**다). → 문항에서 공식 정의로 인용하지 않는다.
3. ✅ **해소(컨트롤러 실측, 2026-11-03) — 정본은 `Amazon Bedrock Model Evaluations`다.** 영문 가이드 도메인 4 본문이 "(for example, **Amazon SageMaker Model Cards, Amazon Bedrock Model Evaluations**, open source models, data, licensing)"로 적는다(https://docs.aws.amazon.com/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain4.html). 한국어 본문의 「Amazon Bedrock 모델 평가」와 일치하고, **영문 본문에도 `Cartify`는 없다** → 개정 표에만 있는 오표기다. 이 노트의 Clarify 판정(신규 고객 차단)과 합쳐 [99-gaps.md](99-gaps.md) **G-08 · G-15**에 결론을 적었다.
4. **PT의 MU당 토큰 수치** — 공식 문서가 수치를 적지 않고 **AWS 계정 매니저에게 문의하라**고 보낸다 `[2]`. 따라서 "MU 1개 = N 토큰/분" 형태의 문항은 만들 수 없다.
