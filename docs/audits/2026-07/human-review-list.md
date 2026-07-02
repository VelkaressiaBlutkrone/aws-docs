# 사람 확인 목록 — 2026-07 전면 감사

> 2단 반박 검증(P12, V1~V12)을 통과해 **정정이 필요하다고 확정(CONFIRMED)** 되었거나 **사람 결정이 필요(UNCERTAIN)** 한 항목만 담는다.
> **REFUTED(검증으로 오탐 확정)** 항목은 맨 아래 「정정 금지」 절로 분리했다 — 옳은 내용을 실수로 고치지 않기 위함.
> 정렬은 **시험 영향 순**(CLF 문항 → CLF 문서 → CLF 오디오 → SAA 활성 문항 → SAA 문서 → SOA 문서·가이드). 시험은 2~4주 내 CLF-C02.
> 원 자료: `03-docs-facts.md`(③ 사실의심 Y 전수) · `raw/verify/V1~V12`(2단 판정) · `raw/04-q-*`(문항) · `raw/05-audio-e`(오디오). 새 사실 판정은 추가하지 않았고 기존 결과의 재구성이다.

---

## 요약

- **사람 확인 항목: 총 105건**(개별 ID 기준, 중복 없음) — **H 14 · M 55 · L 36**.
  - ① CLF 문항 4 · ② CLF 문서 9 · ③ CLF 오디오 3 · ④ SAA 활성 문항 10 · ⑤ SAA 문서 41(개별 11 + 묶음 30) · ⑥ SOA 문서·가이드 38(개별 21 + 묶음 17). 절 표에서 ⑤·⑥은 저심각도 다수를 묶음 행으로 담았으니 묶음 상세 표를 반드시 함께 볼 것.
  - **H 14건**(시험 최우선): DOC-CLF-102·309 · Q-CLF-t4-3-01 · AUD-401 · DOC-SAA-005·006·101·210·301·411 · Q-SAA-c-01 · DOC-SOA-002·009·315.
- **오탐(REFUTED)으로 제외: 12 ID / 11계열** (Aurora 256TiB〔209+406〕·gp3 상향수치〔202〕·CE 18개월〔308/410〕·Support 재편〔310〕·On-Ramp〔311〕·AppStream 개명〔302〕·Customer Enablement〔304〕·Durable Lambda〔104〕·NLB QUIC〔105〕·8세대 인스턴스〔205〕·인스턴스 스토어 복구〔SOA-008〕). 이 중 다수는 **문서가 현행 사실을 맞게 반영**한 것이라 정정하면 오히려 구식화된다.
- 별도(요약 105건에 미포함): AUD-403/405·소스불일치(Q-SAA-c-05/06)·P6 "DX over VPN" 8곳·SOA 자구(005·104·105·205·213) 등 **사실 아님(N)·저위험 자구**는 각 절 각주로만 안내(사람 판단 선택 사항).
- **문서↔문항 원자적 수정 쌍**(문서를 고치면 문항도 같은 커밋에서 함께): DOC-CLF-102↔Q-CLF-t2-3-01 · DOC-CLF-309↔Q-CLF-t4-3-01/02 · DOC-SAA-208↔Q-SAA-b-05/09 · DOC-SAA-210↔Q-SAA-b-08 · (역방향) Q-SAA-c-02→saa-t4-2.md 54%→66% · Q-SAA-c-03→saa-t4-3.md 3년 No Upfront 행 삭제.
- **여러 위치 동시 수정 교차계열**: P3 KMS(SAA t1-5 3곳 + SOA t4-3 3곳) · P4 Interface EP(SAA t1-3 + SOA t5-2) · P5 Geoproximity(SAA t3-7 3곳 + SOA t5-3 3곳, 시점=**2024-01-10**로 확정) · P7 Firehose 개명(SOA t1-2 + t5-4) · P9 단종메모(FSx File GW·Snowmobile·Snowcone).
- **샤드간 불일치 확정**: Route 53 라우팅 정책은 **8종**이 옳음(V6/DOC-SOA-313 CONFIRMED) → SAA 감사가 무결로 본 **saa-t3-7 "7종" 서술도 8종 정정 대상**(⑤에 포함). 그 외 Aurora는 반대로 **256TiB가 현행**이라, "128TiB"로 적힌 문항 자기모순(Q-SAA-b-06/07)을 256TiB로 통일해야 함(④).

### 🔴 시험 전 최우선 — CLF TOP (H 우선, 시험 임박)

| 순위 | ID | 한 줄 | 왜 최우선 |
|---|---|---|---|
| 1 | DOC-CLF-309 (+Q-CLF-t4-3-01·02) | Enterprise Support "프로덕션 15분"의 케이스 등급 오류(→비즈니스 크리티컬) | H · 시험 단골 수치 · 문서+문항 3곳 전파 |
| 2 | DOC-CLF-102 (+Q-CLF-t2-3-01) | "Support 플랜 변경=루트 전용" 낡은 단정(현행 IAM 주체도 가능) | H · 루트 전용 목록은 CLF 핵심 · 문서 3곳+문항 해설 |
| 3 | DOC-CLF-301 | "SNS는 저장·재시도 없이 전달"(재시도 50회·DLQ 실재) | M · 통합·메시징 개념 오류 |
| 4 | DOC-CLF-305 | Savings Plans "72%+완전유연" 결합(72%=EC2 Instance SP 고정) | M · 구매 옵션 단골 함정 |
| 5 | DOC-CLF-203 | 11 9s "1,000만 개 중 1개"(기간 '1만 년' 누락→내구성 왜곡) | M · 내구성 개념 왜곡 |

---

## ① CLF 문항 (시험 영향 최고)

문항 감사 발견 중 **CONFIRMED 문서 오류의 문항 전파**만. 정답 유일성은 모두 유지되며 해설·스템 자구 정정이다.

