import 'package:flutter/material.dart';

import '../data/audio_controller.dart';
import '../theme/app_theme.dart';
import 'focus_ring.dart';

/// 학습 문서 오디오 강의("주머니 라디오") M1 — 하단 고정 미니 플레이어(UI).
///
/// 주입된 [AudioController](전역 싱글톤)의 재생 상태를 구독해 재생/일시정지와
/// 상태 안내를 그린다. DOM `<audio>`/Media Session 부수효과는 controller 뒤에
/// 격리돼 이 위젯은 위젯 테스트로 검증된다(상태별 렌더·버튼 동작).
///
/// DESIGN.md: context.c 토큰만 · InkWell+FocusRing · State Views 보이스 ·
/// 합니다체. 오디오 재생 실패는 페이지 부분 degrade라 wrong 색을 쓰지 않는다
/// (wrong 색은 fatal에만 — DESIGN.md). 검증 메타("✓ 검증됨")와 오디오 메타는
/// 섞지 않는다.
///
/// 노출 정책(M1): 검수 전 생성 강의라 dart-define `audio_lecture` 뒤에서만
/// 진입점이 연결된다(study_doc_page). 출처:
/// docs/superpowers/specs/2026-06-20-study-audio-lecture-review.md (이슈 5-9·8).
class StudyAudioPlayer extends StatefulWidget {
  const StudyAudioPlayer({
    super.key,
    required this.controller,
    required this.title,
    required this.audioSrc,
  });

  /// 전역 오디오 컨트롤러. 이 위젯이 소유하지 않는다 — dispose에서 정리 금지.
  final AudioController controller;

  /// 표시용(그리고 잠금화면 메타용) 문서 식별 제목.
  final String title;

  /// 재생할 합친 오디오 URL(M1은 placeholder 경로, 실제 mp3는 T6).
  final String audioSrc;

  @override
  State<StudyAudioPlayer> createState() => _StudyAudioPlayerState();
}

class _StudyAudioPlayerState extends State<StudyAudioPlayer> {
  @override
  void initState() {
    super.initState();
    // 진입 시 소스만 설정(아직 재생하지 않음). 재생은 사용자가 버튼을 눌러야 —
    // 자동 재생하지 않아 iOS user-activation 진입점을 사용자 제스처로 남긴다.
    widget.controller.load(widget.audioSrc);
  }

  // controller는 전역 싱글톤이라 위젯 dispose에서 정리하지 않는다(재생 유지).

  void _toggle() {
    final controller = widget.controller;
    if (controller.state == PlaybackState.playing) {
      controller.pause();
    } else {
      // await 금지 — backend.play()가 이 동기 진입에서 즉시 호출돼야 iOS
      // user-activation이 보존된다(AudioController.play가 보장).
      controller.play();
    }
  }

  /// 상태별 보조 안내(합니다체 · State Views 보이스). idle은 제목만 보인다.
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
            listenable: widget.controller,
            builder: (context, _) {
              final state = widget.controller.state;
              final isPlaying = state == PlaybackState.playing;
              final status = _statusLine(state);
              return Row(
                children: [
                  _PlayButton(isPlaying: isPlaying, onTap: _toggle),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
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
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isPlaying, required this.onTap});

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
