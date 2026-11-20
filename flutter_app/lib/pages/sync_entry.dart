import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../app_errors.dart';
import '../content/reset_dialog.dart';
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
          // 로그인 실패를 알린다 — 호출부가 Future를 버려 예외가 화면에 닿지 않으므로
          // 이 문구가 없으면 버튼이 고장난 것처럼 보인다(A4). 취소는 실패가 아니라
          // null이므로 아무것도 그리지 않는다.
          final err = ctrl.signInError;
          return _box(
            c,
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('기기 간 동기', style: TextStyle(color: c.text))),
                TextButton(
                  onPressed: ctrl.signIn,
                  child: Text('Google로 동기 켜기',
                      style: TextStyle(color: c.accentStrong, fontWeight: FontWeight.w700, fontVariations: Wght.w700)),
                ),
              ]),
              if (err != null)
                Padding(
                  padding: const EdgeInsets.only(top: Gap.xs),
                  // warningText / surface2는 theme_contrast_test가 AA로 단정하는 쌍이다.
                  child: Text(err,
                      style: TextStyle(fontSize: 12, color: c.warningText)),
                ),
            ]),
          );
        }
        return _box(
          c,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          // 계정 삭제(A7) — Play 는 앱 안에서 계정과 관련 데이터를 지울 수 있어야
          // 한다고 요구한다. 로그인 상태에서만 보인다(지울 계정이 있어야 한다).
          //
          // ⚠️ 패널 안에서는 **중립 톤**이다. `wrong`/`surface2` 는 다크에서 4.40 으로
          // AA(4.5) 미달이고(계산 실측), 레포 관례도 위험 톤을 다이얼로그의 확인
          // 버튼에서만 쓴다(`reset_dialog.dart`). `textMuted`/`surface2` 는
          // `theme_contrast_test` 가 AA 로 단정하는 쌍이다.
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _confirmDeleteAccount(context, ctrl),
              child: Text('계정 삭제',
                  style: TextStyle(fontSize: 12, color: c.textMuted)),
            ),
          ),
          ]),
        );
      },
    );
  }

  /// 계정 삭제 확인 → 실행. 파괴적 동작의 확인 다이얼로그는 레포 공용
  /// `confirmReset`을 쓴다(위험 톤 확인 버튼 · "되돌릴 수 없습니다" 문구).
  ///
  /// ⚠️ 실패를 삼키지 않는다 — 재인증 거부·규칙 거부·네트워크 실패가 조용히 넘어가면
  /// 사용자는 계정이 지워졌다고 믿는다. 로그에 남기고 화면에도 알린다.
  Future<void> _confirmDeleteAccount(
      BuildContext context, SyncController ctrl) async {
    final ok = await confirmReset(
      context,
      title: '계정 삭제',
      message: '구글 계정 연결을 끊고 클라우드에 백업된 학습 기록을 모두 삭제합니다. '
          '이 기기에 저장된 기록도 함께 지워집니다.',
      confirmLabel: '계정 삭제',
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final done = await ctrl.deleteAccount();
      if (!done) return; // 사용자가 재인증을 취소했다 — 아무것도 지워지지 않았다
      messenger.showSnackBar(
        const SnackBar(content: Text('계정과 학습 기록을 삭제했습니다.')),
      );
    } catch (e, st) {
      appLog('계정 삭제 실패: $e\n$st');
      messenger.showSnackBar(
        const SnackBar(content: Text('계정 삭제에 실패했습니다. 다시 시도해 주세요.')),
      );
    }
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
