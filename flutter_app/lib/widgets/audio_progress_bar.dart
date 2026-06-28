import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 공유 오디오 타임바 — 위치/길이 표시 + 드래그/탭 탐색(seek).
/// 트랜스포트 바·미니플레이어가 함께 쓴다. position/duration은 컨트롤러의
/// ValueListenable을 구독(상태 ChangeNotifier와 분리 — 과리빌드 방지).
/// DESIGN.md: context.c 토큰 · accent 슬라이더.
class AudioProgressBar extends StatefulWidget {
  const AudioProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final ValueListenable<Duration> position;
  final ValueListenable<Duration?> duration;
  final void Function(Duration) onSeek;

  @override
  State<AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<AudioProgressBar> {
  double? _dragMs; // 드래그 중 로컬 값(ms) — 놓을 때만 onSeek

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final timeStyle = TextStyle(
      fontSize: 12,
      color: c.textMuted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return ValueListenableBuilder<Duration?>(
      valueListenable: widget.duration,
      builder: (context, dur, _) => ValueListenableBuilder<Duration>(
        valueListenable: widget.position,
        builder: (context, pos, _) {
          final totalMs = (dur?.inMilliseconds ?? 0).toDouble();
          final hasDur = totalMs > 0;
          final curMs =
              (_dragMs ?? pos.inMilliseconds.toDouble()).clamp(0.0, hasDur ? totalMs : 0.0);
          return Row(
            children: [
              Text(_fmt(Duration(milliseconds: curMs.round())), style: timeStyle),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    activeTrackColor: c.accent,
                    inactiveTrackColor: c.border,
                    thumbColor: c.accent,
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: hasDur ? curMs : 0.0,
                    max: hasDur ? totalMs : 1.0,
                    onChanged:
                        hasDur ? (v) => setState(() => _dragMs = v) : null,
                    onChangeEnd: hasDur
                        ? (v) {
                            widget.onSeek(Duration(milliseconds: v.round()));
                            setState(() => _dragMs = null);
                          }
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: Gap.sm),
              Text(hasDur ? _fmt(dur!) : '--:--', style: timeStyle),
            ],
          );
        },
      ),
    );
  }
}
