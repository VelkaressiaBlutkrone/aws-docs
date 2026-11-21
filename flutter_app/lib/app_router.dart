import 'package:flutter/material.dart' hide Text;
import 'package:go_router/go_router.dart';

import 'data/audio_nav.dart';
import 'data/audio_runtime.dart' show audioLectureEnabled;
import 'data/cert_lookup.dart';
import 'data/cloud/feedback_service.dart';
import 'data/content_index.dart' show approvedAudioEntries, certsWithApprovedAudio;
import 'main.dart' show feedbackService;
import 'pages/audio_hub_page.dart';
import 'pages/feedback_page.dart';
import 'pages/cert_audio_page.dart';
import 'pages/cert_detail_page.dart';
import 'pages/cert_exam_page.dart';
import 'pages/exam_page.dart';
import 'pages/home_page.dart';
import 'pages/notices_page.dart';
import 'pages/quiz_page.dart';
import 'pages/plan_page.dart';
import 'pages/report_page.dart';
import 'pages/review_page.dart';
import 'pages/study_doc_page.dart';
import 'theme/app_theme.dart';
import 'widgets/text.dart';

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
                  // 같은 exam 라우트로 code만 바뀌는 전환(go/주소창/뒤로가기)에서 State가
                  // 재사용돼 이전 자격증의 문항 풀·시간·배분이 남던 결함(2026-11-18 라이브
                  // 점검)을 막는다 — study 라우트와 같은 방식으로 code별 정체성을 분리한다.
                  builder: (context, state) => CertExamPage(
                    key: ValueKey('${state.pathParameters['code']}/exam'),
                    cert: certByCode(state.pathParameters['code']!)!,
                  ),
                ),
                GoRoute(
                  path: 'exam/weak',
                  builder: (context, state) => CertExamPage(
                    key: ValueKey('${state.pathParameters['code']}/exam/weak'),
                    cert: certByCode(state.pathParameters['code']!)!,
                    weighted: true,
                  ),
                ),
                GoRoute(
                  path: 'review',
                  // exam 라우트와 같은 이유로 code별 정체성을 분리한다(_load()가 State 생성 때
                  // 한 번만 돌아 이전 자격증의 오답 목록이 남던 결함, 2026-11-18).
                  builder: (context, state) => ReviewListPage(
                    key: ValueKey('${state.pathParameters['code']}/review'),
                    cert: certByCode(state.pathParameters['code']!)!,
                  ),
                ),
                GoRoute(
                  path: 'report',
                  builder: (context, state) => ReportPage(
                    key: ValueKey('${state.pathParameters['code']}/report'),
                    cert: certByCode(state.pathParameters['code']!)!,
                  ),
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
                  // initState 에서만 재생 큐를 그 자격증으로 바꾸므로 code별 정체성을 분리한다
                  // (State 가 재사용되면 다른 자격증 목록에서 이전 큐의 강의가 재생됐다, 2026-11-18).
                  builder: (context, state) => CertAudioPage(
                      key: ValueKey('${state.pathParameters['code']}/audio'),
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
                      // study 라우트와 같은 이유로 taskId별 정체성을 분리한다(2026-11-18).
                      builder: (context, state) => QuizPage(
                        key: ValueKey(
                            '${state.pathParameters['code']}/${state.pathParameters['taskId']}/quiz'),
                        entry: entryByTask(
                          state.pathParameters['code']!,
                          state.pathParameters['taskId']!,
                        )!,
                      ),
                    ),
                    GoRoute(
                      path: 'exam',
                      builder: (context, state) => ExamPage(
                        key: ValueKey(
                            '${state.pathParameters['code']}/${state.pathParameters['taskId']}/exam'),
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
        // 공지는 경로 파라미터가 없어 ValueKey 가 필요하지 않다(같은 라우트로
        // 다른 대상을 여는 전환이 없다 — 2026-11-18 State 재사용 결함과 무관).
        GoRoute(
          path: '/notices',
          builder: (context, state) => const NoticesPage(),
        ),
        // 신고 진입점이 `extra` 로 FeedbackLaunch(유형 + 대상)를 넘긴다.
        // ⚠️ 그 타입이 아니거나 null 이면 **빈 폼**으로 연다(던지지 않는다) —
        // 메뉴에서 바로 열 때가 그 경우다.
        GoRoute(
          path: '/feedback',
          builder: (context, state) {
            final launch = state.extra;
            // 서비스는 첫 프레임 **뒤에** 주입되므로 구독한다(`SyncEntry` 와 같은
            // 사정). ⚠️ `ValueKey(svc)` 로 정체성을 분리해야 null → 실제 주입에서
            // State 가 새로 만들어진다 — 안 그러면 `initState` 의 구독·목록 로드가
            // 영원히 돌지 않는다(2026-11-18 State 재사용 결함과 같은 계열).
            return ValueListenableBuilder<FeedbackService?>(
              valueListenable: feedbackService,
              builder: (context, svc, _) => FeedbackPage(
                key: ValueKey(svc),
                service: svc,
                initialKind: launch is FeedbackLaunch ? launch.kind : null,
                initialContext:
                    launch is FeedbackLaunch ? launch.context : null,
              ),
            );
          },
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
