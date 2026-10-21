---
examGuideTaskId: saa-t3-2
certCode: SAA-C03
domain: 3
domainName: 고성능 아키텍처 설계
domainWeightPct: 24
title: 블록·파일 스토리지 — EBS 볼륨 타입·EFS·FSx 선택
coversTasks:
  - "3.1"
sources:
  - title: Amazon EBS — What is Amazon Elastic Block Store? (공식)
    url: https://docs.aws.amazon.com/ebs/latest/userguide/what-is-ebs.html
  - title: Amazon EBS 볼륨 타입 (공식)
    url: https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html
  - title: Amazon EFS — What is Amazon Elastic File System? (공식)
    url: https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html
  - title: Amazon EFS 수명 주기 관리 (공식)
    url: https://docs.aws.amazon.com/efs/latest/ug/lifecycle-management-efs.html
  - title: Amazon FSx for Windows File Server — What is? (공식)
    url: https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html
  - title: Amazon FSx for Lustre — What is? (공식)
    url: https://docs.aws.amazon.com/fsx/latest/LustreGuide/what-is.html
  - title: Amazon FSx for NetApp ONTAP — What is? (공식)
    url: https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/what-is-fsx-ontap.html
  - title: Amazon FSx for OpenZFS — What is? (공식)
    url: https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/what-is-fsx.html
  - title: Amazon S3 File Gateway — What is? (공식)
    url: https://docs.aws.amazon.com/filegateway/latest/files3/what-is-file-s3.html
  - title: Volume Gateway 작동 방식(캐시형·저장형) (공식)
    url: https://docs.aws.amazon.com/storagegateway/latest/vgw/StorageGatewayConcepts.html
  - title: Amazon FSx File Gateway 변경 이력(신규 고객 이용 불가) (공식)
    url: https://docs.aws.amazon.com/filegateway/latest/filefsxw/DocumentHistory.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
  - title: EBS 범용 SSD — gp3 성능·비율·버스트 미사용 (공식)
    url: https://docs.aws.amazon.com/ebs/latest/userguide/general-purpose.html
  - title: EBS 프로비저닝 IOPS SSD — io2 Block Express·Nitro 제약 (공식)
    url: https://docs.aws.amazon.com/ebs/latest/userguide/provisioned-iops.html
  - title: EBS 최적화 — 전용 대역폭·I/O 크기와 지연 (공식)
    url: https://docs.aws.amazon.com/ebs/latest/userguide/ebs-optimization.html
  - title: Elastic Volumes 수정 제약 — 축소 불가·24시간 4회 (공식)
    url: https://docs.aws.amazon.com/ebs/latest/userguide/ebs-modify-volume.html
  - title: Multi-Attach 볼륨의 NVMe 예약(스토리지 펜싱) (공식)
    url: https://docs.aws.amazon.com/ebs/latest/userguide/nvme-reservations.html
  - title: 인스턴스 스토어 데이터 지속성 — 소실 조건 표 (공식)
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-store-lifetime.html
  - title: EFS 성능 사양 — 처리량 모드 선택 기준 (공식)
    url: https://docs.aws.amazon.com/efs/latest/ug/performance.html
  - title: EFS 파일 시스템 처리량 관리 — 모드 변경 제약 (공식)
    url: https://docs.aws.amazon.com/efs/latest/ug/managing-throughput.html
  - title: FSx for Lustre S3 링크(DRA) — 최대 8개·충돌 미방지 (공식)
    url: https://docs.aws.amazon.com/fsx/latest/LustreGuide/create-dra-linked-data-repo.html
  - title: FSx for Lustre 백업 지원 범위 — 링크된 파일 시스템 미지원 (공식)
    url: https://docs.aws.amazon.com/fsx/latest/LustreGuide/using-backups-fsx.html
  - title: FSx for OpenZFS 성능 — 배포 유형·스토리지 클래스 변경 불가 (공식)
    url: https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/performance.html
  - title: FSx for OpenZFS Intelligent-Tiering 동작 (공식)
    url: https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/performance-intelligent-tiering.html
lastVerified: 2026-10-21
---

# 블록·파일 스토리지 — EBS 볼륨 타입·EFS·FSx 선택

> **커버하는 공식 Task** — SAA-C03 · 도메인 3 「고성능 아키텍처 설계」(24%) · **Task 3.1 스토리지 솔루션 선택** (`saa-t3-2`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 도메인 3은 시험 비중 24%(3위) — 스토리지 타입 선택이 단골 시나리오입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.1의 Skill 항목 기반)

- [ ] **스토리지 3대 유형 구분** — 블록(EBS·인스턴스 스토어)·파일(EFS·FSx)·객체(S3)를 요구사항으로 선택할 수 있다
- [ ] **EBS 볼륨 타입 6종 비교** — gp3·gp2·io2·io1·st1·sc1의 IOPS·처리량·용도·부팅 가능 여부를 구분할 수 있다
- [ ] **EBS 핵심 기능** — 스냅샷·암호화·Multi-Attach의 동작 방식과 제약을 설명할 수 있다
- [ ] **인스턴스 스토어 특성** — 휘발성(임시)·고성능·재시작 시 데이터 소실을 이해한다
- [ ] **EFS 선택 기준** — NFS·리눅스 전용·Multi-AZ 공유·자동 확장의 의미를 안다
- [ ] **FSx 4종 선택** — Windows File Server·Lustre·NetApp ONTAP·OpenZFS를 프로토콜·운영체제·용도로 구분할 수 있다

---

## 🎯 왜 중요한가

