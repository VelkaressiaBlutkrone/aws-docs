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
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-12
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
| **Max I/O** | 더 높은 집합 처리량·IOPS, 다소 높은 지연시간 | 수천 인스턴스가 동시 접근하는 빅데이터 분석 |

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
| **성능** | 서브밀리초 지연시간, 수 TBps 처리량, 수백만 IOPS |
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
9. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
