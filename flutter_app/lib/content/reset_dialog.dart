import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 파괴적 동작(학습 기록 삭제) 확인 다이얼로그. [message]에 영향 범위를 적는다.
/// 동기 켜짐 상태에서도 삭제 표식이 모든 기기·클라우드로 전파되므로(동기 v2)
/// 되돌릴 수 없다. 위험 버튼(c.wrong 톤)으로 실수 클릭을 줄인다. 확인 시 true.
Future<bool> confirmReset(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '초기화',
}) async {
  final c = context.c;
  final t = Theme.of(context).textTheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        side: BorderSide(color: c.border),
      ),
      title: Text(title,
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontVariations: Wght.w800)),
      content: Text('$message\n\n이 작업은 되돌릴 수 없습니다.',
          style: t.bodyMedium?.copyWith(color: c.text)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('취소', style: TextStyle(color: c.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel,
              style: TextStyle(color: c.wrong, fontWeight: FontWeight.w800, fontVariations: Wght.w800)),
        ),
      ],
    ),
  );
  return ok ?? false;
}