| 순위 | ID | 위치 | 의심 내용 | 2단 판정 | 검증 근거(공식 사실) | 정정 방향 | 크기 |
|---|---|---|---|---|---|---|---|
| 1 | Q-CLF-t4-3-01 | clf/t4-3.questions.json:clf-t4-3-q3 (스템·explanation·sources[0].title 3곳) | Enterprise를 "프로덕션 중요 케이스 15분 응답"으로 서술 | **CONFIRMED**(V1 DOC-CLF-309) | 15분 목표는 **비즈니스/미션 크리티컬 시스템 다운**에 걸리고, 프로덕션 시스템 다운은 Enterprise도 **<1시간**. 15분 수치 자체는 맞으나 케이스 등급이 틀림 | 3곳 "프로덕션 중요 케이스"→"비즈니스 크리티컬(시스템 다운) 케이스". **DOC-CLF-309 문서 정정과 동시**(원자적) | S |
| 2 | Q-CLF-t4-3-02 | clf/t4-3.questions.json:clf-t4-3-q13 (스템) | 동일 결합 오기 반복("전담 TAM+프로덕션 중요 케이스 15분") | **CONFIRMED**(V1 DOC-CLF-309) | 상동 | 스템 "비즈니스 크리티컬 케이스 15분 응답"으로 교체(또는 응답목표 언급 삭제). DOC-CLF-309와 동시 | S |
| 3 | Q-CLF-t2-3-01 | clf/t2-3.questions.json:clf-t2-3-q1 (explanation) | 루트 전용 열거에 "AWS Support 플랜 변경/취소" 포함 | **CONFIRMED**(V1 DOC-CLF-102) | 현행 IAM `id_root-user.html` 루트 전용 목록에 Support 플랜 변경 **없음**; 2022-09 이후 IAM 주체도 가능. **정답 근거는 아님**(정답 '계정 해지'는 유효) | explanation에서 해당 항목 삭제(또는 "과거 루트 전용→현재 IAM 권한으로도 가능" 부연). **DOC-CLF-102 문서 정정과 동시**(원자적) | S |
| 4 | Q-CLF-t2-3-02 | clf/t2-3.questions.json:clf-t2-3-q13 (wrongExplanations["2"]) | "일회용 단기 자격증명=IAM 역할(STS) 특성" — STS는 세션 기간 재사용 가능(일회용 아님) | 문항 직접(2단 미대상, 확신 중) | STS 임시 자격증명은 유효기간(기본 ~1h) 내 다중 요청 재사용. 오답 반박 자체는 성립 | "짧은 유효 기간 후 자동 만료되는 세션 자격증명" 류로 자구 교체 | S |

> **주의(정정 금지 방향):** 같은 t4-3 문항의 q2·q7·q11이 서술한 "2026 Support 재편(Business Support+·2027-01-01 단종)"은 **V1에서 REFUTED = 재편 실재**로 판정됨 → 이 문항들의 재편 문구는 **유지**한다(아래 「정정 금지」 참조). Q-CLF-t4-3-03·04는 정정 대상이 아님.

---

## ② CLF 문서

| 순위 | ID | 위치 | 의심 내용 | 2단 판정 | 검증 근거(공식 사실) | 정정 방향 | 크기 |
|---|---|---|---|---|---|---|---|
| 1 | DOC-CLF-309 | clf/t4-3#support-plans (표·시험 포인트) | Enterprise "프로덕션 중요 케이스 15분 응답" | **CONFIRMED**(V1) | 15분=비즈니스 크리티컬 다운, 프로덕션 다운은 Enterprise도 <1h. 문서 자신의 #health-dashboard와도 긴장 | "프로덕션 중요"→"비즈니스 크리티컬(미션 크리티컬) 시스템 다운"으로 케이스 라벨 정정(수치 15분 유지). **Q-CLF-t4-3-01·02와 동시** | S |
| 2 | DOC-CLF-102 | clf/t2-3#root-user (본문·시험 포인트·Q1, 3개소) | "AWS Support 플랜 변경·취소=루트 전용" 단정 | **CONFIRMED**(V1) | 현행 IAM 루트 전용 목록에 없음; 2022-09 Support Plans IAM 제어 도입으로 IAM 주체도 가능. (레거시 기출 관례 충돌은 사람 판단) | 3개소에서 "루트 전용" 단정 제거/완화. **Q-CLF-t2-3-01과 동시** | M |
| 3 | DOC-CLF-301 | clf/t3-8#messaging 원리 | "SNS는 저장·재시도 메커니즘 없이 전달" | **CONFIRMED**(V5) | SNS 프로토콜별 재시도 정책(총 50회, 4단계)+구독별 DLQ(SQS) 공식 지원 | "재시도 정책·DLQ 존재"로 서술 정정 | S |
| 4 | DOC-CLF-305 | clf/t4-1#purchase-options (표·시험 포인트·Q1) | SP "최대 72%+패밀리·리전 무관"을 한 플랜 속성처럼 결합 | **CONFIRMED**(간접, V4/saa-e 교차) | 72%=EC2 Instance SP(고정), 완전 유연=Compute SP(최대 66%). 두 속성은 다른 플랜 | 72%(EC2 Instance SP)와 유연성(Compute SP)을 분리 서술 | M |
| 5 | DOC-CLF-203 | clf/t3-6 용어표 내구성 행 | 11 9s를 "1,000만 개 중 1개 미만 손실"로(기간 누락) | **CONFIRMED**(V12) | 공식 예시는 "1,000만 개 저장 시 **평균 1만 년에 1개** 손실" — 기간 조건 필수 | "평균 1만 년에 1개" 기간 명기 | S |
| 6 | DOC-CLF-201 | clf/t3-4#dynamodb | "(0까지 — 트래픽 없으면 비용 없음)" | **CONFIRMED**(V12) | 요청 비용만 0; 스토리지는 GB-월 연속 과금(온디맨드에서도) | "스토리지는 계속 과금" 단서 추가 | S |
| 7 | DOC-CLF-202 | clf/t3-6#ebs (+시험 포인트·Q3) | "중지·종료해도 데이터 유지" | **CONFIRMED**(V12) | 종료 시 루트 볼륨 기본 삭제(DeleteOnTermination=true); 중지엔만 참 | "종료 시 루트 볼륨 기본 삭제" 구분 서술 | S |
| 8 | DOC-CLF-204 | clf/t3-3#ec2 | "가상 서버를 늘리고(scale up) 줄일(scale down)" | **CONFIRMED**(V12) | 대수 증감=out/in(수평), up/down=수직(사양). 용어 오매핑 | "scale out/in"으로 정정 | S |
| 9 | DOC-CLF-306 | clf/t4-1 용어표 Glacier 행 | "복원에 수 분~수 시간" 일반화 | **CONFIRMED**(V12) | Instant Retrieval=밀리초, Deep Archive=12~48h로 클래스별 상이 | 클래스별 검색 특성 병기(밀리초/분~시간/12~48h) | S |

