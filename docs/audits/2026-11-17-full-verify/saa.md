# SAA 전수 검증 — 2026-11-17

> 범위: `flutter_app/assets/content/saa/` 학습문서 **24편** · 문항 **360개(전부 `verified: true` — 라이브)** · 가이드 `flutter_app/assets/exam_guides/SAA-C03.json`(도메인 4 · 공식 Task 14 · 지식·기술 문장 189개).
> 이 세션은 콘텐츠·코드·테스트를 **고치지 않았다**. 쓴 파일은 이 보고서 하나다(커밋·브랜치 전환 없음).
> 방법: ① 문항 360개 전문 덤프 통독(정답·보기·해설·오답 근거·출처) → ② 문항·md 출처 **496개 수집**(문항 고유 251 · md 전용 245) 후 본문 추출 → ③ 문항별 핵심 사실을 인용 페이지 본문에 **정규식 탐침**(0건이면 동의어·다른 페이지로 재탐침) → ④ 전파 가드 56규칙 + md 가드 금지 리터럴 481건을 문항과 **의미 단위**로 대조 → ⑤ 발견한 27개 계열을 md·문항·다른 자격증에서 **전수 grep** → ⑥ md 「흔한 함정」 절 24편 통독 + 「자가 점검」 절의 단정·수치 줄 → ⑦ `prescreen` · 중복(원형+조사벗김 자카드 64,620쌍) · AWS Lifecycle 134항목 대조 · 가이드 JSON ↔ 공식 한국어 페이지 대조.
> ⚠️ **측정 한계를 먼저 적는다.** 문항 통독·출처 수집·계열 grep·중복·prescreen·lifecycle·가이드 대조는 **전수**다. 반면 ⓐ 공식 본문 대조는 「문항이 단정하는 핵심 사실 1~3개가 인용 페이지에 있는가」를 본 것이고 **해설의 모든 문장**을 대조한 것이 아니다. ⓑ **md 24편은 전문 통독이 아니다** — 「흔한 함정」 절 전수(582줄)와 「자가 점검」의 단정·수치 줄, 그리고 계열 grep 에 걸린 줄을 봤다. 「핵심 개념」 본문의 표·원리 블록은 계열에 걸린 줄만 확인했다. ⓒ 출처 생사는 계약 §2-② 대로 다시 재지 않았다(수집 때 찍힌 상태만 적는다).
> 가드가 이미 금지한 문구(`saa_question_facts_test` · `saa_question_propagation_test` · `saa_t*_facts_test` · `saa_gaps_b*_test` · `saa_p1/p2/p3_review_fix_test` · `saa_p3_source_fix_test`)는 다시 적지 않았다. 아래는 **그 가드들이 보지 않거나 어형으로 비켜 간 자리**다.

## 0. 요약

| 판정 | 수 | 뜻 |
|---|---|---|
| 🔴 | **5** | 사실이 거짓 · 정답이 둘 · 정답이 틀림 (즉시 수정) — 문항 4 + 학습문서 1 |
| 🟡 | **20** | 불완전·모호·출처가 사실을 담지 않음 (수정 권고) — 내용 15항목 + md 잔존 2항목 + 출처 2항목(90문항 · 4문항) + 가이드 1항목 |
| 🟢 | **12** | 품질(길이 단서·메타 문구·중복·표기) — 사실은 옳다 |
| ✅ | **245문항** | 🔴·🟡 어느 항목에도 걸리지 않은 문항(length-cue·중복은 별도 집계) |

- **공개 문항 중 🔴: 4건** — `saa-t2-1-q7`(오답 근거가 공식 수치와 정반대) · `saa-t3-9-q9`(해설 단정이 공식 지원 표와 다름) · `saa-t4-4-q12`(정답 보기가 같은 Task 학습문서·레포 가드 판정과 정반대) · `saa-t1-3-q8`(오답 보기가 공식 비교표로는 참 — **정답이 둘**). **정답 인덱스를 바꿔야 하는 문항은 0건**이다. 나머지 🔴 1건은 라이브 학습문서 `saa-t3-7.md`(5줄)다.
- 문항 기준 집계(고유): 🔴 4 · 🟡 111(내용 계열 17 + 출처 90 + 블로그 4 + 미확보 단정 7 − 겹침) · ✅ 245.
- `prescreen`(`node tool/prescreen.mjs build saa` 실측): 구조·정합성 플래그 **0건** / qualityFlags — length-cue **149** · meta-phrasing **3** · authoring-memo **0** · explanation-long **3** (전체 360문항 중 신호 152문항, 42%) / Task 내 중복 후보 **1쌍**(읽어 보니 다른 사실 — §3 G4).
- 검증한 출처 URL: 문항 고유 **251개**(참조 488회) 전부 `200 r=0` / 그중 「그 사실을 담지 않음」 **90문항**(인용 URL 71개가 걸려 있고 그중 소개류 28개 · 경미 15문항 포함) — §2 Y18 표. md 전용 245개 중 4개가 `r=1`(백서 — 2026-11-17 WA 감사 §5 에서 판정이 끝난 자리라 다시 적지 않는다).
- 구조 실측: 뱅크 24 · Task당 15 · 보기 4개 균일 · `correct` 분포 0:45 / 1:165 / 2:99 / 3:51 · `difficulty` foundational 166 / applied 194(Task당 foundational 최소 5 → 「2개 미만」 **0건**) · `section` 빈 값 **360/360**(§3 G8).
- 지난 보고(2026-11-06) 잔여: Fable §2-1 `saa-t2-4-q1` HA/FT 귀속 **미반영**(→ Y12). 나머지 P1·P2·P3 는 가드로 닫힌 것을 확인했다.
- ⭐ **이 보고의 중심 발견은 「리터럴 전파 가드를 문항이 어형으로 비켜 갔다」는 것이다.** 🔴 4건 중 3건(`t2-1-q7` · `t3-9-q9` · `t4-4-q12`)과 🟡 여럿(Y3 · Y9 · Y14 · Y15)이 **md 는 2026-10-19 에 정정됐고 금지 문구가 `_rules` 에 등재돼 있는데 문항만 남은** 자리다. 지난 Fable 보고는 「리터럴 310개 × 문항 = 유효 탈출 0」으로 닫았지만, 금지 문장을 **의미**로 다시 대조하면 탈출이 나온다. 규칙 하나(`**Java·Scala·SQL**`)는 별표가 들어 있어 평문 문항과 **영원히 일치할 수 없다**(§3 G9).

### 0-1. ✅ 공식 대조로 확인한 사실(손대지 말 것)

SNS 관리형 엔드포인트 재시도 **100,015회·23일** · KMS 봉투 암호화 4 KB · ACM 198일·만료 45일 전 갱신 확인 · Backup Vault Lock 유예 72시간·최대 36,500일 · Lambda 900초 / Managed Instances 5,400초 · Step Functions Standard 90일 이력 · FIFO 300 TPS(배치 3,000) · EventBridge 재시도 기본값 두 종(24시간·185회 / 5회·300초) · ASG 상태 확인 소스 5종 · Aurora Global Database 1초 미만·1분 내 승격 · gp3 3,000 IOPS·125 MiB/s · 분산 배치 그룹 AZ당 7개 · EFA 는 AZ·VPC 를 넘지 못함 · Kinesis 온디맨드 30일 피크 2배 · Geoproximity 는 프라이빗 호스팅 영역에서도 사용 가능 · DXGW 슈퍼넷 예외 · Cost Explorer 13개월 이력·18개월 예측·API $0.01 · Budget action 3종(IAM·SCP·EC2/RDS 대상) · CUR Athena 는 Parquet 전용 · Timestream LiveAnalytics 신규 차단(6/20/25) · Compute Optimizer 기본 lookback 14일 · 소비 모델 75%(40시간/168시간) · Cost Anomaly Detection 고객 관리형 모니터 「up to 10」 · RI·SP 공유는 양쪽 활성화 · 같은 AZ 라도 퍼블릭·Elastic IP 면 $0.01/GB(양방향) · NAT $0.045(오하이오 예시) · **DX 포트 시간 요금 $0.30/hour 는 이제 공식 표에 있다**(1 Gbps 전용 연결 · 일본 제외 — §6 U7).

---

## 1. 🔴 (문항·학습문서)

### R1. `saa-t2-1-q7` — 오답 근거 「SNS→Lambda 는 재시도가 제한적이어서 메시지를 버릴 수 있다」가 공식 수치와 정반대

- **공개 여부**: verified true
- **현재 정답 인덱스**: 1 (「SNS 토픽에 SQS 큐 세 개를 구독(팬아웃)…」)
- **결함**: `wrongExplanations["2"]` = 「SNS가 Lambda를 직접 Push할 때 Lambda 동시성 한도 초과 시 **재시도가 제한적이어서 메시지를 버릴 수 있습니다. SQS 중간 버퍼가 처리 보장의 핵심입니다.**」 공식은 Lambda·SQS 같은 AWS 관리형 엔드포인트에 **100,015회·23일** 재시도를 적는다. 같은 Task 학습문서 `saa-t2-1.md:341` 은 바로 이 주장을 **「흔한 오해」**로 가르친다(2026-10-19 정정). 즉 **문서로 공부한 사람이 이 오답 근거를 읽으면 문서와 정반대를 배운다.** 보기 [2](Lambda 직접 구독)를 떨어뜨리는 진짜 이유는 지문의 「소비자마다 자기 속도로 가져가며 밀린 분량을 쌓아 둔다」(= 내구성 버퍼)이지 재시도 부족이 아니다.
- **공식 근거**:
  - `https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html` (200 r=0) — 전달 정책 표의 「AWS managed endpoints (Amazon Data Firehose, AWS Lambda, Amazon SQS)」 행 합계: "**100,015 times, over 23 days**".
  - `https://docs.aws.amazon.com/sns/latest/dg/sns-dead-letter-queues.html` (200 r=0) — DLQ 는 **구독 단위**로 붙는다.
- **수정안**: `wrongExplanations["2"]` 를 「SNS 는 Lambda 같은 AWS 관리형 엔드포인트에 서버 측 오류 시 최대 100,015회·23일 재시도하고 구독 단위 DLQ 도 붙일 수 있으므로, 재시도가 없어서 떨어지는 보기가 아닙니다. 다만 Lambda 직접 구독은 **Push** 라서 소비자가 자기 속도로 끌어가며 밀린 분량을 쌓아 두는 버퍼가 없습니다 — 지문의 그 요건 때문에 각 구독 앞에 SQS 를 둡니다.」로 바꾼다. **정답 인덱스 불변.** 출처에 위 두 페이지를 더한다(지금은 SNS·SQS 소개 페이지뿐).
- **전수**: 「재시도가 제한|메시지를 버릴|처리 보장」 — saa 문항 **2자리**(`t2-1-q7` W2 · `t2-1-q8` W2 → Y4) · md 0자리(md:249 표의 「재시도·처리 보장」은 SQS 설명이라 무관). 다른 자격증 0.
- ⚠️ **가드**: `saa_question_propagation_test` `_rules` 가 `'제한된 횟수만 재시도하고 이후 메시지를 버립니다'` · `'SNS는 Push 후 재시도가 제한적입니다'` 를 금지하지만 이 문항은 「재시도가 제한적이어서 메시지를 버릴 수」로 **어형이 달라 통과**한다. 고친 뒤 `재시도가 제한` 을 정규식으로 더할 것.

### R2. `saa-t3-9-q9` — 「Athena·EMR·Redshift Spectrum 전반에 Lake Formation 권한이 일관되게 적용」은 공식 지원 표와 다르다

- **공개 여부**: verified true
- **현재 정답 인덱스**: 1 (「AWS Lake Formation — Glue Data Catalog 위에 컬럼·행·셀 수준의 세밀한 접근 제어를 추가한다」)
- **결함**: 해설 「**Athena·EMR·Redshift Spectrum 쿼리 전반에 Lake Formation 권한이 일관되게 적용되므로, 분석 도구를 바꿔도 동일한 권한 모델이 유지됩니다**」. 지문도 「Athena·EMR 쿼리 전체에 이 권한이 일관되게 적용되어야 한다」를 요건으로 걸고 그 요건이 충족된다고 가르친다. 공식 지원 표는 엔진마다 다르다 — EMR 의 Hive 는 행·셀 수준을 지원하지 않고, EMR on EKS·EMR Serverless 의 Hive·Athena Spark 는 **셋 다 미지원**이다. `saa-t3-9.md:524` 는 이미 「엔진별 지원 범위 차이 … EMR의 Hive는 행·셀 수준 미지원」으로 정정됐다.
- **공식 근거**: `https://docs.aws.amazon.com/lake-formation/latest/dg/working-with-services.html` (200 r=0) — 표의 행: "Apache Hive on Amazon EMR (EC2) — Read/write access / Read access / **Not supported**"(테이블 / 열 / 행·셀), "Apache Hive on Amazon EMR Serverless — **Not supported**"(세 칸 모두), "**Amazon EMR on EKS** … **Not supported**", "Amazon Athena (Spark) … **Not supported**". ⚠️ 이 사실은 **표 구조**에 있어 산문 검색으로는 잡히지 않는다.
- **수정안**: ① 해설의 둘째 문장을 「Lake Formation 권한은 통합된 분석 서비스에 적용되지만 **지원 수준은 엔진마다 다릅니다** — Athena(SQL)·Redshift Spectrum 은 열·행·셀 수준까지 지원하고, EMR 은 엔진·배포 형태에 따라 다릅니다(예: EC2 위의 Hive 는 행·셀 수준 미지원). 도구를 바꿀 때는 지원 표를 확인합니다.」로 바꾼다. ② 지문의 「Athena·EMR 쿼리 전체에 … 일관되게」를 「**Athena 쿼리에**」로 좁히거나 「지원되는 분석 엔진에」로 바꾼다(그대로 두면 지문 전제가 공식과 어긋난다). **정답 인덱스 불변.** 출처에 위 표 페이지를 더한다(지금은 소개 페이지 하나).
- **전수**: 「Lake Formation … 일관」 — saa 문항 **1자리**(이 문항 해설) + 지문 1자리 · md 0자리(정정됨). 다른 자격증 0.
- ⚠️ **가드**: `_rules` 의 리터럴 `'Athena, EMR(Apache Spark), Redshift Spectrum, Glue ETL 전반에 Lake Formation 권한이 일관되게 적용됩니다'` 는 문항의 「Athena·EMR·Redshift Spectrum 쿼리 전반에」와 구두점·열거가 달라 **일치하지 않는다**.

