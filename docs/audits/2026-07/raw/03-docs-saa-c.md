# ③ 학습문서 사실성 감사 샤드 — 03-docs-saa-c (t3-1~t3-5) — 2026-07

## 요약 (3~5줄)

- 도메인 3 전반(스토리지·컴퓨팅·RDB) 5개 문서를 전문 정독. 전반적 품질은 높고 최신 사항(IBM Db2 엔진, Multi-AZ DB 클러스터 리더 읽기, EFA-only 모드, FSx Lustre Intelligent-Tiering 등)도 반영돼 있음.
- 발견 13건: H 2건, M 5건, L 6건. 사실의심 Y 8건.
- 핵심 이슈 2건(H): ① saa-t3-5가 gp3를 "버스트 크레딧 방식"으로 오기 — gp3는 버스트 크레딧이 없으며(기준 3,000 IOPS 고정) 같은 샤드의 saa-t3-2 설명과도 정면 모순(gp2→gp3 전환으로 버스트 의존 제거하는 기출 패턴에서 오답 유발). ② Aurora 최대 스토리지 "256TiB(2025년 상향)" — 공식 상한 128TiB 대비 근거 미확인, 사실 오류 가능성.
- 수치 계열(gp3 64TiB·80K IOPS, RDS Read Replica 5개 vs 15개)은 최근 변경·시험 관례 충돌 소지가 있어 2단 검증 대상으로 보수적으로 표기함.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| DOC-SAA-201 | assets/content/saa/saa-t3-1.md §5 접근 제어 | "요청은 아래 순서로 평가됩니다 ①BPA→②IAM→③버킷 정책→④ACL"로 순차 관문 모델을 제시. 실제 IAM 정책 평가는 순차가 아니라 아이덴티티 기반·리소스 기반 정책의 합집합 평가(동일 계정은 둘 중 하나의 Allow로 충분, 명시적 Deny 최우선)이고 BPA는 별도 가드레일. 순차 표기는 "IAM과 버킷 정책 모두 통과해야 한다"는 오개념을 심어 '같은 계정에서 IAM만 허용된 경우 접근 가능' 유형 문항에서 오답 유발 소지. 근거: IAM 공식 정책 평가 로직(교차 계정이 아니면 identity-based OR resource-based Allow) | M | 높 | "평가 순서"를 "겹쳐 작동하는 계층(BPA 가드레일 + IAM·버킷 정책 union + 명시적 Deny 우선)"으로 재서술 | B | Y |
| DOC-SAA-202 | assets/content/saa/saa-t3-2.md §3 SSD 볼륨 표 (+Q2·시험 포인트) | gp3 스펙을 1 GiB–64 TiB·최대 80,000 IOPS·2,000 MiB/s로 기재. 2024-12 상향 발표 기준으로는 현행 수치로 보이나, SAA-C03 문항 관례는 gp3=16,000 IOPS·1,000 MiB/s·16 TiB 상한을 전제로 gp3 vs io1/io2를 가르는 문항이 다수 — 상향 수치만 단독 제시하면 기출 스타일 문항(예: 20,000 IOPS 요구 → io1/io2 정답 설계)에서 오답 유발 가능. 근거: gp3 상향은 re:Invent 2024 발표 기억 기반이며 시험 출제 스냅샷(2022)은 16K 시절 | M | 중 | 현행 수치 유지 여부 2단 검증 후, 유지 시 "시험 문항은 구 상한(16,000 IOPS) 전제일 수 있음" 주석 병기 | B | Y |
| DOC-SAA-203 | assets/content/saa/saa-t3-2.md §6 EFS 스토리지 클래스 표 | Standard·Standard-IA·One Zone·One Zone-IA 4분류는 구 체계. 2023-11 EFS Archive 출시 후 현행 공식 분류는 스토리지 클래스 Standard·IA·Archive + 파일시스템 유형(Regional/One Zone). 시험 오답 직결성은 낮으나 최신 문서와 어긋남. 근거: EFS Archive 클래스 출시(2023 re:Invent)로 클래스 체계 재편 | L | 중 | 현행 분류로 갱신(또는 구/신 병기) 여부 2단 검증 | B | Y |
| DOC-SAA-204 | assets/content/saa/saa-t3-2.md §7 FSx for OpenZFS (+§8 비교표) | 클라이언트를 "Linux·macOS"로 한정 — 공식 문서는 Linux·Windows·macOS 모두 NFS로 접근 가능하다고 명시. Windows 누락. ONTAP vs OpenZFS를 클라이언트 OS로 가르는 문항에서 혼선 소지(낮음). 근거: FSx for OpenZFS 공식 페이지 "accessible from Linux, Windows, and macOS via NFS" | L | 중 | "Linux·Windows·macOS" 로 자구 보정 | A | Y |
| DOC-SAA-205 | assets/content/saa/saa-t3-3.md §2 인스턴스 패밀리 표 | "대표 최신 유형" 예시 중 Hpc8a·M8i·R8i·X8i 등 일부는 실재 여부 확인 불가(Hpc7g·Hpc7a·M8g·R8g까지는 확인됨). 시험 영향은 없으나 fact-checked 문서 신뢰성 문제. 근거: 2026-01 기준 지식에서 Hpc8a 공식 발표 확인 기억 없음 | L | 낮 | 예시 인스턴스명 실재 여부 일괄 재검증, 미확인 명칭은 확인된 세대로 교체 | B | Y |
| DOC-SAA-206 | assets/content/saa/saa-t3-3.md 자가 점검 Q4 정답 | r7g(메모리 최적화) 적합 워크로드를 "메모리 대비 CPU 비율이 높아야 하는 워크로드"로 서술 — 방향 반전. R 패밀리는 vCPU:메모리=1:8로 CPU 대비 메모리 비율이 높음. 같은 문서 §2 표("vCPU:메모리 비율 낮음")와 자기모순, 그대로 암기 시 패밀리 선택 문항 오답 소지 | M | 높 | "vCPU 대비 메모리 비율이 높아야 하는"으로 자구 반전 | A | N |
| DOC-SAA-207 | assets/content/saa/saa-t3-4.md §3 ECS 핵심 리소스 표 | Task를 "실행 후 종료되는 일회성 작업"으로 단정 — 바로 아래 Service 행("지정된 수의 Task를 지속 실행")과 상충. Task는 Task Definition의 실행 인스턴스일 뿐이며 일회성은 standalone task에만 해당 | L | 높 | "단독 실행 시 완료 후 종료(Service 하에서는 상주)" 등으로 한정 자구 수정 | A | N |
| DOC-SAA-208 | assets/content/saa/saa-t3-5.md §3·§4 표·§8 표·Q1 | "RDS 최대 5개" Read Replica 단정 반복. 현행 공식 문서는 MySQL·MariaDB·PostgreSQL 15개, Oracle·SQL Server 5개로 엔진별 상이 — blanket 5는 구식 서술로 신형 문항에서 오답 소지(단, 'Aurora 15 vs RDS 5' 구분 관례 문항도 잔존해 병기가 안전). 근거: RDS User Guide 읽기 복제본 문서가 오픈소스 엔진 15개로 갱신됨 | M | 중 | 2단 검증 후 "MySQL·MariaDB·PostgreSQL 15개, Oracle·SQL Server 5개(구 관례 5)"로 병기 | B | Y |
| DOC-SAA-209 | assets/content/saa/saa-t3-5.md §7 스토리지 특성·§8 비교표 | Aurora 스토리지 자동 확장 상한을 "256TiB(2025년 상향, 구버전 128TiB)"로 기재. Aurora 클러스터 볼륨 공식 상한은 128TiB이며 256TiB 상향 발표 근거를 확인할 수 없음(2025년 발표라면 지식 범위 내여야 하나 기억 없음 — Limitless Database와 혼동 가능성). 사실이 아니면 'Aurora 최대 128TB' 선택지 문항에서 오답 직결. 근거: Aurora 공식 문서·표준 교재의 클러스터 볼륨 상한 128TiB | H | 중 | 2단 검증 필수 — 미확인 시 128TiB로 환원 | B | Y |
| DOC-SAA-210 | assets/content/saa/saa-t3-5.md §6 원리 박스 | "범용 SSD(gp2/gp3)는 버스트 크레딧 방식으로 … 크레딧이 소진되면 기준 처리량으로 되돌아가"로 gp3까지 버스트 크레딧 모델로 서술 — gp3는 버스트 크레딧이 없고 기준 3,000 IOPS 고정+상위 프로비저닝 방식. 버스트 크레딧은 gp2만 해당. 같은 샤드 saa-t3-2 §3("gp3는 용량과 독립 설정, gp2는 용량 비례")과 문서 간 모순이며, 'gp2→gp3 전환으로 버스트 크레딧 의존 제거' 기출 패턴에서 오답 유발 가능. 근거: EBS 공식 — gp3 baseline 3,000 IOPS 크레딧 모델 없음, 버스트 버킷은 gp2 전용 | H | 높 | "범용 SSD 중 gp2는 버스트 크레딧 방식…(gp3는 기준 3,000 IOPS 고정)"으로 자구 정정 | A | Y |
| DOC-SAA-211 | assets/content/saa/saa-t3-5.md §5 RDS 백업 표 | "수냔샷(수동)" 오타 → "수동 스냅샷" | L | 높 | 오타 정정 | A | N |
| DOC-SAA-212 | assets/content/saa/saa-t3-5.md §1 원리 박스 | "OS 접근·SSH·직접 패치는 사용자 영역이 아니며, 수용 불가 시 EC2 직접 설치"로 대안을 EC2로 단정 — RDS Custom(Oracle·SQL Server, OS·DB 접근 허용) 누락. 'OS 접근이 필요하지만 관리형 이점 유지' 유형 문항에서 RDS Custom이 정답인 케이스가 있어 오개념 소지 | M | 중 | RDS Custom 존재를 한 줄 보강(표준 RDS는 OS 접근 불가 유지) | B | N |
| DOC-SAA-213 | assets/content/saa/saa-t3-5.md §9 원리 박스 | "Lambda는 함수 실행마다 새 프로세스(컨테이너)가 기동되고"는 과장 — 웜 실행 환경은 재사용되며, 연결 폭증의 원인은 '동시 실행 수만큼의 실행 환경'임. 같은 문서 Q5("동시 실행마다 별도 컨테이너")와 saa-t3-4 Q5(웜 재사용 설명)가 이미 올바른 서술이라 내부 불일치 | L | 높 | "동시 실행마다 별도 실행 환경이 기동되고"로 자구 정정 | A | N |

