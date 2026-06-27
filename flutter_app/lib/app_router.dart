import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/audio_nav.dart';
import 'data/audio_runtime.dart' show audioLectureEnabled;
import 'data/cert_lookup.dart';
import 'data/content_index.dart' show approvedAudioEntries, certsWithApprovedAudio;
import 'pages/audio_hub_page.dart';
import 'pages/cert_audio_page.dart';
import 'pages/cert_detail_page.dart';
import 'pages/cert_exam_page.dart';
import 'pages/exam_page.dart';
import 'pages/home_page.dart';
import 'pages/quiz_page.dart';
import 'pages/plan_page.dart';
import 'pages/report_page.dart';
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
                  path: 'exam/weak',
                  builder: (context, state) => CertExamPage(
                    cert: certByCode(state.pathParameters['code']!)!,
                    weighted: true,
                  ),
                ),
                GoRoute(
                  path: 'review',
                  builder: (context, state) =>
                      ReviewListPage(cert: certByCode(state.pathParameters['code']!)!),
                ),
                GoRoute(
                  path: 'report',
                  builder: (context, state) =>
                      ReportPage(cert: certByCode(state.pathParameters['code']!)!),
                ),
                GoRoute(
                  path: 'plan',
                  builder: (context, state) =>
                      PlanPage(cert: certByCode(state.pathParameters['code']!)!),
                ),
                GoRoute(
                  path: 'audio',
                  redirect: (context, state) {
                    final code = state.pathParameters['code']!;
                    return certAudioRedirect(
                      certExists: certByCode(code) != null,
                      enabled: audioLectureEnabled,
                      hasAudio: approvedAudioEntries(code).isNotEmpty,
                      code: code,
                    );
                  },
                  builder: (context, state) => CertAudioPage(
                      cert: certByCode(state.pathParameters['code']!)!),
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
                    // 같은 study 라우트로 taskId만 바뀌는 전환(go/주소창/뒤로가기)에서
                    // State가 재사용돼 옛 본문이 남는 것을 막는다 — taskId별 위젯
                    // 정체성을 분리해 새 문서마다 initState가 새로 _load 하게 한다.
                    key: ValueKey(
                        '${state.pathParameters['code']}/${state.pathParameters['taskId']}'),
                    entry: entryByTask(
                      state.pathParameters['code']!,
                      state.pathParameters['taskId']!,
                    )!,
                    targetAnchor: state.uri.queryParameters['at'],
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
        GoRoute(
          path: '/audio',
          redirect: (context, state) => audioHubRedirect(
            enabled: audioLectureEnabled,
            hasAudio: certsWithApprovedAudio().isNotEmpty,
          ),
          builder: (context, state) => const AudioHubPage(),
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
                style: TextStyle(color: c.text, fontWeight: FontWeight.w700, fontVariations: Wght.w700)),
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
