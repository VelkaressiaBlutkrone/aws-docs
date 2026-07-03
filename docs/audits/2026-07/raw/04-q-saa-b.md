# ④ 문항 품질 감사 샤드 — 04-q-saa-b (saa-t3-4·saa-t3-5) — 2026-07

## 요약

- **saa-t3-4.questions.json**: 15문항(예상 일치). 스키마 위생·정답 유일성·해설-정답 일치·skill/difficulty 태그 전수 통과. 발견 4건(M 2·L 2, 4개 문항).
- **saa-t3-5.questions.json**: 15문항(예상 일치). 스키마 위생·정답 유일성·태그 전수 통과. 발견 5건(M 5, 4개 문항 — q5는 2곳 채번).
- **스키마 위생 30/30 통과**: id 유일, correct 0~3 범위, verified 전부 true, 옵션 4개, wrongExplanations가 오답 3개 인덱스를 정확히 커버.
- **section 앵커**: 두 파일 전 30문항에 section 필드 부재 — SAA 콘텐츠 디렉터리 전체가 0건(CLF 문항만 사용, 모델 `question.dart`는 부재 시 `''` 기본값으로 안전 처리)이므로 점검 기준(빈 값 통과)상 전원 통과. 딥링크 미연결 상태라는 관찰만 기재(뱅크 전반 정책 사안, 본 샤드 채번 제외).
- **정답 뒤집힘(H)급 0건**. 사실의심 Y 7건은 전부 해설·디스트랙터 층위로 정답 자체는 보존됨. 컨트롤러 지정 2곳(t3-5:117·121행 128/256TiB 자기모순)은 Q-SAA-b-06·07로 채번, gp3 버스트 크레딧 오기(DOC-SAA-210)의 문항 전파는 t3-5-q11에서 확인(Q-SAA-b-08).

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-SAA-b-01 | saa-t3-4.questions.json:saa-t3-4-q1 | 운영 부담 스펙트럼 5단 서열화 문항 — "EKS가 ECS EC2 시작 유형보다 운영 부담이 낮다"는 상대 순서는 AWS 공식 문서가 규정하지 않는 학습문서(saa-t3-4.md §1) 자체 프레임이며, 같은 문서 §3 표("EKS 러닝커브 높음")와도 긴장. 각 오답이 독립적 명백 오류(Fargate<Lambda 배치 등)를 포함해 정답 유일성 자체는 유지 | L | 중 | 서열 암기형 대신 "노드 관리 유무" 등 공식 사실 축 기반으로 문항 재설계 검토(문서 프레임과 동시 결정) | B | N |
| Q-SAA-b-02 | saa-t3-4.questions.json:saa-t3-4-q2 | wrongExplanations "0"·"3"이 "~설명은 문서에 없습니다"를 오답 근거로 제시 — 문서 부재≠사실 오류인 약한 논리. 예: 옵션3(재무 데이터 규정 제한)의 실제 근거는 "그런 AWS 규정이 존재하지 않는다"임 | L | 중 | 사실 기반 근거로 자구 보강("규정 제한 없음·핵심은 15분 제한") | B | N |
| Q-SAA-b-03 | saa-t3-4.questions.json:saa-t3-4-q7 | wrongExplanations "0": "Job Definition, Task, Service는 ECS의 리소스입니다" — ECS 리소스는 **Task Definition**·Task·Service(학습문서 §3 표와도 불일치)이고, **Job Definition은 오히려 AWS Batch의 공식 구성요소**(What is AWS Batch: Jobs·Job Definitions·Job Queues·Compute Environments 4요소). 뒤절 "AWS Batch는 Job, Job Queue, Compute Environment로 구성"은 Job Definition을 배제(문서의 3계층 단순화 전파) | M | 높 | "Task Definition·Task·Service가 ECS 리소스"로 정정, Job Definition이 Batch 구성요소임을 반영해 해설 재작성 | A | Y |
| Q-SAA-b-04 | saa-t3-4.questions.json:saa-t3-4-q15 | wrongExplanations "3": "EKS Fargate를 Compute Environment로 구성하는 것은 가능하지만" — 공식 문서 기준 **AWS Batch on EKS는 Fargate 미지원**(Batch의 Fargate CE는 ECS 기반 FARGATE/FARGATE_SPOT 타입만). 오답 이유가 '비용 열세'가 아니라 '구성 불가'일 가능성 | M | 중 | AWS Batch on EKS 공식 문서 확인 후 해설 재작성(가능성 단정 제거) | B | Y |
| Q-SAA-b-05 | saa-t3-5.questions.json:saa-t3-5-q2 | explanation: "RDS는 최대 5개, Aurora는 최대 15개를 지원합니다" — 현행 공식 문서(USER_ReadRepl) 기준 RDS for MySQL·MariaDB·PostgreSQL은 **최대 15개**(Oracle·SQL Server만 5개). 학습문서 saa-t3-5.md §3·§4표·§8표의 동일 진술 전파(문서 감사 샤드와 교차 확인 필요). 정답(Read Replica 추가)은 불변 | M | 중 | 공식 문서 재확인 후 "엔진별 15/5" 표기로 문서와 동시 정정 | B | Y |
| Q-SAA-b-06 | saa-t3-5.questions.json:saa-t3-5-q5 (explanation, 117행) | "(최대 128TiB, 공식 문서 기준 256TiB)" **자기모순 해설** — 한 문장 안에서 128TiB와 256TiB를 동시 주장. 공식 상한은 **128TiB**(Aurora MySQL v3·Aurora PostgreSQL 13+ 클러스터 볼륨; 구버전 64TiB)이며 256TiB 근거 없음. 문서 환각 "256TiB(2025년 상향)"(DOC-SAA-209/406, H)의 변형 전파. 정답(3AZ 6벌 복제)은 불변 | M | 높 | "(최대 128TiB)" 단일 표기로 정정 — 문서 정정과 동기화 | A | Y |
| Q-SAA-b-07 | saa-t3-5.questions.json:saa-t3-5-q5 (wrongExplanations."3", 121행) | "Aurora 스토리지의 최대 용량은 128TiB(공식 문서 기준 256TiB)입니다" — Q-SAA-b-06과 동일한 자기모순. 오답 판정(64TiB≠Aurora 한계, 64TiB는 일반 RDS 상한)은 128TiB 기준으로도 성립하므로 정답 영향 없음 | M | 높 | "최대 128TiB" 단일 표기로 정정 | A | Y |
| Q-SAA-b-08 | saa-t3-5.questions.json:saa-t3-5-q11 | 옵션1 자구("범용 SSD(gp2/gp3) — 버스트 크레딧으로…")·explanation("범용 SSD는 버스트 크레딧 소진 후…")·wrongExplanations "1"("gp2/gp3는 크레딧 방식으로…") 3곳이 **gp3에 버스트 크레딧을 귀속** — 공식 기준 버스트 크레딧은 **gp2 전용**이며 gp3는 3,000 IOPS·125MiB/s 기준 성능을 크레딧 없이 상시 제공(필요 시 독립 프로비저닝). 학습문서 §6 원리 박스 오기(DOC-SAA-210, H)의 전파 확인. 정답(io1/io2)은 '일관된 저지연 요구' 기준으로 불변 | M | 높 | "gp2는 크레딧 버스트, gp3는 고정 기준 성능+독립 프로비저닝"으로 3곳 구분 정정 — 문서 정정과 동기화 | A | Y |
| Q-SAA-b-09 | saa-t3-5.questions.json:saa-t3-5-q12 | 옵션1 "RDS MySQL — 최대 15개 Read Replica를 지원한다"를 오답 처리하고 wrongExplanations "1"에서 "일반 RDS MySQL은 최대 5개… 15개는 Aurora의 한계"라고 단정 — 현행 공식 문서 기준 RDS for MySQL이 15개를 지원하면 **옵션1 진술 자체가 참이 되어 디스트랙터 설계 근거 붕괴**(정답 Aurora는 6벌 복제·빠른 페일오버 등 HA 근거로 '가장 적합' 지위 유지 → 정답 모호 H까지는 아님) | M | 중 | 공식 문서 확인 후 디스트랙터·해설 재설계(변별 축을 복제본 수가 아닌 HA 구조로 이동) | B | Y |

