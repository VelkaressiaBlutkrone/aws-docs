// flutter_app/test/feedback_page_test.dart
//
// 피드백 폼 화면과 메뉴 진입점. 설계 §7-2.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' hide Text;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/feedback_service.dart';
import 'package:aws_docs/pages/feedback_page.dart';
import 'package:aws_docs/pages/home/home_header.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

/// `setDoc` 이 완료되지 않는 스토어 — 전송 중 상태와 오프라인 큐를 흉내낸다.
class _HangingCloud extends FakeCloudStore {
  var setDocCalls = 0;

  @override
  Future<void> setDoc(String uid, String collection, String docId,
      Map<String, dynamic> data) {
    setDocCalls++;
    return Completer<void>().future;
  }
}

class _ThrowingCloud extends FakeCloudStore {
  @override
  Future<void> setDoc(String uid, String collection, String docId,
          Map<String, dynamic> data) async =>
      throw Exception('permission-denied');
}

/// `send` 자체가 던지는 서비스 — `FeedbackService.send` 의 `try` **앞** 구간
/// (시각·컨텍스트 직렬화·문서 조립·id 생성)에서 터지는 경우를 흉내낸다.
/// 2026-11-21 리뷰가 찾은 실제 결함이 그 모양이었다(웹에서 `1 << 32 == 0` →
/// `Random.nextInt(0)` 이 RangeError).
class _ThrowingService extends FeedbackService {
  _ThrowingService(super.cloud, super.auth);

  @override
  Future<FeedbackSendResult> send({
    required FeedbackKind kind,
    required String body,
    FeedbackContext? context,
  }) async =>
      throw StateError('boom');
}

/// 로그인이 실패하는 서비스.
class _SignInFailService extends FeedbackService {
  _SignInFailService(super.cloud, super.auth);

  @override
  Future<bool> signIn() async => false;
}

/// 폼은 그리지만 전송 시점에 `notSignedIn` 이 나는 서비스 — 폼을 열어 둔 채
/// 다른 탭·기기에서 로그아웃한 경우(Review Focus 3)다.
class _NotSignedInOnSend extends FeedbackService {
  _NotSignedInOnSend(super.cloud, super.auth);

  @override
  bool get isSignedIn => true;

  @override
  Future<FeedbackSendResult> send({
    required FeedbackKind kind,
    required String body,
    FeedbackContext? context,
  }) async =>
      FeedbackSendResult.notSignedIn;
}

Widget _wrap(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(theme: AppTheme.light, home: child),
    );

