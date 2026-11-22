import 'package:flutter/material.dart' hide Text;

import '../data/cert_lifecycle.dart';
import '../theme/app_theme.dart';
import '../util/open_link.dart';
import 'badges.dart';
import 'focus_ring.dart';
import 'text.dart';
import 'touch_target.dart';

/// 자격증 카드의 수명 배지. 현행 시험이면 아무것도 그리지 않는다.
class CertLifecycleBadge extends StatelessWidget {
  const CertLifecycleBadge({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final notice = certLifecycleNotice(code);
    if (notice == null) return const SizedBox.shrink();
    final c = context.c;
    return AppBadge(label: notice.badge, bg: c.warningWeak, fg: c.warningText);
  }
}

/// 상세 화면의 수명 안내와 공식 출처 링크.
class CertLifecycleBanner extends StatelessWidget {
  const CertLifecycleBanner({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final notice = certLifecycleNotice(code);
    if (notice == null) return const SizedBox.shrink();
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, Gap.xs),
      decoration: BoxDecoration(
        color: c.warningWeak,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.warning),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notice.badge,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontVariations: Wght.w800,
              color: c.warningText,
            ),
          ),
          const SizedBox(height: Gap.xs),
          Text(notice.message, style: t.bodyMedium?.copyWith(color: c.text)),
          Semantics(
            link: true,
            label: '공식 안내 보기 (새 탭으로 열기)',
            excludeSemantics: true,
            child: TouchTarget(
              key: const ValueKey('cert-lifecycle-link'),
              child: FocusTap(
                radius: Radii.sm,
                onTap: () => openLink(notice.sourceUrl),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Gap.xs,
                    vertical: Gap.xs,
                  ),
                  child: Text(
                    '공식 안내 보기 ↗',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontVariations: Wght.w700,
                      color: c.warningText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
