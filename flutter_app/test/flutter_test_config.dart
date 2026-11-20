// 모든 테스트에 적용되는 전역 설정(flutter_test 가 test/ 아래 이 파일을 자동으로 쓴다).
//
// 한국어 어절 단위 줄바꿈([keepAllEnabled])을 끈다. 켜 두면 화면 글자에 보이지 않는
// U+2060 이 섞여 `find.text('추천 순서')` 같은 기존 단정 244곳이 깨진다. 처리 자체는
// test/keep_all_test.dart 가 켜고 실제 렌더로 잰다.
import 'dart:async';

import 'package:aws_docs/util/keep_all.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  keepAllEnabled = false;
  await testMain();
}