> **CLF 문서 오탐(정정 금지):** DOC-CLF-308(CE 18개월)·310(Business Support+ 재편)·311(On-Ramp)·302(AppStream 개명)·304("고객 지원"→발견자 정답이 틀림) — 아래 「정정 금지」 절 참조.

---

## ③ CLF 오디오 대본

> 오디오 항목 공통 절차: **원문 정정 → enrichedScriptText/audioSummary 재생성 → 재합성 → reviewStatus가 needs_human_review로 리셋 → 사람이 청취 재승인**. (음성이 원문 오류를 낭독하는 구조라, 대부분 원문 정정이 선행되어야 완결.)

| 순위 | ID | 위치 | 의심 내용 | 2단 판정 | 검증 근거(공식 사실) | 정정 방향 | 크기 |
|---|---|---|---|---|---|---|---|
| 1 | AUD-401 | audio/clf/clf-t4-3/script.json seg013 enrichedScriptText | 원문 "15분 응답"을 **"15분 응답이 보장된다"**로 단정 강화(대본 고유 결함) | **CONFIRMED**(H, 05-audio-e; 근본은 V1 DOC-CLF-309) | 공식은 응답 '목표(objective)'이지 보장 아님; 15분은 비즈니스 크리티컬 다운 케이스. 같은 문서 seg026은 정확→문서 내 모순 | seg013 "보장된다"→"비즈니스 크리티컬 케이스에 15분 응답 목표를 제공"으로 완화. **대본 단독 수정 가능하나 재합성·재승인 필수**. 근본 수치 배정은 DOC-CLF-309와 함께 교정 | S(대본)+M(원문) |
| 2 | AUD-402 | audio/clf/clf-t4-3/script.json seg012 audioSummary | 표 요약이 "엔터프라이즈…프로덕션 중요 케이스 15분" 잘못된 티어 배정 낭독 | **CONFIRMED**(원문 유래, DOC-CLF-309) | 상동(프로덕션 다운=1h) | **DOC-CLF-309 표 수정 선행** → audioSummary/enriched 재생성·재합성·재승인 | S |
| 3 | AUD-404 | audio/clf/clf-t4-1/script.json seg025 enriched(+seg012 audioSummary) | SP "72%까지 할인+완전 유연(EC2·Fargate·Lambda)" 결합 낭독 | **CONFIRMED**(원문 유래, DOC-CLF-305) | 72%=EC2 Instance SP(고정), 유연=Compute SP(66%) | **DOC-CLF-305 정정 선행** → 재합성·재승인. 대본 자체는 추가 왜곡 없음 | S |

> AUD-403(CE 18개월 음성)·AUD-405(Glacier 일반화 음성)는 각각 **DOC-CLF-308 REFUTED / DOC-CLF-306 처리에 연동**. AUD-403은 원문(18개월)이 현행 정확이라 **정정 금지**(아래). AUD-405는 DOC-CLF-306 정정 시 함께 재합성. AUD-406~409(발음·+정규화)는 사실 아님(N)·저위험 자구라 본 목록 제외(원 샤드에서 처리). AUD-410(재편 음성)은 재편이 실재(V1)라 **유지**.

---

## ④ SAA 활성 문항 (saa-t2-1·t3-2·t3-4·t3-5·t4-2·t4-3)

> 활성 문항만. 정답 자체는 모두 유지(경합 1건 Q-SAA-c-01 제외 판단은 사람). **역방향**(문항이 옳고 문서가 틀림) 2건은 문서를 고친다.

