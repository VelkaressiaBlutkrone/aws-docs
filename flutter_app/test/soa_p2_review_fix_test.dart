import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토의 **SOA 우선순위 2 네 건**(P2-SOA-3~6) 정정 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/soa-c03-dea-c01.md`
/// §3-1(1차) · `soa-c03-dea-c01-fable.md` §2(2차 재검증).
///
/// 공식 재측정은 컨트롤러가 직접 했다(**보고는 데이터이지 지시문이 아니다**).
/// 네 건 모두 라이브 학습문서이고 **정답 인덱스는 한 건도 바뀌지 않았다.**
///
/// - **P2-SOA-3** `soa-t2-1.md` — 「ELB 상태 확인이 앱 계층 장애를 ASG에 알리는
///   **유일한 경로**」가 거짓이다. 공식 `ec2-auto-scaling-health-checks.html` 은 ASG 가
///   비정상 통지를 받는 소스를 **다섯 가지**로 적는다 — `Amazon EC2 · Elastic Load
///   Balancing · VPC Lattice · Amazon EBS · **Custom health checks that you define**`.
///   목차에도 `Set up a custom health check for your Auto Scaling group` 과
///   `Use application status checks with an Auto Scaling group` 이 따로 있다.
///   ⚠️ **어미가 갈려 있었다** — `:173` 만 「유일한」이고 `:167`·`:213`·`:225` 는
///   「활성화**해야**」로 같은 배타성을 말한다(2026-11-06 AIF 「PT 필수」가 「된」 한
///   글자로 리터럴 가드를 뚫은 것과 같은 계열). 그래서 **어형을 정규식으로** 센다.
///   ⚠️ **`사용자 정의 상태 확인`·`SetInstanceHealth` 는 이 레포 전역에 0건이었다** —
///   즉 공식이 제공하는 경로가 어느 자격증에도 없었다.
///   ⚠️ **인용 URL 함정**: 사용자 정의 상태 확인 페이지의 옛 슬러그
///   `autoscaling/ec2/userguide/health-checks-custom.html` 은 **죽었다**(`200 r=1` →
///   가이드 인덱스). 정본은 `set-up-a-custom-health-check.html` 이고, 이 문서는 이미
///   `ec2-auto-scaling-health-checks.html` 을 출처로 들고 있어 그대로 쓴다.
///   근거: https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html
///
/// - **P2-SOA-4** `soa-t4-3.md` — 「RDS 암호화 전환은 새 볼륨으로의 이전이 **유일한
///   방법**」이 거짓이다. 「기존 인스턴스를 제자리에서 전환할 수 없다」는 **참**이지만
///   경로가 스냅샷 경유 하나가 아니다. 공식 RDS API Reference 가 적는다 —
///   `TargetKmsKeyId … Specify this setting in either of the following cases: …
///   **The blue resource is unencrypted and you want to encrypt the green
///   resource.** … For RDS, encryption applies at the DB instance level.`
///   ⭐ **같은 레포 SAA 는 2026-10-28에 이미 고쳤다**(`saa-t1-5.md:157`·`:312` 가
///   Blue/Green 경로를 병기한다) — **자격증 사이에서 어긋나 있었다.**
///   근거: https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_TargetResourceConfiguration.html
///
/// - **P2-SOA-5** 학습문서 죽은 URL 4건 → `source_url_retired_test.dart` 가 가드한다
///   (이 파일은 그 교체가 md 프런트매터·참고자료 **양쪽**에 들어갔는지만 본다).
///   ⚠️ **문항은 이미 정본을 쓰고 있었다** — `soa-t1-4-q7~q9` 가
///   `ec2-instance-recover.html`(**`recovery` 아닌 `recover`**)을, `soa-t2-3-q5`·`q6`
///   가 `ebs/latest/userguide/…` 를 쓴다. **문항 가드는 `.md` 를 보지 않아서** md 만
///   낡은 채 남았다(2026-10-28 `saa-t4-3.md` 와 같은 자리).
///
/// - **P2-SOA-6** `Kinesis Data Firehose` 구식 명칭 — 공식 현행 명칭은
///   **Amazon Data Firehose** 다(`what-is-this-service.html` 의 제목이 `What is
///   Amazon Data Firehose?`). ⚠️ **보고서는 SOA 3개소만 범위로 적고 SAA 2개소를
///   「범위 밖, 기록만」으로 뒀지만, 그 2개소는 `verified: 15/15` 라이브다**
///   (`saa-t3-9.md` 계층 다이어그램 · `saa-t3-9-q2` 의 `skill` 태그). 이 레포의 규율은
///   **오류를 찾으면 그 문구로 전역을 쓸고 가드도 전역으로 건다**이므로 다섯 자리를
///   함께 고쳤다. 공식 가이드 JSON 에 `Firehose` 가 0건이라 `skill` 은 가이드 유래가
///   아니라 저작자 서술이고, 따라서 고쳐도 가이드 동기화와 충돌하지 않는다.
///   ⚠️ **개명을 가르치는 줄은 구명칭을 써야 한다** — DEA 3개소·MLA 1개소가 그렇다.
///   그래서 금지 규칙에 **「같은 줄에 `개명`·`이전 이름`이 있으면 예외」**를 두고,
///   그 예외가 정확히 네 자리인 것을 대조군으로 고정한다.
///   ⚠️ 이 규칙을 `soa_dea_question_propagation_test` 의 `_nameRules` 에 넣지 않았다 —
///   그 목록은 예외 장치가 없어 개명을 가르치는 문항이 생기면 막히고, SOA·DEA 문항만
///   본다(SAA 2개소를 못 본다). 전역 + 예외가 더 넓고 안전하다.
///   근거: https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html
void main() {
  List<File> contentFiles(String suffix, {String? cert}) {
    final root = Directory('assets/content');
    return root
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith(suffix))
        .where((f) =>
            cert == null ||
            f.path.replaceAll(r'\', '/').contains('/content/$cert/'))
        .toList()
      // ⚠️ `listSync()` 순서는 플랫폼마다 다르다(2026-11-06 CI 레드로 실측).
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  String rel(File f) =>
      f.path.replaceAll(r'\', '/').split('assets/content/').last;

  String doc(String cert, String id) =>
      File('assets/content/$cert/$id.md').readAsStringSync();

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> question(String cert, String taskId, String qid) =>
      questionsOf(File('assets/content/$cert/$taskId.questions.json'))
          .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  /// 문항의 **사실 영역 + 보기 전체**. 구식 명칭·배타 단정은 오답 보기에서도
  /// 잘못이므로 문항 전체를 본다(틀린 서술을 일부러 담는 자리라도 **서비스 이름**과
  /// **배타성**은 바르게 써야 한다).
  String allText(Map<String, dynamic> q) => <String>[
        q['stem'] as String? ?? '',
        q['skill'] as String? ?? '',
        q['explanation'] as String? ?? '',
        ...(q['options'] as List).cast<String>(),
        ...(q['wrongExplanations'] as Map<String, dynamic>).values
            .cast<String>(),
        ...((q['sources'] as List?) ?? const [])
            .map((s) => (s as Map)['title']?.toString() ?? ''),
      ].join('\n');

  // ═════════════════════ 공통 대조군 ═════════════════════

  test('대조군: 콘텐츠 파일을 실제로 읽고 있다', () {
    final md = contentFiles('.md');
    final qs = contentFiles('.questions.json');
    expect(md.length, greaterThanOrEqualTo(90),
        reason: '0건 통과가 "파일을 못 읽어서"일 수 있다 — 먼저 센다');
    expect(qs.length, greaterThanOrEqualTo(90));
  });

  // ═════════════════════ P2-SOA-3 ELB ═════════════════════

  /// **앱 계층 장애 감지를 ELB 상태 확인에 독점시키는 단정**인가.
  ///
  /// ⚠️ 이 규칙은 두 번 좁혔다 — 실측으로 배운 구분이다.
  /// ① 「유일한」만 보면 `:167`·`:213`·`:225`·`q10` 의 **「해야」 어미**를 놓친다.
  /// ② 반대로 「해야」만 보면 **참인 서술**이 걸린다 — `soa-t1-4.md:258`·`:298` 은
  ///    「ELB 는 트래픽만 끊고 **교체**는 ASG 상태 확인 유형이 한다」는 **ELB 경로의
  ///    내부 배선** 설명이고 공식과 일치한다. 그 줄들은 **앱 계층 장애 감지의 배타성**을
  ///    말하지 않는다. 그래서 규칙에 **「앱·애플리케이션 장애」 문맥**을 함께 요구한다.
  /// 공식의 다른 경로(사용자 정의 상태 확인 / `SetInstanceHealth`)를 함께 적으면
  /// 배타 단정이 아니므로 제외한다.
  bool elbExclusive(String text) {
    if (!text.contains('ELB 상태 확인') && !text.contains('ELB 헬스 체크')) {
      return false;
    }
    // 앱 계층 장애를 다루는 문맥에서만 「배타성」이 거짓이 된다.
    if (!text.contains('앱') && !text.contains('애플리케이션')) return false;
    final exclusive = RegExp(r'유일한\s*(경로|방법|수단)');
    final necessity = RegExp(r'해야');
    if (!exclusive.hasMatch(text) && !necessity.hasMatch(text)) return false;
    return !(text.contains('사용자 정의 상태 확인') ||
        text.contains('SetInstanceHealth'));
  }

  group('P2-SOA-3 ELB 상태 확인은 ASG 교체의 유일한 경로가 아니다', () {
    test('레포 전수(md): ELB 상태 확인을 배타적 경로로 단정하는 줄이 없다', () {
      final offenders = <String>[];
      for (final f in contentFiles('.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (elbExclusive(lines[i])) offenders.add('${rel(f)}:${i + 1}');
        }
      }
      expect(offenders, isEmpty,
          reason: '공식은 ASG 비정상 통지 소스를 다섯 가지로 적는다(EC2 · ELB · '
              'VPC Lattice · EBS · 사용자 정의 상태 확인). ELB 가 없는 구성에서는 '
              '`SetInstanceHealth` 로 전달한다:\n${offenders.join('\n')}');
    });

    test('레포 전수(문항): 같은 배타 단정이 없다', () {
      final offenders = <String>[];
      for (final f in contentFiles('.questions.json')) {
        for (final q in questionsOf(f)) {
          if (elbExclusive(allText(q))) offenders.add(q['id'] as String);
        }
      }
      expect(offenders, isEmpty, reason: offenders.join(', '));
    });

    test('soa-t2-1.md 이 공식 다섯 소스와 사용자 정의 경로를 적는다', () {
      final t = doc('soa', 'soa-t2-1');
      // ⚠️ 「유일한 경로」를 **리터럴로 금지하지 않는다** — 정정문이 「유일한 경로는
      // 아닙니다」로 옛 오해를 인용해 가르치고, 리터럴 금지는 그 교육 문장을 죽인다
      // (2026-11-06 CLF 배치에서 탐지기가 정정문 자신을 걸었던 것과 같은 계열).
      // 배타 단정 여부는 위 전수 가드의 `elbExclusive` 가 문맥으로 판정한다.
      expect(t.contains('유일한 경로는 아닙니다'), isTrue,
          reason: '왜 「유일」이 아닌지를 문서가 직접 말해야 학습자가 교정된다');
      for (final required in [
        'VPC Lattice',
        '사용자 정의 상태 확인',
        'SetInstanceHealth',
        '가장 일반적인 경로',
        // 출처는 이미 들고 있던 정본이다 — 새로 넣지 않았고 지우지도 않는다.
        'ec2-auto-scaling-health-checks.html',
      ]) {
        expect(t.contains(required), isTrue, reason: '「$required」가 없다');
      }
      // 죽은 슬러그를 끌어오지 않았는지 — health-checks-custom.html 은 200 r=1 이다.
      expect(t.contains('health-checks-custom.html'), isFalse,
          reason: '사용자 정의 상태 확인의 옛 슬러그는 가이드 인덱스로 리다이렉트한다');
    });

    test('soa-t2-1-q10: 정답 불변 + 해설이 완화됐다', () {
      final q = question('soa', 'soa-t2-1', 'soa-t2-1-q10');
      expect(q['correct'], 0,
          reason: '「ASG 상태 확인이 EC2 유형만」이 원인인 것은 그대로 참이다');
      final e = q['explanation'] as String;
      expect(e.contains('사용자 정의 상태 확인'), isTrue,
          reason: '왜 「유일」이 아닌지가 해설에 서야 학습자가 같은 오해를 안 한다');
    });

    test('대조군: 참인 서술은 걸리지 않고, 탐지가 공허하지 않다', () {
      // soa-t1-4.md 의 두 자리는 **다른 참인 주장**이다 — 「ELB 는 트래픽만 끊고
      // 교체는 ASG 의 상태 확인 유형이 한다」. 손대지 않았고 규칙에 걸려서도 안 된다.
      final t14 = doc('soa', 'soa-t1-4');
      expect(t14.contains('ELB 상태 확인만 켜면'), isTrue,
          reason: '이 참인 서술이 사라졌다면 규칙이 과잉으로 번진 것이다');
      for (final line in t14.split('\n')) {
        expect(elbExclusive(line), isFalse,
            reason: 'soa-t1-4 의 참인 서술이 걸렸다: $line');
      }
      // 탐지기가 옛 문구를 여전히 잡는가(민감도).
      expect(
          elbExclusive('ELB 상태 확인은 앱 계층 장애를 ASG가 인지해 '
              '인스턴스를 교체하게 만드는 유일한 경로입니다.'),
          isTrue);
      expect(elbExclusive('**ELB 상태 확인을 활성화해야** 앱 장애 인스턴스를 교체합니다.'),
          isTrue);
      // 완화된 문구는 통과한다(앱 문맥·「해야」가 있어도 다른 경로를 적으면 제외).
      expect(
          elbExclusive('앱 계층 장애를 ASG 가 인지하려면 ELB 상태 확인을 켜야 하고, '
              'ELB 가 없으면 사용자 정의 상태 확인으로 전달해야 합니다.'),
          isFalse);
      // 앱 문맥이 없는 ELB→ASG 배선 설명은 애초에 대상이 아니다.
      expect(
          elbExclusive('ELB 상태 확인 결과가 교체로 이어지려면 ASG 상태 확인 유형을 '
              'ELB 로 설정해야 합니다.'),
          isFalse);
      // ELB 상태 확인을 아예 안 적으면 위 전수 단정이 공허하다.
      final mentions = contentFiles('.md')
          .where((f) => f.readAsStringSync().contains('ELB 상태 확인'))
          .map(rel)
          .toList();
      expect(mentions, isNotEmpty);
    });
  });

  // ═════════════════════ P2-SOA-4 RDS 암호화 ═════════════════════

  /// RDS 암호화 전환 문맥에서 **경로가 하나뿐이라고** 말하는가.
  /// 「제자리 전환 불가」는 참이므로 대상이 아니고, 배타성 단정만 센다.
  bool rdsEncryptionExclusive(String text) {
    if (!text.contains('암호화')) return false;
    if (!text.contains('RDS') &&
        !text.contains('DB 인스턴스') &&
        !text.contains('인스턴스')) {
      return false;
    }
    final exclusive = RegExp(r'유일한\s*(방법|경로|절차)|동일한\s*경로입니다');
    if (!exclusive.hasMatch(text)) return false;
    return !(text.contains('Blue/Green') ||
        text.contains('블루/그린') ||
        text.contains('TargetKmsKeyId'));
  }

  group('P2-SOA-4 RDS 암호화 전환은 스냅샷 경유가 유일한 방법이 아니다', () {
    test('레포 전수(md): 배타 단정이 없다', () {
      final offenders = <String>[];
      for (final f in contentFiles('.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (rdsEncryptionExclusive(lines[i])) {
            offenders.add('${rel(f)}:${i + 1}');
          }
        }
      }
      expect(offenders, isEmpty,
          reason: '공식 Blue/Green 배포가 green 리소스에 `TargetKmsKeyId` 를 지정하는 '
              '경로를 제공한다("The blue resource is unencrypted and you want to '
              'encrypt the green resource."):\n${offenders.join('\n')}');
    });

    test('레포 전수(문항): 같은 배타 단정이 없다', () {
      final offenders = <String>[];
      for (final f in contentFiles('.questions.json')) {
        for (final q in questionsOf(f)) {
          if (rdsEncryptionExclusive(allText(q))) {
            offenders.add(q['id'] as String);
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join(', '));
    });

    test('soa-t4-3.md 이 Blue/Green 경로를 적고 기존 출처를 유지한다', () {
      final t = doc('soa', 'soa-t4-3');
      expect(t.contains('유일한 방법'), isFalse);
      for (final required in [
        'TargetKmsKeyId',
        'API_TargetResourceConfiguration.html',
        // 「제자리 전환 불가」는 참이므로 남아 있어야 한다.
        '생성 후 직접 전환 불가',
        // soa_facts_test.dart 가 지키는 두 출처 — 지우지 않았다.
        'key-policy-overview',
        'certificate-manager/pricing',
      ]) {
        expect(t.contains(required), isTrue, reason: '「$required」가 없다');
      }
    });

    test('soa-t4-3-q7: 정답 불변 + 해설이 두 경로를 적는다', () {
      final q = question('soa', 'soa-t4-3', 'soa-t4-3-q7');
      expect(q['correct'], 0, reason: '스냅샷 경유 절차가 정답인 것은 그대로다');
      final e = q['explanation'] as String;
      expect(e.contains('Blue/Green') || e.contains('TargetKmsKeyId'), isTrue,
          reason: '학습자는 오답노트·모의고사 화면에서 md 를 보지 못한다');
    });

    test('대조군: 참인 서술은 걸리지 않고, SAA 정본이 그대로다', () {
      // `saa-t3-5.md` 의 「스냅샷 … 절차가 필요합니다」는 **참**이다(어떤 경로든
      // 제자리 전환은 아니다). 배타 단정이 아니므로 고치지 않았고 걸려서도 안 된다.
      final t35 = doc('saa', 'saa-t3-5');
      expect(t35.contains('절차가 필요합니다'), isTrue);
      for (final line in t35.split('\n')) {
        expect(rdsEncryptionExclusive(line), isFalse,
            reason: 'saa-t3-5 의 참인 서술이 걸렸다: $line');
      }
      // SAA 는 2026-10-28에 이미 Blue/Green 을 병기했다 — 레포 내 정본이다.
      expect(doc('saa', 'saa-t1-5').contains('TargetKmsKeyId'), isTrue);
      // 탐지기 민감도.
      expect(
          rdsEncryptionExclusive(
              'RDS 암호화는 운영 중 전환 경로가 없고 새 볼륨으로의 이전이 유일한 방법이다.'),
          isTrue);
      expect(
          rdsEncryptionExclusive('RDS 암호화 전환의 대표 경로는 스냅샷 경유이고, '
              'Blue/Green 배포에서 `TargetKmsKeyId` 를 지정하는 경로도 있다.'),
          isFalse);
    });
  });

  // ═════════════════════ P2-SOA-5 죽은 URL ═════════════════════

  group('P2-SOA-5 학습문서의 죽은 출처 URL 4건이 정본으로 교체됐다', () {
    // 은퇴 URL 0건 단정은 `source_url_retired_test.dart` 가 전역으로 센다.
    // 여기서는 **프런트매터와 참고자료 양쪽**에 들어갔는지를 본다(한쪽만 고치는
    // 실수가 2026-10-28 `saa-t4-3.md` 에서 실제로 났다).
    const pairs = <String, List<String>>{
      'soa/soa-t1-4.md': [
        'https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recover.html',
      ],
      'soa/soa-t2-3.md': [
        'https://docs.aws.amazon.com/ebs/latest/userguide/ebs-snapshots.html',
        'https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-lifecycle.html',
      ],
      'soa/soa-t3-2.md': [
        'https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-patch-groups.html',
      ],
    };

    pairs.forEach((path, urls) {
      test('$path — 정본이 두 자리(프런트매터·참고자료)에 있다', () {
        final text = File('assets/content/$path').readAsStringSync();
        for (final url in urls) {
          final n = url.allMatches(text).length;
          expect(n, greaterThanOrEqualTo(2),
              reason: '$url 이 $n 곳뿐이다 — 프런트매터 `url:` 과 참고자료 항목 '
                  '**양쪽**을 고쳐야 한다');
        }
      });
    });

    test('문항이 쓰던 정본과 md 가 이제 같은 페이지를 가리킨다', () {
      // 내부 불일치가 이 건의 본질이었다 — 문항은 처음부터 옳았다.
      expect(
          File('assets/content/soa/soa-t1-4.questions.json')
              .readAsStringSync()
              .contains('ec2-instance-recover.html'),
          isTrue);
      expect(doc('soa', 'soa-t1-4').contains('ec2-instance-recover.html'),
          isTrue);
      expect(
          File('assets/content/soa/soa-t2-3.questions.json')
              .readAsStringSync()
              .contains('ebs/latest/userguide/ebs-snapshots.html'),
          isTrue);
      expect(doc('soa', 'soa-t2-3')
              .contains('ebs/latest/userguide/ebs-snapshots.html'),
          isTrue);
    });
  });

  // ═════════════════════ P2-SOA-6 Firehose 명칭 ═════════════════════

  /// 개명을 **가르치는** 줄은 구명칭을 써야 한다 — 그 줄만 예외로 둔다.
  bool teachesRename(String text) =>
      text.contains('개명') || text.contains('이전 이름');

  group('P2-SOA-6 Amazon Data Firehose — 구식 명칭', () {
    test('레포 전수(md): 개명을 가르치는 줄 외에 구명칭이 없다', () {
      final offenders = <String>[];
      for (final f in contentFiles('.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (!lines[i].contains('Kinesis Data Firehose')) continue;
          if (!teachesRename(lines[i])) offenders.add('${rel(f)}:${i + 1}');
        }
      }
      expect(offenders, isEmpty,
          reason: '공식 현행 명칭은 Amazon Data Firehose 다'
              '(what-is-this-service.html 제목):\n${offenders.join('\n')}');
    });

    test('레포 전수(문항): 구명칭이 없다', () {
      final offenders = <String>[];
      for (final f in contentFiles('.questions.json')) {
        for (final q in questionsOf(f)) {
          final t = allText(q);
          if (!t.contains('Kinesis Data Firehose')) continue;
          if (!teachesRename(t)) offenders.add(q['id'] as String);
        }
      }
      expect(offenders, isEmpty,
          reason: '오답 보기·`skill` 태그·출처 제목도 서비스 이름은 바르게 '
              '불러야 한다: ${offenders.join(', ')}');
    });

    test('SOA 가 개명을 한 번 가르친다', () {
      // DEA·MLA 는 이미 개명 함정을 명시한다 — SOA 에만 그 처리가 없었다.
      final t12 = doc('soa', 'soa-t1-2');
      expect(t12.contains('Amazon Data Firehose'), isTrue);
      expect(teachesRename(t12), isTrue,
          reason: '구명칭으로 공부한 학습자가 같은 서비스임을 알 수 있어야 한다');
    });

    test('saa-t3-9: 라이브 두 자리가 신명칭으로 바뀌고 정답이 불변이다', () {
      // ⚠️ verified 15/15 라이브다 — 보고서가 「범위 밖」으로 둔 자리다.
      expect(doc('saa', 'saa-t3-9').contains('Kinesis Data Firehose'), isFalse);
      expect(doc('saa', 'saa-t3-9').contains('Amazon Data Firehose'), isTrue);
      final q = question('saa', 'saa-t3-9', 'saa-t3-9-q2');
      expect(q['skill'], contains('Amazon Data Firehose'));
      expect(q['correct'], 3, reason: '명칭 교체는 사실을 바꾸지 않는 핫픽스다');
    });

    test('대조군: 개명을 가르치는 자리가 정확히 네 곳이다', () {
      // 예외가 모든 줄을 삼키는 상태와 「정말 0건」을 구별해야 한다.
      final exempt = <String>[];
      for (final f in contentFiles('.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('Kinesis Data Firehose') &&
              teachesRename(lines[i])) {
            exempt.add('${rel(f)}:${i + 1}');
          }
        }
      }
      expect(exempt.length, 5,
          reason: 'dea 3 · mla 1 · 새로 넣은 soa 1 이어야 한다: $exempt');
      expect(exempt.where((e) => e.startsWith('dea/')).length, 3);
      expect(exempt.where((e) => e.startsWith('mla/')).length, 1);
      expect(exempt.where((e) => e.startsWith('soa/')).length, 1);
    });
  });
}
