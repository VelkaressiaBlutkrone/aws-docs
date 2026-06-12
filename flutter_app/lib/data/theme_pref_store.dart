import 'local_kv.dart';

export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 테마 영속화(라이트/다크). 값은 'dark'|'light' 평문 — web/index.html의
/// 스플래시 JS가 같은 키를 직접 읽어 첫 페인트 색을 일치시키므로 JSON 금지.
/// 키 미존재/파손 값은 라이트 폴백(DESIGN.md: 라이트가 기본).
class ThemePrefStore {
  ThemePrefStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static const _key = 'awsdocs.theme.v1';
  static const _dark = 'dark';
  static const _light = 'light';

  bool get isDark => _b.read(_key) == _dark;

  void save({required bool isDark}) => _b.write(_key, isDark ? _dark : _light);
}
