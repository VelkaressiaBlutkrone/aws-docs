import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/content/quiz_widgets.dart';
import 'package:aws_docs/pages/exam/exam_bits.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// 리뷰 M-7 — 커스텀 인터랙티브 위젯이 선택 상태·문항 번호 의미를 노출하지 않아
/// 스크린리더에는 `OptionTile`이 "텍스트, 버튼"으로만, `GridChip`이 숫자로만
/// 읽혔다. 색(선택·플래그·답변 여부)으로만 전달되던 정보를 semantics에 담는다.
///
/// 정본: `docs/audits/2026-09-22-app-code-ux-review.md` M-7.

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  // ⚠️ `ensureSemantics()`의 핸들은 **테스트 본문 안에서** dispose해야 한다 —
  // `addTearDown`에 맡기면 프레임워크의 종료 검증이 먼저 돌아 "SemanticsHandle이
  // 살아 있다"로 실패한다(실측).
  testWidgets('OptionTile이 선택 상태를 배타 그룹으로 노출한다', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_host(Column(children: [
      OptionTile(
          text: '필요한 권한만',
          selected: true,
          state: OptState.idle,
          onTap: () {}),
      OptionTile(
          text: '관리자 먼저',
          selected: false,
          state: OptState.idle,
          onTap: () {}),
    ])));

    // ⚠️ `getSemantics(find.byType(OptionTile))`는 **조상** 노드(루트)를 집는다 —
    // 선택지의 semantics 노드는 위젯 안쪽(InsetFocusRing 아래)에 있으므로
    // 지문 텍스트를 앵커로 쓴다(`excludeSemantics`라 Text 자체 노드는 없다).
    expect(
      tester.getSemantics(find.text('필요한 권한만')),
      containsSemantics(
        label: '필요한 권한만',
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        isButton: true,
        hasTapAction: true,
      ),
      reason: '선택이 색으로만 전달되면 스크린리더 사용자는 무엇을 골랐는지 알 수 없다',
    );

    expect(
      tester.getSemantics(find.text('관리자 먼저')),
      containsSemantics(label: '관리자 먼저', isSelected: false),
    );
    handle.dispose();
  });

  testWidgets('채점 뒤에는 정답·오답을 라벨에 담는다', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_host(Column(children: [
      OptionTile(
          text: '계정 해지', selected: false, state: OptState.correct, onTap: null),
      OptionTile(
          text: 'EC2 시작', selected: true, state: OptState.wrong, onTap: null),
    ])));

    expect(tester.getSemantics(find.text('계정 해지')),
        containsSemantics(label: '계정 해지, 정답'));
    expect(tester.getSemantics(find.text('EC2 시작')),
        containsSemantics(label: 'EC2 시작, 오답'));
    handle.dispose();
  });

  testWidgets('GridChip이 문항 번호·답변 여부·플래그를 읽어 준다', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_host(Row(children: [
      GridChip(
          label: '3',
          answered: true,
          flagged: true,
          current: false,
          onTap: () {}),
      GridChip(
          label: '4',
          answered: false,
          flagged: false,
          current: true,
          onTap: () {}),
    ])));

    expect(
      tester.getSemantics(find.byType(GridChip).first),
      containsSemantics(
        label: '문항 3, 답변함, 플래그',
        isButton: true,
        hasTapAction: true,
      ),
      reason: '숫자만 읽히면 답변 여부·플래그가 색으로만 남는다',
    );

    expect(tester.getSemantics(find.byType(GridChip).last),
        containsSemantics(label: '문항 4, 미답, 현재 문항'));
    handle.dispose();
  });
}
