import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-22 오디오 대본 검수에서 파생된 학습문서 판정 채택 건의 회귀 가드.
///
/// 판정 정본: `docs/audits/2026-11-22-audio-script-review/02-docfix-*.md`.
/// A-06(Lambda 타임아웃 상한)은 사용자 판단 대기라 이 표에 없다.
/// `oldText` 가 null 인 항목은 옛 문구가 새 문구의 부분 문자열이라 포함만 단정한다.
const _fixes = <({String item, String file, String? oldText, String newText})>[
  (
    item: 'CLF:t2-4.md:125',
    file: 'clf/t2-4.md',
    oldText: '- 점검 영역: **비용 절감, 성능 개선, 보안 격차 해소, 내결함성(가용성), 서비스 한도(quota)** 등 모범 사례 카테고리.',
    newText: '- 점검 영역: **비용 절감, 성능 개선, 보안 격차 해소, 내결함성(가용성), 서비스 한도(quota), 운영 우수성** 등 모범 사례 카테고리.',
  ),
  (
    item: 'CLF:t2-4.md:134',
    file: 'clf/t2-4.md',
    oldText: '> Trusted Advisor는 AWS가 수십만 고객을 지원하며 쌓은 **모범 사례 패턴**을 규칙으로 만들어 비용·성능·보안·내결함성·서비스 한도 영역에서 개선 기회를 제안하는 역할에 집중합니다.',
    newText: '> Trusted Advisor는 AWS가 수십만 고객을 지원하며 쌓은 **모범 사례 패턴**을 규칙으로 만들어 비용·성능·보안·내결함성·서비스 한도·운영 우수성 영역에서 개선 기회를 제안하는 역할에 집중합니다.',
  ),
  (
    item: 'CLF:t2-4.md:210',
    file: 'clf/t2-4.md',
    oldText: '- **Trusted Advisor** = AWS 환경을 모범 사례로 점검·권고(비용·성능·보안·내결함성·서비스 한도).',
    newText: '- **Trusted Advisor** = AWS 환경을 모범 사례로 점검·권고(비용·성능·보안·내결함성·서비스 한도·운영 우수성).',
  ),
  (
    item: 'CLF:t4-1.md:114',
    file: 'clf/t4-1.md',
    oldText: '### 3) 스토리지 계층별 요금 (4.x 스토리지와 연계) {#storage-pricing}',
    newText: '### 3) 스토리지 계층별 요금 (3.6 스토리지와 연계) {#storage-pricing}',
  ),
  (
    item: 'A1:116',
    file: 'saa/saa-t1-2.md',
    oldText: '> 🔐 **멤버 계정 루트는 없애는 것이 현행 모범 사례입니다(중앙 루트 접근 관리).** Organizations에서 이 기능을 켜면 멤버 계정의 루트 비밀번호·액세스 키·서명 인증서·MFA를 제거할 수 있고, 제거된 계정은 **루트 로그인도 비밀번호 복구도 불가**합니다. **새로 만드는 계정은 기본적으로 루트 자격증명이 없습니다.** 루트만 할 수 있는 일(잘못 설정된 S3 버킷 정책·SQS 정책 복구 등)은 관리 계정이나 위임 관리자가 **권한 작업(`sts:AssumeRoot`)** 으로 수행하고, 필요할 때만 **비밀번호 복구 허용**을 켭니다. 관리 계정 루트는 제거할 수 없으므로 **MFA가 요구**되며(첫 로그인 후 35일 유예) 다중 승인 보관을 권장합니다.',
    newText: '> 🔐 **멤버 계정 루트는 없애는 것이 현행 모범 사례입니다(중앙 루트 접근 관리).** Organizations에서 이 기능을 켜면 멤버 계정의 루트 비밀번호·액세스 키·서명 인증서·MFA를 제거할 수 있고, 제거된 계정은 **루트 로그인도 비밀번호 복구도 불가**합니다. **새로 만드는 계정은 기본적으로 루트 자격증명이 없습니다.** 루트만 할 수 있는 일(잘못 설정된 S3 버킷 정책·SQS 정책 복구 등)은 관리 계정이나 위임 관리자가 **권한 작업(`sts:AssumeRoot`)** 으로 수행하고, 필요할 때만 **비밀번호 복구 허용**을 켭니다. 관리 계정 루트는 제거할 수 없으므로 **MFA가 요구**되며(MFA가 없으면 첫 콘솔 로그인 시도 후 14일 안에 등록) 다중 승인 보관을 권장합니다.',
  ),
  (
    item: 'A2:271',
    file: 'saa/saa-t1-1.md',
    oldText: '> OIDC 토큰을 검증해 임시 자격증명을 발급하면 IAM 사용자 수명 주기 관리 자체가 없어집니다 — 외부 IdP에서 사용자가 삭제되면 즉시 AWS 접근이 차단됩니다.',
    newText: '> OIDC 토큰을 검증해 임시 자격증명을 발급하면 IAM 사용자 수명 주기 관리 자체가 없어집니다 — 외부 IdP에서 사용자가 삭제되면 새 임시 자격증명을 받을 수 없고, 이미 발급된 자격증명은 만료될 때까지만 유효합니다(만료 전에 끊으려면 역할 세션 취소).',
  ),
  (
    item: 'A3:378',
    file: 'saa/saa-t1-3.md',
    oldText: '- **네트워크 트래픽 감사·모니터링** → **VPC Flow Logs** (CloudWatch 또는 S3 저장).',
    newText: '- **네트워크 트래픽 감사·모니터링** → **VPC Flow Logs** (CloudWatch Logs·S3·Data Firehose 저장).',
  ),
  (
    item: 'A4:201',
    file: 'saa/saa-t1-3.md',
    oldText: '프라이빗 서브넷의 EC2가 S3·DynamoDB 같은 AWS 관리형 서비스에 접근할 때, 기본 경로는 NAT 게이트웨이 → 인터넷 → AWS 퍼블릭 엔드포인트입니다. VPC 엔드포인트는 이 경로를 **인터넷 없이 AWS 내부망으로** 대체합니다.',
    newText: '프라이빗 서브넷의 EC2가 S3·DynamoDB 같은 AWS 관리형 서비스에 접근할 때, 기본 경로는 NAT 게이트웨이 → 인터넷 게이트웨이 → AWS 퍼블릭 서비스 엔드포인트입니다(이 트래픽은 인터넷 게이트웨이를 지나지만 AWS 네트워크를 벗어나지는 않습니다). VPC 엔드포인트는 이 경로를 **인터넷 게이트웨이·NAT 없이** 대체합니다.',
  ),
  (
    item: 'A5:159',
    file: 'saa/saa-t1-3.md',
    oldText: '> 시험 포인트: NAT 게이트웨이는 **퍼블릭 서브넷에 배치**하고 Elastic IP를 연결합니다. 프라이빗 서브넷의 라우트 테이블에 `0.0.0.0/0 → NAT 게이트웨이`를 추가해야 아웃바운드가 동작합니다.',
    newText: '> 시험 포인트: **영역형(zonal) NAT 게이트웨이**는 **퍼블릭 서브넷에 배치**하고 Elastic IP를 연결합니다(리전 NAT 게이트웨이는 퍼블릭 서브넷이 필요 없습니다). 프라이빗 서브넷의 라우트 테이블에 `0.0.0.0/0 → NAT 게이트웨이`를 추가해야 아웃바운드가 동작합니다.',
  ),
  (
    item: 'A5:161',
    file: 'saa/saa-t1-3.md',
    oldText: '> ⚠️ **"NAT 게이트웨이는 자동으로 고가용"이 아닙니다.** 각 NAT 게이트웨이는 **특정 AZ에 만들어지고 그 AZ 안에서만 이중화**됩니다. 여러 AZ의 리소스가 하나의 NAT 게이트웨이를 공유하면 **그 AZ가 내려갈 때 다른 AZ 리소스까지 인터넷이 끊깁니다.** 공식 권고는 **AZ마다 NAT 게이트웨이를 만들고 같은 AZ의 NAT로 라우팅**하는 것입니다. 이 구성이 시험에서 "AZ 장애에도 아웃바운드 유지" 요구의 정답 방향입니다.',
    newText: '> ⚠️ **"NAT 게이트웨이는 자동으로 고가용"이 아닙니다.** 여기서 말하는 것은 **영역형(zonal)** 입니다. 각 영역형 NAT 게이트웨이는 **특정 AZ에 만들어지고 그 AZ 안에서만 이중화**됩니다. 여러 AZ의 리소스가 하나의 NAT 게이트웨이를 공유하면 **그 AZ가 내려갈 때 다른 AZ 리소스까지 인터넷이 끊깁니다.** 공식 권고는 **AZ마다 NAT 게이트웨이를 만들고 같은 AZ의 NAT로 라우팅**하는 것입니다. 이 구성이 시험에서 "AZ 장애에도 아웃바운드 유지" 요구의 정답 방향입니다. **리전 NAT 게이트웨이**를 고르면 워크로드가 있는 AZ로 자동 확장됩니다.',
  ),
  (
    item: 'A5:164',
    file: 'saa/saa-t1-3.md',
    oldText: '> 🧠 원리: 왜 NAT 게이트웨이는 프라이빗이 아닌 퍼블릭 서브넷에 배치해야 할까요?',
    newText: '> 🧠 원리: 왜 영역형 NAT 게이트웨이는 프라이빗이 아닌 퍼블릭 서브넷에 배치해야 할까요?',
  ),
  (
    item: 'A5:122',
    file: 'saa/saa-t2-4.md',
    oldText: '| 단일 NAT 게이트웨이 | AZ마다 NAT 게이트웨이 1개씩 배치 |',
    newText: '| 단일 NAT 게이트웨이 | 영역형은 AZ마다 NAT 게이트웨이 1개씩 배치(또는 리전 NAT 게이트웨이) |',
  ),
  (
    item: 'A5:273',
    file: 'saa/saa-t2-4.md',
    oldText: '| NAT 게이트웨이 | AZ마다 미리 배치 → 한 AZ 장애 시 다른 AZ 독립 동작 |',
    newText: '| NAT 게이트웨이 | 영역형은 AZ마다 미리 배치 → 한 AZ 장애 시 다른 AZ 독립 동작 |',
  ),
  (
    item: 'A5:487',
    file: 'saa/saa-t2-4.md',
    oldText: '6. **"NAT 게이트웨이 1개로 전체 VPC를 커버하면 된다."** → NAT 게이트웨이가 있는 AZ에 장애가 나면 다른 AZ의 프라이빗 서브넷이 인터넷에 나갈 수 없습니다. AZ마다 NAT 게이트웨이를 배치해야 합니다.',
    newText: '6. **"NAT 게이트웨이 1개로 전체 VPC를 커버하면 된다."** → NAT 게이트웨이가 있는 AZ에 장애가 나면 다른 AZ의 프라이빗 서브넷이 인터넷에 나갈 수 없습니다. 영역형은 AZ마다 배치하고, 리전 NAT 게이트웨이를 쓰면 워크로드가 있는 AZ로 자동 확장됩니다.',
  ),
  (
    item: 'A6:70',
    file: 'saa/saa-t1-4.md',
    oldText: '| **웹 ACL** | Web Access Control List | WAF의 규칙 컨테이너 — 요청을 순서대로 평가해 첫 매칭 액션(Allow/Block/Count)을 실행 |',
    newText: '| **웹 ACL** | Web Access Control List | WAF의 규칙 컨테이너 — 규칙을 우선순위 순서로 평가해 처음 매칭된 종료 액션(Allow/Block)에서 끝남(Count는 비종료) |',
  ),
  (
    item: 'A7:82',
    file: 'saa/saa-t1-5.md',
    oldText: '| **키 정책** | Key Policy | CMK에 붙이는 리소스 기반 정책 — IAM 정책만으로는 CMK 접근 불가 |',
    newText: '| **키 정책** | Key Policy | CMK에 붙이는 리소스 기반 정책 — 키 정책이 허용(계정 위임 문장 포함)해야 IAM 정책이 효력을 가짐 |',
  ),
  (
    item: 'A8:249',
    file: 'saa/saa-t2-1.md',
    oldText: '| 여러 구독자 + 재시도·처리 보장 | **SNS + SQS 팬아웃** | SQS가 각 소비자 큐를 안정적으로 버퍼링 |',
    newText: '| 여러 구독자 + 소비자별 버퍼링·독립 속도·재처리 | **SNS + SQS 팬아웃** | SQS가 각 소비자 큐를 안정적으로 버퍼링 |',
  ),
  (
    item: 'A9:351',
    file: 'saa/saa-t2-1.md',
    oldText: '   (원리: §6 — Express는 상태 전이 이력을 콘솔에 보존하지 않아 고빈도·단기에 최적화됐고, 장기 상태 추적은 Standard의 설계 목적이다.)',
    newText: '   (원리: §6 — Express는 실행 이력을 Step Functions에 기록하지 않아(로깅을 켜야 CloudWatch Logs·콘솔에서 조회) 고빈도·단기에 최적화됐고, 장기 상태 추적은 Standard의 설계 목적이다.)',
  ),
  (
    item: 'A11:191',
    file: 'saa/saa-t2-2.md',
    oldText: '| **HTTP API** | 더 저렴·단순·저지연. 기본 기능 위주 | 단순 Lambda 프록시, 비용 우선 |',
    newText: '| **HTTP API** | 더 저렴·단순. 기능을 최소화한 기본 기능 위주 | 단순 Lambda 프록시, 비용 우선 |',
  ),
  (
    item: 'A12:100',
    file: 'saa/saa-t2-4.md',
    oldText: '> **시험 문구 해석**: "highly available" → Multi-AZ + 자동 복구 조합으로 답합니다. "fault tolerant" → 더 강한 요건으로, 완전한 능동 이중화를 암시합니다. "DR"이 나오면 `saa-t2-5`의 4전략으로 답합니다.',
    newText: '> **시험 문구 해석**: "highly available" → Multi-AZ + 자동 복구 조합으로 답합니다. "fault tolerant" → 더 강한 요건으로, 구성 요소가 실패해도 예비(중복) 구성 요소가 넘겨받아 중단 없이 동작하는 설계를 암시합니다. "DR"이 나오면 `saa-t2-5`의 4전략으로 답합니다.',
  ),
  (
    item: 'A12:105',
    file: 'saa/saa-t2-4.md',
    oldText: '> HA는 수 초~수 분의 짧은 중단을 허용하며 비용 대비 자동 복구를 목표로 하고, 내결함성은 중단 자체를 허용하지 않아 능동 이중화 비용이 훨씬 크며, DR은 리전 단위 재해를 대상으로 RTO/RPO로 목표를 수치화합니다.',
    newText: '> HA는 수 초~수 분의 짧은 중단을 허용하며 비용 대비 자동 복구를 목표로 하고, 내결함성은 구성 요소가 실패해도 중단 없이 동작하는 것이 목표라 예비(중복) 용량을 미리 갖추는 비용이 훨씬 크며, DR은 리전 단위 재해를 대상으로 RTO/RPO로 목표를 수치화합니다.',
  ),
  (
    item: 'A12:106',
    file: 'saa/saa-t2-4.md',
    oldText: '> "highly available"이라는 시험 문구는 Multi-AZ 자동 복구를 의미하고, "fault tolerant"는 그보다 강한 무중단 이중화를 암시하므로 두 키워드를 구분해 다른 설계로 답해야 합니다.',
    newText: '> "highly available"이라는 시험 문구는 Multi-AZ 자동 복구를 의미하고, "fault tolerant"는 그보다 강한, 예비 구성 요소가 넘겨받는 무중단 설계를 암시하므로 두 키워드를 구분해 다른 설계로 답해야 합니다.',
  ),
  (
    item: 'A12:466',
    file: 'saa/saa-t2-4.md',
    oldText: '| "fault tolerant" | 능동 이중화(Multi-AZ/Multi-Region)로 무중단 |',
    newText: '| "fault tolerant" | 예비(중복) 구성 요소가 넘겨받아 중단 없이 동작(Multi-AZ/Multi-Region 중복) |',
  ),
  (
    item: 'A13:199',
    file: 'saa/saa-t2-5.md',
    oldText: '> 이 OS 중립적 특성 덕분에 DRS는 온프레미스 Windows·Linux 서버와 타 클라우드 EC2를 추가 에이전트 없이 단일 방식으로 AWS에 복제할 수 있습니다.',
    newText: '> 이 OS 중립적 특성 덕분에 DRS는 온프레미스 Windows·Linux 서버와 다른 클라우드의 서버를, 소스 서버마다 AWS Replication Agent를 설치하는 단일 방식으로 AWS에 복제할 수 있습니다.',
  ),
  (
    item: 'A15:255',
    file: 'saa/saa-t2-5.md',
    oldText: '   (원리: §1 — RPO는 복구 가능한 가장 최근 시점까지의 거리이며, 백업 주기만큼 반드시 손실이 발생한다.)',
    newText: '   (원리: §1 — RPO는 복구 가능한 가장 최근 시점까지의 거리이며, 마지막 백업(또는 PITR이 닿는 시점) 이후의 변경은 잃을 수 있어 0이 되지 않는다.)',
  ),
  (
    item: 'A16:137',
    file: 'saa/saa-t2-5.md',
    oldText: '> Aurora Global Database는 RPO를 가장 낮추고 싶을 때 최선택입니다. "리전 간 1초 미만 복제"가 시험 문구로 자주 등장합니다.',
    newText: '> Aurora Global Database는 RPO를 가장 낮추고 싶을 때 최선의 선택입니다. "리전 간 1초 미만 복제"가 시험 문구로 자주 등장합니다.',
  ),
  (
    item: 'A17:75',
    file: 'saa/saa-t1-1.md',
    oldText: '| **SAML 2.0** | Security Assertion Markup Language | 기업 디렉터리(AD 등) IdP가 발급하는 XML 기반 인증 토큰 표준 |',
    newText: '| **SAML 2.0** | Security Assertion Markup Language | SAML 2.0 호환 IdP(AD FS·Shibboleth·Okta 등)가 발급하는 XML 기반 인증 토큰 표준 |',
  ),
  (
    item: 'A14:133',
    file: 'saa/saa-t2-5.md',
    oldText: '장애 시 1분 내 승격',
    newText: '장애 시 보조 리전 승격(RTO는 분 단위 — 제품 페이지는 1분 미만을 제시)',
  ),
  (
    item: 'A14:280',
    file: 'saa/saa-t2-5.md',
    oldText: '장애 시 1분 내 보조 리전을 Primary로 승격',
    newText: '장애 시 보조 리전을 Primary로 승격(RTO는 분 단위)',
  ),
  (
    item: 'A-01',
    file: 'saa/saa-t3-2.md',
    oldText: '> AZ를 넘어 연결하려면 이 내부 경로 대신 리전 간 네트워크를 거쳐야 해 지연시간이 크게 늘어나므로, AWS는 동일 AZ 내 연결만 허용해 일관된 저지연 성능을 유지합니다.',
    newText: '> AZ를 넘어 연결하려면 이 내부 경로 대신 AZ 간 네트워크를 거쳐야 해 지연시간이 늘어나므로, AWS는 동일 AZ 내 연결만 허용해 일관된 저지연 성능을 유지합니다.',
  ),
  (
    item: 'A-02:250',
    file: 'saa/saa-t3-2.md',
    oldText: '| **휘발성** | 인스턴스 중지·종료·하드웨어 장애 시 데이터 소실 |',
    newText: '| **휘발성** | 인스턴스 중지·최대 절전·종료·인스턴스 유형 변경, 기반 디스크 장애 시 데이터 소실 |',
  ),
  (
    item: 'A-02:255',
    file: 'saa/saa-t3-2.md',
    oldText: '> 인스턴스 재부팅(reboot)으로는 데이터가 유지됩니다. 중지(stop) 또는 종료(terminate)하면 소실됩니다.',
    newText: '> 인스턴스 재부팅(reboot)으로는 데이터가 유지됩니다. 중지(stop)·최대 절전(hibernate)·종료(terminate)하거나 인스턴스 유형을 바꾸면 소실됩니다.',
  ),
  (
    item: 'A-02:462',
    file: 'saa/saa-t3-2.md',
    oldText: '- **인스턴스 스토어 vs EBS**: 인스턴스 스토어는 인스턴스 중지·종료 시 데이터 소실(임시), EBS는 인스턴스와 독립적으로 데이터 유지(영속).',
    newText: '- **인스턴스 스토어 vs EBS**: 인스턴스 스토어는 인스턴스 중지·최대 절전·종료·유형 변경 시 데이터 소실(임시), EBS는 인스턴스와 독립적으로 데이터 유지(영속).',
  ),
  (
    item: 'A-02:484',
    file: 'saa/saa-t3-2.md',
    oldText: '5. **"인스턴스 스토어는 재부팅해도 데이터가 사라진다."** → 인스턴스 **재부팅**으로는 데이터가 유지됩니다. 데이터가 소실되는 시점은 인스턴스 **중지(stop)·종료(terminate)** 또는 하드웨어 장애입니다.',
    newText: '5. **"인스턴스 스토어는 재부팅해도 데이터가 사라진다."** → 인스턴스 **재부팅**으로는 데이터가 유지됩니다. 데이터가 소실되는 시점은 인스턴스 **중지(stop)·최대 절전(hibernate)·종료(terminate)·인스턴스 유형 변경** 또는 기반 디스크 장애입니다.',
  ),
  (
    item: 'A-02:527',
    file: 'saa/saa-t3-2.md',
    oldText: '반면 인스턴스 스토어는 인스턴스 중지·종료 또는 하드웨어 장애 시 데이터가 소실되는 임시 스토리지입니다.',
    newText: '반면 인스턴스 스토어는 인스턴스 중지·최대 절전·종료·유형 변경 또는 기반 디스크 장애 시 데이터가 소실되는 임시 스토리지입니다.',
  ),
  (
    item: 'A-03',
    file: 'saa/saa-t3-3.md',
    oldText: '| **최대 인스턴스 수** | 제한 없음(용량 의존) | AZ당 최대 7파티션, 인스턴스 수 제한 없음 | AZ당 최대 **7개** | 용량·지원 하드웨어 의존 |',
    newText: '| **최대 인스턴스 수** | 제한 없음(용량 의존) | AZ당 최대 7파티션, 인스턴스 수는 계정 한도까지 | AZ당 최대 **7개** | 용량·지원 하드웨어 의존 |',
  ),
  (
    item: 'A-04:121',
    file: 'saa/saa-t3-4.md',
    oldText: '| **AWS Batch** | 작업 단위 상태 | 무제한 | 자동 Compute Env | 낮음 | 대규모 배치, 완료 후 종료 |',
    newText: '| **AWS Batch** | 작업 단위 상태 | 고정 상한 없음(Fargate 리소스 작업은 14일) | 자동 Compute Env | 낮음 | 대규모 배치, 완료 후 종료 |',
  ),
  (
    item: 'A-04:310',
    file: 'saa/saa-t3-4.md',
    oldText: '| 실행 시간 제한 | 15분 | **무제한** |',
    newText: '| 실행 시간 제한 | 15분 | **고정 상한 없음**(Fargate 리소스 작업은 14일 한도) |',
  ),
  (
    item: 'A-05',
    file: 'saa/saa-t3-4.md',
    oldText: '   (원리: §4 본문 — Lambda 함수 타임아웃에는 상한(기본 15분)이 있어, 이를 초과하는 작업은 강제 종료된다.)',
    newText: '   (원리: §4 본문 — Lambda 함수 타임아웃에는 상한이 있어(기본값은 3초), 이를 초과하는 작업은 강제 종료된다.)',
  ),
  (
    item: 'A-07',
    file: 'saa/saa-t3-5.md',
    oldText: '5. **"운영 중 비암호화 RDS DB를 클릭 한 번으로 암호화할 수 있다."** → 불가. 스냅샷 생성 → 암호화 복사 → 복원의 절차가 필요합니다. 암호화는 생성 시에 설정하는 것이 권장됩니다.',
    newText: '5. **"운영 중 비암호화 RDS DB를 클릭 한 번으로 암호화할 수 있다."** → 불가. 그 자리에서(in-place) 전환할 수 없고, 대표 경로는 스냅샷 생성 → 암호화 복사 → 복원입니다(Blue/Green 배포에서 green 리소스에 `TargetKmsKeyId`를 지정하는 경로도 있습니다). 암호화는 생성 시에 설정하는 것이 권장됩니다.',
  ),
  (
    item: 'A-08:116',
    file: 'saa/saa-t3-5.md',
    oldText: '- 다른 AZ에 **동기 복제(synchronous)** 스탠바이 인스턴스를 유지합니다.',
    newText: '- Multi-AZ DB 인스턴스 배포는 다른 AZ에 **동기 복제(synchronous)** 스탠바이 인스턴스를 유지합니다(DB 클러스터 배포는 반동기 복제).',
  ),
  (
    item: 'A-08:176',
    file: 'saa/saa-t3-5.md',
    oldText: '| **복제 방식** | 동기(synchronous) | 비동기(asynchronous) |',
    newText: '| **복제 방식** | DB 인스턴스 배포는 동기(synchronous), DB 클러스터 배포는 반동기 | 비동기(asynchronous) |',
  ),
  (
    item: 'A-09:389',
    file: 'saa/saa-t3-6.md',
    oldText: '   (원리: §7 — Active-Active는 타임스탬프 기반 최후 작성자 우선으로 충돌을 처리하며 모든 리전에서 쓰기를 허용한다.)',
    newText: '   (원리: §7 — Active-Active는 모든 리전에서 쓰기를 허용하며, 기본 모드(MREC)에서는 타임스탬프 기반 최후 작성자 우선으로 충돌을 처리한다. MRSC에서는 충돌한 쓰기가 예외로 실패한다.)',
  ),
  (
    item: 'A-09:423',
    file: 'saa/saa-t3-6.md',
    oldText: '충돌은 최후 작성자 우선(last-writer-wins)으로 자동 해결됩니다.',
    newText: '충돌은 기본 모드(MREC)에서 최후 작성자 우선(last-writer-wins)으로 자동 해결됩니다.',
  ),
  (
    item: 'A-10',
    file: 'saa/saa-t3-6.md',
    oldText: '> 온디맨드 모드는 사전 처리량 설정 없이 AWS가 실시간 트래픽에 따라 용량을 조정하므로, 예측하기 어려운 스파이크 구간에서도 스로틀 없이 요청을 처리할 수 있습니다.',
    newText: '> 온디맨드 모드는 사전 처리량 설정 없이 AWS가 실시간 트래픽에 따라 용량을 조정하므로, 이전 최고치의 2배까지는 스파이크도 스로틀 없이 즉시 받습니다. 다만 30분 안에 이전 최고치의 2배를 넘으면 스로틀이 생길 수 있어, 그런 급증이 예상되면 사전 웜업이 필요합니다.',
  ),
  (
    item: 'A-11:286',
    file: 'saa/saa-t3-6.md',
    oldText: '| **영속성** | 스냅샷(RDB) + AOF 로그 **지원** | **없음** (메모리 한정) |',
    newText: '| **영속성** | 스냅샷(RDB) 백업 **지원**(AOF는 Redis OSS 2.8.22 이후 미지원) | 노드 기반은 **없음** (메모리 한정) — 서버리스 Memcached는 스냅샷 백업 지원 |',
  ),
  (
    item: 'A-11:287',
    file: 'saa/saa-t3-6.md',
    oldText: '| **복제·HA** | 복제 + **Multi-AZ 자동 Failover** 지원 | **없음** |',
    newText: '| **복제·HA** | 복제 + **Multi-AZ 자동 Failover** 지원 | 노드 기반은 **없음** — 서버리스 캐시는 여러 AZ에 복제 |',
  ),
  (
    item: 'A-12:43',
    file: 'saa/saa-t3-7.md',
    oldText: '- [ ] **로드 밸런서 성능 관점** — ALB·NLB·GLB의 성능 특성과 선택 기준을 설명할 수 있다',
    newText: '- [ ] **로드 밸런서 성능 관점** — ALB·NLB·GWLB의 성능 특성과 선택 기준을 설명할 수 있다',
  ),
  (
    item: 'A-12:252',
    file: 'saa/saa-t3-7.md',
    oldText: '| **GLB** (Gateway LB) | **L3** | 모든 IP 패킷·모든 포트 | 트래픽을 어플라이언스(방화벽·IDS 등)로 투명하게 전달 | 네트워크 어플라이언스 통합 |',
    newText: '| **GWLB** (Gateway LB) | **L3** | 모든 IP 패킷·모든 포트 | 트래픽을 어플라이언스(방화벽·IDS 등)로 투명하게 전달 | 네트워크 어플라이언스 통합 |',
  ),
  (
    item: 'A-13',
    file: 'saa/saa-t3-8.md',
    oldText: '- ⚠️ **원격 VPC의 보안 그룹을 TGW에서 참조할 수 없습니다.** VPC 피어링은 보안 그룹 참조를 지원하므로, "SG 참조로 소스를 제한하라"는 요구가 있으면 TGW 허브-스포크만으로는 충족되지 않습니다 — 이것이 피어링을 완전히 대체하지 못하는 대표적 이유입니다.',
    newText: '- ⚠️ **TGW 경유 보안 그룹 참조는 따로 켜야 동작합니다.** 보안 그룹 참조 지원을 **트랜짓 게이트웨이와 VPC 어태치먼트 양쪽에서 활성화**해야 같은 TGW에 붙은 VPC 사이에서 상대 보안 그룹을 참조할 수 있고, **인바운드 규칙에서만** 가능합니다(아웃바운드 규칙은 미지원). "SG 참조로 소스를 제한하라"는 요구에 TGW 허브-스포크를 쓰려면 이 설정이 전제입니다.',
  ),
  (
    item: 'A-14',
    file: 'saa/saa-t3-8.md',
    oldText: '> 이 중복 구조가 VPN 연결의 기본 가용성을 높이는 메커니즘이며, 두 터널을 동시에 활성화하면 부하 분산도 가능합니다.',
    newText: '> 이 중복 구조가 VPN 연결의 기본 가용성을 높이는 메커니즘입니다. 여러 터널에 트래픽을 나눠 싣는 부하 분산은 Transit Gateway에 종단하고 동적 라우팅(BGP)을 쓰는 ECMP 구성에서만 가능합니다.',
  ),
  (
    item: 'A-15:251',
    file: 'saa/saa-t3-8.md',
    oldText: '> 암호화가 필요한 규정 환경에서는 DX 위에 IPsec VPN 터널을 얹는 패턴으로 물리 회선의 낮은 지연과 전송 암호화를 함께 확보할 수 있습니다.',
    newText: '> 암호화가 필요한 규정 환경에서는 DX 위에 IPsec VPN 터널을 얹는 패턴으로 물리 회선의 낮은 지연과 전송 암호화를 함께 확보하거나, MACsec을 지원하는 연결이라면 MACsec으로 암호화할 수 있습니다.',
  ),
  (
    item: 'A-15:431',
    file: 'saa/saa-t3-8.md',
    oldText: '   (원리: §4 — 물리적 격리는 전송 계층 암호화가 아니며, 암호화가 필요하면 DX 위에 IPsec 터널을 얹어야 한다.)',
    newText: '   (원리: §4 — 물리적 격리는 전송 계층 암호화가 아니며, 암호화가 필요하면 DX 위에 IPsec 터널을 얹거나 MACsec을 써야 한다.)',
  ),
  (
    item: 'A-16',
    file: 'saa/saa-t3-9.md',
    oldText: '| 지연 | 분~시간 | 밀리초~초 |',
    newText: '| 지연 | 분~시간 | 밀리초~초 (Firehose는 버퍼 설정에 따라 수 초~수 분) |',
  ),
  (
    item: 'A-17',
    file: 'saa/saa-t4-2.md',
    oldText: '- 도메인 4(20%)는 시험 비중 3위입니다. "요구 조건을 충족하는 가장 저렴한 선택" 유형의 문제가 이 도메인에 집중됩니다.',
    newText: '- 도메인 4(20%)는 시험 비중 4위입니다. "요구 조건을 충족하는 가장 저렴한 선택" 유형의 문제가 이 도메인에 집중됩니다.',
  ),
  (
    item: 'A-18:331',
    file: 'saa/saa-t4-2.md',
    oldText: '> 🧠 원리: 왜 서버리스(Lambda·Fargate) 과금은 유휴 시 비용이 발생하지 않을까요?',
    newText: '> 🧠 원리: 왜 Lambda는 유휴 시 비용이 발생하지 않고, Fargate는 태스크가 떠 있는 동안 과금될까요?',
  ),
  (
    item: 'A-18:333',
    file: 'saa/saa-t4-2.md',
    oldText: '> Lambda와 Fargate는 요청이 들어올 때만 컨테이너·실행 환경을 프로비저닝하고 완료되면 자원을 반환하므로, 대기 상태에서 점유하는 컴퓨팅이 없어 과금도 발생하지 않습니다.',
    newText: '> Lambda는 요청이 들어올 때만 실행 환경에서 코드를 돌리고 그 실행 시간만큼만 과금하므로, 요청이 없는 대기 상태에서는 과금이 발생하지 않습니다(프로비저닝 동시성은 예외). Fargate는 서버 관리는 없지만 컨테이너 이미지를 내려받기 시작한 때부터 태스크가 종료될 때까지 요청 유무와 무관하게 과금됩니다.',
  ),
  (
    item: 'A-19',
    file: 'saa/saa-t4-1.md',
    oldText: '| 과잉 프로비전된 볼륨 | Amazon Compute Optimizer가 rightsizing 권장 |',
    newText: '| 과잉 프로비전된 볼륨 | AWS Compute Optimizer가 rightsizing 권장 |',
  ),
  (
    item: 'A-20',
    file: 'saa/saa-t4-1.md',
    oldText: '| **IOPS** | Input/Output Operations Per Second | 디스크가 초당 처리할 수 있는 읽기·쓰기 횟수 — 크고 클수록 빠르지만 비용도 증가 |',
    newText: '| **IOPS** | Input/Output Operations Per Second | 디스크가 초당 처리할 수 있는 읽기·쓰기 횟수 — 클수록 빠르지만 비용도 증가 |',
  ),
  (
    item: 'A-21',
    file: 'saa/saa-t4-4.md',
    oldText: '> Interface Endpoint(PrivateLink)는 VPC 내부에 ENI를 생성해 서비스마다 프라이빗 IP를 부여하는 방식으로, 200개 이상의 다양한 서비스에 적용 가능합니다. 대신 AZ별 시간 요금과 데이터 처리 요금이 발생합니다.',
    newText: '> Interface Endpoint(PrivateLink)는 VPC 내부에 ENI를 생성해 서비스마다 프라이빗 IP를 부여하는 방식으로, 다수의 AWS 서비스에 적용 가능합니다. 대신 AZ별 시간 요금과 데이터 처리 요금이 발생합니다.',
  ),
  (
    item: 'A-22',
    file: 'saa/saa-t3-2.md',
    oldText: 'FSx for OpenZFS **디스크 IOPS 수치**(C-16 — 이 문서 §7의 "최대 2,000,000 IOPS"는 공식 미확인으로 열려 있는 별건 `[의심]` 항목이라 이번 배치에서 건드리지 않았습니다)',
    newText: 'FSx for OpenZFS **디스크 IOPS 수치**(C-16 — 이 문서 §7의 "최대 2,000,000 IOPS"는 2026-11-22에 공식 소개 페이지로 확인했습니다. 디스크에서 읽는 데이터의 상한은 따로 400,000 IOPS입니다)',
  ),
];