| 순위 | ID | 위치 | 의심 내용 | 2단 판정 | 검증 근거(공식 사실) | 정정 방향 | 크기 |
|---|---|---|---|---|---|---|---|
| 1 | Q-SAA-c-01 | saa-t4-3.questions.json:saa-t4-3-q9 | DynamoDB 온디맨드 vs 프로비저닝 **정답 경합 + 해설-지문 불일치**(지문 '예측 가능' vs 해설 '불규칙') | **UNCERTAIN**(H, 사람 결정) | 주 45h 상시 고볼륨에선 프로비저닝+AS가 총비용 유리 가능; 대응 문서 마무리 퀴즈는 유보 명시. 2단 사실검증 대상 아닌 설계 판단 | 지문을 "급증 시점·규모 예측 불가"로 고치고 "초당 수십만" 완화 + 해설 '불규칙' 전제를 지문과 일치. **키 유지 여부 포함 사람 결정** | M |
| 2 | Q-SAA-c-02 | saa-t4-2.questions.json:saa-t4-2-q2 ↔ saa-t4-2.md:77·286 | (역방향) 문항 Convertible RI **66%가 정답으로 옳고, 문서가 54%(구값)** | **CONFIRMED**(V4) | 공식 "Convertible RIs: up to **66%**". 문서 2곳이 54%로 가르쳐 학습자가 정답을 오답으로 판단 | **saa-t4-2.md 77·286행 54%→66%**(문항 무변경). 문서 감사 '발견 0' 판정 보정 | S |
| 3 | Q-SAA-c-03 | saa-t4-3.questions.json:saa-t4-3-q3 ↔ saa-t4-3.md:118 | (역방향) 문항 "No Upfront=1년 전용"이 옳고, **문서에 존재하지 않는 "3년 No Upfront ~45%" 행** | **CONFIRMED**(V4) | 공식 "No Upfront…only available for one year term". 문서 표 행이 허상 | **saa-t4-3.md:118 "3년 No Upfront" 행 삭제**(또는 "3년 미제공" 명시). 문항 무변경 | S |
| 4 | Q-SAA-b-05 | saa-t3-5.questions.json:saa-t3-5-q2·q14 (explanation) | "RDS는 최대 5개" | **CONFIRMED**(V4) | MySQL·MariaDB·PostgreSQL **15개**(Oracle·SQL Server만 5개) | 해설 "엔진별 15/5"로 정정. **DOC-SAA-208 문서 정정과 동시**(원자적) | S |
| 5 | Q-SAA-b-08 | saa-t3-5.questions.json:saa-t3-5-q11 (옵션1·explanation·wrongExpl."1" 3곳) | gp3에 버스트 크레딧 귀속 | **CONFIRMED**(V3 DOC-SAA-210) | 버스트 크레딧=**gp2 전용**; gp3는 3,000 IOPS·125MiB/s 크레딧 없이 상시+독립 프로비저닝 | 3곳을 "gp2=크레딧 버스트, gp3=고정 기준+독립 프로비저닝"으로 구분. **DOC-SAA-210과 동시** | S |
| 6 | Q-SAA-b-09 | saa-t3-5.questions.json:saa-t3-5-q12 (옵션1·wrongExpl."1") | "일반 RDS MySQL 최대 5개, 15개는 Aurora" 단정 → 디스트랙터 근거 붕괴 | **CONFIRMED**(V4, RDS 15개) | RDS MySQL이 15개를 지원하면 옵션1 진술 자체가 참이 됨(정답 Aurora는 HA로 지위 유지) | 변별 축을 복제본 수→HA 구조로 이동해 디스트랙터·해설 재설계 | M |
| 7 | Q-SAA-b-06 | saa-t3-5.questions.json:saa-t3-5-q5 explanation(117행) | "(최대 128TiB, 공식 256TiB)" **자기모순** 해설 | **정정 필요(방향=256TiB)** ※V3에서 Aurora **256TiB가 현행 정확**으로 REFUTED | 문서·문항이 "128TiB"로 적은 쪽이 오히려 구식. 자기모순을 **256TiB 단일 표기**로 통일 | "(최대 256TiB)" 단일 표기로 정정(원 샤드의 '128로 통일' 권고와 **반대 방향** — V3 반영). 정답(6벌 복제) 불변 | S |
| 8 | Q-SAA-b-07 | saa-t3-5.questions.json:saa-t3-5-q5 wrongExpl."3"(121행) | 동일 자기모순("128TiB(공식 256TiB)") | **정정 필요(방향=256TiB)** ※상동 | 오답 판정(64TiB≠한계)은 어느 기준이든 성립 | "최대 256TiB" 단일 표기로 정정 | S |
| 9 | Q-SAA-b-03 | saa-t3-4.questions.json:saa-t3-4-q7 (wrongExpl."0") | "Job Definition·Task·Service는 ECS 리소스" — Job Definition은 실제 **AWS Batch** 구성요소 | 문항 직접(사실의심 Y, 확신 높) | ECS 리소스=Task Definition·Task·Service·Cluster; Batch=Jobs·**Job Definitions**·Job Queues·Compute Environments | "Task Definition·Task·Service가 ECS", Job Definition=Batch로 해설 재작성 | S |
| 10 | Q-SAA-b-04 | saa-t3-4.questions.json:saa-t3-4-q15 (wrongExpl."3") | "EKS Fargate를 Compute Environment로 구성 가능" 전제 | **UNCERTAIN**(확신 중, 원문 재확인 권장) | Batch on EKS는 EC2/Spot 기반, Fargate 미지원으로 기재됨(정정 전 원문 재확인) | 공식 확인 후 "가능성" 단정 제거하고 오답 사유를 '구성 불가'로 재작성 | S |

> **소스(sources) 주제 불일치**(Q-SAA-c-05: saa-t4-2 q11·q13·q14 / Q-SAA-c-06: saa-t4-3 q6·q7·q11·q12·q14): 사실 오류 아님(N·2단 미대상)이나 '근거 있는 검증 문항' 신뢰를 약화하는 활성 문항 결함. 각 주제의 공식 문서로 sources 교체 권장(L, 문서 무관·문항만). 본 표에는 계상하지 않음(요약 105건에서 제외).
> **원자 해소 부수효과:** DOC-SAA-406(Aurora) 정정 시 saa-t4-3.md:136과 saa-t4-3-q6("128TB")가 현재 상호 모순 — V3 반영 시 **256TiB로 통일**해야 함(원 문항 샤드가 128 기준으로 본 것과 반대).

---

## ⑤ SAA 문서

