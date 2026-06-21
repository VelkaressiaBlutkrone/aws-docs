import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_controller.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/widgets/study_audio_player.dart';

/// 주입용 가짜 백엔드 — DOM <audio> 없이 미니 플레이어의 상태별 렌더/동작만 검증.
/// 실제 백엔드(WebAudioBackend)는 실기기 게이트(T6). (audio_controller_test 패턴)
class FakeAudioBackend implements AudioBackend {
  final _events = StreamController<AudioEvent>.broadcast();
  String? src;
  int playCalls = 0;
  int pauseCalls = 0;
  bool disposed = false;

  @override
  Stream<AudioEvent> get events => _events.stream;
  @override
  void setSrc(String s) => src = s;
  @override
  Future<void> play() async => playCalls++;
  @override
  void pause() => pauseCalls++;
  @override
  void dispose() {
    disposed = true;
    _events.close();
  }

  /// 브라우저 미디어 이벤트 발화 모사.
  void emit(AudioEvent e) => _events.add(e);
}

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('진입 시 audioSrc를 load한다 (src 설정 + loading 전이)',
      (tester) async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    await tester.pumpWidget(_host(StudyAudioPlayer(
      controller: c,
      title: 'CLF-C02 · 도메인 1',
      audioSrc: 'assets/audio/clf/clf-t1-1/lecture.mp3',
    )));
    expect(b.src, 'assets/audio/clf/clf-t1-1/lecture.mp3');
    expect(c.state, PlaybackState.loading);
  });

  testWidgets('문서 제목을 표시한다', (tester) async {
    final c = AudioController(backend: FakeAudioBackend());
    await tester.pumpWidget(_host(StudyAudioPlayer(
      controller: c,
      title: 'CLF-C02 · 도메인 1',
      audioSrc: 'x.mp3',
    )));
    expect(find.text('CLF-C02 · 도메인 1'), findsOneWidget);
  });

  testWidgets('정지 상태에서 재생 버튼(play_arrow)을 보인다', (tester) async {
    final c = AudioController(backend: FakeAudioBackend());
    await tester.pumpWidget(_host(StudyAudioPlayer(
      controller: c,
      title: 't',
      audioSrc: 'x.mp3',
    )));
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsNothing);
  });

  testWidgets('재생 버튼을 누르면 재생을 시작한다 (controller.play)', (tester) async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    await tester.pumpWidget(_host(StudyAudioPlayer(
      controller: c,
      title: 't',
      audioSrc: 'x.mp3',
    )));
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(b.playCalls, 1);
  });

  testWidgets('재생 중에는 일시정지 버튼(pause)으로 바뀐다', (tester) async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    await tester.pumpWidget(_host(StudyAudioPlayer(
      controller: c,
      title: 't',
      audioSrc: 'x.mp3',
    )));
    b.emit(AudioEvent.playing);
    await tester.pump(); // stream 이벤트 전파(마이크로태스크) + notifyListeners
    await tester.pump(); // 리빌드 반영
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });

  testWidgets('재생 중 일시정지 버튼을 누르면 일시정지한다 (controller.pause)',
      (tester) async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    await tester.pumpWidget(_host(StudyAudioPlayer(
      controller: c,
      title: 't',
      audioSrc: 'x.mp3',
    )));
    b.emit(AudioEvent.playing);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byIcon(Icons.pause));
    expect(b.pauseCalls, 1);
  });

  testWidgets('loading 상태에서 준비 중 안내를 보인다 (합니다체)', (tester) async {
    final c = AudioController(backend: FakeAudioBackend());
    await tester.pumpWidget(_host(StudyAudioPlayer(
      controller: c,
      title: 't',
      audioSrc: 'x.mp3',
    )));
    // initState의 load()로 이미 loading 상태.
    expect(find.text('오디오를 준비하고 있습니다…'), findsOneWidget);
  });

  testWidgets('error 상태에서 실패 안내를 보인다 (합니다체)', (tester) async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    await tester.pumpWidget(_host(StudyAudioPlayer(
      controller: c,
      title: 't',
      audioSrc: 'x.mp3',
    )));
    b.emit(AudioEvent.error);
    await tester.pump();
    await tester.pump();
    expect(find.text('오디오를 재생하지 못했습니다.'), findsOneWidget);
  });

  testWidgets('위젯 dispose가 전역 controller를 dispose하지 않는다 (싱글톤 유지)',
      (tester) async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    await tester.pumpWidget(_host(StudyAudioPlayer(
      controller: c,
      title: 't',
      audioSrc: 'x.mp3',
    )));
    // 미니 플레이어 위젯 제거(라우팅 이탈 모사).
    await tester.pumpWidget(_host(const SizedBox.shrink()));
    expect(b.disposed, isFalse); // 전역 controller는 살아있어야 한다
    // controller가 여전히 이벤트를 받아 동작한다.
    b.emit(AudioEvent.playing);
    await tester.pump();
    expect(c.state, PlaybackState.playing);
  });
}
