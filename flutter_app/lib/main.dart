import 'package:flutter/material.dart';

import 'app_router.dart';
import 'data/cloud/firebase_auth_service.dart';
import 'data/cloud/firebase_bootstrap.dart';
import 'data/cloud/firestore_cloud_store.dart';
import 'data/cloud/sync_controller.dart';
import 'data/local_kv.dart';
import 'theme/app_theme.dart';
import 'theme/theme_scope.dart';

/// null iff firebase not configured (stub / REPLACE_ME state → graceful degrade).
SyncController? syncController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configured = await initFirebaseIfConfigured();
  if (configured) {
    syncController = SyncController(
      auth: FirebaseAuthService(),
      cloud: FirestoreCloudStore(),
      local: defaultBackend(),
    )..start();
  }

  runApp(const AwsDocsApp());
}

class AwsDocsApp extends StatefulWidget {
  const AwsDocsApp({super.key});

  @override
  State<AwsDocsApp> createState() => _AwsDocsAppState();
}

class _AwsDocsAppState extends State<AwsDocsApp> {
  // Light is the default theme (DESIGN.md); dark is a toggle.
  ThemeMode _mode = ThemeMode.light;
  final _router = createRouter();

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      isDark: _mode == ThemeMode.dark,
      toggle: _toggleTheme,
      child: MaterialApp.router(
        title: 'AWS Docs Roadmap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _mode,
        routerConfig: _router,
      ),
    );
  }
}
