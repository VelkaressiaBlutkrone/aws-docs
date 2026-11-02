import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/question.dart';
import 'content_index.dart';

/// 에셋 문자열 로더. 테스트에서 주입해 **요청 자체**(개수·순서·동시성)를 볼 수 있게 한다.
typedef AssetStringLoader = Future<String> Function(String key);

/// 한 Task의 엔트리와 그 문항 뱅크 쌍.
typedef LoadedBank = ({ContentEntry entry, QuestionBank bank});

/// 여러 Task의 문항 뱅크를 **병렬로** 읽어 `entries` 순서대로 돌려준다.
///
/// 이 함수가 두 가지 규율을 한 곳에 모은다(리뷰 M-4 / `CODE-P-012`):
///
/// 1. ⚠️ **`hasQuestions`가 false인 Task는 요청하지 않는다** — 학습문서만 있는
///    Task에는 `questions.json`이 없어 배포본에서 404가 난다. 호출부 네 곳 중
///    셋에서 이 가드가 빠져 있었다(드리프트). 가드는 `question_banks_test.dart`.
/// 2. **직렬 `await` 루프를 쓰지 않는다** — 뱅크가 19~24개라 직렬이면 첫 진입이
///    N×RTT였다. `Future.wait`은 입력 순서를 보존하므로 병렬로 바꿔도 뱅크
///    순서(시험 구성·보고서 정렬에 쓰인다)는 그대로다.
///
/// 개별 뱅크의 로드·파싱 실패는 **그 뱅크만 빼고** 나머지로 진행한다.
Future<List<LoadedBank>> loadQuestionBanks(
  Iterable<ContentEntry> entries, {
  AssetStringLoader? loadString,
}) async {
  final load = loadString ?? rootBundle.loadString;
  final targets = [
    for (final e in entries)
      if (e.hasQuestions) e,
  ];
  if (targets.isEmpty) return const [];

  final banks = await Future.wait(targets.map((e) => _loadOne(e, load)));
  return [
    for (var i = 0; i < targets.length; i++)
      if (banks[i] != null) (entry: targets[i], bank: banks[i]!),
  ];
}

Future<QuestionBank?> _loadOne(ContentEntry e, AssetStringLoader load) async {
  try {
    final raw = await load(e.questionsAsset);
    return QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
  } catch (_) {
    return null; // 개별 실패는 무시(나머지로 진행)
  }
}
