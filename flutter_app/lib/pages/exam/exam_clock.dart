import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 시험 러너의 남은 시간 표시. **1초 타이머를 이 위젯이 소유해** 매초 리빌드되는
/// 범위를 시계로 좁힌다(리뷰 m-2) — 전에는 러너가 `setState(() {})`로 문항 그리드
/// 65칩·선택지·버튼까지 매초 다시 그렸다.
///
/// 만료는 [onExpired]로 **한 번만** 통지하고(자동 제출의 트리거) 그 뒤 타이머를
/// 멈춘다. 이미 만료된 상태로 마운트되면 첫 프레임 뒤에 통지한다 — 자동 제출이
/// build 중에 상위 상태를 바꾸지 않도록.
class ExamClock extends StatefulWidget {
  const ExamClock({
    super.key,
    required this.startedAt,
    required this.durationSec,
    this.now,
    this.onExpired,
  });

  final DateTime startedAt;
  final int durationSec;

  /// 테스트 주입용 시계. 기본은 `DateTime.now`.
  final DateTime Function()? now;

  /// 남은 시간이 0이 된 순간 1회 호출.
  final VoidCallback? onExpired;

  @override
  State<ExamClock> createState() => _ExamClockState();
}

class _ExamClockState extends State<ExamClock> {
  Timer? _ticker;
  bool _notified = false;

  DateTime _clock() => (widget.now ?? DateTime.now)();

  int get _remainingSec {
    final elapsed = _clock().difference(widget.startedAt).inSeconds;
    final left = widget.durationSec - elapsed;
    return left < 0 ? 0 : left;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_remainingSec <= 0) {
        _expire();
        return;
      }
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_remainingSec <= 0) {
          _expire();
        } else {
          setState(() {}); // 시계 텍스트만 — 리빌드 범위가 이 위젯이다
        }
      });
    });
  }

  void _expire() {
    _ticker?.cancel();
    _ticker = null;
    if (_notified) return;
    _notified = true;
    if (mounted) setState(() {}); // 00:00 반영
    widget.onExpired?.call();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _mmss(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final remaining = _remainingSec;
    final low = remaining <= (widget.durationSec * 0.1).ceil();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 18,
          color: low ? c.warning : c.textMuted,
        ),
        const SizedBox(width: Gap.xs),
        Text(
          _mmss(remaining),
          style: TextStyle(
            fontFamily: AppTheme.monoFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontVariations: Wght.w700,
            color: low ? c.warningText : c.text,
          ),
        ),
      ],
    );
  }
}
