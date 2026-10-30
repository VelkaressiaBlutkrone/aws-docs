import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/material.dart' show TextTheme;
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// M-6 가드 — 텍스트로 쓰는 색 조합은 WCAG 2.x AA(일반 텍스트 4.5:1)를 넘긴다.
///
/// 리뷰(2026-09-22 §M-6·부록 A)가 라이트 `textFaint` 2.98 · `warning` 텍스트 3.49 ·
/// `correct` 라벨 3.83을 실측해 AA 미달로 적었다. 숫자를 문서에 적어 두는 것으로는
/// 회귀를 막지 못하므로 계산을 테스트로 들여온다.

/// WCAG 2.x 상대 휘도.
double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

/// 대비비(1~21).
double contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// 텍스트로 실제 쓰이는 전경/배경 쌍.
List<(String, Color, Color)> _textPairs(AppColors c) => [
      ('text / bg', c.text, c.bg),
      ('text / surface', c.text, c.surface),
      ('textMuted / bg', c.textMuted, c.bg),
      ('textMuted / surface', c.textMuted, c.surface),
      ('textMuted / surface2', c.textMuted, c.surface2),
      ('accent / bg', c.accent, c.bg),
      ('accent / surface', c.accent, c.surface),
      // ⚠️ `accent / surface2`는 **여기 없다** — 라이트에서 4.21로 AA 미달이다.
      // surface2 패널의 액센트 텍스트는 accentStrong을 쓴다(아래 규칙 테스트).
      ('accentStrong / bg', c.accentStrong, c.bg),
      ('accentStrong / surface', c.accentStrong, c.surface),
      ('accentStrong / surface2', c.accentStrong, c.surface2),
      ('onAccent / accent', c.onAccent, c.accent),
      ('accentStrong / accentWeak', c.accentStrong, c.accentWeak),
      ('correct / bg', c.correct, c.bg),
      ('correct / surface', c.correct, c.surface),
      ('correct / correctWeak', c.correct, c.correctWeak),
      ('wrong / surface', c.wrong, c.surface),
      ('wrong / wrongWeak', c.wrong, c.wrongWeak),
      ('info / infoWeak', c.info, c.infoWeak),
      ('warningText / bg', c.warningText, c.bg),
      ('warningText / surface', c.warningText, c.surface),
      ('warningText / surface2', c.warningText, c.surface2),
      ('warningText / warningWeak', c.warningText, c.warningWeak),
      ('onInk / ink', c.onInk, c.ink),
    ];

void main() {
  group('대비 계산 자체', () {
    test('대조군: 흑/백은 21, 같은 색은 1', () {
      expect(contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
          closeTo(21, 0.01));
      expect(contrast(const Color(0xFF123456), const Color(0xFF123456)),
          closeTo(1, 0.001));
    });

    test('⚠️ 정정 전 값이 실제로 미달이었음을 고정한다 — 가드가 민감한지 보는 대조군', () {
      const bg = Color(0xFFFBFAF8);
      expect(contrast(const Color(0xFF8A93A0), bg), closeTo(2.98, 0.01)); // 옛 textFaint
      expect(contrast(const Color(0xFFB7791F), bg), closeTo(3.49, 0.01)); // warning
      expect(contrast(const Color(0xFF1F8A52), const Color(0xFFE5F4EA)),
          closeTo(3.83, 0.01)); // 옛 correct / correctWeak
    });
  });

  group('AA 4.5:1', () {
    for (final (name, colors) in [
      ('light', AppColors.light),
      ('dark', AppColors.dark),
    ]) {
      for (final (label, fg, bg) in _textPairs(colors)) {
        test('$name $label', () {
          final r = contrast(fg, bg);
          expect(r, greaterThanOrEqualTo(4.5),
              reason: '$name $label = ${r.toStringAsFixed(2)} — AA 미달');
        });
      }
    }
  });

  test('⚠️ accent는 surface2 위 텍스트로 쓰지 않는다 — 4.21로 AA 미달이다', () {
    // 리뷰 부록 A가 빠뜨린 조합이다(accent/surface 4.76만 적혀 있었다). 실제로 홈 due
    // 배너·약점 리포트·요약 패널·동기 진입 등 **surface2 패널 7곳이 accent 텍스트**를
    // 쓰고 있었고, 전부 accentStrong으로 옮겼다(라이트 5.65 · 다크 7.34).
    // 브랜드 액센트 값(#0E8175)은 건드리지 않는다 — DESIGN.md의 중심 결정이다.
    expect(contrast(AppColors.light.accent, AppColors.light.surface2),
        lessThan(4.5));
    expect(contrast(AppColors.light.accentStrong, AppColors.light.surface2),
        greaterThanOrEqualTo(4.5));
    // 아이콘·점·진행 바로는 그대로 쓸 수 있다(비텍스트 3:1).
    expect(contrast(AppColors.light.accent, AppColors.light.surface2),
        greaterThanOrEqualTo(3.0));
  });

  group('비텍스트 3:1 (WCAG 1.4.11) — warning은 아이콘·테두리로 남는다', () {
    test('warning / bg', () {
      expect(contrast(AppColors.light.warning, AppColors.light.bg),
          greaterThanOrEqualTo(3.0));
      expect(contrast(AppColors.dark.warning, AppColors.dark.bg),
          greaterThanOrEqualTo(3.0));
    });
  });

  test('labelSmall 기본색은 textMuted다 — 12px 텍스트가 textFaint를 상속하지 않는다', () {
    for (final (theme, colors) in [
      (AppTheme.light, AppColors.light),
      (AppTheme.dark, AppColors.dark),
    ]) {
      final TextTheme t = theme.textTheme;
      expect(t.labelSmall?.color, colors.textMuted);
      expect(t.labelSmall?.color, isNot(colors.textFaint));
    }
  });

  test('⚠️ textFaint는 텍스트에 쓰지 않는다 — 비활성·장식만', () {
    // 원칙(M-6 B안): 14px 이하 본문 텍스트에 textFaint 금지, 텍스트는 textMuted.
    // 남은 사용처는 WCAG 1.4.3이 대비 요건에서 제외하는 **비활성 컴포넌트**와
    // 순수 장식뿐이다. 새 파일이 textFaint로 텍스트를 그리면 이 단정이 먼저 깨진다.
    //
    // ⚠️ 한계: 파일 단위라, 이미 목록에 있는 파일 **안에서** 새 텍스트가 textFaint를
    // 쓰는 것은 잡지 못한다. 그 경우는 위 AA 단정이 아니라 리뷰가 잡아야 한다.
    const allowed = {
      'lib/content/quiz_widgets.dart': '비활성 버튼 라벨',
      'lib/pages/cert_detail/learning_content_section.dart': '잠긴 Task',
      'lib/pages/home/exams_section.dart': '잠긴 모의고사',
      'lib/pages/plan/plan_agenda.dart': '플랜 범위 밖 날짜',
      'lib/widgets/app_header.dart': '브레드크럼 구분 슬래시(장식)',
      'lib/widgets/lecture_transport_bar.dart': '비활성 트랜스포트 버튼',
    };

    final found = <String>{};
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final rel = f.path.replaceAll(r'\', '/');
      if (rel == 'lib/theme/app_theme.dart') continue; // 토큰 정의 자체
      if (f.readAsStringSync().contains('textFaint')) found.add(rel);
    }

    expect(found, allowed.keys.toSet(),
        reason: 'textFaint 사용 파일이 비활성·장식 허용 목록과 달라졌다');
  });
}
