// flutter_app/test/feedback_service_test.dart
//
// 피드백 전송 서비스. 설계 §7-2.
//
// ⚠️⚠️ 전송 결과가 **셋**이고 그 중 `queued` 가 성공이다 — Firestore 오프라인
// 지속성이 Android 에서 기본 ON 이고 `set()` 의 Future 는 **서버 ack 까지
// 완료되지 않는다.** await 결과만 보고 「전송 완료」를 말하면 오프라인 테스터는
// 끝나지 않는 스피너를 본다(설계 §4-5 의 반목표). 큐는 앱을 닫아도 유지되고
// 재연결 시 올라가므로 「보냈습니다 — 네트워크가 연결되면 올라갑니다」가 **참인
// 서술**이다. 타임아웃을 실패로 바꾸지 않는다.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/app_version.dart';
import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/auth_user.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/feedback_service.dart';

/// `setDoc` 이 **영원히 완료되지 않는** 스토어 — 오프라인 큐 적립 상태를 흉내낸다.
class _HangingCloud extends FakeCloudStore {
  var setDocCalls = 0;

  @override
  Future<void> setDoc(String uid, String collection, String docId,
      Map<String, dynamic> data) {
    setDocCalls++;
    return Completer<void>().future; // 완료되지 않는다
  }
}

/// `setDoc` 이 던지는 스토어 — 규칙 거부·네트워크 오류.
class _ThrowingCloud extends FakeCloudStore {
  @override
  Future<void> setDoc(String uid, String collection, String docId,
          Map<String, dynamic> data) async =>
      throw Exception('permission-denied');
}

/// 쓰인 문서를 그대로 돌려준다(경로 단정용).
Future<Map<String, dynamic>> _onlyDoc(CloudStore c, String uid) async {
  final docs = await c.loadCollection(uid, 'feedback');
  expect(docs, hasLength(1));
  return docs.values.single;
}

FeedbackService _service(CloudStore cloud, AuthService auth,
        {Duration ack = const Duration(seconds: 3)}) =>
    FeedbackService(cloud, auth, ackTimeout: ack);

