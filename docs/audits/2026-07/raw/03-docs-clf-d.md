# ③ 학습문서 사실성 감사 샤드 — 03-docs-clf-d (t3-8·t4-1~t4-3) — 2026-07

## 요약 (3~5줄)

- 4개 문서(t3-8 메시징·EUC·IoT / t4-1 요금 모델 / t4-2 비용 도구 / t4-3 Support 플랜) 전문 정독. **발견 11건(사실의심 9건): H 1 · M 3 · L 7.**
- 최우선은 t4-3 Enterprise 플랜의 "프로덕션 중요 케이스 **15분 응답**"(DOC-CLF-309): 공식 응답 목표는 **비즈니스 크리티컬 시스템 다운 <15분**이며, 프로덕션 시스템 다운은 Enterprise에서도 <1시간(Business와 동일) — 시험 단골 수치라 오답 유발 가능(H).
- 수치·구조 오류 3건(M): Cost Explorer 예측 기간 "~18개월"(공식 12개월, 308) · Savings Plans "최대 72% + 패밀리·리전 무관"을 한 플랜 속성처럼 결합(72%=EC2 Instance SP·패밀리 고정, 완전 유연은 Compute SP·최대 66%, 305) · SNS "저장·재시도 메커니즘 없음"(실제 재시도 정책·DLQ 존재, 301).
- 2026년 최신 주장 2건(AppStream 2.0→WorkSpaces Applications 개명 302, Business Support+·2027-01-01 단종 310·311)은 감사자 지식 컷오프(2026-01) 밖이라 확신도 '낮'으로 2단 검증 회부 — 오류 단정 아님.
- 이 샤드 4개 문서 간 상호 모순은 발견하지 못함(전달·요금·플랜 서술 상호 정합).

## 발견 항목

