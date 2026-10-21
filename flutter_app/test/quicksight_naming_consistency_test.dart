import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// QuickSight 명칭 일관성 — **영구 회귀 가드** (2026-10-21).
///
/// 공식은 **`Amazon Quick`**(상위 서비스) 안의 **`Amazon Quick Sight`**(BI 기능)
/// 으로 적고, *"QuickSight continues as Amazon Quick Sight, a feature within
/// Quick"* 이라고 밝힌다. 기존 QuickSight API·SDK·연동은 변경 없이 동작한다.
/// 근거: https://docs.aws.amazon.com/quick/latest/userguide/what-is.html
///
/// ⚠️ **이 가드는 옛 표기를 금지하지 않는다.** 레포는 의도적으로 옛 이름을
/// 유지한다 — `clf/t3-7.md` 의 정직성 메모가 "CLF 에선 '대시보드·시각화·BI =
/// QuickSight' 로 기억하면 됩니다" 라고 적은 대로, AWS 시험이 개명보다 늦기
/// 때문이다. 그래서 요구하는 것은 **금지가 아니라 공존**이다:
///
///   옛 표기를 쓰는 문서에는 **현행 명칭이 같은 파일 안에 함께 있어야** 한다.
///
/// 그러면 학습자가 어느 문서에서 만나도 두 이름의 관계를 알 수 있고, 옛 이름을
/// 그대로 둬도 "없어진 서비스"로 오해하지 않는다.
void main() {
  const certs = <String>['clf', 'dea', 'saa', 'soa'];

  /// 옛 표기. 현행 명칭(`Quick Sight`)과 구분하려면 **공백 없는** 형태만 센다.
  const legacy = 'QuickSight';
  const current = 'Quick Sight';

  List<File> contentFiles() {
    final out = <File>[];
    for (final c in certs) {
      final dir = Directory('assets/content/$c');
      if (!dir.existsSync()) continue;
      for (final e in dir.listSync()) {
        if (e is File &&
            (e.path.endsWith('.md') || e.path.endsWith('.questions.json'))) {
          out.add(e);
        }
      }
    }
    return out;
  }

  test('옛 표기를 쓰는 콘텐츠 파일에는 현행 명칭이 함께 있다', () {
    final offenders = <String>[];
    for (final f in contentFiles()) {
      final t = f.readAsStringSync();
      if (t.contains(legacy) && !t.contains(current)) {
        offenders.add(f.path.replaceAll('\\', '/'));
      }
    }
    expect(offenders, isEmpty,
        reason: '옛 표기 `$legacy` 만 있고 현행 명칭 `$current` 가 없는 파일 — '
            '학습자가 두 이름의 관계를 알 수 없다:\n  ${offenders.join('\n  ')}');
  });

  test('서비스를 주제로 다루는 문서는 개명 관계를 설명한다', () {
    // 이 서비스가 **설명 대상**인 문서들. 단순 언급이 아니라 개명 관계를
    // 적어 둬야 학습자가 시험에서 어느 이름을 만나도 연결할 수 있다.
    const topicDocs = <String>[
      'assets/content/clf/t3-7.md',
      'assets/content/dea/dea-t3-2.md',
      'assets/content/saa/saa-t3-9.md',
      'assets/content/saa/saa-t4-5.md',
    ];
    for (final p in topicDocs) {
      final t = File(p).readAsStringSync();
      expect(t.contains('Amazon Quick'), isTrue,
          reason: '$p 에 상위 서비스 `Amazon Quick` 설명이 없다');
      expect(t.contains(current), isTrue,
          reason: '$p 에 현행 명칭 `Amazon $current` 가 없다');
    }
  });

  test('개명을 상위·하위 구분 없이 뭉개지 않는다', () {
    // 공식: Quick 은 **상위 서비스**이고 QuickSight 는 그 안의 **Quick Sight**
    //       기능으로 이어진다. "QuickSight가 Amazon Quick이 됐다"는 틀렸다.
    for (final f in contentFiles()) {
      final t = f.readAsStringSync();
      final p = f.path.replaceAll('\\', '/');
      expect(t.contains('QuickSight가 Amazon Quick으로 이름이 바뀌'), isFalse,
          reason: '$p — Quick 은 상위 서비스다');
      expect(t.contains('QuickSight → Amazon Quick'), isFalse, reason: p);
      expect(t.contains('QuickSight는 Amazon Quick으로 대체'), isFalse,
          reason: '$p — 대체가 아니라 그 안의 기능으로 이어진다');
    }
  });

  test('API·SDK 가 그대로 동작한다는 사실이 주제 문서에 있다', () {
    // 시험·실무 모두에서 중요한 비자명한 사실이다 — 개명됐지만 기존
    // QuickSight API·SDK·연동은 변경 없이 동작한다.
    const mustSayApi = <String>[
      'assets/content/clf/t3-7.md',
      'assets/content/dea/dea-t3-2.md',
      'assets/content/saa/saa-t3-9.md',
    ];
    for (final p in mustSayApi) {
      final t = File(p).readAsStringSync();
      expect(t.contains('API'), isTrue, reason: '$p 에 API 무변경 서술이 없다');
    }
  });
}
