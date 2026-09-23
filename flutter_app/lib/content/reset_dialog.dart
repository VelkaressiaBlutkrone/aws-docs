import 'package:flutter/material.dart';

import '../data/cloud/sync_meta.dart';
import '../data/local_kv.dart';
import '../main.dart' show syncController;
import '../theme/app_theme.dart';

/// 파괴적 동작(학습 기록 삭제) 확인 다이얼로그. [message]에 영향 범위를 적는다.
/// 동기 켜짐 상태에서도 삭제 표식이 모든 기기·클라우드로 전파되므로(동기 v2)
/// 되돌릴 수 없다. 위험 버튼(c.wrong 톤)으로 실수 클릭을 줄인다. 확인 시 true.
///
/// [signedIn]·[syncedBefore]는 테스트 주입용이다 — 비우면 전역 상태에서 읽는다.
Future<bool> confirmReset(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '초기화',
  bool? signedIn,
  bool? syncedBefore,
}) async {
  // 비로그인 상태에서 지우면 표식만 로컬에 남는다. 예전에 동기한 적이 있으면
  // 클라우드 사본은 다음 로그인 때 그 표식으로 정리된다 — 그 사실을 알린다.
  final isSignedIn = signedIn ?? (syncController.value?.user != null);
  final hasTrace = syncedBefore ?? (SyncMeta(defaultBackend()).syncedAtMs > 0);
  final notice = (!isSignedIn && hasTrace)
      ? '\n\n로그인하지 않은 상태입니다. 예전에 동기된 클라우드 기록은 다음 로그인 때 함께 정리됩니다.'
      : '';
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
      content: Text('$message\n\n이 작업은 되돌릴 수 없습니다.$notice',
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
