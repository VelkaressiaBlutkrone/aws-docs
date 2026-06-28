import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_controller.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/lecture_playlist.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/widgets/study_audio_player.dart';

class _Fake implements AudioBackend {
  final _ev = StreamController<AudioEvent>.broadcast();
  int playCalls = 0;
  int pauseCalls = 0;
  @override
  Stream<AudioEvent> get events => _ev.stream;
  @override
  void setSrc(String s) {}
  @override
  Future<void> play() async => playCalls++;
  @override
  void pause() => pauseCalls++;
  @override
  void dispose() => _ev.close();
  @override
  void seek(double seconds) {}
  @override
  Stream<Duration> get positionStream => const Stream<Duration>.empty();
  @override
  Duration? get duration => null;
  void emit(AudioEvent e) => _ev.add(e);
}

ContentEntry _e(String t) => ContentEntry(
    certCode: 'CLF-C02', taskId: t, title: 'T $t', domain: 1,
    mdAsset: 'a', questionsAsset: 'b', questionCount: 0, audioApproved: true);

Future<LecturePlaylist> _pump(WidgetTester tester, _Fake fake) async {
  final pl = LecturePlaylist(controller: AudioController(backend: fake));
  pl.setQueue('CLF-C02', [_e('clf-t1-1'), _e('clf-t1-2')]);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(bottomNavigationBar: StudyAudioPlayer(playlist: pl)),
  ));
  return pl;
}

void main() {
  testWidgets('현재 트랙 제목을 표시한다', (tester) async {
    final fake = _Fake();
    final pl = await _pump(tester, fake);
    pl.select(1);
    await tester.pump();
    expect(find.text('T clf-t1-2'), findsOneWidget);
  });

  testWidgets('재생 버튼 탭이 playlist.playPause 경유로 backend.play 호출', (tester) async {
    final fake = _Fake();
    await _pump(tester, fake);
    await tester.tap(find.bySemanticsLabel('재생'));
    await tester.pump();
    expect(fake.playCalls, 1);
  });

  testWidgets('playing 상태면 일시정지 시맨틱·탭 시 pause', (tester) async {
    final fake = _Fake();
    await _pump(tester, fake);
    fake.emit(AudioEvent.playing);
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('일시정지'));
    await tester.pump();
    expect(fake.pauseCalls, 1);
  });
}
