import 'dart:async';

import 'package:flutter/widgets.dart';

/// 네이티브: 앱이 다시 전면으로 올 때(resumed) 신호를 방출한다.
///
/// 웹의 `visibilitychange` 와 같은 목적이다 — 백그라운드에 있는 동안 쌓인 로컬 변경을
/// 복귀 시 클라우드로 reconcile-push 한다(`SyncController` 가 구독한다).
///
/// ⚠️ **broadcast 여야 한다.** single-subscription 이면 두 번째 구독에서
/// "Stream has already been listened to" 로 깨진다.
/// ⚠️ `AppLifecycleListener` 는 `WidgetsBinding.instance` 를 요구한다 — `main()` 이
/// `ensureInitialized()` 뒤에 부르고, 테스트는 `testWidgets` 바인딩 안에서 부른다.
Stream<void> appResumeSignal() {
  late final AppLifecycleListener listener;
  final controller = StreamController<void>.broadcast(
    // 마지막 구독자가 떠나면 리스너를 정리한다.
    onCancel: () => listener.dispose(),
  );
  listener = AppLifecycleListener(onResume: () => controller.add(null));
  return controller.stream;
}
