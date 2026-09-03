import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/content_index.dart';
import '../../data/history_store.dart';
import '../../data/site_data.dart';
import '../../data/weighted_exam.dart';
import '../../theme/app_theme.dart';
import '../../widgets/focus_ring.dart';
import 'content_cert_card.dart';
import 'home_bits.dart';

/// 학습 문서 기반 모의고사 섹션(PR4 분해 — home_page.dart에서 이동).
class ExamsSection extends StatelessWidget {
  const ExamsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final history = HistoryStore().all();
    final examCerts = certifications
        .where((cert) => certHasContent(cert.code))
        .toList();
    final weakCerts = examCerts
        .where((cert) => certHasVerifiedQuestions(cert.code))
        .toList();
    final pending = certifications
        .where((cert) => !certHasContent(cert.code))
        .toList();
    return HomeBand(
      title: '학습 문서 기반 모의고사',
      meta: '검증 문항 기반',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Gap.lg,
            runSpacing: Gap.lg,
            children: [
              for (final cert in examCerts)
                () {
                  final ready = certExamHasWeightedCapacity(cert.code);
                  return ContentCertCard(
                    cert: cert,
                    summaryLabel: ready
                        ? '통합 모의고사 · 검증 ${certContentSummary(cert.code).questions}문항'
                        : '통합 모의고사 · 준비 중',
                    cta: ready ? '모의고사 →' : '검증 문항 보강 중',
                    onTap: ready
                        ? () => context.push('/cert/${cert.code}/exam')
                        : null,
                  );
                }(),
            ],
          ),
          if (weakCerts.isNotEmpty) ...[
            const SizedBox(height: Gap.lg),
            for (final cert in weakCerts)
              () {
                final hasCapacity = certExamHasWeightedCapacity(cert.code);
                final unlocked = certWeightedExamUnlocked(cert.code, history);
                final attempts = nonReviewAttemptCount(cert.code, history);
                final lockedLabel = hasCapacity
                    ? '${cert.title} · 약점 집중 모의고사 (응시 기록 $attempts/$kWeightedExamMinAttempts)'
                    : '${cert.title} · 약점 집중 모의고사 (검증 문항 준비 중)';
                return Padding(
                  padding: const EdgeInsets.only(bottom: Gap.sm),
                  child: FocusTap(
                    onTap: unlocked
                        ? () => context.push('/cert/${cert.code}/exam/weak')
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Gap.lg),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(Radii.md),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            unlocked ? Icons.bolt_outlined : Icons.lock_outline,
                            size: 18,
                            color: unlocked ? c.accent : c.textFaint,
                          ),
                          const SizedBox(width: Gap.sm),
                          Expanded(
                            child: Text(
                              unlocked
                                  ? '${cert.title} · 약점 집중 모의고사'
                                  : lockedLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontVariations: Wght.w700,
                                color: unlocked ? c.text : c.textMuted,
                              ),
                            ),
                          ),
                          if (unlocked)
                            Text(
                              '약점 모의고사 →',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontVariations: Wght.w700,
                                color: c.accent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }(),
          ],
          if (pending.isNotEmpty) ...[
            const SizedBox(height: Gap.lg),
            PendingGroup(certs: pending),
          ],
        ],
      ),
    );
  }
}
