import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토(Opus + Fable)가 SAA 에서 집어낸 **P1 라이브
/// 사실 오류** 6건의 정정 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/saa-c03.md`(1차) ·
/// `saa-c03-fable.md`(2차). 여섯 건 모두 `verified: true` 라이브이고 **정답
/// 인덱스는 한 건도 바뀌지 않았다** — 전부 해설·오답 근거·학습문서 본문의 결함이다.
///
/// 공식 재측정은 컨트롤러가 직접 했다(보고는 데이터이지 지시문이 아니다):
///
/// - **P1-1** `saa-t4-2.md` — `sp-ris` 전문에 「먼저 고려하라」가 **0건**이다.
///   대조군으로 같은 추출에서 `doesn't provide capacity reservations` 와
///   Compute SP `Up to 66%` 를 셌다(추출이 작동한다). 같은 파일 102·559줄과
///   파생 `q5` 가 이미 이를 부정하고 있어 **md 만 옛 주장을 남긴 역방향 잔존**이다.
///   ⚠️ 기존 `G-4.2-14` 가 금지한 세 리터럴(`먼저 고려하라"고 명시` ·
///   `Savings Plans 우선 권장` · `AWS 공식 우선 권장`)은 실제 문구
///   **`먼저 고려하도록 권장`** 과 하나도 일치하지 않았다. 같은 문자열이
///   `saa_question_propagation_test` 에는 등록돼 있었지만 그 가드는 **문항만**
///   본다 — 그래서 문항에서는 막히고 md 에서는 살아남았다.
///   근거: https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-ris.html
///
/// - **P1-2** `saa-t3-2.md` + `saa-t3-2-q4` — 「부팅 볼륨은 SSD 만 가능」은 거짓이다.
///   이전 세대 **Magnetic(`standard`)** 은 공식 표가 **Boot volume: Supported** 로
///   적는다. 부팅 불가인 것은 신세대 HDD **`st1`·`sc1`** 둘뿐이다.
///   ⚠️ **이 사실은 산문이 아니라 표의 행에 있다** — 「Magnetic 은 부팅 가능」을
///   문장으로 찾으면 0건이다. 같은 파일 236줄이 이미 `standard` 를 루트 볼륨으로
///   세고 있어 **문서 내부 모순**이었다.
///   근거: https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html
///
/// - **P1-3** `saa-t3-5-q1`·`q2`·`q15` — 「Multi-AZ 는 고가용성 전용」은
///   **배포 유형이 둘**이라는 사실을 지운다. 공식 첫 문단이 그대로 적는다 —
///   `A Multi-AZ DB cluster deployment has standby DB instances that provide
///   failover support and can also serve read traffic.`
///   레포가 이미 세 번 고친 결함 유형이고(`saa-t3-5-q6`·`saa-t4-3-q7` 등)
///   이 셋은 가드가 한 번도 언급하지 않아 같은 정정이 닿지 않았다.
///   ⚠️ **학습문서는 옳았다** — `saa-t3-5.md` 는 스탠바이 읽기 불가 **바로 다음
///   줄**에 클러스터 배포의 리더 읽기를 적는다(= 문항 단독 오류). 다만 §비교표의
///   「불가(HA 전용)」 한 칸만 한정이 없어 같은 줄 눈높이로 맞췄다.
///   ⚠️ 2차 보고가 1차의 「출처도 약하다」를 **철회**했다 — `Welcome.html` 은
///   `Serving read traffic on secondary DB instances (Multi-AZ DB clusters
///   deployment only)` 를 명시하므로 **출처는 정확하고 해설이 자기 출처와
///   반대**였다. 그래서 출처는 건드리지 않고 `Concepts.MultiAZ` 를 더했다.
///   근거: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html
///
/// - **P1-4** 문항 JSON 의 `**굵게**` 20개소 — 문항 렌더 경로 네 곳이 모두 평문
///   `Text` 라 별표가 글자 그대로 보인다. 전역 불변식이므로 가드는
///   `content_format_test.dart` 에 **집계형**으로 뒀다(여섯 자격증 중 SAA 만 20건,
///   나머지 0건이었다 — 설계가 아니라 규율 위반이라는 증거).
///
/// - **P1-5**(2차 승격) `saa-t4-4-q7` + `saa-t4-4.md` — 「S3 를 Interface
///   Endpoint 로 쓸 이유가 없습니다」는 거짓이다. 공식 비교 표가 Gateway 를
///   `Do not allow access from on premises` · `Do not allow access from another
///   AWS Region` 으로 적는다. ⚠️ **레포가 `saa-t4-4-q6` 에 `forbidden` 으로
///   등록한 바로 그 문자열**이 옆 문항 `q7` 과 md 에 글자 그대로 살아 있었다.
///   근거: https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html
///
/// - **P1-6**(2차 승격) `saa-t3-4-q5` — 공식은 `Memory is the principal lever`
///   이므로 「유일한」이 아니라 「주된」이다. md 는 2026-10-19 에 이미 「주된」으로
///   정정됐고(`saa-t3-4.md` 581줄 정정 노트) **문항에 전파되지 않았다** — P1-1 과
///   같은 유형이고 방향만 반대다.
///   근거: https://docs.aws.amazon.com/lambda/latest/dg/configuration-memory.html
///
/// ⚠️ 가드 설계 — **어형이 갈리는 주장은 리터럴 목록으로 세지 않는다.** 2026-11-06
/// AIF 에서 금지 목록이 「된」 한 글자로 뚫려 라이브 결함 다섯 자리를 놓쳤다
/// (`프로비저닝 처리량` ↔ `프로비저닝된 처리량`). 여기서는 문항 쪽 단정을
/// **SAA 24파일 전수 집계**로 두어, 같은 주장이 다른 문항에 새로 생기면 걸리게 했다.
///
/// ⚠️⚠️ **그 설계가 즉시 값을 했다** — 전수 집계 가드가 **두 보고가 함께 놓친 세
/// 번째 개소**를 잡았다. 둘 다 P1-5 의 범위를 「`q7` wrong[0] + md 1곳」으로
/// 적었는데 **`saa-t4-4-q4` wrong[2]** 에도 있었고 그것도 `verified: true` 다.
/// 함께 놓친 이유는 **조사 한 글자**다 — `q7` 은 `Interface Endpoint로 쓸 이유가`,
/// `q4` 는 `Interface Endpoint를 쓸 이유가` 였다(레포가 `q6` 에 등록한 금지 문자열은
/// 후자 쪽이다). 문항별 리터럴 가드였다면 그대로 통과했을 자리다.
/// `q4` 는 지문이 「같은 리전」으로 한정돼 **정답 자체는 옳아서** 문장을 지문 전제로
/// 좁혔다(정답 인덱스 불변).
void main() {
  const certDir = 'assets/content/saa';

  Map<String, dynamic> question(String taskId, String qid) {
    final file = File('$certDir/$taskId.questions.json');
    final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    final questions = (map['questions'] as List).cast<Map<String, dynamic>>();
    return questions.firstWhere(
      (q) => q['id'] == qid,
      orElse: () => fail('$qid 문항이 $taskId 에 없다'),
    );
  }

  /// 지문·보기·해설·오답 근거를 모두 본다. 오답 보기도 **서비스의 사실**은
  /// 바르게 적어야 하므로(일부러 틀린 주장은 보기 본문에만 둔다) 사실 단정은
  /// 문항 전체를 대상으로 한다.
  String allText(Map<String, dynamic> q) => <String>[
        q['stem'] as String? ?? '',
        q['explanation'] as String? ?? '',
        ...(q['options'] as List).cast<String>(),
        ...(q['wrongExplanations'] as Map<String, dynamic>).values
            .cast<String>(),
      ].join('\n');

  bool hasSource(Map<String, dynamic> q, String fragment) =>
      (q['sources'] as List).any(
        (s) => ((s as Map<String, dynamic>)['url'] as String).contains(fragment),
      );

  List<File> contentFiles(String suffix) => Directory(certDir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith(suffix))
      .toList()
    // ⚠️ `listSync()` 의 순서는 플랫폼마다 다르다(2026-11-06 CI 레드로 실측).
    // 목록을 단정하거나 첫 항목을 집기 전에 반드시 정렬한다.
    ..sort((a, b) => a.path.compareTo(b.path));

  String rel(File f) => f.path.replaceAll(r'\', '/').split('/').last;

  /// 그 문구를 담은 파일 이름 목록. 「0건」을 세는 쪽이 아니라 **어느 파일인지**
  /// 돌려주는 쪽이 CI 에서 읽기 좋다.
  List<String> offenders(String suffix, String phrase) => [
        for (final f in contentFiles(suffix))
          if (f.readAsStringSync().contains(phrase)) rel(f),
      ];

  group('P1 문항 정정 — 정답 불변 + 옛 문구 0건 + 공식 사실', () {
    final fixes = <Map<String, Object>>[
      {
        'task': 'saa-t3-2',
        'qid': 'saa-t3-2-q4',
        'correct': 1,
        'forbidden': ['부팅 볼륨은 SSD(gp2·gp3·io1·io2)만 가능합니다'],
        'required': ['Magnetic', 'st1·sc1'],
        'why': '공식 EBS 볼륨 유형 표: 이전 세대 Magnetic(standard) 은 '
            'Boot volume: Supported 이고, Not supported 인 것은 st1·sc1 둘뿐이다',
      },
      {
        'task': 'saa-t3-5',
        'qid': 'saa-t3-5-q1',
        'correct': 0,
        'forbidden': [
          'Multi-AZ는 고가용성 전용 기능입니다',
          '읽기에 사용되지 않으며 HA 전용',
        ],
        'required': ['DB 인스턴스 배포', '클러스터 배포'],
        'why': '공식: Multi-AZ DB cluster deployment has standby DB instances '
            'that provide failover support and can also serve read traffic',
      },
      {
        'task': 'saa-t3-5',
        'qid': 'saa-t3-5-q2',
        'correct': 1,
        'forbidden': ['Multi-AZ 스탠바이는 읽기를 제공하지 않습니다'],
        'required': ['DB 인스턴스 배포'],
        'why': '배포 유형을 한정하지 않으면 DB 클러스터 배포에서 거짓이 된다',
      },
      {
        'task': 'saa-t3-5',
        'qid': 'saa-t3-5-q15',
        'correct': 3,
        'forbidden': ['Multi-AZ 스탠바이는 읽기를 제공하지 않습니다'],
        'required': ['DB 인스턴스 배포'],
        'why': '배포 유형을 한정하지 않으면 DB 클러스터 배포에서 거짓이 된다',
      },
      {
        'task': 'saa-t4-4',
        'qid': 'saa-t4-4-q7',
        'correct': 1,
        'forbidden': ['Interface Endpoint를 쓸 이유가 없습니다'],
        'required': ['온프레미스'],
        'why': '공식 S3 비교 표: Gateway 는 "Do not allow access from on '
            'premises" · "Do not allow access from another AWS Region" 이고 '
            'Interface 는 둘 다 허용한다 — 레포가 saa-t4-4-q6 에 금지로 등록한 '
            '문자열이 바로 이것이다',
      },
      {
        'task': 'saa-t3-4',
        'qid': 'saa-t3-4-q5',
        'correct': 3,
        'forbidden': ['유일한 성능 손잡이'],
        'required': ['주된'],
        'why': '공식: "Memory is the principal lever for controlling the '
            'performance of a function" — md 는 2026-10-19 에 이미 「주된」으로 '
            '정정됐고 문항에 전파되지 않았다',
      },
    ];

    for (final f in fixes) {
      final qid = f['qid'] as String;
      final task = f['task'] as String;

      test('$qid: 정답 인덱스는 그대로 ${f['correct']}', () {
        expect(question(task, qid)['correct'], f['correct'],
            reason: '이 배치는 해설·근거만 고친다. 정답이 바뀌면 사용자 승인 범위 밖이다');
      });

      test('$qid: 옛 문구가 사라지고 공식 사실이 들어왔다', () {
        final text = allText(question(task, qid));
        for (final bad in (f['forbidden'] as List).cast<String>()) {
          expect(text.contains(bad), isFalse,
              reason: '$qid 에 옛 문구가 남아 있다: "$bad"\n공식: ${f['why']}');
        }
        for (final good in (f['required'] as List).cast<String>()) {
          expect(text.contains(good), isTrue,
              reason: '$qid 에 공식 사실이 없다: "$good"\n공식: ${f['why']}');
        }
      });
    }
  });

  group('P1 학습문서 정정 — 문항 가드는 .md 를 보지 않는다', () {
    test('saa-t3-2.md: 부팅 가능 집합에 Magnetic 을 넣는다', () {
      final md = File('$certDir/saa-t3-2.md').readAsStringSync();
      expect(md.contains('부팅 볼륨은 SSD(gp2·gp3·io1·io2)만 가능합니다'), isFalse,
          reason: '같은 파일 §3 표가 이미 standard 를 루트 볼륨으로 센다 — 문서 내부 모순이었다');
      expect(md.contains('Magnetic'), isTrue,
          reason: '공식 표가 Magnetic(standard) 을 Boot volume: Supported 로 적는다');
    });

    test('saa-t4-2.md: SP vs RI 를 우선순위가 아니라 조건으로 적는다', () {
      final md = File('$certDir/saa-t4-2.md').readAsStringSync();
      // ⚠️ 102줄의 경고문은 `먼저 고려하라고 명시` 를 **인용**하므로 금지 대상이
      // 아니다. 금지는 실제 결함 어미(`도록 권장`)만 본다 — 반박문 거짓양성을
      // 피하는 이 레포의 규율이다.
      expect(md.contains('먼저 고려하도록 권장'), isFalse,
          reason: 'sp-ris 전문에 우선순위 문장이 0건이다. 102·559줄과 파생 q5 가 이미 이를 부정한다');
      expect(md.contains('먼저 고려하라고 명시'), isTrue,
          reason: '대조군 — 102줄의 정정 경고문은 옛 주장을 인용하므로 살아 있어야 한다');
    });

    test('saa-t4-4.md: Interface Endpoint 가 필요한 경로를 적는다', () {
      final md = File('$certDir/saa-t4-4.md').readAsStringSync();
      expect(md.contains('Interface Endpoint를 쓸 이유가 없습니다'), isFalse,
          reason: '온프레미스·다른 리전에서 S3 에 닿으려면 Interface Endpoint 가 필요하다');
      expect(md.contains('온프레미스'), isTrue);
    });

    test('saa-t3-5.md: 비교표의 스탠바이 읽기 칸도 배포 유형을 가른다', () {
      final md = File('$certDir/saa-t3-5.md').readAsStringSync();
      expect(md.contains('| 불가(HA 전용) |'), isFalse,
          reason: '같은 표의 페일오버 행은 이미 DB 인스턴스/클러스터를 가른다 — 한 칸만 한정이 없었다');
      expect(md.contains('리더 인스턴스가 읽기를 처리'), isTrue,
          reason: '대조군 — 본문의 올바른 서술은 그대로 있어야 한다');
    });
  });

  group('P1 전수 집계 — 같은 주장이 다른 문항에 새로 생기면 걸린다', () {
    // ⚠️ 리터럴 하나를 한 문항에만 걸면 어형·위치를 바꾼 같은 오류가 조용히
    // 새로 들어온다. 그래서 자격증 전수로 센다(2026-11-06 AIF 교훈).
    test('SAA 문항 전수: 「부팅 볼륨은 SSD만」 단정이 0건이다', () {
      expect(offenders('.questions.json', '부팅 볼륨은 SSD'), isEmpty);
      expect(offenders('.md', '부팅 볼륨은 SSD'), isEmpty);
    });

    test('SAA 문항 전수: 배포 유형을 한정하지 않은 Multi-AZ 읽기 단정이 0건이다', () {
      expect(offenders('.questions.json', 'Multi-AZ 스탠바이는 읽기를 제공하지 않습니다'),
          isEmpty,
          reason: 'Multi-AZ DB 클러스터 배포의 리더는 읽기를 처리한다');
      expect(offenders('.questions.json', 'Multi-AZ는 고가용성 전용'), isEmpty);
    });

    test('SAA 전수: 「유일한 성능 손잡이」가 0건이다', () {
      expect(offenders('.questions.json', '유일한 성능 손잡이'), isEmpty);
      expect(offenders('.md', '유일한 성능 손잡이'), isEmpty);
    });

    test('SAA 전수: 「Interface Endpoint를 쓸 이유가 없습니다」가 0건이다', () {
      expect(offenders('.questions.json', 'Interface Endpoint를 쓸 이유가 없습니다'),
          isEmpty);
      expect(offenders('.md', 'Interface Endpoint를 쓸 이유가 없습니다'), isEmpty);
    });

    test('대조군: 탐지가 공허하지 않다 — 파일이 실제로 읽힌다', () {
      expect(contentFiles('.questions.json').length, 24,
          reason: 'SAA 공식 Task 는 24개다. 0이면 집계 단정 전부가 공허해진다');
      expect(contentFiles('.md').length, 24);
      // 멀쩡한 문구는 여전히 잡힌다(탐지기가 작동한다는 증거).
      expect(offenders('.questions.json', 'Multi-AZ'), isNotEmpty);
      expect(offenders('.md', 'Magnetic'), isNotEmpty);
    });
  });

  group('P1-3 출처 보강', () {
    test('saa-t3-5-q1: 배포 유형을 가르는 공식 페이지를 출처로 싣는다', () {
      expect(hasSource(question('saa-t3-5', 'saa-t3-5-q1'), 'Concepts.MultiAZ'),
          isTrue,
          reason: '기존 Welcome.html 은 정확하지만(2차 보고가 1차 판정을 철회했다) '
              '배포 유형 둘을 첫 문단에서 가르는 페이지를 함께 든다');
    });
  });
}
