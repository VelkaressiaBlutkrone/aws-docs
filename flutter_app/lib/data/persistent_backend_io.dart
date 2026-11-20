import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'local_kv.dart';

/// 네이티브(Android·데스크톱) 영속 키-값 백엔드 — **키 하나당 파일 하나**.
///
/// 왜 `shared_preferences` 가 아닌가: 공식 문서가 "there is no guarantee that writes will
/// be persisted to disk after returning, so this plugin must not be used for storing
/// critical data" 라고 적는데, A2 의 완료 기준이 **앱 강제 종료 뒤 기록 유지**다. 그리고
/// 단일 저장소라 **매 탭 일어나는 progress 쓰기가 143KB 스냅샷까지 함께 다시 쓰게** 된다
/// (문항 평균 1,957바이트 실측 — 65문항 124KB · 75문항 143KB).
///
/// 설계 둘:
///  - **지연 로드** — 열 때는 파일 *목록*만 읽고 내용은 첫 `read` 에서 읽는다. 시작 비용이
///    저장량이 아니라 파일 수에 비례한다(`main()` 이 첫 프레임을 미루지 않아야 한다 — WS2).
///  - **임시 파일 → rename** — 쓰기 도중 프로세스가 죽어도 반쪽 파일이 남지 않는다.
class FileKvBackend implements KvBackend {
  FileKvBackend._(this._dir, this._files);

  /// 디렉터리를 열고 파일 목록으로 키를 복원한다. 없으면 만든다.
  /// 남아 있는 임시 파일은 이전 실행이 쓰다 만 것이므로 지운다.
  factory FileKvBackend.open(Directory dir) {
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final files = <String, File>{};
    for (final entity in dir.listSync(followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (name.endsWith(_tmpSuffix)) {
        try {
          entity.deleteSync();
        } catch (_) {
          // 지우지 못해도 키로 올라가지는 않는다.
        }
        continue;
      }
      final key = _decodeName(name);
      if (key != null) files[key] = entity;
    }
    return FileKvBackend._(dir, files);
  }

  static const _tmpSuffix = '.tmp';

  final Directory _dir;

  /// 키 → 파일. 열 때 한 번 만들고 쓰기마다 갱신한다.
  final Map<String, File> _files;

  /// 읽은 내용 캐시. 빈 문자열도 **값**이므로 null 과 구별된다(레포의 「지움」 계약).
  final Map<String, String> _cache = {};

  /// 키에는 `:`(세션 키)와 `.`(접두사)가 들어가는데 **Android 파일명에 `:` 를 쓸 수 없다.**
  /// base64url 은 `A-Z a-z 0-9 - _ =` 만 내므로 전 플랫폼에서 안전하고 되돌릴 수 있다
  /// (되돌릴 수 있어야 `keys()` 가 원본 키를 준다).
  static String _encodeName(String key) => base64Url.encode(utf8.encode(key));

  static String? _decodeName(String name) {
    try {
      return utf8.decode(base64Url.decode(name));
    } catch (_) {
      return null; // 외부 파일·손상된 이름 — 키로 올리지 않는다
    }
  }

  File _fileFor(String key) =>
      File('${_dir.path}${Platform.pathSeparator}${_encodeName(key)}');

  @override
  String? read(String key) {
    final cached = _cache[key];
    if (cached != null) return cached;
    final file = _files[key];
    if (file == null) return null;
    try {
      final value = file.readAsStringSync();
      _cache[key] = value;
      return value;
    } catch (_) {
      return null; // 손상 데이터는 "없음"으로 — 기존 스토어들이 그렇게 다룬다
    }
  }

  @override
  void write(String key, String value) {
    final target = _fileFor(key);
    final tmp = File('${target.path}$_tmpSuffix');
    tmp.writeAsStringSync(value, flush: true);
    try {
      tmp.renameSync(target.path);
    } on FileSystemException {
      // Windows 의 rename 은 기존 파일을 덮지 못한다(POSIX 와 다르다).
      // 테스트가 도는 환경이라 폴백이 필요하다 — Android 에서는 첫 시도가 성공한다.
      if (target.existsSync()) target.deleteSync();
      tmp.renameSync(target.path);
    }
    _files[key] = target;
    _cache[key] = value;
  }

  @override
  Iterable<String> keys() => _files.keys.toList();
}

KvBackend? _persistent;

/// 초기화됐으면 그 **단일** 인스턴스, 아니면 null.
///
/// ⚠️ null 을 돌려주는 것이 계약의 일부다 — VM 테스트는 `defaultBackend()` 가 호출마다
/// 별개 `MemoryBackend` 를 주는 성질에 기대고 있다(home_page·cert_exam_page·exam_page 의
/// 주입구 주석). 초기화하지 않은 환경에서는 지금 동작이 그대로 유지된다.
KvBackend? persistentBackendOrNull() => _persistent;

/// 앱 시작 시 한 번. **경로 조회만 비동기**이고 디렉터리 읽기는 동기라 짧다.
/// 실패하면 아무것도 하지 않는다 — 호출부가 메모리 백엔드로 degrade 한다.
Future<void> initPersistentBackend() async {
  if (_persistent != null) return;
  // 사용자에게 노출되지 않는 앱 전용 디렉터리(공식: "Use this for files you don't want
  // exposed to the user"). Android·iOS·데스크톱 전부 지원하고 없으면 자동 생성된다.
  final support = await getApplicationSupportDirectory();
  _persistent = FileKvBackend.open(
    Directory('${support.path}${Platform.pathSeparator}kv'),
  );
}
