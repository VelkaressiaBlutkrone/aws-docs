import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

import '../app_errors.dart';

/// 네이티브(Android·데스크톱): 기본 브라우저로 연다.
///
/// 호출부가 `onTap: () => openLink(widget.href)` 라 **동기 `void` 계약**을 지킨다 —
/// 띄우는 일은 비동기로 하고 실패는 로그로 남긴다. 조용히 삼키면 링크가 열리지 않는 것을
/// 아무도 모른다(A2 에서 `path_provider` 가 깨졌을 때 degrade 로그가 유일한 단서였다).
void openLink(String url) {
  unawaited(_open(url));
}

Future<void> _open(String url) async {
  try {
    // ⚠️ 기본 모드는 플랫폼이 정하므로 **앱 내 웹뷰**가 될 수 있다. 로드맵 A5 의 완료
    // 기준이 "히어로 출처 링크가 **브라우저로** 열린다" 라 외부 앱을 명시한다.
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) appLog('외부 링크를 열지 못했다(처리할 앱이 없을 수 있다): $url');
  } catch (e) {
    // VM 테스트에는 플랫폼 구현이 없어 MissingPluginException 이 난다.
    // 예외를 전파하지 않되(호출부가 동기 void 다) 삼키지도 않는다.
    appLog('외부 링크 열기 실패: $url — $e');
  }
}
