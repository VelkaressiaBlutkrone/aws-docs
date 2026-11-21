import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

import '../../app_version.dart';
import 'auth_service.dart';
import 'cloud_store.dart';

/// 피드백 유형. `question`·`content` 가 **문항·학습문서 오류 신고를 레포 검수
/// 흐름(보고 → 공식 문서 실측 → 전수 가드)으로 들이는 입구**다(설계 §1).
enum FeedbackKind { question, content, bug, idea, other }

/// 전송 결과. ⚠️ **`queued` 도 성공이다**(`send` 주석).
enum FeedbackSendResult { sent, queued, failed, notSignedIn, invalid }

/// 본문 상한. 넘으면 운영자가 읽을 수 없는 문서가 들어온다.
const kFeedbackBodyMax = 2000;

/// 피드백 컬렉션 — `users/{uid}/feedback/{id}`.
///
/// ⚠️ **기존 규칙(`users/{uid}/{document=**}`)이 이 쓰기를 이미 허용한다**(설계
/// §5-2) — 그래서 이 기능은 Firestore 규칙을 바꾸지 않고, 사용자가 콘솔에 규칙을
/// 배포해야 하는 사람 몫이 생기지 않는다. 다만 **동기 컬렉션은 아니다**:
/// `kUserOwnedCollections`(계정 삭제 범위)에만 들어간다.
const kFeedbackCollection = 'feedback';

/// 신고 대상의 식별 정보. 그 화면에서 열었을 때만 붙는다.
class FeedbackContext {
  const FeedbackContext({
    this.certCode,
    this.taskId,
    this.questionId,
    this.shownOptions,
    this.pickedIndex,
  });

  final String? certCode;
  final String? taskId;
  final String? questionId;

  /// **화면에 보여 준 순서**의 보기 원문.
  ///
  /// ⚠️ 보기는 전 경로에서 셔플된다(`applyOptionOrders`). 이것이 없으면 「2번
  /// 보기가 틀렸습니다」를 운영자가 복원할 수 없다. 원본 순서 인덱스가 아니라
  /// **원문**을 담는 이유는 문항 JSON 과 맞출 필요 없이 바로 읽히기 때문이다.
  final List<String>? shownOptions;

  /// 사용자가 고른 자리([shownOptions] 기준). 고르지 않았으면 null.
  final int? pickedIndex;

  Map<String, dynamic> toJson() => {
        if (certCode != null) 'certCode': certCode,
        if (taskId != null) 'taskId': taskId,
        if (questionId != null) 'questionId': questionId,
        if (shownOptions != null) 'shownOptions': shownOptions,
        if (pickedIndex != null) 'pickedIndex': pickedIndex,
      };
}

/// 라우트 `extra` 로 넘기는 「무엇을 신고하는가」.
///
/// ⚠️ `kind` 를 [FeedbackContext] 에 넣지 않는다 — 유형은 `send` 의 인자이고
/// 화면에서 사용자가 바꿀 수 있는 값이며, 컨텍스트는 대상의 식별 정보다.
typedef FeedbackLaunch = ({FeedbackKind kind, FeedbackContext context});

/// 피드백 전송·조회. [CloudStore] 와 [AuthService] 만 받으므로 기존 Fake 로
/// 테스트한다(동기 코드를 건드리지 않는다).
class FeedbackService {
  FeedbackService(
    this._cloud,
    this._auth, {
    Duration ackTimeout = const Duration(seconds: 3),
    DateTime Function()? now,
    Random? random,
  })  : _ackTimeout = ackTimeout,
        _now = now ?? DateTime.now,
        _random = random ?? Random();

  final CloudStore _cloud;
  final AuthService _auth;
  final Duration _ackTimeout;
  final DateTime Function() _now;
  final Random _random;

  /// 의견 한 건을 보낸다.
  ///
  /// ⚠️⚠️ **`queued` 는 성공이다.** Firestore 오프라인 지속성이 Android 에서
  /// 기본 ON 이고 `set()` 의 Future 는 **서버 ack 까지 완료되지 않는다.** 큐는
  /// 앱을 닫아도 유지돼 재연결 시 올라가므로 「네트워크가 연결되면 올라갑니다」가
  /// 참인 서술이고, 타임아웃을 실패로 보면 오프라인 사용자가 **끝나지 않는
  /// 스피너**를 본다(설계 §4-5 의 반목표).
  Future<FeedbackSendResult> send({
    required FeedbackKind kind,
    required String body,
    FeedbackContext? context,
  }) async {
    // Review Focus 3 — 폼을 열어 둔 채 다른 탭·기기에서 로그아웃했을 수 있다.
    final uid = _auth.current?.uid;
    if (uid == null) return FeedbackSendResult.notSignedIn;

    // Review Focus 2 — 빈 전송을 막지 않으면 빈 문서가 쌓인다.
    final text = body.trim();
    if (text.isEmpty || text.length > kFeedbackBodyMax) {
      return FeedbackSendResult.invalid;
    }

    final createdAtMs = _now().toUtc().millisecondsSinceEpoch;
    final ctx = context?.toJson();
    final doc = <String, dynamic>{
      'kind': kind.name,
      'body': text,
      'createdAtMs': createdAtMs,
      'app': {
        'version': kAppVersion,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      },
      if (ctx != null && ctx.isNotEmpty) 'context': ctx,
    };
    // auto-id 가 없는 경로라 클라이언트가 만든다 — 같은 ms 에 두 건을 보내도
    // 덮어쓰지 않게 난수를 붙인다.
    final id = '$createdAtMs-${_random.nextInt(1 << 32).toRadixString(36)}';

    try {
      await _cloud
          .setDoc(uid, kFeedbackCollection, id, doc)
          .timeout(_ackTimeout);
      return FeedbackSendResult.sent;
    } on TimeoutException {
      return FeedbackSendResult.queued;
    } catch (_) {
      return FeedbackSendResult.failed;
    }
  }

  /// 내가 보낸 의견 — **최신 먼저**. 비로그인·조회 실패는 빈 목록이다.
  Future<List<Map<String, dynamic>>> mine() async {
    final uid = _auth.current?.uid;
    if (uid == null) return const [];
    try {
      final docs = await _cloud.loadCollection(uid, kFeedbackCollection);
      return docs.values.toList()
        ..sort((a, b) => ((b['createdAtMs'] as num?) ?? 0)
            .compareTo((a['createdAtMs'] as num?) ?? 0));
    } catch (_) {
      return const [];
    }
  }
}
