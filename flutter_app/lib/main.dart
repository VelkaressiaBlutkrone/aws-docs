import 'dart:async';

import 'package:flutter/material.dart';

import 'app_errors.dart';
import 'app_router.dart';
import 'data/cloud/app_resume.dart';
import 'data/cloud/feedback_service.dart';
import 'data/cloud/firebase_auth_service.dart';
import 'data/cloud/firebase_bootstrap.dart';
import 'data/cloud/firestore_cloud_store.dart';
import 'data/cloud/sync_controller.dart';
import 'data/audio_runtime.dart' show initAudioSession;
import 'data/local_kv.dart' show initLocalStorage;
import 'data/theme_pref_store.dart';
import 'theme/app_theme.dart';
import 'theme/theme_scope.dart';

/// 클라우드 동기 컨트롤러. 부팅 재배열(WS2)로 첫 프레임 뒤에 늦게 주입된다 —
/// value==null은 "미설정(graceful degrade) 또는 초기화 전". SyncEntry가 구독해 리빌드.
final ValueNotifier<SyncController?> syncController = ValueNotifier(null);

/// 피드백 전송 서비스(D2). 동기와 **같은 Auth·Firestore 인스턴스**를 쓰지만 동기
/// 화해 경로와는 무관하다(단방향 쓰기). `syncController` 와 같은 자리·같은 시점에
/// 주입되고, value==null 은 「미설정 또는 초기화 전」이다.
final ValueNotifier<FeedbackService?> feedbackService = ValueNotifier(null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installGlobalErrorHandlers(); // WS8 — 프레임워크/비동기 에러 로깅+비정지

  // 로컬 저장소를 첫 프레임 **앞에서** 연다(A2). 네이티브에서 `defaultBackend()`가
  // 영속 백엔드를 돌려주려면 이것이 먼저여야 한다 — 첫 프레임 뒤로 미루면 홈이 한 번
  // "기록 없음"으로 그려졌다가 바뀐다. 경로 조회만 플랫폼 호출이고 디렉터리 읽기는
  // 동기라(내용은 지연 로드) 비용이 작다. ⚠️ WS2 와의 거래라 실측값을 로그로 남긴다.
  // 웹에서는 no-op 이라 기존 부팅 경로가 그대로다.
  final sw = Stopwatch()..start();
  try {
    await initLocalStorage();
    appLog('local storage ready in ${sw.elapsedMilliseconds}ms');
  } catch (e, st) {
    appLog('local storage init 실패 — 메모리 전용으로 동작: $e\n$st');
  }

  // 미디어 세션(잠금화면·알림·헤드셋)을 첫 프레임 **앞에서** 시작한다(D1-b).
  // ⚠️ await 하지 않는다 — WS2(첫 프레임을 늦추지 않는다)와의 거래다. 그래도 `runApp` 앞에
  // 두는 이유는 공식 문서가 `AudioService.init` 을 「앱 초기화 중 한 번」으로 요구하기
  // 때문이다(알림에서 재생을 눌러 프로세스가 깨어나는 경로는 프레임이 없을 수 있어
  // `addPostFrameCallback` 에 두면 영원히 안 돌 수 있다). 웹·데스크톱에서는 no-op 이고,
  // 실패는 함수 안에서 로그로 삼킨다 — 세션이 없어도 앱 안 재생은 그대로 동작한다.
  unawaited(initAudioSession());

  // 첫 프레임을 Firebase init 뒤로 미루지 않는다(백색 화면 주범 ② — WS2).
  // 스플래시 제거 트리거인 flutter-first-frame이 최대한 일찍 발생해야 한다.
  runApp(const AwsDocsApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(initCloudSync());
  });
}

/// 첫 프레임 뒤 호출되는 클라우드 동기 후행 초기화.
/// 미설정이면 아무것도 하지 않고(기존 graceful degrade 계약), 예외 시 로컬 전용으로
/// degrade한다 — 앱은 클라우드 없이 계속 동작. 로깅은 WS8 공용 훅(appLog).
Future<void> initCloudSync(
    {Future<bool> Function() init = initFirebaseIfConfigured}) async {
  try {
    if (!await init()) return;
    // 동기와 피드백이 **같은 인스턴스**를 공유한다 — 두 번 만들면 Auth 상태가
    // 갈려 「동기는 켜졌는데 의견은 비로그인」 같은 어긋남이 생긴다.
    final auth = FirebaseAuthService();
    final cloud = FirestoreCloudStore();
    syncController.value = SyncController(
      auth: auth,
      cloud: cloud,
      local: defaultBackend(),
      // 로컬→클라우드 트리거: 주기(이 기기 변경 백업 지연 최소화) + 앱 복귀.
      syncInterval: SyncController.defaultSyncInterval,
      onAppResume: appResumeSignal(),
    )..start();
    feedbackService.value = FeedbackService(cloud, auth);
  } catch (e, st) {
    appLog('cloud sync init 실패 — 로컬 전용으로 동작: $e\n$st');
  }
}

class AwsDocsApp extends StatefulWidget {
  const AwsDocsApp({super.key, this.kv});

  /// 테마 영속화 백엔드 — 테스트 주입용. null이면 defaultBackend()(웹=localStorage).
  final KvBackend? kv;

  @override
  State<AwsDocsApp> createState() => _AwsDocsAppState();
}

class _AwsDocsAppState extends State<AwsDocsApp> {
  // Light is the default theme (DESIGN.md); dark is a toggle, persisted (WS9).
  late final ThemePrefStore _themePref = ThemePrefStore(backend: widget.kv);
  late ThemeMode _mode =
      _themePref.isDark ? ThemeMode.dark : ThemeMode.light;
  final _router = createRouter();

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    _themePref.save(isDark: _mode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      isDark: _mode == ThemeMode.dark,
      toggle: _toggleTheme,
      child: MaterialApp.router(
        title: '구름사다리',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _mode,
        routerConfig: _router,
      ),
    );
  }
}
