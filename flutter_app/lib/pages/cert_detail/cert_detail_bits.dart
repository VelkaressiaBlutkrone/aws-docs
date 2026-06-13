import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// cert_detail 섹션들이 공유하는 소형 위젯(PR4 분해 — cert_detail_page.dart에서
/// 이동). 페이지 전용이라 lib/widgets/ 승격 대상이 아니다(승격 규칙: 2+ 페이지).

class Bullet extends StatelessWidget {
  const Bullet(this.text, {super.key, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 10),
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, height: 1.6, color: c.text),
            ),
          ),
        ],
      ),
    );
  }
}

class SubLabel extends StatelessWidget {
  const SubLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800, fontVariations: Wght.w800,
        letterSpacing: 0.6,
        color: c.textFaint,
      ),
    );
  }
}

/// 자격증 코드 모노 필 — 페이지 헤더 titleLeading과 본문이 함께 쓴다.
class CodePill extends StatelessWidget {
  const CodePill(this.code, {super.key});
  final String code;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.full),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: AppTheme.monoFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700, fontVariations: Wght.w700,
          color: c.textMuted,
        ),
      ),
    );
  }
}

class WeightPill extends StatelessWidget {
  const WeightPill(this.pct, {super.key});
  final int pct;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.accentWeak,
        borderRadius: BorderRadius.circular(Radii.full),
      ),
      child: Text(
        '$pct%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800, fontVariations: Wght.w800,
          color: c.accentStrong,
        ),
      ),
    );
  }
}

class FactPill extends StatelessWidget {
  const FactPill(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.full),
        border: Border.all(color: c.borderStrong),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700, fontVariations: Wght.w700,
          color: c.textMuted,
        ),
      ),
    );
  }
}
