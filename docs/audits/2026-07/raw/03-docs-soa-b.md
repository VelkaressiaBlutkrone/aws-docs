# ③ 학습문서 사실성 감사 샤드 — 03-docs-soa-b (t2-1~t2-4) — 2026-07

## 요약 (3~5줄)

- SOA 도메인 2(신뢰성·BC) 4개 문서(soa-t2-1~t2-4) 전문 정독. **발견 9건(H 0 / M 3 / L 6, 사실의심 Y 6건)** — 시험 오답을 직접 유발할 H급 오류는 없음.
- 골격(ASG 정책 4종·쿨다운 vs 워밍업 구분·수명주기 훅 상태 전이·EC2 vs ELB 헬스체크·RDS Multi-AZ 동기/DNS 페일오버·읽기 복제본 비교·Vault Lock 2모드·EBS 증분/완전 복원 지점·RDS 1~35일/PITR·CRR/SRR 버전관리 전제·배치 복제·DR 4종 순서·Pilot Light vs Warm Standby)은 모두 공식 문서와 일치.
- 주요 M 3건: ① t2-1 워밍업 표가 "상태 확인 제외"까지 워밍업 효과로 혼입(유예 기간의 역할), ② t2-2 ELB 원리 블록이 교차 영역 비활성 전제의 노드 우회 메커니즘을 일반화(ALB 기본 활성과 긴장), ③ t2-4 S3 복제 "거의 실시간" 단정 + RTC 부재.
- 병렬 SAA 감사 계열 주장 재점검 결과: NAT GW "자동 고가용성" 단정 **없음**(AZ 단위 리소스로 올바르게 서술), CRR 버전 관리는 "지원"이 아닌 "전제/필수"로 올바르게 표현 — 두 함정 모두 이 샤드에는 해당 없음.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| DOC-SOA-101 | assets/content/soa/soa-t2-1.md#4-쿨다운-vs-워밍업-혼동-주의 (표 "목적" 행) | 워밍업의 효과를 "지표 집계·**상태 확인**에서 제외"로 기술. AWS 공식상 워밍업(default instance warmup 포함)은 신규 인스턴스를 **집계 지표에서 제외**하는 기능이고, 상태 확인 보류는 별도 설정인 **상태 확인 유예 기간**(§6에서 올바르게 별도 서술)의 역할 — 두 설정의 혼입. [근거: default instance warmup 문서는 "워밍업 중 인스턴스는 집계 지표에 카운트되지 않음"만 명시하며 health check grace period를 대체하지 않는다고 구분함] | M | 중 | 표에서 "상태 확인" 삭제 → "지표 집계에서 제외"로 한정하고, 상태 확인 보류는 §6 유예 기간으로 위임(§4 하단 시험 포인트·함정 6은 이미 올바르게 분리돼 있어 표만 수정하면 문서 내 일관) | A | Y |
| DOC-SOA-102 | assets/content/soa/soa-t2-1.md#5-수명-주기-후크lifecycle-hooks ("기본 대기 시간: 1시간(최대 48시간)") | 하트비트 타임아웃 설정값 자체의 범위는 30~7,200초(최대 2시간)이고, 48시간은 **하트비트 기록(갱신)으로 대기를 연장**할 때의 총 상한(48h 또는 타임아웃×100 중 작은 값). 현재 표기는 타임아웃을 48시간으로 직접 설정 가능한 것처럼 읽힘. [근거: PutLifecycleHook HeartbeatTimeout 범위 30–7200s·기본 3600s, 대기 연장은 RecordLifecycleActionHeartbeat 경유] | L | 중 | "기본 1시간, 하트비트 갱신으로 최대 48시간까지 연장 가능"으로 자구 수정 | A | Y |
| DOC-SOA-103 | assets/content/soa/soa-t2-1.md#6-상태-확인--ec2-vs-elb--시험-핵심 ("기본 300초") | 상태 확인 유예 기간 기본값 300초는 **콘솔 생성 시** 기본이며, CLI/API(CreateAutoScalingGroup) 기본값은 0초. 무조건 "기본 300초" 단정은 CLI로 만든 ASG의 조기 종료 트러블슈팅(운영자 관점) 시 오개념 소지. [근거: CreateAutoScalingGroup HealthCheckGracePeriod "Default: 0 seconds", 콘솔 기본 300] | L | 중 | "(콘솔 기본 300초, CLI/API 기본 0초)" 병기 | A | Y |
| DOC-SOA-104 | assets/content/soa/soa-t2-1.md#-먼저-알아야-할-용어 ("연결 드레이닝 Connection Draining") | "Connection Draining"은 CLB(레거시) 용어. ALB/NLB의 공식 명칭은 **등록 취소 지연(deregistration delay)** — SOA 지문·콘솔 UI가 이 용어를 사용하므로 병기 필요. 개념 설명 자체는 정확 | L | 높 | 용어표에 "ALB/NLB 공식 명칭은 등록 취소 지연(deregistration delay)" 병기 | A | N |
| DOC-SOA-105 | assets/content/soa/soa-t2-1.md#7-elb-종류와-asg-연동 (표 "GLB(Gateway)") | Gateway Load Balancer의 AWS 공식 약칭은 **GWLB**. "GLB" 약칭은 비공식 — 시험 선택지·공식 문서 표기와 정렬 권장(표현 수준) | L | 높 | "GWLB(Gateway)"로 표기 정정 | A | N |
| DOC-SOA-106 | assets/content/soa/soa-t2-2.md#4-elb--다중-az (🧠 원리 블록) | "특정 AZ의 모든 대상이 비정상이면 **그 AZ 노드는 트래픽을 받지 않게 되고**" — 이는 교차 영역 부하 분산 **비활성** 전제의 메커니즘(DNS에서 해당 노드 제외). ALB 기본값(교차 영역 활성, t2-1 §7에서 명시)에서는 그 AZ 노드가 트래픽을 계속 받아 **타 AZ의 정상 대상으로 라우팅**함. 결론("정상 대상에만 전달")은 유지되나 메커니즘 서술이 기본 설정과 불일치하고, "각 노드가 자기 AZ의 대상 상태를 추적" 서술이 t2-1 §7의 교차 영역 기본 활성 서술과 샤드 내 긴장. [근거: ALB는 cross-zone 활성 시 각 노드가 전체 AZ의 정상 대상으로 분산, 비활성 시에만 해당 AZ 노드가 DNS에서 제외되는 방식] | M | 중 | 원리 블록을 "교차 영역 비활성이면 해당 AZ 노드가 DNS에서 제외되고, 활성(ALB 기본)이면 노드가 타 AZ 정상 대상으로 우회 라우팅한다"로 재서술 | B | Y |
| DOC-SOA-107 | assets/content/soa/soa-t2-3.md#1-aws-backup--정책-기반-중앙-백업 (백업 규칙 행 "일정(cron/rate)") | AWS Backup 백업 규칙의 ScheduleExpression은 **cron 표현식**(+ 콘솔 빈도 프리셋)이며, rate 표현식 지원은 확인되지 않음(rate는 EventBridge 등 타 서비스 관례). [근거: Backup plan ScheduleExpression 문서 "A cron expression in UTC" — rate 언급 없음] | L | 중 | "(cron)"으로 축소 또는 "빈도 프리셋/cron"으로 수정 (2단 검증 권장) | A | Y |
| DOC-SOA-108 | assets/content/soa/soa-t2-4.md#4-s3-복제--crr-vs-srr ("복제로 거의 실시간 사본을 다른 리전에 유지") + §7-2 | 표준 S3 복제(CRR/SRR)는 **완료 시간 무보증**(대부분 15분 내이나 지연 가능). "15분 내 99.99% 복제" SLA는 유료 옵션 **RTC(S3 Replication Time Control)** 활성화 시에만 제공되는데 문서 전체에 RTC 언급이 없어, "거의 실시간" 단정이 엄격한 RPO 시나리오(예: 복제 완료 시간 보장 요구)에서 오개념 소지. 감사 체크리스트(CRR 전제조건·RTC) 중 RTC 항목 부재 | M | 높 | §4 특성 표에 "복제 완료 시간: 무보증(대부분 15분 내) / 15분 SLA 필요 시 RTC(유료)" 1행 추가하고 "거의 실시간" 표현 완화 | B | N |
| DOC-SOA-109 | assets/content/soa/soa-t2-4.md#6-리전-장애-대비--데이터-복제-수단-정리 (표 DynamoDB 행 "최종 일관성") | DynamoDB Global Tables를 "멀티 리전 활성·활성, **최종 일관성**"으로 단정. 고전적(SOA 시험 관례상 정답 방향)으로는 맞으나, 2025년 **멀티 리전 강한 일관성(MRSC)** 옵션이 GA되어 단정 서술이 구식화될 수 있음 — 신기능 시점·시험 반영 여부는 2단 검증 필요. [근거: Global Tables multi-Region strong consistency 옵션 GA(2025) 인지 — 기본은 여전히 비동기·최종 일관성] | L | 낮 | 2단 검증 후 "기본 최종 일관성(강한 일관성 옵션 별도)" 각주 추가 여부 결정 — 시험 대비 본문 기조는 유지 | B | Y |

