import 'package:flutter/material.dart';

import '../data/audio_controller.dart';
import '../data/lecture_playlist.dart';
import '../theme/app_theme.dart';
import 'focus_ring.dart';
import 'study_audio_player.dart' show PlayPauseButton;

/// 자격증 오디오 페이지 하단 고정 트랜스포트(A안). 좌→우: 처음·이전·재생/정지·
/// 다음·마지막 + 현재 트랙 제목·상태. 경계(첫/끝)에선 해당 버튼 muted+no-op.
/// DESIGN.md: context.c 토큰 · InkWell+FocusRing · 합니다체 · disabled 회피(muted).
class LectureTransportBar extends StatelessWidget {
  const LectureTransportBar({super.key, required this.playlist});

  final LecturePlaylist playlist;

  String? _statusLine(PlaybackState s) => switch (s) {
        PlaybackState.loading => '오디오를 준비하고 있습니다…',
        PlaybackState.error => '오디오를 재생하지 못했습니다.',
        PlaybackState.playing => '재생 중입니다.',
        PlaybackState.paused => '일시정지했습니다.',
        PlaybackState.ended => '재생을 마쳤습니다. 다음 강의를 들어 보세요.',
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
              final isPlaying = playlist.state == PlaybackState.playing;
              final status = _statusLine(playlist.state);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StepButton(
                        icon: Icons.skip_previous,
                        semantic: '처음 강의',
                        enabled: playlist.hasPrev,
                        onTap: playlist.first,
                      ),
                      const SizedBox(width: Gap.sm),
                      _StepButton(
                        icon: Icons.fast_rewind,
                        semantic: '이전 강의',
                        enabled: playlist.hasPrev,
                        onTap: playlist.prev,
                      ),
                      const SizedBox(width: Gap.md),
                      PlayPauseButton(
                          isPlaying: isPlaying, onTap: playlist.playPause),
                      const SizedBox(width: Gap.md),
                      _StepButton(
                        icon: Icons.fast_forward,
                        semantic: '다음 강의',
                        enabled: playlist.hasNext,
                        onTap: playlist.next,
                      ),
                      const SizedBox(width: Gap.sm),
                      _StepButton(
                        icon: Icons.skip_next,
                        semantic: '마지막 강의',
                        enabled: playlist.hasNext,
                        onTap: playlist.last,
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  Text(
                    playlist.currentTitle ?? '오디오 강의',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
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
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 트랜스포트 보조 버튼 — enabled=false면 muted 색·탭 무반응(disabled 위젯 회피).
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.semantic,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String semantic;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: Tooltip(
        message: semantic,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(Radii.full),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(Radii.full),
              border: Border.all(color: c.border),
            ),
            child: Icon(
              icon,
              size: 22,
              color: enabled ? c.textMuted : c.textFaint,
              semanticLabel: semantic,
            ),
          ),
        ),
      ),
    );
  }
}
