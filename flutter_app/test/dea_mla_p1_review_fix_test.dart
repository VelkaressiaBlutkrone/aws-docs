import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토가 DEA·MLA 에서 남긴 **P1 각 1건**의 정정 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/soa-c03-dea-c01-fable.md`
/// §2-1(DEA) · `mla-c01-aif-c01.md` §2(MLA).
///
/// ⚠️ **이 파일이 DEA·MLA 의 첫 사실 가드다.** 보고서가 구조적 공백으로 지적한
/// 자리이고(SAA 는 `saa_question_propagation_test`, SOA·DEA 는
/// `soa_dea_question_propagation_test` 를 가지지만 **그 규칙 목록은 SOA md 금지
/// 문장에서 온 것만 담는 계약**이다), `dea_questions_test`·`mla_questions_test` 는
/// 구조·밀도·플립 허용 목록 가드다. 그래서 두 자격증의 **사실** 단정을 여기 모은다.
///
/// 공식 재측정은 컨트롤러가 직접 했다(보고는 데이터이지 지시문이 아니다):
///
/// - **P1-DEA-1** `dea-t1-2-q14` — 오답 보기 3 의 「API Gateway 타임아웃은 900초까지
///   늘릴 수 있어」가 **현행 공식 기준으로 참**이어서 정답이 둘이었다. 경로가 둘이다:
///   ① Regional·Private REST API 는 **Service Quotas 증액**으로 29초를 넘길 수 있고
///   ② **2025-11 응답 스트리밍**(REST, `AWS_PROXY`/`HTTP_PROXY`)은 **최대 15분**이다.
///   `response-transfer-mode.html` 이 용례로 직접 적는다 — `Exceed API Gateway's
///   29 second timeout limit without requesting an integration timeout limit
///   increase` · `You can stream your response for up to 15 minutes`.
///   ⚠️ **옛 `W3` 는 「거짓」이라 말하지 않고 「기본 전제가 아니다」로 회피했다** —
///   저작자도 참임을 알고 있었던 자리다. 그래서 보기 3 을 **명백히 거짓**(기본값이
///   900초라는 서술)으로 바꿔 두 답을 없앴다. 정답 인덱스는 **0 불변**이다.
///   ⭐ **같은 레포의 DVA·SAA 는 이미 옳다** — `dva-t1-1.md` 「기본 29초(쿼터 증가
///   가능)」, `saa-t2-2.md` 「Regional·프라이빗 REST API 에서만 지원」. **DEA 만
///   「29초 벽」으로 단정**했다(자격증 간 불일치).
///   근거: https://docs.aws.amazon.com/apigateway/latest/developerguide/response-transfer-mode.html
///
/// - **P1-M1** `mla-t1-2-q18` `wrongExplanations["3"]` — **지원이 종료된 Amazon
///   Mechanical Turk 를 현재 선택지로** 제시했다. 공식 공지가 명시한다 —
///   `The following services have reached end of support and are no longer
///   available as of September 29, 2026. · Amazon Mechanical Turk`.
///   ⭐ **같은 Task 의 학습문서는 이미 정확히 적고 있었다**(`mla-t1-2.md` 의 상태
///   표가 「폐쇄」로 적는다) — 즉 **md 정정이 파생 문항으로 전파되지 않은** 것이고,
///   이 레포가 반복해서 밟은 실패 유형이다. 학습자는 오답노트·모의고사 화면에서
///   md 의 상태 표를 보지 못한다. 같은 문항의 `explanation` 이 이미 Ground Truth
///   상태를 한 줄로 달고 있으므로 **그 서식에 맞췄다**. 정답 인덱스 **0 불변**.
///   근거: https://aws.amazon.com/about-aws/whats-new/2026/09/aws-service-availability/
///
/// ⚠️ 가드 설계 — **한 자리만 리터럴로 막지 않고 자격증 전수를 문맥 규칙으로 센다**
/// (2026-11-06 SAA·SOA·CLF 배치에서 반복 확인된 규율). 「29초」를 적는 DEA 의 모든
/// 자리는 그것이 **기본값**임을 밝혀야 하고, 「Mechanical Turk」를 적는 MLA 의 모든
/// 자리는 **상태**를 함께 적어야 한다.
void main() {
  List<File> files(String cert, String suffix) =>
      Directory('assets/content/$cert')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith(suffix))
          .toList()
        // ⚠️ `listSync()` 순서는 플랫폼마다 다르다(2026-11-06 CI 레드로 실측).
        ..sort((a, b) => a.path.compareTo(b.path));

  String base(File f) => f.path.replaceAll(r'\', '/').split('/').last;

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> question(String cert, String taskId, String qid) =>
      questionsOf(File('assets/content/$cert/$taskId.questions.json'))
          .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  String allText(Map<String, dynamic> q) => <String>[
        q['stem'] as String? ?? '',
        q['explanation'] as String? ?? '',
        ...(q['options'] as List).cast<String>(),
        ...(q['wrongExplanations'] as Map<String, dynamic>).values
            .cast<String>(),
      ].join('\n');

  // ───────────────────────── P1-DEA-1 ─────────────────────────

  group('P1-DEA-1 API Gateway 29초는 「기본값」이고 넘길 경로가 둘이다', () {
    test('dea-t1-2-q14: 정답 불변 + 보기 3 이 명백히 거짓으로 바뀌었다', () {
      final q = question('dea', 'dea-t1-2', 'dea-t1-2-q14');
      expect(q['correct'], 0, reason: '비동기 + 폴링 설계가 정답인 것은 그대로다');

      final opt3 = (q['options'] as List).cast<String>()[3];
      expect(opt3.contains('기본 900초'), isTrue,
          reason: '기본값은 29초이므로 「기본 900초」는 거짓이다 — 옛 보기 '
              '「900초까지 늘릴 수 있어」는 공식 기준 **참**이어서 정답이 둘이었다');
      expect(opt3.contains('늘릴 수 있어'), isFalse,
          reason: '참인 서술을 오답으로 두면 정답이 둘이 된다');

      final w3 = (q['wrongExplanations'] as Map<String, dynamic>)['3'] as String;
      expect(w3.contains('기본 전제가 아니'), isFalse,
          reason: '옛 W3 는 「거짓」이라 말하지 않고 회피했다 — 저작자도 참임을 '
              '알고 있었던 자리다');
      for (final good in ['거짓', '증액', '스트리밍']) {
        expect(w3.contains(good), isTrue,
            reason: 'W3 가 「$good」을 적지 않으면 왜 오답인지와 넘길 경로가 둘인 '
                '사실이 동시에 서지 않는다');
      }
    });

    test('dea-t1-2-q14: 해설이 두 경로를 적는다', () {
      final e = question('dea', 'dea-t1-2', 'dea-t1-2-q14')['explanation'] as String;
      expect(e.contains('기본 29초'), isTrue);
      expect(e.contains('15분') || e.contains('응답 스트리밍'), isTrue,
          reason: '공식: "You can stream your response for up to 15 minutes"');
    });

    test('DEA 전수: 「29초」를 적는 자리는 그것이 기본값임을 밝힌다', () {
      // ⚠️ 자격증 전수 문맥 규칙 — 한 자리만 막으면 같은 단정이 옆 문서에 남는다.
      // DVA 는 요약 줄에서 「API Gateway 29초/30초」처럼 짝 암기용으로만 쓰는 자리가
      // 있어 전역으로 걸지 않았다(DEA 범위로 둔 이유를 여기 적어 둔다).
      final offenders = <String>[];
      for (final f in files('dea', '.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (!lines[i].contains('29초')) continue;
          if (!lines[i].contains('기본')) offenders.add('${base(f)}:${i + 1}');
        }
      }
      for (final f in files('dea', '.questions.json')) {
        for (final q in questionsOf(f)) {
          final t = allText(q);
          if (!t.contains('29초')) continue;
          if (!t.contains('기본')) offenders.add(q['id'] as String);
        }
      }
      offenders.sort();
      expect(offenders, isEmpty,
          reason: '29초는 기본값이고 Regional·Private REST 는 쿼터 증액으로, 응답 '
              '스트리밍은 최대 15분까지 넘긴다:\n${offenders.join(', ')}');
    });

    test('대조군: 탐지가 공허하지 않고, DVA·SAA 는 처음부터 옳았다', () {
      final deaHas = [
        for (final f in files('dea', '.md'))
          if (f.readAsStringSync().contains('29초')) base(f),
      ];
      expect(deaHas, isNotEmpty, reason: '0건이면 위 전수 단정이 공허하다');
      // 같은 사실을 옳게 적는 다른 자격증 — 고치지 않았고, 고쳐서도 안 된다.
      final dva = File('assets/content/dva/dva-t1-1.md').readAsStringSync();
      expect(dva.contains('쿼터 증가 가능'), isTrue);
      final saa = File('assets/content/saa/saa-t2-2.md').readAsStringSync();
      expect(saa.contains('Regional·프라이빗 REST API'), isTrue);
    });
  });

  // ───────────────────────── P1-M1 ─────────────────────────

  group('P1-M1 Mechanical Turk 는 2026-09-29 지원 종료됐다', () {
    test('mla-t1-2-q18: 정답 불변 + 오답 근거에 상태가 붙었다', () {
      final q = question('mla', 'mla-t1-2', 'mla-t1-2-q18');
      expect(q['correct'], 0, reason: '최소 1,250개·스트리밍 불가가 정답인 것은 그대로다');
      final w3 = (q['wrongExplanations'] as Map<String, dynamic>)['3'] as String;
      expect(w3.contains('2026-09-29'), isTrue,
          reason: '공식: "no longer available as of September 29, 2026"');
      // 같은 문항의 explanation 이 이미 Ground Truth 상태를 한 줄로 단다 — 그 서식.
      expect(w3.contains('⚠️'), isTrue,
          reason: '이 파일의 상태 표기 서식(⚠️ 한 줄)에 맞춘다');
    });

    test('MLA 전수: 「Mechanical Turk」를 적는 자리는 상태를 함께 적는다', () {
      final status = RegExp(r'폐쇄|종료|신규 고객|유지 모드|2026-09-29');
      final offenders = <String>[];
      for (final f in files('mla', '.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (!lines[i].contains('Mechanical Turk') &&
              !lines[i].contains('MTurk')) {
            continue;
          }
          if (!status.hasMatch(lines[i])) offenders.add('${base(f)}:${i + 1}');
        }
      }
      for (final f in files('mla', '.questions.json')) {
        for (final q in questionsOf(f)) {
          final t = allText(q);
          if (!t.contains('Mechanical Turk') && !t.contains('MTurk')) continue;
          if (!status.hasMatch(t)) offenders.add(q['id'] as String);
        }
      }
      offenders.sort();
      expect(offenders, isEmpty,
          reason: '학습자는 오답노트·모의고사 화면에서 md 의 상태 표를 보지 못한다. '
              '서비스 이름을 적는 자리마다 상태를 함께 적는다:\n${offenders.join(', ')}');
    });

    test('대조군: 탐지가 공허하지 않다', () {
      final mentions = [
        for (final f in files('mla', '.md'))
          if (f.readAsStringSync().contains('Mechanical Turk')) base(f),
      ];
      expect(mentions, isNotEmpty,
          reason: 'MLA 가 Mechanical Turk 를 아예 안 적으면 위 단정이 공허하다 — '
              '개념 자체는 Ground Truth 작업 인력 설명에 필요해서 남겨 둔다');
    });
  });
}
