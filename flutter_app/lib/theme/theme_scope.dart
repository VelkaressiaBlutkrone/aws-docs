import 'package:flutter/material.dart';

/// 앱 전역 테마 토글 상태를 라우터 하위 페이지에 전달하는 InheritedWidget.
/// MaterialApp.router 상위에 배치되어 모든 라우트 페이지가 조상으로 접근 가능.
class ThemeScope extends InheritedWidget {
  const ThemeScope({
    super.key,
    required this.isDark,
    required this.toggle,
    required super.child,
  });

  final bool isDark;
  final VoidCallback toggle;

  static ThemeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ThemeScope oldWidget) => isDark != oldWidget.isDark;
}
