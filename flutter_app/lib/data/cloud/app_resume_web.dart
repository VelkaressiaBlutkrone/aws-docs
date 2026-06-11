import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// 웹: 탭이 다시 보이게 될 때(visibilitychange → visible) 신호를 방출.
/// 백그라운드에서 만든 로컬 변경을 앱 복귀 시 클라우드로 reconcile-push 하기 위함.
Stream<void> appResumeSignal() {
  final controller = StreamController<void>.broadcast();
  void onChange(web.Event _) {
    if (web.document.visibilityState == 'visible') controller.add(null);
  }

  final listener = onChange.toJS;
  web.document.addEventListener('visibilitychange', listener);
  controller.onCancel =
      () => web.document.removeEventListener('visibilitychange', listener);
  return controller.stream;
}
