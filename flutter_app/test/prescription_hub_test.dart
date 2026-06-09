import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/prescription_hub.dart';
import 'package:aws_docs/theme/app_theme.dart';

Widget _host(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('해제 시 약점 집중 모의고사 링크 노출 + 탭 발화', (tester) async {
    var weak = 0;
    await tester.pumpWidget(_host(PrescriptionHub(
      onReview: () {},
      onReport: () {},
      onWeightedExam: () => weak++,
      weightedAttemptCount: 5,
    )));
    expect(find.text('약점 집중 모의고사 →'), findsOneWidget);
    await tester.tap(find.text('약점 집중 모의고사 →'));
    expect(weak, 1);
  });

  testWidgets('잠김 시 응시 N/3 안내 + 비활성, 12→3 clamp', (tester) async {
    await tester.pumpWidget(_host(const PrescriptionHub(
      onReview: _noop,
      onReport: _noop,
      onWeightedExam: null,
      weightedAttemptCount: 12,
    )));
    expect(find.text('약점 집중 모의고사 · 응시 3/3'), findsOneWidget); // clamp
    expect(find.text('약점 집중 모의고사 →'), findsNothing); // 비활성
  });

  testWidgets('오답 복습/약점 리포트 탭 발화 + 만점 노트', (tester) async {
    var review = 0;
    var report = 0;
    await tester.pumpWidget(_host(PrescriptionHub(
      onReview: () => review++,
      onReport: () => report++,
      onWeightedExam: () {},
      weightedAttemptCount: 3,
      allCorrect: true,
    )));
    expect(find.text('이번 회차 오답 없음 — 좋아요.'), findsOneWidget);
    await tester.tap(find.text('오답 복습'));
    await tester.tap(find.text('약점 리포트 →'));
    expect(review, 1);
    expect(report, 1);
  });

  testWidgets('만점 아니면 오답 없음 노트 비표시', (tester) async {
    await tester.pumpWidget(_host(const PrescriptionHub(
      onReview: _noop,
      onReport: _noop,
      onWeightedExam: _noop,
      weightedAttemptCount: 3,
    )));
    expect(find.text('이번 회차 오답 없음 — 좋아요.'), findsNothing);
  });
}

void _noop() {}