| 순위 | ID | 위치 | 의심 내용 | 2단 판정 | 검증 근거(공식 사실) | 정정 방향 | 크기 |
|---|---|---|---|---|---|---|---|
| 1 | DOC-SAA-005 | saa/saa-t1-3 §2(NAT 표·Q1) | NAT GW "자동 고가용성" | **CONFIRMED**(V10) | 단일 AZ 내 이중화뿐("redundancy in that zone"); AZ 장애 대비는 AZ별 배치+라우팅 | "AZ별 배치 필요" 명시, '자동 HA' 표현 정정 | S |
| 2 | DOC-SAA-006 〔P4〕 | saa/saa-t1-3 §4(유형 표) | "Interface Endpoint 대상: S3·DDB **외**" | **CONFIRMED**(V10) | S3(2021)·DynamoDB Interface EP 실재; 문서 Q3와 내부 모순 | "S3·DDB도 Interface EP 지원"으로 정정. **DOC-SOA-311과 여러 위치 동시 수정** | S |
| 3 | DOC-SAA-101 | saa/saa-t2-1 Q3 해설 | "SNS는 조건 필터링 없이 전체 구독자에 Push" | **CONFIRMED**(V5) | 구독 필터 정책(속성 2017~·페이로드 2022-11) 실재; 불일치 구독자엔 미전달 | "구독 필터 정책 존재"로 정정(§7과 일치) | S |
| 4 | DOC-SAA-210 | saa/saa-t3-5 §6 원리 | "gp2/gp3는 버스트 크레딧 방식" | **CONFIRMED**(V3) | gp3는 크레딧 없음; 버스트 버킷은 gp2 전용 | "gp3는 고정 기준+독립 프로비저닝"으로 정정. **Q-SAA-b-08과 동시** | S |
| 5 | DOC-SAA-301 | saa/saa-t3-7 §7+시험 포인트 | "CloudFront 앞에 GA 붙여 고정 IP+CDN" 조합 | **CONFIRMED**(V6) | GA 표준 엔드포인트=NLB·ALB·EC2·EIP뿐(CloudFront 불가). 고정 IP는 Anycast Static IP(2024-11) 별개 | 불가능한 아키텍처 서술 삭제; 고정 IP 요구는 별도 기능으로 | M |
| 6 | DOC-SAA-411 | saa/saa-t4-5 §3(코드블록·함정 7) | Budget Actions 3종을 "IAM·SNS·SSM Automation"으로 오기 | **CONFIRMED**(간접, Budgets 공식) | 공식 3종=①IAM 정책 ②SCP ③EC2/RDS 중지(SNS는 알림 채널, SSM은 액션 아님) | 3종을 IAM/SCP/EC2·RDS 중지로 정정 | S |
| 7 | DOC-SAA-208 | saa/saa-t3-5 §3·§4·§8·Q1 | RDS Read Replica "최대 5개" 반복 | **CONFIRMED**(V4) | MySQL·MariaDB·PostgreSQL 15개; Oracle·SQL Server 5개 | "엔진별 15/5" 병기. **Q-SAA-b-05·09와 동시** | M |
| 8 | DOC-SAA-302 〔P5〕 | saa/saa-t3-7 §3(3회) | "Geoproximity=Traffic Flow 전용" 단정 | **CONFIRMED**(V6) | **2024-01-10** 일반 DNS로 확장(콘솔·API·SDK·CLI). SAA "2024-02"는 근사 정확 | "일반 레코드 직접 지원"으로 3곳 정정. **DOC-SOA-312와 동시**(시점 2024-01-10 통일) | S |
| 9 | DOC-SAA-007 | saa/saa-t1-4 시험 포인트 | WAF×CloudFront "us-east-1 제한 없음" | **CONFIRMED**(V10) | CLOUDFRONT 스코프 웹 ACL은 **us-east-1에서 생성** 필수(사실과 반대) | "us-east-1에서 생성" 제약 명시 | S |
| 10 | DOC-SAA-010 〔P3〕 | saa/saa-t1-5 §2(+함정 3·Q2, 3개소) | KMS 접근을 "IAM·키 정책 교집합/둘 다 Allow"로 단정 | **CONFIRMED**(V7) | 키 정책이 주체를 **직접** 허용하면 IAM 없이 성립; IAM 필요한 건 `:root` 위임 시뿐 | "키 정책 단독 허용 가능"으로 3개소 정정. **DOC-SOA-305와 여러 위치 동시 수정** | M |
| 11 | saa-t3-7 "7종"(SAA 감사 오탐 정정) | saa/saa-t3-7 라우팅 정책 개수 서술 | "라우팅 정책 7종" 서술 | **CONFIRMED**(V6/DOC-SOA-313) | 현행 **8종**(IP-based 2022-06 포함). **SAA 감사가 무결로 본 것은 오탐** | saa-t3-7 "7종"→"8종" 정정(DOC-SOA-313과 동일 근거) | S |
| 12 | (묶음) SAA 문서 M/L 다수 | saa 각 위치(아래 목록) | 개별 CONFIRMED 사실 오류(정답 비뒤집힘, 자구·수치) | **CONFIRMED**(V-각) | 아래 개별 근거 | 개별 정정(대개 S) | S |

**⑤-12 묶음 상세**(모두 CONFIRMED, 크기 S, 활성 문항 밖·문서 정정):

