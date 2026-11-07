import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토의 **CLF 우선순위 3(P3) 계열** 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/clf-c02-dva-c03.md`
/// §4의 `P3-1`(파서가 렌더하지 않는 단일 이탤릭) · `P3-2`(프리 티어가 학습문서
/// 0편) · `P3-4②`(Snowball 비중 메모) · `P3-5`(`q2`↔`q12` 중복) ·
/// `P3-7`(Aurora 처리량 배수).
///
/// `P3-3`·`P3-4①`·`P3-6`·`P3-8`은 그 뒤의 P1·P2 배치가 이미 닫았다(2026-11-07
/// 실측 — 잔여 대장은 HANDOFF §0-2026-11-07-c).
///
/// 공식 재측정은 컨트롤러가 직접 했다. **CLF 301문항은 전부 라이브**다.
///
/// ## ⚠️⚠️ 공식 주 가이드가 「6배」로 적는다 — 보고서보다 한 걸음 더 들어갔다
///
/// 보고서 `P3-7`은 「공식이 갈리니 해설에 6배 한 줄을 더하라」로 적었다. 그런데
/// 실측하면 **Aurora 사용 설명서의 첫 페이지**, 그리고 **문항이 이미 출처로 달고
/// 있던 바로 그 페이지**(`CHAP_AuroraOverview.html`)가
/// `Aurora delivers up to 6x the throughput of stock PostgreSQL and up to 6x the
/// throughput of stock MySQL on similar hardware.` 로 적는다. 즉 **인용 페이지에
/// 「5배/3배」가 없다** — 이 레포가 반복해 밟은 「URL은 200인데 그 페이지에 인용
/// 사실이 없다」 결함이다. 5배/3배는 **GovCloud(US) 안내서**에만 남아 있고
/// (`up to five times the throughput of MySQL and up to three times the throughput
/// of PostgreSQL`), 리전 부록보다 **주 가이드가 정본**이다. 그래서 6배를 앞세우고
/// 5배/3배를 **공식 표현의 갈림**으로 함께 가르친다(`auroraextendedcontent`가
/// `Testing on standard benchmarks such as SysBench` 로 6배의 근거를 적는다).
///
/// ⚠️ **5배/3배는 거짓이 아니므로 금지하지 않는다.** 가드는 **「5배/3배를 적는
/// 파일은 6배도 적는다」**는 집계형이다 — 갈림을 가르치지 않는 쪽만 막는다.
///
/// ⚠️ **오디오는 재합성하지 않는다.** `clf-t3-4` 대본 `seg020`이 「최대 5배,
/// PostgreSQL의 최대 3배」를 말하는데 그것은 **GovCloud 페이지의 공식 문구를
/// 인용한 참인 문장**이다. 2026-11-06 CLF P2 배치의 사용자 판정대로 **재합성
/// 범위는 「거짓인 곳」**이고, 여기서는 md가 더 완전해지는 것뿐이다.
///
/// ## 비자명한 공식 사실 (직접 인용)
///
/// ⚠️ **AWS 생성 태그는 소급 적용되지 않는다** — `aws-tags.html` 이
/// `After the tag is activated, AWS starts applying the tag to resources that are
/// created after the AWS-generated tag is activated.` 로 적고, 키는
/// `aws:createdBy` 이며 `available only in the Billing and Cost Management console
/// and reports, and doesn't appear anywhere else in the AWS console, including the
/// AWS Tag Editor` 다. 관리 계정이 활성화하면 **모든 멤버 계정에도** 활성화되고
/// **리소스당 태그 쿼터에 들지 않는다.** 그리고 CUR 쪽에서 사용자 정의 태그는
/// `resourceTags/user:<키>` 열로 나타난다(`resource-tags-columns.html`) — 공식
/// Task 4.2 기술의 「태그와 결제 보고서 간 관계」가 바로 이 자리다.
///
/// ⚠️ **프리 티어는 「계정 플랜 + 크레딧」 구조다** — `free-tier.html` 이
/// 가입 시 `Free account plan` / `Paid account plan` 선택, 신규 계정 `USD $100`
/// 크레딧(활동으로 최대 $100 추가), `over 30 always free AWS services`, Free
/// plan은 `ends after six months or when your credits are fully used - whichever
/// occurs first`, 오퍼는 `Always Free` 와 `Short-term trials` 둘이고 **Free
/// account plan은 Always Free만 활성**이라고 적는다. ⚠️ **개편 날짜와 「레거시
/// 12개월 무료」는 쓰지 않는다** — 그 서술의 근거는 `repost.aws` 뿐이고 공식
/// 사용 설명서에는 없다(2026-11-06 CLF 죽은 URL 배치가 같은 판정을 했다).
///
/// ⚠️ **공식 가이드 작업 1.3의 예시에서 Snowball이 빠졌다** — 현재 기술은
/// 「전략적 마이그레이션 사례 파악(예: **데이터베이스 복제**)」뿐이고, 「범위 내
/// AWS 서비스」의 「마이그레이션 및 전송」에도 Snow 계열이 없다. ⚠️ 다만
/// **「범위 외」 목록에도 없으므로 범위 밖으로 단정하지 않는다**(두 목록 모두
/// 스스로 non-exhaustive라고 밝힌다).
///
/// ## 비자명한 규율
///
/// ⚠️ **보고서가 과대였던 자리.** `P3-7`의 집계는 「`최대 5배`: clf md 1 · q 3 ·
/// 발화 1 / **saa md 1 · q 1 · 발화 1**」인데, SAA 쪽 `5배`·`3배`는 **Aurora와
/// 무관**하다(Kinesis 샤드 「5배 과대 추정」 · 「읽기 트래픽이 5배 급증」 ·
/// Lambda 폴러 「약 3배 빠른 스케일링」). **문맥을 섞은 집계**이므로 이 배치의
/// 범위는 CLF뿐이다 — 전수 가드가 그것을 고정한다.
///
/// ⚠️ **문항 해설은 평문 `Text` 위젯으로 렌더된다**
/// (`lib/content/quiz_widgets.dart` 의 `Text(q.explanation, …)`) — 그래서 단일
/// `*이탤릭*` 은 학습자에게 **별표가 글자 그대로** 보인다. 레포 전역에 이 한 건만
/// 남아 있었으므로, 고치는 김에 `content_format_test.dart` 의 이탤릭 불변식을
/// **`.questions.json` 까지** 확장했다(그 전역 단정은 그 파일에 있고 여기서
/// 중복하지 않는다).
void main() {
  const content = 'assets/content';

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

  String answer(Map<String, dynamic> q) =>
      (q['options'] as List).cast<String>()[q['correct'] as int];

  List<String> urls(Map<String, dynamic> q) => (q['sources'] as List)
      .cast<Map<String, dynamic>>()
      .map((s) => s['url'] as String)
      .toList();

  /// 파서가 렌더하지 않는 단일 `*이탤릭*` 탐지기 — `**굵게**` 는 걸리지 않아야
  /// 한다. 탐지기 본체를 함수로 빼서 양방향 대조군을 붙인다.
  bool hasBareItalic(String text) =>
      RegExp(r'(?<!\*)\*(?!\*)[^*\n]+\*(?!\*)').hasMatch(text);

  // ═════════════════════ 대조군 ═════════════════════

  test('대조군: 손댄 네 문항이 읽히고 구조가 성립한다', () {
    for (final q in <Map<String, dynamic>>[
      question('clf', 't2-3', 'clf-t2-3-q1'),
      question('clf', 't4-2', 'clf-t4-2-q2'),
      question('clf', 't4-2', 'clf-t4-2-q12'),
      question('clf', 't3-4', 'clf-t3-4-q2'),
    ]) {
      expect((q['options'] as List).length, 4);
      expect(blob(q).length, greaterThan(400));
      expect(q['verified'], true, reason: 'CLF 301문항은 전부 라이브다');
    }
  });

  test('§P3: 정답 인덱스·section·difficulty 가 불변이다', () {
    // ⚠️ 이 값은 **추측하지 않고 실측했다** — 처음 0 으로 썼다가 이 단정이
    // 잡았다(보고서는 정답 인덱스를 적지 않는다).
    expect(question('clf', 't2-3', 'clf-t2-3-q1')['correct'], 2);
    expect(question('clf', 't3-4', 'clf-t3-4-q2')['correct'], 0);
    final q12 = question('clf', 't4-2', 'clf-t4-2-q12');
    expect(q12['correct'], 0, reason: '교체 문항의 정답은 같은 자리에 둔다');
    expect(q12['section'], 'cost-tools');
    expect(q12['difficulty'], 'foundational');
  });

  // ═══════════════ P3-1 — 평문 렌더에 새던 단일 이탤릭 ═══════════════

  group('§P3-1 문항 해설의 단일 이탤릭', () {
    test('clf-t2-3-q1 해설에서 별표가 사라졌다', () {
      final q = question('clf', 't2-3', 'clf-t2-3-q1');
      final expl = q['explanation'] as String;
      expect(hasBareItalic(expl), isFalse);
      expect(expl.contains('계정 자체에'), isTrue, reason: '문장은 남는다');
    });

    test('대조군: 탐지기가 옛 문구를 잡고 굵게는 통과한다', () {
      expect(hasBareItalic('계정 *자체*에 대한 것이거나'), isTrue);
      expect(hasBareItalic('**굵게**는 파서가 읽는다'), isFalse,
          reason: '굵게를 걸면 전역 확장이 불가능해진다');
    });
  });

  // ═══════════════ P3-5 — q2 ↔ q12 중복 해소 ═══════════════

  group('§P3-5 clf-t4-2-q2 ↔ q12 가 다른 사실을 묻는다', () {
    test('q12 가 더 이상 Cost Explorer 예측을 묻지 않는다', () {
      final q12 = question('clf', 't4-2', 'clf-t4-2-q12');
      expect((q12['stem'] as String).contains('예측'), isFalse);
      expect(answer(q12).contains('AWS Cost Explorer'), isFalse);
    });

    test('q2 는 그대로 Cost Explorer 다 (대조군)', () {
      final q2 = question('clf', 't4-2', 'clf-t4-2-q2');
      expect(answer(q2), 'AWS Cost Explorer');
      expect((q2['stem'] as String).contains('예측'), isTrue);
    });

    test('q12 의 새 소재는 AWS 생성 태그이고 공식 사실을 적는다', () {
      final q12 = question('clf', 't4-2', 'clf-t4-2-q12');
      final b = blob(q12);
      expect(b.contains('aws:createdBy'), isTrue);
      expect(answer(q12).contains('이후'), isTrue, reason: '소급 적용되지 않는다');
      expect(b.contains('Tag Editor'), isTrue);
      expect(b.contains('resourceTags/user:'), isTrue,
          reason: '공식 Task 4.2 기술의 「태그와 결제 보고서 간 관계」');
      expect(urls(q12).any((u) => u.contains('aws-tags.html')), isTrue);
      expect(
        urls(q12).any((u) => u.contains('resource-tags-columns.html')),
        isTrue,
      );
    });
  });

  // ═══════════════ P3-2 — 프리 티어가 학습문서 0편 ═══════════════

  group('§P3-2 프리 티어가 학습문서에 들어왔다', () {
    test('t4-1.md 가 free-tier 절과 공식 사실을 적는다', () {
      final md = doc('clf', 't4-1');
      expect(md.contains('{#free-tier}'), isTrue);
      for (final required in <String>[
        'Free account plan',
        'Paid account plan',
        'Always Free',
        'Short-term',
        '6개월',
      ]) {
        expect(md.contains(required), isTrue, reason: '빠진 문구: $required');
      }
    });

    test('범위 메모가 함께 붙는다', () {
      final md = doc('clf', 't4-1');
      final line = md.split('\n').firstWhere(
            (l) => l.contains('프리 티어') && l.contains('기술'),
            orElse: () => fail('범위 메모가 없다'),
          );
      expect(line.contains('없습니다'), isTrue,
          reason: '공식 작업 4.1·4.2 지식·기술 목록에 프리 티어가 없다');
    });

    test('검증되지 않은 개편 날짜·레거시 12개월은 쓰지 않는다', () {
      final md = doc('clf', 't4-1');
      expect(md.contains('2025-07'), isFalse,
          reason: '그 날짜의 근거는 repost.aws 뿐이다');
      expect(RegExp(r'12개월\s*무료').hasMatch(md), isFalse,
          reason: '현행 공식 프리 티어 페이지에 그 서술이 없다');
      // 대조군 — 같은 탐지기가 옛 문구를 잡는다.
      expect(RegExp(r'12개월\s*무료').hasMatch('12개월 무료(가입일로부터)'), isTrue);
    });

    test('q10 이 그 절을 가리킨다', () {
      final q10 = question('clf', 't4-1', 'clf-t4-1-q10');
      expect(q10['section'], 'free-tier');
    });
  });

  // ═══════════════ P3-4② — Snowball 비중 메모 ═══════════════

  group('§P3-4② Snowball 비중 메모', () {
    test('t1-3.md 가 가이드 예시 제외와 범위 목록 부재를 적는다', () {
      final md = doc('clf', 't1-3');
      final hit = md.split('\n').where((l) =>
          l.contains('Snow') && l.contains('범위 내') && l.contains('예시'));
      expect(hit, isNotEmpty, reason: '비중 메모가 없다');
      final line = hit.first;
      expect(line.contains('범위 외'), isTrue,
          reason: '⚠️ 「범위 외」 목록에도 없으므로 범위 밖으로 단정하지 않는다');
    });

    test('frontmatter 출처 제목이 페이지 제목과 맞는다', () {
      final md = doc('clf', 't1-3');
      expect(md.contains('AWS Snowball이란?'), isFalse,
          reason: 'URL 은 whatisedge.html(Snowball Edge)이다');
      expect(md.contains('AWS Snowball Edge란?'), isTrue);
    });
  });

  // ═══════════════ P3-7 — Aurora 처리량 배수 ═══════════════

  group('§P3-7 Aurora 처리량은 주 가이드의 6배를 앞세운다', () {
    test('t3-4.md 가 6배를 적고 5배/3배를 갈림으로 가르친다', () {
      final md = doc('clf', 't3-4');
      expect(md.contains('6배'), isTrue);
      expect(md.contains('GovCloud'), isTrue, reason: '5배/3배의 출처를 밝힌다');
      expect(md.contains('SysBench'), isTrue, reason: '6배의 근거');
    });

    test('clf-t3-4-q2 의 출처 제목이 그 페이지가 적는 수치를 말한다', () {
      final q = question('clf', 't3-4', 'clf-t3-4-q2');
      final b = blob(q);
      expect(b.contains('6배'), isTrue);
      expect(b.contains('MySQL 최대 5배 처리량'), isFalse,
          reason: 'CHAP_AuroraOverview 는 두 엔진 모두 6배로 적는다');
      expect(
        urls(q).any((u) => u.contains('CHAP_AuroraOverview.html')),
        isTrue,
      );
      expect(urls(q).any((u) => u.contains('govcloud-aurora.html')), isTrue,
          reason: '5배/3배를 적는 쪽도 함께 둔다');
    });

    test('전수: 5배/3배를 적는 파일은 6배도 적는다', () {
      final offenders = <String>[];
      var scanned = 0;
      for (final dir in Directory(content).listSync().whereType<Directory>()) {
        for (final f in dir.listSync().whereType<File>()) {
          if (!f.path.endsWith('.md') &&
              !f.path.endsWith('.questions.json')) {
            continue;
          }
          final text = f.readAsStringSync();
          // ⚠️ Aurora 문맥으로 좁힌다 — 보고서는 Kinesis·Lambda 의 「5배」·
          // 「3배」까지 같은 집계에 넣었다(과대).
          if (!text.contains('Aurora')) continue;
          if (!text.contains('최대 5배') && !text.contains('최대 3배')) continue;
          scanned++;
          if (!text.contains('6배')) {
            offenders.add(f.uri.pathSegments.last);
          }
        }
      }
      expect(scanned, greaterThanOrEqualTo(1), reason: '대조군 — 비공허');
      expect(offenders, isEmpty,
          reason: '갈림을 가르치지 않으면 보기에 6배가 섞일 때 흔들린다: '
              '${offenders.join(' · ')}');
    });
  });
}
