// DVA-C02 → DVA-C03 전환 가드.
//
// 공식 인증 페이지와 가이드가 DVA-C02 마지막 응시일을 2026-11-30, DVA-C03 사용
// 시작을 2026-12-01 로 적는다. 이 전환은 12월 1일 이후에만 main 에 들어간다.
//
// 가이드 JSON 은 공식 한국어 도메인 페이지에서 기계로 추출했다. 도메인 이름은
// 도메인 페이지 H1, 비중은 「내용 개요」에서 가져온다(저작 결정 D-01).
// 시험 시간 130분은 가이드 본문에 없고 공식 인증 페이지가 근거다(갭 G-03).
import 'dart:convert';
import 'dart:io';

import 'package:aws_docs/data/cert_lifecycle.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/content_audit.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:flutter_test/flutter_test.dart';

const _taskIds = [
  'dva-t1-1', 'dva-t1-2', 'dva-t1-3',
  'dva-t2-1', 'dva-t2-2', 'dva-t2-3',
  'dva-t3-1', 'dva-t3-2', 'dva-t3-3',
  'dva-t4-1', 'dva-t4-2', 'dva-t4-3',
];

/// 공식 작업 제목과 기술 수(2026-11-23 공식 한국어 페이지에서 추출).
const Map<String, (String, int)> _officialTasks = {
  '1.1': ('AWS에서 호스팅하는 애플리케이션의 코드를 개발합니다.', 10),
  '1.2': ('AWS Lambda용 코드를 개발합니다.', 4),
  '1.3': ('애플리케이션 개발 중에 데이터 스토어를 사용합니다.', 4),
  '2.1': ('애플리케이션과 AWS 서비스에 대한 인증 및 권한 부여 메커니즘을 구현합니다.', 7),
  '2.2': ('AWS 서비스를 사용하여 암호화를 구현하고 민감한 데이터를 관리합니다.', 7),
  '2.3': ('AI 서비스를 사용하고 애플리케이션 개발에 통합하는 것과 관련된 보안 위험을 식별하고 완화합니다.', 5),
  '3.1': ('AWS에 배포할 애플리케이션 아티팩트를 준비합니다.', 5),
  '3.2': ('AWS 환경에서 애플리케이션 테스트를 구현하고 자동화합니다.', 5),
  '3.3': ('AWS 지속적 통합 및 지속적 전달 (CI/CD) 서비스를 사용하여 코드를 배포합니다.', 9),
  '4.1': ('근본 원인 분석을 지원합니다.', 5),
  '4.2': ('로깅, 모니터링, 관찰성 모범 사례를 적용합니다.', 5),
  '4.3': ('AWS 서비스와 기능을 사용하여 애플리케이션을 최적화합니다.', 6),
};

Map<String, dynamic> _guide() =>
    json.decode(File('assets/exam_guides/DVA-C03.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('DVA-C03 가이드', () {
    test('메타: 공식 출처와 65문항·720점·130분', () {
      final g = _guide();
      expect(g['code'], 'DVA-C03');
      expect(g['slug'], 'developer-associate-03');
      expect(g['sourceUrl'], contains('/ko_kr/'));
      expect(g['sourceUrl'], contains('developer-associate-03'));
      expect(g['overview'], {
        'level': 'Associate',
        'passingScore': 720,
        'scoredQuestions': 50,
        'unscoredQuestions': 15,
        'durationMinutes': 130,
      });
    });

    test('도메인 이름과 비중이 공식과 같고 합이 100이다', () {
      final domains = _guide()['domains'] as List;
      expect(
        [for (final d in domains) (d['no'], d['name'], d['weightPct'])],
        [
          (1, 'AWS 서비스를 통한 개발', 30),
          (2, '보안', 26),
          (3, '테스트 및 배포', 22),
          (4, '문제 해결 및 최적화', 22),
        ],
      );
    });

    test('작업 12개의 제목과 기술 수가 공식과 같고 기술은 72개다', () {
      final actual = <String, (String, int)>{};
      for (final d in _guide()['domains'] as List) {
        for (final t in d['tasks'] as List) {
          expect(t['knowledge'], isEmpty, reason: '${t['no']}');
          actual[t['no'] as String] = (
            t['title'] as String,
            (t['skills'] as List).length,
          );
        }
      }
      expect(actual, _officialTasks);
      expect(actual.values.fold<int>(0, (a, v) => a + v.$2), 72);
    });

    test('기술 본문에 번호 접두사가 남지 않았고 빈 항목이 없다', () {
      for (final d in _guide()['domains'] as List) {
        for (final t in d['tasks'] as List) {
          for (final s in (t['skills'] as List).cast<String>()) {
            expect(s.trim(), isNotEmpty);
            expect(s, isNot(startsWith('기술 ')), reason: s);
          }
        }
      }
    });
  });

  group('앱 등재', () {
    test('자격증 코드가 DVA-C03 으로 바뀌고 옛 코드는 사라진다', () {
      expect(certByCode('DVA-C03'), isNotNull);
      expect(certByCode('DVA-C02'), isNull);
      expect(File('assets/exam_guides/DVA-C02.json').existsSync(), isFalse);
      expect(kCertLifecycles.containsKey('DVA-C02'), isFalse);
    });

    test('학습문서 12편이 도메인과 함께 등재되고 파일이 실재한다', () {
      final entries = contentFor('DVA-C03');
      expect([for (final e in entries) e.taskId], _taskIds);
      for (final e in entries) {
        expect(e.domain, int.parse(e.taskId[5]), reason: e.taskId);
        expect(e.mdAsset, 'assets/content/dva/${e.taskId}.md');
        expect(File(e.mdAsset).existsSync(), isTrue, reason: e.mdAsset);
      }
    });

    test('등재 제목이 학습문서 프런트매터 제목과 같다', () {
      for (final e in contentFor('DVA-C03')) {
        final title = RegExp(r'^title:\s*(.+?)\s*$', multiLine: true)
            .firstMatch(File(e.mdAsset).readAsStringSync())!
            .group(1)!;
        expect(e.title, title, reason: e.taskId);
      }
    });

    test('요약과 공식 문서 대조일이 새 코드로 있다', () {
      final s = json.decode(File('assets/exam_summaries.json').readAsStringSync())
          as Map<String, dynamic>;
      expect(s.containsKey('DVA-C03'), isTrue);
      expect(s.containsKey('DVA-C02'), isFalse);
      expect(kOfficialDocsAuditDates['DVA-C03'], '2026-11-17');
    });

    test('웹 메타데이터와 noscript 가 DVA-C03 만 적는다', () {
      final html = File('web/index.html').readAsStringSync();
      expect(html, isNot(contains('DVA-C02')));
      expect('DVA-C03'.allMatches(html).length, 2);
    });
  });
}