### R3. `saa-t4-4-q12` — 정답 보기 「Transit Gateway $0.03/GB($0.01 교차 AZ + $0.02 처리)」가 같은 Task 학습문서·가드 판정과 정반대

- **공개 여부**: verified true
- **현재 정답 인덱스**: 2 (「VPC 피어링 $0.01/GB(교차 AZ 전송), Transit Gateway $0.03/GB($0.01 교차 AZ + $0.02 처리)로 피어링이 저렴하다」)
- **결함**: 정답 보기 · 해설(「Transit Gateway는 교차 AZ 전송 $0.01/GB에 … $0.02/GB가 추가되어 $0.03/GB입니다」) · `wrongExplanations["1"]`·`["3"]` 네 자리가 **TGW 쪽에 교차 AZ 전송 요금을 합산**한다. 같은 Task 학습문서는 2026-10-19 에 이것을 **「이중 계상」**이라며 고쳤다 — `saa-t4-4.md:328` 「$0.02/GB (처리 요금만 — **TGW를 통과하는 AZ 간 트래픽에는 목적지 AZ 전송 요금이 붙지 않음**)」 · `:444` 정정 메모. md 가드(`saa_t2_t4_facts_test.dart:632`)와 전파 규칙(`saa_question_propagation_test.dart:456`)이 `'$0.01/GB + $0.02/GB'` 를 **금지 문구로 등재**해 뒀다. 문항은 같은 산술을 「$0.01 교차 AZ + $0.02 처리」로 적어 통과했다. **학습문서로 공부하면 이 문항의 정답 보기가 틀린 수치로 보인다.**
- **공식 근거**:
  - `https://docs.aws.amazon.com/eks/latest/best-practices/cost-opt-networking.html` (200 r=0, md 근거 7번): "You are billed on an hourly basis and for data sent to the TGW. **There is no destination cost associated with inter-AZ traffic that flows through the TGW.**"
  - ⚠️ 반대 방향으로 읽히는 공식 문장도 있다 — 문항이 인용한 `https://aws.amazon.com/transit-gateway/pricing/` (200 r=0): "Data Transfer Charges: You will incur standard AWS data transfer charges, **in addition to** any Transit Gateway charges." → **공식 내부 어긋남**이다(§6 U1). 레포는 더 구체적인 쪽(EKS 모범 사례)을 정본으로 이미 판정했다.
- **수정안**: 레포가 내린 판정에 문항을 맞춘다 — 정답 보기를 「VPC 피어링은 교차 AZ 전송 요금($0.01/GB)만 붙고 데이터 처리 요금이 없으며, Transit Gateway 는 GB당 데이터 처리 요금($0.02/GB)이 붙어 피어링이 저렴하다」로, 해설·오답 근거의 `$0.03/GB` 를 같은 방향으로 고친다. 공식이 갈리는 자리이므로 **「TGW 쪽 교차 AZ 전송 요금의 유무」를 정답의 근거로 쓰지 않는** 쪽이 안전하다(갈림길을 「처리 요금의 유무」로 옮긴다). 오답 [1]「둘 다 $0.02/GB」가 참이 되지 않도록 함께 확인한다. **정답 인덱스 불변.**
- **전수**: 「0.03/GB|$0.01 교차 AZ」 — saa 문항 **5자리**(전부 이 문항: 보기 [0]·정답 [2]·해설·W1·W3) · md 0자리. 다른 자격증 0.
- ⚠️ **가드 충돌**: `saa_question_facts_test` 의 이 문항 레코드가 `correct: 2` · `forbidden: ['GB당 총비용 비교로 옳은 것은']` · `required: ['송신 측 1 GB 기준', '양방향']` 을 건다. 재작성 때 두 `required` 문구를 유지할 것.

### R4. `saa-t1-3-q8` — 오답 보기 「NAT 인스턴스로 교체하면 인바운드 트래픽도 처리할 수 있다」는 공식 비교표로는 참이다(정답이 둘)

- **공개 여부**: verified true
- **현재 정답 인덱스**: 3 (「NAT 게이트웨이는 아웃바운드 전용이므로, ALB를 퍼블릭 서브넷에 배치…」)
- **결함**: 지문은 「프라이빗 서브넷의 EC2에 외부 인터넷에서 직접 접근하려 한다 … 올바른 접근 방법은?」이고 오답 [1]이 「NAT 인스턴스로 교체하면 인바운드 트래픽도 처리할 수 있다」다. `wrongExplanations["1"]` 은 「**NAT 인스턴스도 NAT 게이트웨이와 동일하게 아웃바운드 전용** 역할을 합니다. 인바운드 직접 접근 문제는 해결되지 않습니다」라고 단정한다. 공식 비교표는 NAT 인스턴스가 **포트 포워딩**과 **배스천 서버** 용도를 지원한다고 적는다. 따라서 보기 [1]은 사실로서 참이고(설정이 필요할 뿐) 오답 근거는 공식 표와 정면으로 다르다. `saa-t1-3.md:145` 도 「NAT 인스턴스 … 아웃바운드 전용」으로 적는다.
- **공식 근거**: `https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-comparison.html` (200 r=0) — 비교표: "Port forwarding — NAT gateway: **Not supported.** / NAT instance: **Manually customize the configuration to support port forwarding.**" · "Bastion servers — NAT gateway: **Not supported.** / NAT instance: **Use as a bastion server.**"
- **수정안**: ① 보기 [1]을 **명백히 거짓**인 서술로 바꾼다(예: 「NAT 게이트웨이에 인바운드 규칙을 추가하면 외부에서 프라이빗 EC2로 직접 접속할 수 있다」). ② `wrongExplanations["1"]` 을 새 보기에 맞게 쓰되 「NAT 인스턴스는 포트 포워딩·배스천으로 쓸 수 있지만 AWS 는 NAT 게이트웨이를 권장하고, 웹 서비스 인바운드는 ALB 가 표준」이라는 사실을 해설에 한 줄 남긴다. ③ `saa-t1-3.md:145` 의 「아웃바운드 전용」을 「아웃바운드 NAT 가 본래 용도(포트 포워딩·배스천으로도 구성 가능 — 비교표)」로 고친다. **정답 인덱스 불변.**
- **전수**: 「NAT 인스턴스」 — saa md **8자리**(`saa-t1-3.md:61·145·148·150` · `saa-t4-4.md:240·249·343·432`) · 문항 **2자리**(이 문항 보기 [1]·W1). 「아웃바운드 전용」 단정은 그중 `saa-t1-3.md:145` 와 W1 **2자리**. `saa-t4-4.md` 의 비교 서술은 옳다.

### R5. `saa-t3-7.md` — 「Geoproximity 는 Route 53 Traffic Flow 에서만」 5줄: 공식·문항과 정반대(라이브 학습문서)

- **공개 여부**: 라이브 학습문서(이 Task 문항 15/15 verified)
- **현재 정답 인덱스**: 해당 없음(학습문서). 관련 문항 `saa-t3-7-q1`[1] · `saa-t3-7-q6`[1] 은 **이미 옳다**.
- **결함**: `saa-t3-7.md:110`(표 「(Traffic Flow 필요)」) · `:120`(「Geoproximity는 **Route 53 Traffic Flow** 기능에서만 사용할 수 있습니다」) · `:318`(시험 직전 요약 「Geoproximity는 Traffic Flow 필요」) · `:339`(흔한 함정 5 「Traffic Flow 없이는 설정할 수 없습니다」) · `:340`(원리 줄). 문항 쪽은 2026-10-28 배치가 고쳤고 `saa_question_facts_test.dart:1644~1671` 이 문항에서 이 문구를 금지하며 「**Traffic Flow 전용이 아니다** — Traffic Flow 에서만 되는 것은 편향 범위를 보여 주는 **지도**」를 요구한다. **학습문서만 남아 문항 q1·q6 의 해설과 정반대를 가르친다**(문항 가드는 `.md` 를 보지 않는다).
- **공식 근거**:
  - `https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html` (200 r=0): "Geoproximity routing policy – Use when you want to route traffic based on the location of your resources and, optionally, shift traffic from resources in one location to resources in another location. **You can use geoproximity routing to create records in a private hosted zone.**"
  - `https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geoproximity.html` (200 r=0): "**The maps are available only with Traffic Flow.**"
- **수정안**: 다섯 줄을 「Geoproximity 는 레코드를 만들 때 고르는 라우팅 정책이고 프라이빗 호스팅 영역에서도 쓸 수 있습니다. **Traffic Flow 에서만 되는 것은 편향 범위를 보여 주는 지도**입니다」로 통일한다(문항 q6 해설과 같은 문장). `lastVerified` 를 올리고, md 가드(`saa_t2_t4_facts_test` 또는 전수 집계)에 `Traffic Flow[^|]{0,20}(에서만|필요)` 금지를 **md 까지** 걸 것.
- **전수**: 「Geoproximity … Traffic Flow」 단정 — saa md **5자리**(위) · 문항 0자리(가드로 닫힘). 다른 자격증: `soa-t5-3.md:67·133·214` 3자리(→ §5).

---

## 2. 🟡

### Y1. `saa-t1-2-q9` + `saa-t1-2.md` — Control Tower 예방 제어를 「SCP」 하나로 적는다

- **공개 여부**: verified true · **현재 정답 인덱스**: 2
- **결함**: 해설 「예방적 제어는 SCP, 탐지적 제어는 AWS Config 규칙으로 구현됩니다」 · `wrongExplanations["0"]` 「예방적 제어는 SCP로 구현해…」. 정답(사전예방적 = CloudFormation 훅)은 옳다. 공식은 예방 제어의 구현 수단을 **셋**으로 적는다. md `saa-t1-2.md:238`(표 「예방적 … SCP」) · `:253`(「예방적 가드레일(SCP)」) · `:307`(「예방적 가드레일만 SCP로 구현됩니다」)도 같다(`:254` 는 탐지·사전예방 설명이라 맥락만 맞추면 된다). 덤으로 `:253` 은 「SCP 는 **IAM API 호출**을 차단」이라 적는데 문항 W0 는 「IAM API 호출로 한정되지 않습니다」라고 적어 **md 와 문항이 어긋난다**.
- **공식 근거**: `https://docs.aws.amazon.com/controltower/latest/controlreference/control-behavior.html` (200 r=0): "The preventive controls are implemented using Service Control Policies (SCPs), **Resource Control Policies (RCPs), and declarative policies** … The detective controls are implemented using AWS Config rules. The proactive controls are implemented using AWS CloudFormation hooks."
- **수정안**: 「예방적 제어는 SCP·RCP·선언적 정책으로 구현」으로 고친다(문항 2자리 + md 3자리). `:253` 의 「IAM API 호출」을 「금지된 API 작업」으로. 출처에 위 페이지를 더한다(현 인용 페이지 2개에는 `hook`·`SCP`·`Config` 가 0건). 정답 인덱스 불변.
- **전수**: 「예방…SCP」 — saa md 3자리(`:238·:253·:307`; 정규식에 함께 걸리는 `:219·:372·:376` 은 SCP 쿼터 서술이라 무관) · 문항 2자리(이 문항 해설·W0).

### Y2. `saa-t1-2-q11` + `saa-t1-2.md:113` — 감사 계정을 「전 계정 읽기 전용」으로만 적는다

- **공개 여부**: verified true · **현재 정답 인덱스**: 1
- **결함**: 정답 보기 「감사 계정은 보안팀이 전 계정에 **읽기 전용**으로 접근할 수 있어…」 · 해설 「전 계정에 읽기 전용 접근 권한을 가집니다」 · md:113 「보안팀 전용. 전 계정 읽기 전용 접근」. 공식은 감사 계정에 **읽기 전용과 관리자(전체 권한) 두 교차 계정 역할**이 있다고 적고, 계정 이름도 바뀌었다.
- **공식 근거**: `https://docs.aws.amazon.com/controltower/latest/userguide/special-accounts.html` (200 r=0): "The Config aggregator account should be restricted to security and compliance teams with **auditor (read-only) and administrator (full-access) cross-account roles** to all accounts in the landing zone." · "You might know this account by its **previous name: the audit account**."
- **수정안**: 보기·해설·md 를 「보안·컴플라이언스 팀이 전 계정에 교차 계정 역할(읽기 전용 감사 역할과 관리자 역할)로 접근」으로 고치고, 「감사 계정(현행 문서 명칭 Config aggregator 계정)」을 한 번 병기한다. 독립 조사라는 정답의 요지는 그대로다. 정답 인덱스 불변.
- **전수**: saa 문항 2자리(이 문항 보기·해설) · md 1자리.

### Y3. `saa-t1-5-q9` · `saa-t1-5-q10` + `saa-t1-5.md:242·357` — Macie 를 「머신러닝으로」만 적는다

