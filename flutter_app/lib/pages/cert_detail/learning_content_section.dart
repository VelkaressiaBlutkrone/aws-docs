import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/content_index.dart';
import '../../data/study_progress.dart';
import '../../data/weighted_exam.dart';
import '../../theme/app_theme.dart';
import '../../widgets/badges.dart';
import '../../widgets/focus_ring.dart';

/// 검증된 학습 콘텐츠(학습문서 + 연습 문제) 진입 섹션 + 진행률 배너.
/// (PR4 분해 — cert_detail_page.dart에서 이동.)
class LearningContentSection extends StatelessWidget {
  const LearningContentSection({
    super.key,
    required this.entries,
    required this.weakByTask,
    this.progress,
    required this.attemptCount,
  });
  final List<ContentEntry> entries;
  final Map<String, int> weakByTask;
  final StudyProgress? progress;
  final int attemptCount;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final hasQuestions = entries.any((e) => e.questionCount > 0);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Gap.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, size: 18, color: c.accent),
              const SizedBox(width: 8),
              Text('학습 콘텐츠 · 검증 문항', style: t.headlineSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text('AWS 공식 출처로 검증한 한국어 학습문서와 연습 문제.', style: t.bodyMedium),
          const SizedBox(height: Gap.lg),
          if (progress != null && progress!.hasAny) ...[
            _ProgressBanner(progress: progress!),
            const SizedBox(height: Gap.lg),
          ],
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: FocusTap(
                onTap: () =>
                    context.push('/cert/${e.certCode}/study/${e.taskId}'),
                child: Container(
                  padding: const EdgeInsets.all(Gap.lg),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task ${e.taskId.replaceAll('clf-t', '').replaceAll('-', '.')} · ${e.title}',
                              style: t.titleMedium,
                            ),
                            const SizedBox(height: Gap.xs),
                            Row(
                              children: [
                                if (e.questionCount > 0)
                                  AppBadge(
                                    label: '검증 문항 ${e.questionCount}',
                                    bg: c.correctWeak,
                                    fg: c.correct,
                                    vPad: 3,
                                  ),
                                if ((weakByTask[e.taskId] ?? 0) > 0) ...[
                                  const SizedBox(width: Gap.xs),
                                  AppBadge(
                                    label: '오답 ${weakByTask[e.taskId]}',
                                    bg: c.wrongWeak,
                                    fg: c.wrong,
                                    vPad: 3,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '학습문서 →',
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
            ),
          Padding(
            padding: const EdgeInsets.only(top: Gap.xs),
            child: FocusTap(
              onTap: () => context.push('/cert/${entries.first.certCode}/plan'),
              child: Container(
                padding: const EdgeInsets.all(Gap.lg),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 18,
                      color: c.textMuted,
                    ),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text(
                        '학습 일정 · 시험일까지 무엇을 언제 공부할지',
                        style: t.titleMedium?.copyWith(color: c.text),
                      ),
                    ),
                    Text(
                      '일정 →',
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
          ),
          if (hasQuestions)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: FocusTap(
                onTap: () =>
                    context.push('/cert/${entries.first.certCode}/report'),
                child: Container(
                  padding: const EdgeInsets.all(Gap.lg),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insights_outlined, size: 18, color: c.accent),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: Text(
                          '약점 리포트 · Task별 정답률 보기',
                          style: t.titleMedium?.copyWith(color: c.text),
                        ),
                      ),
                      Text(
                        '리포트 →',
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
            ),
          if (hasQuestions)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: () {
                final certCode = entries.first.certCode;
                final hasCapacity = certExamHasWeightedCapacity(certCode);
                final hasAttempts = attemptCount >= kWeightedExamMinAttempts;
                final unlocked = hasCapacity && hasAttempts;
                final lockedLabel = hasCapacity
                    ? '약점 집중 모의고사 · 응시 기록이 3회 쌓이면 열립니다 ($attemptCount/$kWeightedExamMinAttempts)'
                    : '약점 집중 모의고사 · 공식 도메인 비중을 적용할 검증 문항이 더 필요합니다';
                return FocusTap(
                  onTap: unlocked
                      ? () => context.push('/cert/$certCode/exam/weak')
                      : null,
                  child: Container(
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
                                ? '약점 집중 모의고사 · 자주 틀린 Task 가중 출제'
                                : lockedLabel,
                            style: t.titleMedium?.copyWith(
                              color: unlocked ? c.text : c.textMuted,
                            ),
                          ),
                        ),
                        if (unlocked)
                          Text(
                            '시작 →',
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
                );
              }(),
            ),
          if (weakByTask.values.fold(0, (a, b) => a + b) > 0)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: FocusTap(
                onTap: () =>
                    context.push('/cert/${entries.first.certCode}/review'),
                child: Container(
                  padding: const EdgeInsets.all(Gap.lg),
                  decoration: BoxDecoration(
                    color: c.wrongWeak,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: c.wrong.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 18, color: c.wrong),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: Text(
                          '오답노트 · 틀린 ${weakByTask.values.fold(0, (a, b) => a + b)}문항 다시 풀기',
                          style: t.titleMedium?.copyWith(color: c.text),
                        ),
                      ),
                      Text(
                        '복습 →',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontVariations: Wght.w700,
                          color: c.wrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 학습 진행률 배너(열람률 + 최고 정답률 + 마지막 응시일). 정직 표기 툴팁.
class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.progress});
  final StudyProgress progress;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final p = progress;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Wrap(
        spacing: Gap.xl,
        runSpacing: Gap.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Tooltip(
            message: '학습 자료가 추가되면 진도율이 변할 수 있습니다.',
            child: _stat(c, t, '문서 열람', '${p.viewedCount}/${p.totalDocs}'),
          ),
          if (p.bestRatePct != null) _stat(c, t, '최고 정답률', '${p.bestRatePct}%'),
          if (p.lastAttemptIso != null)
            _stat(c, t, '마지막 응시', p.lastAttemptIso!.split('T').first),
        ],
      ),
    );
  }

  Widget _stat(AppColors c, TextTheme t, String label, String value) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: t.labelSmall?.copyWith(color: c.textFaint)),
      const SizedBox(height: 2),
      Text(
        value,
        style: t.titleMedium?.copyWith(
          color: c.accent,
          fontFamily: AppTheme.monoFamily,
        ),
      ),
    ],
  );
}
