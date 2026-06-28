import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/widgets/audio_progress_bar.dart';

Future<void> _pump(WidgetTester tester,
    {required Duration pos, Duration? dur, void Function(Duration)? onSeek}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: AudioProgressBar(
            position: ValueNotifier<Duration>(pos),
            duration: ValueNotifier<Duration?>(dur),
            onSeek: onSeek ?? (_) {},
          ),
        ),
      ),
    ),
  ));
}

void main() {
  testWidgets('위치·길이를 mm:ss로 표시', (tester) async {
    await _pump(tester,
        pos: const Duration(seconds: 30), dur: const Duration(seconds: 125));
    expect(find.text('0:30'), findsOneWidget);
    expect(find.text('2:05'), findsOneWidget);
  });

  testWidgets('duration null이면 총 시간 --:--', (tester) async {
    await _pump(tester, pos: Duration.zero, dur: null);
    expect(find.text('--:--'), findsOneWidget);
  });

  testWidgets('슬라이더 드래그 종료 시 onSeek 호출', (tester) async {
    Duration? seeked;
    await _pump(tester,
        pos: Duration.zero,
        dur: const Duration(seconds: 100),
        onSeek: (d) => seeked = d);
    await tester.drag(find.byType(Slider), const Offset(80, 0));
    await tester.pump();
    expect(seeked, isNotNull);
  });
}
