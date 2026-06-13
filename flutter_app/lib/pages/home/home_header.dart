import 'package:flutter/material.dart';

import '../../main.dart' show syncController;
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/focus_ring.dart';
import '../sync_entry.dart';

/// 홈형 AppHeader(와이어프레임 정답지 2번 섹션 위 변형) — 브랜드 + 내비
/// 앵커 + 토글·설정. 셸(56px·blur 14·88% 불투명·하단 border)은
/// [AppHeaderShell] 공유, 토글은 [ThemeToggleButton] 공유.
///
/// compact(<768px)에선 내비·설정을 햄버거 메뉴로 통합 — 기존 홈 동작의
/// 이식이다(문서형 헤더의 "햄버거 신설 금지"와는 별개). 내비 활성탭
/// 언더라인은 홈이 단일 스크롤 페이지라 활성 개념이 없어 미적용
/// (인벤토리 §3 — 허브형 라우팅 도입 시 적용).
class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({
    super.key,
    required this.onNav,
    required this.onResetAll,
  });

  final Map<String, VoidCallback> onNav;
  final VoidCallback onResetAll;

  static const _navBreakpoint = 768.0;

  @override
  Size get preferredSize => const Size.fromHeight(AppHeaderShell.height);

  @override
  Widget build(BuildContext context) {
    return AppHeaderShell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < _navBreakpoint;
          // 브랜드는 loose Flexible — 우측 버튼군이 항상 우선 확보되고,
          // 아주 좁은 폭에선 브랜드 텍스트가 ellipsis로 양보한다(오버플로 금지).
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(child: _Brand()),
              if (compact)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 좁은 폭: 설정 액션을 햄버거 메뉴에 통합(버튼 과다 방지).
                    _NavMenuButton(onNav: onNav, onResetAll: onResetAll),
                    const SizedBox(width: Gap.sm),
                    const ThemeToggleButton(),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...onNav.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(left: Gap.sm),
                        child: _NavLink(label: e.key, onTap: e.value),
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    const ThemeToggleButton(),
                    const SizedBox(width: Gap.sm),
                    _SettingsButton(onResetAll: onResetAll),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text('A',
              style: TextStyle(
                  color: c.onAccent,
                  fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                  fontSize: 14)),
        ),
        const SizedBox(width: Gap.sm),
        Flexible(
          child: Text('AWS Docs Roadmap',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                  fontSize: 16,
                  letterSpacing: -0.4,
                  color: c.text)),
        ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.sm + 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600, fontVariations: Wght.w600,
                  color: c.textMuted)),
        ),
      ),
    );
  }
}

class _NavMenuButton extends StatelessWidget {
  const _NavMenuButton({required this.onNav, this.onResetAll});
  final Map<String, VoidCallback> onNav;
  final VoidCallback? onResetAll;

  static const _resetKey = '__reset_all__';
  static const _syncKey = '__sync__';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: PopupMenuButton<String>(
        tooltip: '메뉴',
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.border),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        onSelected: (key) {
          if (key == _syncKey) {
            _SettingsButton.openSyncSheet(context);
          } else if (key == _resetKey) {
            onResetAll?.call();
          } else {
            onNav[key]?.call();
          }
        },
        itemBuilder: (context) => [
          for (final key in onNav.keys)
            PopupMenuItem<String>(
              value: key,
              child: Text(key,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600, fontVariations: Wght.w600,
                      color: c.text)),
            ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: _syncKey,
            child: Row(
              children: [
                Icon(Icons.sync_outlined, size: 18, color: c.accent),
                const SizedBox(width: Gap.sm),
                Text('기기 간 동기',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600, fontVariations: Wght.w600,
                        color: c.text)),
              ],
            ),
          ),
          if (onResetAll != null) ...[
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: _resetKey,
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: c.wrong),
                  const SizedBox(width: Gap.sm),
                  Text('모든 학습 기록 초기화',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600, fontVariations: Wght.w600,
                          color: c.text)),
                ],
              ),
            ),
          ],
        ],
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(Radii.full),
            border: Border.all(color: c.border),
          ),
          child: Icon(Icons.menu, size: 18, color: c.textMuted),
        ),
      ),
    );
  }
}

/// 설정 버튼 — "기기 간 동기" + "모든 학습 기록 초기화".
class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onResetAll});
  final VoidCallback onResetAll;

  static void openSyncSheet(BuildContext context) {
    if (!context.mounted) return;
    final c = context.c;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(Radii.lg)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('기기 간 동기',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: c.text)),
            const SizedBox(height: Gap.lg),
            SyncEntry(controller: syncController),
            const SizedBox(height: Gap.md),
            Text(
              '동기를 켜면 여러 기기에서 같은 Google 계정으로 학습 기록을 공유합니다.',
              style: TextStyle(fontSize: 13, color: c.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: PopupMenuButton<String>(
        tooltip: '설정',
        position: PopupMenuPosition.under,
        onSelected: (v) {
          if (v == 'reset') onResetAll();
          if (v == 'sync') openSyncSheet(context);
        },
        itemBuilder: (ctx) => [
          PopupMenuItem<String>(
            value: 'sync',
            child: Row(
              children: [
                Icon(Icons.sync_outlined, size: 18, color: c.accent),
                const SizedBox(width: Gap.sm),
                const Text('기기 간 동기'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'reset',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: c.wrong),
                const SizedBox(width: Gap.sm),
                const Text('모든 학습 기록 초기화'),
              ],
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(Radii.full),
            border: Border.all(color: c.border),
          ),
          child: Icon(Icons.settings_outlined, size: 18, color: c.textMuted),
        ),
      ),
    );
  }
}
