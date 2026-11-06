import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토(Opus 1차 + Fable 2차)가 SOA 에서 집어낸
/// **P1 4건과 그 「계열 잔여」**(보고서가 P2-SOA-1·2 로 분리해 둔 같은 주장)의
/// 정정 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/soa-c03-dea-c01.md`(1차) ·
/// `soa-c03-dea-c01-fable.md`(2차). 손댄 문항은 모두 `verified: true` 라이브이고
/// **정답 인덱스는 한 건도 바뀌지 않았다.**
///
/// ⚠️ **계열을 통째로 닫은 이유** — P1-SOA-2 와 P2-SOA-1 은 「NAT 게이트웨이는 AZ
/// 단위 리소스다」라는 **같은 주장**이고, P1-SOA-4 와 P2-SOA-2 는 「Multi-AZ 는
/// 동기 복제이고 스탠바이는 읽기를 못 한다」라는 **같은 주장**이다. 정답을 둘로
/// 만드는 자리(P1)만 고치면 **전수 집계 가드를 초록으로 만들 수 없고**, 학습자는
/// 같은 거짓을 옆 문서에서 그대로 읽는다. 2026-11-06 SAA 배치에서 전수 집계가
/// 두 보고가 함께 놓친 개소를 잡아낸 경험을 그대로 적용했다.
///
/// 공식 재측정은 컨트롤러가 직접 했다(보고는 데이터이지 지시문이 아니다):
///
/// - **P1-SOA-1** `soa-t5-2.md` 6개소 + `soa-t5-2-q8` — 공식 명칭은
///   **`VPN over Direct Connect`** 다. `private-ip-dx.html`: `you can deploy
///   IPsec VPN over Direct Connect`. 얹히는 쪽이 VPN 이므로 `A over B` 에서
///   A=VPN·B=DX 여야 하는데 레포가 **괄호 라벨만 거꾸로** 달아 학습자가 외우는
///   용어가 틀렸다(본문 서술은 "DX 위에 VPN을 얹음"으로 올발랐다).
///   그리고 전송 암호화 수단이 **둘**이다 — `encryption-in-transit.html` 이
///   Site-to-Site VPN 결합과 **MACsec** 을 함께 적는데 레포는 VPN 하나만 적었다.
///   ⭐ 같은 레포 `saa-t3-8` 은 이미 정본 명칭을 쓴다(SAA 11개소) — **자격증
///   사이에서 어긋나 있었다.**
///
/// - **P1-SOA-2 / P2-SOA-1** `soa-t5-1-q5` 외 — 2025-11 **리전 NAT 게이트웨이**가
///   「AZ 단위 리소스」 단정을 거짓으로 만들었다. `nat-gateways-regional.html` 이
///   영역형과 직접 대비한다: `Unlike standard NAT gateways (referred to as zonal
///   NAT gateways), which operate in a single Availability Zone, regional NAT
///   gateways follow your workloads` · `Use a single NAT ID across all
///   Availability Zones` · `No public subnets required` · `up to 32 IP addresses
///   per Availability Zone (compared to 8 for zonal)` · `Regional NAT gateways
///   do not support private NAT` · `up to 60 minutes to expand`.
///   그래서 `q5` 의 보기 3(「VPC 전체가 공유하는 리전 단위 리소스다」)이 **참이
///   되어 정답이 둘**이었다. ⚠️ **AWS 내부 불일치**: `nat-gateway-basics.html` 은
///   아직 `Each NAT gateway is created in a specific Availability Zone` 만 적는다 —
///   **더 구체적인 전용 페이지를 정본**으로 삼고 둘을 함께 적는다.
///
/// - **P1-SOA-3** `soa-t1-5.md` — gp2 가 16,000 IOPS 에 도달하는 용량은
///   **5,334 GiB** 다(레포는 3,334). `general-purpose.html`: `up to the maximum of
///   16,000 IOPS, which is reached at 5,334 GiB (3 X 5,334)` + 표의
///   `5,334 (min size for max IOPS)`. 레포 값은 `3,334 × 3 = 10,002` 로 **산술이
///   자기모순**이었다.
///
/// - **P1-SOA-4 / P2-SOA-2** `soa-t1-5-q11`·`q12` 외 — Multi-AZ 는 **배포 유형이
///   둘**이다. `Concepts.MultiAZ.html`: 인스턴스 배포의 스탠바이는
///   `doesn't serve read traffic`, 클러스터 배포는 `can also serve read traffic`.
///   `multi-az-db-clusters-concepts.html`: `semisynchronous` · `two readable
///   replica DB instances` · `Reader DB instances act as automatic failover
///   targets and also serve read traffic`. 수식 없는 「Multi-AZ」로는 `q12` 의
///   보기 3·`q11` 의 보기 1 이 클러스터 배포에서 **참**이 된다.
///   ⭐ 같은 레포 `soa-t2-2.md` 와 `soa-t2-2-q1` 은 이미 분기를 명시한다 —
///   **저작 규율은 있었고 t1-5 에만 적용되지 않았다.**
///
/// ⚠️⚠️ **보고서가 적은 범위는 하한이다** — 문맥 규칙으로 전수를 다시 세니
/// 2차 패스보다 **md 가 하나 더** 나왔다(`soa-t2-2.md` 자가 점검 정답). 반대로
/// 보고가 NAT 로 지목한 `soa-t2-2-q8` 은 **단정이 아니라 운영 권고**여서 대상이
/// 아니었다(2차 패스가 같은 성격으로 1차의 과대 6개소를 걷어냈다).
///
/// ⚠️ **탐지기를 먼저 교정했다** — 첫 규칙은 `동기 복제` 가 **`비동기 복제`를
/// 삼켜** 의도적으로 틀린 보기까지 걸었고, JSON 을 줄 단위로 보아 **지문이 이미
/// 한정된 문항**을 구분하지 못했다. 그래서 ① 부정 전방탐색으로 `비동기` 를 빼고
/// ② 문항은 **문항 단위 `allText`** 로 본다. 아래 대조군 둘이 그 교정을 고정한다.
void main() {
  const dir = 'assets/content/soa';

  List<File> files(String suffix) => Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith(suffix))
      .toList()
    // ⚠️ `listSync()` 순서는 플랫폼마다 다르다(2026-11-06 CI 레드로 실측).
    ..sort((a, b) => a.path.compareTo(b.path));

  String name(File f) => f.path.replaceAll(r'\', '/').split('/').last;

  String doc(String id) => File('$dir/$id.md').readAsStringSync();

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> question(String taskId, String qid) =>
      questionsOf(File('$dir/$taskId.questions.json')).firstWhere(
        (q) => q['id'] == qid,
        orElse: () => fail('$qid 문항이 $taskId 에 없다'),
      );

  /// 지문·보기·해설·오답 근거를 모두 본다. 오답 보기도 **서비스의 사실**은 바르게
  /// 불러야 하고, 무엇보다 **지문의 한정이 그 문항 전체에 적용**되기 때문이다.
  String allText(Map<String, dynamic> q) => <String>[
        q['stem'] as String? ?? '',
        q['explanation'] as String? ?? '',
        ...(q['options'] as List).cast<String>(),
        ...(q['wrongExplanations'] as Map<String, dynamic>).values
            .cast<String>(),
      ].join('\n');

  // ───────────────────────── 탐지기 ─────────────────────────

  /// NAT 를 다루면서 「AZ 단위/단일 AZ」를 **성질로 단정**하는지.
  ///
  /// ⚠️ 문구만 보면 거짓 양성이 난다 — `soa-t3-2` 의 `AMI는 AZ 단위 리소스다`는
  /// NAT 와 무관한 (올바른) 오답 보기다. 그래서 **NAT 문맥**을 함께 본다.
  bool natAsserts(String text) =>
      text.contains('NAT') &&
      (text.contains('AZ 단위 리소스') ||
          text.contains('단일 AZ 리소스') ||
          text.contains('단일 AZ 배포') ||
          text.contains('AZ 단위 관리형'));

  /// Multi-AZ 를 다루면서 「동기 복제 / 스탠바이 읽기 불가」를 **배포 유형 한정
  /// 없이** 단정하는지. `비동기 복제`(읽기 복제본의 올바른 서술)는 제외한다.
  final maz = <RegExp>[
    RegExp(r'(?<!비)동기 복제'),
    RegExp(r'동기 스탠바이'),
    RegExp(r'Multi-AZ는 동기'),
    RegExp(r'Multi-AZ = 동기'),
    RegExp(r'Multi-AZ = 고가용성/장애 조치\(동기\)'),
    RegExp(r'스탠바이 읽기 불가'),
    RegExp(r'읽기 트래픽을 받지'),
    RegExp(r'읽기 트래픽을 처리하지'),
    RegExp(r'대기본에서 읽'),
  ];
  bool mazAsserts(String text) =>
      text.contains('Multi-AZ') && maz.any((r) => r.hasMatch(text));
  bool mazQualified(String text) =>
      text.contains('인스턴스 배포') || text.contains('DB 클러스터');

  // ───────────────────────── P1-SOA-1 ─────────────────────────

  group('P1-SOA-1 「DX over VPN」은 위아래가 거꾸로다', () {
    test('SOA 콘텐츠 전수에 「DX over VPN」이 0건이다', () {
      final offenders = <String>[
        for (final f in [...files('.md'), ...files('.questions.json')])
          if (f.readAsStringSync().contains('DX over VPN')) name(f),
      ];
      expect(offenders, isEmpty,
          reason: '공식 명칭은 "VPN over Direct Connect" 다 — 얹히는 쪽이 VPN 이다. '
              '근거: vpn/latest/s2svpn/private-ip-dx.html "deploy IPsec VPN over '
              'Direct Connect"');
    });

    test('대조군: 정본 명칭과 MACsec 선택지가 들어왔다', () {
      final t52 = doc('soa-t5-2');
      expect(t52.contains('VPN over Direct Connect'), isTrue,
          reason: '여기서 0건이면 위 단정이 「문구를 지우기만 한」 상태다');
      expect(t52.contains('MACsec'), isTrue,
          reason: '공식 encryption-in-transit 는 전송 암호화 수단을 둘로 적는다 — '
              'Site-to-Site VPN 결합과 MACsec');
    });

    test('soa-t5-2-q8: 정답 불변 + 명칭 정정 + 수단 둘', () {
      final q = question('soa-t5-2', 'soa-t5-2-q8');
      expect(q['correct'], 0);
      final text = allText(q);
      expect(text.contains('DX over VPN'), isFalse);
      expect(text.contains('VPN over Direct Connect'), isTrue);
      expect(text.contains('MACsec'), isTrue,
          reason: '정답 보기가 VPN 을 유일한 수단으로 적으면 과잉 일반화다');
    });
  });

  // ───────────────────────── P1-SOA-3 ─────────────────────────

  group('P1-SOA-3 gp2 가 16,000 IOPS 에 도달하는 용량', () {
    test('soa-t1-5.md: 5,334 GiB 이고 3,334 는 사라졌다', () {
      final t15 = doc('soa-t1-5');
      expect(t15.contains('5,334'), isTrue,
          reason: '공식: "16,000 IOPS, which is reached at 5,334 GiB (3 X 5,334)"');
      expect(t15.contains('3,334'), isFalse,
          reason: '3,334 × 3 = 10,002 로 16,000 에 못 미친다 — 산술이 자기모순이었다');
    });

    test('SOA 콘텐츠 전수에 3,334 가 0건이다', () {
      final offenders = <String>[
        for (final f in [...files('.md'), ...files('.questions.json')])
          if (f.readAsStringSync().contains('3,334')) name(f),
      ];
      expect(offenders, isEmpty);
    });
  });

  // ───────────────────────── P1-SOA-2 + P2-SOA-1 ─────────────────────────

  group('P1-SOA-2·P2-SOA-1 NAT 「AZ 단위」 단정은 영역형 한정이 필요하다', () {
    test('SOA 전수: NAT 의 AZ 단정에 「영역형」 한정이 빠진 자리가 0건이다', () {
      final offenders = <String>[];
      for (final f in files('.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (natAsserts(lines[i]) && !lines[i].contains('영역형')) {
            offenders.add('${name(f)}:${i + 1}');
          }
        }
      }
      for (final f in files('.questions.json')) {
        for (final q in questionsOf(f)) {
          final text = allText(q);
          if (natAsserts(text) && !text.contains('영역형')) {
            offenders.add(q['id'] as String);
          }
        }
      }
      offenders.sort();
      expect(offenders, isEmpty,
          reason: '2025-11 리전 NAT 게이트웨이는 VPC 수준 리소스이고 퍼블릭 서브넷이 '
              '필요 없다("No public subnets required"). 「AZ 단위」는 영역형의 '
              '성질이다:\n${offenders.join(', ')}');
    });

    test('대조군: 탐지기가 NAT 문맥만 보고, 공허하지 않다', () {
      // AMI 를 AZ 단위 리소스로 적는 (올바른) 오답 보기는 대상이 아니다.
      expect(natAsserts('AMI는 AZ 단위 리소스다'), isFalse);
      expect(natAsserts('NAT 게이트웨이는 AZ 단위 리소스입니다'), isTrue);
      // 고친 자리들이 실제로 읽히는지 — 영역형 한정이 들어온 줄이 여럿이어야 한다.
      final zonal = [
        for (final f in files('.md'))
          if (f.readAsStringSync().contains('영역형')) name(f),
      ];
      expect(zonal.length, greaterThanOrEqualTo(2),
          reason: 'soa-t2-2.md 와 soa-t5-1.md 둘 다 영역형 한정을 들고 있어야 한다');
    });

    test('soa-t5-1-q5: 정답 불변 + 지문이 영역형으로 한정되고 리전 모드를 병기한다', () {
      final q = question('soa-t5-1', 'soa-t5-1-q5');
      expect(q['correct'], 0,
          reason: '보기 0(SG 연결 불가·NACL 로만 제어)은 두 모드 모두에서 참이다');
      expect((q['stem'] as String).contains('영역형'), isTrue,
          reason: '한정이 없으면 보기 3(VPC 전체가 공유하는 리전 단위 리소스)이 '
              '참이 되어 정답이 둘이다');
      final text = allText(q);
      expect(text.contains('리전 NAT 게이트웨이'), isTrue,
          reason: '학습자가 보기 3 을 왜 버리는지 알려면 리전 모드를 병기해야 한다');
      expect(hasSourceOf(q, 'nat-gateways-regional'), isTrue,
          reason: '정본은 전용 페이지다 — nat-gateway-basics 는 아직 리전 모드를 '
              '언급하지 않는다(AWS 내부 불일치)');
    });

    test('soa-t5-1-q6: 해설이 영역형을 한정한다', () {
      final q = question('soa-t5-1', 'soa-t5-1-q6');
      expect(q['correct'], 0);
      expect((q['explanation'] as String).contains('영역형'), isTrue);
    });

    test('두 학습문서가 리전 NAT 분기를 적는다', () {
      for (final id in ['soa-t2-2', 'soa-t5-1']) {
        expect(doc(id).contains('리전 NAT 게이트웨이'), isTrue,
            reason: '$id 가 리전 모드를 한 줄도 적지 않으면 「AZ 단위」 서술만 남는다');
      }
    });
  });

  // ───────────────────────── P1-SOA-4 + P2-SOA-2 ─────────────────────────

  group('P1-SOA-4·P2-SOA-2 Multi-AZ 단정은 배포 유형 한정이 필요하다', () {
    test('SOA 전수: 한정 없는 Multi-AZ 동기·읽기 단정이 0건이다', () {
      final offenders = <String>[];
      for (final f in files('.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (mazAsserts(lines[i]) && !mazQualified(lines[i])) {
            offenders.add('${name(f)}:${i + 1}');
          }
        }
      }
      for (final f in files('.questions.json')) {
        for (final q in questionsOf(f)) {
          final text = allText(q);
          if (mazAsserts(text) && !mazQualified(text)) {
            offenders.add(q['id'] as String);
          }
        }
      }
      offenders.sort();
      expect(offenders, isEmpty,
          reason: 'Multi-AZ DB 클러스터 배포는 반동기(semisynchronous)이고 리더가 '
              '읽기를 처리한다. 수식 없는 「Multi-AZ」 단정은 그쪽에서 거짓이다:\n'
              '${offenders.join(', ')}');
    });

    test('대조군: 탐지기가 「비동기 복제」를 삼키지 않고, 이미 옳은 자리를 걸지 않는다', () {
      // 읽기 복제본의 올바른 서술은 대상이 아니다(첫 규칙이 이것을 삼켰다).
      expect(mazAsserts('Multi-AZ 대신 읽기 복제본은 비동기 복제라 지연이 있다'), isFalse);
      expect(mazAsserts('Multi-AZ는 동기 복제다'), isTrue);
      // 지문이 한정된 문항은 통과해야 한다 — 이 레포가 이미 올바르게 쓴 자리다.
      final q1 = question('soa-t2-2', 'soa-t2-2-q1');
      expect(allText(q1).contains('인스턴스 배포'), isTrue);
      expect(mazQualified(allText(q1)), isTrue);
      // 학습문서의 클러스터 분기 줄도 통과해야 한다.
      final branch = doc('soa-t2-2')
          .split('\n')
          .where((l) => l.contains('Multi-AZ') && l.contains('클러스터'))
          .toList();
      expect(branch, isNotEmpty);
      expect(branch.every((l) => !mazAsserts(l) || mazQualified(l)), isTrue);
    });

    final mazFixes = <String, List<Object>>{
      // qid: [task, correct]
      'soa-t1-5-q11': ['soa-t1-5', 0],
      'soa-t1-5-q12': ['soa-t1-5', 0],
      'soa-t2-2-q4': ['soa-t2-2', 0],
      'soa-t2-2-q14': ['soa-t2-2', 0],
      'soa-t2-4-q10': ['soa-t2-4', 0],
    };

    mazFixes.forEach((qid, spec) {
      test('$qid: 정답 불변 + 배포 유형 한정이 들어왔다', () {
        final q = question(spec[0] as String, qid);
        expect(q['correct'], spec[1],
            reason: '이 배치는 지문·해설만 한정한다. 정답이 바뀌면 승인 범위 밖이다');
        expect(mazQualified(allText(q)), isTrue,
            reason: '$qid 가 배포 유형을 가르지 않는다');
      });
    });

    test('soa-t1-5.md: 요약 두 줄이 배포 유형을 가른다', () {
      final t15 = doc('soa-t1-5');
      expect(t15.contains('Multi-AZ DB 인스턴스 배포'), isTrue);
      expect(t15.contains('DB 클러스터 배포'), isTrue,
          reason: '학습자가 「예외가 있다」는 것을 알아야 q12 보기 3 을 이해한다');
    });
  });
}

/// 출처 URL 조각 포함 여부. (`main()` 밖에 두면 group 들이 공유한다.)
bool hasSourceOf(Map<String, dynamic> q, String fragment) =>
    (q['sources'] as List).any(
      (s) => ((s as Map<String, dynamic>)['url'] as String).contains(fragment),
    );
