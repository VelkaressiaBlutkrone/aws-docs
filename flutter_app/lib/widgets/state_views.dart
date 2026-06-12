import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'focus_ring.dart';

/// 비동기 페이지 공용 상태 뷰 3종 (DESIGN.md State Views, 시각 리펙토링 WS4).
///
/// 7개 비동기 페이지(StudyDoc/Quiz/Exam/CertExam/CertDetail/Review/Report)의
/// 로딩/빈/에러 표시를 표준화한다. 세 위젯 모두 콘텐츠 블록(자체 Center 없음) —
/// 풀바디 배치는 호출부가 `Center(child: ...)`로, 인라인 배치는 그대로 둔다.
/// 카피는 합니다체(DESIGN.md Voice) — 페이지별 문구는 카피 매트릭스 참조.

/// 로딩: 표시 전 150ms 유예 — 그 안에 Future가 해소되면 로딩 UI가 한 번도
/// 그려지지 않는다(짧은 로드에서 깜빡임 방지, 디자인 리뷰 2A). 등장은 80ms
/// ease-out 페이드인. 틸 링 + "무엇을 불러오는지" 한 줄.
class LoadingView extends StatefulWidget {
  const LoadingView({super.key, required this.label});

  final String label;

  static const Duration delay = Duration(milliseconds: 150);
  static const Duration fadeIn = Duration(milliseconds: 80);

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(LoadingView.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final c = context.c;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduceMotion ? Duration.zero : LoadingView.fadeIn,
      curve: Curves.easeOut,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: c.accent,
              backgroundColor: c.accentWeak,
            ),
          ),
          const SizedBox(height: Gap.md),
          Text(widget.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// 빈 상태: 아이콘 없음 — 텍스트(+선택 CTA)만 (디자인 리뷰 2A, 에디토리얼 절제).
/// 빈 이유와 다음 행동을 정직하게 설명한다.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.description,
    this.ctaLabel,
    this.onCta,
  }) : assert((ctaLabel == null) == (onCta == null),
            'CTA는 라벨과 콜백을 함께 제공해야 한다');

  final String title;
  final String? description;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, textAlign: TextAlign.center, style: t.titleMedium),
        if (description != null) ...[
          const SizedBox(height: Gap.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(description!,
                textAlign: TextAlign.center, style: t.bodyMedium),
          ),
        ],
        if (ctaLabel != null) ...[
          const SizedBox(height: Gap.lg),
          FocusRing(
            borderRadius: BorderRadius.circular(Radii.full),
            child: OutlinedButton(
              onPressed: onCta,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.accent,
                side: BorderSide(color: c.borderStrong),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              child: Text(ctaLabel!),
            ),
          ),
        ],
      ],
    );
  }
}

/// 에러(fatal — 페이지의 주된 콘텐츠 로드 실패): wrong 시맨틱 원형 아이콘 +
/// 메시지 + 보조 설명 + 복구 경로 2개(다시 시도 / 홈으로).
/// 부가 메타 실패(optional)는 이 뷰가 아니라 기존 의도적 부분 degrade를 유지한다.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.description = '네트워크가 잠시 불안정했을 수 있습니다. 다시 시도하면 대부분 해결됩니다.',
    required this.onRetry,
    required this.onHome,
  });

  final String message;
  final String description;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: c.wrongWeak, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(Icons.priority_high, size: 22, color: c.wrong),
        ),
        const SizedBox(height: Gap.md),
        Text(message, textAlign: TextAlign.center, style: t.titleMedium),
        const SizedBox(height: Gap.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(description,
              textAlign: TextAlign.center, style: t.bodyMedium),
        ),
        const SizedBox(height: Gap.lg),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FocusRing(
              borderRadius: BorderRadius.circular(Radii.full),
              child: FilledButton(
                onPressed: onRetry,
                child: const Text('다시 시도'),
              ),
            ),
            const SizedBox(width: Gap.md),
            FocusRing(
              child: TextButton(
                onPressed: onHome,
                child: Text(
                  '홈으로',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c.textMuted,
                    decoration: TextDecoration.underline,
                    decorationColor: c.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