- **공개 여부**: verified true · **현재 정답 인덱스**: q9 = 1 · q10 = 3
- **결함**: q9 정답 보기 「Amazon Macie — **머신러닝으로** S3를 스캔해 PII를 탐지…」 · q9 해설 · q10 해설 「머신러닝으로 탐지합니다」. md 는 `:234` 가 「머신러닝과 패턴 매칭」으로 정정됐지만 `:242`(🧠 원리 「왜 Macie는 **규칙 기반이 아닌 머신러닝으로**…」)와 `:357`(자가 점검 정답)이 남았다. 같은 레포의 CLF·DEA·MLA 는 이미 「머신러닝과 패턴 매칭」으로 적는다(§5).
- **공식 근거**: `https://docs.aws.amazon.com/macie/latest/user/what-is-macie.html` (200 r=0): "…discovers sensitive data by using **machine learning and pattern matching**…"
- **수정안**: 문항 3자리 + md 2자리를 「머신러닝과 패턴 매칭(관리형·사용자 지정 데이터 식별자)」으로. `:242` 원리 블록은 「규칙 기반이 아닌」이라는 전제 자체가 틀렸으므로 문장을 다시 쓴다. 정답 인덱스 불변.
- **전수**: 「Macie…머신러닝」 — saa md 5자리(그중 `:35·:377` 은 「머신러닝+패턴 매칭」으로 옳고 `:382` 는 정정 메모) → 고칠 것 **2자리** · 문항 **3자리**.

### Y4. `saa-t2-1-q8` — 「처리 보장을 위해 SQS를 중간에 두는 것을 권장」(R1 계열)

- **공개 여부**: verified true · **현재 정답 인덱스**: 1
- **결함**: `wrongExplanations["2"]` 「Lambda를 직접 구독할 수 있지만 **처리 보장을 위해** SQS를 중간에 두는 것을 **권장**합니다」. R1 과 같은 전제(직접 구독은 처리가 보장되지 않는다)이고 「권장」의 공식 근거가 없다.
- **공식 근거**: R1 과 같다(100,015회·23일 · 구독 단위 DLQ).
- **수정안**: 「Lambda 는 SNS 구독자로 지원됩니다. 소비자별로 처리 속도를 분리하거나 밀린 메시지를 쌓아 둬야 하면 SQS 를 사이에 둡니다.」 정답 인덱스 불변.
- **전수**: R1 참조(문항 2자리).

### Y5. `saa-t2-5-q11` + `saa-t2-5.md:182` — 「동기 복제의 쓰기 지연이 체감되지 않는다」

- **공개 여부**: verified true · **현재 정답 인덱스**: 0
- **결함**: 해설 「같은 리전의 AZ 간 왕복 지연은 충분히 짧아 동기 복제로 인한 **쓰기 지연이 애플리케이션에서 체감되지 않습니다**」 · md:182 「체감되지 않는 수준입니다」. 공식은 쓰기·커밋 지연이 **늘 수 있다**고 적는다. 같은 자격증의 `saa-t2-4-q4`[1] 해설은 「쓰기 지연이 약간 추가되지만」이라 적어 **문항끼리도 어긋난다**.
- **공식 근거**: `https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html` (200 r=0): "DB instances using Multi-AZ DB instance deployments can have **increased write and commit latency** compared to a Single-AZ deployment. This can happen because of the synchronous data replication that occurs."
- **수정안**: 「같은 리전 안이라 동기 복제가 가능하지만, 단일 AZ 배포보다 쓰기·커밋 지연이 늘 수 있습니다」로(문항 1 + md 1). 정답 인덱스 불변.
- **전수**: 「체감되지」 — saa md 1자리 · 문항 1자리.

### Y6. 「RDS Multi-AZ = 동기 복제」 한정 없는 서술 — md 10줄 + 문항 3 (+ 「스탠바이는 장애조치용」 2)

- **공개 여부**: verified true · **현재 정답 인덱스**: `saa-t2-4-q2` = 2 · `saa-t2-5-q8` = 0 · `saa-t2-5-q11` = 0 · `saa-t4-4-q15` = 1
- **결함**: Multi-AZ 는 배포 유형이 둘이고 **DB 클러스터 배포는 반동기**이며 리더가 읽기를 처리한다. 2026-10-28 A조가 세 문항을 「Multi-AZ **DB 인스턴스** 배포」로 한정했고 SOA 는 같은 계열을 전수 가드로 닫았지만, SAA 에는 한정 없는 자리가 남아 있다. 탐지 규칙은 SOA 판과 같다(「Multi-AZ」 문맥 + `(?<!비)(?<!반)동기` + 「인스턴스 배포|DB 클러스터|반동기」 한정 없음, **문항 단위**).
- **공식 근거**: Y5 의 페이지(인스턴스 배포 = synchronous) + `https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html` 이 "Multi-AZ DB clusters deployment only" 를 따로 적는다(지난 P1 판정에서 확인된 자리).
- **수정안**: 아래 자리의 「RDS Multi-AZ」를 「RDS Multi-AZ **DB 인스턴스 배포**」로 한정한다(문장을 다시 쓰지 않고 한정어만 넣는다). 정답 인덱스 불변.
- **전수**(실측): md **10줄** — `saa-t2-4.md:200·473·503·531` · `saa-t2-5.md:176·179·184·251` · `saa-t3-5.md:56·186` / 문항 **3개** — `saa-t2-4-q2`(해설) · `saa-t2-5-q8`(보기 [1]·W1) · `saa-t2-5-q11`(보기 [0]·[1]·[2]·해설·W2). 같은 뿌리의 「Multi-AZ RDS의 스탠바이는 장애조치용」 — `saa-t4-4.md:360` · `saa-t4-4-q15`(해설).

### Y7. `saa-t3-4-q8` + `saa-t3-4.md:493·509` — 「AWS Batch 는 실행 시간 제한이 없다」

- **공개 여부**: verified true · **현재 정답 인덱스**: 2
- **결함**: 정답 보기 「AWS Batch — **실행 시간 제한 없이**…」 · 해설 「실행 시간 제한이 없습니다」 · md 흔한 함정 6(`:493`) · 자가 점검 정답(`:509`). Fargate 컴퓨팅 환경의 작업은 14일을 넘길 수 없다(같은 Task `q7` 해설이 Fargate 를 컴퓨팅 환경으로 든다). `99-gaps` 의 `G-3.2-16` 이 「미확보」로 남긴 자리가 라이브에 단정으로 있다.
- **공식 근거**: `https://docs.aws.amazon.com/batch/latest/userguide/job_timeouts.html` (200 r=0): "Jobs that run on Fargate resources **can't expect to run for more than 14 days**. If the timeout duration exceeds 14 days, the Fargate resources may no longer be available and the job will be terminated."
- **수정안**: 「Lambda 의 15분 같은 실행 시간 상한이 없어 장시간 작업을 돌릴 수 있습니다(단 Fargate 컴퓨팅 환경의 작업은 14일을 넘길 수 없습니다)」로(문항 2 + md 2). 정답 인덱스 불변.
- **전수**: 「실행 시간 제한…없」 — saa md 3자리(`saa-t3-4.md:493·509` + `saa-t2-2.md:411`) · 문항 4자리(`t3-4-q8` 보기·해설 · `t3-4-q1` W3 · `t2-2-q14` 해설). 그중 **Batch 를 가리키는 것은 md 2 + 문항 2**이고, 나머지(ECS on Fargate 의 장시간 실행)는 이 항목의 대상이 아니다.

### Y8. `saa-t3-5-q11` — RDS Magnetic 은 「이전 세대」가 아니라 **사용 중단**이다(자기 인용 페이지가 그렇게 적는다)

- **공개 여부**: verified true · **현재 정답 인덱스**: 3
- **결함**: 보기 [0] 「Magnetic 스토리지 — 가장 오래된 옵션으로 안정적이다」의 오답 근거가 「Magnetic(standard)은 **이전 세대 볼륨 타입이고** … 현재 세대 볼륨을 쓰도록 공식 문서가 권장합니다. **평균 약 100 IOPS 수준**이라…」. 문항이 인용한 페이지는 지금 **deprecated** 를 명시하고 새 인스턴스 생성 불가·기존 볼륨 gp3 이전을 적는다. 「평균 약 100 IOPS」는 그 페이지에 없다(100 IOPS 는 gp2 최솟값으로만 나온다). `saa-t3-5.md:203` 은 이미 「사용 중단됨. 새 DB 인스턴스 생성에는 제공되지 않으며」로 옳다 — **md 는 옳고 문항만 낡았다.**
- **공식 근거**: `https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html` (200 r=0): "**Amazon RDS has deprecated magnetic storage. You can no longer create new DB instances using magnetic storage, and Amazon RDS has migrated existing magnetic storage volumes to gp3.** Starting July 1, 2026, you can no longer restore a snapshot to magnetic storage."
- **수정안**: W0 를 「RDS 는 Magnetic 스토리지를 사용 중단했습니다 — 새 DB 인스턴스를 Magnetic 으로 만들 수 없고 기존 볼륨은 gp3 로 이전됐습니다. 선택지가 될 수 없습니다.」로. 「평균 약 100 IOPS」는 지운다. 보기 [0] 자체를 다른 오답으로 바꾸는 것도 방법이다. 해설의 「gp3 (기준 3,000 IOPS·125 MiB/s)」는 같은 페이지가 「용량이 임계값을 넘으면 기준 성능이 오른다」고 적으므로 「(임계 용량 미만의 기준)」을 붙인다. 정답 인덱스 불변.
- **전수**: 「Magnetic|마그네틱」 — saa 문항 3자리(`t3-5-q11` 보기 [0]·W0 = RDS · `t3-2-q4` 해설 = **EBS** 이전 세대, 대상 아님) · md 3자리(`t3-5.md:203` 옳음 · `t3-2.md:468`·`t4-1.md:223` 은 EBS). ⚠️ `saa_question_facts_test` 가 이 문항에 `forbidden ['범용 SSD(gp2/gp3)']` · `required ['gp3는 버스트를 쓰지 않아']` 를 건다 — 유지할 것.

### Y9. `saa-t3-8-q11` — 「NAT 게이트웨이는 … 인터넷을 경유합니다」

- **공개 여부**: verified true · **현재 정답 인덱스**: 0
- **결함**: `wrongExplanations["3"]` 「NAT 게이트웨이는 비용이 발생하고 **인터넷을 경유합니다**」. 같은 계열의 `saa-t1-3-q9`[2] W0 는 2026-10-28 에 「AWS 네트워크를 벗어나지 않으므로 공용 인터넷으로 나간다는 서술은 정확하지 않지만…」으로 정정됐다. 이 문항에는 전파되지 않았다.
- **공식 근거**: `https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html` (200 r=0, 이 세션 추출 본문에서 재확인): "While traffic to Amazon S3 or DynamoDB traverses the internet gateway, **it does not leave the AWS network**".
- **수정안**: 「NAT 게이트웨이 경로는 S3·DynamoDB 의 퍼블릭 엔드포인트를 쓰고 시간·데이터 처리 요금이 붙습니다(트래픽이 AWS 네트워크를 벗어나지는 않습니다). 비용 최소화 요건에 맞지 않습니다.」 정답 인덱스 불변.
- **전수**: 「NAT … 인터넷을 경유」 — saa 문항 1자리(이 문항) · md 0.

### Y10. `saa-t1-3-q7` — 「NAT 게이트웨이는 Elastic IP가 반드시 필요」

- **공개 여부**: verified true · **현재 정답 인덱스**: 1
- **결함**: `wrongExplanations["2"]` 가 한정 없이 「반드시」를 쓴다. 프라이빗 NAT 게이트웨이에는 EIP 를 붙일 수 없다. 지문은 인터넷 아웃바운드(퍼블릭 NAT) 맥락이라 결론은 맞다.
- **공식 근거**: `https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html` (200 r=0): "You can't associate an Elastic IP address with a private NAT gateway."
- **수정안**: 「**퍼블릭** NAT 게이트웨이는 Elastic IP 가 필요합니다」. 정답 인덱스 불변. 인용 출처(VPC 소개)도 위 페이지로(Y18).
- **전수**: 「EIP … 반드시」 — saa 문항 1자리.

### Y11. `saa-t2-3-q15` — 오답 보기 [3] 「Elastic Beanstalk — 자동 스케일링과 로드밸런싱을 모두 내장한다」가 참인 서술이다

- **공개 여부**: verified true · **현재 정답 인덱스**: 1
- **결함**: 보기 [3]은 사실로서 참이고 `wrongExplanations["3"]` 이 「내부적으로 ASG·ELB 를 쓰는 PaaS … 하지만 질문의 핵심은 … 직접 수행하는 서비스는 ASG」라며 참·거짓을 말하지 않는다(회피형 반박 — 이 레포에서 「저작자도 참임을 알았다」는 신호로 다뤄 온 형태). 지문이 「역할 구분」을 묻기 때문에 정답은 방어되지만 유일성이 약하다.
- **공식 근거**: 별도 대조 없이 문항 내부 논리로 판정했다(보기가 참이라는 것은 W3 자신이 인정한다).
- **수정안**: 보기 [3]을 거짓 서술로 바꾼다(예: 「AWS Elastic Beanstalk — 인스턴스 수를 사람이 직접 지정해야 하며 자동 조정은 제공하지 않는다」). 정답 인덱스 불변.
- **전수**: 「Beanstalk」 — saa 문항 1개(이 문항 보기·W3) · md 2자리(`t1-5.md:213` · `t2-3.md:390`, 무관).

### Y12. `saa-t2-4-q1` + `saa-t2-4.md:97` — 내결함성 「완전 무중단」 귀속(지난 Fable §2-1 미반영)

