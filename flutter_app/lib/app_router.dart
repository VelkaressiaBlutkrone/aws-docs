import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/cert_lookup.dart';
import 'pages/cert_detail_page.dart';
import 'pages/cert_exam_page.dart';
import 'pages/exam_page.dart';
import 'pages/home_page.dart';
import 'pages/quiz_page.dart';
import 'pages/review_page.dart';
import 'pages/study_doc_page.dart';
import 'theme/app_theme.dart';

/// go_router 설정. 웹 기본 hash 전략(무설정) → GitHub Pages 딥링크 동작.
/// 라우트 빌더가 path param을 엔티티로 해석해 기존 페이지에 주입한다.
GoRouter createRouter({String initialLocation = '/'}) => GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'cert/:code',
              redirect: (context, state) =>
                  certByCode(state.pathParameters['code']!) == null ? '/' : null,
              builder: (context, state) =>
                  CertDetailPage(cert: certByCode(state.pathParameters['code']!)!),
              routes: <RouteBase>[
                GoRoute(
                  path: 'exam',
                  builder: (context, state) =>
                      CertExamPage(cert: certByCode(state.pathParameters['code']!)!),
                ),
                GoRoute(
                  path: 'review',
                  builder: (context, state) =>
                      ReviewListPage(cert: certByCode(state.pathParameters['code']!)!),
                ),
                GoRoute(
                  path: 'study/:taskId',
                  redirect: (context, state) => entryByTask(
                            state.pathParameters['code']!,
                            state.pathParameters['taskId']!,
                          ) ==
                          null
                      ? '/'
                      : null,
                  builder: (context, state) => StudyDocPage(
                    entry: entryByTask(
                      state.pathParameters['code']!,
                      state.pathParameters['taskId']!,
                    )!,
                  ),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'quiz',
                      builder: (context, state) => QuizPage(
                        entry: entryByTask(
                          state.pathParameters['code']!,
                          state.pathParameters['taskId']!,
                        )!,
                      ),
                    ),
                    GoRoute(
                      path: 'exam',
                      builder: (context, state) => ExamPage(
                        entry: entryByTask(
                          state.pathParameters['code']!,
                          state.pathParameters['taskId']!,
                        )!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => _RouteErrorPage(),
    );

class _RouteErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('페이지를 찾을 수 없습니다.',
                style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
            const SizedBox(height: Gap.md),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    );
  }
}
