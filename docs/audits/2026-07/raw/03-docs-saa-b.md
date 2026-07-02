# ③ 학습문서 사실성 감사 샤드 — 03-docs-saa-b (t2-1~t2-5) — 2026-07

## 요약 (3~5줄)

- 대상 5개 문서(saa-t2-1 ~ t2-5) 전문 정독. 핵심 시험 수치·관례(SQS visibility timeout 30초/0~12h·보존 4일/최대 14일·롱폴링 20초, Lambda 15분·비동기 재시도 2회, Step Functions Standard 1년/Express 5분, ALB L7/NLB L4, cross-zone 기본값 ALB on·NLB off, Multi-AZ 동기 vs Read Replica 비동기, DR 4전략 비용·복구속도 순서, Pilot Light vs Warm Standby 구분선)는 모두 공식 문서·시험 관례와 부합 — 전반 품질 높음.
- 발견 총 10건: H 1건(SNS "조건 필터링 없이"라는 정답 해설 — SNS 구독 필터 정책 존재를 부정, 같은 문서 §7 원리와도 모순), M 5건(Durable Lambda 표기, NLB QUIC, ALB 대상그룹에 "다른 ALB", NLB 스티키 서술, CRR "버전 관리 지원"), L 4건.
- 문서 간(샤드 내) 모순은 없음. 문서 내 모순 1건(DOC-SAA-101). 사실의심 Y 8건은 2단 검증 대상.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| DOC-SAA-101 | assets/content/saa/saa-t2-1.md#자가 점검 Q3 정답 해설 | "SNS는 조건 필터링 없이 전체 구독자에게 Push하므로" — 사실 오류. SNS는 구독 필터 정책(메시지 속성 기반, 2022부터 페이로드 기반도)을 공식 지원. SAA에 "SNS 팬아웃 + 필터 정책으로 구독자별 선별 전달" 정답 문항이 존재해, 이 문장대로 배우면 해당 문항에서 오답(EventBridge/토픽 분리) 유발 가능. 같은 문서 §7 원리("SNS는 필터링 깊이가 EventBridge보다 얕다" = 존재 전제)와도 문서 내 모순. 근거: SNS 공식 Subscription filter policies 문서 | H | 높 | "SNS도 속성 기반 필터 정책은 지원하나, AWS 서비스 이벤트 패턴 매칭·SaaS 통합은 EventBridge" 취지로 해설 재작성 | A | Y |
| DOC-SAA-102 | assets/content/saa/saa-t2-1.md#4) 팬아웃 패턴(원리 블록)·흔한 함정 3 | "Lambda가 동시성 한도에 도달하면 SNS는 제한된 횟수만 재시도하고 이후 메시지를 버립니다" — 메커니즘 귀속 부정확. SNS→Lambda는 비동기 호출 수락 후 Lambda 비동기 이벤트 큐(재시도 2회·최대 이벤트 수명 기본 6시간)가 실패 처리를 담당하고, SNS 자체의 AWS 관리형 엔드포인트 재시도 정책은 10만+회/23일로 "제한된 횟수" 서술과 상충. 결론(SQS 버퍼 권장)은 시험 관례와 일치하므로 오답 유발성은 낮음. 근거: SNS delivery retry policy(AWS managed endpoints)·Lambda async invocation 공식 문서 | L | 중 | 유실 지점을 "Lambda 비동기 큐의 재시도·수명 한도"로 귀속시키거나 메커니즘 상세를 중립화("재시도가 소진되면 유실될 수 있다") | B | Y |
| DOC-SAA-103 | assets/content/saa/saa-t2-1.md#흔한 함정 1 | 원리 참조 오기: "(원리: §1 — SQS Pull 모델은…)" — Pull 모델·잠금 설명은 §2(Amazon SQS)이며 §1은 Decoupling 정의. 사실 오류 아님, 내부 참조 불일치 | L | 높 | §1 → §2로 참조 정정 | A | N |
| DOC-SAA-104 | assets/content/saa/saa-t2-2.md#흔한 함정 1 | "Fargate, AWS Batch, Step Functions(Durable Lambda) 등" — "(Durable Lambda)"가 Step Functions의 별칭처럼 읽히나 그런 AWS 공식 명칭은 확인 불가(감사자 지식 컷오프 2026-01 기준). 설령 Lambda 측 신기능(durable functions류)을 지칭하더라도 Step Functions 뒤 괄호 표기는 부정확하고, SAA-C03 정답 관례는 "15분 초과 → Step Functions로 분할/Fargate/Batch"라 괄호가 혼동만 유발. 근거: AWS 서비스 목록에 "Durable Lambda" 명칭 부재 | M | 중 | 괄호 "(Durable Lambda)" 삭제(또는 "Step Functions로 여러 Lambda를 분할 오케스트레이션"으로 풀어쓰기). 신기능 지칭 여부는 2단 검증 | A | Y |
| DOC-SAA-105 | assets/content/saa/saa-t2-3.md#1) ELB 종류 표(NLB 행) | NLB 주요 프로토콜에 "QUIC" 포함 — NLB 리스너 프로토콜 공식 목록은 TCP·UDP·TCP_UDP·TLS이며 QUIC 리스너는 없음(QUIC 트래픽은 UDP 리스너로 통과할 뿐). 프로토콜 매칭형 문항에서 오개념 소지. 근거: NLB 공식 Listeners 문서의 지원 프로토콜 목록(컷오프 기준) — 2026년 신규 지원 발표 여부 2단 확인 필요 | M | 중 | "QUIC" 삭제 또는 "UDP(QUIC 트래픽 통과 가능)"로 수정 | A | Y |
| DOC-SAA-106 | assets/content/saa/saa-t2-3.md#2) ALB 핵심 구성 요소 표(대상 그룹 행) | ALB 대상 그룹에 "…Lambda 함수·다른 ALB 등록 가능" — 방향 오류. ALB 대상 그룹의 대상 유형은 instance/ip/lambda뿐이고, "ALB를 대상으로 등록"은 NLB 대상 그룹의 기능(NLB 고정 IP + ALB L7 라우팅 결합 패턴, SAA 기출 소재). 이대로 배우면 해당 조합 문항에서 계층 방향을 혼동할 수 있음. 근거: ELB 공식 "Application Load Balancers as targets"는 NLB 가이드 소속, ALB Target groups 문서의 target type 목록 | M | 높 | ALB 표에서 "다른 ALB" 삭제, 필요 시 §3(NLB)에 "NLB 뒤에 ALB를 대상으로 둘 수 있음(고정 IP+L7 라우팅)" 추가 | A | Y |
| DOC-SAA-107 | assets/content/saa/saa-t2-3.md#5) 고정 세션 표(지원 유형 행) | "NLB(TCP 플로우 해시로 자연스럽게 고정)" — 오개념 소지. 플로우 해시는 개별 TCP 연결 수명 동안의 대상 고정일 뿐, 동일 클라이언트의 새 연결이 같은 대상으로 가는 세션 고정이 아님. NLB의 세션 고정은 대상 그룹 속성 source_ip 스티키니스(opt-in)로 별도 제공. 근거: NLB Target group attributes(stickiness.type=source_ip) 공식 문서 | M | 높 | "NLB(소스 IP 기반 스티키니스 — 대상 그룹 속성으로 활성화)"로 정정 | A | Y |
| DOC-SAA-108 | assets/content/saa/saa-t2-3.md#1) ELB 종류 표(CLB 행) | CLB 대표 사용 사례 "기존 EC2-Classic 환경만" — EC2-Classic은 2023년 완전 폐지되어 현존하지 않는 환경. CLB 자체는 VPC에서도 동작하는 이전 세대 LB. 시험 영향은 미미(CLB 비권장 결론은 동일)하나 사실이 낡음. 근거: AWS EC2-Classic 네트워킹 retirement(2023) 공지 | L | 높 | "레거시 — 신규 사용 비권장(마이그레이션 대상)" 정도로 사용 사례 문구 교체 | A | Y |
| DOC-SAA-109 | assets/content/saa/saa-t2-5.md#4) 리전 간 데이터 복제 수단 표(S3 행) | S3 CRR 특징 "비동기 연속 복제, 버전 관리 지원" — "지원"이 아니라 원본·대상 버킷 모두 버전 관리 활성화가 필수 전제 조건. "CRR 활성화에 무엇이 필요한가"는 시험 단골 포인트라 전제를 기능처럼 서술하면 해당 문항 대비가 누락됨. 근거: S3 Replication requirements — 원본·대상 모두 versioning enabled 필수 | M | 높 | "버전 관리 필수(원본·대상 버킷 모두 활성화)"로 정정 | A | Y |
| DOC-SAA-110 | assets/content/saa/saa-t2-4.md#4)·5) (스탠바이는 읽기 불가) | "스탠바이는 읽기 불가"를 무조건 서술 — Multi-AZ **DB 인스턴스** 배포(문서가 인용한 SingleStandby 페이지) 기준으로는 정확하나, 읽기 가능한 스탠바이 2개를 갖는 RDS **Multi-AZ DB 클러스터** 배포가 별도로 존재. 신형 문항에 "Multi-AZ DB cluster(readable standbys)"가 등장할 수 있어 절대 서술은 경미한 혼동 소지. 고전 문항 정답 방향("standby 읽기 불가")은 그대로 유효 | L | 중 | "Multi-AZ(인스턴스 배포) 기준" 한정어 또는 각주 1줄 추가 여부를 사람 결정(어소시에이트 범위 판단) | B | N |

## 비고

- 점검했으나 이상 없음(대표): SQS Standard/FIFO 표(300/3,000 TPS·고처리량 모드·5분 중복 제거 창), Step Functions Standard exactly-once/Express at-least-once·실행 이력 위치, Lambda 메모리 128MB~10,240MB·Reserved vs Provisioned 구분, API Gateway 3종·인증 3종, ECS/EKS·EC2/Fargate 책임 분리, ASG 정책 4종·수명 주기 훅 기본 1시간(하트비트로 최대 48시간), RDS Multi-AZ 페일오버 1~2분, Route 53 헬스 체크 데이터 플레인, Aurora Global Database 1초 미만/1분 승격, DRS=Pilot Light·RDS 제외, DR 4전략 스펙트럼 서술.
- 샤드 내 5개 문서 상호 참조(표준 HA 구조, Multi-AZ 동기 vs 교차 리전 비동기, DR 위임 관계 t2-4→t2-5)는 일관됨.