| ID | 위치 | 정정 방향 | 근거 |
|---|---|---|---|
| DOC-SAA-001 | saa-t1-1 §7 | SCP 관리계정 예외를 "루트만"→"모든 IAM 사용자·역할·루트" | V10 |
| DOC-SAA-011 | saa-t1-5 §2 인용 | "암호화된 상태로 안 벗어남"→"평문(unencrypted)으로 안 벗어남"(방향 반전 수정) | V7 |
| DOC-SAA-012 | saa-t1-5 §2 표 | 관리형 키 행 "(AWS 소유)" 표기 제거(별도 유형과 혼동) | V7 |
| DOC-SAA-013 | saa-t1-5 §4 | "FIPS L3→CloudHSM" 결정 규칙 완화(KMS도 140-3 L3) | V7 |
| DOC-SAA-106 | saa-t2-3 §2 표 | "ALB 대상그룹에 다른 ALB 등록"은 NLB 기능 — 방향 정정 | V5 |
| DOC-SAA-107 | saa-t2-3 §5 표 | 플로우 해시≠세션 고정(source_ip 스티키니스 opt-in 별개) | V5 |
| DOC-SAA-102 | saa-t2-1 §4·함정 3 | 유실 지점은 Lambda 비동기 큐; SNS 재시도는 최대 23일 | V5 |
| DOC-SAA-108 | saa-t2-3 §1 표 | CLB "EC2-Classic 환경만"→2023 폐지 반영 | V11 |
| DOC-SAA-109 | saa-t2-5 §4 표 | CRR "버전 관리 지원"→양측 활성화 필수 전제 | (S3 공식) |
| DOC-SAA-201 | saa-t3-1 §5 | S3 접근 순차 관문→union 평가+명시 Deny 우선 | V12 |
| DOC-SAA-003 | saa-t1-2 §3 | 리전 차단 SCP에 글로벌 서비스 NotAction 예외 추가 | V10 |
| DOC-SAA-004 | saa-t1-2 §2 | Audit 계정 "읽기 전용"→read/write(Control Tower) | (CT 공식) |
| DOC-SAA-008 | saa-t1-4 §1 | Count는 비종결 액션(계속 평가) | V10 |
| DOC-SAA-009 | saa-t1-4 §1 표 | Rate-based 윈도우 1·2·5·10분 4종 | V10 |
| DOC-SAA-401 | saa-t4-1 §5 표 | 교차 AZ 프라이빗 IP도 퍼블릭과 동일 $0.01/GB | V2 |
| DOC-SAA-402 | saa-t4-1 §2(+함정 7) | 128KB 미만은 모니터링 비대상·비과금(실 리스크=절감 0) | V2 |
| DOC-SAA-403 | saa-t4-1 §7 | Storage Class Analysis=S3 Analytics(Storage Lens와 별개) | V2 |
| DOC-SAA-408 | saa-t4-4 §2 표+시나리오 | 같은 리전 EC2↔S3는 경로 무관 무료(NAT 처리요금만) | V2 |
| DOC-SAA-409 | saa-t4-4 §5 표+시나리오 | TGW 교차 AZ 무료화(2022-04)→$0.03 구식 정정 | V2 |
| DOC-SAA-404 | saa-t4-1 시험 포인트·§4 | 미연결 EBS 탐지는 TA(CE는 분석·시각화) | V2 |
| DOC-SAA-407 | saa-t4-3 §2(+Q5) | RDS RI "속성 하나라도 다르면 미적용" 완화(사이즈 유연성 예외) | V4 |
| DOC-SAA-307 | saa-t3-6 Q5 | "처리량 파티션 균등 배분"→adaptive capacity 재배분(구모델 정정) | V4 |
| DOC-SAA-305 | saa-t3-9 함정 6+§2 | "샤드 자동 확장 불가"→온디맨드 모드(2021-11) 예외 | (KDS 공식) |
| DOC-SAA-308 | saa-t3-8 §6 표 | DX "SLA 보장"→SLA는 가용성만(대역폭·지연 아님) | (DX SLA) |
| DOC-SAA-203 | saa-t3-2 §6 표 | EFS 클래스에 Archive(2023-11) 추가 | V3 |
| DOC-SAA-204 | saa-t3-2 §7 | FSx OpenZFS 클라이언트에 Windows 추가(3종) | V3 |
| DOC-SAA-014 | saa-t1-5 §7 | Vault Lock "기본 3일"→최소 3일 지정 파라미터 | (Backup 공식) |
| DOC-SAA-015 | saa-t1-5 §7 | Backup 지원 목록 EKS는 공식 목록 대조 후 결정 | UNCERTAIN(낮) |
| DOC-SAA-306 〔P9〕 | saa-t3-9 §10 | Snowmobile·Snowcone 2024 단종 메모 추가 | V11 |
| DOC-SAA-303 | saa-t3-8 §3 | "터널당 5Gbps" 실재 확인 후 정정(표준 1.25Gbps+ECMP) | UNCERTAIN(낮) |

> **SAA 계열 오탐(정정 금지):** DOC-SAA-209/406(Aurora 256TiB 현행 정확)·DOC-SAA-202(gp3 80,000 IOPS·2,000MiB/s·64TiB 현행)·DOC-SAA-410(CE 18개월)·DOC-SAA-104(Durable Lambda 실재)·DOC-SAA-105(NLB QUIC)·DOC-SAA-205(8세대 인스턴스 실재) — 아래 「정정 금지」.
> DOC-SAA-304·310〔P6 "DX over VPN" 표기 역전〕은 SOA와 공통 자구 통일(⑥ 참조, N이지만 8곳 일괄).

---

## ⑥ SOA 문서·가이드 (문항 0 — 시험 영향 최저·미래 대비)

> SOA-C03은 활성 문항이 없어 시험 임박 영향이 가장 낮다(미래 대비). 전부 CONFIRMED(V6·V8·V9·V10·V11 + 가이드 현행성). 정답 뒤집힘 없음.

