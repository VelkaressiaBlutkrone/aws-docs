import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 `clf-t4-3` 재합성 회귀 가드.
///
/// 전 콘텐츠 검증 2단계가 발화 5세그먼트(seg006·014·030·031·033)의 거짓·불완전
/// 서술을 고쳤고(`clf_v2_fix_test.dart` 가 그 문구를 지킨다) 이 PR 이 재합성해
/// `sourceExcerpt`·`sourceHash`·`reviewStatus`·mp3 를 맞췄다. 이 파일이 지키는 것은
/// **발화 문구가 아니라 대본이 어느 md 에서 왔는지의 정합**이다.
///
/// ⚠️⚠️ **`reviewStatus`·`audioApproved` 를 여기서 단정하지 않는다.** `approved` 는
/// 사람의 청취 서명이고, 상태를 테스트에 박으면 **사람의 재승인이 레드로 끝난다**
/// (문항 `verified` flip 과 같은 함정 — `content_index_audio_test.dart` 의 규율).
/// 승인 ↔ 메타 정합은 `content_index_test.dart` 의 동기화 단정이 **양방향으로**
/// 지키므로 승인 전·후 모두 녹색이다.
///
/// ⚠️ **md 의 sha256 을 Dart 에서 직접 계산하지 않는다.** 이 레포에는 `crypto`
/// 의존이 없고(실측: `pubspec.yaml`·`pubspec.lock` 0건, Dart 코드는 저장된 해시
/// 문자열만 비교한다), 게다가 `Path.read_text` 와 달리 Dart 의
/// `readAsStringSync()` 는 줄끝을 정규화하지 않아 **작업트리(CRLF)와 CI(LF)가 다른
/// 값을 낸다**. 그래서 freshness 는 해시가 아니라 **문구 쌍**으로 센다.
///
/// ⚠️ 알려진 잔여 공백: 대본 43편 가운데 `script.sourceHash` ·
/// `audio_meta.source.sha256` · 현재 md 의 sha256 **세 값이 일치하는 것은
/// `clf-t4-3` 한 편뿐이다**(2026-11-17 실측 — 나머지 42편은 합성 이후 md 가 여러
/// 배치에서 바뀌었다. CLAUDE.md 가 「전 19편이 이미 stale」로 기록해 둔 그 조건이다).
/// 그 전수 freshness 는 Python 게이트(`gen_lecture_audio.py gate`)만 볼 수 있고
/// 자격증별 재합성 배치가 와야 닫힌다.
void main() {
  final audioRoot = Directory('assets/audio');

  List<File> scriptFiles() => audioRoot
      .listSync()
      .whereType<Directory>()
      .expand((family) => family.listSync().whereType<Directory>())
      .map((doc) => File('${doc.path}/script.json'))
      .where((f) => f.existsSync())
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  Map<String, dynamic> readJson(String path) =>
      json.decode(File(path).readAsStringSync()) as Map<String, dynamic>;

  Map<String, dynamic> t4m3Script() =>
      readJson('assets/audio/clf/clf-t4-3/script.json');

  String excerpt(String segId) {
    final seg = (t4m3Script()['segments'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((s) => s['id'] == segId,
            orElse: () => throw StateError('$segId 세그먼트가 없다'));
    return (seg['sourceExcerpt'] as String?) ?? '';
  }

  // ═════════════════════════ 대조군 ═════════════════════════

  group('대조군 — 대본과 학습문서가 읽혔다', () {
    test('대본 43편이 읽히고 clf-t4-3 이 54세그먼트다', () {
      // 0건 통과가 「경로를 못 찾아서」인 것을 막는다.
      expect(scriptFiles().length, greaterThanOrEqualTo(40));
      final segs = t4m3Script()['segments'] as List;
      expect(segs.length, 54);
      expect(segs.where((s) => (s as Map)['id'].toString().startsWith('seg')).length,
          47);
    });

    test('clf-t4-3 학습문서가 읽히고 Support 플랜을 다룬다', () {
      final md = File('assets/content/clf/t4-3.md').readAsStringSync();
      expect(md.length, greaterThan(5000));
      expect(md.contains('Support 플랜'), isTrue);
    });
  });

  // ═════════════════ 저장된 두 해시의 짝 (전수) ═════════════════

  group('대본 ↔ 오디오 메타 해시 짝', () {
    // `synthesize` 는 `meta["source"]` 를 script.json 에서 그대로 복사한다.
    // 둘이 어긋나면 **메타만 손으로 고쳤거나 대본만 갱신**한 것이다.
    // 2026-11-17 실측: meta 가 있는 대본 39편 전부 일치 → 전수로 걸 수 있다.
    test('meta 가 있는 모든 대본에서 sourceHash == source.sha256', () {
      final checked = <String>[];
      final mismatched = <String>[];
      for (final sf in scriptFiles()) {
        final metaPath = sf.path.replaceAll('script.json', 'audio_meta.json');
        if (!File(metaPath).existsSync()) continue;
        final script = readJson(sf.path);
        final meta = readJson(metaPath);
        final docId = script['docId'] as String;
        checked.add(docId);
        final a = script['sourceHash'] as String?;
        final b = (meta['source'] as Map<String, dynamic>?)?['sha256'] as String?;
        if (a == null || b == null || a != b) {
          mismatched.add('$docId: script=$a meta=$b');
        }
      }
      expect(checked.length, greaterThanOrEqualTo(39),
          reason: '대조군 — meta 를 가진 대본이 이만큼은 있어야 한다');
      expect(mismatched, isEmpty,
          reason: 'script.sourceHash ↔ audio_meta.source.sha256 불일치:\n'
              '${mismatched.join('\n')}');
    });

    test('clf-t4-3 의 해시가 2026-07-03 판본의 것이 아니다', () {
      // 재합성 전 `sourceHash` 는 **2026-07-03 md** 의 것이었다(역추적 실측).
      // 그 뒤 평문화 두 배치·P1·P2·검증 2단계가 md 를 고쳤고 Python 게이트가
      // `HARD stale` 두 건으로 막고 있었다.
      const retired =
          '8e5e05f9718db13601e291c76b486196c80ff8f02e4d43bfb2b110332773e9eb';
      final script = t4m3Script();
      final meta = readJson('assets/audio/clf/clf-t4-3/audio_meta.json');
      expect(script['sourceHash'], isNot(retired));
      expect((meta['source'] as Map<String, dynamic>)['sha256'], isNot(retired));
    });
  });

  // ═══════════ sourceExcerpt freshness — 문구 쌍 ═══════════

  group('md 를 고친 세그먼트의 sourceExcerpt 가 현행 md 에서 왔다', () {
    // 쌍으로 센다: ① 현행 문구가 md 와 excerpt **양쪽**에 있다 ② 옛 문구가
    // excerpt 에 **없다**. ①만 보면 excerpt 를 손으로 덧붙여도 통과하고,
    // ②만 보면 excerpt 를 지워 버려도 통과한다.
    const pairs = <String, ({String now, String retired})>{
      'seg006': (
        now: 'Basic 무료 → Business Support+ → Enterprise TAM → Unified Operations',
        retired: '(Basic 무료 → Enterprise TAM)',
      ),
      'seg014': (
        now: '전통 4단계 명칭으로 적힌 자료도 아직 많으므로',
        retired: '시중 기출·교재는 아직 전통 4단계로 출제하므로',
      ),
      'seg026': (
        now: '전통 분류에서는 **Business**가 최소 24x7 프로덕션 기술 지원 플랜입니다',
        retired: '시험 대비로는 전통 분류인 **Business**를',
      ),
      'seg030': (
        now: '**전담 TAM + 15분 응답 = Enterprise**(그 위의 Unified Operations는 5분 응답)',
        retired: '**전담 TAM + 15분 응답 = Enterprise.**',
      ),
      'seg031': (
        now: 'Enterprise On-Ramp의 2027-01-01 단종 공지',
        retired: 'Enterprise On-Ramp의 신규 가입 종료 공지',
      ),
      'seg033': (
        now: 'Business Support+에는 없고 Enterprise Support부터 포함된다',
        retired: '가장 높은 미션 크리티컬 요구를 가진 Enterprise 플랜에서만 포함된다',
      ),
    };

    final md = File('assets/content/clf/t4-3.md').readAsStringSync();

    pairs.forEach((segId, p) {
      test('$segId: 현행 문구가 md·excerpt 양쪽에 있고 옛 문구가 없다', () {
        expect(md.contains(p.now), isTrue,
            reason: '$segId 의 현행 문구가 md 에 없다 — 문구 쪽이 먼저 바뀌었다');
        expect(excerpt(segId).contains(p.now), isTrue,
            reason: '$segId 의 sourceExcerpt 가 낡았다 — 재합성 때 갱신하지 않았다');
        expect(excerpt(segId).contains(p.retired), isFalse,
            reason: '$segId 의 sourceExcerpt 에 옛 문구가 남아 있다');
        expect(md.contains(p.retired), isFalse,
            reason: '$segId 의 옛 문구가 md 에 되살아났다');
      });
    });
  });
}
