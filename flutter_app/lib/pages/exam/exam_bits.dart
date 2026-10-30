import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/focus_ring.dart';

/// 시험 러너가 쓰는 소형 위젯(분해 — exam_page.dart에서 이동. 분할 전에는
/// `_GridChip`·`_SecondaryButton`이었다). ExamView 전용이라 lib/widgets/ 승격
/// 대상이 아니다(승격 규칙: 2+ 페이지).

/// 좁은 화면 판정 폭(UX-1). 홈 헤더의 compact 분기와 같은 값을 쓴다.
///
/// `ExamView`는 네 호출부 전부 `ConstrainedBox(maxWidth: Layout.exam = 768)` 안에 있으므로
/// 러너 안의 `LayoutBuilder`는 데스크톱에서 정확히 768을, 그 아래에서는 실제 폭을 본다
/// — 그래서 `< examCompactBreakpoint`가 "모바일"과 같은 뜻이 된다.
const double examCompactBreakpoint = 768.0;

/// 접힌 그리드를 대신하는 한 줄 요약(UX-1). 플래그가 없으면 그 절을 적지 않는다 —
/// "플래그 0"은 알려 주는 것이 없고 소음만 된다. 미답 0은 정직하게 적는다(다 풀었다는 신호).
String examGridSummaryLabel({
  required int index,
  required int total,
  required int answered,
  required int flagged,
}) {
  final unanswered = total - answered;
  final base = '${index + 1} / $total · 미답 $unanswered';
  return flagged > 0 ? '$base · 플래그 $flagged' : base;
}

/// 접힌 문항 그리드의 손잡이 — 진행 요약을 보이고 탭하면 그리드를 펼친다.
class ExamGridSummaryChip extends StatelessWidget {
  const ExamGridSummaryChip({
    super.key,
    required this.label,
    required this.expanded,
    required this.onTap,
  });
  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // 칩이므로 full radius(DESIGN.md Layout — 칩·배지만 full). 높이는 러너의
    // 다른 컨트롤(SecondaryButton 44)과 맞춰 한 행에 섰을 때 기준선이 어긋나지 않게.
    return InsetFocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.full),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(Radii.full),
            border: Border.all(color: c.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.monoFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontVariations: Wght.w700,
                    color: c.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: Gap.xs),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: c.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
