/// 자격증 오디오 강의 플레이리스트 — 전역 [AudioController]를 감싸는 단일 소스.
///
/// 오디오 페이지(CertAudioPage)와 학습문서 미니플레이어가 같은 인스턴스를 구독해
/// 화면 전환에도 재생이 끊기지 않는다(주머니 라디오). 트랙 변경은
/// select/next/prev/first/last로만 일어나고, 트랙 종료(ended)는 자동 전환하지
/// 않는다(수동 전환 — iOS 잠금 자동전환 함정 회피).
///
/// 설계: docs/superpowers/specs/2026-06-27-cert-audio-page-design.md
library;

import 'package:flutter/foundation.dart';

import 'audio_controller.dart';
import 'content_index.dart';

class LecturePlaylist extends ChangeNotifier {
  LecturePlaylist({required AudioController controller})
      : _controller = controller {
    _controller.addListener(notifyListeners); // 재생 상태 변화 재방출
  }

  final AudioController _controller;
  List<ContentEntry> _queue = const <ContentEntry>[];
  int _index = 0;
  String _certCode = '';

  List<ContentEntry> get queue => _queue;
  int get index => _index;
  String get certCode => _certCode;
  ContentEntry? get current =>
      (_index >= 0 && _index < _queue.length) ? _queue[_index] : null;
  String? get currentTitle => current?.title;
  PlaybackState get state => _controller.state;
  bool get hasPrev => _index > 0;
  bool get hasNext => _index < _queue.length - 1;

  /// 큐 설정(자동재생 안 함). 같은 cert·같은 트랙 목록이면 위치 보존.
  void setQueue(String certCode, List<ContentEntry> tracks,
      {int startIndex = 0}) {
    if (certCode == _certCode && listEquals(_queue, tracks)) return;
    _queue = tracks;
    _certCode = certCode;
    _index = tracks.isEmpty ? 0 : startIndex.clamp(0, tracks.length - 1);
    notifyListeners();
  }

  /// 학습문서 진입 — 비중단 규칙: idle일 때만 해당 트랙 load(준비). 재생/일시정지
  /// 중이면 컨트롤러를 건드리지 않는다(연속성). 큐 cert만 정합.
  void openDoc(String certCode, String taskId) {
    if (certCode != _certCode) {
      setQueue(certCode, approvedAudioEntries(certCode));
    }
    if (_controller.state == PlaybackState.idle) {
      final i = _queue.indexWhere((e) => e.taskId == taskId);
      if (i >= 0) _index = i;
      final src = current?.lectureAudioSrc;
      if (src != null) _controller.load(src);
      notifyListeners();
    }
  }

  /// 명시적 트랙 변경 — 그 트랙 load 후 play(사용자 제스처 동기 진입).
  /// 같은 트랙 재선택은 처음부터 재시작하지 않는다: 일시정지면 이어재생,
  /// 재생/로딩 중이면 no-op. (idle/ended/error는 재로드 = 정상 재생/재시작.)
  void select(int i) {
    if (_queue.isEmpty) return;
    final target = i.clamp(0, _queue.length - 1);
    if (target == _index &&
        _controller.state != PlaybackState.idle &&
        _controller.state != PlaybackState.ended &&
        _controller.state != PlaybackState.error) {
      if (_controller.state == PlaybackState.paused) _controller.play();
      return;
    }
    _index = target;
    _controller.load(current!.lectureAudioSrc);
    _controller.play();
    notifyListeners();
  }

  void next() {
    if (hasNext) select(_index + 1);
  }

  void prev() {
    if (hasPrev) select(_index - 1);
  }

  void first() {
    if (hasPrev) select(0);
  }

  void last() {
    if (hasNext) select(_queue.length - 1);
  }

  void playPause() {
    if (_controller.state == PlaybackState.playing) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(notifyListeners);
    super.dispose();
  }
}
