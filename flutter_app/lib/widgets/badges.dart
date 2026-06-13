import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 둥근 배지 프리미티브(12px·full 반경) — DESIGN.md 배지 체계의 공통 셸.
/// '✓ 검증됨'(correct), '오답 N'(wrong), '검증 문항 N'(correct),
/// 요약 라벨(surface2/muted) 등이 home·cert_detail·study_doc·review에서
/// 같은 레시피로 반복되어 승격(PR4 T7 — 승격 규칙: 2+ 페이지 사용 충족).
/// 색·굵기는 호출부가 토큰으로 주입한다(시맨틱은 페이지가 결정).
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.strong = true,
    this.vPad = 4,
  });

  final String label;
  final Color bg;
  final Color fg;

  /// true=w800(기본, 수치 배지) / false=w700(보조 칩).
  final bool strong;

  /// 세로 패딩 — 기존 인스턴스가 3(밀집 행)과 4(독립 배지)를 혼용해 보존.
  final double vPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: vPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.full),
      ),
      child: Text(label,
          style: strong
              ? TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                  color: fg)
              : TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                  color: fg)),
    );
  }
}
