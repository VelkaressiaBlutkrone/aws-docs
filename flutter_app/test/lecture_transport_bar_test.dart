import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_controller.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/lecture_playlist.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/widgets/lecture_transport_bar.dart';

class _Fake implements AudioBackend {
  final _ev = StreamController<AudioEvent>.broadcast();
  int playCalls = 0;
  String? src;
  @override
  Stream<AudioEvent> get events => _ev.stream;
  @override
  void setSrc(String s) => src = s;
  @override
  Future<void> play() async => playCalls++;
  @override
  void pause() {}
  @override
  void dispose() => _ev.close();
  @override
  void seek(double seconds) {}
  @override
  Stream<Duration> get positionStream => const Stream<Duration>.empty();
  @override
  Duration? get duration => null;
}

ContentEntry _e(String t) => ContentEntry(
    certCode: 'CLF-C02', taskId: t, title: 'T $t', domain: 1,
    mdAsset: 'a', questionsAsset: 'b', questionCount: 0, audioApproved: true);

Future<LecturePlaylist> _pump(WidgetTester tester, {int start = 0}) async {
  final pl = LecturePlaylist(controller: AudioController(backend: _Fake()));
  pl.setQueue('CLF-C02', [_e('clf-t1-1'), _e('clf-t1-2'), _e('clf-t1-3')],
      startIndex: start);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(bottomNavigationBar: LectureTransportBar(playlist: pl)),
  ));
  return pl;
}

void main() {
  testWidgets('다음 버튼 탭이 index를 증가시킨다', (tester) async {
    final pl = await _pump(tester);
    await tester.tap(find.bySemanticsLabel('다음 강의'));
    await tester.pump();
    expect(pl.index, 1);
  });

  testWidgets('마지막 버튼 탭이 마지막 트랙으로 점프', (tester) async {
    final pl = await _pump(tester);
    await tester.tap(find.bySemanticsLabel('마지막 강의'));
    await tester.pump();
    expect(pl.index, 2);
  });

  testWidgets('처음 트랙에선 이전 탭이 no-op', (tester) async {
    final pl = await _pump(tester, start: 0);
    await tester.tap(find.bySemanticsLabel('이전 강의'));
    await tester.pump();
    expect(pl.index, 0);
  });

  testWidgets('처음 트랙에선 처음 탭이 no-op', (tester) async {
    final pl = await _pump(tester, start: 0);
    await tester.tap(find.bySemanticsLabel('처음 강의'));
    await tester.pump();
    expect(pl.index, 0);
  });

  testWidgets('마지막 트랙에선 다음·마지막 탭이 no-op', (tester) async {
    final pl = await _pump(tester, start: 2);
    await tester.tap(find.bySemanticsLabel('다음 강의'));
    await tester.pump();
    expect(pl.index, 2);
    await tester.tap(find.bySemanticsLabel('마지막 강의'));
    await tester.pump();
    expect(pl.index, 2);
  });
}
