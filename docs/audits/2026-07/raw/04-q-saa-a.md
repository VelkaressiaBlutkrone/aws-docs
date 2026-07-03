# ④ 문항 품질 감사 샤드 — 04-q-saa-a (saa-t2-1·saa-t3-2) — 2026-07

## 요약
- **saa-t2-1.questions.json** (느슨한 결합 — SQS·SNS·EventBridge·Step Functions): 15문항 중 12문항 전 항목 통과, 발견 3건(M 2·L 1).
- **saa-t3-2.questions.json** (EBS·EFS·FSx): 15문항 중 12문항 전 항목 통과, 발견 3건(M 2·L 1) + 두 파일 공통 참고 1건(L).
- 스키마 위생 전수 통과: id 유일(30/30)·correct 0–3 범위(30/30)·verified true(30/30)·옵션 4개(30/30)·wrongExplanations 키 = 오답 인덱스 정확 일치(30/30)·해설-정답 인덱스 어긋남 0건. difficulty는 foundational/applied만 사용(SAA 관례 일치), skill 태그 전 문항 유효.
- section 필드는 두 파일 모두 **전무**(빈 값 통과 규칙 적용) — grep 실측 결과 SAA 문항 파일 전체(24개)가 동일하게 section 없음(CLF 19파일만 보유). 파일 고유 결함이 아닌 SAA 전반 관례로 판단, L 참고 발견으로만 기록(Q-SAA-a-07).
- 병렬 문서 감사 교차 점검 결과: DOC-SAA-101(SNS 필터 부정)·DOC-SAA-202(gp3 80K 수치)·DOC-SAA-203(EFS 구분류 Standard-IA) 3건 모두 문항 측에도 동일 계열 서술 존재 확인 → 각각 별도 발견(사실의심 Y)으로 기재.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|----|------|-----------|---------------|------------------|-----------|------------|----------------|
| Q-SAA-a-01 | saa-t2-1.questions.json:saa-t2-1-q9 | wrongExplanations["2"]의 "SNS는 전체 구독자에게 Push하는 구조라 … **구독자 측에서 자체 필터링이 필요합니다**" — SNS 구독 필터 정책(메시지 속성 기반 2017~, 페이로드 기반 2022-11~) 존재를 부정하는 서술. **DOC-SAA-101(md L288 "SNS는 조건 필터링 없이 전체 구독자에게 Push")과 동일 오류 계열**로 문서·문항 동반 정정 필요. md 본문 L223("필터링 깊이가 EventBridge보다 얕습니다")은 올바른 상대 비교라 그 표현으로 통일 권장. 정답 인덱스에는 무영향 | M | 높 | 해설을 "SNS도 필터 정책으로 속성/페이로드 필터링이 가능하나, EventBridge의 이벤트 패턴이 AWS 서비스 이벤트 수신·조건 라우팅에 더 풍부" 취지로 수정 | A | Y |
| Q-SAA-a-02 | saa-t2-1.questions.json:saa-t2-1-q15 | 스템 "기본 FIFO 큐 설정으로 이 처리량(500건/초)을 달성할 수 있는가?"에 **배치 미사용 조건이 없음**. 비고처리량 FIFO도 배치(요청당 최대 10건) 사용 시 3,000msg/s까지 가능하므로 "가능(배치 사용)" 반론 여지 → 정답 선지("불가하다")의 단서 불충분. 해설에만 "배치 없이"로 한정돼 있고 선지는 "(API 요청 기준)"으로 부분 헷지. 오답 3개가 명백히 틀려 최선답 선택은 유지되나 스템 정밀도 결함 | M | 높 | 스템에 "배치 없이 건당 1요청으로 전송" 조건을 명시(해설의 한정 조건을 스템으로 승격) | A | N |
| Q-SAA-a-03 | saa-t2-1.questions.json:saa-t2-1-q7 | wrongExplanations["3"] "각 소비자별 독립적인 재시도·DLQ 보장에는 SQS 큐가 필요합니다" — EventBridge도 **대상(target)별 재시도 정책(최대 24h/185회)·대상별 DLQ**를 자체 지원하므로 절대 서술은 과함. 전달 실패(EventBridge DLQ)와 소비자 처리 실패(SQS 재노출·maxReceiveCount) 구분이 없으면 오해 소지. 반박의 취지(처리 실패의 내구적 재시도엔 큐 필요)는 유효 | L | 중 | "EventBridge의 대상별 재시도·DLQ는 전달 실패용이고, 소비자 처리 실패의 내구적 재시도·격리에는 SQS 버퍼가 필요" 취지로 정밀화 여부 결정 | B | Y |
| Q-SAA-a-04 | saa-t3-2.questions.json:saa-t3-2-q3 | option[0]·explanation·wrongExplanations["0"]의 "**gp3 — 최대 80,000 IOPS**" — **DOC-SAA-202(md L111 gp3 최대 IOPS 80,000)와 동일 수치 계열**. AWS가 2025년 말 gp3 한도를 16,000→80,000 IOPS(처리량 2,000MiB/s·용량 64TiB)로 상향 발표한 것과 부합할 가능성이 높아 '현행 실측'으로는 참일 수 있으나, SAA-C03 시험 관례 수치는 16,000이라 수험 정합 충돌. 어느 쪽이든 정답 유일성 무영향(80K/16K 모두 200K 미달, io2 BE 유지). 검증 결과 상향 발표가 사실이 아니면 H로 승격 필요 | M | 중 | 현행 AWS 공식 문서로 80K 한도 실재 검증 후, 문항 은행 표기 기준(시험 관례 16K vs 현행 문서)을 문서(DOC-SAA-202)와 함께 일괄 결정 | B | Y |
| Q-SAA-a-05 | saa-t3-2.questions.json:saa-t3-2-q15 | option[1]·explanation의 "**Standard-IA**" — **DOC-SAA-203(md L207–209 구 4분류 Standard/Standard-IA/One Zone/One Zone-IA)과 동일 계열**의 구세대 명칭. 2023-11 EFS Archive 도입 이후 현행 분류는 Standard / IA(Infrequent Access) / Archive(+One Zone 계열)이고 "Standard-IA" 명칭은 개편 전 것. 실체(수명주기 정책 30일→IA 전환, 다중 AZ 유지, 비용 절감)는 유효하고 정답 유일성 무영향 | M | 높 | 현행 명칭(IA)으로 갱신할지 시험 관례 명칭을 유지할지 문서(DOC-SAA-203)와 함께 일괄 결정. Archive 클래스 존재도 해설에 반영 검토 | B | Y |
| Q-SAA-a-06 | saa-t3-2.questions.json:saa-t3-2-q13 | 정답이 FSx for NetApp ONTAP인데 sources에 **ONTAP 공식 문서가 없음**(EFS·FSx for Windows 문서만 인용) — 정답 근거 소스 누락 | L | 높 | sources에 FSx for NetApp ONTAP 공식 문서(https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/what-is-fsx-ontap.html) 추가 | A | N |
| Q-SAA-a-07 | saa-t2-1.questions.json·saa-t3-2.questions.json (파일 공통) | 두 파일 모두 **section 필드 전무** — 개념 딥링크(약점 리포트→학습문서 섹션 스크롤)가 이 문항들에서 동작하지 않음. 단 grep 실측상 SAA 문항 파일 24개 전부 동일(section은 CLF 19파일에만 존재)하여 파일 고유 결함이 아닌 SAA 전반 미적용 상태. 앵커 점검은 빈 값 통과 처리 | L | 높 | SAA 문항 section 매핑 확장 여부를 로드맵 차원에서 결정(개별 파일 수정 아님) | B | N |