- 도메인 3(24%)은 SAA에서 "어떤 스토리지 서비스를 선택해야 하는가"를 가장 자주 묻는 도메인입니다.
- 시험은 "여러 EC2가 동시에 같은 파일에 접근", "고IOPS 데이터베이스", "HPC·ML 워크로드", "Windows 파일 공유" 같은 키워드를 주고 서비스를 고르게 합니다.
- 블록·파일·객체 구분, EBS 볼륨 타입 수치, EFS vs FSx 선택 기준 — 이 세 축이 이 Topic의 전부입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **NFS** | Network File System | 네트워크를 통해 파일시스템을 마운트하는 표준 프로토콜 — 리눅스 서버끼리 공유 드라이브처럼 쓰는 방식 |
| **SMB** | Server Message Block | Windows 파일 공유 표준 프로토콜 — 네트워크 드라이브 연결(\\server\share)에 사용 |
| **IOPS** | Input/Output Operations Per Second | 스토리지가 1초에 처리할 수 있는 읽기·쓰기 횟수 — 데이터베이스처럼 작은 블록을 자주 읽고 쓸 때 핵심 지표 |
| **POSIX** | Portable Operating System Interface | 파일 권한(chmod)·링크·프로세스 등 Unix 계열 OS 동작 표준 — POSIX 호환 파일시스템은 리눅스 앱이 수정 없이 동작 |
| **프로비저닝** | Provisioning | 사전에 용량·성능을 명시적으로 지정하고 예약하는 방식 — 요청 즉시 그 용량이 보장됨 |
| **KMS** | AWS Key Management Service | AWS에서 암호화 키를 생성·관리하는 서비스 — EBS 암호화가 내부적으로 사용하는 키 저장소 |
| **Active Directory** | Active Directory (AD) | Microsoft의 네트워크 사용자·컴퓨터 인증 디렉터리 서비스 — 기업 Windows 환경에서 로그인·권한 관리 담당 |
| **Nitro** | AWS Nitro System | AWS가 자체 개발한 하이퍼바이저·오프로드 칩 기반 인스턴스 플랫폼 — EBS Multi-Attach가 지원되는 인스턴스 조건 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) 스토리지 3대 유형 {#storage-types}

| 유형 | 대표 서비스 | 접근 방식 | 대표 사용 사례 |
|---|---|---|---|
| **블록** | EBS, 인스턴스 스토어 | EC2 디스크처럼 마운트 | OS 부팅 볼륨, DB 데이터 파일 |
| **파일** | EFS, FSx | NFS·SMB로 네트워크 마운트 | 공유 홈 디렉터리, HPC 데이터셋 |
| **객체** | S3 | HTTP API(GET·PUT) | 정적 파일, 백업, 데이터 레이크 |

> 블록은 "디스크처럼 쓴다", 파일은 "네트워크 드라이브처럼 쓴다", 객체는 "API로 올리고 내려받는다"로 구분하면 됩니다.

> 🧠 원리: 왜 스토리지를 블록·파일·객체 세 유형으로 나눌까요?
> 각 유형은 OS가 데이터를 다루는 단위가 다릅니다. 블록은 OS 커널이 섹터 단위로 직접 읽고 써야 하는 로우 디스크가 필요한 경우(DB가 직접 블록을 관리), 파일은 디렉터리 계층과 잠금이 필요한 경우, 객체는 고유 식별자(키)로 찾으면 되는 경우에 적합합니다.
> 세 계층이 각각 다른 접근 인터페이스를 노출하기 때문에, 애플리케이션이 요구하는 접근 방식을 먼저 파악하면 서비스 선택이 자연스럽게 좁혀집니다.
> 예를 들어 데이터베이스 엔진은 블록 수준 직접 접근이 필요하고, 웹 서버 공유 설정 파일은 여러 프로세스가 파일 단위로 읽어야 하며, 정적 미디어는 HTTP로 꺼내면 충분하므로 각각 블록·파일·객체 유형이 선택됩니다.

### 2) EBS(Amazon Elastic Block Store)란 {#ebs-basics}

공식 정의: **"Amazon EC2 인스턴스에 연결해 사용하는 확장 가능한 고성능 블록 스토리지."** EC2에 연결하면 로컬 하드 드라이브처럼 파일 저장·애플리케이션 설치에 사용할 수 있습니다.

핵심 특성:
- **단일 AZ 내** 자동 복제 — 단일 하드웨어 장애로부터 보호
- EC2 인스턴스와 **같은 AZ**에 위치해야 연결 가능
- 기본적으로 **단일 인스턴스** 연결 (Multi-Attach는 io1/io2에서만 지원)
- 인스턴스를 중지해도 데이터 유지 (인스턴스 스토어와의 핵심 차이)

> 🧠 원리: 왜 EBS 볼륨은 같은 AZ에 있어야만 EC2에 연결할 수 있을까요?
> EBS 볼륨은 물리적으로 같은 데이터센터(AZ) 내 스토리지 서버에 위치하며, EC2와 EBS 사이의 데이터 경로는 AWS 내부 고속 네트워크를 사용합니다.
> AZ를 넘어 연결하려면 이 내부 경로 대신 리전 간 네트워크를 거쳐야 해 지연시간이 크게 늘어나므로, AWS는 동일 AZ 내 연결만 허용해 일관된 저지연 성능을 유지합니다.
> 이 설계 덕분에 EBS는 블록 스토리지 성능을 예측 가능하게 제공하지만, AZ 간 이동이 필요할 때는 스냅샷을 통한 복사가 유일한 경로가 됩니다.

### 3) EBS 볼륨 타입 비교 (★ 시험 핵심) {#ebs-volume-types}

#### SSD 볼륨

| 항목 | gp3 | gp2 | io2 Block Express | io1 |
|---|---|---|---|---|
| **분류** | 범용 SSD | 범용 SSD | 프로비저닝 IOPS SSD | 프로비저닝 IOPS SSD |
| **용량** | 1 GiB–64 TiB | 1 GiB–16 TiB | 4 GiB–64 TiB | 4 GiB–16 TiB |
| **최대 IOPS** | 80,000 | 16,000 | 256,000 | 64,000 |
| **최대 처리량** | 2,000 MiB/s | 250 MiB/s | 4,000 MiB/s | 1,000 MiB/s |
| **Multi-Attach** | 미지원 | 미지원 | 지원 | 지원 |
| **부팅 볼륨** | 가능 | 가능 | 가능 | 가능 |
| **내구성** | 99.8–99.9% | 99.8–99.9% | 99.999% | 99.8–99.9% |
| **주요 사용 사례** | 일반 목적 **기본 추천** | 레거시 일반 목적 | 미션 크리티컬 DB, 초고IOPS | 고IOPS DB |

> gp3는 IOPS와 처리량을 **용량과 독립적으로** 설정할 수 있습니다. gp2는 IOPS가 용량에 비례(GB당 3 IOPS)하여 용량을 늘려야만 IOPS가 늘어납니다. 동일 성능이면 gp3가 더 저렴합니다.

#### HDD 볼륨

| 항목 | st1 (처리량 최적화 HDD) | sc1 (콜드 HDD) |
|---|---|---|
| **용량** | 125 GiB–16 TiB | 125 GiB–16 TiB |
| **최대 IOPS** | 500 (1 MiB I/O 기준) | 250 (1 MiB I/O 기준) |
| **최대 처리량** | 500 MiB/s | 250 MiB/s |
| **Multi-Attach** | 미지원 | 미지원 |
| **부팅 볼륨** | 불가 | 불가 |
| **주요 사용 사례** | 빅데이터·로그·데이터 웨어하우스 | 자주 접근하지 않는 콜드 데이터, 저비용 |

> HDD 볼륨은 **부팅 볼륨으로 사용할 수 없습니다.** IOPS보다 처리량(순차 읽기·쓰기)이 중요한 대용량 스트리밍 워크로드에 적합합니다.

> 🧠 원리: 왜 HDD 볼륨은 SSD에 비해 IOPS 한계가 낮을까요?
> HDD는 데이터를 읽으려면 자기 디스크가 물리적으로 회전해 헤드가 해당 섹터 위에 올 때까지 기다려야 합니다. 이 회전 대기(rotational latency)가 수 밀리초 단위로 발생하기 때문에 초당 처리할 수 있는 I/O 횟수에 물리적 상한이 생깁니다.
> SSD는 전기 신호로 셀에 직접 접근하므로 이 대기가 없고, 작은 요청을 빠르게 반복할수록(랜덤 I/O) 차이가 극대화됩니다.
> 반면 HDD는 헤드를 한 번 위치시킨 후 연속 구간을 쭉 읽는 순차 처리(처리량 중심)에서는 비용 대비 효율이 높아, st1·sc1 같은 스트리밍 전용 볼륨으로 포지셔닝됩니다.

**EBS 성능을 결정하는 조건 (★ 시험 수치)**

볼륨 타입만으로 성능이 정해지지 않습니다 — **인스턴스 쪽 한계**와 **I/O 크기**가 함께 걸립니다.

| 항목 | gp3 | io2 Block Express |
|---|---|---|
| 기준 성능(스토리지 가격 포함) | **3,000 IOPS · 125 MiB/s** | — |
| 최대 IOPS | **80,000** — **GiB당 500 IOPS** 비율, **160 GiB 이상**에서 달성(500 × 160) | **256,000** — IOPS:GiB **1,000:1**, **256 GiB 이상**에서 달성 |
| 최대 처리량 | **2,000 MiB/s** — **프로비저닝 IOPS당 0.25 MiB/s**, 8,000 IOPS 이상 + 16 GiB 이상 | **4,000 MiB/s** — IOPS당 0.256 MiB/s, 16,000 IOPS 이상 |
| 용량 | — | 최대 **64 TiB** |
| 버스트 | ⚠️ **쓰지 않습니다** — 프로비저닝한 IOPS·처리량을 **무한히 지속** | 쓰지 않음 |

- ⚠️ **io2의 256,000 IOPS는 Nitro 기반 인스턴스에서만 달성됩니다.** 그 외 인스턴스는 **최대 32,000 IOPS**입니다(볼륨은 64,000 IOPS까지 **연결**할 수 있지만 **달성**은 32,000까지라는 점이 함정입니다).
- **I/O 크기 기준** — 인스턴스 타입 표의 최대 IOPS는 **16 KiB I/O 기준**이고, 최대 처리량은 **128 KiB I/O 스트리밍 읽기 기준**입니다. I/O 크기가 커지면 지연도 함께 커집니다.
- **EBS 최적화 인스턴스**는 EBS I/O 전용 대역폭을 따로 제공해 인스턴스의 다른 트래픽과의 경합을 줄입니다. ⚠️ **인스턴스의 EBS 성능은 "인스턴스 성능 한계"와 "연결된 볼륨 성능 합계" 중 더 작은 쪽**에 묶입니다 — 공식 예시는 `r6i.16xlarge`에서 80,000 IOPS를 내려면 16,000 IOPS gp3 볼륨 **5개**가 필요하다는 것입니다.
- **지연·일관성 설계 목표** — io2 Block Express는 16 KiB I/O에서 **평균 500마이크로초 미만**, io1·io2는 프로비저닝 IOPS의 **90% 이상을 연간 99.9%**, gp2·gp3는 **90% 이상을 연간 99%** 제공하도록 설계됩니다.

> Outposts에서는 gp3가 최대 16 TiB·16,000 IOPS·1,000 MiB/s로 제한됩니다. 또 일부 SDK 문서(ECS 관리형 볼륨 등)는 gp3 IOPS 범위를 `3,000–16,000`으로 적는데, **EBS 사용자 가이드의 80,000이 볼륨 자체의 상한**입니다 — 서비스별 관리형 볼륨의 제약과 구분하세요.

---

### 4) EBS 스냅샷·암호화·Multi-Attach {#ebs-features}

**스냅샷(Snapshot):**
- EBS 볼륨의 **특정 시점(point-in-time) 백업** — S3에 저장(사용자가 직접 S3를 관리하지 않음)
- 스냅샷에서 새 볼륨을 즉시 복원하거나, 다른 AZ·리전으로 복사해 마이그레이션 가능
- **증분(incremental)** — 최초 스냅샷 이후에는 변경된 블록만 저장

**암호화(Encryption):**
- EBS 암호화 활성화 시 볼륨 데이터·스냅샷·전송 중 데이터 모두 암호화
- AWS KMS 키를 사용하며, 암호화·복호화는 **EC2 인스턴스를 호스팅하는 서버**에서 처리
- 암호화된 볼륨에서 만든 스냅샷과, 그 스냅샷에서 복원한 볼륨도 자동으로 암호화

**Multi-Attach:**
- **io1·io2 볼륨에서만** 지원 — 동일 AZ 내 여러 EC2 Nitro 인스턴스에 동시 연결 가능
- 클러스터 데이터베이스·고가용성 애플리케이션에서 사용
- 파일 시스템 레벨의 동시성 제어는 애플리케이션이 직접 담당해야 합니다 (EFS처럼 자동 관리되지 않음)

> 🧠 원리: 왜 EBS 암호화·복호화는 EC2 인스턴스가 아닌 호스트 서버에서 처리될까요?
> EC2 인스턴스 위에서 암호화를 처리하면 인스턴스 CPU를 사용해야 하고, 게스트 OS나 그 위에서 실행되는 프로세스가 키에 접근할 수 있는 경로가 생길 수 있습니다.
> Nitro 기반 호스트는 전용 하드웨어 오프로드 칩을 통해 데이터가 네트워크를 떠나기 전(호스트 → EBS 스토리지 서버 전송 중)에 투명하게 암호화하므로, 인스턴스에서 실행되는 애플리케이션 코드 경로가 암호화 처리에 관여하지 않습니다.
> 이 구조가 "암호화된 볼륨에서 만든 스냅샷도 자동으로 암호화"되는 일관성의 기반이 됩니다.

**Multi-Attach 보강 — 펜싱은 NVMe 예약으로 합니다**

- `io1`·`io2` 볼륨을 **같은 AZ의 최대 16개 Nitro 인스턴스**에 **동시 연결**할 수 있습니다.
- 동시 쓰기를 조율하는 수단이 **NVMe 예약(reservations)** 입니다 — **업계 표준 스토리지 펜싱 프로토콜** 집합으로, 여러 인스턴스의 공유 볼륨 접근을 제어·조율하는 예약을 만들고 관리합니다. 공유 스토리지 애플리케이션이 데이터 일관성을 지키는 데 씁니다.
- ⚠️ 그래서 "애플리케이션이 직접 담당한다"는 말은 **맨손으로 하라는 뜻이 아닙니다** — 클러스터 인식 파일 시스템이나 NVMe 예약 같은 **펜싱 수단**을 써야 한다는 뜻입니다. Multi-Attach는 **일반 파일 시스템을 여러 인스턴스가 그대로 공유하는 용도가 아닙니다.**
- Multi-Attach 활성 볼륨은 **`io1` ↔ `io2` 양방향 유형 변경만** 지원하고(연결된 상태에서도 가능), 변경 시 **NVMe 예약 활성 상태가 대상 유형으로 이어집니다.** 다른 유형 변경은 지원되지 않습니다.

**Elastic Volumes — 운영 중 변경의 규칙 (★ 시험 포인트)**

현행 세대 인스턴스에 연결된 볼륨은 **중지·분리 없이** 크기·타입·IOPS를 바꿀 수 있습니다(이전 세대는 분리·재연결이나 중지·재시작이 필요할 수 있습니다).

| 규칙 | 내용 |
|---|---|
| **크기 축소** | ⚠️ **불가.** 늘리는 것만 됩니다. 줄여야 하면 **작은 볼륨을 새로 만들어 `rsync`·`robocopy` 로 데이터를 옮깁니다** |
| **변경 횟수** | **롤링 24시간 내 최대 4회.** 볼륨이 `in-use`·`available` 이고 이전 수정이 모두 `completed` 여야 합니다 |
| **순서** | 한 수정이 `completed` 가 되기 전에는 같은 볼륨의 다음 수정을 시작할 수 없습니다 |
| **취소** | 제출한 수정 요청은 **취소할 수 없습니다** |
| **크기 상한** | 새 크기가 **파일 시스템·파티셔닝 스킴이 지원하는 용량**을 넘을 수 없습니다 |
| **타입 변경 시 한계** | 타입을 바꾸지 않으면 **현재 타입**의 한계 내, 바꾸면 **대상 타입**의 한계 내에서만 |
| 루트 볼륨 제약 | `io1`·`io2`·`gp2`·`gp3`·`standard` 루트 볼륨은 **`st1`·`sc1` 으로 변경 불가**(분리된 상태여도) |

- ⚠️ **크기를 늘린 뒤에는 파일 시스템 크기를 확장**해야 새 용량을 쓸 수 있습니다. 볼륨만 키우고 끝내면 OS가 보는 용량은 그대로입니다 — 시험에서 "볼륨을 늘렸는데 공간이 안 늘어난다"는 시나리오의 답입니다.

---

### 5) 인스턴스 스토어(임시 블록 스토리지) {#instance-store}

인스턴스 스토어는 EC2 인스턴스에 **물리적으로 부착된** 임시 블록 스토리지입니다.

| 특성 | 설명 |
|---|---|
| **휘발성** | 인스턴스 중지·종료·하드웨어 장애 시 데이터 소실 |
| **성능** | 네트워크를 거치지 않아 매우 낮은 지연시간 |
| **비용** | 인스턴스 요금에 포함 (별도 요금 없음) |
| **용도** | 임시 파일, 버퍼, 캐시, 스크래치 데이터 |

> 인스턴스 재부팅(reboot)으로는 데이터가 유지됩니다. 중지(stop) 또는 종료(terminate)하면 소실됩니다.

> 🧠 원리: 왜 인스턴스 스토어 데이터는 인스턴스를 중지하면 소실될까요?
> 인스턴스 스토어는 EC2 호스트 서버에 물리적으로 부착된 디스크입니다. 인스턴스를 중지하면 AWS는 해당 인스턴스를 다시 시작할 때 다른 물리 호스트에 배치할 수 있으며, 이 경우 원래 호스트의 로컬 디스크에는 더 이상 접근할 수 없습니다.
> 재부팅은 같은 물리 호스트에서 OS만 재시작하므로 로컬 디스크 연결이 유지되지만, 중지·종료는 호스트 배치가 고정되지 않아 데이터 접근이 보장되지 않습니다.
> EBS가 네트워크를 통해 독립된 스토리지 서버에 데이터를 저장하는 방식과 달리, 인스턴스 스토어는 호스트 물리 장치에 묶여 있다는 점이 이 차이의 근본 원인입니다.

**인스턴스 스토어 데이터가 사라지는 조건 — 공식 표 전체 (★ 시험 필출)**

"중지·종료"만 외우면 틀립니다. 공식 데이터 지속성 표는 다음과 같습니다.

| 이벤트 | 데이터 |
|---|---|
| **재부팅**(인스턴스·시스템·OS 재시작) | **유지** |
| **중지** | 유지되지 않음 |
| **최대 절전(hibernate)** | 유지되지 않음 |
| **종료** | 유지되지 않음 |
| **인스턴스 유형 변경** | 유지되지 않음 |
| **인스턴스 은퇴(retirement)** | 유지되지 않음 |
| OS에서 셧다운 시작 | 유지되지 않음 |
| EBS 기반 AMI 생성 | 생성된 AMI에 유지되지 않음 |
| S3 기반 AMI 생성(Linux) | AMI 번들에는 유지됨 |

- 인스턴스 스토어 볼륨은 **시작 시에만 연결**되고 이후 연결할 수 없으며, 한 인스턴스에서 분리해 다른 인스턴스에 붙일 수도 없습니다. 인스턴스 **수명 동안만** 존재하도록 설계돼 있어, 그 이상 지속되게 **구성할 방법이 없습니다.**
- ⚠️ 중지·최대 절전·종료 시 인스턴스 스토어의 **모든 블록이 암호학적으로 소거(cryptographically erased)** 됩니다.
- ⚠️ **EBS 루트 볼륨 인스턴스에 붙은 인스턴스 스토어 볼륨도 마찬가지**입니다 — 루트가 EBS라서 안전하다고 오해하기 쉬운 지점입니다.
- **인스턴스 은퇴**는 AWS가 기반 호스트의 복구 불가 장애를 감지했을 때 예정됩니다 — 루트 볼륨 유형에 따라 **EBS 루트는 중지**, **인스턴스 스토어 루트는 종료**로 예정되고, 어느 쪽이든 인스턴스 스토어 데이터는 사라집니다.
- 남겨야 하는 데이터는 미리 **EBS·S3·EFS** 같은 영구 스토리지로 복사해 두는 것이 유일한 방법입니다.

---

### 6) Amazon EFS(Elastic File System) {#efs}

공식 정의: **"서버리스·완전 관리형 NFS 파일 스토리지 — 프로비저닝 없이 페타바이트까지 자동 확장."**

핵심 특성:
- **NFSv4.1·NFSv4.0** 프로토콜 — Linux 기반 인스턴스에서 마운트 (Windows EC2 미지원)
- **리전(Regional) 파일 시스템**: 여러 AZ에 데이터를 중복 저장, 여러 AZ의 EC2·ECS·EKS·Lambda에서 동시 마운트
- 스토리지 용량 사전 지정 불필요 — 파일 추가·삭제에 따라 자동 증감

**성능 모드:**

| 모드 | 설명 | 권장 대상 |
|---|---|---|
| **General Purpose** (기본) | 지연시간 민감 워크로드에 최적 | 웹 서비스, 콘텐츠 관리, 홈 디렉터리 |
| **Max I/O** | **이전 세대** 성능 모드. 고도 병렬 워크로드용이지만 작업당 지연시간이 General Purpose보다 큼. **One Zone 파일 시스템·Elastic 처리량과 함께 쓸 수 없음** | AWS는 **모든 파일 시스템에 General Purpose를 권장**합니다(신규 설계에서 Max I/O를 고르지 않음) |

**처리량 모드:**

| 모드 | 설명 |
|---|---|
| **Elastic** (권장) | 워크로드 활동에 따라 처리량을 자동 확장·축소 |
| **Bursting** | 스토리지 크기에 비례한 기본 처리량 + 버스트 크레딧 |
| **Provisioned** | 스토리지 크기와 무관하게 처리량을 직접 지정 |

**스토리지 클래스:**

| 클래스 | 설명 |
|---|---|
| **Standard** | 자주 접근하는 데이터, 다중 AZ |
| **Standard-IA** | 자주 접근하지 않는 데이터, 다중 AZ, 저비용 |
| **Archive** | 1년에 몇 번 이하로 접근하는 장기 보관 파일, 다중 AZ, 최저 비용 계층 |
| **One Zone** | 단일 AZ, 더 저렴 |
| **One Zone-IA** | 단일 AZ + IA |

> 🧠 원리: 왜 EFS는 용량을 미리 지정하지 않아도 페타바이트까지 확장될까요?
> EFS는 AWS가 완전 관리하는 분산 스토리지 인프라에 파일 데이터를 저장하며, 사용자가 마운트하는 파일시스템은 그 인프라의 논리적 뷰입니다. 물리 용량 할당은 AWS가 내부적으로 처리하므로 사용자에게 노출되지 않습니다.
> EBS처럼 볼륨 크기를 미리 예약하지 않아도 되는 이유는, 파일이 추가될 때마다 AWS가 스토리지를 자동으로 확보하는 서버리스 모델이기 때문입니다.
> 이 구조는 편리하지만 스토리지 비용이 사용량에 비례해 증가하므로, 접근 빈도가 낮은 파일을 IA 클래스로 자동 전환하는 수명 주기 정책이 비용 관리 수단이 됩니다.

**EFS 처리량 모드 선택 기준 (★ 시험 포인트)**

모드 이름만으로는 고를 수 없습니다 — 공식 선택 기준은 **평균/피크 비율**입니다.

| 모드 | 언제 고르는가 |
|---|---|
| **Elastic**(기본·권장) | 스파이크가 있거나 예측이 어려워 성능 요구를 미리 가늠하기 힘들 때, 또는 애플리케이션의 **평균/피크 처리량 비율이 5% 이하**일 때. 성능이 워크로드 활동에 맞춰 자동으로 오르내립니다 |
| **Provisioned** | 워크로드의 성능 요구를 **이미 알 때**, 또는 **평균/피크 비율이 5% 이상**일 때. 파일 시스템 크기·버스트 크레딧과 **무관하게** 처리량을 지정합니다 |
| **Bursting** | 처리량이 **파일 시스템 저장량에 따라 확장**되길 원할 때. **하루 최대 12시간** 더 높은 수준으로 버스트합니다 |

- ⚠️ Bursting을 쓰다가 **허용 처리량의 80%를 넘게 쓰거나 버스트 크레딧을 다 소진했다면**, 공식 권고는 **Elastic 또는 Provisioned로 전환**입니다. 이것이 "처리량 제약(throughput-constrained)" 상태의 판단 기준입니다.
- 모드 변경 자체는 **애플리케이션 다운타임을 일으키지 않습니다.** 다만 ⚠️ **Provisioned로 바꾸거나 프로비저닝 양을 늘리면 24시간 이상 기다려야** 다시 모드를 바꾸거나 양을 줄일 수 있습니다.
- Elastic도 자동 확장을 믿고 방치하지 말고 **CloudWatch `MeteredIOBytes` 모니터링과 사용 경보**를 두는 것이 공식 운영 권고입니다.

---

### 7) Amazon FSx 패밀리 {#fsx-family}

FSx는 AWS가 완전 관리형으로 제공하는 서드파티·업계 표준 파일 시스템입니다.

#### FSx for Windows File Server

| 항목 | 내용 |
|---|---|
| **프로토콜** | SMB(버전 2.0–3.1.1) |
| **인증** | Microsoft Active Directory 통합(필수) |
| **운영체제** | Windows·Linux 클라이언트 모두 접근 가능 (Windows 네이티브) |
| **배포 옵션** | Single-AZ, Multi-AZ(스탠바이 파일 서버) |
| **스토리지** | SSD·HDD 선택 |
| **사용 사례** | 엔터프라이즈 Windows 앱, 홈 디렉터리, 콘텐츠 관리, 미디어 처리 |

#### FSx for Lustre

| 항목 | 내용 |
|---|---|
| **프로토콜** | Lustre(POSIX 호환, Linux 전용) |
| **성능(스토리지 클래스별)** | **SSD** = 전체 데이터에 *일관된* 서브밀리초 지연 + 최대 TBps / **Intelligent-Tiering** = **자주 접근하는 데이터**에 서브밀리초(선택적 SSD 읽기 캐시), 전체 데이터에 일관된 저지연은 아님 / **HDD** = 일관된 **한 자릿수 ms** + 최대 수십 GBps |
| **S3 통합** | S3 버킷을 데이터 리포지토리로 연결 — S3 객체를 파일처럼 투명하게 노출 |
| **배포 옵션** | Scratch(임시·단기), Persistent(장기·복제) |
| **스토리지** | SSD, Intelligent-Tiering, HDD |
| **사용 사례** | HPC, 머신러닝/딥러닝, 비디오 처리, 금융 모델링 |

#### FSx for NetApp ONTAP

- NetApp ONTAP 파일 시스템을 AWS에서 완전 관리형으로 제공
- **NFS·SMB·iSCSI** 프로토콜을 동시 지원 → Linux·Windows·macOS 클라이언트 통합
- Multi-AZ 배포 지원, 자동 스토리지 계층화, 스냅샷·복제 기능
- 온프레미스 NetApp 환경을 AWS로 리프트앤시프트하는 시나리오에 적합

#### FSx for OpenZFS

- OpenZFS 파일 시스템을 AWS에서 완전 관리형으로 제공
- **NFS** 프로토콜, Linux·Windows·macOS 클라이언트
- 최대 2,000,000 IOPS, 수백 마이크로초 지연시간
- ZFS 스냅샷·복제 기능, 온프레미스 ZFS 워크로드 마이그레이션에 적합

> 🧠 원리: 왜 FSx는 단일 서비스가 아니라 여러 파일 시스템 엔진을 별도 제품으로 제공할까요?
> 각 파일시스템(Windows File Server·Lustre·ONTAP·OpenZFS)은 독자적인 프로토콜·잠금 의미론·성능 특성을 가지며, 기존 온프레미스 워크로드는 특정 파일시스템 API에 의존하도록 작성된 경우가 많습니다.
> 하나의 범용 파일시스템으로 통합하면 어느 한쪽의 동작이 달라져 마이그레이션 시 애플리케이션 수정이 불가피해집니다. FSx가 각 엔진을 그대로 관리형으로 제공하는 이유는 "리프트앤시프트" — 코드 변경 없이 온프레미스 파일시스템을 AWS로 옮기는 것 — 을 가능하게 하기 위함입니다.
> 결과적으로 FSx 제품 선택은 "어떤 파일시스템을 현재 쓰고 있는가"에서 시작하며, 프로토콜·OS·워크로드 특성이 제품을 결정합니다.

**FSx 보조 특성 — 시험에 나오는 제약들**

**FSx for Lustre ↔ S3 링크(DRA)**

- 파일 시스템 디렉터리와 S3 버킷·프리픽스의 연결을 **DRA(data repository association)** 라 부릅니다. 파일 시스템 생성 시 또는 **이후 언제든** 만들 수 있습니다.
- 파일 시스템당 **최대 8개 DRA**. 요청은 8개까지 큐에 들어가지만 **한 번에 하나만 처리**되고, 각 DRA는 **고유한 디렉터리와 고유한 S3 버킷·프리픽스**를 가져야 합니다.
- 자동 가져오기 전용 · 자동 내보내기 전용 · **양방향** 중에서 고를 수 있습니다. 양방향이면 S3 변경이 파일 시스템으로 자동 반영되고, 파일 변경이 S3로 비동기 내보내기됩니다.
- ⚠️ **같은 파일을 파일 시스템과 S3 양쪽에서 수정하면 애플리케이션 수준 조율이 필요합니다** — FSx for Lustre는 **여러 위치의 충돌 쓰기를 막지 않습니다.**
- ⚠️ **백업은 S3 데이터 리포지토리에 링크되지 않은 persistent 파일 시스템에서만 지원**됩니다. **scratch는 미지원**(임시·단기 처리용), **S3에 링크된 파일 시스템도 미지원**입니다 — S3가 주 데이터 리포지토리이고 파일 시스템이 항상 전체 데이터셋을 담지는 않기 때문입니다.
- DRA·자동 내보내기·다중 데이터 리포지토리는 **FSx for Lustre 2.10 또는 `Scratch 1` 파일 시스템에서는 쓸 수 없습니다.**

**FSx for OpenZFS — 생성 후 바꿀 수 없는 것**

- ⚠️ **배포 유형과 스토리지 클래스는 파일 시스템 생성 후 변경할 수 없습니다.** 바꾸려면 데이터를 옮겨야 합니다.
  - **백업에서 복원** — Single-AZ 1 → Single-AZ 2, Single-AZ(비HA) → Single-AZ(HA)는 가능합니다. ⚠️ 그러나 **Single-AZ 백업으로 Multi-AZ를 만들 수 없고, 복원으로 스토리지 클래스를 바꿀 수도 없습니다.**
  - **온디맨드 복제** — 배포 유형·스토리지 클래스가 다른 파일 시스템 사이에서 데이터를 동기화할 수 있습니다.
- 반대로 **생성 후에도 바꿀 수 있는 것**: 처리량 용량(**증감 모두**) · 프로비저닝 SSD IOPS(고정값 또는 **GiB당 3 SSD IOPS 자동 유지**) · 네트워크 유형 · 주간 유지관리 창 · 자동 일일 백업 설정.
- **스토리지 용량**은 SSD(프로비저닝)에서는 **증가만** 가능하고 감소는 불가합니다. **Intelligent-Tiering** 클래스는 데이터에 맞춰 **자동으로 늘고 줄어듭니다.**
- **Intelligent-Tiering 클래스**는 고가용성 파일 서버 쌍 + 서버별 인메모리 캐시 구조이고, 볼륨 대신 **탄력적·지능형 계층화 리전 블록 스토리지**를 씁니다. 선택적 **프로비저닝 SSD 읽기 캐시**(사이징 모드 Automatic·Custom·None)와 내장 **SSD 기반 쓰기 로그**를 둡니다. SSD(프로비저닝) 대비 **최대 85% 비용 절감**이고, 지연은 Intelligent-Tiering 접근이 **수십 ms 수준 TTFB + 요청당 비용**, SSD 읽기 캐시 적중이 **1 ms 미만 + 요청당 비용 없음**입니다.

---

### 8) EFS vs FSx 선택 기준 비교 {#efs-vs-fsx}

| 요구사항 | 선택 | 이유 |
|---|---|---|
| 여러 리눅스 EC2 공유 파일시스템 | **EFS** | NFS·Multi-AZ·자동 확장 |
| Windows 파일 공유 (SMB·AD 인증) | **FSx for Windows** | SMB 네이티브·AD 통합 |
| HPC·ML 초고성능 파일시스템 | **FSx for Lustre** | 수 TBps·수백만 IOPS·S3 통합 |
| NFS·SMB·iSCSI 멀티 프로토콜 통합 | **FSx for NetApp ONTAP** | 멀티 프로토콜·온프레미스 ONTAP 마이그레이션 |
| ZFS 기반 고성능 NFS | **FSx for OpenZFS** | ZFS 기능·Linux·Windows·macOS·최대 200만 IOPS |

> 🧠 원리: 왜 동일한 "리눅스 파일 공유" 요건에서도 EFS와 FSx for Lustre가 나뉠까요?
> EFS는 범용 NFS로, 다수 클라이언트가 동시에 파일을 읽고 쓰는 공유 홈 디렉터리·콘텐츠 저장소처럼 접근 패턴이 고르게 분산된 워크로드에 설계됩니다.
> FSx for Lustre는 수천 개 컴퓨팅 노드가 동시에 대용량 데이터셋에 접근하는 HPC·ML 훈련처럼 집중적이고 병렬적인 I/O에 특화된 파일시스템으로, 내부 통신 프로토콜 자체가 이 부하를 전제로 설계되어 있습니다.
> 요건이 "여러 서버가 공유"이면 EFS, "초고성능 병렬 접근 + S3 데이터 연동"이면 FSx for Lustre로 선택이 분기됩니다.

---

### 9) 하이브리드 스토리지 — AWS Storage Gateway {#storage-gateway}

지금까지는 전부 **AWS 안에서** 쓰는 스토리지였습니다. 온프레미스 애플리케이션을 **고치지 않고** 클라우드 스토리지를 쓰게 하는 쪽이 **AWS Storage Gateway**입니다. 온프레미스 가상 머신(VMware ESXi·Microsoft Hyper-V·Linux KVM 등)이나 **하드웨어 어플라이언스**로 배포하고, VPC 안의 **EC2 인스턴스**로도 띄울 수 있습니다. 최근에 쓴 데이터는 **로컬 캐시**에 남아 저지연으로 읽힙니다.

| 게이트웨이 | 온프레미스에 보이는 인터페이스 | 실제 저장 위치 |
|---|---|---|
| **Amazon S3 File Gateway** | **NFS**(v3·v4.1)·**SMB**(v2·v3) 파일 공유 | S3 객체 — 올라간 뒤에는 수명 주기·교차 리전 복제·버전 관리를 그대로 적용 |
| **Amazon FSx File Gateway** ⚠️ | SMB 파일 공유 | FSx for Windows File Server. **2024-10-28부터 신규 고객은 이용할 수 없습니다**(기존 고객은 계속 사용) |
| **Volume Gateway** | **iSCSI** 블록 볼륨 | S3. 시점 백업은 **EBS 스냅샷** 형태로 보관 |
| **Tape Gateway** | **iSCSI VTL**(가상 테이프 라이브러리) | 활성 테이프는 S3, 백업 앱이 eject·export 하면 **S3 Glacier Flexible Retrieval 또는 S3 Glacier Deep Archive**로 아카이브 |

**Volume Gateway의 두 모드 (★ 시험 핵심)**

- **캐시형(cached volumes)** — **주 데이터는 S3**에 두고 자주 쓰는 데이터만 로컬 캐시에 둡니다. 온프레미스 스토리지를 증설하지 않고 용량을 늘리는 쪽. 볼륨 하나는 **1 GiB~32 TiB**, 게이트웨이당 **32개**까지(합계 최대 1,024 TiB).
- **저장형(stored volumes)** — **전체 데이터셋을 온프레미스에 두고** S3로는 비동기 시점 스냅샷만 보냅니다. 전체 데이터에 저지연 접근이 필요하고 클라우드는 오프사이트 백업으로만 쓰는 쪽.

> **구분 신호**: "기존 백업 소프트웨어를 그대로 쓰면서 물리 테이프를 없애고 싶다" → **Tape Gateway**. "온프레미스 앱이 iSCSI 블록 볼륨을 요구한다" → **Volume Gateway**. "NFS·SMB 파일 공유인데 실제 데이터는 S3 객체로 두고 싶다" → **S3 File Gateway**.

> 🧠 원리: 왜 Storage Gateway는 어떤 유형이든 **로컬 캐시**를 두어야 할까요?
> NFS·SMB·iSCSI는 원래 로컬 디스크나 같은 건물 안의 스토리지를 전제로 만들어진 프로토콜이라, 애플리케이션이 블록이나 파일을 읽을 때 돌아오는 응답이 빠를 것이라고 가정하고 동작합니다.
> 그런데 실제 데이터가 클라우드에 있으면 읽기마다 인터넷·전용 회선을 왕복해야 하므로, 프로토콜이 가정한 응답 시간과 실제 응답 시간 사이에 큰 간극이 생깁니다.
> 로컬 캐시는 그 간극을 메우는 장치입니다 — 최근 접근한 데이터를 온프레미스에 두어 프로토콜이 기대하는 속도로 응답하고, 클라우드로의 업로드는 뒤에서 비동기로 처리합니다. 그래서 캐시 크기 산정이 Storage Gateway 설계의 핵심 변수가 됩니다.

---

## ✍️ 시험 포인트

- **EBS 기본 추천**: gp3 — 용량과 독립적으로 IOPS·처리량을 설정 가능하고 gp2보다 비용 효율적. 새 워크로드엔 gp3를 선택.
- **고IOPS DB**: io1·io2 — 미션 크리티컬 데이터베이스. io2 Block Express는 최대 256,000 IOPS와 99.999% 내구성.
- **대용량 순차 처리**: st1 — 빅데이터·로그·스트리밍. 부팅 불가.
- **저비용 콜드**: sc1 — 접근 빈도가 낮은 아카이브. 부팅 불가.
- **Multi-Attach**: io1·io2만 지원 — 같은 AZ의 여러 Nitro 인스턴스에 동시 연결.
- **인스턴스 스토어 vs EBS**: 인스턴스 스토어는 인스턴스 중지·종료 시 데이터 소실(임시), EBS는 인스턴스와 독립적으로 데이터 유지(영속).
- **EFS는 Linux 전용**: Windows EC2에서 EFS 마운트는 공식 미지원. Windows 공유는 FSx for Windows.
- **FSx for Lustre + S3**: ML·HPC에서 S3 데이터를 고성능 파일시스템으로 빠르게 처리해야 할 때.
- **EFS One Zone vs Regional**: 가용성 요건이 낮고 비용을 줄이려면 One Zone, 기본은 Regional(다중 AZ).
- **스냅샷 = S3 저장**: EBS 스냅샷은 S3에 증분으로 저장되며, 다른 리전으로 복사 가능.

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"여러 EC2가 EBS를 공유하면 된다."** → EBS는 기본적으로 단일 인스턴스 연결입니다. 여러 인스턴스가 동시에 같은 파일에 접근해야 하면 EFS(Linux) 또는 FSx for Windows(Windows)를 사용합니다. io1·io2의 Multi-Attach는 존재하지만, 클러스터 파일시스템이 없으면 데이터 충돌이 발생할 수 있습니다.
   *(원리: §2 본문 — EBS는 기본적으로 단일 인스턴스 연결이며, §4 본문 — 파일 시스템 수준 동시성 제어는 애플리케이션이 직접 담당해야 한다.)*

2. **"st1이나 sc1을 부팅 볼륨으로 사용할 수 있다."** → HDD 볼륨(st1·sc1)은 부팅 볼륨으로 사용할 수 없습니다. 부팅 볼륨은 SSD(gp2·gp3·io1·io2)만 가능합니다.
   *(원리: §3 — HDD는 회전 대기 때문에 랜덤 소규모 I/O가 많은 OS 부팅 패턴에 대응하지 못해 부팅 볼륨에서 제외된다.)*

3. **"gp2 IOPS를 빠르게 늘리려면 IOPS 설정만 바꾸면 된다."** → gp2는 IOPS가 용량에 자동 비례(GB당 3 IOPS)하므로 IOPS를 올리려면 용량을 늘려야 합니다. gp3로 전환하면 용량과 무관하게 IOPS를 독립 설정할 수 있습니다.
   *(원리: §3 본문 — gp3는 IOPS·처리량을 용량과 독립 설정할 수 있어 gp2보다 유연하고 비용 효율적이다.)*

4. **"EFS는 Windows EC2에서도 사용할 수 있다."** → Amazon EFS는 Windows 기반 EC2를 공식 지원하지 않습니다. Windows 공유 파일시스템에는 FSx for Windows File Server(SMB·AD)를 사용합니다.
   *(원리: §6 본문 — EFS는 NFSv4 프로토콜 기반으로 Linux 인스턴스에서 마운트하도록 설계되어, Windows의 SMB 프로토콜 스택과 호환되지 않는다.)*

5. **"인스턴스 스토어는 재부팅해도 데이터가 사라진다."** → 인스턴스 **재부팅**으로는 데이터가 유지됩니다. 데이터가 소실되는 시점은 인스턴스 **중지(stop)·종료(terminate)** 또는 하드웨어 장애입니다.
   *(원리: §5 — 재부팅은 같은 물리 호스트에서 OS만 재시작해 로컬 디스크 연결이 유지되지만, 중지·종료는 호스트 배치가 바뀔 수 있어 데이터 접근이 보장되지 않는다.)*

6. **"EBS 스냅샷은 전체 데이터를 매번 저장한다."** → 첫 스냅샷 이후에는 **변경된 블록만** 증분 저장합니다. 단, 삭제 시에는 해당 스냅샷만 참조하는 블록만 실제 삭제됩니다.
   *(원리: §4 본문 — 스냅샷은 증분 방식으로 변경된 블록만 S3에 저장하므로, 첫 스냅샷 이후 저장 용량과 시간이 크게 줄어든다.)*

7. **"FSx for Lustre는 Windows에서도 마운트 가능하다."** → FSx for Lustre는 POSIX 호환 Linux 전용입니다. Windows 고성능 파일시스템이 필요하면 FSx for Windows File Server를 사용합니다.
   *(원리: §7 — FSx 각 엔진은 특정 OS 프로토콜 스택을 전제로 설계되어 있어, Lustre의 POSIX 인터페이스는 Windows 클라이언트가 사용하는 SMB와 호환되지 않는다.)*

8. **"FSx for OpenZFS도 Linux·macOS만 접근한다."** → FSx for OpenZFS는 NFS 프로토콜로 Linux·Windows·macOS 클라이언트에서 접근할 수 있습니다.
   *(원리: §7 — OpenZFS는 파일시스템 엔진이고, 클라이언트 접근은 업계 표준 NFS 프로토콜로 제공되므로 Windows에서도 NFS 클라이언트 경로를 사용할 수 있다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 웹 서버 Auto Scaling 그룹의 여러 리눅스 EC2 인스턴스가 공통 업로드 파일에 동시 접근해야 합니다. 가장 적합한 스토리지는?

<details><summary>정답 보기</summary>

**Amazon EFS**입니다. EFS는 NFSv4 기반의 완전 관리형 파일 스토리지로, 여러 AZ에 걸쳐 다수의 Linux EC2 인스턴스에서 동시 마운트가 가능합니다. EBS는 단일 인스턴스 연결이 기본이므로 공유 파일시스템에 적합하지 않습니다. S3는 파일시스템 마운트 방식이 아닌 HTTP API 기반 객체 스토리지입니다.
</details>

**Q2.** 미션 크리티컬 Oracle 데이터베이스가 초당 200,000 IOPS를 요구합니다. 어떤 EBS 볼륨 타입을 선택해야 하나요?

<details><summary>정답 보기</summary>

**io2 Block Express**입니다. 최대 256,000 IOPS를 지원하며, 99.999% 내구성을 제공합니다. io1은 최대 64,000 IOPS, gp3는 최대 80,000 IOPS로 200,000 IOPS 요건을 충족하지 못합니다. io2 Block Express는 Nitro 기반 인스턴스에서 전체 성능을 활용할 수 있습니다.
</details>

**Q3.** 머신러닝 훈련 클러스터가 Amazon S3에 저장된 수백 TB 데이터셋을 고성능으로 처리해야 합니다. 가장 적합한 파일 스토리지는?

<details><summary>정답 보기</summary>

**Amazon FSx for Lustre**입니다. FSx for Lustre는 서브밀리초 지연시간과 수 TBps 처리량·수백만 IOPS를 제공하며, S3 버킷을 데이터 리포지토리로 직접 연결해 S3 객체를 파일처럼 투명하게 접근할 수 있습니다. SageMaker AI와 통합되어 ML 훈련 데이터 로딩을 가속화합니다.
</details>

**Q4.** EC2 인스턴스가 중지된 후에도 데이터를 유지해야 합니다. 인스턴스 스토어와 EBS 중 어느 것을 사용해야 하나요?

<details><summary>정답 보기</summary>

**Amazon EBS**입니다. EBS 볼륨은 인스턴스 중지·종료와 독립적으로 데이터를 유지합니다. 반면 인스턴스 스토어는 인스턴스 중지·종료 또는 하드웨어 장애 시 데이터가 소실되는 임시 스토리지입니다. 재부팅(reboot)으로는 인스턴스 스토어 데이터도 유지됩니다.
</details>

**Q5 (원리).** 왜 EBS Multi-Attach를 사용한다고 해서 여러 EC2가 자동으로 안전하게 파일을 공유할 수 있는 것은 아닌가요?

<details><summary>정답 보기</summary>

EBS Multi-Attach는 동일 볼륨을 여러 Nitro 인스턴스에 동시 연결하는 것만 허용할 뿐, 동시 쓰기가 발생할 때 어느 쪽 쓰기가 우선인지 조율하는 파일 잠금(locking) 메커니즘을 제공하지 않습니다. 두 인스턴스가 같은 블록에 동시에 쓰면 마지막에 쓴 내용이 앞의 내용을 덮어쓸 수 있어 데이터가 손상됩니다. 이 충돌을 막으려면 클러스터 파일시스템처럼 분산 잠금을 애플리케이션 레이어에서 직접 구현해야 하며, 그 조율이 없으면 Multi-Attach는 고가용성 클러스터 DB처럼 잠금을 직접 관리하는 특수 용도로만 안전하게 쓸 수 있습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. Amazon EBS — What is Amazon Elastic Block Store? — https://docs.aws.amazon.com/ebs/latest/userguide/what-is-ebs.html
2. Amazon EBS 볼륨 타입 — https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html
3. Amazon EFS — What is Amazon Elastic File System? — https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html
4. Amazon EFS 수명 주기 관리 — https://docs.aws.amazon.com/efs/latest/ug/lifecycle-management-efs.html
5. Amazon FSx for Windows File Server — What is? — https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html
6. Amazon FSx for Lustre — What is? — https://docs.aws.amazon.com/fsx/latest/LustreGuide/what-is.html
7. Amazon FSx for NetApp ONTAP — What is? — https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/what-is-fsx-ontap.html
8. Amazon FSx for OpenZFS — What is? — https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/what-is-fsx.html
9. Amazon EFS 성능 사양(Max I/O = previous generation, One Zone·Elastic 미지원) — https://docs.aws.amazon.com/efs/latest/ug/performance.html
10. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
11. Amazon S3 File Gateway — What is?(NFS v3·v4.1 / SMB v2·v3, VM·하드웨어 어플라이언스·EC2 AMI, 로컬 캐시) — https://docs.aws.amazon.com/filegateway/latest/files3/what-is-file-s3.html
12. Volume Gateway 작동 방식(캐시형 1 GiB~32 TiB·게이트웨이당 32볼륨, 저장형은 전체 데이터셋 온프레미스) — https://docs.aws.amazon.com/storagegateway/latest/vgw/StorageGatewayConcepts.html
13. Tape Gateway(가상 테이프 라이브러리 → S3 Glacier Flexible Retrieval·Deep Archive 아카이브) — https://aws.amazon.com/storagegateway/vtl/
14. Amazon FSx File Gateway 변경 이력(2024-10-28부터 신규 고객 이용 불가) — https://docs.aws.amazon.com/filegateway/latest/filefsxw/DocumentHistory.html
15. EBS 범용 SSD — gp3(기준 3,000 IOPS·125 MiB/s, 최대 **80,000 IOPS**·GiB당 500, 최대 **2,000 MiB/s**·IOPS당 0.25, **버스트 미사용**, Outposts 제한) — https://docs.aws.amazon.com/ebs/latest/userguide/general-purpose.html
16. EBS 프로비저닝 IOPS SSD — io2 Block Express(최대 **256,000 IOPS**·1,000:1·256 GiB 이상, 4,000 MiB/s·IOPS당 0.256, 64 TiB, **Nitro에서만 256,000·그 외 32,000**, 16 KiB에서 500µs 미만) — https://docs.aws.amazon.com/ebs/latest/userguide/provisioned-iops.html
17. EBS 최적화(전용 대역폭·I/O 크기가 지연에 영향·io1·io2 90%/99.9%·gp2·gp3 90%/99%) — https://docs.aws.amazon.com/ebs/latest/userguide/ebs-optimization.html
18. Elastic Volumes 수정 제약(**크기 축소 불가**·롤링 24시간 **4회**·취소 불가·파일 시스템 확장 필요·타입별 한계·Multi-Attach는 io1↔io2만·루트 볼륨 st1/sc1 불가·Nitro 256,000 / 그 외 64,000 연결·32,000 달성) — https://docs.aws.amazon.com/ebs/latest/userguide/ebs-modify-volume.html
19. Multi-Attach 볼륨의 **NVMe 예약**(업계 표준 스토리지 펜싱 프로토콜) — https://docs.aws.amazon.com/ebs/latest/userguide/nvme-reservations.html
20. 인스턴스 스토어 데이터 지속성 표(재부팅 유지 / 중지·**최대 절전**·종료·**유형 변경**·**은퇴**·셧다운 미유지, **암호학적 소거**, 시작 시에만 연결) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-store-lifetime.html
21. EFS 성능 사양 — 처리량 모드 선택 기준(**평균/피크 5%**·Bursting 하루 **12시간**·80% 초과 시 전환 권고) — https://docs.aws.amazon.com/efs/latest/ug/performance.html
22. EFS 처리량 관리(모드 변경은 다운타임 없음·**Provisioned 증액 후 24시간 대기**·`MeteredIOBytes` 모니터링 권고) — https://docs.aws.amazon.com/efs/latest/ug/managing-throughput.html
23. FSx for Lustre S3 링크 DRA(**최대 8개**·동시 1건 처리·고유 디렉터리·양방향·**충돌 쓰기 미방지**·2.10/`Scratch 1` 미지원) — https://docs.aws.amazon.com/fsx/latest/LustreGuide/create-dra-linked-data-repo.html
24. FSx for Lustre 백업 지원 범위(**S3에 링크되지 않은 persistent만**·scratch 미지원) — https://docs.aws.amazon.com/fsx/latest/LustreGuide/using-backups-fsx.html
25. FSx for OpenZFS 성능 — **배포 유형·스토리지 클래스 생성 후 변경 불가**(복원·온디맨드 복제로만 이전, Single-AZ 백업→Multi-AZ 불가) — https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/performance.html
26. FSx for OpenZFS Intelligent-Tiering(HA 파일 서버 쌍·탄력적 리전 블록 스토리지·SSD 읽기 캐시 3모드·SSD 대비 **최대 85% 절감**·TTFB 수십 ms vs 캐시 1 ms 미만) — https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/performance-intelligent-tiering.html

> 📝 **2026-10-21 보강(갭 `G-3.1-02`·`03`·`04`·`07`·`08`·`14`, 배치 B7a)**: ① **§3에 EBS 성능 결정 조건** — gp3/io2 상한·비율, **io2 256,000은 Nitro 전용**(그 외 32,000, 볼륨은 64,000까지 *연결*만 가능), I/O 크기 기준(IOPS 16 KiB·처리량 128 KiB), EBS 최적화와 **인스턴스 한계 vs 볼륨 합계 중 작은 쪽** 제약(근거 15·16·17번). ② **§4에 Multi-Attach 보강**(최대 16 Nitro·**NVMe 예약 = 업계 표준 펜싱**·io1↔io2만 변경)과 **Elastic Volumes 규칙**(축소 불가·24시간 4회·취소 불가·**파일 시스템 확장 필요**)(근거 18·19번). ③ **§5에 인스턴스 스토어 소실 조건 공식 표** — 기존 "중지·종료·하드웨어 장애" 외에 **최대 절전·인스턴스 유형 변경·은퇴·셧다운**도 소실이고 **모든 블록이 암호학적으로 소거**됩니다(근거 20번). ④ **§6에 EFS 처리량 모드 선택 기준**(평균/피크 **5%**·Bursting 하루 12시간·80% 초과 시 전환·Provisioned 증액 후 24시간)(근거 21·22번). ⑤ **§7에 FSx 보조 특성** — Lustre DRA 최대 8개·충돌 미방지·**링크된 파일 시스템 백업 미지원**, OpenZFS **배포 유형·스토리지 클래스 변경 불가**와 Intelligent-Tiering(근거 23·24·25·26번).
>
> **쓰지 않은 것:** FSx for Windows의 **AD 통합 "필수"** 단정(`99-gaps` V-18) · FSx for Lustre **IOPS 한도**(V-19) · FSx for OpenZFS **디스크 IOPS 수치**(C-16 — 이 문서 §7의 "최대 2,000,000 IOPS"는 공식 미확인으로 열려 있는 별건 `[의심]` 항목이라 이번 배치에서 건드리지 않았습니다) · **EFS IA 절감률**(C-02 — 95% vs 92% 상충) · 인스턴스 스토어 **NVMe 성능 수치**(V-20).

> 📝 **2026-10-19 정정**: ① EFS **Max I/O를 이전 세대 성능 모드**로 고쳤습니다 — 지연시간이 더 크고 One Zone·Elastic 처리량과 병용할 수 없으며, AWS는 모든 파일 시스템에 General Purpose를 권장합니다(근거 9번). ② FSx for Lustre 성능을 한 줄 수치로 적었던 칸을 **스토리지 클래스별(SSD·Intelligent-Tiering·HDD)**로 분리했습니다(근거 6번).

> 📝 **2026-10-20 보강**: 공식 가이드 Task 3.1 Knowledge 「하이브리드 스토리지 솔루션」에 대응하는 서술이 없어 **§9 AWS Storage Gateway**를 신설했습니다(근거 11~14번). 게이트웨이 4유형·Volume Gateway 캐시형/저장형 구분·Tape Gateway 아카이브 대상을 공식 문서로 확인했고, **FSx File Gateway가 2024-10-28부터 신규 고객에게 제공되지 않는다**는 점을 함께 표시했습니다.
