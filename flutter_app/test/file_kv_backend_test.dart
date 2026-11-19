// Android 로컬 저장소 가드 (A2, 2026-11-19).
//
// `defaultBackend()` 가 네이티브에서 `MemoryBackend` 를 돌려줘 **앱을 닫으면 학습 기록이
// 사라지던** 것을 파일 백엔드로 닫는다(`local_kv.dart` 의 네이티브 분기).
//
// ⚠️ `shared_preferences` 는 쓰지 않는다 — 공식 문서가 "there is no guarantee that writes
// will be persisted to disk after returning, so this plugin must not be used for storing
// critical data" 라고 적는데, A2 의 완료 기준이 바로 **앱 강제 종료 뒤 기록 유지**다.
// 게다가 단일 저장소라 매 탭 progress 쓰기가 143KB 스냅샷까지 함께 다시 쓰게 된다
// (문항 평균 1,957바이트 실측 — 65문항 124KB · 75문항 143KB).
//
// ⚠️ 이 파일은 `dart:io` 를 직접 쓴다. 웹 빌드는 조건부 import 가 스텁을 고르므로
// `persistent_backend_io.dart` 가 웹 컴파일에 들어가지 않는다.
import 'dart:convert';
import 'dart:io';

import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/persistent_backend_io.dart';
import 'package:flutter_test/flutter_test.dart';

/// 실제 저장 키 모양 — 접두사에 `.` 가, 세션 키에 `:` 가 들어간다.
/// ⚠️ Android 파일명에 `:` 를 쓸 수 없으므로 파일명은 인코딩해야 한다.
const _sessionKey = 'awsdocs.examSnapshot.v1:exam:SAA-C03-mock';
const _historyKey = 'awsdocs.history.v1';

Directory _freshDir() {
  final d = Directory.systemTemp.createTempSync('awsdocs_kv_test_');
  addTearDown(() {
    if (d.existsSync()) d.deleteSync(recursive: true);
  });
  return d;
}

void main() {
  test('대조군: 빈 디렉터리로 열면 비어 있다', () {
    final b = FileKvBackend.open(_freshDir());
    expect(b.keys(), isEmpty);
    expect(b.read(_historyKey), isNull);
  });

  test('쓴 값이 새 인스턴스에서 읽힌다(영속 — A2 의 핵심)', () {
    final dir = _freshDir();
    FileKvBackend.open(dir).write(_historyKey, '{"v":1}');

    // 같은 디렉터리를 **새로 연다** = 앱 재시작과 같은 상황.
    final reopened = FileKvBackend.open(dir);
    expect(reopened.read(_historyKey), '{"v":1}');
  });

  test('키의 `:`·`.` 가 파일명에서 안전하고 keys() 가 원본 키를 돌려준다', () {
    final dir = _freshDir();
    FileKvBackend.open(dir).write(_sessionKey, 'x');

    expect(FileKvBackend.open(dir).keys(), contains(_sessionKey));
    // 파일명에 `:` 가 그대로 들어가면 Android 에서 쓰기가 실패한다.
    final names = dir.listSync().map((e) => e.uri.pathSegments.last).toList();
    expect(names, isNotEmpty);
    expect(names.any((n) => n.contains(':')), isFalse,
        reason: '파일명에 콜론이 남아 있다 — Android 파일 시스템에서 쓸 수 없다');
  });

  test('빈 문자열이 보존된다(지움 계약 — null 과 구별되지 않아야 한다)', () {
    final dir = _freshDir();
    final b = FileKvBackend.open(dir);
    b.write(_historyKey, 'something');
    b.write(_historyKey, ''); // 레포의 「지움」은 빈 문자열 쓰기다

    final reopened = FileKvBackend.open(dir);
    expect(reopened.read(_historyKey), '',
        reason: '빈 문자열을 저장하지 않으면 read 가 null 이 되는데, '
            'sync_service 의 `read(key) != value` 비교가 매번 쓰기를 유발한다');
    expect(reopened.keys(), contains(_historyKey));
  });

  test('스냅샷 크기(143KB)가 왕복한다', () {
    final dir = _freshDir();
    // 75문항 × 평균 1,957바이트 ≈ 143KB(AIP-C01 연습 세트가 가장 크다).
    final big = jsonEncode({'q': List.filled(75, 'x' * 1957)});
    expect(big.length, greaterThan(140 * 1024));

    FileKvBackend.open(dir).write(_sessionKey, big);
    expect(FileKvBackend.open(dir).read(_sessionKey), big);
  });

  test('keys() 로 접두사 일괄 정리가 된다(ExamSessionStore.clearAll 경로)', () {
    final dir = _freshDir();
    final b = FileKvBackend.open(dir);
    b.write('awsdocs.examSnapshot.v1:exam:A', '1');
    b.write('awsdocs.examProgress.v1:exam:A', '2');
    b.write(_historyKey, '3');

    final snap = b.keys().where((k) => k.startsWith('awsdocs.examSnapshot.v1:'));
    expect(snap, hasLength(1));
    expect(b.keys(), hasLength(3));
  });

  test('디코드할 수 없는 파일명은 무시한다(외부 파일·손상)', () {
    final dir = _freshDir();
    FileKvBackend.open(dir).write(_historyKey, 'ok');
    File('${dir.path}${Platform.pathSeparator}not-a-key!!!').writeAsStringSync('junk');

    final b = FileKvBackend.open(dir);
    expect(b.keys(), [_historyKey], reason: '알 수 없는 파일이 키로 올라오면 안 된다');
    expect(b.read(_historyKey), 'ok');
  });

  test('쓰기가 원자적이고 임시 파일이 남지 않는다', () {
    final dir = _freshDir();
    final b = FileKvBackend.open(dir);
    b.write(_historyKey, 'v1');
    b.write(_historyKey, 'v2'); // 덮어쓰기 — Windows 는 rename 이 기존 파일을 덮지 못한다

    expect(b.read(_historyKey), 'v2');
    expect(FileKvBackend.open(dir).read(_historyKey), 'v2');
    final leftovers =
        dir.listSync().map((e) => e.uri.pathSegments.last).where((n) => n.endsWith('.tmp'));
    expect(leftovers, isEmpty, reason: '임시 파일이 남으면 keys() 와 용량이 오염된다');
  });

  test('초기화 전 defaultBackend() 는 여전히 호출마다 새 MemoryBackend 다', () {
    // ⚠️ 이 성질에 기대는 주석이 home_page·cert_exam_page·exam_page 에 있다
    // ("VM의 defaultBackend()는 호출마다 별도 MemoryBackend라 주입구 없이는
    //  심은 것을 페이지가 볼 수 없다"). 싱글턴으로 바꾸면 테스트 간 상태가 샌다.
    expect(persistentBackendOrNull(), isNull,
        reason: '테스트 스위트는 initPersistentBackend() 를 부르지 않는다');
    final a = defaultBackend()..write('k', 'v');
    final b = defaultBackend();
    expect(b.read('k'), isNull);
    expect(identical(a, b), isFalse);
  });
}
