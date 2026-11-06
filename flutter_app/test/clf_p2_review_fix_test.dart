import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토의 **CLF 우선순위 2 잔여 네 건**(P2-E·F·G·H) 정정 가드.
/// P2-C(가이드 JSON 6곳)는 `clf_guide_sync_test.dart` 가 따로 본다.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/clf-c02-dva-c03.md`
/// §3(1차) · `clf-c02-dva-c03-fable.md` §1(2차 재검증).
///
/// 공식 재측정은 컨트롤러가 직접 했다. **정답 인덱스는 한 건도 바뀌지 않았다.**
///
/// ## ⚠️ 오디오 전파 — 사용자 판정으로 `clf-t3-8` 한 편만 재합성했다
///
/// 세 건이 **승인된 라이브 음성**에 전파돼 있었다(발화 본문 실측):
/// P2-E 8개소(`clf-t2-4` seg026 · `clf-t3-8` seg036 · `clf-t4-3` 6) ·
/// P2-F Kendra 13개소(`clf-t3-7` 10 세그먼트) · P2-G 10개소(`clf-t3-8` seg034·042).
///
/// 그중 **실제로 거짓인 것은 `clf-t3-8` seg034 뿐이다** — 절 제목이 공식 Task 3.8
/// 제목(「시험 범위에 포함되는 다른 AWS 서비스 범주의 서비스 파악」)을 그대로 따르는데
/// 그 아래 표를 읽으며 **범위 외 서비스를 범위 내로 가르친다.** 나머지 둘은 거짓이
/// 아니다 — **P2-E 플랜 이름은 2027-01-01까지 유효**하고(그리고 **GovCloud(US)에서는
/// 계속 제공**된다), **Kendra 는 기존 고객에게 계속 제공**된다. 그래서 그 둘은 md·문항에만
/// 반영했다. 재합성은 그 1편을 사람의 청취 재승인까지 비노출로 만들기 때문이다.
///
/// ⚠️ **보고서의 「seg042 가 CloudShell 을 범위 내로 말한다」는 과대다** — 그 세그먼트는
/// 「범주만 매칭해서 알아 두면 되는 것들」로 CloudShell 을 들 뿐 **「범위 내」라고 말하지
/// 않는다**(발화 본문 실측). 그래서 seg042 는 손대지 않았다.
///
/// ## 건별 공식 근거
///
/// - **P2-E** `aws-support-plans.html`·`trusted-advisor.html` 이 셋만 든다 —
///   `AWS Trusted Advisor checks are available to customers with an **AWS Business
///   Support+, AWS Enterprise Support, or AWS Unified Operations** plan.` 그리고
///   `Developer Support will be discontinued **January 1, 2027**` ·
///   `Developer Support, Business Support, and Enterprise On-Ramp will remain
///   available in the **AWS GovCloud (US) Region**.`
///   ⭐ Basic 의 범위도 정확히 적혀 있다 — `all checks in the **Service Limits**
///   category and **selected checks in the Security and Fault tolerance** categories`
///   (레포의 「핵심(core) 점검만」은 그 축약이라 정밀화했다).
/// - **P2-F** `what-is-kendra.html` 배너 — `Amazon Kendra will no longer be open to
///   new customers starting on **July 30, 2026**. … explore **Amazon Bedrock
///   Knowledge Bases**.` 즉 **이미 지났다.**
/// - **P2-G** 공식 범위 내 목록의 「개발자 도구」는 `AWS CLI · AWS CodeBuild ·
///   AWS CodePipeline · AWS X-Ray` **넷뿐**이고, 「프런트엔드 웹 및 모바일」은
///   `AWS Amplify` **하나**, 「고객 지원」은 `AWS Support` **하나**다.
///   ⚠️ **보고서는 7종을 적었지만 `CodeCommit` 이 빠져 있다** — 그것도 범위 내 목록에
///   없다(다만 **범위 외 목록에도 없다**: `CodeCommit`·`Cloud9`·`AppSync` 셋은 어느
///   목록에도 없으므로 「범위 외」로 단정하지 않고 **「어느 목록에도 없다」**로 적는다.
///   두 목록 모두 스스로 `non-exhaustive` 라고 밝힌다).
/// - **P2-H 보고서를 기각했다.** 「`500+ 점검` 의 근거를 찾지 못했다」고 했지만
///   인용 페이지 `aws-support-plans.html` 의 Business Support+ 절이
///   **`More than 500 checks with AWS Trusted Advisor.`** 를 그대로 싣는다(실측).
///   지울 것이 아니라 **출처 제목의 플랜 이름이 낡은 것**이 결함이다.
void main() {
  const clf = 'assets/content/clf';

  List<Map<String, dynamic>> questionsOf(String task) =>
      ((json.decode(File('$clf/$task.questions.json').readAsStringSync())
                  as Map<String, dynamic>)['questions'] as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> question(String task, String qid) => questionsOf(task)
      .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  String doc(String task) => File('$clf/$task.md').readAsStringSync();

  String blob(Map<String, dynamic> q) => json.encode(q);

  /// 대본의 **발화 본문**만 모은다 — `gen_lecture_audio.py` 의 `_spoken_body` 와 같은
  /// 우선순위(`kind == 'table'` 이면 `audioSummary`, 그 외는 `enrichedScriptText`
  /// → `scriptText`). `sourceExcerpt` 는 발화되지 않으므로 세지 않는다.
  String spokenBody(Map<String, dynamic> seg) {
    if (seg['kind'] == 'table') return (seg['audioSummary'] as String?) ?? '';
    return (seg['enrichedScriptText'] as String?) ??
        (seg['scriptText'] as String?) ??
        '';
  }

  Map<String, dynamic> script(String docId) =>
      json.decode(File('assets/audio/clf/$docId/script.json').readAsStringSync())
          as Map<String, dynamic>;

  // ═════════════════════ 대조군 ═════════════════════

  test('대조군: CLF 콘텐츠와 대본을 실제로 읽고 있다', () {
    final mds = Directory(clf)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .length;
    expect(mds, greaterThanOrEqualTo(19), reason: 'CLF 학습문서는 19편이다');
    final scripts = Directory('assets/audio/clf')
        .listSync()
        .whereType<Directory>()
        .length;
    expect(scripts, greaterThanOrEqualTo(19));
  });

  // ═════════════════════ P2-E 지원 플랜 ═════════════════════

  group('P2-E 단종 예정 플랜 — 현행 명칭 병기와 단종일', () {
    test('clf-t4-3-q6: 정답 불변 + 단종 안내가 붙었다', () {
      final q = question('t4-3', 'clf-t4-3-q6');
      expect(q['correct'], 0, reason: '전통 분류 기출 대비로 Developer Support 가 정답이다');
      final e = q['explanation'] as String;
      expect(e.contains('2027-01-01'), isTrue,
          reason: '단종 예정 플랜을 정답으로 고르게 하면서 상태를 안 적으면 안 된다');
      expect(e.contains('Business Support+'), isTrue,
          reason: '현행 최저 유료 플랜을 함께 적어야 학습자가 현실과 잇는다');
    });

    test('clf-t4-3-q7: 정답 불변 + Basic 범위가 공식대로 정밀해졌다', () {
      final q = question('t4-3', 'clf-t4-3-q7');
      expect(q['correct'], 0);
      final e = q['explanation'] as String;
      expect(e.contains('서비스 할당량'), isTrue,
          reason: '공식: "all checks in the Service Limits category"');
      expect(e.contains('Unified Operations'), isTrue,
          reason: '공식 현행은 Business Support+·Enterprise·Unified Operations 셋이다');
    });

    test('clf-t4-3-q10: 정답 불변 + 현행 세 플랜 병기', () {
      final q = question('t4-3', 'clf-t4-3-q10');
      expect(q['correct'], 2);
      final e = q['explanation'] as String;
      expect(e.contains('Business Support+'), isTrue);
      expect(e.contains('Unified Operations'), isTrue);
      expect(e.contains('2027-01-01'), isTrue);
    });

    test('CLF 전수: 단종 예정 플랜을 적는 문항은 상태를 함께 적는다', () {
      // ⚠️ 문맥 규칙 — 한 자리만 막으면 같은 누락이 옆 문항에 남는다.
      // 「Developer Support」·「Enterprise On-Ramp」를 **본문에서** 드는 문항은
      // 그 문항 어디에든 단종일이나 현행 명칭이 있어야 한다.
      final offenders = <String>[];
      for (final f in Directory(clf)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path))) {
        final task = f.path
            .replaceAll(r'\', '/')
            .split('/')
            .last
            .replaceAll('.questions.json', '');
        for (final q in questionsOf(task)) {
          final t = blob(q);
          if (!t.contains('Developer Support') &&
              !t.contains('Enterprise On-Ramp')) {
            continue;
          }
          if (!t.contains('2027-01-01') && !t.contains('Business Support+')) {
            offenders.add(q['id'] as String);
          }
        }
      }
      expect(offenders, isEmpty,
          reason: '공식이 2027-01-01 단종을 명시한다(GovCloud(US)는 계속 제공): '
              '${offenders.join(', ')}');
    });

    test('대조군: 단종 예정 플랜을 적는 문항이 실제로 여럿이다', () {
      final mentions = questionsOf('t4-3')
          .where((q) => blob(q).contains('Developer Support'))
          .map((q) => q['id'])
          .toList();
      expect(mentions.length, greaterThanOrEqualTo(4),
          reason: '0~1건이면 위 전수 단정이 공허하다');
    });
  });

  // ═════════════════════ P2-F 닫힌 서비스 정직성 메모 ═════════════════════

  group('P2-F 신규 고객에게 닫힌 서비스에 정직성 메모가 있다', () {
    test('t3-7.md 에 Kendra 정직성 메모가 있다', () {
      final t = doc('t3-7');
      expect(t.contains('Kendra'), isTrue, reason: '대조군 — 언급 자체는 남는다');
      // 레포 관례: `ℹ️ 정직성 메모:` 한 줄(Forecast·SageMaker·QuickSight 선례).
      final memo = t
          .split('\n')
          .where((l) => l.contains('정직성 메모') && l.contains('Kendra'))
          .toList();
      expect(memo, hasLength(1),
          reason: '같은 문서가 Forecast 에는 메모를 달고 Kendra 에는 안 달아 '
              '비대칭이었다(2026-07 감사의 「단종 메모 비일관」과 같은 패턴)');
      expect(memo.first.contains('2026-07-30'), isTrue,
          reason: '공식: "starting on July 30, 2026" — 이미 지났다');
      expect(memo.first.contains('Bedrock Knowledge Bases'), isTrue,
          reason: '공식 배너가 유사 기능으로 그것을 지목한다');
    });

    test('clf-t3-7-q3: 정답 불변 + 해설에 상태 메모', () {
      final q = question('t3-7', 'clf-t3-7-q3');
      expect(q['correct'], 0, reason: 'Kendra 가 정답인 것은 그대로다');
      final e = q['explanation'] as String;
      expect(e.contains('2026-07-30'), isTrue,
          reason: '학습자는 오답노트·모의고사 화면에서 md 메모를 보지 못한다');
    });

    test('clf-t2-2-q10: 정답 불변 + 해설에 상태 메모', () {
      final q = question('t2-2', 'clf-t2-2-q10');
      expect(q['correct'], 2, reason: 'Audit Manager 가 정답인 것은 그대로다');
      final e = q['explanation'] as String;
      expect(e.contains('2026-04-30'), isTrue,
          reason: 'md 에는 메모가 있는데 문항에는 없던 비대칭을 닫는다');
    });

    test('CLF 전수: 닫힌 서비스가 정답인 문항은 상태를 적는다', () {
      const closed = <String, List<String>>{
        'Amazon Kendra': ['2026-07-30'],
        'AWS Audit Manager': ['2026-04-30'],
        'Amazon Forecast': ['신규 고객'],
      };
      final offenders = <String>[];
      for (final f in Directory(clf)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path))) {
        final task = f.path
            .replaceAll(r'\', '/')
            .split('/')
            .last
            .replaceAll('.questions.json', '');
        for (final q in questionsOf(task)) {
          final correct = (q['options'] as List).cast<String>()[q['correct'] as int];
          closed.forEach((name, markers) {
            if (!correct.contains(name)) return;
            final t = blob(q);
            if (!markers.any(t.contains)) offenders.add('${q['id']} ← $name');
          });
        }
      }
      expect(offenders, isEmpty,
          reason: '정답이 닫힌 서비스면 그 상태를 해설에 적는 것이 이 레포의 관례다: '
              '${offenders.join(', ')}');
    });
  });

  // ═════════════════════ P2-G t3-8 범위 내 표 ═════════════════════

  group('P2-G t3-8 의 「범위 내」 표가 공식 목록과 같다', () {
    test('표에 공식 범위 내 서비스만 남았다', () {
      final t = doc('t3-8');
      // 절 제목은 공식 Task 3.8 제목을 따르므로 **내용을 좁히는 쪽**이 맞다.
      expect(t.contains('그 외 범위 내 서비스'), isTrue);
      final table = t
          .split('\n')
          .where((l) => l.startsWith('| **개발자 도구**') ||
              l.startsWith('| **프런트엔드') ||
              l.startsWith('| **고객 지원'))
          .join('\n');
      expect(table, isNotEmpty, reason: '대조군 — 세 행을 실제로 집었다');
      for (final inScope in ['CodeBuild', 'CodePipeline', 'X-Ray', 'Amplify', 'AWS Support']) {
        expect(table, contains(inScope), reason: '$inScope 는 공식 범위 내다');
      }
      for (final notInScope in [
        'CloudShell',
        'Cloud9',
        'CodeCommit',
        'CodeDeploy',
        'AWS IQ',
        'Managed Services',
        'Activate',
        'AppSync',
      ]) {
        expect(table.contains(notInScope), isFalse,
            reason: '$notInScope 는 공식 범위 내 목록에 없다 — 표 세 행에서 빠져야 한다');
      }
    });

    test('빠진 이름을 「범위 외·미기재」로 따로 가르친다', () {
      final t = doc('t3-8');
      // 지우고 끝내면 학습자가 보기에서 그 이름을 만났을 때 판단 근거가 없다.
      expect(t.contains('범위 외'), isTrue);
      for (final name in ['CloudShell', 'CodeDeploy', 'AWS IQ', 'Activate']) {
        expect(t, contains(name), reason: '$name 은 범위 외로 가르쳐야 한다');
      }
      // ⚠️ 어느 목록에도 없는 셋은 「범위 외」로 단정하지 않는다.
      expect(t.contains('어느 목록에도 없'), isTrue,
          reason: 'Cloud9·AppSync·CodeCommit 은 범위 내·외 목록 어디에도 없고 '
              '두 목록 모두 non-exhaustive 라고 밝힌다');
    });

    test('clf-t3-8 대본 seg034 가 범위 외 서비스를 읽지 않는다', () {
      final s = script('clf-t3-8');
      final segs = (s['segments'] as List).cast<Map<String, dynamic>>();
      final seg034 =
          segs.firstWhere((e) => e['id'] == 'seg034', orElse: () => fail('seg034 없음'));
      final body = spokenBody(seg034);
      expect(body, isNotEmpty, reason: '대조군 — 발화 본문을 실제로 집었다');
      for (final notInScope in [
        'CloudShell',
        'Cloud9',
        'CodeCommit',
        'CodeDeploy',
        '아이큐',
        'Managed Services',
        'Activate',
        'AppSync',
      ]) {
        expect(body.contains(notInScope), isFalse,
            reason: '승인된 라이브 음성이 범위 외 서비스를 범위 내로 가르치고 있었다: '
                '$notInScope');
      }
    });

    test('재합성 대기 — 사람의 청취 재승인이 필요하다', () {
      // ⚠️ `reviewStatus: approved` 는 사람의 청취 서명이다. 대본을 바꿨으므로
      // 되돌렸고, `content_index.dart` 의 `audioApproved`·`audioSha8` 동기화는
      // `content_index_test.dart` 가 양방향으로 지킨다.
      final meta = json.decode(
              File('assets/audio/clf/clf-t3-8/audio_meta.json').readAsStringSync())
          as Map<String, dynamic>;
      expect(meta['reviewStatus'], 'needs_human_review',
          reason: 'AI 가 approved 를 쓰지 않는다 — 청취는 사람 몫이다');
    });

    test('대조군: 손대지 않은 세그먼트는 그대로다', () {
      // 보고서가 「CloudShell 을 범위 내로 말한다」고 적은 seg042 는 실제로는
      // 「범주만 매칭해서 알아 두면 되는 것들」이라 거짓이 아니다 — 손대지 않았다.
      final segs = (script('clf-t3-8')['segments'] as List)
          .cast<Map<String, dynamic>>();
      final seg042 =
          segs.firstWhere((e) => e['id'] == 'seg042', orElse: () => fail('없음'));
      final body = spokenBody(seg042);
      expect(body.contains('클라우드셸'), isTrue,
          reason: '보고서 과대 판정을 따라 지웠다면 멀쩡한 발화를 바꿨다');
      expect(body.contains('범위 내'), isFalse,
          reason: '이 세그먼트는 「범위 내」라고 말하지 않는다 — 그래서 대상이 아니다');
    });
  });

  // ═════════════════════ P2-H 500+ 점검 ═════════════════════

  group('P2-H 「500+ 점검」은 인용 페이지에 실재한다 — 보고서 기각', () {
    test('clf-t4-3-q2: 정답 불변 + 500+ 유지 + 플랜 이름 현행화', () {
      final q = question('t4-3', 'clf-t4-3-q2');
      expect(q['correct'], 0);
      final title =
          ((q['sources'] as List).first as Map)['title'] as String;
      expect(title.contains('500+ 점검'), isTrue,
          reason: '공식 `aws-support-plans.html` 이 "More than 500 checks with '
              'AWS Trusted Advisor." 를 그대로 싣는다 — 지우면 참인 수치를 잃는다');
      expect(title.contains('Business Support+'), isTrue,
          reason: '그 페이지는 500+ 를 **Business Support+** 절에 적는다 — '
              '「Business 이상」은 낡은 플랜 이름이다');
      expect(title.contains('Business 이상'), isFalse);
    });

    test('대조군: 출처 URL 이 그대로다', () {
      final q = question('t4-3', 'clf-t4-3-q2');
      final url = ((q['sources'] as List).first as Map)['url'] as String;
      expect(url,
          'https://docs.aws.amazon.com/awssupport/latest/user/aws-support-plans.html',
          reason: '인용 페이지가 사실을 담고 있으므로 출처를 바꿀 이유가 없다');
    });
  });
}
