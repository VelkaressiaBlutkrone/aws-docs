import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SOA 문항의 사실 정정 가드 (2026-11-01).
///
/// 2026-10-29 출처 URL 전수 실측 보고서(`docs/saa-review/2026-10-29-soa-dea-source-url-audit.md`)
/// §4가 `soa-t1-1-q11` 을 `rewrite` 후보로 남기면서 "전부 드래프트라 라이브 노출은
/// 없다"고 적었다. **그 전제는 2026-10-31 `soa-t1-1` flip(#305)으로 깨졌다** —
/// 그 Task 는 게이트를 여는 5 Task 중 하나였고, 2026-11-01 에는 SOA 300문항이
/// 전부 `verified` 다. 그래서 라이브 문항의 핫픽스로 처리한다(flip 아님).
///
/// 결함: 경보 **작업**(alarm actions)에 EventBridge 가 들어 있다고 적는다.
/// 공식 `alarm-actions.html` 이 적는 작업은 SNS 알림 · **Lambda 함수 호출** ·
/// EC2 작업(중지·종료·재부팅·복구) · Auto Scaling 그룹 · Application Auto Scaling ·
/// Systems Manager OpsItem · Systems Manager Incident Manager · 조사 시작이고,
/// EventBridge 는 그 표에 없다. 같은 페이지가 이렇게 적는다 —
/// "Alarms also **emit events to** Amazon EventBridge when they change state,
/// and you can set up Amazon EventBridge to trigger other actions for these
/// state changes." 즉 EventBridge 는 작업 대상이 아니라 **경보가 이벤트를
/// 내보내는 곳**이다.
/// 근거: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-actions.html
///
/// ⚠️ **정답 인덱스는 두 문항 모두 바뀌지 않는다** — 결함이 지문의 전제·해설·
/// 오답 보기 문구에 있었고 고를 답은 그대로다. 그래서 각 묶음의 첫 단정이
/// 정답 불변을 고정한다.
void main() {
  List<Map<String, dynamic>> questionsOf(String taskId) {
    final file = File('assets/content/soa/$taskId.questions.json');
    final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    return (map['questions'] as List).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> question(String taskId, String qid) =>
      questionsOf(taskId).firstWhere(
        (q) => q['id'] == qid,
        orElse: () => fail('$qid 문항이 $taskId 에 없다'),
      );

  /// 문항 전체(지문·보기·해설·오답 근거·출처 제목)를 한 덩어리로.
  String allText(Map<String, dynamic> q) => json.encode(q);

  group('soa-t1-1-q11 EventBridge 는 경보 작업이 아니다', () {
    final q = question('soa-t1-1', 'soa-t1-1-q11');

    test('정답은 그대로 EventBridge(인덱스 0)', () {
      expect(q['correct'], 0,
          reason: '라우팅·필터링의 해법이 EventBridge 라는 것 자체는 옳다 — 틀린 것은 '
              '그것을 "경보 작업 대상"이라고 부른 전제다');
    });

    test('지문이 EventBridge 를 "경보 작업 대상"으로 묻지 않는다', () {
      expect((q['stem'] as String).contains('경보 작업 대상'), isFalse);
      expect((q['stem'] as String).contains('어떤 경보 작업'), isFalse);
    });

    test('해설의 작업 목록에서 EventBridge 가 빠지고 Lambda 가 들어왔다', () {
      final e = q['explanation'] as String;
      expect(e.contains('Systems Manager, EventBridge가 있습니다'), isFalse,
          reason: 'EventBridge 를 경보 작업으로 열거하던 옛 문장');
      expect(e.contains('Lambda'), isTrue,
          reason: '공식 목록의 Lambda 함수 호출이 빠져 있었다');
    });

    test('EventBridge 가 이벤트 수신처라는 공식 사실이 들어왔다', () {
      final e = q['explanation'] as String;
      expect(e.contains('이벤트를 내보내'), isTrue);
      expect(e.contains('경보 작업이 아니'), isTrue);
    });

    test('출처는 그대로 공식 alarm-actions 페이지', () {
      expect(
        (q['sources'] as List).any((s) =>
            ((s as Map<String, dynamic>)['url'] as String)
                .contains('monitoring/alarm-actions.html')),
        isTrue,
      );
    });
  });

  group('soa-t1-1-q4 오답 보기도 경보 작업을 바르게 부른다', () {
    final q = question('soa-t1-1', 'soa-t1-1-q4');

    test('정답은 그대로 M out of N 조정(인덱스 0)', () {
      expect(q['correct'], 0);
    });

    test('"경보 작업을 SNS에서 EventBridge로" 보기가 사라졌다', () {
      expect(allText(q).contains('EventBridge로 변경'), isFalse,
          reason: 'EventBridge 는 경보 작업이 아니라서 "작업을 EventBridge 로 바꾼다"가 '
              '성립하지 않는다 — 오답 보기라도 서비스 모델을 틀리게 가르치면 안 된다');
    });

    test('오답 근거가 "작업 대상 변경"이라는 표현을 쓰지 않는다', () {
      final w = (q['wrongExplanations'] as Map<String, dynamic>)['3'] as String;
      expect(w.contains('작업 대상 변경'), isFalse);
      expect(w.contains('전이 판단 기준과 무관'), isTrue,
          reason: '오답인 이유(전이 판단과 무관)는 그대로 유지한다');
    });
  });

  group('SOA 전수 — EventBridge 를 경보 작업으로 적는 문구가 없다', () {
    test('문항 300개 어디에도 남아 있지 않다', () {
      final offenders = <String>[];
      final dir = Directory('assets/content/soa');
      for (final file in dir.listSync().whereType<File>()) {
        if (!file.path.endsWith('.questions.json')) continue;
        final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
        for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
          final text = json.encode(q);
          for (final bad in const [
            'Systems Manager, EventBridge가 있습니다',
            '경보 작업 대상에는',
            'EventBridge로 변경',
          ]) {
            if (text.contains(bad)) offenders.add('${q['id']}: $bad');
          }
        }
      }
      expect(offenders, isEmpty,
          reason: 'EventBridge 는 경보 작업이 아니라 경보가 이벤트를 내보내는 곳이다:\n'
              '${offenders.join('\n')}');
    });
  });
}
