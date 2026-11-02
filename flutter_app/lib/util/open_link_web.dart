import 'package:web/web.dart' as web;

/// 웹: 새 탭(`_blank`)으로 URL을 연다.
///
/// ⚠️ `window.open`은 `<a target="_blank">`와 달리 **`noopener`가 기본이 아니다** —
/// 넘기지 않으면 열린 페이지가 `window.opener`로 이 탭을 조작할 수 있다
/// (reverse tabnabbing). 가드는 `test/web_hardening_test.dart`.
void openLink(String url) {
  web.window.open(url, '_blank', 'noopener,noreferrer');
}
