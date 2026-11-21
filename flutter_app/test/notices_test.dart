// flutter_app/test/notices_test.dart
//
// 공지 데이터 계층(번들 자산 로더)과 **콘텐츠 규율** 가드.
// 설계 정본: `docs/superpowers/specs/2026-11-21-notice-feedback-design.md` §7-1.
//
// ⚠️ 공지는 Firestore 가 아니라 **번들 자산**이다(설계 §5-1 B안) — 규칙 변경이
// 필요 없고 오프라인에서도 보이는 대신, 공지를 내는 데 릴리스가 따른다. 그래서
// 본문 형식을 콘솔이 아니라 **이 가드가** 검증한다.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/notices.dart';
import 'package:aws_docs/models/notice.dart';

const _twoNotices = '''
[{"id":"n-20261202-01","date":"2026-12-02","title":"두 번째","body":"본문2"},
 {"id":"n-20261201-01","date":"2026-12-01","title":"첫 번째","body":"본문1"}]''';

void main() {
  group('공지 자산 로더', () {
    test('정상 JSON 을 최신 먼저 순서대로 읽는다', () async {
      final list = await loadNotices(loadString: (_) async => _twoNotices);
      expect([for (final n in list) n.id],
          ['n-20261202-01', 'n-20261201-01']);
      expect(list.first.title, '두 번째');
      expect(list.first.body, '본문2');
      expect(list.last.date, '2026-12-01');
    });

    // Review Focus 1 — 빈 배열은 결함이 아니라 **초기 상태**다.
    test('빈 배열은 빈 목록이다', () async {
      expect(await loadNotices(loadString: (_) async => '[]'), isEmpty);
    });

    test('손상된 JSON 은 던지지 않고 빈 목록이다', () async {
      expect(await loadNotices(loadString: (_) async => '{not json'), isEmpty);
    });

    test('자산이 없어도 던지지 않는다', () async {
      expect(
        await loadNotices(loadString: (_) async => throw Exception('404')),
        isEmpty,
      );
    });

    // 로더가 **어느 키를 요청하는지** 고정한다 — 키가 어긋나면 번들 자산을
    // 선언해도 화면이 빈 채로 뜬다(2026-11-14 라이브 404 와 같은 계열).
    test('자산 키는 assets/notices.json 이다', () async {
      String? asked;
      await loadNotices(loadString: (k) async {
        asked = k;
        return '[]';
      });
      expect(asked, 'assets/notices.json');
    });
  });

  group('번들 공지 콘텐츠 규율', () {
    // ⚠️⚠️ 자산 **내용** 검증은 `rootBundle` 이 아니라 `dart:io` 로 디스크에서
    // 읽는다(`all_content_parse_test` 와 같은 관례). `testWidgets` 안에서
    // `rootBundle.loadString` 을 직접 await 하면 **두 번째 호출이 캐시된 Future
    // 에 묶여 멈춘다** — 실측에서 10분 타임아웃이었다. 로더가 보는 키는 위
    // 「자산 키는 …」 테스트가, 번들 포함은 아래 pubspec 테스트가 따로 지킨다.
    String diskJson() => File('assets/notices.json').readAsStringSync();

    // 대조군 — 번들 파일의 실제 내용이 로더를 통과한다.
    test('번들 자산이 파싱된다', () async {
      expect(await loadNotices(loadString: (_) async => diskJson()),
          isA<List<Notice>>());
    });

    // Review Focus 4(가드 쪽) — id 유일·형식 · date 형식·내림차순 · 본문 평문.
    // 런타임은 이 규율이 깨져도 안전하게 흡수한다(Task 2 의 폴백).
    test('번들 공지가 콘텐츠 규율을 지킨다', () async {
      final list = await loadNotices(loadString: (_) async => diskJson());
      final ids = [for (final n in list) n.id];
      expect(ids.toSet().length, ids.length, reason: 'id 가 중복이다');
      for (final n in list) {
        expect(RegExp(r'^n-\d{8}-\d{2}$').hasMatch(n.id), isTrue,
            reason: 'id 형식이 n-YYYYMMDD-NN 이 아니다: ${n.id}');
        expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(n.date), isTrue,
            reason: 'date 형식이 YYYY-MM-DD 가 아니다: ${n.date}');
        expect(n.title.trim(), isNotEmpty, reason: '${n.id} 의 제목이 비었다');
        expect(n.body.trim(), isNotEmpty, reason: '${n.id} 의 본문이 비었다');
        expect(RegExp(r'\[[^\]]+\]\([^)]+\)').hasMatch(n.body), isFalse,
            reason: '본문은 평문이다 — 마크다운 링크를 쓰지 않는다: ${n.id}');
      }
      final dates = [for (final n in list) n.date];
      final sorted = [...dates]..sort((a, b) => b.compareTo(a));
      expect(dates, sorted, reason: 'date 내림차순이어야 한다(최신 먼저)');
    });

    // 2026-11-14 라이브 404 선례 — 자산을 더하면 pubspec 선언이 함께 가야 한다.
    test('pubspec 이 notices.json 을 선언한다', () {
      expect(File('pubspec.yaml').readAsStringSync(),
          contains('- assets/notices.json'));
    });
  });
}