- **공개 여부**: verified true · **현재 정답 인덱스**: 1
- **결함**: 정답 보기·해설·W0·md 표가 「HA = 짧은 중단 후 자동 복구 / 내결함성 = 장애 중에도 **완전 무중단**」으로 정의하고 그것을 AWS 공식 구분처럼 가르친다. 2026-11-06 Fable 보고 §2-1 이 P3 로 지적했는데 **가드·HANDOFF 어디에도 판정이 없다**. 현재 출처(`wellarchitected/latest/framework/reliability.html`)에는 `fault tolera`·`high availability` 가 **0건**이다(WA 재구성 뒤 URL 만 바뀐 자리).
- **공식 근거**: 「없다」 — 현 인용 페이지(추출 5,977자, 대조군 `recover` 5건·`resilien` 7건 양성)에서 두 용어 0건. 이 정의를 그대로 적는 공식 페이지를 이 세션에서 찾지 못했다(→ §6 U6 과 함께 「확인되지 않음」).
- **수정안**: 「완전 무중단」을 「중단 없이 계속 동작하도록 **설계 목표**를 둔다」로 낮추고 「공식 정의」처럼 읽히지 않게 「일반적으로 구분하는 방식」으로 쓴다. 근거 페이지를 찾으면 출처를 교체한다. 정답 인덱스 불변.
- **전수**: 「완전 무중단」 — saa md 1자리 · 문항 4자리(전부 이 문항: 보기 [0]·[1]·해설·W0).

### Y13. `saa-t4-3-q8` + `saa-t4-3.md:193` — 「최솟값(기본 0.5 ACU)」

- **공개 여부**: verified true · **현재 정답 인덱스**: 2
- **결함**: 해설 「유휴 상태에서는 설정된 최솟값(**기본 0.5 ACU**) ACU만 과금」. 인용 페이지에 `default` 가 0건이고, 설정 페이지는 0.5 를 「기본값」이 아니라 「고르고 싶어지는 값」으로 적으며 **0 ACU(자동 일시 정지)** 도 최솟값으로 둘 수 있다고 적는다. 같은 Task `q1`[1] 해설과 md `:194·:414` 는 0 ACU 를 반영했는데 md `:193`(「유휴 시 최솟값(0.5 ACU)만 과금」)과 이 문항이 남았다.
- **공식 근거**: `https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html` (200 r=0): "**It's tempting to always choose 0.5** for the minimum Aurora serverless capacity setting. … You can also enable automatic pause behavior by specifying a **minimum capacity of 0 ACUs**…"
- **수정안**: 「설정한 최솟값만큼 과금됩니다(0 이 아닌 최솟값은 0.5 ACU 부터이고, 최솟값을 0 ACU 로 두면 자동 일시 정지로 컴퓨팅 요금이 0 이 됩니다)」. md:193 도 같이. 정답 보기의 「유휴 시 최솟값 ACU만 과금된다」는 그대로 둘 수 있다. 정답 인덱스 불변.
- **전수**: 「기본 0.5」 — saa 문항 1자리 · md 0자리(「0.5 ACU」 표현은 md 4 · 문항 5자리이고 「증가 폭 0.5 ACU」는 옳다).

### Y14. `saa-t3-9-q15` + `saa-t3-9.md:130·146` — Kinesis Video Streams + Rekognition 「실시간 영상 분석」: 그 Rekognition 기능이 신규 고객에게 닫혔다 / Flink 언어에서 Python 누락

- **공개 여부**: verified true · **현재 정답 인덱스**: 2
- **결함 ⓐ(서비스 상태)**: 지문 「Amazon Rekognition으로 **실시간 영상 분석**을 수행하려 한다」와 정답 보기 「…Rekognition과 연동한다」, md `:130`(「Amazon Rekognition과 연동해 실시간 영상 분석」)·`:146` 이 가르치는 스트리밍 영상 분석은 **신규 고객에게 더 이상 제공되지 않는다**. 상태 표기가 없다(같은 문서는 Snow 패밀리·FSx File Gateway 에는 꼼꼼히 단다).
- **결함 ⓑ(전파 탈출)**: `wrongExplanations["3"]` 「Managed Service for Apache Flink는 … 분석 로직(**Java·Scala·SQL**)을 작성하는 서비스」 — Python 누락. md `:122` 는 「Java·Scala·Python·SQL」로 정정됐다.
- **공식 근거**:
  - `https://docs.aws.amazon.com/rekognition/latest/dg/streaming-video.html` (200 r=0): "**Streaming Video and Bulk Image Analysis is no longer available to new customers.** … This change does not impact the availability of other Amazon Rekognition features." (AWS Lifecycle 「Services in Maintenance」 표: "Amazon Rekognition – Streaming Events and Batch Image Content Moderation — March 31, 2026")
  - `https://docs.aws.amazon.com/managed-flink/latest/java/what-is.html` (200 r=0): "you can use Java, Scala, **Python**, or SQL".
- **수정안**: ⓐ 해설에 상태 한 줄(「Rekognition 의 스트리밍 영상 분석은 신규 고객에게 더 이상 제공되지 않습니다 — 영상 수집·저장이라는 이 문항의 답은 그대로입니다」)을 달고 md 두 줄에도 같은 메모를 단다. 지문을 「영상을 수집·저장한 뒤 분석 서비스로 넘기려 한다」로 일반화하는 방법도 있다. ⓑ W3 를 「Java·Scala·Python·SQL」로. 정답 인덱스 불변.
- **전수**: 「Rekognition」 — saa 문항은 이 문항뿐(지문·보기 [0]·[1]·[2]) · md `t3-9.md:130·146`(+ `t2-4.md:446·450` 은 이미지 콘텐츠 검토 — 단건 API 라 대상 아님). 「Java·Scala」 — 문항 1자리 · md 2자리(옳음).

### Y15. `saa-t4-4-q6` · `saa-t4-4-q7` — 「시간당 ENI 요금」: 레포 판정(엔드포인트·AZ별)이 문항에 전파되지 않았다

- **공개 여부**: verified true · **현재 정답 인덱스**: q6 = 3 · q7 = 1
- **결함**: q6 정답 보기·해설 「$0.01/GB 데이터 처리 요금과 **시간당 ENI 요금**」 · q7 `wrongExplanations["3"]` 「데이터 처리 요금과 ENI 요금」. md 는 2026-10-19 에 「"ENI별"에서 **엔드포인트·AZ별**로」 고쳤고(`saa-t4-4.md:444` ②) md 가드·전파 규칙이 `'$0.01/GB + 시간당 ENI 요금'` 을 금지한다(`saa_t2_t4_facts_test.dart:640` · `saa_question_propagation_test.dart:461`). 문항은 「$0.01/GB 데이터 처리 요금**과** 시간당 ENI 요금」으로 적어 통과했다. 같은 파일 `q4`[1] W2 는 「시간 요금은 ENI 단위가 **아니라**…」고 적어 **한 파일 안에서 문항끼리 어긋난다**.
- **공식 근거**: `https://aws.amazon.com/privatelink/pricing/` (200 r=0): "You will be billed for each hour that your VPC endpoint remains provisioned **in each Availability Zone**, irrespective of the state of its association with the service." ⚠️ 같은 페이지의 가격 예시는 "you will be charged $0.01 per hour for **each endpoint ENI**" 라고도 적는다 — 표현이 둘이다(§6 U3). 즉 「ENI 요금」이 거짓은 아니고, 결함은 **레포가 고른 표현과 문항의 불일치**다.
- **수정안**: 세 자리를 「AZ별 시간 요금(엔드포인트가 각 AZ 에 프로비저닝된 시간 기준)」으로 통일하고, q4 W2 의 「ENI 단위가 아니라」는 단정을 「AZ 마다 엔드포인트 ENI 가 하나씩 생기므로 사실상 AZ별 시간 요금」으로 누그러뜨린다. q6 의 「200개 이상 서비스 지원」은 근거가 없다(§6 U6). 정답 인덱스 불변.
- **전수**: 「ENI 요금」 — saa 문항 3자리(q6 보기·해설 · q7 W3) · md 0자리(「ENI 유지 비용」 `t4-4.md:148` 1자리는 같은 계열).

### Y16. 학습문서에만 남은 서술 2건(문항은 이미 정정 — 역방향 잔존)

- **`saa-t2-2.md:365`** 「단순 프록시라면 HTTP API가 더 저렴하고 **지연도 낮습니다**」 — `saa_question_facts_test.dart:2474` 가 문항 `saa-t2-2-q8`[1] 에서 「지연도 낮다」·「지연이 낮다」를 금지하며 「**어느 공식 페이지에도 없다**」고 적는다. 가드가 문항만 봐서 md 가 남았다. → 「더 저렴하고 기능이 최소화돼 있습니다」로. (공식 근거: 「없다」 — 2026-10-28 배치가 비교 페이지·소개 페이지 둘 다에서 "lower price"·"minimal features" 까지만 확인.)
- **`saa-t1-3.md:389`** 「IP 차단은 **반드시 NACL**을 사용합니다」 — `saa_p3_review_fix_test` §4-8 이 문항에서 「반드시 NACL」을 금지했다(WAF `IP set match statement` 가 "allow or block web requests based on the IP addresses that the requests originate from"). md 흔한 함정 2 가 남았다. → 「서브넷 수준에서 IP 를 차단하려면 NACL(웹 요청이라면 WAF IP 집합도 가능)」.
- **전수**: 각 1자리(md 전수 grep). 문항 쪽 0자리(가드로 닫힘).

### Y17. `saa-t2-5.md:161` — ARC readiness check 에 상태 표기가 없다

- **공개 여부**: 라이브 학습문서(해당 문항 없음 — 문항은 ARC 를 묻지 않는다)
- **결함**: §5 의 「ARC의 기능 구분」 표가 readiness check 를 다섯 기능 중 하나로 싣고 상태를 적지 않는다(요금 칸 「—」). 이 기능은 신규 고객에게 닫혔다. SCS 문서는 같은 사실을 이미 적는다(§5).
- **공식 근거**: `https://docs.aws.amazon.com/r53recovery/latest/dg/arc-readiness-availability-change.html` (200 r=0): "The readiness check feature in Amazon Application Recovery Controller (ARC) is **no longer open to new customers**. Existing customers can continue to use the service as normal."
- **수정안**: 표의 그 행에 「⚠️ 신규 고객에게 열려 있지 않음(기존 고객은 계속 사용)」을 단다.
- **전수**: 「readiness check」 — saa md 3자리(`t2-5.md:161` 표 · `:317` 근거 · `:322` 메모) · 문항 0.

### Y18. 인용 페이지가 그 사실을 담지 않는다 — **90문항**(계약 §2-②)

- **무엇을 셌나**: 문항의 핵심 주장을 인용 페이지 추출 본문에 탐침해 **0건**이 나온 자리. 0건이면 동의어·다른 표현으로 다시 탐침했고(예: `t2-5-q8` 수치·`t4-5-q8` 75%·`t4-4-q5` 「each way」는 재탐침에서 **실재**가 확인돼 표에서 뺐다), 추출 길이를 함께 봤다. **사실 자체는 대부분 옳다** — 결함은 출처다. 원인은 셋이다: ① 서비스 **소개 페이지**(welcome·what-is·Introduction)를 단 자리(인용 URL 71개 중 28개) ② 2026-11-17 WA 재구성으로 `reliability-pillar/welcome.html` 이 `framework/reliability.html` 로 **URL 만 교체**돼 사실이 따라오지 않은 `saa-t2-4` 8문항 ③ 페이지 자체가 바뀐 자리(CloudFront 요금 → 정액제 플랜 표 · RDS 스토리지 → 목차 페이지).
- **대체 출처 열의 뜻**: ✔ = 이 세션에서 `curl -sL` 로 **`200 r=0`** 을 확인하고 **본문에 그 사실이 있음**을 확인한 페이지(34문항) · ◐ = 일부만 담음(6문항) · — = 검증한 대체 출처가 없음(2단계가 찾아야 한다). 「(경미)」 15문항은 시나리오 값·부수 표현이라 우선순위가 낮다.
- **공개 여부**: 전부 verified true. 「정답」 열은 **실측 정답 인덱스**다.
- ⚠️ **형식**: SAA 의 `sources` 는 **한 줄 압축 형식**(`{ "title": …, "url": … }`)이다(CLF·MLA·AIF 의 다중 행과 다르다 — 파일마다 실측할 것). `json.dumps(indent=2)` 로 재현되지 않는다.