void main() {
  late FakeCloudStore cloud;
  late FakeAuthService auth;

  setUp(() async {
    cloud = FakeCloudStore();
    auth = FakeAuthService();
    await auth.signInWithGoogle(); // uid 'u-test'
  });

  Future<void> pump(WidgetTester tester, FeedbackService? svc,
      {FeedbackKind? kind, FeedbackContext? context}) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_wrap(FeedbackPage(
        service: svc, initialKind: kind, initialContext: context)));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();
  }

  Future<void> tapSend(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, '보내기'));
    await tester.pumpAndSettle();
  }

  group('로그인 상태', () {
    testWidgets('비로그인이면 폼 대신 로그인 안내를 보인다', (tester) async {
      await auth.signOut();
      await pump(tester, FeedbackService(cloud, auth));
      expect(find.text('의견을 보내려면 Google 로그인이 필요합니다.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    // ⚠️⚠️ A4 선례의 재발 — `SyncController.signIn` 은 예외를 잡아 화면에 올리는데
    // (그 주석이 「호출부가 Future 를 버린다 → 던지면 unhandled async」라고 적는다)
    // 새 화면이 그 보호 없이 같은 모양을 복제하고 있었다. 설계 §4-5 가 이 선례를
    // 이름까지 들어 반목표로 적는다.
    testWidgets('로그인이 실패하면 문구를 보인다', (tester) async {
      await auth.signOut();
      await pump(tester, _SignInFailService(cloud, auth));
      await tester.tap(find.widgetWithText(FilledButton, 'Google로 로그인'));
      await tester.pumpAndSettle();
      expect(find.text('로그인하지 못했습니다. 잠시 뒤 다시 시도해 주세요.'),
          findsOneWidget);
    });

    // 전역 주입이 아직 안 됐거나 Firebase 미설정 — 빈 화면을 두지 않는다.
    testWidgets('서비스 미설정(null)이면 안내를 보인다', (tester) async {
      await pump(tester, null);
      expect(find.text('의견 보내기는 지금 사용할 수 없습니다.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('전송', () {
    testWidgets('본문을 적어 보내면 성공 문구가 보인다', (tester) async {
      await pump(tester, FeedbackService(cloud, auth));
      await type(tester, '버튼이 안 눌립니다');
      await tapSend(tester);
      expect(find.text('의견을 보냈습니다.'), findsOneWidget);
      expect(await cloud.loadCollection('u-test', 'feedback'), hasLength(1));
    });

    // 설계 §7-2 — 오프라인 큐는 성공이고 **참인 서술**을 보인다.
    testWidgets('ack 가 늦으면 대기 문구가 보인다', (tester) async {
      final svc = FeedbackService(_HangingCloud(), auth,
          ackTimeout: const Duration(milliseconds: 20));
      await pump(tester, svc);
      await type(tester, '오프라인에서 보냅니다');
      await tapSend(tester);
      expect(find.text('의견을 저장했습니다 — 네트워크가 연결되면 올라갑니다.'),
          findsOneWidget);
    });

    testWidgets('실패하면 실패 문구와 보조 설명이 보인다', (tester) async {
      await pump(tester, FeedbackService(_ThrowingCloud(), auth));
      await type(tester, '거부되는 쓰기');
      await tapSend(tester);
      expect(find.text('의견을 보내지 못했습니다.'), findsOneWidget);
      expect(find.textContaining('다시 시도하면'), findsOneWidget);
    });

    // ⚠️⚠️ 2026-11-21 전체 브랜치 리뷰가 찾은 **Critical** — `_send` 에 `finally`
    // 가 없어 `send` 가 던지면 `_sending` 이 true 로 남고 버튼이 「보내는 중입니다…」
    // 로 **영구히 잠긴다.** 사용자는 뒤로가기밖에 못 하고 본문도 사라진다.
    // 설계 §4-5 의 반목표 둘(「전송 결과가 화면에 닿지 않는다」·「끝나지 않는
    // 스피너」)을 동시에 위반하던 자리다.
    testWidgets('send 가 던져도 실패를 알리고 버튼이 되살아난다', (tester) async {
      await pump(tester, _ThrowingService(cloud, auth));
      await type(tester, '예외가 나는 전송');
      await tapSend(tester);
      expect(find.text('의견을 보내지 못했습니다.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '보내기'), findsOneWidget,
          reason: '라벨이 「보내는 중입니다…」로 고정되면 안 된다');
      expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, '보내기'))
              .onPressed,
          isNotNull,
          reason: '버튼이 영구 잠기면 안 된다');
    });

    // Review Focus 3 의 실제 경로 — 「다시 시도하면 대부분 해결됩니다」는 **거짓**
    // 이다(다시 시도해도 영원히 안 된다). 네트워크 조언은 `failed` 에만 붙인다.
    testWidgets('notSignedIn 에는 네트워크 조언을 붙이지 않는다', (tester) async {
      await pump(tester, _NotSignedInOnSend(cloud, auth));
      await type(tester, '로그아웃된 채 보냅니다');
      await tapSend(tester);
      expect(find.text('의견을 보내려면 Google 로그인이 필요합니다.'), findsOneWidget);
      expect(find.textContaining('네트워크가 잠시 불안정'), findsNothing);
    });

    testWidgets('본문이 비면 전송 버튼이 비활성이다', (tester) async {
      await pump(tester, FeedbackService(cloud, auth));
      expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, '보내기'))
              .onPressed,
          isNull);
      await type(tester, '본문');
      expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, '보내기'))
              .onPressed,
          isNotNull);
    });

    // Review Focus 5 — 같은 의견이 두 문서로 들어오면 운영자가 중복을 읽는다.
    testWidgets('전송 중에는 두 번 눌러도 한 번만 쓰인다', (tester) async {
      final hanging = _HangingCloud();
      // ⚠️ 타임아웃을 길게 주면 그 Timer 가 테스트 종료까지 pending 으로 남아
      // 「A Timer is still pending」으로 실패한다(실측). 짧게 주고 끝에서 소진한다.
      await pump(
          tester,
          FeedbackService(hanging, auth,
              ackTimeout: const Duration(milliseconds: 50)));
      await type(tester, '두 번 누릅니다');
      await tester.tap(find.widgetWithText(FilledButton, '보내기'));
      await tester.pump();
      // 전송 중에는 라벨이 바뀌고 버튼이 **비활성**이다 — 두 겹으로 막는다.
      expect(find.widgetWithText(FilledButton, '보내는 중입니다…'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull);
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();
      expect(hanging.setDocCalls, 1);
      // 타임아웃 Timer 를 소진한다(남기면 위 경고로 실패한다). 이때 큐 적립으로
      // 판정되어 대기 문구가 뜬다 — 그것도 함께 확인한다.
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
      expect(find.text('의견을 저장했습니다 — 네트워크가 연결되면 올라갑니다.'),
          findsOneWidget);
    });
  });

  group('문항 신고 컨텍스트', () {
    testWidgets('대상 문항과 보기 지목 유도를 보인다', (tester) async {
      await pump(tester, FeedbackService(cloud, auth),
          kind: FeedbackKind.question,
          context: const FeedbackContext(
              certCode: 'SAA-C03',
              taskId: 'saa-t1-1',
              questionId: 'saa-t1-1-q3',
              shownOptions: ['가', '나', '다', '라'],
              pickedIndex: 1));
      expect(find.textContaining('saa-t1-1-q3'), findsOneWidget);
      expect(find.text('어느 보기인지 내용을 그대로 적어 주시면 더 빠릅니다.'),
          findsOneWidget);
    });

    testWidgets('신고 컨텍스트가 전송 문서에 담긴다', (tester) async {
      await pump(tester, FeedbackService(cloud, auth),
          kind: FeedbackKind.question,
          context: const FeedbackContext(
              questionId: 'saa-t1-1-q3', shownOptions: ['가', '나']));
      await type(tester, '2번 보기가 틀렸습니다');
      await tapSend(tester);
      final docs = await cloud.loadCollection('u-test', 'feedback');
      final doc = docs.values.single;
      expect(doc['kind'], 'question');
      expect((doc['context'] as Map)['questionId'], 'saa-t1-1-q3');
    });

    // 학습문서 오류는 이번 범위에 진입점이 없다 — 폼이 안내로 메운다(설계 §7-2).
    testWidgets('학습문서 오류 유형을 고르면 문서를 적어 달라고 안내한다',
        (tester) async {
      await pump(tester, FeedbackService(cloud, auth));
      await tester.tap(find.text('학습문서 오류'));
      await tester.pumpAndSettle();
      expect(find.text('어느 학습 문서인지 함께 적어 주세요.'), findsOneWidget);
    });
  });

  group('내가 보낸 의견', () {
    testWidgets('보낸 의견이 없으면 빈 상태 문구를 보인다', (tester) async {
      await pump(tester, FeedbackService(cloud, auth));
      expect(find.text('아직 보낸 의견이 없습니다'), findsOneWidget);
    });

    testWidgets('보낸 의견 목록을 보인다', (tester) async {
      await cloud.setDoc('u-test', 'feedback', 'f1', {
        'kind': 'bug',
        'body': '먼저 보낸 의견',
        'createdAtMs': DateTime.utc(2026, 12, 1).millisecondsSinceEpoch,
      });
      await pump(tester, FeedbackService(cloud, auth));
      expect(find.text('먼저 보낸 의견'), findsOneWidget);
    });

    testWidgets('전송하면 목록에 바로 나타난다', (tester) async {
      await pump(tester, FeedbackService(cloud, auth));
      await type(tester, '방금 보낸 의견');
      await tapSend(tester);
      expect(find.text('방금 보낸 의견'), findsOneWidget);
    });
  });

  group('메뉴 진입점', () {
    Future<int> tapFeedback(
        WidgetTester tester, Size size, String tooltip) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      var opened = 0;
      await tester.pumpWidget(_wrap(Scaffold(
        appBar: HomeHeader(
          onNav: {'자격증': () {}},
          onResetAll: () {},
          onOpenFeedback: () => opened++,
        ),
        body: const SizedBox(),
      )));
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text('의견 보내기'));
      await tester.pumpAndSettle();
      return opened;
    }

    testWidgets('좁은 폭: 메뉴의 의견 보내기가 폼을 연다', (tester) async {
      expect(await tapFeedback(tester, const Size(400, 800), '메뉴'), 1);
    });

    testWidgets('넓은 폭: 설정의 의견 보내기가 폼을 연다', (tester) async {
      expect(await tapFeedback(tester, const Size(1200, 800), '설정'), 1);
    });

    testWidgets('콜백을 주지 않으면 의견 보내기 항목이 없다', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(Scaffold(
        appBar: HomeHeader(onNav: {'자격증': () {}}, onResetAll: () {}),
        body: const SizedBox(),
      )));
      await tester.tap(find.byTooltip('메뉴'));
      await tester.pumpAndSettle();
      expect(find.text('의견 보내기'), findsNothing);
    });
  });

  test('라우터에 /feedback 라우트가 있고 extra 를 쪼개 넘긴다', () {
    final src = File('lib/app_router.dart').readAsStringSync();
    expect(src, contains("path: '/feedback'"));
    expect(src, contains('FeedbackPage'));
    // `extra` 가 FeedbackLaunch 가 아니거나 null 이면 빈 폼으로 연다.
    expect(src, contains('FeedbackLaunch'));
  });

  test('main 이 동기와 같은 Auth·Firestore 로 피드백 서비스를 주입한다', () {
    final src = File('lib/main.dart').readAsStringSync();
    expect(src, contains('feedbackService'));
    expect(src, contains('FeedbackService('));
  });
}