| 순위 | ID | 위치 | 의심 내용 | 2단 판정 | 정정 방향 | 크기 |
|---|---|---|---|---|---|---|
| 1 | DOC-SOA-002 | soa-t1-1 §4(표·시험 포인트) | EventBridge를 경보 작업 대상으로 오분류 + Lambda 직접 작업 누락 | **CONFIRMED**(V8) | 경보 직접 작업=SNS·EC2·ASG·OpsItem/인시던트; EventBridge는 자동 발행 통합 | M |
| 2 | DOC-SOA-009 | soa-t1-5 §2 "빈출 수치" | gp2 16,000 IOPS 도달 용량 "≈3,334GB" | **CONFIRMED**(V3) | **≈5,334GiB**(3 IOPS/GiB); 3,334는 구 10,000 IOPS 시절 | S |
| 3 | DOC-SOA-315 | soa-t5-4 전반(§2·§3·함정 2·Q1 등) | "SG 거부는 Flow Log에 REJECT로 안 남는다" 반복 교육 | **CONFIRMED**(간접, Flow Logs 공식) | REJECT=SG **또는** NACL 불허(SG 인바운드 불허 시 REJECT 기록 예시 존재). §3 전면 재작성 | L |
| 4 | DOC-SOA-311 〔P4〕 | soa-t5-2 §5·함정 4 | "게이트웨이=S3·DDB 전용, 나머지 인터페이스" | **CONFIRMED**(V10) | S3·DDB Interface EP 실재+게이트웨이 VPC 내부 전용 제약 누락. **DOC-SAA-006과 동시** | S |
| 5 | DOC-SOA-305 〔P3〕 | soa-t4-3 §1(3개소) | KMS "키 정책+IAM 둘 다 Allow(교집합)" | **CONFIRMED**(V7) | 키 정책 직접 허용이면 IAM 불요. **DOC-SAA-010과 여러 위치 동시 수정** | M |
| 6 | DOC-SOA-312 〔P5〕 | soa-t5-3(용어표·§4, 3곳) | "Geoproximity=Traffic Flow에서만" | **CONFIRMED**(V6) | 2024-01-10 일반 DNS 확장. **SOA "2023-11"은 오기** → 2024-01-10로. DOC-SAA-302와 동시 | S |
| 7 | DOC-SOA-313 | soa-t5-3(체크리스트·§4·시험 포인트) | "라우팅 정책 7종" | **CONFIRMED**(V6) | 현행 **8종**(IP-based 포함). **saa-t3-7도 동시 정정**(⑤-11) | S |
| 8 | DOC-SOA-314 | soa-t5-3 §6·함정 5 | "잦은 전체 무효화는 비용 큼" | **CONFIRMED**(V6) | `/*`는 1경로 과금(월 1,000경로 무료); 실 문제는 캐시 적중률 | S |
| 9 | DOC-SOA-211 | soa-t4-1 §1 표 | 인라인 정책 대상 "사용자·역할"(그룹 누락) | **CONFIRMED**(V9) | PutGroupPolicy 존재 — 그룹도 가능 | S |
| 10 | DOC-SOA-212 | soa-t4-1 §7 | 루트 전용에 "특정 S3/SCP 우회"(문서 내 정면 모순) | **CONFIRMED**(V9) | 멤버 계정 루트도 SCP 적용. 자기모순 정정 | S |
| 11 | DOC-SOA-206 | soa-t3-2 §2(+함정 3·Q1) | "암호화 AMI 공유=KMS 키 공유" | **CONFIRMED**(V9) | 기본 aws/ebs 키 암호화본은 공유 불가(CMK 재암호화 필요) | S |
| 12 | DOC-SOA-203 | soa-t3-1 §7(함정 2·Q4) | RDS DeletionPolicy "기본=삭제" 단정 | **CONFIRMED**(V9) | DBCluster 등 기본 Snapshot 예외 | S |
| 13 | DOC-SOA-201 | soa-t3-1 §3(+Q5) | 생성 실패 기본이 "스택 제거"로 읽힘 | **CONFIRMED**(V9) | 기본 ROLLBACK→ROLLBACK_COMPLETE 잔존(수동 삭제) | S |
| 14 | DOC-SOA-204 | soa-t3-1 §5(+함정 3) | "StackSets=다중 계정×다중 리전 전용" | **CONFIRMED**(V9) | 단일 계정×다중 리전도 표준 | S |
| 15 | DOC-SOA-301 | soa-t4-2 §1 | Config "지속 평가(변경 시 아님)" 프레임 | **CONFIRMED**(V9) | 트리거 3종(변경·주기·하이브리드) | S |
| 16 | DOC-SOA-302 | soa-t4-2 §3 | GuardDuty "Low/Medium/High" 3단 | **CONFIRMED**(V9) | Critical 포함 4단(2024-12~) | S |
| 17 | DOC-SOA-304 | soa-t4-2(체크리스트·§5·시험 포인트) | Trusted Advisor "5개 범주" | **CONFIRMED**(V9) | 6범주(Operational Excellence 2022-11 추가) | S |
| 18 | DOC-SOA-306 | soa-t4-3 §7 | 갱신 불가 사유를 "개인 키가 ACM 외부"로 | **CONFIRMED**(V7) | import는 개인 키 업로드 필수; 실사유는 외부 CA 재발급 불가 | S |
| 19 | DOC-SOA-307 | soa-t4-3 §7(+시험 포인트) | "자동 갱신(DNS/이메일 유효 시)" 병렬 | **CONFIRMED**(V7) | 무개입 자동은 DNS만; 이메일은 소유자 대응 필요 | S |
| 20 | DOC-SOA-308 | soa-t5-1 §7 | 프라이빗 DNS 요건을 enableDnsSupport만으로 | **CONFIRMED**(V10) | enableDnsHostnames도 필요(둘 다 true) | S |
| 21 | DOC-SOA-309 | soa-t5-1 §5 표 | NAT GW "최대 수십 Gbps" | **CONFIRMED**(V10) | 현행 100Gbps(구 45Gbps 흔적) | S |
| 22 | DOC-SOA-003·004·101·102·103·106 | soa-t1-1·t2-1·t2-2 각 위치 | CloudWatch/ASG 6건(런북 직접작업·고해상도 지표 과금·워밍업/상태확인·훅 2h·유예 0초·cross-zone) | **CONFIRMED**(V8) | 각 개별 정정(모두 S) — 상세는 03-docs-facts M/L·V8 | S |
| 23 | DOC-SOA-007·109·207·208·209 외 | soa 각 위치 | 개념·구식화 다수(EBS 상태확인 3종·MRSC·PatchGroup 태그·Parameter Store RAM·EventBridge cron 6필드 등) | **CONFIRMED**(V9·V12) | 각 개별 정정(대개 S) | S |
| 24 | GUIDE-001·002·003 + P7 Firehose | exam_guides JSON·앱 표시명·soa 문서 | SOA-C03 가이드 v1.1 미반영·CloudOps 개명·SageMaker AI·Firehose 개명 | **CONFIRMED**(V11 등) | JSON v1.1 반영/앱 표시명 CloudOps/SageMaker AI/"Amazon Data Firehose(구 Kinesis)" 병기(SOA t1-2+t5-4 동시) | M |

