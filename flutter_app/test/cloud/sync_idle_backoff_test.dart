// flutter_app/test/cloud/sync_idle_backoff_test.dart

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';
import 'package:aws_docs/data/history_store.dart';
import 'package:aws_docs/models/attempt_record.dart';

/// 리뷰 M-8 본체 — 30초 타이머가 **변경 유무와 무관하게** 컬렉션 로드를 반복해,
/// 사용자 수가 늘면 Firestore 읽기 비용의 유일한 조정점이었다.
///
/// 유휴(= 그 회차에 **아무 변경도 없었던** reconcile)가 이어지면 간격을 배로 늘려
/// 상한까지 가고, 변경이 생기면 기본 간격으로 돌아온다. ⚠️ **주기 폴링을 없애지는
/// 않는다** — watch가 죽은 사이 다른 기기 변경을 받는 안전망이기 때문이다(P1의 재구독이
/// 대부분을 자체 복구하지만, 폴링이 마지막 그물이다).
///
/// 정본: `docs/audits/2026-09-22-app-code-ux-review.md` M-8.

const _base = Duration(seconds: 30);
const _cap = Duration(minutes: 5);

/// sync() 호출 수를 센다(틱 발화 관측).
class _ProbeController extends SyncController {
  _ProbeController({
    required super.auth,
    required super.cloud,
    required super.local,
    required super.syncInterval,
    super.idleIntervalCap,
  });
  int syncCalls = 0;

  @override
  Future<void> sync() {
    syncCalls++;
    return super.sync();
  }
}

_ProbeController _signedIn(KvBackend local) {
  final c = _ProbeController(
    auth: FakeAuthService(),
    cloud: FakeCloudStore(),
    local: local,
    syncInterval: _base,
    idleIntervalCap: _cap,
  );
  c.signIn();
  return c;
}

void main() {
  test('변경 없는 틱이 이어지면 간격이 배로 늘어난다', () {
    fakeAsync((fa) {
      final c = _signedIn(MemoryBackend());
      fa.flushMicrotasks();

      // 로그인 직후 회차는 메타를 쓰므로(변경 있음) 기본 간격이다.
      fa.elapse(_base);
      fa.flushMicrotasks();
      final afterFirstTick = c.syncCalls;
      expect(afterFirstTick, greaterThan(0), reason: '전제: 기본 간격에서 틱이 돈다');

      // 이 틱은 아무것도 바꾸지 않았으므로 다음 간격은 2배(60초)여야 한다.
      fa.elapse(_base);
      fa.flushMicrotasks();
      expect(c.syncCalls, afterFirstTick,
          reason: '유휴인데도 30초마다 계속 돈다 — 읽기 비용이 줄지 않는다');

      fa.elapse(_base);
      fa.flushMicrotasks();
      expect(c.syncCalls, afterFirstTick + 1, reason: '60초 지점에서 한 번 돌아야 한다');

      c.dispose();
      fa.flushTimers();
    });
  });

  test('간격은 상한에서 멈추고, 상한 뒤에도 폴링은 계속된다', () {
    fakeAsync((fa) {
      final c = _signedIn(MemoryBackend());
      fa.flushMicrotasks();

      // 충분히 흘려 간격을 상한까지 키운다.
      fa.elapse(const Duration(hours: 1));
      fa.flushMicrotasks();

      // ⚠️ 임의 시점에서 "상한 − 1초"를 재면 **틱의 위상**을 모른다 — 직전 틱이 언제
      // 떨어졌는지에 따라 다음 틱이 더 가까울 수 있다(처음 쓴 단정이 그래서 16 vs 15로
      // 실패했다). 그래서 틱이 막 지난 지점으로 위상을 맞춘 뒤 **연속 두 틱의 간격**을 본다.
      final sync0 = c.syncCalls;
      while (c.syncCalls == sync0) {
        fa.elapse(const Duration(seconds: 1));
        fa.flushMicrotasks();
      }
      final justTicked = c.syncCalls;

      fa.elapse(_cap - const Duration(seconds: 1));
      fa.flushMicrotasks();
      expect(c.syncCalls, justTicked, reason: '상한보다 짧은 간격으로 돌고 있다');

      fa.elapse(const Duration(seconds: 1));
      fa.flushMicrotasks();
      expect(c.syncCalls, justTicked + 1,
          reason: '상한에서 멈추지 않고 더 늘어났다 — 그러면 안전망이 사라진다');

      c.dispose();
      fa.flushTimers();
    });
  });

  test('변경이 생기면 간격이 기본값으로 돌아온다', () {
    fakeAsync((fa) {
      final local = MemoryBackend();
      final c = _signedIn(local);
      fa.flushMicrotasks();

      fa.elapse(const Duration(hours: 1)); // 상한까지 키운다
      fa.flushMicrotasks();

      // 로컬에 실제 변경을 만든다(응시 기록 1건) → 다음 회차가 클라우드로 올린다.
      HistoryStore(backend: local).add(const AttemptRecord(
        certId: 'CLF-C02',
        examId: 'practice:clf-t1-1',
        mode: 'practice',
        date: '2026-11-02T00:00:00.000Z',
        correct: 1,
        total: 1,
        wrongQuestionIds: [],
        flaggedQuestionIds: [],
        durationSpentSec: 10,
      ));

      fa.elapse(_cap); // 변경을 올리는 회차
      fa.flushMicrotasks();
      final afterPush = c.syncCalls;

      // 변경이 있었으므로 간격이 기본값(30초)으로 복귀해야 한다.
      fa.elapse(_base);
      fa.flushMicrotasks();
      expect(c.syncCalls, afterPush + 1,
          reason: '변경 뒤에도 긴 간격을 유지하면 다음 백업이 최대 상한만큼 늦어진다');

      c.dispose();
      fa.flushTimers();
    });
  });
}
