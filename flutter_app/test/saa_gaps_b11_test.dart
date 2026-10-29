import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 **B11** — 갭 노트 `[누락]`·`[부분]` **8행** + B3에서 넘어온
/// 잔여 2건 (2026-10-30).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B11".
/// B1~B10 이 끝나 **134행 배정의 마지막 배치**다.
///
/// ## ⚠️ 세 문서 모두 `verified:true` 라이브다
///
/// `saa-t1-1`·`saa-t1-4`·`saa-t2-5` 는 2026-10-29 전 Task flip(#272·#273)으로
/// 문항이 라이브다. B11 이 원래 "사람 flip 이후"로 미뤄져 있던 이유가 그것이고,
/// flip 이 끝나 조건이 소멸했다. 그래서 **문항과 어긋나지 않는지**를 저작 전에
/// 전수 대조했다(결과는 PR 본문).
///
/// ## ⚠️ 조사 노트와 다르게 쓴 것 — 공식 문서 실측이 이긴다
///
/// 1. **역할 체이닝 1시간은 콘솔에도 적용된다.** 조사 노트 `1-1.md` F-08 은
///    출처가 SDK 문서이고 "CLI/API" 로만 적었으나, 공식
///    `id_roles_terms-and-concepts` 는 **"AWS Management Console, AWS CLI or AWS
///    API"** 를 모두 적고 "콘솔은 예외" 서술이 없다. 콘솔 전환의 세션 규칙
///    (`reference_iam-quotas` 의 "maximum session duration or the remaining
///    time") 은 **사용자 → 역할** 전환이라 다른 사실이다 — 둘을 섞으면 안 된다.
/// 2. **Shield Advanced "1년 약정" 은 쓰지 않았다.** 갭 노트 G-1.2-11 과 조사
///    노트 F-21 이 요구하지만 `aws.amazon.com/shield/faqs/` 전문에 commitment
///    문장이 **없다**(실측). `99-gaps.md` 규율대로 근거 미확보 주장은 쓰지 않고
///    판정을 노트에 남겼다. ⚠️ 그래서 **금지 가드로도 걸지 않는다** — 뒤에
///    근거가 확인되면 막히고, "1년 약정은 확인되지 않았다" 같은 **옳은 문장**이
///    걸린다(맵 §4 "가드 설계" 교훈 1~5).
/// 3. **Detective 데이터원에 EKS 감사 로그를 쓰지 않았다.** 조사 노트 `1-2.md`
///    F-28 이 적지만 공식 `what-is-detective` 에서 EKS 감사 로그는 **Security
///    Lake 가 지원하는 로그 목록**에만 나오고 Detective 수집원으로 적히지 않는다.
/// 4. **HopLimit 기본값을 쓰지 않았다.** `API_ModifyInstanceMetadataOptions` 에
///    기본값 수치가 없다(예시 응답의 `1` 은 샘플 값이다).
///
/// ## ⚠️ 출처 URL 은 전수 실측했다 — 3건이 리다이렉트였다
///
/// `docs.aws.amazon.com` 은 없는 페이지에도 200 을 주고 그 가이드 인덱스로
/// 보내므로 판정 신호는 **`num_redirects`** 다(#280 교훈). 24개 중 3건이 걸렸다:
/// `id_roles_create_for-user_externalid` → `id_roles_common-scenarios_third-party`
/// (이름 변경) · `declarative_policies` → userguide 인덱스(**소멸**, 정본은
/// `orgs_manage_policies_declarative`) · `detective/latest/adminguide/…` →
/// userguide 인덱스(**가이드 이름 변경**, 정본은 `detective/latest/userguide/…`).
/// 죽은 쪽 두 건은 아래에서 0건으로 고정한다.
///
/// ## ⚠️ 기존 가드와 겹치지 않게
///
/// `saa_t1_facts_test` 가 `saa-t1-1` 에서 `Directory Service`·`Identity Center
/// 디렉터리`·`Entra ID`/`Okta`·`합집합`·`양쪽 계정`·`KMS`·`14일`·`중앙 루트 접근
/// 관리` 를 요구하고 `Active Directory 등 SAML 2.0 IdP` 를 금지한다.
/// `saa_t12_t13_facts_test` 가 `saa-t1-4` 에서 `CLOUDFRONT`·`us-east-1`·`비종료`·
/// `AWSManagedRulesAntiDDoSRuleSet` 등을 요구하고, `saa_t2_t4_facts_test` 가
/// `saa-t2-5` 에서 `MREC`·`MRSC`·`GlobalTables` 를 요구한다. 그 서술은 손대지
/// 않았고, 이 파일은 거기서 다루지 않는 축만 본다.
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처 절 이전 본문. 요구를 본문에 한정할 때 쓴다.
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B11 G-1.1-01 — 디렉터리 서비스 연동 시점 (saa-t1-1)', () {
    // 공식: "AWS Managed Microsoft AD is your best choice if you have more than
    //       5,000 users" · "Simple AD does not support trust relationships."
    //       · "AD Connector ... use your existing on-premises directory"
    test('Managed AD·AD Connector·Simple AD 의 선택 기준을 적는다', () {
      final t = body('saa-t1-1');
      expect(t.contains('5,000'), isTrue, reason: 'Managed AD 사용자 수 기준 누락');
      expect(t.contains('AD Connector'), isTrue);
      expect(t.contains('신뢰 관계'), isTrue, reason: 'Managed AD 신뢰 관계 기준 누락');
    });

    // 공식: "Simple AD is no longer open to new customers."
    test('Simple AD 가 신규 고객에게 닫혔다는 현행 상태를 적는다', () {
      expect(body('saa-t1-1').contains('신규 고객'), isTrue);
    });

    test('Directory Service 공식 출처를 싣는다', () {
      final t = doc('saa-t1-1');
      expect(t.contains('simple_ad_best_practices'), isTrue);
      expect(t.contains('directory_simple_ad'), isTrue);
    });
  });

  group('B11 G-1.1-03 — 리소스 정책 사용 결정 (saa-t1-1)', () {
    // 공식 갈림길: 리소스 정책 경로는 "does not have to give up their
    //            permissions", 역할 수임은 "they give up their original
    //            permissions and take on the permissions assigned to the role".
    test('리소스 정책은 원 권한을 유지하고 역할 수임은 내려놓는다고 적는다', () {
      final t = body('saa-t1-1');
      expect(t.contains('원래 권한'), isTrue, reason: '선택 기준의 핵심 축 누락');
      expect(t.contains('내려놓'), isTrue, reason: '역할 수임 쪽 대비 누락');
    });

    // 공식: "The following list includes some of the AWS services that support
    //       resource-based policies." — S3 버킷·SNS 주제·SQS 큐.
    test('리소스 정책을 지원하는 서비스 예시를 적는다', () {
      final t = body('saa-t1-1');
      expect(t.contains('SNS'), isTrue);
      expect(t.contains('SQS'), isTrue);
    });

    test('교차 계정 리소스 접근 공식 출처를 싣는다', () {
      expect(
          doc('saa-t1-1')
              .contains('access_policies-cross-account-resource-access'),
          isTrue);
    });
  });

  group('B11 G-1.1-04 — 역할 전환·체이닝·외부 ID (saa-t1-1)', () {
    // 공식: "Role chaining limits your AWS Management Console, AWS CLI or AWS
    //       API role session to a maximum of one hour." + "It applies
    //       regardless of the maximum session duration configured for
    //       individual roles."
    // 교정 문맥 요구 — 체이닝을 적으면 1시간과 "개별 역할 설정과 무관"이 함께 있어야
    // 한다. 콘솔을 뺀 서술은 공식과 어긋나므로 적용 범위도 함께 요구한다.
    test('역할 체이닝을 적으면 1시간 상한과 적용 범위를 함께 적는다', () {
      final t = body('saa-t1-1');
      if (t.contains('역할 체이닝')) {
        expect(t.contains('1시간'), isTrue, reason: '체이닝 상한 누락');
        expect(t.contains('개별 역할'), isTrue,
            reason: '"개별 역할의 최대 세션과 무관" 서술 누락');
        expect(t.contains('콘솔'), isTrue,
            reason: '공식은 콘솔·CLI·API 모두에 적용된다고 적는다');
      }
    });

    // 공식: "IAM users who switch roles in the console are granted the maximum
    //       session duration or the remaining time in the user's session,
    //       whichever is less" — 체이닝(역할 → 역할)과 다른 사실이다.
    test('콘솔에서 사용자가 역할로 전환할 때의 세션 규칙을 적는다', () {
      final t = body('saa-t1-1');
      expect(t.contains('남은'), isTrue, reason: '남은 세션 시간 비교 누락');
      expect(t.contains('짧은'), isTrue, reason: '"짧은 쪽" 규칙 누락');
    });

    // 공식: "The primary function of the external ID is to address and prevent
    //       the confused deputy problem" + "AWS does not treat the external ID
    //       as a secret".
    test('외부 ID·혼동된 대리인을 적고 비밀이 아니라는 점을 밝힌다', () {
      final t = body('saa-t1-1');
      expect(t.contains('외부 ID') || t.contains('ExternalId'), isTrue);
      expect(t.contains('혼동된 대리인'), isTrue);
      expect(t.contains('비밀'), isTrue, reason: '"비밀이 아니다" 서술 누락');
    });

    test('역할 용어·제3자 접근 공식 출처를 싣는다', () {
      final t = doc('saa-t1-1');
      expect(t.contains('id_roles_terms-and-concepts'), isTrue);
      expect(t.contains('id_roles_common-scenarios_third-party'), isTrue);
    });

    // 실측(2026-10-30): 요청하면 `id_roles_common-scenarios_third-party` 로
    // 리다이렉트되는 옛 슬러그다.
    test('죽은 externalid 슬러그를 쓰지 않는다', () {
      expect(doc('saa-t1-1').contains('id_roles_create_for-user_externalid'),
          isFalse);
    });
  });

  group('B11 G-1.1-05 — RCP·선언적 정책 (saa-t1-1)', () {
    test('정책 유형 표에 RCP 와 역할 신뢰 정책이 있다', () {
      final t = body('saa-t1-1');
      expect(t.contains('RCP'), isTrue);
      expect(t.contains('신뢰 정책'), isTrue);
    });

    // 공식 Note 의 구분: SCP 는 "limit permissions of IAM principals"(조직 내
    // 주체), RCP 는 "IAM principals that are external to your organization".
    test('RCP 가 조직 밖 주체의 접근을 제한한다는 공식 구분을 적는다', () {
      expect(body('saa-t1-1').contains('조직 밖'), isTrue);
    });

    // 공식: "RCPs apply to resources for a subset of AWS services" — 지원 목록이
    //       62개 서비스이고 EC2 단독·RDS·Lambda 는 거기에 없다.
    test('RCP 적용 범위가 일부 서비스임을 적고 전 서비스로 단정하지 않는다', () {
      final t = body('saa-t1-1');
      expect(t.contains('일부 서비스'), isTrue, reason: 'RCP 적용 범위 한정 누락');
      expect(t.contains('모든 AWS 서비스의 리소스에 적용'), isFalse);
    });

    // 공식 한도표: 직접 연결 SCP 10 / RCP 5, 문서 크기 SCP 10,240자 · RCP 5,120자.
    test('직접 연결 한도와 정책 문서 크기를 적는다', () {
      final t = body('saa-t1-1');
      expect(t.contains('10,240'), isTrue);
      expect(t.contains('5,120'), isTrue);
    });

    // 공식: "declarative policies are applied directly at the service level" +
    //       "block public internet access to Amazon VPC resources" 예시.
    test('선언적 정책이 서비스 수준에서 적용된다고 적는다', () {
      final t = body('saa-t1-1');
      expect(t.contains('선언적 정책'), isTrue);
      expect(t.contains('서비스 수준'), isTrue);
    });

    test('Organizations 공식 출처를 싣는다', () {
      final t = doc('saa-t1-1');
      expect(t.contains('orgs_manage_policies_rcps'), isTrue);
      expect(t.contains('orgs_manage_policies_declarative'), isTrue);
      expect(t.contains('orgs_reference_limits'), isTrue);
    });

    // 실측(2026-10-30): userguide 인덱스로 리다이렉트되는 죽은 슬러그다.
    test('죽은 declarative_policies 슬러그를 쓰지 않는다', () {
      expect(doc('saa-t1-1').contains('declarative_policies.html'), isFalse);
    });
  });

  group('B11 G-1.2-02 잔여 — AWS STS 엔드포인트 (saa-t1-1)', () {
    // 공식: "AWS recommends using Regional AWS Security Token Service (AWS STS)
    //       endpoints" + 글로벌은 "hosted in a single AWS Region, US East (N.
    //       Virginia)" 이고 "doesn't provide automatic failover".
    test('리전 엔드포인트 권장과 글로벌 엔드포인트의 단일 리전 호스팅을 적는다', () {
      final t = body('saa-t1-1');
      expect(t.contains('리전 엔드포인트'), isTrue);
      expect(t.contains('자동 페일오버'), isTrue, reason: '글로벌 엔드포인트의 한계 누락');
    });

    // 공식: "Session tokens from Regional AWS STS endpoints are valid in all
    //       AWS Regions." / 글로벌 토큰은 "valid only in AWS Regions that are
    //       enabled by default."
    test('세션 토큰의 유효 범위 차이를 적는다', () {
      final t = body('saa-t1-1');
      expect(t.contains('세션 토큰'), isTrue);
      expect(t.contains('기본적으로 활성화') || t.contains('기본 활성'), isTrue,
          reason: '글로벌 엔드포인트 토큰의 유효 범위 조건 누락');
    });

    test('STS 엔드포인트 공식 출처를 싣는다', () {
      expect(doc('saa-t1-1').contains('id_credentials_temp_enable-regions'),
          isTrue);
    });
  });

  group('B11 G-1.2-11 — Shield Advanced 요금·SRT 조건 (saa-t1-4)', () {
    // 공식 FAQ: "you pay a monthly fee of \$3,000 per month per organization" +
    //          "You will pay the monthly fee once" (통합 결제) + "you also pay
    //          for AWS Shield Advanced Data Transfer usage fees".
    // ⚠️ 요금 축만 요구한다 — 리전 의존 단가는 쓰지 않는다(맵 §5 G-02).
    test('요금 축을 적는다: 월 고정 요금·조직 단위·통합 결제 1회·데이터 전송 별도', () {
      final t = body('saa-t1-4');
      expect(t.contains('3,000'), isTrue);
      expect(t.contains('조직'), isTrue);
      expect(t.contains('통합 결제'), isTrue);
      expect(t.contains('데이터 전송'), isTrue);
    });

    // 공식 FAQ: "you need a Business or Enterprise support plan in order to
    //          escalate to or engage the AWS Shield Response Team (SRT)."
    test('SRT 연락에 Business·Enterprise Support 플랜이 필요하다고 적는다', () {
      final t = body('saa-t1-4');
      expect(t.contains('Business'), isTrue);
      expect(t.contains('Enterprise'), isTrue);
    });

    // 정정: 구독만으로 SRT 를 쓸 수 있다고 읽히던 단정을 지웠다.
    test('"Advanced 가입 시에만 이용 가능" 이라는 구식 단정이 남아 있지 않다', () {
      expect(doc('saa-t1-4').contains('가입 시에만 이용 가능'), isFalse);
    });

    // 공식: "Your Shield Advanced subscription covers the costs of using
    //       standard AWS WAF capabilities" — "up to 1,500 WCUs", 자동 L7 완화
    //       규칙 그룹은 "uses 150 web ACL capacity units (WCUs)".
    test('표준 WAF 비용 포함 범위와 자동 L7 완화 규칙 그룹의 WCU 를 적는다', () {
      final t = body('saa-t1-4');
      expect(t.contains('1,500'), isTrue);
      expect(t.contains('150'), isTrue);
      expect(t.contains('WCU'), isTrue);
    });

    test('Shield FAQ·WAF 결정 공식 출처를 싣는다', () {
      final t = doc('saa-t1-4');
      expect(t.contains('shield/faqs'), isTrue);
      expect(t.contains('ddos-advanced-summary-deciding'), isTrue);
    });
  });

  group('B11 G-1.2-05 — IMDSv2 강제·Session Manager (saa-t1-4)', () {
    // 공식: `HttpTokens=required` → "IMDSv2 is required. You must send a session
    //       token" + "IMDSv1 credentials are not available."
    test('IMDSv2 강제 수단과 효과를 적는다', () {
      final t = body('saa-t1-4');
      expect(t.contains('IMDSv2'), isTrue);
      expect(t.contains('HttpTokens'), isTrue);
      expect(t.contains('IMDSv1'), isTrue, reason: 'optional 과의 대비 누락');
    });

    // 공식: "without the need to open inbound ports, maintain bastion hosts, or
    //       manage SSH keys" + "permissions to managed nodes are provided
    //       through IAM policies instead of SSH keys".
    test('Session Manager 가 무엇을 불필요하게 만드는지 적는다', () {
      final t = body('saa-t1-4');
      expect(t.contains('Session Manager'), isTrue);
      expect(t.contains('배스천'), isTrue);
      expect(t.contains('SSH 키'), isTrue);
    });

    // 교정 문맥 요구 — 공식이 적는 예외다: "Logging isn't available for Session
    // Manager sessions that connect through port forwarding or SSH."
    test('세션 로깅을 적으면 포트 포워딩·SSH 예외도 함께 적는다', () {
      final t = body('saa-t1-4');
      if (t.contains('세션 로그') || t.contains('세션 로깅')) {
        expect(t.contains('포트 포워딩'), isTrue,
            reason: '로깅이 안 되는 경로(포트 포워딩·SSH)를 함께 적어야 한다');
      }
    });

    test('EC2 메타데이터·Session Manager 공식 출처를 싣는다', () {
      final t = doc('saa-t1-4');
      expect(t.contains('API_ModifyInstanceMetadataOptions'), isTrue);
      expect(t.contains('session-manager'), isTrue);
    });
  });

  group('B11 G-1.2-01 잔여 — GuardDuty·Detective (saa-t1-4)', () {
    // 공식: "Amazon GuardDuty is a threat detection service" + 기본 데이터원
    //       "AWS CloudTrail management events, VPC flow logs ... and DNS logs".
    test('GuardDuty 를 위협 탐지로 정의하고 기본 데이터원을 적는다', () {
      final t = body('saa-t1-4');
      expect(t.contains('GuardDuty'), isTrue);
      expect(t.contains('CloudTrail'), isTrue);
      expect(t.contains('흐름 로그') || t.contains('Flow Logs'), isTrue);
      expect(t.contains('DNS'), isTrue);
    });

    // 공식: "helps you analyze, investigate, and quickly identify the root
    //       cause of security findings or suspicious activities."
    test('Detective 를 근본 원인 조사로 적는다', () {
      final t = body('saa-t1-4');
      expect(t.contains('Detective'), isTrue);
      expect(t.contains('근본 원인'), isTrue);
    });

    test('GuardDuty·Detective 공식 출처를 싣는다', () {
      final t = doc('saa-t1-4');
      expect(t.contains('what-is-guardduty'), isTrue);
      expect(t.contains('detective/latest/userguide/what-is-detective'), isTrue);
    });

    // 실측(2026-10-30): adminguide 는 userguide 인덱스로 리다이렉트된다.
    test('죽은 detective adminguide 슬러그를 쓰지 않는다', () {
      expect(doc('saa-t1-4').contains('detective/latest/adminguide'), isFalse);
    });
  });

  group('B11 G-2.2-10 — ARC 기능 구분 (saa-t2-5)', () {
    // 공식 what-is: 다중 AZ(zonal shift·zonal autoshift) / 다중 리전(Region
    //              switch·routing control) + readiness check.
    test('ARC 의 공식 기능 5종을 적는다', () {
      final t = body('saa-t2-5');
      expect(t.contains('zonal shift'), isTrue);
      expect(t.contains('zonal autoshift'), isTrue);
      expect(t.contains('routing control'), isTrue);
      expect(t.contains('Region switch'), isTrue);
      expect(t.contains('readiness check'), isTrue);
    });

    // 공식: "from one minute up to three days (72 hours), which you can extend"
    //       + "All zonal shifts are temporary mitigations." + "you must
    //       prescale your application".
    test('zonal shift 의 임시 성격·최대 기간·사전 용량 요건을 적는다', () {
      final t = body('saa-t2-5');
      expect(t.contains('72시간') || t.contains('3일'), isTrue);
      expect(t.contains('임시'), isTrue);
      expect(t.contains('사전'), isTrue, reason: 'prescale 요건 누락');
    });

    // 공식 비교표: zonal shift·autoshift "Included with services (no additional
    //            charge)" / routing control·Region switch "Fee-based".
    test('기능별 요금 구분을 적는다', () {
      final t = body('saa-t2-5');
      expect(t.contains('추가 요금'), isTrue);
      expect(t.contains('별도 요금'), isTrue);
    });

    // 정정: 기능 구분이 없던 거친 한 줄을 교체했다.
    test('"수동 페일오버 스크립트 제어용 스위치" 라는 한 줄이 남아 있지 않다', () {
      expect(doc('saa-t2-5').contains('수동 페일오버 스크립트 제어용 스위치'), isFalse);
    });

    test('ARC 공식 출처를 싣는다', () {
      final t = doc('saa-t2-5');
      expect(t.contains('what-is-route53-recovery'), isTrue);
      expect(t.contains('arc-zonal-shift'), isTrue);
      expect(t.contains('compare-capabilities'), isTrue);
    });
  });

  group('B11 G-2.2-12 — DR 전략 공식 수치·쿼터·페일백 (saa-t2-5)', () {
    // 공식 REL13-BP02: Backup and restore "(RPO in hours, RTO in 24 hours or
    //       less)" · Pilot light "(RPO in minutes, RTO in tens of minutes)" ·
    //       Warm standby "(RPO in seconds, RTO in minutes)" · Multi-site
    //       active-active "(RPO near zero, RTO potentially zero)".
    test('REL13-BP02 의 전략별 RPO·RTO 수치를 적는다', () {
      final t = body('saa-t2-5');
      expect(t.contains('24시간 이하'), isTrue, reason: 'B&R 공식 RTO 누락');
      expect(t.contains('수십 분'), isTrue, reason: 'Pilot Light 공식 RTO 누락');
      expect(t.contains('REL13-BP02'), isTrue, reason: '수치의 출처 근거 누락');
    });

    // 공식: "your standby Region often runs at reduced capacity until you need
    //       to recover into it" + "This gap can cause a healthy-looking plan to
    //       fail during execution".
    test('대기 리전의 축소 용량과 쿼터 함정을 적는다', () {
      final t = body('saa-t2-5');
      expect(t.contains('축소 용량'), isTrue);
      expect(t.contains('쿼터'), isTrue);
    });

    // 공식: "Design a plan for how your workload will fail back." + "Failback
    //       is when you return workload operation to the primary Region".
    test('페일백 계획을 적는다', () {
      expect(body('saa-t2-5').contains('페일백'), isTrue);
    });

    test('Well-Architected·Region switch 쿼터 공식 출처를 싣는다', () {
      final t = doc('saa-t2-5');
      expect(t.contains('rel_planning_for_recovery_disaster_recovery'), isTrue);
      expect(t.contains('working-with-rs-service-quota-checks'), isTrue);
    });
  });
}