### 검증 완료(발견 아님) — 주요 확인 사항

- t2-1: 조정 정책 4종 분류·타깃 추적 권장/경보 자동 생성·예측 조정 24시간 최소 이력·Forecast Only 모드·쿨다운=단순 조정 전용·수명주기 훅 상태 전이(Pending:Wait→Proceed)·CONTINUE/ABANDON·EC2 vs ELB 헬스체크 구분·ALB cross-zone 기본 활성(무과금)/NLB·GWLB 기본 비활성(활성 시 AZ 간 전송 요금)·NLB AZ당 고정 IP·GENEVE 6081 — 모두 공식과 일치.
- t2-2: RDS Multi-AZ 동기 복제·자동 페일오버 60~120초·스탠바이 읽기 불가·DNS 엔드포인트 유지·Multi-AZ DB 클러스터(읽기 가능 스탠바이 2) 예외 구분·읽기 복제본 비동기/수동 승격/교차 리전·NAT GW AZ 단위 리소스(자동 HA 단정 없음 — SAA 계열 함정 미해당)·Route 53 페일오버 TTL 지연 — 일치.
- t2-3: Vault Lock 거버넌스/컴플라이언스(루트 불가·유예 기간) 구분·EBS 증분+각 스냅샷 완전 복원 지점·중간 삭제 안전·RDS 자동 백업 1~35일/PITR/수동 스냅샷 무기한/새 인스턴스 복원·DLM 범위(EBS·AMI 한정)·S3 복제 버전 관리 "전제" 표현(SAA 계열 함정 미해당)·MFA Delete — 일치.
- t2-4: DR 4종 순서(B&R→Pilot Light→Warm Standby→Multi-Site)와 RTO/RPO/비용 축·Pilot Light vs Warm Standby 구분(백서 인용 정확)·배치 복제(기존 객체 소급)·교차 리전 읽기 복제본 수동 승격 사유·Aurora Global DB 1초 미만 지연 — 일치.
