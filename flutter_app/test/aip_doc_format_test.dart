import 'dart:io';

import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// AIP-C01 학습문서 포맷 가드 — SCS 판(`scs_doc_format_test.dart`)을 옮겼다.
///
/// ⚠️ `content_enrichment_test`는 **명시 허용 목록**(clf·saa·soa)이라 신규 자격증을
/// 강제하지 않는다. 그래서 MLA·DVA·AIF·SCS가 각자 포맷 가드를 뒀고 AIP도 그렇게 한다.
///
/// 포맷 네 줄의 유래는 2026-10-26 MLA 외부 리뷰 3건 + AIF D-05다:
///   ① 자가 점검에 정답이 없다 → 접이식 `<details>` 정답을 요구
///   ② "시험 직전 요약"이 없다 → 전용 절을 요구
///   ③ 학습 목표가 너무 길다 → 항목 수 상한 8
///   ④ 도메인 이름을 저작자가 임의로 바꿔 쓴다 → 공식 이름과 대조
/// 다섯 번째(시험 형식 중복 금지)도 AIF에서 가져왔다.
///
/// ⚠️ **AIP는 도메인이 5개**이고 **Task가 20개**(6·5·4·3·2)다. 도메인 이름의 정본은
/// `assets/exam_guides/AIP-C01.json`이고 그 JSON은 2026-11-13 P-02에서 공식과
/// **70/70 바이트 일치**로 맞춰 뒀다. 아래 표는 그 JSON에서 **기계 추출**한 것이다
/// (2026-11-14 — 손으로 적으면 틀린다: SCS에서 Task 제목 20줄 중 17줄이 틀렸다).
///
/// ⚠️ **목록은 배치마다 늘린다.** 저작된 Task만 올린다. 문항 가드
/// `aip_questions_test.dart`는 **이미 있고**(2026-11-13 P-04) 저작 선언이 따로이므로
/// 문항 배치에서는 그쪽 `authoredTaskIds`를 늘린다 — 두 파일의 목록이 **다른 것을
/// 센다**(이 파일은 학습문서, 그 파일은 문항).
void main() {
  // 2026-11-14 도메인 1 전체(작업 1.1~1.6) + 도메인 2 배치 1(작업 2.1·2.5).
  //
  // ⚠️ 도메인 2는 기술이 **25개**(7·3·5·4·6)이고 깊이 노트 `94`가 **2.1(7)·2.5(6)만**
  // 측정해 뒀다. 그 둘을 한 배치로 묶은 이유는 **같은 프레임워크를 양쪽에서 인용**하기
  // 때문이다(`기술 2.1.1`·`2.5.5`가 둘 다 Strands·Agent Squad를 든다) — SCS 도메인 3에서
  // 네 편을 병렬로 쓰다 서로 어긋난 서술이 같은 PR에 들어온 일이 있었다.
  // 🏁 2026-11-14 **도메인 2 완료** — 배치 1(2.1·2.5, 깊이 노트 `94` 축) ·
  // 배치 2(2.2·2.4, 모델 서빙 + API 계층) · 배치 3(2.3, 하이브리드·엣지·ID·CI/CD).
  // 서비스 집합으로 가른 이유는 **같은 서비스를 인용하는 편을 한 PR에 묶어 교차 대조**
  // 하기 위해서다(SCS 도메인 3에서 네 편을 병렬로 쓰다 서술이 어긋난 선례).
  const aipTaskIds = [
    'aip-t1-1', 'aip-t1-2', 'aip-t1-3',
    'aip-t1-4', 'aip-t1-5', 'aip-t1-6',
    'aip-t2-1', 'aip-t2-2', 'aip-t2-3', 'aip-t2-4', 'aip-t2-5',
  ];

  /// 한 Task의 **저작된 전 텍스트** — 학습문서 `.md` + 문항 `.questions.json`.
  ///
  /// ⚠️⚠️ 아래 「저작 규율」 가드가 보는 범위다. SCS에서 같은 가드들이 `.md`만
  /// 순회해 **문항이 같은 이름을 상태 없이 써도 초록**이던 결함이 세 번 반복됐고,
  /// 2026-11-10에 **읽는 함수 하나를 넓혀** 구조적으로 닫았다. AIP는 그 해법을
  /// 처음부터 쓴다 — 문항 파일이 아직 없어도 `existsSync`로 건너뛴다.
  /// ⚠️ 새 종류의 파일(대본·요약 등)이 Task 단위로 들어오면 **여기를 늘린다.**
  String? authoredTextOf(String taskId) {
    final parts = <String>[];
    for (final path in [
      'assets/content/aip/$taskId.md',
      'assets/content/aip/$taskId.questions.json',
    ]) {
      final f = File(path);
      if (f.existsSync()) parts.add(f.readAsStringSync());
    }
    return parts.isEmpty ? null : parts.join('\n');
  }

  const maxObjectives = 8;
  const maxSummaryBullets = 10;

  // 공식 도메인 이름 (`AIP-C01.json` = 공식 가이드 전사. 2026-11-14 기계 추출).
  const domainNames = <String, String>{
    '1': '파운데이션 모델 통합, 데이터 관리 및 규정 준수',
    '2': '구현 및 통합',
    '3': 'AI 안전, 보안 및 거버넌스',
    '4': 'GenAI 애플리케이션을 위한 운영 효율성 및 최적화',
    '5': '테스트, 검증 및 문제 해결',
  };

  for (final taskId in aipTaskIds) {
    group(taskId, () {
      final path = 'assets/content/aip/$taskId.md';
      String raw() => File(path).readAsStringSync();

      test('학습 목표 체크리스트가 $maxObjectives개 이하다', () {
        final blocks = parseStudyDoc(raw()).blocks;
        final checklists = blocks.whereType<MdChecklist>().toList();
        expect(checklists, isNotEmpty, reason: '$taskId: 학습 목표 체크리스트가 없다');
        final count = checklists.first.items.length;
        expect(count, lessThanOrEqualTo(maxObjectives),
            reason: '$taskId: 학습 목표 $count개 — $maxObjectives개 이하로 압축하고 '
                '세부는 각 절로 넘긴다');
      });

      test('"시험 직전 요약" 절이 있고 불릿이 $maxSummaryBullets개 이하다', () {
        final blocks = parseStudyDoc(raw()).blocks;
        final idx = blocks.indexWhere(
            (b) => b is MdHeading && b.text.contains('시험 직전 요약'));
        expect(idx, isNot(-1),
            reason: '$taskId: "시험 직전 요약" 절이 없다 — 시험 포인트 앞에 둔다');

        var bullets = 0;
        for (var i = idx + 1; i < blocks.length; i++) {
          final b = blocks[i];
          if (b is MdHeading && b.level <= 2) break;
          if (b is MdBullets) bullets += b.items.length;
        }
        expect(bullets, inInclusiveRange(1, maxSummaryBullets),
            reason: '$taskId: 요약 불릿 $bullets개 — 1~$maxSummaryBullets개여야 한다');
      });

      test('자가 점검의 모든 질문에 접이식 정답이 붙어 있다', () {
        final text = raw();
        final start = text.indexOf('## 🧪 자가 점검');
        expect(start, isNot(-1), reason: '$taskId: 자가 점검 절이 없다');
        final after = text.indexOf('\n## ', start + 1);
        final section =
            after == -1 ? text.substring(start) : text.substring(start, after);

        final questions = RegExp(r'^\*\*Q\d+\.\*\*', multiLine: true)
            .allMatches(section)
            .length;
        final answers =
            RegExp(r'^<details><summary>정답 보기</summary>', multiLine: true)
                .allMatches(section)
                .length;
        final closes =
            RegExp(r'^</details>', multiLine: true).allMatches(section).length;

        expect(questions, greaterThanOrEqualTo(5),
            reason: '$taskId: 자가 점검 질문 $questions개 — "**Qn.**" 형식으로 5개 이상');
        expect(answers, questions,
            reason: '$taskId: 질문 $questions개 vs 접이식 정답 $answers개');
        expect(closes, answers,
            reason: '$taskId: </details> 닫힘 $closes개 ≠ 열림 $answers개');

        final details =
            parseStudyDoc(text).blocks.whereType<MdDetails>().toList();
        expect(details.length, greaterThanOrEqualTo(questions),
            reason: '$taskId: 파서가 인식한 MdDetails ${details.length}개 '
                '< 질문 $questions개');
        expect(details.every((d) => d.summary.isNotEmpty), isTrue,
            reason: '$taskId: summary가 빈 접이식 블록이 있다');
        expect(details.every((d) => d.body.isNotEmpty), isTrue,
            reason: '$taskId: 본문이 빈 접이식 블록이 있다');
      });

      test('프런트매터의 domainName이 공식 도메인 이름과 같다', () {
        final text = raw();
        final domain = RegExp(r'^domain:\s*(\d)\s*$', multiLine: true)
            .firstMatch(text)
            ?.group(1);
        expect(domain, isNotNull, reason: '$taskId: 프런트매터에 domain이 없다');
        final name = RegExp(r'^domainName:\s*(.+)$', multiLine: true)
            .firstMatch(text)
            ?.group(1)
            ?.trim();
        expect(name, domainNames[domain],
            reason: '$taskId: domainName="$name" — 공식 도메인 이름은 '
                '"${domainNames[domain]}"이다(`AIP-C01.json`이 정본)');
      });
    });
  }

  // 공식 문항 유형 2종(선다형·복수 응답형) 설명은 **도메인 1 첫 편에만** 둔다
  // (AIF 저작 결정 D-05의 AIP 판 = D-04). 20편에 반복하면 소음이 되고, 빠지면
  // 응시자가 시험장에서 처음 본다. ⚠️ AIF는 4종, SCS는 4종이었고 **AIP는 2종**이다 —
  // 자격증마다 다르므로 베끼지 않고 가이드를 읽는다.
  test('시험 형식 안내는 aip-t1-1에만 있다', () {
    const marker = '## 🧭 시험 형식';
    final t11 = File('assets/content/aip/aip-t1-1.md').readAsStringSync();
    expect(t11.contains(marker), isTrue,
        reason: 'aip-t1-1: 시험 형식 절이 없다 — 문항 유형 2종과 채점 규칙은 '
            '도메인 1 첫 편에서 한 번 설명한다');

    for (final taskId in aipTaskIds.where((t) => t != 'aip-t1-1')) {
      final f = File('assets/content/aip/$taskId.md');
      if (!f.existsSync()) continue;
      expect(f.readAsStringSync().contains(marker), isFalse,
          reason: '$taskId: 시험 형식 절이 중복됐다 — aip-t1-1에만 둔다');
    }
  });

  // ── 저작 규율 (D-07·D-13의 AIP 판) ───────────────────────────────────────
  //
  // 공식 기술 본문이 **이름으로 드는 서비스·기능 가운데 상태가 바뀐 것**이 있다.
  // 상태를 적지 않으면 학습자가 **대체된 쪽을 현행으로** 배운다. 규칙은 전부
  // **자격증 전수 집계**다 — 2026-11-06 AIF에서 파일별 리터럴 가드가 어형 하나로
  // 뚫려 라이브에 오류가 남은 뒤로 사실 단정은 저작된 전 텍스트를 센다.

  test('`Data Wrangler`를 언급하는 문서는 접근 경로(Canvas)를 함께 적는다', () {
    // `기술 1.3.1`이 「SageMaker Data Wrangler」를 예시로 드는데, 새 Studio 경험은
    // **클래식 Data Wrangler UI를 지원하지 않고** Canvas 애플리케이션을 만들어야
    // 한다(공식 `canvas-data-prep.html` Note · `studio-updated-migrate-ui.html`).
    // ⚠️ 닫힌 서비스가 아니라 **접근 경로가 접힌** 것이다 — AIF §P1b-A4와 같은 계열.
    var checked = 0;
    for (final taskId in aipTaskIds) {
      final text = authoredTextOf(taskId);
      if (text == null || !text.contains('Data Wrangler')) continue;
      checked++;
      expect(text.contains('Canvas'), isTrue,
          reason: '$taskId: `Data Wrangler`를 적으면서 `Canvas`를 적지 않았다 — '
              '새 Studio는 클래식 Data Wrangler UI를 지원하지 않는다');
    }
    expect(checked, greaterThanOrEqualTo(1),
        reason: '대조군: `Data Wrangler`를 언급하는 문서가 하나도 없다 — '
            '탐지기가 작동하지 않는 상태로 이 가드가 통과하고 있다');
  });

  test('`Well-Architected Agent`를 언급하는 문서는 프리뷰임을 적는다', () {
    // `기술 1.1.3`이 「AWS WA Tool」을 드는데 공식 what-is 페이지가
    // `AWS Well-Architected Agent is in preview release and is subject to change.`
    // 를 적는다(96 §6-6). 시험이 묻는 쪽은 **Tool**이다.
    // ⚠️ 트리거를 `Well-Architected`로 넓히면 정상인 Framework·렌즈까지 걸린다 —
    // **기능 이름으로 좁힌다**(D-13).
    for (final taskId in aipTaskIds) {
      final text = authoredTextOf(taskId);
      if (text == null || !text.contains('Well-Architected Agent')) continue;
      expect(text.contains('프리뷰'), isTrue,
          reason: '$taskId: `Well-Architected Agent`를 적으면서 프리뷰임을 '
              '적지 않았다 — 시험이 묻는 쪽은 Tool이다');
    }
  });

  test('`Agents Classic`을 언급하는 문서는 신규 고객 상태를 함께 적는다', () {
    // `기술 2.1.1`·`2.5.5`가 에이전트 오케스트레이션을 묻는 자리라 저작자가
    // `Amazon Bedrock Agents`를 그대로 쓰기 쉽다. 공식 전용 페이지 첫 문단이
    // `Amazon Bedrock Agents (launched November 2023) is now Amazon Bedrock Agents
    // Classic and will no longer be open to new customers starting on July 30, 2026.`
    // 이므로 **새 설계의 답으로 가리키면 거짓**이 된다(94 §4).
    // ⚠️ 트리거를 `Bedrock`으로 넓히면 안 된다 — 같은 페이지 Note가
    // `Amazon Bedrock continues to be fully supported`와 기존 모델·지식 베이스·
    // Guardrails는 영향받지 않는다를 명시한다. 대상은 **`Agents Classic`뿐**이다(D-13).
    // ⚠️ **날짜는 요구하지 않는다** — 집계표(2026-06-30)와 전용 페이지(2026-07-30)가
    // 어긋나 있어 묻지 않는 쪽으로 분류했다(99-gaps **G-24**).
    var checked = 0;
    for (final taskId in aipTaskIds) {
      final text = authoredTextOf(taskId);
      if (text == null || !text.contains('Agents Classic')) continue;
      checked++;
      expect(text.contains('신규 고객'), isTrue,
          reason: '$taskId: `Agents Classic`을 적으면서 신규 고객에게 열려 있지 '
              '않다는 상태를 적지 않았다');
    }
    expect(checked, greaterThanOrEqualTo(1),
        reason: '대조군: `Agents Classic`을 언급하는 문서가 하나도 없다 — '
            '탐지기가 작동하지 않는 상태로 이 가드가 통과하고 있다');
  });

  test('Classic 이벤트 버스를 언급하면 새 애플리케이션 권고를 함께 적는다', () {
    // `기술 2.3.2`가 「이벤트 기반 통합 구현에 Amazon EventBridge 사용」으로만 적는데,
    // 공식 `eb-event-bus.html`(2026-11-14 실측)이 그 장을 **기본 버스와
    // `Custom Event Bus - Classic`**으로 한정하고 **`For new applications, start with
    // the Custom Event Bus.`**를 적는다(구독자 모델 + 리플레이용 이벤트 보존 ·
    // 기존 규칙을 옮기는 마이그레이션 안내 별도).
    // ⚠️ **닫힌 서비스가 아니라 권고가 바뀐 것**이다 — 상태 메모가 아니라 **권고**를
    // 요구한다. ⚠️ 트리거를 `Classic`만으로 넓히면 `Agents Classic`·`Inspector
    // Classic` 같은 다른 계열이 걸린다 — **이벤트 버스 문맥으로 좁힌다**(D-13).
    var checked = 0;
    for (final taskId in aipTaskIds) {
      final text = authoredTextOf(taskId);
      if (text == null) continue;
      if (!text.contains('Custom Event Bus - Classic') &&
          !text.contains('Classic 이벤트 버스')) {
        continue;
      }
      checked++;
      expect(text.contains('Custom Event Bus') && text.contains('시작'), isTrue,
          reason: '$taskId: Classic 이벤트 버스를 적으면서 새 애플리케이션은 '
              '`Custom Event Bus`로 시작하라는 공식 권고를 적지 않았다');
    }
    expect(checked, greaterThanOrEqualTo(1),
        reason: '대조군: Classic 이벤트 버스를 언급하는 문서가 하나도 없다 — '
            '탐지기가 작동하지 않는 상태로 이 가드가 통과하고 있다');
  });

  test('사용자 지정 모델 + 프로비저닝 처리량을 다루면 경로가 둘임을 적는다', () {
    // ⚠️⚠️⚠️ AIF 트랙이 **세 번 고쳤다고 보고한 뒤에도 라이브에 남아 있던** 오류다
    // (99-gaps G-19 → G-37 → G-46). 공식 자신이 갈려 있어서 새어 나간다:
    //   · `prov-throughput.html`(2026-11-14 실측) — `If you customized a model, you
    //     must purchase Provisioned Throughput to be able to use it.`
    //   · `model-customization-use.html` — 경로가 **둘**(PT 구매 / 온디맨드 배포)
    // AIF 판 가드는 **리터럴 금지**였고 「프로비저닝**된** 처리량」의 「된」 한 글자와
    // 어미·조사로 뚫렸다. 그래서 AIP 판은 **금지가 아니라 요구**로 뒤집는다 —
    // 두 주제를 함께 다루는 문서는 **두 경로를 적어야** 한다. 어형에 둔감하고,
    // 옛 문구를 인용해 정정하는 줄을 죽이지 않는다(그 줄도 「둘」을 함께 적는다).
    // ⚠️ 트리거를 `프로비저닝`만으로 넓히면 **서버리스의 프로비저닝된 동시성**과
    // **PT 일반 서술**까지 걸린다 — `사용자 지정 모델`과의 **동시 등장**으로 좁힌다.
    final twoPaths = RegExp(r'(경로는?\s*\*{0,2}둘|둘\*{0,2}입니다|거짓입니다)');
    var checked = 0;
    for (final taskId in aipTaskIds) {
      final text = authoredTextOf(taskId);
      if (text == null) continue;
      if (!text.contains('사용자 지정 모델')) continue;
      if (!text.contains('프로비저닝') || !text.contains('처리량')) continue;
      checked++;
      expect(twoPaths.hasMatch(text), isTrue,
          reason: '$taskId: 사용자 지정 모델과 프로비저닝 처리량을 함께 다루면서 '
              '추론 경로가 **둘**(PT 구매 / 온디맨드 배포)임을 적지 않았다 — '
              '공식 PT 페이지는 아직 「PT를 사야 쓸 수 있다」고 적어 문서 사이가 갈린다');
    }
    expect(checked, greaterThanOrEqualTo(2),
        reason: '대조군: 두 주제를 함께 다루는 문서가 2편 미만이다 — '
            '탐지기가 작동하지 않는 상태로 이 가드가 통과하고 있다');
  });

  test('`Q Developer` IDE 플러그인을 언급하면 지원 종료와 대안을 함께 적는다', () {
    // `기술 2.5.4`가 「코드 생성 및 리팩터링에 Amazon Q Developer 사용」으로 적지만
    // 공식 개요 페이지가 **IDE 플러그인 2027-04-30 지원 종료**와
    // `For capabilities similar to Amazon Q Developer IDE plugins, explore Kiro`를
    // 적는다(96 §6-3 · 99-gaps **G-15**·**G-16**).
    // ⚠️ **콘솔 쪽은 개명됐을 뿐이라** 트리거를 `Q Developer`로 넓히면 멀쩡한 서술이
    // 걸린다 — **`IDE 플러그인`이라는 기능 이름으로 좁힌다**(D-13).
    var checked = 0;
    for (final taskId in aipTaskIds) {
      final text = authoredTextOf(taskId);
      if (text == null) continue;
      if (!text.contains('Q Developer') || !text.contains('IDE 플러그인')) continue;
      checked++;
      expect(text.contains('지원 종료'), isTrue,
          reason: '$taskId: Q Developer IDE 플러그인을 적으면서 지원 종료를 '
              '적지 않았다 — 대체된 쪽을 정답으로 가르치게 된다');
      expect(text.contains('Kiro'), isTrue,
          reason: '$taskId: 공식이 드는 대안 `Kiro`를 적지 않았다');
    }
    expect(checked, greaterThanOrEqualTo(1),
        reason: '대조군: Q Developer IDE 플러그인을 언급하는 문서가 하나도 없다 — '
            '탐지기가 작동하지 않는 상태로 이 가드가 통과하고 있다');
  });

  test('용어는 공식 표기 `GenAI`·`FM`을 쓰고 「생성형 AI」를 사실 서술에 쓰지 않는다', () {
    // 저작 결정 **D-03** — 공식 ko 가이드 본문 전수에서 `GenAI` 34건 · `FM` 95건 ·
    // 「생성형」 **0건**이다. 도메인 4의 이름 자체가 「**GenAI** 애플리케이션을 위한…」
    // 이므로 이 자격증의 표기는 `GenAI`다.
    // ⚠️ 제품 고유명 `Generative AI Lens`는 **영문**이라 이 규칙에 걸리지 않는다 —
    // 한국어로 「생성형 AI 렌즈」라고 옮기면 걸린다(그것이 의도다).
    var canonical = 0;
    for (final taskId in aipTaskIds) {
      final text = authoredTextOf(taskId);
      if (text == null) continue;
      if (text.contains('GenAI')) canonical++;
      expect(text.contains('생성형 AI'), isFalse,
          reason: '$taskId: 「생성형 AI」는 공식 가이드 본문에 0건이다 — '
              'D-03대로 `GenAI`를 쓴다');
    }
    expect(canonical, greaterThanOrEqualTo(1),
        reason: '대조군: `GenAI`를 쓰는 문서가 하나도 없다 — 탐지기가 '
            '작동하지 않는 상태로 이 가드가 통과하고 있다');
  });
}
