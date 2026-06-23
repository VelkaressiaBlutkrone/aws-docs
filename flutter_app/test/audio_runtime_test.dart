import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_runtime.dart';

/// 전역 오디오 런타임의 VM/test 경로(stub) 검증.
/// web 경로(WebAudioBackend 연결)는 package:web이라 VM 테스트 불가 —
/// build web 컴파일로 검증한다(M1 T4).
void main() {
  test('audioLectureEnabled는 dart-define 없으면 false (검수 전 강의 비공개 정책)',
      () {
    // 노출 정책(2026-06-20-study-audio-lecture-review.md 이슈 5-9):
    // M1 오디오는 공개 UI 미연결이 기본. dart-define audio_lecture=true일 때만 노출.
    expect(audioLectureEnabled, isFalse);
  });

  test('VM/test 환경에선 audioRuntime이 null (웹 전용 — 조건부 import가 stub)', () {
    // study_doc_page가 web_audio_backend(package:web)를 직접 import하지 않고
    // 이 런타임 경계를 거치므로 app_router_test(VM)가 컴파일된다.
    expect(audioRuntime, isNull);
  });
}