### 검토했으나 보고 제외(오류 아님 확인)

- t3-1: 11-nine 내구성 전 클래스 동일(One Zone-IA 포함), Intelligent-Tiering 최소 보관 기간 없음(2021-09 폐지 반영), 128KB 미만 모니터링 제외, 멀티파트 5GB 초과 필수·100MB 권장, 버킷 정책 20KB, 프리사인 URL 권한 상한, CRR 양측 버저닝 전제 — 모두 공식 문서와 일치.
- t3-2: io2 BE 256K IOPS·99.999% 내구성, HDD 부팅 불가, Multi-Attach io1/io2·Nitro·동일 AZ, 인스턴스 스토어 재부팅 유지/중지·종료 소실, EFS Windows 미지원 — 일치.
- t3-3: 배치 그룹 3종(클러스터 단일 AZ·파티션 AZ당 7파티션·분산 AZ당 7인스턴스), 전용 호스트·Spot 중지/최대절전 배치 그룹 불가, T 패밀리 클러스터 PG 제외, T3/T3a/T4g 기본 unlimited, 스팟 2분 경고·리밸런스 권장, 클러스터 PG 단일 플로우 10Gbps — 일치.
- t3-4: Lambda 15분·기본 동시성 1,000, Fargate 태스크별 격리, Batch 3계층·ECS/EKS/Fargate 실행 엔진 — 일치.
- t3-5: Multi-AZ 동기/Read Replica 비동기, 스탠바이 읽기 불가(+Multi-AZ DB 클러스터 예외 병기), Aurora 3AZ 6벌·15 Replica·30초 미만 페일오버, Global Database RPO~1초/RTO~1분, Backtrack MySQL 한정, RDS Proxy VPC 전용·비공개, 운영 중 원클릭 암호화 불가 — 일치.
