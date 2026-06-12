import 'package:flutter/material.dart';

import '../data/weighted_exam.dart' show kWeightedExamMinAttempts;
import '../theme/app_theme.dart';
import 'quiz_widgets.dart' show PrimaryButton;

/// 시험 제출 직후 결과 화면의 "처방 허브".
/// 점수·오답 복기는 ResultsView가, 다음 행동은 여기서 처방한다.
///
/// DESIGN.md 정합(2026-06-09 plan-design-review D2):
///  - 주 동작 1개(오답 복습) + 보조 텍스트 링크 2개. 3-버튼 가로 묶음 금지(AI 슬롭).
///  - 세로 스택 → 좁은 폭에서 자연 반응형, 액센트는 링크에만(드물게).
///
/// 잠금/현재응시 상태는 부모가 history(현재 응시 포함)로 계산해 주입한다
/// (ExamView.resultsActionsBuilder가 제출 후 호출 → stale 방지).
///
///   [점수/복기 = ResultsView]
///        │
///   ┌────┴───────────────────────────┐
///   │ [오답 복습]            (주, accent 채움)
///   │ 약점 집중 모의고사 →    (보조 링크 / 잠김=응시 N/3 muted)
///   │ 약점 리포트 →          (보조 링크)
///   └────────────────────────────────┘
class PrescriptionHub extends StatelessWidget {
  const PrescriptionHub({
    super.key,
    required this.onReview,
    required this.onReport,
    this.onWeightedExam,
    this.weightedAttemptCount = 0,
    this.allCorrect = false,
  });

  /// 주 동작: 오답노트(복습)로. null이면 비활성(이력 없음 등).
  final VoidCallback? onReview;

  /// 보조: 약점 리포트로.
  final VoidCallback? onReport;

  /// 보조: 약점 집중 모의고사로. null이면 아직 잠김 → "응시 N/3" 안내만.
  final VoidCallback? onWeightedExam;

  /// 잠김 표시용 비-review 응시 횟수(현재 응시 포함). 표시는 min(n,3)/3로 clamp.
  final int weightedAttemptCount;

  /// 이번 회차 오답 0(만점)이면 차분한 한 줄을 덧붙인다.
  final bool allCorrect;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final lockedLabel =
        '응시 ${weightedAttemptCount.clamp(0, kWeightedExamMinAttempts)}/$kWeightedExamMinAttempts';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allCorrect) ...[
          Text('이번 회차 오답 없음 — 좋아요.',
              style: t.labelLarge?.copyWith(color: c.textMuted)),
          const SizedBox(height: Gap.md),
        ],
        SizedBox(
          width: 220,
          child: PrimaryButton(label: '오답 복습', onTap: onReview),
        ),
        const SizedBox(height: Gap.md),
        _HubLink(
          label: '약점 집중 모의고사',
          onTap: onWeightedExam,
          // 잠김이면 사유를 같은 줄에 정직하게(배지 어휘) 표기.
          lockedNote: onWeightedExam == null ? lockedLabel : null,
        ),
        const SizedBox(height: Gap.sm),
        _HubLink(label: '약점 리포트', onTap: onReport),
      ],
    );
  }
}

/// 보조 처방 링크: 활성이면 "라벨 →"(accent), 잠김이면 "라벨 · 사유"(muted, 비활성).
class _HubLink extends StatelessWidget {
  const _HubLink({required this.label, this.onTap, this.lockedNote});
  final String label;
  final VoidCallback? onTap;
  final String? lockedNote;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enabled = onTap != null;
    final child = Padding(
      // 44px 터치 타깃 확보.
      padding: const EdgeInsets.symmetric(vertical: Gap.md, horizontal: Gap.xs),
      child: Text(
        enabled ? '$label →' : '$label · ${lockedNote ?? '준비 중'}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700, fontVariations: Wght.w700,
          color: enabled ? c.accent : c.textMuted,
        ),
      ),
    );
    if (!enabled) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: child,
    );
  }
}
