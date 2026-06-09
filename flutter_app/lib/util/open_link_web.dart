import 'package:web/web.dart' as web;

/// 웹: 새 탭(`_blank`)으로 URL을 연다.
void openLink(String url) {
  web.window.open(url, '_blank');
}
