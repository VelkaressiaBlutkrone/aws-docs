import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/cert_lookup.dart';
import '../data/content_index.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/focus_ring.dart';

/// 오디오 허브 — 승인 오디오 강의를 가진 자격증 목록. 각 항목 → /cert/:code/audio.
class AudioHubPage extends StatelessWidget {
  const AudioHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final codes = certsWithApprovedAudio();
    return Scaffold(
      backgroundColor: c.bg,
      appBar: const AppHeader.document(title: '오디오 강의'),
      body: ListView(
        padding: const EdgeInsets.all(Gap.lg),
        children: [
          for (final code in codes)
            _CertCard(
              code: code,
              count: approvedAudioEntries(code).length,
              onTap: () => context.go('/cert/$code/audio'),
            ),
        ],
      ),
    );
  }
}

class _CertCard extends StatelessWidget {
  const _CertCard(
      {required this.code, required this.count, required this.onTap});

  final String code;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cert = certByCode(code);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: FocusRing(
        borderRadius: BorderRadius.circular(Radii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.md),
          child: Container(
            padding: const EdgeInsets.all(Gap.lg),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(Icons.headphones_outlined, size: 22, color: c.accent),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cert?.code ?? code,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontVariations: Wght.w700,
                              color: c.text)),
                      const SizedBox(height: 2),
                      Text('강의 $count개',
                          style:
                              TextStyle(fontSize: 13, color: c.textMuted)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: c.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
