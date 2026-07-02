# 2단 반박 검증 — V11 단종·개명 서비스 — 2026-07

독립 검증자 판정. 각 의심 항목이 오탐인지 반박(REFUTED = 문서 현행 유지 정당 / CONFIRMED = 문서 갱신 필요 / UNCERTAIN)을 AWS 공식 사실로 판정. 웹 조회 사용(각 항목 ≤2회). 각 항목 1회 판정 후 재론 없음.

## 조회 출처 (URL 목록)
- https://aws.amazon.com/blogs/storage/aws-snow-device-updates/ (Snow 디바이스 업데이트 — Snowcone/Snowmobile 단종)
- https://www.cnbc.com/2024/04/17/aws-stops-selling-snowmobile-truck-for-cloud-migrations.html (Snowmobile 판매 중단, 2024-03/04)
- https://www.datacenterdynamics.com/en/news/aws-to-discontinue-snowcone-edge-appliance-cuts-snowball-family-hardware-range-to-two-devices/ (Snowcone 단종, 2024-11-12)
- https://aws.amazon.com/blogs/storage/switch-your-file-share-access-from-amazon-fsx-file-gateway-to-amazon-fsx-for-windows-file-server/ (FSx File Gateway 신규 고객 중단)
- https://docs.aws.amazon.com/filegateway/latest/filefsxw/what-is-file-fsxw.html (FSx File Gateway 공식 문서 — 2024-10-28 신규 생성 불가)
- https://aws.amazon.com/about-aws/whats-new/2024/02/amazon-data-firehose-formerly-kinesis-data-firehose/ (Kinesis Data Firehose → Amazon Data Firehose 개명, 2024-02-09)
- https://aws.amazon.com/workspaces/applications/ (Amazon WorkSpaces Applications = formerly AppStream 2.0)
- https://docs.aws.amazon.com/appstream2/latest/developerguide/what-is-appstream.html (공식 문서 제목 "What Is Amazon WorkSpaces Applications?")
- https://aws.amazon.com/blogs/aws/ec2-classic-is-retiring-heres-how-to-prepare/ (EC2-Classic 은퇴 — 2022-08-15 목표, 2023-08 완료)
- https://aws.amazon.com/blogs/aws/new-general-purpose-amazon-ec2-m8i-and-m8i-flex-instances-are-now-available/ (M8i GA 2025-08-28, Intel Xeon 6)
- https://www.infoq.com/news/2025/08/ec2-r8i-intel-xeon-six/ (R8i GA 2025-08, Intel Xeon 6 Granite Rapids)
- https://aws.amazon.com/ec2/instance-types/x8i/ (X8i GA, Intel Xeon 6 custom)
- https://aws.amazon.com/blogs/aws/amazon-ec2-hpc8a-instances-powered-by-5th-gen-amd-epyc-processors-are-now-available/ (Hpc8a GA 2026-02, 5th Gen AMD EPYC)
- https://aws.amazon.com/ec2/instance-types/hpc8a/ (Hpc8a 제품 페이지)
- https://aws.amazon.com/blogs/aws/introducing-the-next-generation-of-amazon-sagemaker-the-center-for-all-your-data-analytics-and-ai/ (기존 SageMaker → SageMaker AI 개명, re:Invent 2024)
- https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html ("What is Amazon SageMaker AI?" 현행 문서)

## 판정

| ID | 판정 | 근거(3줄 이내, 시점 명기) |
|---|---|---|
| DOC-CLF-205 (1a) FSx File Gateway | CONFIRMED | 2024-10-28부터 신규 고객은 FSx File Gateway를 새로 생성할 수 없음(기존 고객만 유지). clf/t3-6이 Storage Gateway 유형에 무주석 나열 → 신규 중단 각주 필요. 발견자 의심 정확. |
| DOC-SAA-306 (1b) Snowmobile·Snowcone | CONFIRMED | Snowmobile 2024-03/04 판매 중단(AWS 웹사이트 제거), Snowcone 2024-11-12 주문 종료. saa-t3-9이 Snowcone→Snowball Edge→Snowmobile를 현행 라인업으로 제시 → 갱신 필요(현행은 Snowball Edge 중심). |
| DOC-CLF-302 (2) AppStream 2.0 개명 | REFUTED | 개명 실재: 공식 문서 제목이 "Amazon WorkSpaces Applications", 제품 페이지도 "formerly AppStream 2.0". clf/t3-8이 "AppStream 2.0(현재 Amazon WorkSpaces Applications)"로 기술한 것은 정확 → 문서 옳음, 오탐. |
| DOC-SOA-006 + DOC-SOA-316 (3) Firehose 개명 | CONFIRMED | 2024-02-09 AWS가 Kinesis Data Firehose → Amazon Data Firehose로 개명(콘솔·문서·서비스 페이지 반영; API·엔드포인트 불변). soa 문서(soa-t1-2, soa-t5-4)의 "Kinesis Data Firehose" 구명칭은 갱신 대상. |
| DOC-SAA-108 (4) EC2-Classic 폐지 | CONFIRMED | EC2-Classic 은퇴 2022-08-15 목표, 2023-08-23 완료(잔존 인스턴스 0). saa-t2-3의 CLB 사용 사례 "기존 EC2-Classic 환경만"은 폐지된 플랫폼을 현존처럼 지목 → 부정확, 갱신 대상. |
| DOC-SAA-205 (5) M8i·R8i·X8i·Hpc8a 실재 | REFUTED | 전부 실재·GA: M8i(2025-08-28 Intel Xeon 6), R8i(2025-08 Xeon 6 Granite Rapids), X8i(GA, custom Xeon 6), Hpc8a(2026-02 5th Gen AMD EPYC). saa-t3-3 예시 정확 → 문서 옳음, 오탐. |
| GUIDE-003 (6) SageMaker AI 표기 | CONFIRMED | re:Invent 2024에서 기존 Amazon SageMaker가 "Amazon SageMaker AI"로 개명(현행 공식 문서 "What is Amazon SageMaker AI?"). CLF-C02.json task 3.7이 "Amazon SageMaker"로 표기 → 현행 명칭 갱신 대상. 단, CLF-C02 시험 가이드 자체가 아직 구명칭이면 원문 인용은 별도 판단 필요(아래 주석). |

### 주석 (GUIDE-003)
- CLF-C02.json은 AWS 공식 CLF-C02 시험 가이드의 skills 문항을 그대로 옮긴 것으로 보임(line 240 "예: Amazon SageMaker, Amazon Lex, Amazon Kendra"). 서비스 자체는 "SageMaker AI"로 개명됐으나, **AWS 공식 CLF-C02 시험 가이드 원문이 아직 "Amazon SageMaker"로 되어 있다면** 이 JSON은 원문 충실 인용으로서 옳다(개명은 서비스 사실, 가이드 텍스트 현행성은 별개). 판정은 "서비스 현행 명칭 = SageMaker AS"라는 발견자 핵심 주장에 대해 CONFIRMED(개명 사실 확인)이나, 편집 조치 전 시험 가이드 원문 대조 권장.

### 요약
- CONFIRMED 5 (1a FSx File Gateway, 1b Snow, 3 Firehose, 4 EC2-Classic, 6 SageMaker AI)
- REFUTED 2 (2 AppStream 개명 실재→문서 옳음, 5 인스턴스 타입 전부 실재→문서 옳음)
- UNCERTAIN 0
- (항목 수 기준: DOC-CLF-205/DOC-SAA-306을 각각 세면 CONFIRMED 5·REFUTED 2·총 7 판정)
