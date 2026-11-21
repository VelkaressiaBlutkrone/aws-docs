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

import 'package:aws_docs/data/local_kv.dart';
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

  // Review Focus 4(런타임 흡수) + 설계 §7-1 의 폴백 둘.
  //
  // ⚠️ 읽음 상태는 **기기별 로컬**이다(동기하지 않는다) — 동기 컬렉션을 하나
  // 늘리면 계정 삭제·처리방침 가드 셋을 모두 건드려야 하고, 공지를 읽었는지는
  // 기기마다 달라도 해가 없다.
  group('공지 읽음 상태', () {
    const a = Notice(
        id: 'n-20261203-01', date: '2026-12-03', title: 't3', body: 'b');
    const b = Notice(
        id: 'n-20261202-01', date: '2026-12-02', title: 't2', body: 'b');
    const c = Notice(
        id: 'n-20261201-01', date: '2026-12-01', title: 't1', body: 'b');
    const all = [a, b, c]; // 최신 먼저

    // 폴백 ① — 새 테스터의 첫 화면이 공지 배너가 되지 않게 한다. 배너는
    // 「내가 본 뒤에 새로 온 것」만을 뜻한다.
    test('신규 설치(키 없음)는 전부 읽음이다', () {
      expect(unreadCount(all, MemoryBackend()), 0);
    });

    test('저장된 id 뒤에 온 공지만 센다', () {
      final kv = MemoryBackend()..write(kNoticeReadUpToKey, c.id);
      expect(unreadCount(all, kv), 2);
    });

    test('최신을 읽었으면 0 이다', () {
      final kv = MemoryBackend()..write(kNoticeReadUpToKey, a.id);
      expect(unreadCount(all, kv), 0);
    });

    // 폴백 ② — append-only 규율이 깨져(공지를 지우거나 id 를 바꿔) 저장값을
    // 목록에서 찾을 수 없을 때. 「전부 안 읽음」으로 떨어지면 전 기기에 배너가
    // 되살아나는데 그것이 더 나쁜 실패다.
    test('번들에 없는 id 는 전부 읽음으로 흡수한다', () {
      final kv = MemoryBackend()..write(kNoticeReadUpToKey, 'n-20250101-99');
      expect(unreadCount(all, kv), 0);
    });

    // 레포에서 빈 문자열 쓰기는 「지움」을 뜻한다(동기 표식) — 그 값도 안전해야 한다.
    test('빈 문자열이 저장돼 있어도 전부 읽음이다', () {
      final kv = MemoryBackend()..write(kNoticeReadUpToKey, '');
      expect(unreadCount(all, kv), 0);
    });

    test('빈 공지 목록은 0 이고 markAllRead 가 아무것도 쓰지 않는다', () {
      final kv = MemoryBackend();
      expect(unreadCount(const [], kv), 0);
      markAllRead(const [], kv);
      expect(kv.read(kNoticeReadUpToKey), isNull);
    });

    test('markAllRead 뒤에는 0 이다', () {
      final kv = MemoryBackend()..write(kNoticeReadUpToKey, c.id);
      markAllRead(all, kv);
      expect(kv.read(kNoticeReadUpToKey), a.id);
      expect(unreadCount(all, kv), 0);
    });
  });
}
