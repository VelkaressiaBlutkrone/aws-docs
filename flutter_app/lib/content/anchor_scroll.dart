import 'package:flutter/widgets.dart';

import 'package:aws_docs/models/study_content.dart';

/// 타깃을 글래스 헤더 아래로 보정한 스크롤 오프셋. [revealOffset]은
/// RenderAbstractViewport.getOffsetToReveal(alignment 0)의 offset(타깃을
/// 뷰포트 최상단에 올리는 값). 헤더가 가리는 만큼 위로 당기고 clamp.
double anchorScrollOffset({
  required double revealOffset,
  required double headerInset,
  required double maxScrollExtent,
}) =>
    (revealOffset - headerInset).clamp(0.0, maxScrollExtent);

/// 앵커가 붙은 제목마다 GlobalKey 1개를 만든 맵(키=anchor id). 렌더 시
/// 해당 제목 위젯에 부착해 좌표를 찾는다. 앵커 없는 제목은 제외.
Map<String, GlobalKey> buildAnchorKeys(List<MdBlock> blocks) {
  final map = <String, GlobalKey>{};
  for (final b in blocks) {
    if (b is MdHeading && b.anchor != null) {
      map[b.anchor!] = GlobalKey(debugLabel: 'anchor:${b.anchor}');
    }
  }
  return map;
}
