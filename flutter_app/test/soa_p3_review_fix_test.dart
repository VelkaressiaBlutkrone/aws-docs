import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토의 **SOA 우선순위 3(P3) 계열** 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/soa-c03-dea-c01.md`
/// §4-1 `P3-SOA-2`(gp2/gp3 수치 귀속) · `P3-SOA-3`(자동 복구 두 메커니즘) ·
/// `P3-SOA-4`(오답 근거의 회피적 반박).
///
/// 공식 재측정은 컨트롤러가 직접 했다. **정답 인덱스는 한 건도 바뀌지 않았다.**
/// 손댄 문항 3개와 학습문서 2편은 **전부 라이브**(`verified: true`)다.
///
/// ## ⚠️⚠️ 보고서의 제안 용어를 그대로 쓰면 공식 한국어 표기를 어긋나게 만든다
///
/// 보고서는 `P3-SOA-3`을 「**단순 자동 복구**가 빠져 있다」로 적었다. 그런데
/// **공식 한국어 문서의 표기는 「간소화된 자동 복구」**다(`ko_kr` 판 전문 실측 —
/// 제목·목차·비교 표·주요 개념 전부 「간소화된」이고 「단순」은 0건).
/// 그리고 **SOA 쪽은 그 표기를 이미 쓰고 있었다**(`soa-t1-4.md:130`) — 즉
/// 「후자만 다룬다」는 보고서의 전제가 틀렸다. 실제로 빠져 있던 것은
/// **기본 활성**이라는 사실이다.
///
/// ⭐ 거꾸로, **라이브 `saa-t2-3.md` 가 「단순 자동 복구」를 2곳에 쓰고 있었다**
/// (레포 전수: 「단순」 SAA md 2 · 「간소화된」 SOA md 1). 보고서를 따랐다면
/// **비공식 표기를 SOA 로 번지게** 했을 자리다. 그래서 이 배치는 SOA 3건과 함께
/// **표기 계열을 전수로 닫는다** — 계열을 통째로 닫지 않으면 전수 가드를 초록으로
/// 만들 수 없다(2026-11-06 SOA·CLF·SAA 배치에서 반복 확인된 규율).
///
/// ## 비자명한 공식 사실 (직접 인용)
///
/// ⚠️ **`16,000 IOPS + 1,000 MiB/s` 는 gp2 의 값이 아니라 Outposts 의 gp3 한도
/// 조합이다** — `general-purpose.html` 이 `On Outposts, gp3 volumes support sizes
/// up to 16 TiB, IOPS up to 16,000, and throughput up to 1,000 MiB/s.` 로 **그 두
/// 수치를 한 문장에** 적는다. 보고서는 1,000 만 Outposts 로 귀속했는데 **16,000 도
/// 같은 문장에 있다.** 일반 리전 gp3 는 베이스라인 `3,000 IOPS`·`125 MiB/s`,
/// 최대 `80,000 IOPS`·`2,000 MiB/s` 다.
///
/// ⚠️ **gp2 의 16,000 IOPS 는 「상한에 가까운 값」이 아니라 정확한 상한**이다 —
/// `maximum of 16,000 at a rate of 3 IOPS per GiB` 이고 `which is reached at
/// 5,334 GiB` 다. gp2 최대 처리량은 `250 MiB/s` 라 **1,000 MiB/s 는 gp2 쪽
/// 어느 수치도 아니다**.
///
/// ⚠️ **자동 복구 메커니즘은 둘이고 간소화된 쪽이 기본 활성**이다 —
/// `By default, simplified automatic recovery is enabled during instance launch.`
/// 그리고 `Simplified automatic recovery and Amazon CloudWatch action based
/// recovery are only available on supported instances.` 비교 표는 **메탈 인스턴스
/// 크기**를 간소화된 쪽에서 `Excluded`, 복구 시간을 CloudWatch 쪽이
/// `Faster recovery attempts` 로 적는다.
///
/// ⚠️ **휘발성 메모리 손실은 단정이고, 인스턴스 스토어 손실은 한정이다** —
/// `data stored in volatile memory (RAM) will be lost` (= 「유실될 수 있습니다」가
/// 아니다) / `Data stored on instance store volumes (applicable to CloudWatch
/// action based recovery only)`. 두 손실을 한 괄호에 묶으면 뒤쪽 한정이 사라진다.
///
/// ⚠️ **「Nitro 전용」은 거짓**이다 — 공식은 `supported instances` 로만 한정하고,
/// 간소화된 쪽에서 빠지는 것은 **메탈 인스턴스 크기**다. 회피형 반박
/// (「핵심이 아닙니다」)은 **저작자도 참·거짓을 몰랐다는 신호**이므로 F축 규율대로
/// 참·거짓을 말하게 바꾼다.
///
/// ## 비자명한 규율
///
/// ⚠️ **보고서 범위는 또 하한이었다.** 보고서는 「유실될 수 있습니다」를 `q7`
/// 하나로 적었지만 **같은 파일의 md 에 3곳 더** 있었다(시험 포인트·흔한 함정·자가
/// 점검). **문항 가드는 `.md` 를 보지 않으므로** 금지를 **md + 문항 전수 집계**로
/// 둔다.
///
/// ⚠️ **단위 표기는 이 배치에서 바꾸지 않았다.** 공식 EBS 문서는 처리량을
/// `MiB/s` 로 적는데 이 레포는 `MB/s` 를 쓴다. 그런데 `soa-t1-5` 는 **md 6곳 +
/// 문항 3곳**이 모두 `MB/s` 로 **일관**돼 있어, `W2` 하나만 공식 단위로 쓰면
/// 학습자가 방금 읽은 보기와 어긋난다. 그래서 `W2` 도 **보기와 같은 표기**로
/// 적고, 단위 자체는 **별건**으로 남긴다(레포 전역 `MB/s` 66건 — saa 10 · soa 9 ·
/// dea 30 · mla 5 · dva 12. Kinesis 처럼 공식이 `MB/sec` 로 적는 자리가 섞여
/// 일괄 치환이 불가하다). 대신 가드는 **「한 문항 안에서 두 표기가 섞이지
/// 않는다」**는 불변식으로 두어, 나중에 정규화 배치가 와도 깨지지 않게 했다.
///
/// ⚠️ **`soa_v11_topics_test.dart` 의 `changed` 맵은 날짜를 정확히 비교한다**
/// (SAA 의 하한 비교와 다르다). `soa-t1-4.md` 를 고치면 그 맵도 함께 올려야 한다.
void main() {
  const content = 'assets/content';

  List<File> questionFiles(String cert) => Directory('$content/$cert')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.questions.json'))
      .toList()
    // ⚠️ `listSync()` 순서는 플랫폼마다 다르다.
    ..sort((a, b) => a.path.compareTo(b.path));

  List<File> docFiles(String cert) => Directory('$content/$cert')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> question(String cert, String task, String qid) =>
      questionsOf(File('$content/$cert/$task.questions.json'))
          .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  String doc(String cert, String id) =>
      File('$content/$cert/$id.md').readAsStringSync();

  String blob(Map<String, dynamic> q) => json.encode(q);

  String wrong(Map<String, dynamic> q, String key) =>
      (q['wrongExplanations'] as Map<String, dynamic>)[key] as String;

  /// 「유실될 수 있다」류 완화 표현 탐지기 — 공식은 `will be lost` 로 단정한다.
  /// 탐지기 본체를 함수로 빼서 **양방향 대조군**을 붙인다.
  /// ⚠️ 어형이 둘이다 — 「유실될 수 있습니다/있음」과 「유실 가능」. 리터럴로
  /// 세면 한쪽이 샌다(2026-11-06 AIF 「PT 필수」 교훈).
  bool hedgesMemoryLoss(String text) =>
      RegExp(r'유실(될\s*수\s*있|\s*가능)').hasMatch(text);

  // ═════════════════════ 대조군 ═════════════════════

  test('대조군: 손댄 세 문항이 읽히고 구조가 성립한다', () {
    for (final q in <Map<String, dynamic>>[
      question('soa', 'soa-t1-5', 'soa-t1-5-q6'),
      question('soa', 'soa-t1-4', 'soa-t1-4-q7'),
      question('soa', 'soa-t1-4', 'soa-t1-4-q9'),
    ]) {
      expect((q['options'] as List).length, 4);
      expect((q['wrongExplanations'] as Map).length, 3);
      expect(blob(q).length, greaterThan(400));
    }
  });

  test('§P3-SOA: 정답 인덱스와 verified 가 불변이다', () {
    final q6 = question('soa', 'soa-t1-5', 'soa-t1-5-q6');
    final q7 = question('soa', 'soa-t1-4', 'soa-t1-4-q7');
    final q9 = question('soa', 'soa-t1-4', 'soa-t1-4-q9');
    expect(q6['correct'], 1);
    expect(q7['correct'], 1);
    expect(q9['correct'], 0);
    for (final q in <Map<String, dynamic>>[q6, q7, q9]) {
      expect(q['verified'], true,
          reason: '세 문항은 라이브다 — 핫픽스이고 flip 이 아니다');
    }
  });

  // ═════════════════ P3-SOA-2 — gp2/gp3 수치 귀속 ═════════════════

  group('§P3-SOA-2 16,000 IOPS·1,000 MiB/s 를 gp2 에 귀속하지 않는다', () {
    test('W2 가 Outposts gp3 조합으로 귀속하고 옛 문구가 사라졌다', () {
      final w2 = wrong(question('soa', 'soa-t1-5', 'soa-t1-5-q6'), '2');
      expect(w2.contains('상한에 가까운'), isFalse,
          reason: '16,000 은 gp2 의 정확한 상한이다');
      expect(w2.contains('Outposts'), isTrue);
      expect(w2.contains('2,000'), isTrue, reason: '일반 리전 gp3 최대 처리량');
      expect(w2.contains('250'), isTrue, reason: 'gp2 최대 처리량');
      expect(w2.contains('5,334'), isTrue, reason: '16,000 에 닿는 gp2 용량');
    });

    test('q6 안에서 처리량 단위 표기가 섞이지 않는다', () {
      final b = blob(question('soa', 'soa-t1-5', 'soa-t1-5-q6'));
      final hasMb = RegExp(r'(?<!Mi)MB/s').hasMatch(b);
      final hasMib = b.contains('MiB/s');
      expect(hasMb || hasMib, isTrue, reason: '대조군 — 처리량 단위가 있어야 한다');
      expect(hasMb && hasMib, isFalse,
          reason: '학습자가 방금 읽은 보기와 해설의 단위가 달라지면 안 된다 '
              '(단위 정규화 자체는 별건이다)');
    });

    test('대조군: 정답 보기의 베이스라인 수치는 그대로다', () {
      final q = question('soa', 'soa-t1-5', 'soa-t1-5-q6');
      final right = (q['options'] as List).cast<String>()[q['correct'] as int];
      expect(right.contains('3,000'), isTrue);
      expect(right.contains('125'), isTrue);
    });
  });

  // ═════════════ P3-SOA-3 — 자동 복구 두 메커니즘·손실 단정 ═════════════

  group('§P3-SOA-3 간소화된 자동 복구의 기본 활성과 손실 단정', () {
    test('soa-t1-4.md 가 기본 활성과 지원 인스턴스 조건을 적는다', () {
      final md = doc('soa', 'soa-t1-4');
      expect(md.contains('간소화된 자동 복구'), isTrue);
      expect(md.contains('CloudWatch 작업 기반 복구'), isTrue);
      expect(md.contains('기본적으로 활성화'), isTrue,
          reason: 'By default, simplified automatic recovery is enabled');
      expect(md.contains('지원되는 인스턴스'), isTrue,
          reason: 'only available on supported instances');
      expect(md.contains('메탈 인스턴스'), isTrue,
          reason: '간소화된 쪽에서 제외되는 것이 메탈 인스턴스 크기다');
    });

    test('인스턴스 스토어 손실을 말하는 모든 줄이 CloudWatch 작업 기반으로 한정한다', () {
      final offenders = <String>[];
      var scanned = 0;
      for (final f in <File>[
        File('$content/soa/soa-t1-4.md'),
        File('$content/soa/soa-t1-4.questions.json'),
      ]) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          final l = lines[i];
          if (!l.contains('인스턴스 스토어')) continue;
          if (!l.contains('유실') && !l.contains('손실')) continue;
          scanned++;
          if (!l.contains('CloudWatch')) {
            offenders.add('${f.uri.pathSegments.last}:${i + 1}');
          }
        }
      }
      expect(scanned, greaterThanOrEqualTo(2), reason: '대조군 — 비공허');
      expect(offenders, isEmpty,
          reason: '휘발성 메모리와 한 괄호에 묶으면 뒤쪽 한정이 사라진다: '
              '${offenders.join(' · ')}');
    });

    test('soa-t1-4 전수(md + 문항)에서 손실 완화 표현이 0건이다', () {
      final offenders = <String>[];
      for (final f in <File>[
        File('$content/soa/soa-t1-4.md'),
        File('$content/soa/soa-t1-4.questions.json'),
      ]) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (hedgesMemoryLoss(lines[i])) {
            offenders.add('${f.uri.pathSegments.last}:${i + 1}');
          }
        }
      }
      expect(offenders, isEmpty,
          reason: '공식은 will be lost 로 단정한다: ${offenders.join(' · ')}');
    });

    test('대조군: 탐지기가 옛 문구를 잡고 새 문구는 통과한다', () {
      expect(hedgesMemoryLoss('인메모리 데이터는 유실될 수 있습니다'), isTrue);
      expect(hedgesMemoryLoss('인메모리는 유실 가능'), isTrue);
      expect(hedgesMemoryLoss('휘발성 메모리(RAM) 데이터는 유실됩니다'), isFalse,
          reason: '정정문 자신이 걸리면 안 된다');
    });
  });

  // ═══════════ P3-SOA-4 — 회피형 반박을 참·거짓 서술로 ═══════════

  test('§P3-SOA-4 q9 W1 이 Nitro 전용 주장을 거짓으로 말한다', () {
    final w1 = wrong(question('soa', 'soa-t1-4', 'soa-t1-4-q9'), '1');
    expect(w1.contains('핵심이 아닙니다'), isFalse,
        reason: '회피형 반박은 참·거짓을 말하지 않는다(F축)');
    expect(w1.contains('Nitro'), isTrue);
    expect(w1.contains('지원되는 인스턴스'), isTrue);
  });

  // ═══════ 파생 — 「단순 자동 복구」 비공식 표기 전수 (SAA 라이브) ═══════

  group('공식 한국어 표기는 「간소화된 자동 복구」다', () {
    test('레포 전수에서 「단순 자동 복구」가 0건이다', () {
      final offenders = <String>[];
      var scanned = 0;
      for (final cert in <String>[
        'clf',
        'saa',
        'soa',
        'dea',
        'mla',
        'aif',
        'dva',
      ]) {
        final dir = Directory('$content/$cert');
        if (!dir.existsSync()) continue;
        for (final f in <File>[...docFiles(cert), ...questionFiles(cert)]) {
          scanned++;
          if (f.readAsStringSync().contains('단순 자동 복구')) {
            offenders.add(f.uri.pathSegments.last);
          }
        }
      }
      expect(scanned, greaterThanOrEqualTo(100), reason: '전수 대조군 — 비공허');
      expect(offenders, isEmpty,
          reason: '공식 ko 판은 「간소화된 자동 복구」로만 적는다: '
              '${offenders.join(' · ')}');
    });

    test('공식 표기가 SAA·SOA 양쪽에 실재한다', () {
      expect(doc('soa', 'soa-t1-4').contains('간소화된 자동 복구'), isTrue);
      expect(doc('saa', 'saa-t2-3').contains('간소화된 자동 복구'), isTrue,
          reason: '표기만 바꿨고 그 표의 사실(기본 활성)은 원래 옳았다');
    });
  });
}
