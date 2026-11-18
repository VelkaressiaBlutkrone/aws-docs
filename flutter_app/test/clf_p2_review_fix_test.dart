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

    test('두 reviewStatus 가 같은 값으로 움직인다 (반쪽 flip 금지)', () {
      // ⚠️⚠️ **이 단정은 2026-11-17 에 뒤집혔다.** 원래 `'needs_human_review'` 를
      // 리터럴로 박아 「AI 가 approved 를 쓰지 않는다」를 지키려 했는데, 그것은
      // **과정 규칙이고 파일로 검사할 수 없다.** 사람이 실제로 청취·승인하자
      // 그 단정이 레드로 끝났다 — 문항 `verified` flip·승인 편수와 **같은 함정**이다
      // (`content_index_audio_test.dart` 의 규율: 상태 숫자·상태 값을 박지 않는다).
      //
      // 승인 전·후 모두 녹색이면서 의미가 남는 불변식으로 바꿨다: **top 과 script 의
      // `reviewStatus` 가 같은 값이고 허용된 두 값 중 하나다.** 반쪽만 올리면
      // `publish_audio.py` 의 `find_approved()`(둘 다 approved 를 요구)와
      // `content_index_test` 의 동기화 단정이 어긋나므로 그것이 진짜 결함이다.
      // 승인 ↔ `audioApproved`·`audioSha8` 정합은 `content_index_test.dart` 가
      // 양방향으로 지킨다.
      final meta = json.decode(
              File('assets/audio/clf/clf-t3-8/audio_meta.json').readAsStringSync())
          as Map<String, dynamic>;
      final top = meta['reviewStatus'];
      final scriptStatus = (meta['script'] as Map<String, dynamic>)['reviewStatus'];
      expect(top, anyOf('needs_human_review', 'approved'),
          reason: '스키마에 없는 reviewStatus');
      expect(scriptStatus, top,
          reason: 'top 과 script 의 reviewStatus 가 갈렸다 — 반쪽 flip 은 발행 게이트와 '
              'content_index 동기화를 동시에 어긋나게 한다');
    });

    test('seg042 가 CloudShell 을 범위 외로 말한다 (2026-11-18 사용자 지시)', () {
      // ⚠️⚠️⚠️ **이 자리의 판정이 두 번 바뀌었다 — 그 경위가 이 주석의 요점이다.**
      // ① 2026-11-06: 보고서가 「seg042 가 CloudShell 을 범위 내로 말한다」고 적었지만
      //    실측하면 **「범위 내」라고 말하지 않아** 과대 판정이었다 → 손대지 않았다.
      // ② 2026-11-17: 2단계가 C-Y10 으로 `t3-8.md` 에서 CloudShell 을 「공식 「범위 외」
      //    목록에 있다」로 고쳤는데 **그 보고서의 「발화 판정」 절은 `clf-t4-3` 만 읽어**
      //    이 편의 발화는 범위 밖이었다. 실측하면 seg042 는 CloudShell 을 「범주만
      //    매칭해서 알아 두시면 되는 것들」에 넣고 같은 음성 seg034 는 「이 표에는 공식
      //    범위 내 목록에 있는 이름만 남겼습니다」라고 말해 **거짓은 아니지만 음성
      //    내부에서 어긋났다.** 「재합성 범위는 거짓인 곳」 판정에 따라 기록만 했다.
      // ③ 2026-11-18: **사용자가 「고쳐」로 지시해** seg042 를 md 구조대로 고치고
      //    재합성했다 — CloudShell 을 목록에서 빼고 **공식 범위 외 목록에 있다**고
      //    말하게 했다(seg034 의 어투에 맞춰 괄호 없이). 사용자 지시가 ②의 판정보다
      //    앞서므로 **가드를 먼저 뒤집고** 콘텐츠를 고쳤다.
      //
      // ⚠️ **`클라우드셸` 자체는 지우지 않았다** — 이름을 말하면서 범위 외임을 알려야
      // 보기에서 만났을 때 가를 수 있다(md 의 범위 메모와 같은 처리다). 그래서 이
      // 가드는 ①의 「지우지 않았다」와 ③의 「범위 외를 적는다」를 **함께** 지킨다.
      //
      // ⚠️ **`sourceExcerpt`·`sourceHash` 는 손대지 않았다** — clf-t4-3 과 달리 이 대본은
      // 현재 md 와 **블록 수가 다르다**(대본 60 seg ↔ `generate` 61 seg). `cf0e0a3` 이
      // md 에 더한 범위 외 콜아웃이 새 `seg036` 이 되어 그 뒤가 한 칸씩 밀리므로 id 로
      // 이식할 수 없고, 번호를 다시 매기는 것은 `test/` 가 세그먼트 id 를 참조해 불가다.
      // 해시를 올리면 「이 대본이 현재 md 에서 왔다」가 **거짓 선언**이 된다.
      final segs = (script('clf-t3-8')['segments'] as List)
          .cast<Map<String, dynamic>>();
      final seg042 =
          segs.firstWhere((e) => e['id'] == 'seg042', orElse: () => fail('없음'));
      final body = spokenBody(seg042);
      expect(body.contains('클라우드셸'), isTrue,
          reason: '이름을 지우면 보기에서 만났을 때 가를 수 없다 (①의 판정)');
      expect(body.contains('범위 외'), isTrue,
          reason: '③ 사용자 지시 — CloudShell 이 범위 외임을 말해야 한다');
      expect(body.contains('범위 내'), isFalse,
          reason: '이 세그먼트는 CloudShell 을 「범위 내」로 말하지 않는다');

      // 2026-11-06 §P2-G 수정이 음성에 남아 있다(seg034 가 표를 공식 목록으로 한정).
      final seg034 =
          segs.firstWhere((e) => e['id'] == 'seg034', orElse: () => fail('없음'));
      expect(spokenBody(seg034).contains('공식 범위 내 목록에 있는 이름만'), isTrue,
          reason: '§P2-G 가 고친 한정 문장이 사라졌다');

      // md 의 범위 외 콜아웃은 어느 세그먼트의 sourceExcerpt 에도 없다 — 위 주석의
      // 「md 에 블록을 더해도 대본에 자동으로 생기지 않는다」를 기계로 고정한다.
      final md = File('assets/content/clf/t3-8.md').readAsStringSync();
      expect(md.contains('보기에 나오면'), isTrue,
          reason: '대조군 — md 쪽 콜아웃이 실재해야 아래 0건이 의미를 갖는다');
      expect(
          segs.where((e) => ((e['sourceExcerpt'] as String?) ?? '')
              .contains('보기에 나오면')),
          isEmpty,
          reason: 'md 콜아웃이 대본 세그먼트로 들어왔다 — 그렇다면 발화도 다시 본다');
    });

    test('범위 외 이름의 첫 언급 세그먼트가 범위 메모를 단다', () {
      // ⚠️⚠️ **seg042 를 고치다 같은 결함이 라이브 음성 세 편에 더 있는 것을 찾았다.**
      // 2026-11-06 2단 검토 **C-Y9** 가 `t3-1`(CodeDeploy)·`t3-2`(Wavelength)·
      // `t3-7`(Personalize) **md** 에 범위 메모를 달았지만 **음성에는 어느 편에도
      // 전파되지 않았다** — 「md 를 고치면 발화에 전파되지 않는다」가 네 번째로 확인된
      // 자리다. 2026-11-18 **사용자 지시로 세 편을 고치고 재합성했다.**
      //
      // ⚠️⚠️ **메모는 문서당 한 자리다 — 13곳에 다 달지 않았다.** md 자신이
      // CodeDeploy 를 **8회** · Wavelength 를 **10회** · Personalize 를 **14회**
      // 적으면서 범위 메모는 **표 바로 뒤 한 번**만 단다(t3-2·t3-7 은 학습 목표
      // 체크박스에 짧은 괄호 표기가 하나 더 있다). 음성은 **선형**이라 그 편을 듣는 사람은
      // 뒤의 언급 전에 이미 메모를 들었고, 13곳에 다 달면 한 편에서 같은 메모를
      // 다섯 번 읽으며 **md 보다 더 말하게** 된다(문항은 각각 독립이라 반대로
      // **문항마다** 단다 — 2026-11-06 AIF Model Monitor·MLA Clarify 배치).
      //
      // ⚠️ 그래서 단정이 「언급마다」가 아니라 **「각 이름의 첫 언급 세그먼트」**다.
      // 개수를 박지 않으므로 뒤쪽 언급이 늘어도 깨지지 않고, 메모를 뒤로 옮기거나
      // 메모 없는 **더 앞선** 언급이 생기면 깨진다(앞을 듣는 사람에게는 메모가 없다).
      const names = <String, String>{
        '클라우드셸': 'CloudShell',
        '코드디플로이': 'CodeDeploy',
        '웨이브렝스': 'Wavelength',
        '퍼스널라이즈': 'Personalize',
      };
      final pairs = <String>[];
      final violations = <String>[];
      for (final dir in Directory('assets/audio/clf').listSync().whereType<Directory>()) {
        final f = File('${dir.path}/script.json');
        if (!f.existsSync()) continue;
        final doc = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
        final segs = (doc['segments'] as List).cast<Map<String, dynamic>>();
        for (final entry in names.entries) {
          final i = segs.indexWhere((s) => spokenBody(s).contains(entry.key));
          if (i < 0) continue;
          pairs.add('${doc['docId']} ${entry.value} ${segs[i]['id']}');
          if (!spokenBody(segs[i]).contains('범위 외')) {
            violations.add('${doc['docId']} ${segs[i]['id']} (${entry.value})');
          }
        }
      }
      expect(pairs.length, greaterThanOrEqualTo(4),
          reason: '대조군 — 탐지기가 음차 이름을 실제로 찾는다. 현재 네 자리: '
              'clf-t3-1 CodeDeploy · clf-t3-2 Wavelength · clf-t3-7 Personalize · '
              'clf-t3-8 CloudShell');
      expect(violations, isEmpty,
          reason: '범위 외 서비스를 **처음** 말하는 발화가 범위 메모 없이 지나간다:\n'
              '${violations.join('\n')}');
    });

    test('범위 메모가 공식 목록 근거와 남는 축을 함께 말한다', () {
      // ⚠️ 「범위 외」 한 마디로 쪼그라들면 학습자가 **그럼 무엇을 공부하나**를 모른다.
      // md 의 메모는 근거(공식 목록)와 **비중을 둘 곳**을 함께 적으므로 발화도 그렇게
      // 적는다. 검사 범위를 「범위 외」가 든 세그먼트로 좁혀 문구가 메모 자신에게
      // 붙어 있는지 본다(편 전체를 보면 다른 자리의 같은 낱말이 통과시킨다).
      const required = <String, List<String>>{
        'clf-t3-1': ['공식 범위 외 서비스 목록', '파이프라인의 배포 단계'],
        'clf-t3-2': ['공식 범위 외 서비스 목록', '아웃포스트에 두'],
        'clf-t3-7': ['공식 범위 외 서비스 목록', '구분 구조'],
        'clf-t3-8': ['공식 범위 외 서비스 목록'],
      };
      var checked = 0;
      required.forEach((docId, phrases) {
        final segs =
            (script(docId)['segments'] as List).cast<Map<String, dynamic>>();
        expect(segs.length, greaterThan(20), reason: '대조군 — $docId 를 집었다');
        final memo =
            segs.map(spokenBody).where((t) => t.contains('범위 외')).join('\n');
        for (final p in phrases) {
          expect(memo.contains(p), isTrue,
              reason: '$docId 의 범위 메모에서 「$p」가 사라졌다');
        }
        checked++;
      });
      expect(checked, 4);
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
