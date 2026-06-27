import 'package:flutter/material.dart';

import '../data/audio_controller.dart';
import '../data/lecture_playlist.dart';
import '../theme/app_theme.dart';
import 'focus_ring.dart';

/// 학습 문서 오디오 강의("주머니 라디오") — 하단 고정 미니 플레이어(UI).
///
/// 전역 [LecturePlaylist]의 현재 트랙 제목·재생 상태를 구독해 재생/일시정지와
/// 상태 안내를 그린다. 로딩(트랙 load)은 호출부(study_doc_page의 openDoc /
/// CertAudioPage의 select) 책임 — 이 위젯은 표시·토글만 한다.
///
/// DESIGN.md: context.c 토큰만 · InkWell+FocusRing · State Views 보이스 ·
/// 합니다체. 오디오 실패는 부분 degrade라 wrong 색을 쓰지 않는다.
class StudyAudioPlayer extends StatelessWidget {
  const StudyAudioPlayer({super.key, required this.playlist});

  /// 전역 플레이리스트(소유하지 않음 — dispose에서 정리 금지).
  final LecturePlaylist playlist;

  String? _statusLine(PlaybackState s) => switch (s) {
        PlaybackState.loading => '오디오를 준비하고 있습니다…',
        PlaybackState.error => '오디오를 재생하지 못했습니다.',
        PlaybackState.playing => '재생 중입니다.',
        PlaybackState.paused => '일시정지했습니다.',
        PlaybackState.ended => '재생을 마쳤습니다.',
        PlaybackState.idle => null,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
          child: ListenableBuilder(
            listenable: playlist,
            builder: (context, _) {
              final state = playlist.state;
              final isPlaying = state == PlaybackState.playing;
              final status = _statusLine(state);
              return Row(
                children: [
                  PlayPauseButton(
                      isPlaying: isPlaying, onTap: playlist.playPause),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.currentTitle ?? '오디오 강의',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontVariations: Wght.w700,
                            color: c.text,
                          ),
                        ),
                        if (status != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              fontVariations: Wght.w400,
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 재생/일시정지 토글 — 액센트 원형 아이콘 버튼(InkWell+FocusRing, DESIGN.md).
/// 트랜스포트 바와 공유한다.
class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, required this.isPlaying, required this.onTap});

  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: Material(
        color: c.accent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: c.onAccent,
                size: 24,
                semanticLabel: isPlaying ? '일시정지' : '재생',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
