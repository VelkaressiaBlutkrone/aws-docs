import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/audio_runtime.dart';
import '../data/content_index.dart';
import '../data/lecture_playlist.dart';
import '../models/certification.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/focus_ring.dart';
import '../widgets/lecture_transport_bar.dart';

/// 자격증별 오디오 학습 페이지(A안) — 승인 오디오 강의 목록 + 하단 트랜스포트.
/// 진입 시 전역 플레이리스트가 이 cert 큐가 아니면 setQueue(자동재생 안 함).
/// 행 탭=그 트랙 재생(select), "문서 보기"=학습문서로 이동(재생 유지).
class CertAudioPage extends StatefulWidget {
  const CertAudioPage({super.key, required this.cert});

  final Certification cert;

  @override
  State<CertAudioPage> createState() => _CertAudioPageState();
}

class _CertAudioPageState extends State<CertAudioPage> {
  late final LecturePlaylist? _pl;

  @override
  void initState() {
    super.initState();
    _pl = lecturePlaylist;
    final pl = _pl;
    if (pl != null && pl.certCode != widget.cert.code) {
      pl.setQueue(widget.cert.code, approvedAudioEntries(widget.cert.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final pl = _pl;
    final tracks = approvedAudioEntries(widget.cert.code);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppHeader.document(
        backLabel: widget.cert.code,
        title: '오디오 강의',
      ),
      bottomNavigationBar: pl == null ? null : LectureTransportBar(playlist: pl),
      body: pl == null
          ? Center(
              child: Text('오디오는 웹에서만 재생할 수 있습니다.',
                  style: TextStyle(color: c.textMuted)))
          : ListenableBuilder(
              listenable: pl,
              builder: (context, _) => ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                itemCount: tracks.length,
                itemBuilder: (context, i) => _TrackRow(
                  index: i,
                  entry: tracks[i],
                  current: pl.index == i,
                  onPlay: () => pl.select(i),
                  onOpenDoc: () => context.go(
                      '/cert/${widget.cert.code}/study/${tracks[i].taskId}'),
                ),
              ),
            ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.index,
    required this.entry,
    required this.current,
    required this.onPlay,
    required this.onOpenDoc,
  });

  final int index;
  final ContentEntry entry;
  final bool current;
  final VoidCallback onPlay;
  final VoidCallback onOpenDoc;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: current ? c.surface2 : null,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FocusRing(
              borderRadius: BorderRadius.circular(Radii.sm),
              child: InkWell(
                onTap: onPlay,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Gap.lg, vertical: Gap.md),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text('${index + 1}',
                            style: TextStyle(
                                fontSize: 13,
                                color: c.textMuted),
                            textAlign: TextAlign.right),
                      ),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: Text(
                          entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                current ? FontWeight.w700 : FontWeight.w500,
                            fontVariations:
                                current ? Wght.w700 : Wght.w500,
                            color: current ? c.accent : c.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FocusRing(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: InkWell(
              onTap: onOpenDoc,
              borderRadius: BorderRadius.circular(Radii.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Gap.lg, vertical: Gap.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description_outlined,
                        size: 16, color: c.textMuted),
                    const SizedBox(width: 4),
                    Text('문서 보기',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontVariations: Wght.w600,
                            color: c.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
