/// 전역 오디오 런타임 — VM/test(웹 아님) 폴백.
///
/// 오디오 강의는 웹 전용 기능(package:web DOM `<audio>`)이라 VM/test에는
/// 런타임이 없다. 조건부 import([audio_runtime.dart])가 web이 아닐 때 이 파일을
/// 골라 `audioRuntime == null`로 만든다.
library;

import 'audio_runtime.dart';

/// 웹이 아닌 타겟에선 런타임 없음(null).
AudioRuntime? get audioRuntime => null;
