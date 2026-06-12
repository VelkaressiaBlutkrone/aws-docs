import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/theme_pref_store.dart';

void main() {
  test('저장→복원 라운드트립: dark 저장 후 새 인스턴스에서 dark 복원', () {
    final kv = MemoryBackend();
    ThemePrefStore(backend: kv).save(isDark: true);
    expect(ThemePrefStore(backend: kv).isDark, isTrue);

    ThemePrefStore(backend: kv).save(isDark: false);
    expect(ThemePrefStore(backend: kv).isDark, isFalse);
  });

  test('키 미존재: 라이트 폴백', () {
    expect(ThemePrefStore(backend: MemoryBackend()).isDark, isFalse);
  });

  test('파손/구버전 값: 라이트 폴백', () {
    final kv = MemoryBackend()..write('awsdocs.theme.v1', '###corrupt###');
    expect(ThemePrefStore(backend: kv).isDark, isFalse);
  });

  test('스플래시 JS와 공유하는 키/값 계약: awsdocs.theme.v1 = dark|light', () {
    final kv = MemoryBackend();
    ThemePrefStore(backend: kv).save(isDark: true);
    expect(kv.read('awsdocs.theme.v1'), 'dark');
    ThemePrefStore(backend: kv).save(isDark: false);
    expect(kv.read('awsdocs.theme.v1'), 'light');
  });
}