| 문항 | 정답 | 현재 출처 | 인용 페이지에 없는 것 | 대체 출처 |
|---|---|---|---|---|
| `saa-t1-1-q2` | 1 | `…/IAM/latest/UserGuide/id_roles.html` | `instance profile`·`metadata` 0건(역할 일반 페이지) | ✔ `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html` (`instance profile` 23건) |
| `saa-t1-1-q3` | 1 | `…/IAM/latest/UserGuide/id_roles.html` | `execution role` 0건 | ✔ `https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html` (`execution role` 29건) |
| `saa-t1-1-q15` | 1 | `…/IAM/latest/UserGuide/root-user-best-practices.html` | 「Organizations에서 새로 만든 계정은 루트 자격증명 없음」 문장을 못 찾음(`by default`·`new accounts` 0건). 14일 유예는 있음 | — (미검증) |
| `saa-t1-2-q1` | 0 | `…/organizations/latest/userguide/orgs_introduction.html` | `inherit` 0건(소개 페이지) | ✔ `https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_evaluation.html` |
| `saa-t1-2-q4` | 3 | `…/organizations/latest/userguide/orgs_manage_policies_scps.html` | `explicit deny`·`inherit` 0건 | ✔ 위 `orgs_manage_policies_scps_evaluation.html` ("there must be an explicit Allow statement at every level from the root through each OU") |
| `saa-t1-2-q7` | 1 | `…/organizations/latest/userguide/orgs_manage_policies_scps.html` · `…/organizations/latest/userguide/orgs_introduction.html` | `DeleteTrail`·`log archive` 0건(시나리오 값이지만 기제도 없음) | — (미검증) |
| `saa-t1-2-q9` | 2 | `…/controltower/latest/userguide/what-is-control-tower.html` · `…/controltower/latest/controlreference/controls.html` | `hook`·`SCP`·`Config` 0건(→ Y1 과 함께 처리) | ✔ `https://docs.aws.amazon.com/controltower/latest/controlreference/control-behavior.html` |
| `saa-t1-2-q13` | 3 | `…/singlesignon/latest/userguide/howtogetcredentials.html` | `STS` 0건(`temporary` 18건 — 「STS를 통해」만 근거 없음) | — (경미) |
| `saa-t1-2-q15` | 1 | `…/organizations/latest/userguide/orgs_introduction.html` · `…/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html` | `blast radius`·`isolat` 0건 | — (미검증) |
| `saa-t1-3-q4` | 3 | `…/vpc/latest/userguide/vpc-network-acls.html` | `ephemeral`·`1024-65535` 0건 | — (⚠️ `vpc/latest/userguide/nacl-ephemeral-ports.html` 은 `200 r=1` 죽은 슬러그 — 쓰지 말 것) |
| `saa-t1-3-q7` | 1 | `…/vpc/latest/userguide/what-is-amazon-vpc.html` | 소개 페이지(`regional`·`public subnet` 0건) | ✔ `https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html` |
| `saa-t1-3-q9` | 2 | `…/vpc/latest/privatelink/concepts.html` | `prefix list`·무료 0건(PrivateLink 개념 페이지) | ✔ `https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html` (`prefix list` 12 · `no additional charge` 1) |
| `saa-t1-3-q10` | 1 | `…/vpc/latest/privatelink/concepts.html` | 위와 같음 | ✔ 위와 같음 |
| `saa-t1-3-q13` | 3 | `…/vpc/latest/userguide/what-is-amazon-vpc.html` | `Firehose`·`CloudWatch Logs` 0건(VPC 소개 페이지) | ✔ `https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html` |
| `saa-t1-4-q1` | 1 | `…/waf/latest/developerguide/what-is-aws-waf.html` · `…/waf/latest/developerguide/aws-managed-rule-groups-use-case.html` | `Core rule set`·`XSS` 0건 | ✔ `https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html` |
| `saa-t1-4-q3` | 3 | `…/waf/latest/developerguide/ddos-overview.html` | `SRT`·`24`·`cost protection` 0건 | ◐ `https://docs.aws.amazon.com/waf/latest/developerguide/ddos-srt-support.html` (SRT 5건 · ⚠️ `24` 0건 — 「24×7」은 여기에도 없다) |
| `saa-t1-4-q6` | 2 | `…/waf/latest/developerguide/what-is-aws-waf.html` · `…/AWSCloudFormation/latest/TemplateReference/aws-properties-wafv2-webacl-ruleaction.html` | 평가 순서·기본 동작 서술 없음 | — (미검증) |
| `saa-t1-4-q11` | 1 | `…/secretsmanager/latest/userguide/intro.html` · `…/systems-manager/latest/userguide/parameter-store-policies.html` | 「표준 티어(무료)」 — `standard`·`free` 0건 | — (미검증) |
| `saa-t1-4-q12` | 2 | `…/waf/latest/developerguide/what-is-aws-waf.html` · `…/waf/latest/developerguide/ddos-overview.html` | `edge` 0건 | — (미검증) |
| `saa-t2-1-q4` | 1 | `…/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html` | `maxReceiveCount` 0건(소개 페이지) | — (경미) |
| `saa-t2-1-q9` | 1 | `…/eventbridge/latest/userguide/eb-what-is.html` | `event pattern` 0건(소개 페이지) | — (미검증) |
| `saa-t2-1-q10` | 1 | `…/eventbridge/latest/userguide/eb-what-is.html` | `partner`·`SaaS` 0건 | ✔ `https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-saas.html` |
| `saa-t2-2-q2` | 3 | `…/lambda/latest/dg/welcome.html` · `…/lambda/latest/dg/configuration-vpc.html` | `provisioned concurrency`·`cold start` 0건(Lambda 소개) | ✔ `https://docs.aws.amazon.com/lambda/latest/dg/provisioned-concurrency.html` |
| `saa-t2-2-q4` | 0 | `…/lambda/latest/dg/welcome.html` | `stateless` 0건 | — (경미) |
| `saa-t2-2-q6` | 2 | `…/lambda/latest/dg/welcome.html` | `RDS Proxy`·`database` 0건(Lambda 소개) | ◐ `https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html` (`connection pool` 2 · ⚠️ `Lambda` 0건) |
| `saa-t2-2-q9` | 2 | `…/apigateway/latest/developerguide/welcome.html` | `JWT` 0건 | — (미검증) |
| `saa-t2-2-q11` | 3 | `…/AmazonECS/latest/developerguide/Welcome.html` | `Kubernetes`·`EKS` 0건(ECS 소개) | — (미검증) |
| `saa-t2-2-q12` | 1 | `…/AmazonECS/latest/developerguide/AWS_Fargate.html` | 「Fargate GPU 미지원」 — `GPU` 0건 | — (미검증 — 사실 자체도 재확인 필요) |
| `saa-t2-2-q14` | 1 | `…/lambda/latest/dg/welcome.html` · `…/AmazonECS/latest/developerguide/AWS_Fargate.html` | `EFS` 0건 | — (경미) |
| `saa-t2-2-q15` | 2 | `…/lambda/latest/dg/welcome.html` | `VPC`·`internet` 0건(Lambda 소개) | ✔ `https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html` |
| `saa-t2-3-q5` | 1 | `…/elasticloadbalancing/latest/network/introduction.html` | 「AZ 간 데이터 전송 요금」 — `charge`·`data transfer` 0건 | — (미검증) |
| `saa-t2-3-q9` | 1 | `…/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html` | `machine learning` 0건(`forecast` 3 · `predict` 12) | — (「ML」 문구만 근거 없음) |
| `saa-t2-3-q10` | 0 | `…/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html` · `…/autoscaling/ec2/userguide/lifecycle-hooks.html` | `Pending:Wait` 0건(「wait state」만) | — (경미: 상태 이름은 인스턴스 수명 주기 페이지 쪽) |
| `saa-t2-3-q11` | 1 | `…/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html` · `…/autoscaling/ec2/userguide/lifecycle-hooks.html` | `Terminating:Wait` 0건 | — (경미) |
| `saa-t2-3-q12` | 3 | `…/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html` | 「다섯 가지」 — `VPC Lattice` 0건(소개 페이지) | ✔ `https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html` ("Amazon EC2 · Elastic Load Balancing · VPC Lattice · Amazon EBS · Custom health checks that you define") |
| `saa-t2-3-q14` | 1 | `…/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html` | `mixed` 0건 | — (미검증) |
| `saa-t2-4-q1` | 1 | `…/wellarchitected/latest/framework/reliability.html` | `fault tolera`·`high availability` 0건(→ Y12) | — (미검증) |
| `saa-t2-4-q2` | 2 | `…/wellarchitected/latest/framework/reliability.html` | `single point`·`NAT`·`Multi-AZ` 0건 | — (미검증) |
| `saa-t2-4-q3` | 1 | `…/wellarchitected/latest/framework/reliability.html` | `Route 53`·`load balanc` 0건 | — (미검증) |
| `saa-t2-4-q9` | 1 | `…/wellarchitected/latest/framework/reliability.html` | `static stability` 1건(비용 절충 문장뿐) · `control plane` 0건 | — (미검증) |
| `saa-t2-4-q10` | 2 | `…/wellarchitected/latest/framework/reliability.html` | `session`·`stateless` 0건 | — (미검증) |
| `saa-t2-4-q11` | 1 | `…/wellarchitected/latest/framework/reliability.html` | `NAT` 0건 | ◐ `https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-pricing.html` (AZ별 배치 권고 문장이 있다 — 리전 NAT 는 별도) |
| `saa-t2-4-q12` | 1 | `…/wellarchitected/latest/framework/reliability.html` | `Availability Zone` 0건 | — (미검증) |
| `saa-t2-4-q15` | 1 | `…/wellarchitected/latest/framework/reliability.html` · `…/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html` | 종합 문항 — 페이지에 해당 서술 없음 | — (미검증) |
| `saa-t2-4-q5` | 1 | `…/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html` | 「1~2분」 — `60`·`120`·`DNS` 0건 | — (미검증) |
| `saa-t2-4-q8` | 1 | `…/Route53/latest/DeveloperGuide/dns-failover.html` | `active-passive`·`secondary` 0건 | — (경미) |
| `saa-t2-4-q13` | 1 | `…/Route53/latest/DeveloperGuide/dns-failover.html` | `load balancer` 0건 | — (경미) |
| `saa-t2-4-q14` | 1 | `…/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html` | `automatic` 0건 | — (경미) |
| `saa-t2-5-q10` | 3 | `…/drs/latest/userguide/what-is-drs.html` | `block`·`Windows`·`Linux` 0건(what-is-drs 1,667자) | — (DR 백서가 담지만 「사람이 열 수 없는」 백서 — 2026-11-17 WA 감사 §5) |
| `saa-t3-1-q6` | 1 | `…/AmazonS3/latest/userguide/object-lifecycle-mgmt.html` | 전환 방향 제약 문장 0건 | ◐ `https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html` |
| `saa-t3-2-q2` | 2 | `…/ebs/latest/userguide/ebs-volume-types.html` | `3 IOPS` 0건 | ✔ `https://docs.aws.amazon.com/ebs/latest/userguide/general-purpose.html` (`3 IOPS` 2 · `3,000` 7) |
| `saa-t3-2-q7` | 1 | `…/ebs/latest/userguide/what-is-ebs.html` | `increment` 0건 · 「리전 내 모든 AZ 자동 복제」 없음 | ◐ `https://docs.aws.amazon.com/ebs/latest/userguide/ebs-snapshots.html` ("A snapshot is an incremental backup" · "Snapshots are stored in Amazon S3") |
| `saa-t3-2-q14` | 1 | `…/ebs/latest/userguide/what-is-ebs.html` | 위와 같음 | ◐ 위와 같음 |
| `saa-t3-3-q2` | 2 | `…/AWSEC2/latest/UserGuide/instance-types.html` | `NVMe`·`instance store` 0건 | ✔ `https://docs.aws.amazon.com/ec2/latest/instancetypes/instance-type-names.html` ("d – Instance store volumes") |
| `saa-t3-3-q6` | 2 | `…/AWSEC2/latest/UserGuide/instance-types.html` | `40%` 0건 | — (미검증) |
| `saa-t3-3-q8` | 1 | `…/AWSEC2/latest/UserGuide/instance-purchasing-options.html` | `two-minute`·`hibernate` 0건(구매 옵션 1,753자) | ✔ `https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-instance-termination-notices.html` ("issued two minutes before Amazon EC2 stops or terminates your Spot Instance") |
| `saa-t3-3-q9` | 2 | `…/AWSEC2/latest/UserGuide/instance-purchasing-options.html` | `90%` 0건 | — (미검증) |
| `saa-t3-3-q10` | 2 | `…/AWSEC2/latest/UserGuide/placement-groups.html` | `single AZ`·`10 Gbps` 0건 | ✔ `https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html` |
| `saa-t3-3-q13` | 2 | `…/AWSEC2/latest/UserGuide/placement-groups.html` | `single launch request` 0건 | ✔ 위와 같음 |
| `saa-t3-3-q14` | 2 | `…/AWSEC2/latest/UserGuide/enhanced-networking.html` | `EFA` 0건(enhanced-networking) | ✔ `https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html` |
| `saa-t3-4-q3` | 1 | `…/AmazonECS/latest/developerguide/AWS_Fargate.html` | 「EKS의 시작 유형」 — `EKS` 0건 | — (경미) |
| `saa-t3-4-q7` | 3 | `…/batch/latest/userguide/what-is-batch.html` | `job queue`·`compute environment`·`job definition` 0건 | ✔ `https://docs.aws.amazon.com/batch/latest/userguide/batch_components.html` |
| `saa-t3-5-q5` | 1 | `…/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html` | `six` 0건 · `three Availability Zones` 0건 | ✔ `https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html` ("synchronously replicates the data across Availability Zones to six storage nodes") + `…/AuroraUserGuide/Aurora.Overview.StorageReliability.html` ("copies of the data across three Availability Zones") |
| `saa-t3-5-q12` | 2 | `…/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html` · `…/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html` · `…/AmazonRDS/latest/UserGuide/USER_ReadRepl.Promote.html` | 출처 **제목**이 「되돌릴 수 없음」이라 적지만 그 페이지에 `irrevers`·`undo`·`revert`·`permanent` 0건("it is no longer a read replica" 뿐) | — (제목만 고치면 됨) |
| `saa-t3-6-q8` | 1 | `…/amazondynamodb/latest/developerguide/DAX.html` | `pass` 0건(「strongly consistent reads 에 이상적이지 않다」뿐) | ✔ `https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DAX.consistency.html` |
| `saa-t3-6-q9` | 2 | `…/amazondynamodb/latest/developerguide/Introduction.html` · `…/AmazonCloudFront/latest/DeveloperGuide/Introduction.html` | `last writer`·`MREC` 0건(DynamoDB 소개) | — (미검증) |
| `saa-t3-6-q13` | 2 | `…/AmazonElastiCache/latest/dg/WhatIs.html` · `…/AmazonElastiCache/latest/dg/engine-versions.html` · `…/memorydb/latest/devguide/what-is-memorydb.html` | `transaction log` 0건 | — (경미) |
| `saa-t3-7-q11` | 2 | `…/global-accelerator/latest/dg/what-is-global-accelerator.html` · `…/AmazonCloudFront/latest/DeveloperGuide/request-static-ips.html` | `TCP`·`UDP` 0건(GA 소개 3,845자) | — (미검증) |
| `saa-t3-7-q12` | 1 | `…/global-accelerator/latest/dg/what-is-global-accelerator.html` | `cach`·`TCP` 0건 | — (미검증) |
| `saa-t3-8-q8` | 1 | `…/vpn/latest/s2svpn/VPC_VPN.html` · `…/directconnect/latest/UserGuide/Welcome.html` | `backup` 0건(VPN·DX 소개) | — (미검증 — SOA 감사 A6 이 쓴 `reliability-pillar` REL02-BP02 판 참조) |
| `saa-t3-9-q1` | 1 | `…/streams/latest/dev/introduction.html` | 소개 페이지 — 경미 | — (경미) |
| `saa-t3-9-q2` | 3 | `…/firehose/latest/dev/what-is-this-service.html` | `Lambda` 0건 | — (경미) |
| `saa-t3-9-q4` | 2 | `…/firehose/latest/dev/what-is-this-service.html` · `…/streams/latest/dev/introduction.html` · `…/streams/latest/dev/kinesis-extended-retention.html` | `near real-time` 0건 | — (경미) |
| `saa-t3-9-q7` | 0 | `…/athena/latest/ug/what-is.html` | `Parquet`·`columnar` 0건(Athena 소개 1,277자) | — (미검증) |
| `saa-t3-9-q8` | 2 | `…/emr/latest/ManagementGuide/emr-what-is-emr.html` · `…/glue/latest/dg/what-is-glue.html` | `custom` 0건 | — (경미) |
| `saa-t3-9-q15` | 2 | `…/kinesisvideostreams/latest/dg/what-is-kinesis-video.html` | `Rekognition` 0건(KVS 소개) — Y14 와 함께 처리 | ✔(상태) `https://docs.aws.amazon.com/rekognition/latest/dg/streaming-video.html` |
| `saa-t4-1-q7` | 3 | `…/ebs/latest/userguide/general-purpose.html` | 「약 20% 저렴」 — `20%` 0건 | — (미검증 — 수치 근거 없음) |
| `saa-t4-1-q8` | 2 | `…/ebs/latest/userguide/ebs-volume-types.html` · `…/AWSEC2/latest/UserGuide/preserving-volumes-on-termination.html` | 「중지 상태에서도 과금」 — `billed`·`stopped` 0건 | — (미검증) |
| `saa-t4-1-q9` | 0 | `…/ebs/latest/userguide/ebs-volume-types.html` · `…/compute-optimizer/latest/ug/view-idle-recommendations.html` | `Trusted Advisor` 0건 | ✔ `https://docs.aws.amazon.com/awssupport/latest/user/cost-optimization-checks.html` ("Underutilized Amazon EBS volumes") |
| `saa-t4-1-q14` | 0 | `…/efs/latest/ug/lifecycle-management-efs.html` | `Intelligent-Tiering` 0건(수명 주기 페이지) | — (이름은 EFS FAQ 에 실재하나 `aws.amazon.com` 페이지다. ⚠️ `efs/latest/ug/storage-classes.html` 은 죽은 슬러그) |
| `saa-t4-2-q1` | 1 | `…/AWSEC2/latest/UserGuide/ec2-reserved-instances.html` | 「공식 문서는 … 권장합니다」의 원문 0건(RI 개요) | ✔ `https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html` ("We recommend that you use On-Demand Instances for applications with short-term, irregular workloads that cannot be interrupted.") |
| `saa-t4-2-q8` | 2 | `…/AWSEC2/latest/UserGuide/using-spot-instances.html` | `90` 0건 | — (미검증) |
| `saa-t4-2-q11` | 2 | `…/AWSEC2/latest/UserGuide/ec2-reserved-instances.html` | **무관한 출처**(RI 개요 — `scheduled`·`scaling` 0건) | ✔ `https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-scheduled-scaling.html` |
| `saa-t4-3-q6` | 0 | `…/AmazonRDS/latest/UserGuide/USER_PIOPS.StorageTypes.html` | **목차 페이지**(1,200자 — `reduce`·`can't` 0건) | ✔ `https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIOPS.ModifyingExisting.html` ("You can't deallocate space.") + `…/UserGuide/USER_PIOPS.Autoscaling.html` (maximum storage threshold) |
| `saa-t4-4-q8` | 0 | `aws.amazon.com/cloudfront/pricing/` | 정액제 플랜 표로 바뀐 페이지 — 「오리진 전송 면제」 0건 | ✔ `https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html` ("The data transfer from your origin to CloudFront is always free when using AWS origins") 또는 `https://aws.amazon.com/cloudfront/pricing/pay-as-you-go/` ("Free for origin fetches from any AWS origin") |
| `saa-t4-4-q9` | 3 | `aws.amazon.com/cloudfront/pricing/` | 위와 같음 | ✔ 위와 같음 |
| `saa-t4-5-q5` | 2 | `…/awsaccountbilling/latest/aboutv2/activating-tags.html` | `backfill`·`12 months` 0건(태그 활성화 페이지) | ✔ `https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-allocation-backfill.html` ("Management account users can request a backfill of cost allocation tags for up to twelve months.") |
| `saa-t4-5-q7` | 3 | `…/cost-management/latest/userguide/ce-what-is.html` · `…/compute-optimizer/latest/ug/view-idle-recommendations.html` | Trusted Advisor 쪽 출처 없음(Cost Explorer 페이지에 `Trusted Advisor`·`Compute Optimizer` 0건) | ✔ `https://docs.aws.amazon.com/awssupport/latest/user/cost-optimization-checks.html` ("Idle Load Balancers" · "Underutilized Amazon EBS volumes") |
| `saa-t4-5-q12` | 3 | `…/awsaccountbilling/latest/aboutv2/activating-tags.html` | **무관한 출처**(태그 활성화 페이지 — `tag polic` 0건) | ✔ `https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies.html` ("…maintain consistent tags, including the preferred case treatment of tag keys and tag values.") |
| `saa-t4-5-q14` | 0 | `…/wellarchitected/latest/cost-optimization-pillar/design-principles.html` | 「공식 정의」 원문 0건(설계 원칙 페이지) | ✔ `https://docs.aws.amazon.com/wellarchitected/latest/framework/cost-optimization.html` ("A cost-optimized workload delivers business outcomes at the lowest appropriate price point while meeting its functional requirements and your performance, reliability, security, and sustainability standards.") |

