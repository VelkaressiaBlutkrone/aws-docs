import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/content_audit.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/models/exam_guide.dart';
import 'package:aws_docs/pages/cert_detail/official_guide_section.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// 상세 화면의 가이드 버전·대조일 표시 가드(외부 리뷰 후속 §5-1).
///
/// ⚠️ 버전은 **공식 한국어 개정 페이지**의 값이다. 앱의 가이드 본문이 한국어 판의
/// 전사이므로, 영문 판이 더 높아도(SOA·AIF 1.2) 그 번호를 적으면 본문과 어긋난다.
/// 한국어 개정 페이지가 없는 자격증은 버전을 적지 않는다.
const _koreanGuideVersions = {
  'SOA-C03': ('1.1', '2026-06-01'),
  'DEA-C01': ('1.1', '2025-12-12'),
  'AIF-C01': ('1.1', '2026-04-30'),
  'SCS-C03': ('1.0', '2026-03-26'),
};

Map<String, dynamic> _rawGuide(String code) =>
    json.decode(File('assets/exam_guides/$code.json').readAsStringSync())
        as Map<String, dynamic>;

ExamGuide _guide(String code, {String? version, String? published}) => ExamGuide(
  code: code,
  overview: const ExamOverview(
    level: null,
    passingScore: null,
    scoredQuestions: null,
    unscoredQuestions: null,
    durationMinutes: null,
  ),
  domains: const [],
  sourceUrl: 'https://example.test',
  guideVersion: version,
  guidePublished: published,
);

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('모델', () {
    test('guideVersion·guidePublished 를 읽는다', () {
      final g = ExamGuide.fromJson(_rawGuide('SOA-C03'));
      expect(g.guideVersion, '1.1');
      expect(g.guidePublished, '2026-06-01');
    });

    test('필드가 없으면 null 이다', () {
      final g = ExamGuide.fromJson(_rawGuide('CLF-C02'));
      expect(g.guideVersion, isNull);
      expect(g.guidePublished, isNull);
    });
  });

  group('가이드 JSON', () {
    final codes = [
      // 로컬 도구 폴더(.omc)가 끼어도 세지 않도록 JSON 파일만 본다.
      for (final f in Directory('assets/exam_guides').listSync())
        if (f is File && f.path.endsWith('.json'))
          f.uri.pathSegments.last.replaceAll('.json', ''),
    ];

    test('대조군: 가이드 파일을 실제로 읽었다', () {
      expect(codes, containsAll(_koreanGuideVersions.keys));
      expect(codes.length, greaterThan(_koreanGuideVersions.length));
    });

    test('한국어 개정 페이지가 있는 자격증만 버전을 갖고 값이 공식과 같다', () {
      for (final code in codes) {
        final raw = _rawGuide(code);
        final want = _koreanGuideVersions[code];
        expect(raw['guideVersion'], want?.$1, reason: code);
        expect(raw['guidePublished'], want?.$2, reason: code);
      }
    });
  });

  group('대조일', () {
    test('학습 콘텐츠가 등재된 자격증 전부에 대조일이 있다', () {
      expect(kOfficialDocsAuditDates.keys.toSet(), kContentIndex.keys.toSet());
    });

    test('표시 문구: 버전이 있으면 버전·게시일·대조일을 함께 적는다', () {
      expect(
        guideProvenance(
          _guide('SOA-C03', version: '1.1', published: '2026-06-01'),
        ),
        '공식 한국어 가이드 버전 1.1 · 게시 2026-06-01 · '
        '공식 문서 전수 대조 ${kOfficialDocsAuditDates['SOA-C03']}',
      );
    });

    test('표시 문구: 버전이 없으면 대조일만 적는다', () {
      expect(
        guideProvenance(_guide('CLF-C02')),
        '공식 문서 전수 대조 ${kOfficialDocsAuditDates['CLF-C02']}',
      );
    });

    test('표시 문구: 콘텐츠가 없는 자격증은 적을 것이 없다', () {
      expect(guideProvenance(_guide('SAP-C02')), isNull);
    });
  });

  group('화면', () {
    testWidgets('버전과 대조일을 공식 가이드 절에 보여 준다', (tester) async {
      final g = _guide('SOA-C03', version: '1.1', published: '2026-06-01');
      await tester.pumpWidget(_host(OfficialGuideSection(guide: g)));
      expect(find.text(guideProvenance(g)!), findsOneWidget);
    });

    testWidgets('콘텐츠가 없는 자격증에는 그 줄이 없다', (tester) async {
      await tester.pumpWidget(
        _host(OfficialGuideSection(guide: _guide('SAP-C02'))),
      );
      expect(find.textContaining('전수 대조'), findsNothing);
      expect(find.textContaining('가이드 버전'), findsNothing);
    });
  });
}
