import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/focus_ring.dart';

/// 시험 러너가 쓰는 소형 위젯(분해 — exam_page.dart에서 이동. 분할 전에는
/// `_GridChip`·`_SecondaryButton`이었다). ExamView 전용이라 lib/widgets/ 승격
/// 대상이 아니다(승격 규칙: 2+ 페이지).

/// 문항 번호 그리드의 칩 — 응답/플래그/현재 문항 상태를 테두리와 색으로 보인다.
class GridChip extends StatelessWidget {
  const GridChip({
    super.key,
    required this.label,
    required this.answered,
    required this.flagged,
    required this.current,
    required this.onTap,
  });
  final String label;
  final bool answered;
  final bool flagged;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // 인셋 링(DT4): 34px 밀집 그리드라 바깥 링(4px)은 간격을 깨뜨린다.
    return InsetFocusRing(
      borderRadius: BorderRadius.circular(Radii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: answered ? c.accentWeak : c.surface,
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(
              color: current ? c.accent : (flagged ? c.warning : c.border),
              width: current ? 2 : 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.monoFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontVariations: Wght.w700,
                  color: answered ? c.accentStrong : c.textMuted,
                ),
              ),
              if (flagged)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Icon(Icons.flag, size: 11, color: c.warning),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 시험 하단 보조 버튼(이전·플래그) — active면 warning 톤으로 전환.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // 인셋 링(DT4): 플래그·이전 버튼 — Tab으로 닿고 Enter/Space로 동작.
    return InsetFocusRing(
      borderRadius: BorderRadius.circular(Radii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: Gap.md),
          decoration: BoxDecoration(
            color: active ? c.warningWeak : c.surface,
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(color: active ? c.warning : c.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: active ? c.warning : c.textMuted),
              const SizedBox(width: Gap.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontVariations: Wght.w700,
                  color: active ? c.warning : c.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
