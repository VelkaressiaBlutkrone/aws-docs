import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토의 **MLA 우선순위 3(P3) 계열** 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/mla-c01-aif-c01.md`
/// §5 `P3-M2`(Clarify·Model Monitor 상태 표기) · `P3-M3`(「미세 조정」 표기
/// 3갈래). `P3-M5`(전파 가드 공백)는 `mla_aif_question_propagation_test.dart`
/// 로 따로 세웠다. `P3-M1`·`P3-M4` 는 각각 2026-11-06 배치가 닫았고 보고서가
/// 「재보고하지 않는다」로 남겼다.
///
/// 공식 재측정은 컨트롤러가 직접 했다. 손댄 콘텐츠는 **전부 라이브**이고
/// **정답 인덱스·`verified` 는 한 건도 바뀌지 않았다.**
///
/// ## ⚠️⚠️ `P3-M2` 는 이미 닫혀 있었다 — 그리고 보고서의 ②가 옳았다
///
/// 보고서는 `mla-t4-1-q19`·`q20`·`q21` 에 **Model Monitor 상태 한 줄**이 없다며
/// ①(한 줄 추가 + `mmTaughtIds` 13 → 16)과 ②(달지 않고 제외 이유를 주석에
/// 적는다)를 제시하고 「②도 충분히 정당하다」고 했다. 2026-11-07 실측 결과
/// **세 문항은 이미 상태를 적는다** — 다만 Model Monitor 가 아니라 **Clarify**
/// 쪽이고, 2026-11-06 MLA·AIF P2 배치(§P2-M1)가 「가르치는 층」 기준으로 달아
/// 뒀다(`mla_aif_p2_review_fix_test.dart` 의 MLA 전수 단정이 그것을 지킨다).
///
/// 세 문항의 출처는 전부 `clarify-model-monitor-*` 계열이고 가르치는 것은
/// **Clarify 가 구현하는 모니터 유형**이므로, **Clarify 상태가 더 정확한 층**이다.
/// 여기에 Model Monitor 한 줄을 더 붙이면 같은 사실을 두 번 말하는 셈이고,
/// 보고서가 걱정한 「Model Monitor 는 닫혔지만 편향 드리프트는 쓸 수 있다」는
/// 오독도 **이미 생기지 않는다.** 그래서 ②를 택하고 **제외를 가드로 고정**한다.
///
/// ## 비자명한 공식 사실
///
/// ⚠️ **공식 한국어 표기는 「미세 조정」(띄어 씀)이다** — `ko_kr` Bedrock 사용자
/// 지정 페이지가 「**감독 미세 조정**」·「**강화 미세 조정**」·「미세 조정으로 모델
/// 사용자 지정」으로 적고 **「파인튜닝」은 0건**이다. 공식 시험 가이드 JSON 도
/// 목표 3.3 을 「파운데이션 모델의 훈련과 **미세 조정** 프로세스 설명」으로 적는다
/// (`aif_guide_v11_test.dart` 가 그 전문을 단정한다).
///
/// ## 비자명한 규율
///
/// ⚠️ **앵커는 건드리지 않는다.** `mla-t2-2.md:337` 의 `{#fine-tuning}` 은
/// `mla_questions_test.dart` 의 「문항의 `section` 이 학습문서 앵커와 짝이
/// 맞는다」가 대조하는 값이다. 바꾸는 것은 **표시 문자열만**이다.
///
/// ⚠️ **md `title:` 을 바꾸면 `content_index.dart` 도 함께 바꾼다.** 둘을 묶는
/// 동기화 테스트는 **없다**(실측) — 그래서 어긋나도 아무도 알려 주지 않는다.
/// 이 파일이 그 짝을 단정한다.
///
/// ⚠️ **보고서 범위가 또 하한이었다** — 「파인튜닝」을 MLA 8건으로 적었지만
/// `dea-t1-2.questions.json` 에 **1건 더** 있었다. 전역 0건으로 닫지 않으면
/// 전파 가드를 초록으로 만들 수 없다.
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

  const clarifyNote = '⚠️ SageMaker Clarify는 신규 고객에게 닫혀 있습니다';
  const mmIds = <String>['mla-t4-1-q19', 'mla-t4-1-q20', 'mla-t4-1-q21'];

  // ═════════════════════ §P3-M2 ═════════════════════

  group('§P3-M2 드리프트 판정 문항의 상태 표기', () {
    test('세 문항은 Clarify 상태를 적고 정답·verified 가 불변이다', () {
      for (final qid in mmIds) {
        final q = question('mla', 'mla-t4-1', qid);
        expect((q['explanation'] as String).contains(clarifyNote), isTrue,
            reason: '$qid: 2026-11-06 P2 배치가 가르치는 층 기준으로 달아 둔 줄이다');
        expect(q['correct'], 0);
        expect(q['verified'], true);
      }
    });

    test('Model Monitor 목록(mmTaughtIds)에는 세 문항이 들어가지 않는다', () {
      final src = File('test/mla_questions_test.dart').readAsStringSync();
      final listStart = src.indexOf('const mmTaughtIds');
      expect(listStart, greaterThan(0), reason: '대조군 — 목록이 실재한다');
      final listEnd = src.indexOf('];', listStart);
      final list = src.substring(listStart, listEnd);
      for (final qid in mmIds) {
        expect(list.contains(qid), isFalse,
            reason: '$qid 은 Clarify 상태를 이미 적는다 — 같은 사실을 두 번 '
                '말하지 않는다(보고서 §P3-M2 의 ②안)');
      }
    });

    test('제외 이유가 그 목록 주석에 적혀 있다', () {
      final src = File('test/mla_questions_test.dart').readAsStringSync();
      expect(src.contains('드리프트 판정'), isTrue,
          reason: '왜 드리프트 판정 메커니즘 문항을 제외하는지 한 줄이 필요하다'
              '(보고서 §P3-M2 ②안의 요구)');
    });
  });

  // ═════════════════════ §P3-M3 ═════════════════════

  group('§P3-M3 「미세 조정」 표기 통일', () {
    test('mla-t2-2.md 의 절 제목이 공식 표기를 쓰고 앵커는 그대로다', () {
      final md = doc('mla', 'mla-t2-2');
      expect(md.contains('### 12) 사전 훈련 모델 미세 조정 {#fine-tuning}'), isTrue);
      expect(md.contains('{#fine-tuning}'), isTrue,
          reason: '앵커는 문항 section 과 짝이 맞아야 한다 — 표시 문자열만 바꾼다');
    });

    test('mla-t2-2.md 의 title·H1 에 음차 표기가 없다', () {
      final md = doc('mla', 'mla-t2-2');
      final head = md.split('\n').take(60).join('\n');
      expect(head.contains('파인튜닝'), isFalse);
      expect(head.contains('미세 조정'), isTrue);
    });

    test('content_index.dart 의 제목이 md title 과 짝이 맞는다', () {
      final md = doc('mla', 'mla-t2-2');
      final title = RegExp(r'^title: (.+)$', multiLine: true)
          .firstMatch(md)!
          .group(1)!
          .trim();
      final index = File('lib/data/content_index.dart').readAsStringSync();
      expect(index.contains("title: '$title'"), isTrue,
          reason: '둘을 묶는 동기화 테스트가 없어 어긋나도 아무도 알려 주지 않는다');
      expect(index.contains('파인튜닝'), isFalse);
    });

    test('교차 참조 라벨도 함께 움직였다', () {
      for (final id in <String>['mla-t2-1', 'mla-t2-2']) {
        expect(doc('mla', id).contains('파인튜닝'), isFalse, reason: id);
      }
      expect(doc('mla', 'mla-t2-2').contains('12) 미세 조정'), isTrue,
          reason: '절 번호를 가리키는 라벨이 제목과 같아야 한다');
    });

    test('대조군: AIF 는 원래 공식 표기만 쓴다', () {
      final aifMd = Directory('$content/aif')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .map((f) => f.readAsStringSync())
          .join('\n');
      expect(aifMd.contains('미세 조정'), isTrue,
          reason: '이 전제가 사라지면 「공식 표기」 판단의 근거가 사라진다');
      expect(aifMd.contains('미세조정'), isFalse);
      expect(aifMd.contains('파인튜닝'), isFalse);
    });
  });
}