void main() {
  late FakeCloudStore cloud;
  late FakeAuthService auth;

  setUp(() async {
    cloud = FakeCloudStore();
    auth = FakeAuthService();
    await auth.signInWithGoogle(); // uid 'u-test'
  });

  group('전송', () {
    test('정상 전송은 sent 이고 users/{uid}/feedback 에 쓰인다', () async {
      final r = await _service(cloud, auth)
          .send(kind: FeedbackKind.bug, body: '버튼이 안 눌립니다');
      expect(r, FeedbackSendResult.sent);

      final doc = await _onlyDoc(cloud, 'u-test');
      expect(doc['kind'], 'bug');
      expect(doc['body'], '버튼이 안 눌립니다');
      expect(doc['createdAtMs'], isA<int>());
      expect((doc['app'] as Map)['version'], kAppVersion);
      expect((doc['app'] as Map)['platform'], isNotEmpty);
    });

    test('다른 사용자 경로에는 쓰지 않는다', () async {
      await _service(cloud, auth)
          .send(kind: FeedbackKind.idea, body: '이런 기능이 있으면 좋겠습니다');
      expect(await cloud.loadCollection('other-uid', 'feedback'), isEmpty);
    });

    // 설계 §7-2 — ack 가 늦으면 **성공**이다(오프라인 큐).
    test('ack 가 늦으면 queued 다', () async {
      final hanging = _HangingCloud();
      final r = await _service(hanging, auth,
              ack: const Duration(milliseconds: 20))
          .send(kind: FeedbackKind.bug, body: '오프라인에서 보냅니다');
      expect(r, FeedbackSendResult.queued);
      expect(hanging.setDocCalls, 1, reason: '쓰기는 한 번 시도했다');
    });

    test('예외는 failed 다', () async {
      final r = await _service(_ThrowingCloud(), auth)
          .send(kind: FeedbackKind.bug, body: '거부되는 쓰기');
      expect(r, FeedbackSendResult.failed);
    });
  });

  // Review Focus 2 — 본문 경계. 빈 전송을 막지 않으면 빈 문서가 쌓이고,
  // 상한이 없으면 운영자가 읽을 수 없는 문서가 들어온다.
  group('본문 검증', () {
    test('빈 본문은 invalid 이고 아무것도 쓰지 않는다', () async {
      final r =
          await _service(cloud, auth).send(kind: FeedbackKind.bug, body: '');
      expect(r, FeedbackSendResult.invalid);
      expect(await cloud.loadCollection('u-test', 'feedback'), isEmpty);
    });

    test('공백만 있는 본문도 invalid 다', () async {
      final r = await _service(cloud, auth)
          .send(kind: FeedbackKind.bug, body: '   \n  ');
      expect(r, FeedbackSendResult.invalid);
      expect(await cloud.loadCollection('u-test', 'feedback'), isEmpty);
    });

    test('상한을 넘으면 invalid 다', () async {
      final r = await _service(cloud, auth)
          .send(kind: FeedbackKind.bug, body: 'ㄱ' * (kFeedbackBodyMax + 1));
      expect(r, FeedbackSendResult.invalid);
      expect(await cloud.loadCollection('u-test', 'feedback'), isEmpty);
    });

    test('상한과 정확히 같으면 보낸다', () async {
      final r = await _service(cloud, auth)
          .send(kind: FeedbackKind.bug, body: 'ㄱ' * kFeedbackBodyMax);
      expect(r, FeedbackSendResult.sent);
    });

    test('앞뒤 공백은 잘라 저장한다', () async {
      await _service(cloud, auth)
          .send(kind: FeedbackKind.bug, body: '  본문  ');
      expect((await _onlyDoc(cloud, 'u-test'))['body'], '본문');
    });
  });

  // Review Focus 3 — 폼을 열어 둔 채 다른 탭·기기에서 로그아웃한 경우.
  group('로그인 상태', () {
    test('비로그인은 notSignedIn 이고 아무것도 쓰지 않는다', () async {
      await auth.signOut();
      final r = await _service(cloud, auth)
          .send(kind: FeedbackKind.bug, body: '본문');
      expect(r, FeedbackSendResult.notSignedIn);
      expect(await cloud.loadCollection('u-test', 'feedback'), isEmpty);
    });

    test('비로그인이면 mine 은 빈 목록이다', () async {
      await auth.signOut();
      expect(await _service(cloud, auth).mine(), isEmpty);
    });
  });

  group('컨텍스트', () {
    test('문항 신고는 문항 식별자와 보여 준 보기를 담는다', () async {
      await _service(cloud, auth).send(
        kind: FeedbackKind.question,
        body: '2번 보기가 틀렸습니다',
        context: const FeedbackContext(
          certCode: 'SAA-C03',
          taskId: 'saa-t1-1',
          questionId: 'saa-t1-1-q3',
          shownOptions: ['가', '나', '다', '라'],
          pickedIndex: 1,
        ),
      );
      final ctx = (await _onlyDoc(cloud, 'u-test'))['context'] as Map;
      expect(ctx['certCode'], 'SAA-C03');
      expect(ctx['taskId'], 'saa-t1-1');
      expect(ctx['questionId'], 'saa-t1-1-q3');
      expect(ctx['shownOptions'], ['가', '나', '다', '라']);
      expect(ctx['pickedIndex'], 1);
    });

    // 보기는 전 경로에서 셔플되므로 **보여 준 순서**가 들어가야 한다.
    // 운영자가 문항 JSON 과 맞출 필요 없이 바로 읽힌다(설계 §7-2).
    test('고르지 않은 채 신고하면 pickedIndex 가 없다', () async {
      await _service(cloud, auth).send(
        kind: FeedbackKind.question,
        body: '지문이 이상합니다',
        context: const FeedbackContext(
            questionId: 'saa-t1-1-q3', shownOptions: ['가', '나']),
      );
      final ctx = (await _onlyDoc(cloud, 'u-test'))['context'] as Map;
      expect(ctx.containsKey('pickedIndex'), isFalse);
      expect(ctx['questionId'], 'saa-t1-1-q3');
    });

    test('context 가 없으면 문서에 context 키가 없다', () async {
      await _service(cloud, auth)
          .send(kind: FeedbackKind.other, body: '그 밖의 의견');
      expect((await _onlyDoc(cloud, 'u-test')).containsKey('context'), isFalse);
    });
  });

  group('내 의견 조회', () {
    // ⚠️ 시계를 주입한다 — 연속 전송은 같은 ms 가 되어 정렬 단정이 불안정해진다.
    test('mine 은 보낸 의견을 최신 먼저 돌려준다', () async {
      var t = DateTime.utc(2026, 12, 1);
      final s = FeedbackService(cloud, auth, now: () => t);
      await s.send(kind: FeedbackKind.bug, body: '첫 번째');
      t = DateTime.utc(2026, 12, 2);
      await s.send(kind: FeedbackKind.idea, body: '두 번째');
      final mine = await s.mine();
      expect(mine, hasLength(2));
      expect(mine.first['body'], '두 번째',
          reason: '최신이 먼저여야 한다(createdAtMs 내림차순)');
    });

    test('mine 은 다른 사용자의 의견을 돌려주지 않는다', () async {
      await cloud.setDoc('other-uid', 'feedback', 'x', {
        'kind': 'bug',
        'body': '남의 의견',
        'createdAtMs': 1,
      });
      expect(await _service(cloud, auth).mine(), isEmpty);
    });
  });

  test('문서 id 가 매번 다르다', () async {
    final s = _service(cloud, auth);
    await s.send(kind: FeedbackKind.bug, body: '하나');
    await s.send(kind: FeedbackKind.bug, body: '둘');
    final docs = await cloud.loadCollection('u-test', 'feedback');
    expect(docs, hasLength(2), reason: '같은 id 로 덮어썼다');
  });
}