const _files = <String>[
  'clf/t2-4.md',
  'clf/t4-1.md',
  'saa/saa-t1-1.md',
  'saa/saa-t1-2.md',
  'saa/saa-t1-3.md',
  'saa/saa-t1-4.md',
  'saa/saa-t1-5.md',
  'saa/saa-t2-1.md',
  'saa/saa-t2-2.md',
  'saa/saa-t2-4.md',
  'saa/saa-t2-5.md',
  'saa/saa-t3-2.md',
  'saa/saa-t3-3.md',
  'saa/saa-t3-4.md',
  'saa/saa-t3-5.md',
  'saa/saa-t3-6.md',
  'saa/saa-t3-7.md',
  'saa/saa-t3-8.md',
  'saa/saa-t3-9.md',
  'saa/saa-t4-1.md',
  'saa/saa-t4-2.md',
  'saa/saa-t4-4.md',
];

const _addedSources = <String, List<String>>{
  'saa/saa-t3-5.md': [
    'https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_TargetResourceConfiguration.html',
  ],
  'saa/saa-t3-6.md': [
    'https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/backups.html',
    'https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/ParameterGroups.Engine.html',
  ],
};

String _read(String file) => File('assets/content/$file')
    .readAsStringSync()
    .replaceAll('\r\n', '\n');

