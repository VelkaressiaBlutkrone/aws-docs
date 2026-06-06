import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/certification.dart';
import '../theme/app_theme.dart';

/// 통합 모의고사 진입점(Spec 2 예약). 본 스펙에선 "준비 중" 안내만.
class CertExamPage extends StatelessWidget {
  const CertExamPage({super.key, required this.cert});
  final Certification cert;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
        title: Text('${cert.title} · 통합 모의고사',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(Gap.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('통합 모의고사 준비 중', style: t.headlineSmall),
                const SizedBox(height: Gap.sm),
                Text(
                  '자격증 전체 문항 풀에서 출제하는 통합 모의고사는 곧 제공됩니다. '
                  '지금은 각 학습문서의 "시험처럼 풀기"로 Task별 시험을 응시할 수 있습니다.',
                  style: t.bodyMedium?.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Gap.xl),
                FilledButton(
                  onPressed: () => context.go('/cert/${cert.code}'),
                  child: const Text('학습 콘텐츠로 이동'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
