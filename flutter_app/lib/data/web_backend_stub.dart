import 'history_store.dart';

/// Non-web stub — never used at runtime on web, only satisfies VM/test compiler.
class WebBackend implements HistoryBackend {
  @override
  String? read(String key) => null;
  @override
  void write(String key, String value) {}
}