- **Task별 분포**: t1-1 3 · t1-2 6 · t1-3 5 · t1-4 5 · t2-1 3 · t2-2 8 · t2-3 6 · **t2-4 12** · t2-5 1 · t3-1 1 · t3-2 3 · t3-3 7 · t3-4 2 · t3-5 2 · t3-6 3 · t3-7 2 · t3-8 1 · t3-9 6 · t4-1 4 · t4-2 3 · t4-3 1 · t4-4 2 · t4-5 4.
- ⚠️ **지난 판정과의 관계**: `saa_p3_source_fix_test` 가 「출처가 전부 소개류인 99건 중 수치를 단정하는 27건」을 측정해 8건만 고치고 나머지를 「기제가 실려 있으면 유지」로 판정했다. 이 표는 **수치가 아니라 기제·용어가 0건인 자리**라 그 판정과 겹치지 않는다. 다만 그 테스트의 「소개 유지 대조군」(`saa-t1-5-q11` · `saa-t2-1-q3` · `saa-t2-3-q7`)은 이 표에 **없다** — 건드리지 말 것.

### Y19. AWS 블로그를 「(공식)」 출처로 단 4문항

- **공개 여부**: verified true · **현재 정답 인덱스**: `saa-t4-4-q1` = 3 · `saa-t4-4-q10` = 1 · `saa-t4-4-q11` = 2 · `saa-t4-4-q15` = 1
- **결함**: `https://aws.amazon.com/blogs/architecture/overview-of-data-transfer-costs-for-common-architectures/` 를 출처로 달고 제목에 「(공식)」을 붙였다(계약 §3-7: 블로그는 근거로 쓰지 않는다). 네 문항 모두 **다른 공식 출처가 함께 달려 있고 그쪽이 사실을 담는다** — q1: EC2 요금 페이지(`Data Transfer IN` 5건) · q10·q11: TGW 요금 페이지(`0.05` 1 · `0.02` 3) · q15: `prescriptive-guidance/…/network-cost-reduction.html`("$0.01/GB each way").
- **수정안**: 블로그 항목을 지우거나 제목의 「(공식)」을 「(AWS 아키텍처 블로그)」로 바꾼다. q11 의 「TGW 는 수백~수천 VPC 연결」은 블로그에만 있으므로(`hundreds` 1 · `thousands` 1) 그 문구가 본문에 있다면 근거를 따로 찾는다.
- **전수**: 문항 출처 488참조 중 `aws.amazon.com/blogs/` 4참조(이 4문항). 그 밖의 docs 밖 출처 14종은 요금 페이지·FAQ·whats-new 다.

### Y20. 가이드 JSON `SAA-C03.json` — 공식 한국어 가이드와 4문장이 다르다

- **무엇을 셌나**: JSON 의 지식·기술 문장 189개를 공식 한국어 도메인 4페이지(`https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03-domain{1..4}.html`, 전부 200 r=0)의 본문과 공백을 지우고 대조했다. **185개 일치 · 4개 불일치.** 도메인 이름·Task 제목은 전부 일치.
- **불일치**:
  - 1.2 지식 5번째 — JSON 「적절한 사용 사례를 갖춘 보안 서비스(예: **AWS** Cognito, **AWS** GuardDuty, **AWS** Macie)」 ↔ 공식 「보안 서비스와 적합한 사용 사례(예: **Amazon** Cognito, **Amazon** GuardDuty, **Amazon** Macie)」
  - 3.4 지식 3번째 · 4.4 지식 3번째 — JSON 「로드 밸런싱 개념(예: Application Load Balancer)」 ↔ 공식 「…(예: Application Load Balancer**(ALB)**)」
  - 3.5 지식 1번째 — JSON 「…AWS Lake Formation, **Amazon QuickSuite**)」 ↔ 공식 「…AWS Lake Formation, **Amazon Quick**)」
- **수정안**: 네 문장을 공식 전문으로 교체하고 `test/` 에 SAA 가이드 동기화 가드를 신설한다(CLF·SOA·AIF·SCS·AIP 에는 있고 **SAA 에는 없다** — `ls test | grep -i guide` 로 확인). ⚠️ 가이드 JSON 은 서식(한 줄 compact 여부)을 먼저 실측할 것.
- **전수**: 189문장 전수 대조. `overview`(합격선 720 · 채점 50 + 미채점 15 · 130분)는 이 세션에서 대조하지 않았다.

---

## 3. 🟢 (품질 — 사실은 옳다)

