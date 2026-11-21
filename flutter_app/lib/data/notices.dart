import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/notice.dart';
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
