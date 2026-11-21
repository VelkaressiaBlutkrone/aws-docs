import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/notice.dart';
import 'local_kv.dart';
// `AssetStringLoader` 는 재정의하지 않고 기존 정의를 쓴다 — 문항 뱅크 로더와
// 같은 주입 규율(테스트가 **요청 자체**를 볼 수 있게 한다)을 공유한다.
import 'question_banks.dart' show AssetStringLoader;

/// 공지 번들 자산 키. 이 값이 어긋나면 pubspec 에 선언해도 화면이 빈 채로 뜬다.
const kNoticesAsset = 'assets/notices.json';

/// 공지를 파일에 적힌 순서(= 최신 먼저)로 읽는다.
///
/// ⚠️ **파싱 실패·자산 부재는 빈 목록으로 degrade 한다**(던지지 않는다). 공지는
/// 부가 정보이고, 자산 하나가 깨져서 화면이 죽는 쪽이 더 나쁜 실패다. 형식 규율
/// (id 유일·date 내림차순·본문 평문)은 런타임이 아니라 `test/notices_test.dart`
/// 가 지킨다 — 공지는 번들이라 **릴리스 전에** 가드가 먼저 본다.
Future<List<Notice>> loadNotices({AssetStringLoader? loadString}) async {
  final load = loadString ?? rootBundle.loadString;
  try {
    final decoded = json.decode(await load(kNoticesAsset));
    if (decoded is! List) return const [];
    return [
      for (final e in decoded)
        if (e is Map<String, dynamic>) Notice.fromJson(e),
    ];
  } catch (_) {
    return const [];
  }
}

/// 「가장 최근 읽은 공지의 id」를 담는 로컬 KV 키.
///
/// ⚠️ **동기하지 않는다**(기기별 상태다). 동기 컬렉션을 하나 늘리면 계정 삭제
/// 범위와 처리방침 기록 목록 가드를 모두 건드려야 하고, 공지를 어느 기기에서
/// 읽었는지는 기기마다 달라도 해가 없다.
const kNoticeReadUpToKey = 'notices.readUpTo';

/// 저장된 id **뒤에 온**(= 더 최신인) 공지 수. `notices` 는 최신 먼저다.
///
/// ⚠️⚠️ 폴백이 둘이고 **둘 다 0(전부 읽음)**이다(설계 §7-1):
/// - 키가 없거나 비었다(신규 설치, 또는 빈 문자열 = 레포에서 「지움」) → 새
///   테스터의 첫 화면을 공지 배너로 채우지 않는다. 배너는 「내가 본 뒤에 새로
///   온 것」만을 뜻한다.
/// - 저장된 id 를 목록에서 찾을 수 없다(append-only 규율이 깨진 경우) →
///   「전부 안 읽음」으로 떨어뜨리면 **전 기기에 배너가 되살아난다.**
int unreadCount(List<Notice> notices, KvBackend backend) {
  if (notices.isEmpty) return 0;
  final readUpTo = backend.read(kNoticeReadUpToKey);
  if (readUpTo == null || readUpTo.isEmpty) return 0;
  final i = notices.indexWhere((n) => n.id == readUpTo);
  return i < 0 ? 0 : i;
}

/// 목록의 **최신 id** 를 읽음 기준으로 저장한다.
///
/// 목록이 비면 아무것도 쓰지 않는다 — 쓸 기준이 없고, 빈 값을 쓰면 위 폴백과
/// 구별되지 않는다.
void markAllRead(List<Notice> notices, KvBackend backend) {
  if (notices.isEmpty) return;
  backend.write(kNoticeReadUpToKey, notices.first.id);
}
