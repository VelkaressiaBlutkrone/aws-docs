import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-21 `saa-t3-2` EFS 스토리지 클래스 발화 정정 가드.
///
/// PR #654 가 학습문서 §6 의 표를 공식 구성으로 고쳤다. 클래스는 EFS Standard·
/// Infrequent Access(IA)·Archive 이고, One Zone 은 Regional 과 나란한 **파일 시스템
/// 유형**이며, Archive 는 Regional + Elastic 처리량 전용이다
/// (`https://docs.aws.amazon.com/efs/latest/ug/features.html`). 승인된 음성의
/// `seg045` 는 옛 표를 읽고 있어 이 가드가 그 한 자리를 지킨다.
///
/// ⚠️ `reviewStatus`·`audioApproved` 를 여기서 단정하지 않는다. `approved` 는 사람의
/// 청취 서명이라 상태를 박으면 **사람의 재승인이 레드로 끝난다**
/// (`clf_t4_3_resynth_test.dart` 와 같은 규율).
///
/// ⚠️ `sourceHash` 는 올리지 않았다. 이 대본은 `seg*` 85개이고 현재 md 로 `generate`
/// 하면 118개이며 `seg027` 부터 블록이 어긋나, 해시를 올리면 「이 대본이 현재 md 에서
/// 왔다」는 거짓 선언이 된다. 현재 md 에서 온 것은 `seg045` 의 `sourceExcerpt` 뿐이다.
void main() {
  List<Map<String, dynamic>> segments() {
    final doc = json.decode(
      File('assets/audio/saa/saa-t3-2/script.json').readAsStringSync(),
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
    test('대본이 읽히고 seg045 가 발화되는 표 세그먼트다', () {
      expect(segments().length, greaterThan(80));
      expect(seg('seg045')['kind'], 'table');
      expect(spoken(seg('seg045')), contains('스토리지 클래스'));
    });

    test('seg062 의 파일 시스템 유형 설명은 옳으므로 그대로 있다', () {
      expect(spoken(seg('seg062')), contains('원 존과 리저널 두 가지'));
    });
  });

  group('seg045 발화가 공식 구성을 말한다', () {
    test('스토리지 클래스 셋을 말한다', () {
      final t = spoken(seg('seg045'));
      for (final name in ['스탠다드', '인프리퀀트 액세스', '아카이브']) {
        expect(t, contains(name), reason: '$name 이 발화에 없다');
      }
    });

    test('One Zone 을 클래스가 아니라 파일 시스템 유형으로 말한다', () {
      final t = spoken(seg('seg045'));
      expect(t, contains('파일 시스템 유형'));
      expect(t, contains('리저널'));
      expect(t, contains('원 존'));
      expect(t.indexOf('파일 시스템 유형'), lessThan(t.indexOf('원 존')),
          reason: '원 존이 유형 설명보다 먼저 나오면 클래스 목록으로 들린다');
    });

    test('Archive 의 사용 조건을 말한다', () {
      final t = spoken(seg('seg045'));
      expect(t, contains('리저널 파일 시스템'));
      expect(t, contains('엘라스틱 처리량'));
    });

    test('옛 클래스 이름과 잘못된 발음이 없다', () {
      final t = spoken(seg('seg045'));
      for (final retired in ['스탠다드 아이에이', '원 존 아이에이', '이이에프에스']) {
        expect(t, isNot(contains(retired)), reason: '$retired 이 남아 있다');
      }
    });

    test('이 문서의 어느 발화에도 옛 클래스 이름이 없다', () {
      final hits = [
        for (final s in segments())
          if (spoken(s).contains('스탠다드 아이에이') ||
              spoken(s).contains('원 존 아이에이'))
            s['id'],
      ];
      expect(hits, isEmpty);
    });
  });

  test('seg045 의 sourceExcerpt 가 현행 md 의 표에서 왔다', () {
    final md = File('assets/content/saa/saa-t3-2.md').readAsStringSync();
    final excerpt = seg('seg045')['sourceExcerpt'] as String;
    for (final now in [
      '| **EFS Infrequent Access(IA)** |',
      '| **EFS Archive** |',
      '| **One Zone** | 단일 AZ에 저장해 더 저렴.',
    ]) {
      expect(md, contains(now), reason: '현행 문구가 md 에 없다: $now');
      expect(excerpt, contains(now), reason: 'excerpt 가 낡았다: $now');
    }
    for (final retired in ['| **Standard-IA** |', '| **One Zone-IA** |']) {
      expect(md, isNot(contains(retired)));
      expect(excerpt, isNot(contains(retired)));
    }
  });
}
