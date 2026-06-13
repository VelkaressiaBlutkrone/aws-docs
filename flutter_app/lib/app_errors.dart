import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

/// 앱 공용 로그 훅(PR4 T9/WS8) — 글로벌 핸들러와 부팅 degrade 경로가 공유.
/// 현재는 debugPrint(웹 콘솔). 외부 수집을 붙이면 이 한 곳만 바꾼다.
void appLog(String message) => debugPrint(message);

/// 글로벌 에러 핸들러 설치(WS8) — main()에서 runApp 전에 1회 호출.
///
/// - [FlutterError.onError]: 프레임워크 에러. 기본 presentError(콘솔 덤프)를
///   유지하고 [log]로도 한 줄 남긴다 — 삼키지 않는다.
/// - [PlatformDispatcher.onError]: 프레임워크 밖 비동기 에러. 로그 후 true를
///   돌려 앱 종료를 막는다(로컬-퍼스트 학습 앱 — 진행 중 데이터가 우선).
/// - [ErrorWidget.builder]: 빌드 실패 위젯 대체. 기본 빨강/회색 박스 대신
///   state_views의 Error 보이스와 정합하는 절제된 안내. 테마 컨텍스트가 없는
///   최후 방어선이라 라이트 토큰 상수를 쓴다(다크에서도 읽힘 우선).
void installGlobalErrorHandlers({void Function(String) log = appLog}) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log('FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log('UncaughtError: $error\n$stack');
    return true;
  };
  ErrorWidget.builder = (details) => const BuildErrorBox();
}

/// 빌드 실패 영역 대체 박스 — wrong 시맨틱(라이트 상수), 합니다체 한 줄.
/// ErrorView(state_views)는 Theme이 필요해 여기선 쓸 수 없다 — 보이스만 정합.
class BuildErrorBox extends StatelessWidget {
  const BuildErrorBox({super.key});

  @override
  Widget build(BuildContext context) {
    const c = AppColors.light;
    return ColoredBox(
      color: c.wrongWeak,
      child: Padding(
        padding: const EdgeInsets.all(Gap.md),
        child: Text(
          '이 영역을 그리지 못했습니다. 새로고침해 주세요.',
          style: TextStyle(fontSize: 13, color: c.wrong),
        ),
      ),
    );
  }
}