## 부록 — 사실의심 항목 근거 (공식 문서 기준)

- **Aurora 스토리지 상한(b-06·07)**: Aurora User Guide(CHAP_AuroraOverview / Aurora storage) — 클러스터 볼륨 자동 확장 최대 **128TiB**(Aurora MySQL v3, Aurora PostgreSQL 13+; 이전 버전 64TiB). 256TiB 상향 발표·문서 근거 확인 불가(2026-07 감사 시점 지식 기준) — 문서 감사 DOC-SAA-209/406과 동일 판정.
- **gp2 vs gp3(b-08)**: EBS 볼륨 타입 공식 문서 — gp2는 크레딧 기반 버스트(기준 3 IOPS/GiB), gp3는 크레딧 메커니즘 없이 3,000 IOPS·125MiB/s 기준 성능 상시 제공, 상위 성능은 크기와 무관하게 별도 프로비저닝.
- **RDS Read Replica 상한(b-05·09)**: RDS User Guide USER_ReadRepl — 엔진별 상한 표 기준 MySQL·MariaDB·PostgreSQL **15개**, Oracle·SQL Server 5개. "RDS=5개" 일괄 표기는 구식(확신도 중 — 정정 전 원문 재확인 권장).
- **AWS Batch 구성요소(b-03)**: What is AWS Batch — Jobs·**Job Definitions**·Job Queues·Compute Environments. ECS 리소스는 Task Definition·Task·Service·Cluster.
- **AWS Batch on EKS의 Fargate(b-04)**: AWS Batch User Guide(Batch on EKS) — EKS 컴퓨팅 환경은 EC2/Spot 기반이며 Fargate 미지원으로 기재(확신도 중 — 정정 전 원문 재확인 권장).

## 통과 집계

- 정답 유일성 30/30 (사실의심 항목 반영 후에도 의도 정답이 '가장 적합' 지위 유지 — b-09만 변별 축 약화로 B 판정)
- 해설-정답 일치 30/30 · wrongExplanations 논리 28/30(b-02 약논리·b-09 사실 단정)
- section 앵커: 해당 없음(전 문항 필드 부재 → 빈 값 통과 규칙 적용)
- skill·difficulty 태그 30/30(모델상 자유 문자열, foundational/applied 사용)
- 스키마 위생 30/30