> **SOA 자구 통일(N이지만 사람 결정 필요):** P6 "DX over VPN"→"VPN over Direct Connect"(SAA t3-8 4곳 + SOA t5-2 4곳, 총 8곳) · DOC-SOA-005("고대수"→"사용자 지정") · DOC-SOA-104(Connection Draining→deregistration delay 병기) · DOC-SOA-105(GLB→GWLB) · DOC-SOA-205·213 인용/용어. 사실 아님이나 일괄 자구 통일 권장.

---

## 검증으로 오탐 확정 — 정정 금지 (REFUTED)

> **아래는 2단 검증에서 "문서가 옳다"로 확정된 항목이다. 절대 고치지 말 것 — 고치면 오히려 구식화·오류가 된다.**

| ID | 위치 | 왜 문서가 옳은가 | 근거 |
|---|---|---|---|
| DOC-CLF-308 + DOC-SAA-410 | clf/t4-2#cost-tools · saa/saa-t4-5(4곳) | Cost Explorer 예측이 2025-11 **12→18개월로 확대**됨. 원문 "향후 ~18개월"이 현행 정확(12개월로 되돌리면 구식). "과거 ~13개월" 표기도 여전히 정확 | V2 |
| DOC-CLF-310 | clf/t4-3#support-plans | Business Support+ 재편은 **실재**(공식 `support-plans-eos.html`: Developer·Business·On-Ramp 2027-01-01 단종→Business Support+ 이관). 문서 서술이 공식과 부합 | V1 |
| DOC-CLF-311 | clf/t4-3#support-plans·학습 목표 | Enterprise On-Ramp 실재(2021 출시, 전용 페이지 존재). 전통 4분류로 가르치고 On-Ramp 단종을 메모한 것은 사실 오류 아님 | V1 |
| DOC-CLF-302 | clf/t3-8#appstream-mq | AppStream 2.0 → **Amazon WorkSpaces Applications 개명 실재**(공식 문서 제목·제품 페이지 "formerly AppStream 2.0"). 문서의 신·구 병기 정확 | V11 |
| DOC-CLF-304 | clf/t3-8#other-services | 문서 라벨("고객 지원")은 부정확하나 **발견자가 제시한 정답 "Customer Engagement"가 틀림** — 공식 CLF-C02 부록 범주명은 **"Customer Enablement"**. 발견 자체가 오탐이라 이 지적대로 고치면 안 됨(별도로 Customer Enablement 확인은 가능) | V12 |
| DOC-SAA-209 + DOC-SAA-406 | saa/saa-t3-5 §7·§8 · saa/saa-t4-3 §3 | Aurora 스토리지 상한은 **256TiB가 현행**(공식 Aurora 문서 "256-TiB size limit" 명시). "128TiB"가 오히려 구식 → **문서·문항의 128TiB 표기를 256으로 통일**해야 함(Q-SAA-b-06/07 참조). 256TiB를 128로 되돌리지 말 것 | V3 |
| DOC-SAA-202 | saa/saa-t3-2 §3(+Q2·시험 포인트) | gp3 **80,000 IOPS·2,000 MiB/s·64TiB 현행 정확**(공식 수치 일치). 시험 관례 16,000과의 괴리는 병기 문제일 뿐, 문서 수치 자체는 옳음 | V3 |
| DOC-SAA-104 | saa/saa-t2-2 함정 1 | **"Durable Lambda"(Lambda durable functions)는 실재**(2025-12 정식 출시). 명칭 부재 전제가 틀림(Step Functions와의 병기 느슨함은 별개 경미 사안) | V5 |
| DOC-SAA-105 | saa/saa-t2-3 §1 표 NLB 행 | NLB 리스너에 **QUIC·TCP_QUIC 실재**(공식 리스너 문서 verbatim). QUIC 포함이 오히려 현행 정답 | V5 |
| DOC-SAA-205 | saa/saa-t3-3 §2 표 | **Hpc8a·M8i·R8i·X8i 전부 실재·GA**(M8i 2025-08, R8i 2025-08, X8i GA, Hpc8a 2026-02). 문서 예시 정확 | V11 |
| DOC-SOA-008 | soa/soa-t1-4 함정 4·§4 | 문서는 "인스턴스 스토어 데이터 유실 **가능**"만 경고 — CloudWatch action-based recovery는 인스턴스 스토어 장착 인스턴스도 지원하며 그때 데이터 유실됨(공식 서술과 일치). 발견자의 "복구=EBS 전용만"이 과일반화 | V12 |

---

*집계: 확인 105건(개별 ID, H 14·M 55·L 36) · 오탐 제외 12 ID/11계열(REFUTED). AUD-403/405·소스불일치·P6/자구통일 등 N(비사실) 항목은 요약 105건에서 제외하고 각 절 각주로 안내. 절별 행수 ① 4 · ② 9 · ③ 3 · ④ 10 · ⑤ 41 · ⑥ 38.*
*본 문서는 기존 감사·검증 결과의 재구성이며 새 사실 판정을 추가하지 않았다.*