## 통과 집계 (요약 보조)
- 정답 유일성: 30/30 통과 — SAA 관례(최소 운영 부담·관리형 우선) 기준으로 전 문항 최선답 유일. Q-SAA-a-02는 스템 정밀도 결함이나 오답 3개가 명백히 틀려 최선답 선택 자체는 유지.
- 해설-정답 인덱스 일치: 30/30 (어긋남 0건). wrongExplanations 키 정합·실제 반박 여부: 30/30 (누락 0건).
- AWS 사실 검증 통과 예: FIFO exactly-once·중복제거 ID, Visibility Timeout 재노출, Long Polling 최대 20초·기본 Short, DLQ maxReceiveCount, SNS 구독자 유형(Data Firehose 포함·RDS 제외), Step Functions Standard 1년/2,000건·Express 5분/100,000건·CloudWatch Logs 이력, EventBridge 파트너 이벤트 소스(Salesforce), gp2 3IOPS/GB·gp2→gp3 온라인 전환, io1 64K·내구성 99.8–99.9%, io2 BE 256K·99.999%, st1/sc1 부팅 불가·500/250MiB/s·st1 500IOPS(1MiB), Multi-Attach io1/io2·동일 AZ·앱 동시성 책임, 인스턴스 스토어 reboot 보존/stop·terminate 소실, 스냅샷 증분·AZ/리전 복사·암호화 유지, EFS NFSv4·Windows 미지원, FSxW SMB 2.0–3.1.1·AD 필수·iSCSI 미지원, FSx Lustre S3 연계·서브밀리초, ONTAP 멀티 프로토콜(NFS/SMB/iSCSI), EFS GP 권장·Max I/O 이전 세대·Elastic은 GP 전용.
