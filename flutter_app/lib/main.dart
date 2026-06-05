import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'theme/app_theme.dart';

void main() => runApp(const AwsDocsApp());

class AwsDocsApp extends StatefulWidget {
  const AwsDocsApp({super.key});

  @override
  State<AwsDocsApp> createState() => _AwsDocsAppState();
}

class _AwsDocsAppState extends State<AwsDocsApp> {
  // Light is the default theme (DESIGN.md); dark is a toggle.
  ThemeMode _mode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWS Docs Roadmap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _mode,
      home: HomePage(
        isDark: _mode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
