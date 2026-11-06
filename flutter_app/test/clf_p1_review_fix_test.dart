import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토(Opus 1차 + Fable 2차)가 CLF 에서 집어낸
/// **P1 4건**의 정정 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/clf-c02-dva-c03.md`(1차) ·
/// `clf-c02-dva-c03-fable.md`(2차).
///
/// ⚠️⚠️ **CLF 는 다른 자격증과 다르다 — 결함이 승인된 라이브 음성에 들어 있다.**
/// 네 건 중 셋이 **대본 4편 · 7 세그먼트**에 번져 있고 전부 `enrichedScriptText`
/// 이므로 **mp3 에 실제로 들어 있다**(`gen_lecture_audio.py` 의 `_spoken_body`:
/// `kind == table` 이면 `audioSummary`, 그 외는 `enrichedScriptText` → `scriptText`.
/// `sourceExcerpt` 는 **발화되지 않는다**). 그래서 이 가드는 md·문항만 보지 않고
/// **대본의 「발화 본문」까지 같은 규칙으로 센다.**
///
/// 공식 재측정은 컨트롤러가 직접 했다(보고는 데이터이지 지시문이 아니다):
///
/// - **P1-1** 「도메인 2가 30%로 가장 크다」 — md 3편 + 발화 3곳.
///   공식 CLF-C02 「내용 개요」는 도메인 1 **24%** · 2 **30%** · 3 **34%** · 4 **12%**
///   이므로 최대는 **도메인 3**이다. ⭐ 레포 안에 정답이 이미 있었다 —
///   `exam_guides/CLF-C02.json` 의 `weightPct` 가 34 를 최대로 들고 있고,
///   `t3-2.md` 와 `clf-t3-2` seg006 은 「도메인 3 34% 최대」를 **옳게** 말한다.
///   **학습자가 네 편의 강의에서 「가장 큰 도메인」을 두 가지로 들었다.**
///   근거: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/cloud-practitioner-02.html
///
/// - **P1-2** `clf-t4-1-q2` 가 Compute Savings Plans 를 **72%** 로 적는다.
///   공식은 Compute SP **최대 66%** · EC2 Instance SP **최대 72%** 이고, 그
///   트레이드오프(유연성 ↔ 할인율)가 이 Task 의 출제 축이다. 해설이 **유연성과
///   최고 할인율을 한 플랜에 결합**해 축을 무너뜨렸다. ⭐ **학습문서와 음성은
///   이미 옳았다** — `t4-1.md:73`·`:126` 과 `clf-t4-1` seg025 의 발화문이 66/72 를
///   가른다. **문항과 참고자료 한 줄만 옛 서술에 남았다**(발화 전파 0).
///   근거: https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-ris.html
///
/// - **P1-3** Audit Manager 신규 중단을 「2024년 이후」로, 그리고 「공식 가이드가
///   거버넌스 서비스로 명시한다」로 적었다 — md 1 + 발화 1. 공식 공지는
///   **2026-04-30**이고(`aws.amazon.com/audit-manager/`: `starting on 4/30/2026`,
///   사용자 안내서 배너: `no longer open to new customers`), **공식 가이드 작업
///   2.2 의 관련 기술에는 Audit Manager 가 0건**이다 — 지금은
///   `CloudWatch를 통한 모니터링, AWS CloudTrail, AWS Config를 통한 감사,
///   액세스 보고서를 통한 보고` 가 그 자리다.
///   근거: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/cloud-practitioner-02-domain2.html
///
/// - **P1-4** 「CLF-C02 공식 시험 가이드는 전통적 분류(Basic·Developer·Business·
///   Enterprise)를 명시한다」 — md 2 + 발화 2. **거짓이다.** 공식 작업 4.3 의
///   관련 기술은 `고객 서비스 및 커뮤니티, 기본 지원, AWS Business Support+,
///   AWS Enterprise Support, AWS Unified Operations` 다. 즉 가이드는 **신규 플랜**을
///   명시하는데 문서는 그 반대를 말하고, 그 결과 **학습자에게 「시험에는 옛
///   4단계로 외우라」고 지시**했다 — 사실 하나가 틀린 것이 아니라 **학습 전략을
///   틀린 방향으로 고정**하는 형태다.
///   근거: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/cloud-practitioner-02-domain4.html
///         https://docs.aws.amazon.com/awssupport/latest/user/aws-support-plans.html
///
/// ⚠️⚠️ **보고서 범위가 양방향으로 틀렸고, 이번엔 「과대」가 결정적이었다.**
/// 1차·2차 모두 P1-4 의 발화를 `clf-t4-3` **seg014·026·030 세 곳**으로 적었는데,
/// **seg030 은 결함이 아니다** — 그 발화문은 「전통적인 비즈니스와 디벨로퍼
/// 플랜은 2027년 1월 1일에 단종될 예정」으로 **공식과 정확히 일치한다**(현행
/// `aws-support-plans.html` 의 End of Support Notice). 보고를 그대로 따랐다면
/// **옳은 문장을 고쳤다.** 아래 대조군이 그 문장을 **지킨다**.
/// 반대로 과소도 있었다 — 1차의 좁은 탐침은 P1-1 발화를 1곳으로 셌고(실제 3곳),
/// 어미·단위를 푼 탐침이 세 곳을 잡았다.
///
/// ⚠️ **사람이 바꿀 상태는 단정하지 않는다.** 대본 텍스트를 고치면 재합성이
/// 필요하고, `reviewStatus: approved` 는 **사람의 청취 서명**이다(문항의
/// `verified: true` 와 같은 규율). 그래서 이 파일은 「지금 미승인이다」를 **고정하지
/// 않는다** — 그렇게 박으면 사용자의 재승인이 레드로 끝난다(`content_index_test`
/// 의 `audioApproved ↔ audio_meta` 동기화 단정이 양방향을 이미 지킨다).
void main() {
  const contentDir = 'assets/content/clf';
  const audioDir = 'assets/audio/clf';

  List<File> contentFiles(String suffix) => Directory(contentDir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith(suffix))
      .toList()
    // ⚠️ `listSync()` 순서는 플랫폼마다 다르다(2026-11-06 CI 레드로 실측).
    ..sort((a, b) => a.path.compareTo(b.path));

  String base(File f) => f.path.replaceAll(r'\', '/').split('/').last;

  String doc(String id) => File('$contentDir/$id.md').readAsStringSync();

  Map<String, dynamic> question(String taskId, String qid) {
    final map = json.decode(
        File('$contentDir/$taskId.questions.json').readAsStringSync()) as Map<String, dynamic>;
    return (map['questions'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));
  }

  String allText(Map<String, dynamic> q) => <String>[
        q['stem'] as String? ?? '',
        q['explanation'] as String? ?? '',
        ...(q['options'] as List).cast<String>(),
        ...(q['wrongExplanations'] as Map<String, dynamic>).values
            .cast<String>(),
        ...(q['sources'] as List).map(
            (s) => (s as Map<String, dynamic>)['title'] as String? ?? ''),
      ].join('\n');

  /// 대본의 **발화 본문** — `gen_lecture_audio.py` 의 `_spoken_body` 와 같은 규칙.
  /// `sourceExcerpt` 는 읽지 않는다(발화되지 않으므로).
  List<({String docId, String segId, String text})> spokenSegments() {
    final out = <({String docId, String segId, String text})>[];
    final dirs = Directory(audioDir).listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final d in dirs) {
      final f = File('${d.path}/script.json');
      if (!f.existsSync()) continue;
      final docId = d.path.replaceAll(r'\', '/').split('/').last;
      final map = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
      for (final seg in (map['segments'] as List).cast<Map<String, dynamic>>()) {
        if (seg['skip'] == true) continue;
        final body = seg['kind'] == 'table'
            ? (seg['audioSummary'] as String? ?? '')
            : (seg['enrichedScriptText'] as String? ??
                seg['scriptText'] as String? ??
                '');
        if (body.isEmpty) continue;
        out.add((docId: docId, segId: seg['id'] as String? ?? '?', text: body));
      }
    }
    return out;
  }

  /// md 줄 · 문항 전체 · 대본 발화 본문을 한 규칙으로 센다.
  List<String> sweep(RegExp re) {
    final hits = <String>[];
    for (final f in contentFiles('.md')) {
      final lines = f.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (re.hasMatch(lines[i])) hits.add('${base(f)}:${i + 1}');
      }
    }
    for (final f in contentFiles('.questions.json')) {
      final map = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
      for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
        if (re.hasMatch(allText(q))) hits.add(q['id'] as String);
      }
    }
    for (final s in spokenSegments()) {
      if (re.hasMatch(s.text)) hits.add('${s.docId}/${s.segId}');
    }
    hits.sort();
    return hits;
  }

  // ───────────────────── 탐지기가 공허하지 않다 ─────────────────────

  group('대조군 — 탐지 범위가 실재한다', () {
    test('md·문항·대본을 모두 읽는다', () {
      expect(contentFiles('.md').length, 19, reason: 'CLF 학습문서는 19편이다');
      expect(contentFiles('.questions.json').length, 19);
      final spoken = spokenSegments();
      expect(spoken.length, greaterThan(500),
          reason: '발화 세그먼트가 0이면 대본 단정 전부가 공허하다');
      expect(spoken.map((s) => s.docId).toSet().length, 19,
          reason: 'CLF 대본 19편 전부를 본다');
    });

    test('sourceExcerpt 는 발화로 세지 않는다', () {
      // clf-t4-1 seg025 는 sourceExcerpt·scriptText 에 옛 결합(72% + Fargate·Lambda)을
      // 담고 있지만 enrichedScriptText 가 66/72 를 **옳게** 가르므로 발화는 정상이다.
      // 그래서 「발화 본문」 규칙으로는 걸리지 않아야 한다.
      final seg = spokenSegments()
          .where((s) => s.docId == 'clf-t4-1' && s.segId == 'seg025')
          .toList();
      expect(seg, hasLength(1));
      expect(seg.first.text.contains('66'), isTrue,
          reason: 'enrichedScriptText 가 발화 본문으로 선택돼야 한다');
    });
  });

  // ───────────────────── P1-1 도메인 비중 ─────────────────────

  group('P1-1 최대 비중 도메인은 3(34%)이다', () {
    /// 「최대 비중」을 주장하는 줄인지. ⚠️ **정정문 자신을 걸지 않도록** 「도메인 3
    /// / 34%」를 함께 적는 줄은 제외한다 — 고친 문장은 반드시 진짜 최대를 명시하므로
    /// 이 예외는 "최대를 말하려면 도메인 3을 들어야 한다"는 규칙이 된다.
    /// (첫 규칙은 `30%로 큰 축이고(가장 큰 것은 34%인 도메인 3입니다)` 를 위반으로
    ///  잡았다 — 탐지기를 먼저 좁혔다.)
    bool claimsWrongMax(String text) {
      final says = RegExp(r'(도메인\s*2|30\s*(%|퍼센트))[^.。\n]{0,40}'
              r'가장\s*(크|큽|큰)')
          .hasMatch(text);
      if (!says) return false;
      return !RegExp(r'도메인\s*3|34\s*(%|퍼센트)').hasMatch(text);
    }

    test('대조군: 탐지기가 옛 문구를 잡고 정정문은 통과시킨다', () {
      expect(claimsWrongMax('- **도메인 2는 시험 비중 30%로 가장 큽니다.**'), isTrue);
      expect(claimsWrongMax('이 도메인은 시험 비중이 30%로 전체에서 가장 큽니다.'), isTrue);
      expect(claimsWrongMax('도메인 2는 시험 비중이 30퍼센트로 가장 큽니다.'), isTrue);
      expect(
          claimsWrongMax('도메인 2는 시험 비중 30%로 큰 축이고'
              '(가장 큰 것은 34%인 도메인 3입니다), 접근 관리는'),
          isFalse);
      expect(claimsWrongMax('도메인 3은 시험 비중 34%로 가장 크고'), isFalse);
    });

    test('「도메인 2가 가장 크다」가 0건이다 (md·문항·발화 전수)', () {
      final hits = <String>[];
      for (final f in contentFiles('.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (claimsWrongMax(lines[i])) hits.add('${base(f)}:${i + 1}');
        }
      }
      for (final f in contentFiles('.questions.json')) {
        final map = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
        for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
          if (claimsWrongMax(allText(q))) hits.add(q['id'] as String);
        }
      }
      for (final s in spokenSegments()) {
        if (claimsWrongMax(s.text)) hits.add('${s.docId}/${s.segId}');
      }
      hits.sort();
      expect(hits, isEmpty,
          reason: '공식 「내용 개요」는 24·30·34·12 이고 최대는 도메인 3 이다:\n'
              '${hits.join(', ')}');
    });

    test('대조군: 「도메인 3이 34%로 가장 크다」는 옳은 서술이라 남아 있다', () {
      final re = RegExp(r'도메인\s*3[^.。\n]{0,40}가장\s*(크|큽|큰)|'
          r'34\s*(%|퍼센트)[^.。\n]{0,40}가장\s*(크|큽|큰)');
      expect(re.hasMatch(doc('t3-2')), isTrue,
          reason: 't3-2.md 는 처음부터 옳았다 — 지우면 안 된다');
      expect(spokenSegments().any((s) => re.hasMatch(s.text)), isTrue,
          reason: 'clf-t3-2 발화도 옳다');
    });

    test('세 문서가 도메인 3(34%)을 병기해 혼동을 닫는다', () {
      for (final id in ['t2-1', 't2-2', 't2-3']) {
        expect(doc(id).contains('34%'), isTrue,
            reason: '$id 이 최대 비중 도메인을 적지 않으면 학습자가 다시 혼동한다');
      }
    });
  });

  // ───────────────────── P1-2 Savings Plans ─────────────────────

  group('P1-2 Compute SP 는 최대 66%, EC2 Instance SP 가 72%다', () {
    test('clf-t4-1-q2: 정답 불변 + 66% 로 정정 + 72% 귀속 명시', () {
      final q = question('t4-1', 'clf-t4-1-q2');
      expect(q['correct'], 0, reason: '정답은 Savings Plans 그대로다');
      final text = allText(q);
      expect(text.contains('66%'), isTrue,
          reason: '공식 sp-ris 비교 표: Compute Savings Plans — Up to 66%');
      expect(text.contains('EC2 Instance'), isTrue,
          reason: '72% 가 어느 플랜의 수치인지 적어야 출제 축이 살아난다');
    });

    /// Compute SP 에 72% 를 결합하는지. ⚠️ **옳은 병기를 걸지 않도록** 같은 범위에
    /// `EC2 Instance`(또는 음차)가 있으면 제외한다 — 72% 를 적는 올바른 문장은 반드시
    /// 그 플랜에 귀속시키므로, 이 예외는 "72% 를 말하려면 EC2 Instance SP 를 들어야
    /// 한다"는 규칙이 된다. (첫 규칙은 정정한 출처 제목
    /// `Compute SP 최대 66%(…) / EC2 Instance SP 최대 72%` 를 위반으로 잡았다.)
    bool combinesComputeWith72(String text) {
      final re = RegExp(r'(Compute\s*(Savings\s*Plans|SP)|컴퓨트\s*세이빙스)'
          r'[^.。\n]{0,60}72\s*(%|퍼센트)');
      if (!re.hasMatch(text)) return false;
      return !RegExp(r'EC2\s*Instance|이씨투\s*인스턴스').hasMatch(text);
    }

    test('대조군: 탐지기가 옛 결합을 잡고 옳은 병기는 통과시킨다', () {
      expect(
          combinesComputeWith72(
              'Compute Savings Plans는 … Fargate·Lambda 사용에도 적용되어 유연합니다(최대 72% 절감)'),
          isTrue);
      expect(
          combinesComputeWith72(
              'Compute SP 최대 66%(EC2·Fargate·Lambda 유연) / EC2 Instance SP 최대 72%'),
          isFalse);
      expect(
          combinesComputeWith72(
              '컴퓨트 세이빙스 플랜은 최대 66퍼센트를 할인하고, 이씨투 인스턴스 세이빙스 플랜은 최대 72퍼센트까지'),
          isFalse);
    });

    test('Compute SP 에 72% 를 붙인 결합이 0건이다 (문항·발화)', () {
      final hits = <String>[];
      for (final f in contentFiles('.questions.json')) {
        final map = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
        for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
          if (combinesComputeWith72(allText(q))) hits.add(q['id'] as String);
        }
      }
      for (final s in spokenSegments()) {
        if (combinesComputeWith72(s.text)) hits.add('${s.docId}/${s.segId}');
      }
      hits.sort();
      expect(hits, isEmpty, reason: hits.join(', '));
    });

    test('대조군: 학습문서와 발화는 처음부터 66/72 를 가른다', () {
      final t41 = doc('t4-1');
      expect(t41.contains('최대 66%'), isTrue);
      expect(t41.contains('최대 72%'), isTrue);
      expect(
          spokenSegments().any((s) =>
              s.docId == 'clf-t4-1' &&
              s.text.contains('66') &&
              s.text.contains('72')),
          isTrue,
          reason: 'clf-t4-1 발화는 고치지 않는다 — 이미 옳다');
    });
  });

  // ───────────────────── P1-3 Audit Manager ─────────────────────

  group('P1-3 Audit Manager 상태와 가이드 수록 여부', () {
    test('「2024년」 연도 오류와 「가이드가 명시한다」가 0건이다', () {
      final hits = sweep(RegExp(
          r'Audit Manager[^.。\n]{0,40}202[45]|'
          r'Audit Manager[^.。\n]{0,40}거버넌스 서비스로 명시|'
          r'거버넌스 서비스로 명시'));
      expect(hits, isEmpty,
          reason: '공식 공지는 2026-04-30 이고, 공식 가이드 작업 2.2 의 관련 기술에 '
              'Audit Manager 는 0건이다:\n${hits.join(', ')}');
    });

    test('t2-2.md 가 현행 상태와 가이드 변경을 적는다', () {
      final t22 = doc('t2-2');
      expect(t22.contains('2026-04-30'), isTrue,
          reason: '"starting on 4/30/2026" — 지금이 막 닫힌 직후라는 맥락이 필요하다');
      expect(t22.contains('CloudTrail'), isTrue,
          reason: '가이드가 그 자리에 넣은 서비스(CloudWatch·CloudTrail·Config)를 적는다');
    });
  });

  // ───────────────────── P1-4 Support 플랜 ─────────────────────

  group('P1-4 공식 가이드는 전통 분류를 명시하지 않는다', () {
    test('「가이드가 전통 분류를 명시한다」가 0건이다 (md·문항·발화 전수)', () {
      final hits = sweep(RegExp(
          r'(시험\s*)?가이드[^.。\n]{0,30}전통[^.。\n]{0,30}(분류|명시)|'
          r'가이드에서는?\s*여전히\s*전통'));
      expect(hits, isEmpty,
          reason: '공식 작업 4.3 의 관련 기술은 Business Support+ · Enterprise · '
              'Unified Operations 다 — 전통 4단계가 아니다:\n${hits.join(', ')}');
    });

    test('t4-3.md 가 현행 공식 플랜을 적는다', () {
      final t43 = doc('t4-3');
      expect(t43.contains('Business Support+'), isTrue);
      expect(t43.contains('Unified Operations'), isTrue);
    });

    test('대조군: 「2027-01-01 단종」은 사실이므로 지우지 않는다', () {
      // ⚠️ 보고서 1차·2차가 모두 `clf-t4-3` seg030 을 결함으로 셌지만, 그 발화문은
      // 공식 End of Support Notice 와 정확히 일치한다. 보고를 따랐다면 옳은 문장을
      // 고쳤다. 이 단정이 그 문장을 지킨다.
      final re = RegExp(r'2027[-년\s.]*0?1[-월\s.]*0?1|2027년\s*1월\s*1일');
      expect(re.hasMatch(doc('t4-3')), isTrue,
          reason: 'Developer·Business·Enterprise On-Ramp 단종일은 공식 사실이다');
      final seg = spokenSegments()
          .where((s) => s.docId == 'clf-t4-3' && re.hasMatch(s.text))
          .toList();
      expect(seg, isNotEmpty,
          reason: '발화에서도 단종 공지는 유지된다(seg030 이 대표)');
    });
  });
}
