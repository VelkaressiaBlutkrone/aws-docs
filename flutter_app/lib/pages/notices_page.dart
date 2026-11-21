import 'package:flutter/material.dart' hide Text;

import '../data/local_kv.dart';
import '../data/notices.dart';
import '../data/question_banks.dart' show AssetStringLoader;
import '../models/notice.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/state_views.dart';
import '../widgets/text.dart';

/// 공지 목록 — 번들 자산(`assets/notices.json`)을 최신 먼저 보인다.
///
/// 화면을 열면 최신 공지를 **읽음으로 표시**한다. 그래서 홈 배너는 「내가 본
/// 뒤에 새로 온 것」만을 뜻한다(설계 §7-1).
///
/// ⚠️ `ErrorView` 분기가 없는 것은 누락이 아니다 — `loadNotices` 가 파싱 실패·
/// 자산 부재를 **빈 목록으로 degrade** 하므로 이 화면에 에러 상태가 구조적으로
/// 없다. 공지 자산 하나가 깨져서 화면이 죽는 쪽이 더 나쁜 실패다.
class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key, this.backend, this.loadString});

  /// 테스트 주입구 — VM 의 `defaultBackend()` 는 **호출마다 새 `MemoryBackend`**
  /// 라, 주입구 없이는 테스트가 심은 읽음 상태를 페이지가 보지 못한다(레포 관례).
  final KvBackend? backend;

  /// 테스트 주입구 — `testWidgets` 본문에서 실제 `rootBundle` 비동기를 await 하면
  /// 파일 연속 실행에서 멈춘다(`cert_detail_sections_test` 와 같은 실측).
  final AssetStringLoader? loadString;

  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  late final KvBackend _kv = widget.backend ?? defaultBackend();
  late final Future<List<Notice>> _future = _load();

  /// 화면을 열기 **전에** 안 읽은 개수. 목록은 최신 먼저이므로 앞의 이 개수가
  /// 안 읽은 것들이다.
  int _unreadAtOpen = 0;

  Future<List<Notice>> _load() async {
    final list = await loadNotices(loadString: widget.loadString);
    // ⚠️⚠️ **`markAllRead` 앞에서 캡처한다** — 그것을 먼저 부르면 「무엇이 안 읽은
    // 것이었나」가 지워져 표식을 그릴 수 없다(2026-11-21 리뷰 지적).
    _unreadAtOpen = unreadCount(list, _kv);
    markAllRead(list, _kv); // 목록이 비면 아무것도 쓰지 않는다
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: const AppHeader.document(title: '공지'),
      body: FutureBuilder<List<Notice>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: LoadingView(label: '공지를 불러오고 있습니다…'));
          }
          final list = snap.data ?? const <Notice>[];
          if (list.isEmpty) {
            return const Center(
              child: EmptyView(
                title: '아직 공지가 없습니다',
                description: '새 공지가 올라오면 홈에서 알려 드립니다.',
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(Gap.lg)
                .copyWith(bottom: scrollBottomInset(context, gap: Gap.lg)),
            children: [
              for (var i = 0; i < list.length; i++)
                NoticeCard(notice: list[i], isNew: i < _unreadAtOpen),
            ],
          );
        },
      ),
    );
  }
}

/// 공지 한 건 — 날짜·제목·본문. 본문은 **평문**이다(마크다운 파서를 타지 않는다).
class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key, required this.notice, this.isNew = false});
  final Notice notice;

  /// 화면을 열기 전에 **안 읽은** 공지였는지. 홈 배너가 「새 공지 N개」로 약속한
  /// 정보를 화면에서 가려 준다 — 표식이 없으면 어느 것이 새 것인지 알 수 없다.
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(notice.date,
                    style: TextStyle(fontSize: 12, color: c.textMuted)),
                if (isNew) ...[
                  const SizedBox(width: Gap.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Gap.xs, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.accentWeak,
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Text('새 공지',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontVariations: Wght.w700,
                            color: c.accentStrong)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: Gap.xs),
            Text(notice.title,
                style: t.titleMedium?.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w700,
                    fontVariations: Wght.w700)),
            const SizedBox(height: Gap.sm),
            Text(notice.body,
                style: TextStyle(fontSize: 15, height: 1.6, color: c.text)),
          ],
        ),
      ),
    );
  }
}
