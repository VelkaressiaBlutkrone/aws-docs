import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/app_theme.dart';

/// 탭 영역을 [Touch.min](48dp)까지 넓히는 래퍼 — **도색 크기는 그대로 둔다.**
///
/// 자식을 더 크게 그리는 것이 아니라, 자신이 48dp를 차지하고 그 안의 빈 띠에
/// 들어온 포인터를 자식 중앙으로 돌려보낸다. 그래서 잉크(ripple·hover)는
/// 보이는 버튼에 딱 맞게 남고 웹의 시각은 바뀌지 않는다. Material 3의 버튼이
/// 쓰는 것과 같은 수법이다(도색 40dp + 타깃 48dp, `MaterialTapTargetSize.padded`)
/// — 다만 그 구현(`_InputPadding`)이 private이라 같은 렌더 객체를 여기 둔다.
///
/// ⚠️ **레이아웃은 커진다.** 간격 토큰으로 보정하지 않으면 요소 사이가 넓어
/// 보인다(헤더 액션은 [Gap.xs]로 보정해 도색 사이 16px을 보존한다).
///
/// ⚠️ **[FocusRing] 바깥에 둔다.** 링이 자식 경계에 붙어야 하므로
/// `TouchTarget(child: FocusRing(child: InkWell(...)))` 순서다.
///
/// Material 원본과 **다른 한 곳**: 원본 `_RenderInputPadding.hitTest`는 폴백에
/// 경계 검사가 없어 자기 영역 **밖**의 포인터도 자식으로 돌려보낼 수 있다.
/// 여기서는 [size] 안으로 한정한다 — 가드가 "48dp 밖은 눌리지 않는다"를
/// 단정한다(`test/touch_target_test.dart`).
class TouchTarget extends SingleChildRenderObjectWidget {
  const TouchTarget({
    super.key,
    required Widget super.child,
    this.minSize = const Size(Touch.min, Touch.min),
  });

  /// 탭 영역의 하한. 부모가 폭을 꽉 조이면(전폭 버튼 등) 폭은 그대로다 —
  /// `constraints.constrain`이 최종 치수를 정한다.
  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderTouchTarget(minSize);

  @override
  void updateRenderObject(
          BuildContext context, covariant RenderTouchTarget renderObject) =>
      renderObject.minSize = minSize;
}

/// [TouchTarget]의 렌더 객체. 공개는 테스트 가드가 타입으로 찾기 위한 것이다.
class RenderTouchTarget extends RenderShiftedBox {
  RenderTouchTarget(this._minSize, [RenderBox? child]) : super(child);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value) return;
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) => child == null
      ? 0.0
      : math.max(child!.getMinIntrinsicWidth(height), minSize.width);

  @override
  double computeMinIntrinsicHeight(double width) => child == null
      ? 0.0
      : math.max(child!.getMinIntrinsicHeight(width), minSize.height);

  @override
  double computeMaxIntrinsicWidth(double height) => child == null
      ? 0.0
      : math.max(child!.getMaxIntrinsicWidth(height), minSize.width);

  @override
  double computeMaxIntrinsicHeight(double width) => child == null
      ? 0.0
      : math.max(child!.getMaxIntrinsicHeight(width), minSize.height);

  Size _computeSize({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
  }) {
    final RenderBox? child = this.child;
    if (child == null) return Size.zero;
    final Size childSize = layoutChild(child, constraints);
    return constraints.constrain(Size(
      math.max(childSize.width, minSize.width),
      math.max(childSize.height, minSize.height),
    ));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _computeSize(
        constraints: constraints,
        layoutChild: ChildLayoutHelper.dryLayoutChild,
      );

  @override
  double? computeDryBaseline(
      covariant BoxConstraints constraints, TextBaseline baseline) {
    final RenderBox? child = this.child;
    if (child == null) return null;
    final double? result = child.getDryBaseline(constraints, baseline);
    if (result == null) return null;
    final Size childSize = child.getDryLayout(constraints);
    return result +
        Alignment.center
            .alongOffset(getDryLayout(constraints) - childSize as Offset)
            .dy;
  }

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );
    final RenderBox? child = this.child;
    if (child != null) {
      (child.parentData! as BoxParentData).offset =
          Alignment.center.alongOffset(size - child.size as Offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) return true;
    // 자식 밖 · 자기 안의 빈 띠 → 자식 중앙으로 돌려보낸다. 자기 **밖**은
    // 돌려보내지 않는다(Material 원본과 다른 점 — 클래스 주석 참고).
    final RenderBox? child = this.child;
    if (child == null || !size.contains(position)) return false;
    final Offset center = child.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (BoxHitTestResult result, Offset position) {
        assert(position == center);
        return child.hitTest(result, position: center);
      },
    );
  }
}
