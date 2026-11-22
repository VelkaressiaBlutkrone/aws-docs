import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-21 `saa-t4-1` EFS 계층 전환 발화 정정 가드.
///
/// PR #655 가 학습문서 §6 을 공식 수명 주기 정책에 맞췄다. 수명 주기 관리가
/// Standard→IA, Standard 또는 IA→Archive 로 내리고, Intelligent-Tiering 은 IA·Archive
/// 파일에 접근할 때 Standard 로 되올린다. Archive→IA 전환은 없다
/// (`https://docs.aws.amazon.com/efs/latest/ug/lifecycle-management-efs.html`).
///
/// ⚠️ `reviewStatus`·`audioApproved` 를 여기서 단정하지 않는다. `approved` 는 사람의
/// 청취 서명이라 상태를 박으면 **사람의 재승인이 레드로 끝난다**.
///
/// ⚠️ `sourceHash` 는 올리지 않았다. 이 대본은 `seg*` 75개이고 현재 md 로 `generate`
/// 하면 128개이며 `seg015` 부터 블록이 어긋난다. 현재 md 에서 온 것은 `seg044`·
/// `seg045` 의 `sourceExcerpt` 에서 고친 그 줄뿐이다.
void main() {
  List<Map<String, dynamic>> segments() {
    final doc = json.decode(
      File('assets/audio/saa/saa-t4-1/script.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    return (doc['segments'] as List).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> seg(String id) =>
      segments().firstWhere((s) => s['id'] == id,
          orElse: () => throw StateError('$id 세그먼트가 없다'));

  // `gen_lecture_audio.py` 의 `_segment_speech` 와 같은 우선순위다.
  String spoken(Map<String, dynamic> s) {
    if (s['skip'] == true) return '';
    if (s['kind'] == 'table') return (s['audioSummary'] as String?) ?? '';
    final enriched = s['enrichedScriptText'] as String?;
    if (enriched != null && enriched.isNotEmpty) return enriched;
    return (s['scriptText'] as String?) ?? '';
  }

  group('대조군', () {
    test('대본이 읽히고 seg044 는 표, seg045 는 문단이다', () {
      expect(segments().length, greaterThan(70));
      expect(seg('seg044')['kind'], 'table');
      expect(seg('seg045')['kind'], 'paragraph');
      expect(spoken(seg('seg044')), contains('Amazon FSx for Lustre'));
    });

    test('seg053 의 시나리오 요약은 md 가 그대로라 유지된다', () {
      expect(spoken(seg('seg053')),
          contains('이에프에스 비용 자동 최적화는 이에프에스 Intelligent-Tiering 활성화입니다'));
    });
  });

  group('EFS 계층 전환 발화', () {
    test('seg044 가 Standard 로 되올리는 동작과 없는 전환을 말한다', () {
      final t = spoken(seg('seg044'));
      expect(t, contains('수명 주기 정책이 아이에이나 Archive로 내린 파일에 다시 접근하면 Standard로 되올립니다'));
      expect(t, contains('Archive에서 아이에이로 가는 전환은 없습니다'));
    });

    test('seg045 가 수명 주기 관리와 인텔리전트 티어링의 역할을 가른다', () {
      final t = spoken(seg('seg045'));
      expect(t, contains('더 저렴한 계층으로 내려 주는 것은 수명 주기 관리입니다'));
      expect(t, contains('이에프에스 인텔리전트 티어링을 켜면 그 파일에 다시 접근할 때 스탠다드로 되올려 줍니다'));
    });

    test('이 문서의 어느 발화에도 옛 전환 서술이 없다', () {
      const retired = [
        'Standard, 아이에이, Archive 사이를 자동 전환',
        '이 기능을 설정해 두면, 자주 접근하지 않는 파일을',
      ];
      final hits = [
        for (final s in segments())
          for (final r in retired)
            if (spoken(s).contains(r)) '${s['id']}: $r',
      ];
      expect(hits, isEmpty);
    });
  });

  test('seg044·seg045 의 sourceExcerpt 가 현행 md 의 문구를 담는다', () {
    final md = File('assets/content/saa/saa-t4-1.md').readAsStringSync();
    const pairs = <String, ({String now, String retired})>{
      'seg044': (
        now: '수명 주기 정책이 내린 IA·Archive 파일에 접근하면 Standard로 되올림',
        retired: '접근 패턴에 따라 Standard↔IA↔Archive 자동 전환',
      ),
      'seg045': (
        now: '수명 주기 관리가 자주 접근하지 않는 파일을 IA·Archive로 내리고',
        retired: 'EFS Intelligent-Tiering으로 설정하면 자동으로 저렴한 계층으로 이동',
      ),
    };
    pairs.forEach((id, p) {
      final excerpt = seg(id)['sourceExcerpt'] as String;
      expect(md, contains(p.now), reason: '$id 현행 문구가 md 에 없다');
      expect(excerpt, contains(p.now), reason: '$id excerpt 가 낡았다');
      expect(excerpt, isNot(contains(p.retired)), reason: '$id 옛 문구가 남았다');
    });
  });
}
