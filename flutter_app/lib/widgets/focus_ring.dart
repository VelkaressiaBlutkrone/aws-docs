import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// focus-visible 토큰(DESIGN.md): 키보드 포커스 시 액센트 2px 아웃라인 + 2px 오프셋.
/// 자손(버튼·토글 등 포커스 가능한 위젯)이 포커스를 받으면 바깥 링을 그린다.
/// 링 공간(테두리 2px + 오프셋 2px)은 평시에도 투명하게 확보해 포커스가
/// 오갈 때 레이아웃 시프트가 없다.
///
/// 적용 표면: 상태뷰 버튼·테마 토글(PR2), 헤더 내비(PR4 예정).
class FocusRing extends StatefulWidget {
  const FocusRing({super.key, required this.child, this.borderRadius});

  final Widget child;

  /// 자식 모서리에 맞출 링 반경. null이면 [Radii.sm] + 오프셋.
  final BorderRadius? borderRadius;

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // canRequestFocus:false — 링 자신은 Tab 순서에 들어가지 않고
    // 자손의 포커스(hasFocus 전파)만 감지한다.
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius:
              widget.borderRadius ?? BorderRadius.circular(Radii.sm + 4),
          border: Border.all(
            width: 2,
            color: _focused ? c.accent : Colors.transparent,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
