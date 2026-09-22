import 'package:flutter/material.dart';

import '../main.dart' show syncController;
import '../theme/app_theme.dart';

/// 파괴적 동작(학습 기록 삭제) 확인 다이얼로그. [message]에 영향 범위를 적고,
/// 끝맺음은 동기 상태로 정한다 — 로그인(기기 간 동기) 중엔 초기화가 로컬만 지우고
/// 다음 reconcile이 클라우드 백업으로 되살리므로(삭제 표식 부재, CODE-D-003)
/// "되돌릴 수 없음" 대신 그 사실을 알린다. 위험 버튼(c.wrong 톤)으로 실수 클릭을
/// 줄인다. 확인 시 true.
Future<bool> confirmReset(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '초기화',
}) async {
  final c = context.c;
  final t = Theme.of(context).textTheme;
  final notice = syncController.value?.user != null
      ? '기기 간 동기가 켜져 있어 클라우드 백업본은 삭제되지 않습니다. '
          '다음 동기 때 응시 이력·열람 기록 등이 다시 내려옵니다.'
      : '이 작업은 되돌릴 수 없습니다.';
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
      content: Text('$message\n\n$notice',
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