void main() {
  test('대조군: 대상 문서를 실제로 읽는다', () {
    for (final file in _files) {
      expect(File('assets/content/$file').existsSync(), isTrue, reason: file);
      expect(_read(file), contains('lastVerified:'), reason: file);
    }
    expect(_read('clf/t2-4.md'), contains('Trusted Advisor'));
    expect(_read('saa/saa-t2-5.md'), contains('Aurora Global Database'));
  });

  group('판정 채택 문구', () {
    for (final fix in _fixes) {
      test('${fix.item} (${fix.file})', () {
        final text = _read(fix.file);
        final oldText = fix.oldText;
        if (oldText != null) {
          expect(text.contains(oldText), isFalse, reason: '옛 문구가 남았다');
        }
        expect(text, contains(fix.newText));
      });
    }
  });

  test('온디맨드 2배·30분 규칙을 본문이 적으면 메모가 「공식에 없다」고 하지 않는다', () {
    final text = _read('saa/saa-t3-6.md');
    expect(text, contains('이전 최고치의 2배'));
    expect(text, isNot(contains('"이전 피크 2배·30분 규칙"')));
  });

  test('추가한 출처가 프런트매터와 참고자료 양쪽에 있다', () {
    _addedSources.forEach((file, urls) {
      final text = _read(file);
      final end = text.indexOf('lastVerified:');
      for (final url in urls) {
        expect(text.substring(0, end), contains('url: $url'), reason: url);
        expect(text.substring(end), contains('— $url'), reason: url);
      }
    });
  });
}
