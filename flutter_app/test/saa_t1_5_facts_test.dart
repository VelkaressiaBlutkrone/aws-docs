import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA Task 1.3(`saa-t1-5`) 문항 재검수 가드 (2026-10-20).
///
/// **원인**: `saa-t1-5.md` 는 2026-10-19에 8건 정정됐는데(md 정정 로그) 그 정정이
/// 파생 문항에 전파되지 않았다. 내용 결함 5건이 전부 md가 이미 바로잡은 항목이었다.
/// 아래 가드는 문항을 md와 같은 공식 사실로 맞춘 상태를 고정한다.
///
/// `correct`(정답 인덱스)는 15문항 **전부 바뀌지 않았다** — 루브릭 §3의
/// `fix`(해설·보기 표현) / `resource`(출처 교체) 판정뿐이고 `rewrite`·`drop`은 0건이다.
///
/// 가드 규율(2026-10-20 교훈 `saa-t1-4-q10`): 쌍 단정에서 **금지할 것만 고정하고
/// 요구는 느슨하게** 둔다. 고쳐 넣은 문장을 그대로 못박으면 다음 재검수에서
/// 테스트가 먼저 터진다.
///
/// - `q2` AWS 관리형 키는 **내 계정에 존재**하고 조회·감사할 수 있다. 관리 못 하는
///   것은 수명 주기와 권한(키 정책)이다 — "AWS 소유"는 별개 키 유형이다.
///   근거: https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html
/// - `q3` 직접 암호화 상한 4KB와 봉투 암호화는 인용했던 KMS 개요에 없다.
///   근거: https://docs.aws.amazon.com/kms/latest/cryptographic-details/encrypt-operation.html
///   ("limit of 4 KB on the amount of plaintext ... in a direct call") ·
///   https://docs.aws.amazon.com/kms/latest/developerguide/kms-cryptography.html
/// - `q4` **기본 키 정책이 IAM 정책을 활성화**한다. 역할이 키 정책에 Principal로
///   적혀 있지 않아도 계정 위임 문장이 있으면 접근된다 — "교집합"은 과단정.
///   근거: https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
///   ("Unless the key policy explicitly allows it ... The default key policy
///    enables IAM policies.")
/// - `q5` 갈림길은 **단일 테넌트**다. AWS는 모든 키 저장소가 "AWS 운영자를 포함해
///   누구도 평문 키에 접근하지 못하게" 설계됐다고 밝히므로 "KMS는 AWS가 키에
///   접근한다"는 근거를 쓸 수 없다. KMS 표준 HSM도 FIPS 140-3 Level 3 검증이다.
///   근거: https://docs.aws.amazon.com/kms/latest/developerguide/key-store-overview.html
///   ("tenant-agnostic fleet of HSMs" · "requirements that explicitly mandate
///    key material protection in a single-tenant HSM")
/// - `q7` **완전 자동 갱신은 DNS 검증**으로 발급한 인증서다. 이메일 검증은 ACM이
///   알림 메일을 보내고 소유자가 응답해야 한다. 가져온(imported) 인증서는 비적격.
///   근거: https://docs.aws.amazon.com/acm/latest/userguide/managed-renewal.html ·
///   https://docs.aws.amazon.com/acm/latest/userguide/dns-renewal-validation.html
/// - `q8` "CloudFront 컨트롤 플레인이 배포 설정을 엣지 PoP에 복제한다"는 기전은
///   **공식 근거를 찾지 못했다**. 공식 문구는 us-east-1 인증서가 배포에 연결되면
///   "그 배포에 설정된 모든 지리적 위치로 배포된다"까지다.
///   근거: https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html
/// - `q13` Vault Lock 유예(grace time)는 **내가 지정**하며 72시간 쿨오프 때문에
///   **최소 3일**, 최대 36,500일이다 — "기본 3일"이 아니다.
///   근거: https://docs.aws.amazon.com/aws-backup/latest/devguide/vault-lock.html
/// - `q9`·`q10`·`q14`·`q15` 인용 URL이 주제와 맞지 않았다(KMS 개요 복붙).
///   근거: https://docs.aws.amazon.com/macie/latest/user/what-is-macie.html ·
///   https://docs.aws.amazon.com/inspector/latest/user/what-is-inspector.html ·
///   https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html ·
///   https://docs.aws.amazon.com/kms/latest/developerguide/logging-using-cloudtrail.html
void main() {
  Map<String, dynamic> question(String taskId, String qid) {
    final file = File('assets/content/saa/$taskId.questions.json');
    final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    final questions = (map['questions'] as List).cast<Map<String, dynamic>>();
    return questions.firstWhere(
      (q) => q['id'] == qid,
      orElse: () => fail('$qid 문항이 $taskId 에 없다'),
    );
  }

  String wrong(Map<String, dynamic> q, String index) =>
      (q['wrongExplanations'] as Map<String, dynamic>)[index] as String;

  String option(Map<String, dynamic> q, int index) =>
      (q['options'] as List)[index] as String;

  bool hasSource(Map<String, dynamic> q, String fragment) =>
      (q['sources'] as List).any(
        (s) => ((s as Map<String, dynamic>)['url'] as String).contains(fragment),
      );

  /// 주제가 맞지 않는 복붙 출처(KMS 개요). `key-store-overview.html`·
  /// `key-policy-overview.html` 처럼 끝이 `overview.html` 인 다른 페이지와
  /// 섞이지 않도록 디렉터리까지 붙여 맞춘다.
  const kmsOverview = 'developerguide/overview.html';

  group('정답 인덱스·보기 수 불변 (재검수가 정답을 바꾸지 않았다)', () {
    const expected = <String, int>{
      'saa-t1-5-q1': 0,
      'saa-t1-5-q2': 2,
      'saa-t1-5-q3': 3,
      'saa-t1-5-q4': 1,
      'saa-t1-5-q5': 0,
      'saa-t1-5-q6': 0,
      'saa-t1-5-q7': 2,
      'saa-t1-5-q8': 2,
      'saa-t1-5-q9': 1,
      'saa-t1-5-q10': 3,
      'saa-t1-5-q11': 0,
      'saa-t1-5-q12': 2,
      'saa-t1-5-q13': 1,
      'saa-t1-5-q14': 1,
      'saa-t1-5-q15': 3,
    };
    expected.forEach((qid, correct) {
      test('$qid 정답 $correct · 보기 4개', () {
        final q = question('saa-t1-5', qid);
        expect(q['correct'], correct);
        expect((q['options'] as List).length, 4);
      });
    });
  });

  group('saa-t1-5-q2 AWS 관리형 키 vs AWS 소유 키', () {
    final q = question('saa-t1-5', 'saa-t1-5-q2');

    test('"AWS 소유로" 라는 오분류가 사라졌다', () {
      expect(wrong(q, '1').contains('AWS 소유로'), isFalse,
          reason: 'AWS 관리형 키는 내 계정에 존재한다 — AWS 소유 키는 별개 유형이다');
    });

    test('관리형 키가 내 계정에 있다는 사실이 들어왔다', () {
      expect(wrong(q, '1').contains('내 계정'), isTrue);
    });

    test('연 1회 자동 교체라는 공식 사실은 유지된다', () {
      expect(wrong(q, '1').contains('연 1회'), isTrue,
          reason: 'KMS는 AWS 관리형 키의 키 구성 요소를 매년 교체한다');
    });

    test('공식 KMS 키 유형 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'developerguide/concepts.html'), isTrue);
    });
  });

  group('saa-t1-5-q3 봉투 암호화 출처', () {
    final q = question('saa-t1-5', 'saa-t1-5-q3');

    test('4KB 상한을 적은 공식 페이지를 출처로 싣는다', () {
      expect(hasSource(q, 'encrypt-operation'), isTrue);
    });

    test('봉투 암호화 공식 페이지를 출처로 싣는다', () {
      expect(hasSource(q, 'kms-cryptography'), isTrue);
    });
  });

  group('saa-t1-5-q4 키 정책과 IAM 정책의 관계', () {
    final q = question('saa-t1-5', 'saa-t1-5-q4');

    test('"교집합" 과단정이 사라졌다', () {
      expect((q['explanation'] as String).contains('교집합'), isFalse,
          reason: '기본 키 정책의 계정 위임 문장만 있어도 IAM 정책으로 접근된다');
    });

    test('"Principal로 명시되지 않으면 차단" 단정이 사라졌다', () {
      expect(
        (q['explanation'] as String).contains('Principal로 명시되지 않으면'),
        isFalse,
      );
    });

    test('해설이 계정 위임 경로를 설명한다', () {
      final text = q['explanation'] as String;
      expect(text.contains('위임'), isTrue,
          reason: '기본 키 정책의 계정 주체 문장이 IAM 정책을 활성화한다');
    });

    test('보기 1을 정답으로 만드는 핵심 근거(키 정책도 허용해야 함)는 유지된다', () {
      expect((q['explanation'] as String).contains('키 정책'), isTrue);
    });

    test('공식 키 정책 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'developerguide/key-policies.html'), isTrue);
    });
  });

  group('saa-t1-5-q5 KMS vs CloudHSM — 단일 테넌트가 갈림길', () {
    final q = question('saa-t1-5', 'saa-t1-5-q5');

    test('"멀티테넌트" 라는 비공식 낱말이 해설·오답근거에서 사라졌다', () {
      for (final text in [
        q['explanation'] as String,
        wrong(q, '1'),
        wrong(q, '2'),
      ]) {
        expect(text.contains('멀티테넌트'), isFalse,
            reason: '공식 표현은 "테넌트 구분이 없는(tenant-agnostic) HSM 플릿"이다');
      }
    });

    test('"AWS가 키에 접근한다"는 근거가 사라졌다', () {
      expect(wrong(q, '1').contains('AWS는 KMS 서비스를 관리하는'), isFalse,
          reason: 'AWS는 모든 키 저장소가 AWS 운영자의 평문 키 접근을 막는다고 명시한다');
    });

    test('해설이 단일 테넌트 요건으로 정답을 가른다', () {
      expect((q['explanation'] as String).contains('단일 테넌트'), isTrue);
    });

    test('KMS도 FIPS 140-3 Level 3 검증임을 부정하지 않는다', () {
      expect(wrong(q, '2').contains('FIPS 140-3 Level 3'), isTrue,
          reason: 'KMS 표준 HSM도 같은 등급이라 FIPS 등급만으로는 CloudHSM이 정답이 아니다');
    });

    test('공식 키 저장소 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'key-store-overview'), isTrue);
    });
  });

  group('saa-t1-5-q6 CloudHSM 키 저장소 출처', () {
    final q = question('saa-t1-5', 'saa-t1-5-q6');

    test('공식 CloudHSM 키 저장소 페이지를 출처로 싣는다', () {
      expect(hasSource(q, 'keystore-cloudhsm'), isTrue);
    });
  });

  group('saa-t1-5-q7 ACM 자동 갱신 — 완전 자동은 DNS 검증', () {
    final q = question('saa-t1-5', 'saa-t1-5-q7');

    test('"DNS 검증 또는 이메일 검증" 묶음 서술이 보기·해설에서 사라졌다', () {
      const stale = 'DNS 검증 또는 이메일 검증이 유효한 상태여야';
      expect(option(q, 2).contains(stale), isFalse,
          reason: '완전 자동 갱신은 DNS 검증 인증서에 해당한다');
      expect((q['explanation'] as String).contains(stale), isFalse);
    });

    test('보기 2는 여전히 DNS 검증을 짚는 정답이다', () {
      expect(option(q, 2).contains('DNS 검증'), isTrue);
    });

    test('해설이 DNS 검증과 이메일 검증을 구분한다', () {
      final text = q['explanation'] as String;
      expect(text.contains('DNS 검증'), isTrue);
      expect(text.contains('이메일'), isTrue,
          reason: '이메일 검증은 소유자가 갱신 메일에 응답해야 한다는 대비가 남아야 한다');
    });

    test('가져온 인증서가 비적격이라는 오답 근거는 유지된다', () {
      expect(wrong(q, '1').contains('자동 갱신'), isTrue);
    });

    test('공식 관리형 갱신·DNS 갱신 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'managed-renewal'), isTrue);
      expect(hasSource(q, 'dns-renewal-validation'), isTrue);
    });
  });

  group('saa-t1-5-q8 CloudFront us-east-1 — 확인 못 한 기전 제거', () {
    final q = question('saa-t1-5', 'saa-t1-5-q8');

    test('"컨트롤 플레인" 기전 서술이 사라졌다', () {
      expect((q['explanation'] as String).contains('컨트롤 플레인'), isFalse,
          reason: '공식 문서에서 근거를 찾지 못한 기전이다');
    });

    test('해설이 공식 요구사항(us-east-1 발급)을 그대로 남긴다', () {
      final text = q['explanation'] as String;
      expect(text.contains('us-east-1'), isTrue);
    });

    test('해설이 공식 문구(배포에 설정된 지리적 위치로 배포)로 근거를 댄다', () {
      expect((q['explanation'] as String).contains('지리적 위치'), isTrue);
    });
  });

  group('saa-t1-5-q9 Macie 출처 복붙 오류', () {
    final q = question('saa-t1-5', 'saa-t1-5-q9');

    test('주제가 다른 KMS 개요 출처가 사라졌다', () {
      expect(hasSource(q, kmsOverview), isFalse);
    });

    test('공식 Macie 페이지를 출처로 싣는다', () {
      expect(hasSource(q, 'what-is-macie'), isTrue);
    });
  });

  group('saa-t1-5-q10 Macie·Inspector 출처 복붙 오류', () {
    final q = question('saa-t1-5', 'saa-t1-5-q10');

    test('주제가 다른 KMS 개요 출처가 사라졌다', () {
      expect(hasSource(q, kmsOverview), isFalse);
    });

    test('공식 Macie·Inspector 페이지를 출처로 싣는다', () {
      expect(hasSource(q, 'what-is-macie'), isTrue);
      expect(hasSource(q, 'what-is-inspector'), isTrue);
    });
  });

  group('saa-t1-5-q13 Vault Lock 유예 기간', () {
    final q = question('saa-t1-5', 'saa-t1-5-q13');

    test('"쿨다운(기본 3일)" 오류가 사라졌다', () {
      expect((q['explanation'] as String).contains('기본 3일'), isFalse,
          reason: '유예는 내가 지정하며 72시간 쿨오프 때문에 최소 3일이다');
    });

    test('공식 문구에 없는 "AWS Support" 열거가 사라졌다', () {
      expect((q['explanation'] as String).contains('AWS Support'), isFalse,
          reason: '공식 문구는 "any user or by AWS"·"including the root user" 까지다');
    });

    test('해설이 유예를 사용자 지정·최소 3일로 적는다', () {
      final text = q['explanation'] as String;
      expect(text.contains('72시간'), isTrue);
      expect(text.contains('3일'), isTrue);
    });

    test('루트도 막힌다는 정답 근거는 유지된다', () {
      expect((q['explanation'] as String).contains('루트'), isTrue);
    });

    test('공식 Vault Lock 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'vault-lock'), isTrue);
    });
  });

  group('saa-t1-5-q14 RDS 암호화 출처 복붙 오류', () {
    final q = question('saa-t1-5', 'saa-t1-5-q14');

    test('주제가 다른 KMS 개요 출처가 사라졌다', () {
      expect(hasSource(q, kmsOverview), isFalse);
    });

    test('공식 RDS 암호화 페이지를 출처로 싣는다', () {
      expect(hasSource(q, 'Overview.Encryption'), isTrue);
    });
  });

  group('saa-t1-5-q15 KMS CloudTrail 출처', () {
    final q = question('saa-t1-5', 'saa-t1-5-q15');

    test('주제가 다른 KMS 개요 출처가 사라졌다', () {
      expect(hasSource(q, kmsOverview), isFalse);
    });

    test('공식 CloudTrail 로깅 페이지를 출처로 싣는다', () {
      expect(hasSource(q, 'logging-using-cloudtrail'), isTrue);
    });
  });

  group('saa-t1-5.md — 확인 못 한 기전 제거 (라이브 학습문서)', () {
    final t15 = File('assets/content/saa/saa-t1-5.md').readAsStringSync();
    // 문서 끝 정정 로그는 "무엇을 뺐는지" 적어야 해서 그 낱말이 남는다.
    // 금지 대상은 로그의 서술이 아니라 본문의 주장이므로 본문만 본다.
    final body = t15.split('> 📝 **2026-10-').first;

    test('"컨트롤 플레인" 기전 서술이 본문에서 사라졌다', () {
      expect(body.contains('컨트롤 플레인'), isFalse,
          reason: 'ACM 공식 문서에 없는 기전이라 라이브 본문에 남기지 않는다');
    });

    test('정정 로그가 본문과 분리돼 실제로 존재한다', () {
      expect(body.length, lessThan(t15.length),
          reason: '정정 로그 앵커를 못 찾으면 위 본문 단정이 전체 파일을 보게 된다');
    });

    test('공식 요구사항(us-east-1 발급)은 그대로 남는다', () {
      expect(t15.contains('us-east-1'), isTrue);
    });

    test('공식 문구(배포에 설정된 지리적 위치로 배포)가 근거로 들어왔다', () {
      expect(t15.contains('지리적 위치'), isTrue);
    });
  });
}
