import 'local_kv.dart';

/// Non-web stub — never used at runtime on web, only satisfies VM/test compiler.
class WebBackend implements KvBackend {
  @override
  String? read(String key) => null;
  @override
  void write(String key, String value) {}
  @override
  Iterable<String> keys() => const [];
}
