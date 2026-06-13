import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 홈 푸터(PR4 분해 — home_page.dart에서 이동).
class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Gap.xl3),
      padding: const EdgeInsets.only(top: Gap.xl),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Text(
        '비공식 학습 사이트 · 응시 전 반드시 AWS 공식 시험 가이드를 단일 진실 공급원으로 확인하세요.',
        style: TextStyle(fontSize: 13, color: c.textFaint),
      ),
    );
  }
}