- **G1. length-cue 149문항**(41%) — `prescreen` 실측. Task별: t1-1 8 · t1-2 10 · t1-3 9 · t1-4 4 · t1-5 8 · t2-1 7 · t2-2 2 · t2-3 5 · t2-4 9 · t2-5 7 · t3-1 7 · t3-2 7 · t3-3 4 · t3-4 9 · t3-5 3 · t3-6 5 · t3-7 5 · t3-8 4 · t3-9 6 · t4-1 9 · t4-2 4 · t4-3 6 · t4-4 6 · t4-5 5. 비율 2.0 이상 **20문항**, 1.6 이상 67문항. 상위: `saa-t2-1-q15`[1] 3.11배(137자 대 44자) · `saa-t2-4-q15`[1] 2.68 · `saa-t1-5-q7`[2] 2.50 · `saa-t1-3-q13`[3] 2.48 · `saa-t4-1-q10`[1] 2.44. 문항 ID 전수는 `flutter_app/build/saa_review/*.prescreen.json` 의 `qualityFlags`. ⚠️ SCS 의 교훈: 정답만 줄이면 반대 방향 단서가 생긴다 — 오답을 같은 정밀도로 올리는 쪽이 주 수단이다. 여러 건이 **가드 `required` 문구 때문에 정답 보기가 길어진** 자리라(`t2-1-q15` 의 「배치 API 없이」 등) 줄일 때 가드를 먼저 볼 것.
- **G2. meta-phrasing 3문항** — `saa-t2-5-q4`[3] · `saa-t3-4-q1`[0] · `saa-t4-5-q14`[0] (지문·정답에 「공식」). `t4-5-q14` 는 「공식 정의에 가장 부합하는 설명은?」인데 인용 페이지에 그 정의가 없다(Y18) — 함께 처리.
- **G3. explanation-long 3문항** — `saa-t3-8-q10`[3] 441자 · `saa-t3-9-q11`[0] 421자 · `saa-t4-4-q6`[3] 407자(임계 400).
- **G4. 교차 Task 의미 중복 16쌍** — `prescreen` 의 Task 내 후보는 1쌍(`saa-t2-5-q2`↔`q4`, 0.444)인데 읽어 보니 **다른 사실**(순서 대 식별)이다. 교차 Task 는 내가 따로 쟀다: 64,620쌍 중 정답 보기 자카드(원형·조사벗김 중 큰 값) ≥ 0.30 등 임계에 39쌍, **정답 문자열 완전 동일 2쌍**. 39쌍을 읽어 같은 사실을 묻는다고 판정한 것이 16쌍이다 — `t3-5-q8`↔`t4-3-q1`(정답 문자열 동일 「Aurora serverless를 사용한다」) · `t1-1-q3`↔`t2-2-q5`(Lambda 실행 역할) · `t3-1-q2`↔`t4-1-q3`(S3 Intelligent-Tiering) · `t3-1-q4`↔`t4-1-q6`(Glacier Instant Retrieval) · `t2-2-q2`↔`t3-4-q6`(Provisioned Concurrency) · `t1-3-q11`↔`t3-8-q1`(피어링 비전이) · `t2-2-q11`↔`t3-4-q4`(EKS 이식성) · `t3-8-q11`↔`t4-4-q7`(게이트웨이 엔드포인트 두 서비스) · `t1-3-q9`↔`t4-4-q4`(S3 게이트웨이 엔드포인트로 NAT 우회) · `t1-3-q10`↔`t4-4-q6`(엔드포인트 두 유형 비교) · `t3-3-q15`↔`t3-4-q9`(EFA + 클러스터 배치) · `t2-4-q6`↔`t3-5-q2`(읽기 복제본) · `t2-3-q1`↔`t3-7-q15`(ALB 경로 기반) · `t3-2-q10`↔`t3-4-q10`(FSx for Lustre) · `t3-1-q5`↔`t4-1-q5`(Standard-IA 최소 보관) · `t1-1-q12`↔`t1-4-q9`(Cognito 두 풀). 정답 문자열이 같지만 중복이 아닌 1쌍: `t1-4-q4`↔`t2-1-q8`(「Amazon RDS 데이터베이스 인스턴스」 — 지문이 전혀 다르다). ⚠️ **구조적 원인**: 콘텐츠 Task 24개가 공식 Task 14개를 나눠 쓰고, 도메인 4(비용)가 도메인 1~3 의 같은 서비스를 다시 묻는다. 2026-10-28 에 8쌍을 해소했지만 이 16쌍은 그때 목록에 없었다. 지표는 하한이다(조사를 벗겨도 표현이 다르면 못 잡는다).
- **G5. 학습문서의 표현 잔존 5종**(문항은 옳거나 정밀하다) — ⓐ `saa-t3-6.md:397·398·437` 「Memcached 는 복제가 없다」 한정 없음(서버리스 캐시는 복제된 Multi-AZ — 문항 쪽은 2026-10-28 에 「노드 기반」으로 한정) ⓑ `saa-t3-4.md:478` 「Lambda 최대 15분」 한정 없음(`saa-t2-2.md:359` 는 Managed Instances 5,400초를 적는다) ⓒ `saa-t3-8.md:430·472` 「전송 암호화가 필요하면 VPN over Direct Connect 패턴을 사용해야」(같은 문서 `:212` 는 MACsec 포함 **둘**을 적는다 — `saa-t3-8-q7`[2] 정답 보기의 「적용해야 한다」도 같은 결) ⓓ `saa-t4-1.md:197·461` 「30일 이전에 Standard-IA 로 전환하면 절감이 아니다」(문항 `t4-1-q4`[3]·`q5`[0] 는 「그 클래스에 **머문 기간**」으로 고쳤다 — 「생성 후 30일」로 읽히는 표현) ⓔ `saa-t4-1.md:493` 자가 점검 「Day 30 전환과 일치하므로 추가 요금 없음」(결론은 맞고 논리가 생성 기준).
- **G6. `saa-t3-7-q13`[2] — 「GLB는 L3/L4에서」 + 약칭** — md `saa-t2-3.md:112`·`saa-t3-7.md:252` 는 2026-10-19 에 **L3** 로 고쳤고 문항 W1 만 「L3/L4」다. 공식이 둘 다 적으므로 거짓은 아니다(§6 U2). 약칭은 md 가 `GWLB`(t2-3)와 `GLB`(t3-7) 둘을 쓴다 — 공식 약칭은 GWLB.
- **G7. `saa-t3-3-q2`[2] 등 인스턴스 접미사 표현** — 해설 「네트워크 강화는 `n`, EBS 최적화는 `b`」(`t3-3-q1`[1] W2 · `q2` W1 도 「네트워크 강화 접미사 `n`」). 공식 `https://docs.aws.amazon.com/ec2/latest/instancetypes/instance-type-names.html`: "b – Block storage optimization" · "**n – Network and EBS optimized**" · "d – Instance store volumes". md `:84` 는 「n=네트워크·EBS 최적화, b=블록 스토리지 최적화」로 정밀하다. 문항을 md 표현에 맞추면 된다.
- **G8. `section` 빈 값 360/360** — SAA 문항은 전부 `"section": ""` 이다(개념 딥링크 `?at=` 가 걸리지 않는다). 결함인지 미구현인지는 이 세션이 판정할 수 없다 — 2단계가 다른 자격증(CLF)과 비교해 결정.
- **G9. 가드 자체의 구멍**(고치지 않고 적는다) — ⓐ `saa_question_propagation_test` `_rules` 의 `'**Java·Scala·SQL**'` 은 **별표가 들어 있어** 평문 문항과 일치할 수 없다(Y14 ⓑ 가 그래서 통과). md 표·굵게에서 온 리터럴 전체를 같은 눈으로 볼 것. ⓑ 같은 파일 `G-1.1-10` 의 why 주석이 「35일 유예」인데 공식·md·`saa-t1-1-q15`[1] 은 **14일**이다("Users must register MFA within 14 days of their first sign-in attempt"). ⓒ R1·R2·R3·Y9·Y15 가 모두 「금지 문장의 리터럴」을 어형·조사·구두점으로 비켜 갔다 — AIF 「PT 필수」와 같은 실패 기제다. 고칠 때 **정규식 + 문항 단위 탐지**로 바꾸는 것을 권한다.
- **G10. 정답 인덱스 분포 0:45 / 1:165 / 2:99 / 3:51** — `saa-t1-1`·`saa-t2-1` 은 15/15 가 인덱스 1, `saa-t2-4`·`saa-t3-1` 은 13/15 가 1. 루브릭이 「앱이 전 경로에서 보기를 섞으므로 정답 위치를 옮기려고 문항을 고치지 않는다」고 적으므로 **고치지 않는다**(기록만).
- **G11. 닫힌·종료 서비스의 목록 언급 3자리**(가르치는 대상이 아니라 나열) — `AWS App Runner`(유지 관리 2026-03-31): `saa-t1-4.md:94` · `saa-t1-4-q4`[2] · `saa-t1-4-q12`[2] 의 WAF 연결 가능 리소스 목록 / `Service Catalog AppRegistry`(유지 관리 2026-06-30): `saa-t4-5.md:233` / `WAF Classic`(완전 종료): `saa-t1-3.md:352` 글로벌 엔드포인트 목록. 상태 한 줄을 달거나 목록에서 뺀다.
- **G12. 그 밖의 경미한 표현** — `saa-t4-5-q7`[3] 해설 「CloudWatch 지표 **14일 이상**을 수집」(공식: "the default lookback period of 14 days" — 「이상」이 아니라 기본 14일) · `saa-t3-5-q12`[2] 출처 **제목**의 「되돌릴 수 없음」(그 페이지에 그 표현 없음 — Y18 표).

---

## 4. 커버리지·범위

### 4-1. 커버리지(축 ⑩)

- **공식 Task별 문항 수**(콘텐츠 Task → 공식 Task 매핑): 1.1 = 30(t1-1·t1-2) · 1.2 = 30(t1-3·t1-4) · 1.3 = 15(t1-5) · 2.1 = 30+(t2-1·t2-2·t2-3 일부) · 2.2 = 45(t2-3·t2-4·t2-5) · 3.1 = 30(t3-1·t3-2) · 3.2 = 30(t3-3·t3-4) · 3.3 = 30(t3-5·t3-6) · 3.4 = 30(t3-7·t3-8) · 3.5 = 15(t3-9) · 4.1~4.4 = 각 15(t4-1~t4-4) + t4-5 15(4.x 공통 K2·K3). **문항 5개 미만 공식 Task 0건 · foundational 2개 미만 Task 0건.**
- **문항이 0개인 공식 지식·기술**(지문·정답 보기·`skill` 태그를 정규식으로 전수 검색 — 「any」는 오답·해설 포함 어디든, 「core」는 지문+정답+skill):

| 공식 항목 | 키워드 | any / core | 비고 |
|---|---|---|---|
| 1.1 K5 공동 책임 모델 | `공동 책임` | 0 / 0 | |
| 1.2 K5 보안 서비스(GuardDuty) | `GuardDuty` | 3 / 0 | 오답 보기로만 |
| 1.3 S7 암호화 키 교체 | `키 교체\|로테이션\|rotation` | 7 / 2 | core 2건은 Secrets Manager 자동 교체 — **KMS 키 회전 문항 0** |
| 2.1 K8 컨테이너로 마이그레이션 | `컨테이너로 마이그레이션\|App2Container` | 0 / 0 | |
| 2.1 K6 수평·수직 스케일링 | `수직\|스케일 업` | 2 / 0 | |
| 2.2 K2 관리형 AI 서비스(Comprehend·Polly) | `Comprehend\|Polly\|Textract\|Transcribe\|Translate` | 0 / 0 | md `saa-t2-4.md:446~451` 에는 있음 |
| 2.2 K7 변경 불가능한 인프라 | `불변\|immutable` | 1 / 0 | |
| 2.2 K10 Service Quotas | `Service Quotas\|쿼터` | 0 / 0 | md `saa-t2-4.md:425` 에는 있음 |
| 2.2 K12 워크로드 가시성(X-Ray) | `X-Ray` | 0 / 0 | |
| 2.2 S1 자동화 전략 | `CloudFormation` | 2 / 1 | core 1건은 Control Tower 훅 |
| 2.2 S7 레거시 앱 신뢰성(EC2 자동 복구) | `자동 복구` | 1 / 1 | 그 1건은 HA 정의 문항 — **실질 0** |
| 3.1 K1 · 4.1 K8 하이브리드 스토리지 | `Storage Gateway` | 0 / 0 | md `saa-t3-2.md` §9 에는 있음 |
| 3.2 K2 엣지 분산 컴퓨팅 | `Lambda@Edge\|CloudFront Functions` | 0 / 0 | |
| 3.5 S4 시각화 전략 | `QuickSight\|Quick Sight` | 1 / 1 | CUR 파이프라인의 끝 단계로만 |
| 4.1 K1 요청자 지불 | `Requester Pays\|요청자 지불` | 0 / 0 | |
| 4.1 S1 배치 업로드 대 개별 업로드 | `배치 업로드` | 0 / 0 | |
| 4.2 K6 하이브리드 컴퓨팅(Outposts) | `Outposts` | 1 / 0 | |
| 4.2 K5 엣지 프로세싱 | `Local Zone\|Wavelength` | 0 / 0 | |
| 4.4 K4 NAT 인스턴스 대 NAT 게이트웨이 비용 | `NAT 인스턴스` | 1 / 0 | R4 의 오답 보기로만 |
| 4.4 S6 제한(throttling) 전략 · S7 대역폭 할당 | — | 0 / 0 | DX 속도·복수 VPN 문항 없음 |

- **읽는 법**: 2026-10 갭 배치(B1~B11)가 **학습문서**에 이 주제들을 채웠지만 **문항 뱅크는 따라오지 않았다.** 문항 수는 충분하므로(Task당 15) 추가가 아니라 **G4 의 중복 16쌍을 이 빈 주제로 교체**하는 것이 가장 싸다(§7).
- 도메인 간 중복 주제(§G4)가 많은 만큼 빈 주제도 많다 — 같은 원인(콘텐츠 Task 가 서비스 축으로 나뉘고 공식 지식·기술 목록에서 역산하지 않았다)이다.

### 4-2. 범위(축 ⑨)

- **범위 외 서비스가 정답인 문항: 새로 찾은 것 0건.** 360문항의 정답 보기와 `skill` 태그를 통독했고 정답에 등장하는 서비스는 전부 SAA 학습문서가 다루는 서비스다. 지난 보고 §4-3(`saa-t4-3-q13` Timestream 등)은 `saa_p3_source_fix_test` 가 **「고치지 않는다」 판정을 가드로 고정**했으므로 다시 적지 않는다.
- ⚠️ 한계: 공식 가이드의 「범위 내 서비스」 부록과 기계 대조는 하지 않았다(레포 JSON 에 그 목록이 없다 — 키가 `code·slug·overview·domains·sourceUrl` 뿐).

---

## 5. 교차 자격증 — 다른 자격증과 어긋나는 자리 (고치지 않고 적기만)

