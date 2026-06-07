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
  - title: Amazon FSx for Windows File Server — What is? (공식)
    url: https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html
  - title: Amazon FSx for Lustre — What is? (공식)
    url: https://docs.aws.amazon.com/fsx/latest/LustreGuide/what-is.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-07
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

## 📖 핵심 개념

### 1) 스토리지 3대 유형

| 유형 | 대표 서비스 | 접근 방식 | 대표 사용 사례 |
|---|---|---|---|
| **블록** | EBS, 인스턴스 스토어 | EC2 디스크처럼 마운트 | OS 부팅 볼륨, DB 데이터 파일 |
| **파일** | EFS, FSx | NFS·SMB로 네트워크 마운트 | 공유 홈 디렉터리, HPC 데이터셋 |
| **객체** | S3 | HTTP API(GET·PUT) | 정적 파일, 백업, 데이터 레이크 |

> 블록은 "디스크처럼 쓴다", 파일은 "네트워크 드라이브처럼 쓴다", 객체는 "API로 올리고 내려받는다"로 구분하면 됩니다.

### 2) EBS(Amazon Elastic Block Store)란

공식 정의: **"Amazon EC2 인스턴스에 연결해 사용하는 확장 가능한 고성능 블록 스토리지."** EC2에 연결하면 로컬 하드 드라이브처럼 파일 저장·애플리케이션 설치에 사용할 수 있습니다.

핵심 특성:
- **단일 AZ 내** 자동 복제 — 단일 하드웨어 장애로부터 보호
- EC2 인스턴스와 **같은 AZ**에 위치해야 연결 가능
- 기본적으로 **단일 인스턴스** 연결 (Multi-Attach는 io1/io2에서만 지원)
- 인스턴스를 중지해도 데이터 유지 (인스턴스 스토어와의 핵심 차이)

### 3) EBS 볼륨 타입 비교 (★ 시험 핵심)

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

### 4) EBS 스냅샷·암호화·Multi-Attach

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

### 5) 인스턴스 스토어(임시 블록 스토리지)

인스턴스 스토어는 EC2 인스턴스에 **물리적으로 부착된** 임시 블록 스토리지입니다.

| 특성 | 설명 |
|---|---|
| **휘발성** | 인스턴스 중지·종료·하드웨어 장애 시 데이터 소실 |
| **성능** | 네트워크를 거치지 않아 매우 낮은 지연시간 |
| **비용** | 인스턴스 요금에 포함 (별도 요금 없음) |
| **용도** | 임시 파일, 버퍼, 캐시, 스크래치 데이터 |

> 인스턴스 재부팅(reboot)으로는 데이터가 유지됩니다. 중지(stop) 또는 종료(terminate)하면 소실됩니다.

### 6) Amazon EFS(Elastic File System)

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
| **One Zone** | 단일 AZ, 더 저렴 |
| **One Zone-IA** | 단일 AZ + IA |

### 7) Amazon FSx 패밀리

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
- **NFS** 프로토콜, Linux·macOS 클라이언트
- 최대 1,000,000 IOPS, 서브밀리초 지연시간
- ZFS 스냅샷·복제 기능, 온프레미스 ZFS 워크로드 마이그레이션에 적합

### 8) EFS vs FSx 선택 기준 비교

| 요구사항 | 선택 | 이유 |
|---|---|---|
| 여러 리눅스 EC2 공유 파일시스템 | **EFS** | NFS·Multi-AZ·자동 확장 |
| Windows 파일 공유 (SMB·AD 인증) | **FSx for Windows** | SMB 네이티브·AD 통합 |
| HPC·ML 초고성능 파일시스템 | **FSx for Lustre** | 수 TBps·수백만 IOPS·S3 통합 |
| NFS·SMB·iSCSI 멀티 프로토콜 통합 | **FSx for NetApp ONTAP** | 멀티 프로토콜·온프레미스 ONTAP 마이그레이션 |
| ZFS 기반 고성능 NFS | **FSx for OpenZFS** | ZFS 기능·리눅스·macOS·최대 100만 IOPS |

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

## ⚠️ 흔한 함정

1. **"여러 EC2가 EBS를 공유하면 된다."** → EBS는 기본적으로 단일 인스턴스 연결입니다. 여러 인스턴스가 동시에 같은 파일에 접근해야 하면 EFS(Linux) 또는 FSx for Windows(Windows)를 사용합니다. io1·io2의 Multi-Attach는 존재하지만, 클러스터 파일시스템이 없으면 데이터 충돌이 발생할 수 있습니다.

2. **"st1이나 sc1을 부팅 볼륨으로 사용할 수 있다."** → HDD 볼륨(st1·sc1)은 부팅 볼륨으로 사용할 수 없습니다. 부팅 볼륨은 SSD(gp2·gp3·io1·io2)만 가능합니다.

3. **"gp2 IOPS를 빠르게 늘리려면 IOPS 설정만 바꾸면 된다."** → gp2는 IOPS가 용량에 자동 비례(GB당 3 IOPS)하므로 IOPS를 올리려면 용량을 늘려야 합니다. gp3로 전환하면 용량과 무관하게 IOPS를 독립 설정할 수 있습니다.

4. **"EFS는 Windows EC2에서도 사용할 수 있다."** → Amazon EFS는 Windows 기반 EC2를 공식 지원하지 않습니다. Windows 공유 파일시스템에는 FSx for Windows File Server(SMB·AD)를 사용합니다.

5. **"인스턴스 스토어는 재부팅해도 데이터가 사라진다."** → 인스턴스 **재부팅**으로는 데이터가 유지됩니다. 데이터가 소실되는 시점은 인스턴스 **중지(stop)·종료(terminate)** 또는 하드웨어 장애입니다.

6. **"EBS 스냅샷은 전체 데이터를 매번 저장한다."** → 첫 스냅샷 이후에는 **변경된 블록만** 증분 저장합니다. 단, 삭제 시에는 해당 스냅샷만 참조하는 블록만 실제 삭제됩니다.

7. **"FSx for Lustre는 Windows에서도 마운트 가능하다."** → FSx for Lustre는 POSIX 호환 Linux 전용입니다. Windows 고성능 파일시스템이 필요하면 FSx for Windows File Server를 사용합니다.

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

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07)

1. Amazon EBS — What is Amazon Elastic Block Store? — https://docs.aws.amazon.com/ebs/latest/userguide/what-is-ebs.html
2. Amazon EBS 볼륨 타입 — https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html
3. Amazon EFS — What is Amazon Elastic File System? — https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html
4. Amazon FSx for Windows File Server — What is? — https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html
5. Amazon FSx for Lustre — What is? — https://docs.aws.amazon.com/fsx/latest/LustreGuide/what-is.html
6. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
