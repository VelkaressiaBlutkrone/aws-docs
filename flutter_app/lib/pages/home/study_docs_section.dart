import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/content_index.dart';
import '../../data/history_store.dart';
import '../../data/site_data.dart';
import '../../data/study_progress.dart';
import '../../data/viewed_docs_store.dart';
import '../../theme/app_theme.dart';
import 'content_cert_card.dart';
import 'home_bits.dart';

/// 상세 학습 문서 섹션(PR4 분해 — home_page.dart에서 이동).
class StudyDocsSection extends StatelessWidget {
  const StudyDocsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final withContent =
        certifications.where((c) => certHasContent(c.code)).toList();
    final pending =
        certifications.where((c) => !certHasContent(c.code)).toList();
    final viewedStore = ViewedDocsStore();
    final history = HistoryStore().all();
    return HomeBand(
      title: '상세 학습 문서',
      meta: '검증된 학습 콘텐츠',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Gap.lg,
            runSpacing: Gap.lg,
            children: [
              for (final cert in withContent)
                ContentCertCard(
                  cert: cert,
                  summaryLabel: () {
                    final s = certContentSummary(cert.code);
                    return s.questions > 0
                        ? '검증 학습문서 ${s.docs} · 총 ${s.questions}문항'
                        : '학습문서 ${s.docs} · 문항 준비 중';
                  }(),
                  cta: '학습문서 보기 →',
                  onTap: () => context.push('/cert/${cert.code}'),
                  viewedBadge: () {
                    final p = StudyProgress.build(
                      certId: cert.code,
                      allTaskIds: [
                        for (final e in contentFor(cert.code)) e.taskId
                      ],
                      viewedTaskIds: viewedStore.viewed(cert.code),
                      history: history,
                    );
                    return p.viewedCount > 0
                        ? '열람 ${p.viewedCount}/${p.totalDocs}'
                        : null;
                  }(),
                ),
            ],
          ),
          if (pending.isNotEmpty) ...[
            const SizedBox(height: Gap.lg),
            PendingGroup(certs: pending),
          ],
        ],
      ),
    );
  }
}
