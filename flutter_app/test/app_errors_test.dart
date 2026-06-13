import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/app_errors.dart';

/// 글로벌 에러 핸들러(PR4 T9/WS8) 단위 테스트.
/// FlutterError.onError는 테스트 프레임워크 소유라 반드시 저장→복원한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FlutterError.onError: presentError 유지 + 로그 한 줄', () {
    final logs = <String>[];
    final prevOnError = FlutterError.onError;
    final prevPresent = FlutterError.presentError;
    // presentError의 콘솔 덤프가 테스트 출력을 어지럽히지 않게 무음 치환.
    FlutterError.presentError = (_) {};
    try {
      installGlobalErrorHandlers(log: logs.add);
      FlutterError.reportError(
          FlutterErrorDetails(exception: StateError('boom')));
      expect(logs, hasLength(1));
      expect(logs.single, contains('FlutterError'));
      expect(logs.single, contains('boom'));
    } finally {
      FlutterError.onError = prevOnError;
      FlutterError.presentError = prevPresent;
      ErrorWidget.builder = ErrorWidget.new;
      PlatformDispatcher.instance.onError = null;
    }
  });

  test('PlatformDispatcher.onError: 로그 후 true(앱 비정지)', () {
    final logs = <String>[];
    final prevOnError = FlutterError.onError;
    try {
      installGlobalErrorHandlers(log: logs.add);
      final handled = PlatformDispatcher.instance.onError!(
          StateError('async-boom'), StackTrace.current);
      expect(handled, isTrue);
      expect(logs.single, contains('async-boom'));
    } finally {
      FlutterError.onError = prevOnError;
      ErrorWidget.builder = ErrorWidget.new;
      PlatformDispatcher.instance.onError = null;
    }
  });

  testWidgets('ErrorWidget.builder: 절제된 빌드 에러 박스(합니다체)', (tester) async {
    final prevOnError = FlutterError.onError;
    try {
      installGlobalErrorHandlers(log: (_) {});
      final replacement = ErrorWidget.builder(
          FlutterErrorDetails(exception: StateError('build-boom')));
      expect(replacement, isA<BuildErrorBox>());
      await tester.pumpWidget(MaterialApp(
          home: Directionality(
              textDirection: TextDirection.ltr, child: replacement)));
      expect(find.textContaining('새로고침해 주세요'), findsOneWidget);
    } finally {
      FlutterError.onError = prevOnError;
      ErrorWidget.builder = ErrorWidget.new;
      PlatformDispatcher.instance.onError = null;
    }
  });
}