| 주제 | SAA | 다른 자격증 | 공식 |
|---|---|---|---|
| Geoproximity 는 Traffic Flow 전용? | md 5줄 「전용」(R5) · 문항은 「전용 아님」 | **`soa-t5-3.md:67·133·214`** 「Route 53 Traffic Flow 에서만 사용한다」 3자리(라이브) | 전용 아님(R5 인용) — **SOA 도 같은 결함** |
| Control Tower 예방 제어 구현 | SCP 하나(Y1) | `scs-t6-1.md:72·139·344` 「SCP·RCP·선언적 정책 **셋**」, `scs-t6-1-q3` 이 「예방 제어는 SCP 하나로만」을 **오답 보기**로 쓴다 | 셋 — SCS 가 옳다 |
| Macie 탐지 방식 | 「머신러닝으로」(Y3) | `clf-t2-2-q3`·`clf-t2-4-q9`·`dea-t4-3.md:112`·`dea-t4-5.md:118`·`mla-t1-3-q13` 「머신러닝과 패턴 매칭」 / **`soa-t4-2.md:90`** 「S3 객체 머신러닝 분류」 | 둘 다 — SOA 도 한 자리 남음 |
| GWLB 계층 | md 「L3」 · 문항 `t3-7-q13` 「L3/L4」 | `clf t3-3.md:182` 「L3/4」 · `soa-t2-1.md:181` 「L3/4」(약칭 GLB) | 공식이 둘 다 적음(§6 U2) |
| RDS Magnetic | md 「사용 중단」 · 문항 「이전 세대」(Y8) | **`soa-t1-5.md:153`** 「gp3/gp2·프로비저닝 IOPS·**마그네틱** 중 선택합니다」 | deprecated — SOA 가 낡음 |
| Flink 언어 | md 4종 · 문항 3종(Y14) | `mla-t1-1.md:155` 등 「Java·Scala·Python·SQL」 | 4종 |
| ARC readiness check 상태 | 표기 없음(Y17) | `scs-t2-1.md:37·213` 이 「2026-03-31 공지로 유지 관리」를 적는다 | 신규 고객 비개방 |
| EventBridge 새 권고 | 규칙·대상 모델만 가르침(문항 `t2-1-q7` W3 가 「사용자 지정 이벤트 버스 구독자 5회·300초」를 한 번 언급) | `aip-t2-3.md:69·114·211·231` 「새 애플리케이션은 `Custom Event Bus` 로 시작」 + 가드 · `dea-t3-1.md:240` 메모 | "For new applications, start with the Custom Event Bus"(§6 U8) |
| NAT 인스턴스 | 「아웃바운드 전용」(R4) | `soa-t5-1.md:116·158·160` 은 소스/대상 확인 비활성화까지 정확히 다룬다(포트 포워딩 언급은 없음) | 포트 포워딩·배스천 가능 |

---

## 6. 공식 내부 어긋남 / 「확인되지 않음」 — 수정안을 낼 수 없는 것

- **U1. Transit Gateway 를 지나는 교차 AZ 트래픽에 전송 요금이 붙는가**(R3) — `https://docs.aws.amazon.com/eks/latest/best-practices/cost-opt-networking.html`: "There is no destination cost associated with inter-AZ traffic that flows through the TGW." ↔ `https://aws.amazon.com/transit-gateway/pricing/`: "You will incur standard AWS data transfer charges, in addition to any Transit Gateway charges." 레포는 전자를 정본으로 판정해 md·가드를 고쳤다. **요금 페이지의 문장은 일반 문구이고 EKS 문서가 그 시나리오를 직접 다루므로** 레포 판정이 계약 §3-5(더 구체적인 쪽)와 맞는다. 다만 문항이 이 갈림을 정답의 근거로 삼지 않게 하는 것이 안전하다.
- **U2. GWLB 의 OSI 계층** — `https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/introduction.html`: "operates at the **third layer** of the OSI model, the network layer" ↔ `https://aws.amazon.com/elasticloadbalancing/features/` 비교표: "**Layer 3 Gateway + Layer 4 Load Balancing**". 레포 SAA md 는 L3 로 정했다. 「계층 번호」를 묻는 문항을 만들지 않는다.
- **U3. 인터페이스 엔드포인트 시간 요금의 단위** — `https://aws.amazon.com/privatelink/pricing/` 한 페이지 안에서 "billed for each hour that your VPC endpoint remains provisioned in each Availability Zone" 와 예시 "$0.01 per hour for each endpoint ENI" 가 함께 나온다(Y15). 「ENI 단위가 아니다」도 「ENI 요금이다」도 단정하지 않는다.
- **U4. Snowball Edge 의 단계** — AWS Lifecycle 「Services in **Full Shutdown**」 표에 "AWS Snowball Edge — End of Support Date **November 12, 2025**"(`https://docs.aws.amazon.com/general/latest/gr/full_shutdown_services.html`, 200 r=0) ↔ 전용 페이지 `https://docs.aws.amazon.com/snowball/latest/developer-guide/snowball-edge-availability-change.html`: "AWS Snowball Edge is no longer available to new customers. … **This change will not impact customers currently using AWS Snowball Edge**…". `saa-t3-9-q11`[0] 은 「기존 고객은 계속 사용」으로 정답을 세웠고 **전용 페이지와 일치**한다(집계표보다 전용 페이지가 정본). 다만 집계표가 「완전 종료」로 싣는 서비스를 **정답으로 삼는 문항**이라는 점은 2단계·검수자가 알고 있어야 한다 — 표의 그 항목이 특정 디바이스 세대를 뜻하는지는 이 세션에서 가를 수 없었다.
- **U5. Rekognition 가용성 변경 안내의 공식 링크가 죽어 있다** — Lifecycle 표가 가리키는 `https://docs.aws.amazon.com/rekognition/latest/dg/rekognition-streaming-video-analysis-availability-change.html` 은 `200 r=1`(가이드 인덱스). 상태 문구는 `streaming-video.html` 본문에서 확인했다(Y14). 닫힌 범위가 「얼굴 검색·레이블 탐지 스트림 프로세서 전부」인지는 그 안내 페이지를 열 수 없어 확정하지 못했다.
- **U6. 라이브에 단정으로 남은 「미확보」 항목**(`99-gaps.md` 가 이미 미확보로 적었거나 이 세션에서 근거를 못 찾은 것 — 수치를 지우라는 권고가 **아니다**. `98-existing-gap.md` 와 `saa_gaps_b10b_test` 의 「이미 본문에 있는 단가는 건드리지 않는다」 판정을 확인했다):
  - `saa-t3-2-q9`[1] 해설 · `saa-t3-2.md:348` 「Active Directory 와 통합**(필수)**」 — V-18. 인용 페이지는 "Users accessing file systems are authenticated with Microsoft Active Directory" 까지(`require`·`must` 0건). md `:565` 는 「쓰지 않은 것」으로 적어 놓고 본문 표에는 남아 있다.
  - `saa-t3-8-q5`[2] 정답 보기 「수 분 내 구축 / 수 주」 · `saa-t3-8.md:427` — V-34(인용 페이지 둘 다 `minutes`·`weeks` 0건).
  - `saa-t4-3-q2`[3] 정답 보기 「RDS 인스턴스 비용이 EC2보다 **소폭 높지만**」 · `saa-t4-3.md:100` — G-4.3-21(`higher` 0건).
  - `saa-t4-3.md:82`(「예약 인스턴스로 최대 60% 절감」) · `:122`(표 「3년 All Upfront ~60%」) · `:446`(자가 점검 「약 60% 할인」) — V-57(RDS RI 페이지에 `%` 는 "50 percent of the usage" 1건뿐). 문항 `saa-t4-3-q3`[3] 은 수치 없이 「약정이 길고 선납이 클수록」으로만 적어 옳다.
  - `saa-t4-4-q8`[0] W2 「EC2 아웃바운드 단가는 CloudFront보다 높습니다」 — G-4.4-18.
  - `saa-t4-4-q13`[3] 정답 보기 「인터넷 아웃바운드(약 $0.09/GB)」 — G-4.4-14. DX 요금 페이지의 `0.0900` 은 리전별 DX 전송 단가 표의 값(도쿄·오사카 행 등)이고 인터넷 아웃바운드 단가가 아니다.
  - `saa-t3-3-q3`[2] vCPU:메모리 비율 — G-3.2-12.
  - `saa-t4-4-q6`[3] 해설 · `saa-t4-4.md:148` 「**200개 이상**의 서비스」 — PrivateLink 요금 페이지에 그 수치 0건.
  - `saa-t4-1-q7`[3] 「GB당 약 **20%** 저렴」 · `saa-t3-3-q6`[2] 「**40%**」 · `saa-t3-3-q9`[2]·`saa-t4-2-q8`[2] 「최대 **90%**」 — 각 인용 페이지에 수치 0건(Y18 표).
  - `saa-t2-4-q1`[1] HA/FT 정의(Y12).
- **U7. (해소) DX 포트 시간 요금 $0.30** — `99-gaps` G-4.4-15 가 「미확보」로 뒀는데 지금 `https://aws.amazon.com/directconnect/pricing/pay-as-you-go/` 표에 "1 Gbps — **$0.30/hour**(Port hour rate excluding Japan) / $0.285/hour(Japan)" 가 있다. `saa-t4-4-q13` 해설의 「$0.30/시간 등」은 **1 Gbps 전용 연결·일본 제외**라는 한정과 함께면 확인된 사실이다.
- **U8. EventBridge 의 새 권고** — `https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html`(200 r=0): "EventBridge offers two event buses. The Custom Event Bus … **Custom Event Bus - Classic** routes events using rules and targets … **For new applications, start with the Custom Event Bus.**" SAA `saa-t2-1` 은 규칙·이벤트 패턴·대상 모델로 가르친다(`saa-t2-1-q9`[1]·`q10`[1]). 거짓은 아니지만(Classic 과 기본 버스는 그대로 그 모델이다) 공식 권고가 바뀐 자리다 — SAA 시험 가이드가 이 구분을 묻는지 근거가 없어 수정안을 내지 않는다. AIP 의 처리(권고 병기)를 따를지 2단계·사람이 정한다.
- **U9. 측정하지 못한 것** — md 「핵심 개념」 본문 전문 통독(위 한계) · 가이드 `overview` 수치의 공식 대조 · 공식 「범위 내 서비스」 부록 대조 · `saa-t2-2-q12`[1] 「Fargate GPU 미지원」의 현재 사실 여부(인용 페이지에 `GPU` 0건이고 대체 근거를 찾지 않았다 — **최신성 위험이 있는 단정**이라 2단계가 먼저 확인할 것).

---

## 7. 2단계에 넘기는 순서 제안

1. **🔴 4문항 + md 1편을 한 배치로**(R1~R5). 전부 정답 인덱스 불변 · 보기 또는 해설·오답 근거만 바뀐다. R3 는 `saa_question_facts_test` 의 `required: ['송신 측 1 GB 기준','양방향']` 을 지켜야 하고, R5 는 md 라 **md 가드**가 필요하다(문항 가드는 `.md` 를 보지 않는다). R4·R5 는 SOA 세션의 같은 계열(`soa-t5-3.md` Geoproximity)과 **한 판정**이다 — 문구를 맞출 것.
2. **전파 가드를 먼저 고친다(1번과 같은 PR).** `_rules` 를 리터럴에서 **정규식 + 문항 단위**로 바꾸고 「재시도가 제한」·「Lake Formation … 일관」·「\$0\.03/GB|교차 AZ \+」·「ENI 요금」·「Java·Scala·SQL」·「인터넷을 경유」를 넣는다. 별표가 든 규칙(`**Java·Scala·SQL**`)과 낡은 주석(35일)을 정리한다. ⚠️ 가드를 먼저 넣으면 현재 콘텐츠에서 **레드가 나는 것이 정상**이다 — 그 레드가 이 보고의 🔴·🟡 목록과 일치하는지로 가드 민감도를 확인한다.
3. **내용 🟡 15항목**(Y1~Y15). 의존 관계: Y4 는 R1 과, Y6 은 Y5 와, Y15 는 R3 과 같은 파일이다 — 파일별로 묶으면 `saa-t2-1` · `saa-t1-2` · `saa-t1-5` · `saa-t2-4`/`t2-5` · `saa-t3-4` · `saa-t3-5` · `saa-t3-8` · `saa-t3-9` · `saa-t4-3` · `saa-t4-4` 열 묶음. Y6(Multi-AZ 한정)은 SOA 가 쓴 탐지기(문맥 + 한정어, 문항 단위)를 그대로 옮기면 전수 가드로 닫힌다.
4. **md 잔존**(Y16·Y17 + §3 G5). 본문을 고치면 `lastVerified` 를 올린다 — SAA 의 `lastVerified` 가드는 **하한 비교**라 가드를 고칠 필요가 없다(SOA·CLF 의 고정 맵과 다르다).
5. **출처 교체**(Y18 90문항 · Y19 4문항). ✔ 34문항은 표의 URL 을 그대로 쓰면 된다(이 세션이 `200 r=0` 과 본문을 확인했다). ◐ 6문항과 — 50문항은 2단계가 정본을 찾아야 하고, **제안하기 전에 `curl -sL` 로 `200 r=0` + 본문**을 확인할 것(이 세션에서 추정 슬러그 2개가 죽어 있었다: `vpc/latest/userguide/nacl-ephemeral-ports.html` · `efs/latest/ug/storage-classes.html`). `saa-t2-4` 12문항은 한 페이지(`framework/reliability.html`)에 몰려 있어 한 번에 본다. ⚠️ `sources` 는 한 줄 압축 형식 · 문항 JSON 은 json 왕복 금지(바이트 블록 치환 + 횟수 단정) · 출처를 바꾸면 **그 URL 이 업고 있던 사실을 하나씩 다시 센다** · 문항이 새 URL 을 들이면 md 프런트매터에도 등재(G-84 계열 규율을 SAA 에 걸지 여부는 2단계 판단).
6. **가이드 JSON 4문장 + 동기화 가드 신설**(Y20). 독립 작업이다.
7. **중복 16쌍 ↔ 빈 주제 20개 교체**(§3 G4 · §4-1) — 「같은 사실을 두 번 묻는 문항」을 「문항이 0개인 공식 지식·기술」로 바꾼다. **라이브 문항 교체는 사람 승인 영역**이다(2026-10-28 선례: `verified` 값을 스크립트가 그대로 옮기고 AI 가 true 를 쓰지 않는다 · 교체 전 그 문항 ID 를 참조하는 가드를 `grep -rn` 으로 먼저 센다 · 정답은 교체 전과 같은 자리).
8. **🟢 품질**(G1 length-cue 149 등)은 마지막. 3·5·7번이 보기·해설을 바꾸므로 그 뒤에 재야 한다.
9. **사람에게 넘길 판정**: U4(Snowball Edge 를 정답으로 두는 문항의 존치) · U8(EventBridge 새 권고 반영 여부) · G8(`section` 빈 값) · §4-1 의 문항 교체 승인.
