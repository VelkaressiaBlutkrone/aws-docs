import 'package:web/web.dart' as web;
import 'local_kv.dart';

/// Real localStorage backend — compiled only when targeting web.
class WebBackend implements KvBackend {
  @override
  String? read(String key) => web.window.localStorage.getItem(key);
  @override
  void write(String key, String value) =>
      web.window.localStorage.setItem(key, value);
  @override
  Iterable<String> keys() {
    final ls = web.window.localStorage;
    return [
      for (var i = 0; i < ls.length; i++) ?ls.key(i),
    ];
  }
}
