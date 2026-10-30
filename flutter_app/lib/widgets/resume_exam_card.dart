import 'package:flutter/material.dart';

import '../data/resume_exam.dart';
import '../theme/app_theme.dart';
import 'focus_ring.dart';

/// 진행 중인 모의고사 "이어서 풀기" 카드(UX-4). 세션 복원 기능이 이미 있는데도
/// 발견되지 않던 문제를 메운다 — 탭을 닫은 학습자가 세션이 남아 있는지 알 길이 없었다.
///
/// 홈(전 자격증)과 자격증 상세(한 자격증) 두 페이지가 쓴다.
class ResumeExamCard extends StatelessWidget {
  const ResumeExamCard({
    super.key,
    required this.exam,
    required this.onTap,
    this.showCertCode = false,
  });

  final ResumableExam exam;
  final VoidCallback onTap;

  /// 홈처럼 여러 자격증이 섞이는 곳에서만 자격증 코드를 적는다.
  final bool showCertCode;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final name = showCertCode ? '${exam.certCode} ${exam.title}' : exam.title;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: FocusTap(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, size: 18, color: c.accent),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '진행 중인 $name',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontVariations: Wght.w700,
                          color: c.accent)),
                  TextSpan(
                      text: '  ·  ${remainingExamLabel(exam.remainingSec)}',
                      style: TextStyle(color: c.textMuted)),
                ])),
              ),
              Text('이어서 풀기 →',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                      color: c.accent)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 0건이면 아무것도 그리지 않는 카드 묶음. 페이지가 목록만 넘기면 된다.
class ResumeExamSection extends StatelessWidget {
  const ResumeExamSection({
    super.key,
    required this.exams,
    required this.onOpen,
    this.showCertCode = false,
  });

  final List<ResumableExam> exams;
  final void Function(String route) onOpen;
  final bool showCertCode;

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Gap.lg, bottom: Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in exams)
            ResumeExamCard(
              exam: e,
              showCertCode: showCertCode,
              onTap: () => onOpen(e.route),
            ),
        ],
      ),
    );
  }
}