> Phase 표기: **A** = 문구 정정으로 즉시 반영 가능 / **B** = 2단 검증(라이브 확인) 또는 보강 여부 판단 필요.

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| DOC-CLF-301 | assets/content/clf/t3-8.md#messaging (🧠 원리) | "SNS는 메시지를 **저장하거나 재시도하는 메커니즘 없이** 전달하는 데 최적화" — 사실과 다름. 근거: SNS는 프로토콜별 전달 재시도 정책(SQS·Lambda 엔드포인트는 최대 23일 재시도)과 DLQ를 공식 제공하고, 전달 완료까지 다중 AZ에 메시지를 보관함. 의도한 대비(소비자가 꺼내 갈 수 있는 내구 큐가 아님)는 유효하나 문장 자체가 오개념을 심음 | M | 높 | "소비자가 나중에 폴링해 가져가도록 보관하지 않는다(큐가 아님)"로 재서술하고 '재시도 없음' 표현 제거 | A | Y |
| DOC-CLF-302 | assets/content/clf/t3-8.md#appstream-mq (및 학습 목표·출처 목록) | "AppStream 2.0의 현재 공식 문서명 = **Amazon WorkSpaces Applications**" 주장 — 감사자 컷오프(2026-01) 기준 해당 개명을 확인할 수 없음(문서 lastVerified 2026-06-21은 컷오프 이후). 근거: 2026-01까지 학습 데이터에 개명 공지 부재. 문서가 신·구 명칭을 병기해 시험 위험 자체는 낮음 | L | 낮 | appstream2 공식 문서 제목을 라이브로 확인(2단 검증); 사실이면 현행 유지 | B | Y |
| DOC-CLF-303 | assets/content/clf/t3-8.md#pitfalls (함정 7·8) | 함정 7·8의 원리 참조가 "(원리: §3 …)"로 표기 — §3은 IoT Core이고 실제 근거는 무번호 절 'AppStream 2.0 · Amazon MQ'(#appstream-mq). 내부 참조 불일치(사실 오류 아님) | L | 높 | 참조를 해당 절로 수정하거나 절에 번호 부여 | A | N |
| DOC-CLF-304 | assets/content/clf/t3-8.md#other-services | 묶음명 "**고객 지원**"(AWS Support·IQ·AMS) — CLF-C02 시험 가이드의 공식 범주명은 "**고객 참여(Customer Engagement)**"(AWS Activate for Startups·AWS IQ·AMS·AWS Support). 이 절의 학습 목표가 '범주 매칭'이므로 공식 명칭이 안전. 근거: C02 가이드 부록의 범주명 Customer Engagement | L | 중 | "고객 참여(Customer Engagement)"로 병기, AWS Activate 예시 추가 검토 | A | Y |
| DOC-CLF-305 | assets/content/clf/t4-1.md#purchase-options (표·시험 포인트·Q1 답) | Savings Plans 행이 "**최대 72%**"와 "**인스턴스 패밀리·크기·OS·리전 무관**(+Fargate·Lambda)"을 단일 플랜 속성처럼 결합. 근거: 공식 구분은 Compute SP=최대 66%·완전 유연(패밀리·리전·OS 무관, Fargate·Lambda 포함) / EC2 Instance SP=최대 72%·특정 패밀리+리전 고정 — 한 플랜이 최대 할인과 최대 유연성을 동시에 주는 듯한 오개념 소지(단, CLF 관례상 'SP=최대 72%' 단독 표기는 통용) | M | 높 | "최대 72%는 EC2 Instance SP(패밀리 고정) 기준, 완전 유연한 Compute SP는 최대 66%"를 각주로 분리 서술 | A | Y |
| DOC-CLF-306 | assets/content/clf/t4-1.md 「먼저 알아야 할 용어」 Glacier 행 | "Glacier … **복원에 수 분~수 시간**" 일반화 — S3 Glacier Instant Retrieval(밀리초 접근) 존재와 상충하고 Deep Archive는 12~48시간. 근거: S3 스토리지 클래스 공식 문서의 Glacier 3개 클래스(Instant/Flexible/Deep Archive) 검색 특성. 스토리지 클래스 비교 문항에서 '즉시 복원 Glacier는 없다'는 오판 유발 소지 | L | 높 | "Flexible Retrieval 기준 수 분~수 시간(Instant Retrieval은 밀리초, Deep Archive는 12~48시간)"으로 클래스 한정 | A | Y |
| DOC-CLF-307 | assets/content/clf/t4-1.md#purchase-options (+학습 목표 "6종") | **Dedicated Instances 미언급(누락, 오류 아님)** — Dedicated Hosts vs Dedicated Instances 구분(호스트 단위·소켓/코어 가시성·BYOL vs 인스턴스 단위·가시성 없음)이 CLF 단골 함정인데 문서 전체에서 다루지 않고, '구매 옵션 6종' 프레이밍이 부재를 고착 | L | 높 | Dedicated Hosts 행 인근에 Dedicated Instances 한 줄 보강 검토 | B | N |
| DOC-CLF-308 | assets/content/clf/t4-2.md#cost-tools (표 Cost Explorer 행) | "(과거 ~13개월, **향후 ~18개월 예측**)" — 예측 기간 수치 오류. 근거: 공식 문서·제품 페이지는 '과거 최대 13개월 조회 + **향후 12개월 예측**'(월 단위 최대 38개월 이력은 별도 옵트인 기능) | M | 높 | "향후 ~12개월 예측"으로 정정 | A | Y |
| DOC-CLF-309 | assets/content/clf/t4-3.md#support-plans (표 Enterprise 행, ✍️ 시험 포인트) | Enterprise "프로덕션 중요 케이스 **15분 응답**" — 케이스 유형 오기. 근거: 공식 응답 목표는 '**비즈니스 크리티컬 시스템 다운** <15분'이고 '프로덕션 시스템 다운'은 Enterprise에서도 <1시간(Business와 동일, 문서 자신의 #health-dashboard 절 '프로덕션 다운 1시간'과도 긴장). 응답 시간은 시험 단골 수치라 오답 유발 가능 | H | 높 | "비즈니스 크리티컬 시스템 다운 15분 응답"으로 정정, 시험 포인트의 "TAM + 15분 응답"에도 케이스 유형 병기 | A | Y |
| DOC-CLF-310 | assets/content/clf/t4-3.md#support-plans (정직성 메모)·#health-dashboard·시험 포인트 | "Developer·Business·Enterprise On-Ramp **2027-01-01 단종** 예정, **Business Support+**·**Unified Operations** 도입" — 감사자 컷오프(2026-01) 기준 확인 불가한 최신 재편 주장. 근거: 2026-01까지 학습 데이터에 해당 재편 공지 부재(오류 단정 아님). 시험 대비는 전통 4분류로 안내하고 있어 시험 위험은 낮음 | L | 낮 | 공식 Support 플랜 페이지·문서 공지에서 명칭·단종일 실재 확인(2단 검증) | B | Y |
| DOC-CLF-311 | assets/content/clf/t4-3.md#support-plans (정직성 메모)·학습 목표 | "CLF-C02 공식 시험 가이드는 전통적 분류(Basic·Developer·Business·Enterprise)를 **명시**" — 가이드 원문이 플랜 4종을 실제로 열거하는지 확정 불가 + **Enterprise On-Ramp**(2022년 출시, 비즈니스 크리티컬 30분·TAM 풀 제공)를 본문에서 전혀 다루지 않음. 근거: On-Ramp는 C02 출시(2023-09) 이전부터 존재하는 플랜으로 C02 문항에 등장할 수 있음 | L | 낮 | 가이드 원문 확인(2단 검증) 후 필요 시 On-Ramp 한 줄 보강 | B | Y |
