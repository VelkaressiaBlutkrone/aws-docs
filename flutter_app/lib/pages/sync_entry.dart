import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../data/cloud/sync_controller.dart';
import '../theme/app_theme.dart';

/// 동기 진입점. 부팅 재배열(WS2)로 컨트롤러가 첫 프레임 뒤 늦게 주입되므로
/// ValueListenable을 구독해 주입 시점에 리빌드한다. value==null이면 미설정(비활성) 안내.
class SyncEntry extends StatelessWidget {
  const SyncEntry({super.key, required this.controller});
  final ValueListenable<SyncController?> controller;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ValueListenableBuilder<SyncController?>(
      valueListenable: controller,
      builder: (context, ctrl, _) {
        if (ctrl == null) {
          return _box(
              c,
              Text('기기 간 동기 — 미설정',
                  style: TextStyle(color: c.textMuted)));
        }
        return _body(ctrl, c);
      },
    );
  }

  Widget _body(SyncController ctrl, AppColors c) {
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
                    style: TextStyle(color: c.accentStrong, fontWeight: FontWeight.w700, fontVariations: Wght.w700)),
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
            // 동기 실패(규칙 거부·오프라인)를 알린다 — 스피너만 있던 시절에는
            // 백업이 멈춘 것을 사용자가 알 수 없었다(리뷰 m-3). 재시도는 다음
            // 트리거(주기·앱 복귀·클라우드 변경)가 하므로 버튼을 두지 않는다.
            if (ctrl.status == SyncStatus.error)
              Padding(
                padding: const EdgeInsets.only(right: Gap.sm),
                child: Icon(Icons.cloud_off,
                    size: 16,
                    color: c.warningText,
                    semanticLabel: '동기 실패 — 다음 트리거에 재시도'),
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
