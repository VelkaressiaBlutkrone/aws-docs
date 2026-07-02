# 2단 반박 검증 — V3 EBS·Aurora 스토리지 — 2026-07

독립 검증자가 발견자 의심 항목의 오탐 여부를 AWS 공식 문서로 적극 반박. 판정 3값(REFUTED=발견자 틀림·문서 정확 / CONFIRMED=문서 오류 실재 / UNCERTAIN). 이 클러스터는 수치 정확도가 핵심이라 현행 공식 한도를 직접 확인함.

## 조회 출처 (URL 목록)
- https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Performance.html (Aurora 스토리지 스케일링 — 공식 예제가 "256-TiB size limit" 명시)
- https://docs.aws.amazon.com/ebs/latest/userguide/general-purpose.html (gp2·gp3 성능 — 공식 수치 원문)
- https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/what-is-fsx.html (FSx for OpenZFS 클라이언트 OS)
- https://aws.amazon.com/about-aws/whats-new/2023/11/amazon-efs-archive-storage-class/ (EFS Archive 출시 공지, 2023-11)
- https://aws.amazon.com/efs/storage-classes/ (EFS 스토리지 클래스 — Standard·IA·Archive)

## 판정

| ID | 판정 | 근거(3줄 이내, 정확한 수치 명기) |
| --- | --- | --- |
| DOC-SAA-209 + DOC-SAA-406 (Aurora 256TiB) | **REFUTED** | 공식 Aurora 스토리지 문서가 호환 버전 상한을 명시적으로 "256-TiB size limit"으로 기술(`AuroraVolumeBytesLeftTotal`=140,515,818,864,640/TiB=256). 구엔진 하한은 별도지만 saa-t3-5는 "구버전 128TiB"로 병기함. 발견자의 "128TiB 상한·256TiB 미확인"은 현행과 불일치 → 문서 정확. (saa-t3-5는 §본문 64TiB→256TiB 표기가 있으나 이는 "구엔진 64TiB→현행 256TiB" 대비로 읽히며 별도 경미 사안) |
| DOC-SAA-210 (gp2/gp3 버스트 크레딧) | **CONFIRMED** | 공식: "gp3 volumes do not use burst performance. They can indefinitely sustain their full provisioned IOPS and throughput." 버스트 I/O 크레딧은 gp2 전용(1TiB 미만·3,000 IOPS 미만 볼륨). saa-t3-5 line 156 "범용 SSD(gp2/gp3)는 버스트 크레딧 방식"은 gp3를 잘못 포함 → 문서 오류 실재. |
| DOC-SOA-009 (gp2 16,000 IOPS 도달 용량) | **CONFIRMED** | 공식: "maximum of 16,000 IOPS ... reached at 5,334 GiB (3 × 5,334)"; "Volumes 5,334 GiB and larger are provisioned with 16,000 IOPS." soa-t1-5 line 126 "≈3,334 GB에서 16,000 IOPS 상한"은 오류(3,334×3=10,002으로 구 10,000 IOPS 시절 수치). 정정치=**5,334GiB** → 문서 오류 실재. |
| DOC-SAA-202 (gp3 80,000 IOPS·2,000 MiB/s·64TiB) | **REFUTED** | 공식: gp3 추가 프로비저닝 "up to a maximum of 80,000" IOPS(500 IOPS/GiB, 160GiB↑), 처리량 "up to a maximum of 2,000 MiB/s", 크기 "1 GiB to 64 TiB". saa-t3-2 line 111·112·110 수치 전부 현행 공식과 일치 → 문서 정확(시험 관례 16,000과의 괴리는 별개 사안, 문서 수치 자체는 옳음). |
| DOC-SAA-203 (EFS 스토리지 클래스 4분류) | **CONFIRMED** | EFS Archive 클래스가 2023-11 출시(공식 공지)되어 현행 EFS는 Standard·IA·**Archive** 라이프사이클 계층 포함. saa-t3-2 line 207~209는 Standard·Standard-IA·One Zone·One Zone-IA만 열거하고 Archive 누락 → 현행 불완전(문서 오류 실재, 경미도 L 타당). |
| DOC-SAA-204 (FSx OpenZFS 클라이언트 Linux·macOS) | **CONFIRMED** | 공식: "broadly accessible from **Linux, Windows, and macOS** compute instances ... using the industry-standard NFS protocol (v3, v4.0, v4.1, v4.2)." saa-t3-2 line 269 "리눅스·macOS"는 **Windows 누락** → 문서 오류 실재. (Windows도 NFS로 OpenZFS 접근 가능) |

## 요약
- **REFUTED 2건**: DOC-SAA-209/406(Aurora 256TiB 현행 정확), DOC-SAA-202(gp3 80,000 IOPS·2,000 MiB/s·64TiB 현행 정확). 발견자 의심이 오탐 — 2024~2025 상향이 실재하며 문서가 현행을 반영함.
- **CONFIRMED 4건**: DOC-SAA-210(gp3는 버스트 없음), DOC-SOA-009(정정 5,334GiB), DOC-SAA-203(EFS Archive 누락), DOC-SAA-204(FSx OpenZFS Windows 누락). 모두 문서 수정 필요.
