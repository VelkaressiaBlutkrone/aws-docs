import 'package:flutter/material.dart';

import '../data/cloud/sync_controller.dart';
import '../theme/app_theme.dart';

/// 동기 진입점. controller==null이면 미설정(비활성) 안내.
class SyncEntry extends StatelessWidget {
  const SyncEntry({super.key, this.controller});
  final SyncController? controller;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ctrl = controller;
    if (ctrl == null) {
      return _box(c, Text('기기 간 동기 — 미설정', style: TextStyle(color: c.textMuted)));
    }
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final user = ctrl.user;
        if (user == null) {
          return _box(
            c,
            Row(children: [
              Expanded(child: Text('기기 간 동기', style: TextStyle(color: c.text))),
              TextButton(
                onPressed: ctrl.signIn,
                child: Text('Google로 동기 켜기',
                    style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
              ),
            ]),
          );
        }
        return _box(
          c,
          Row(children: [
            Expanded(
              child: Text('동기 켜짐 · ${user.email}',
                  style: TextStyle(color: c.text), overflow: TextOverflow.ellipsis),
            ),
            if (ctrl.status == SyncStatus.syncing)
              Padding(
                padding: const EdgeInsets.only(right: Gap.sm),
                child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: c.textMuted)),
              ),
            TextButton(
              onPressed: ctrl.signOut,
              child: Text('로그아웃', style: TextStyle(color: c.textMuted)),
            ),
          ]),
        );
      },
    );
  }

  Widget _box(AppColors c, Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: child,
      );
}
