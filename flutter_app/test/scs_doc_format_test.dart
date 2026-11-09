import 'dart:io';

import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// SCS-C03 학습문서 포맷 가드 — AIF 판(`aif_doc_format_test.dart`)을 옮겼다.
///
/// 포맷 세 줄은 2026-10-26 MLA 외부 리뷰 3건이 반복 지적한 것이다:
///   ① 자가 점검에 정답이 없다 → 접이식 `<details>` 정답을 요구
///   ② "시험 직전 요약"이 없다 → 전용 절을 요구
///   ③ 학습 목표가 너무 길다 → 항목 수 상한 8
///
/// 네 번째(`domainName`)와 다섯 번째(시험 형식 중복 금지)는 AIF에서 가져왔다.
/// SCS 가이드는 AIF와 달리 **도메인 이름을 한 가지로만** 적지만(2026-11-08 실측),
/// 선언을 두면 저작자가 도메인 이름을 임의로 바꿔 쓰는 것을 막는다. 도메인 이름의
/// 정본은 `assets/exam_guides/SCS-C03.json`이고 그 JSON은 2026-11-08 P-03에서
/// 공식과 **70/70 바이트 일치**로 맞춰 뒀다.
///
/// ⚠️ **SCS는 도메인이 6개다** — 이 레포에서 처음이다(다른 자격증은 4개, SOA·AIF가
/// 5개). 아래 표를 5개로 줄이면 도메인 6 문서가 조용히 가드를 비켜 간다.
///
/// ⚠️ **목록은 배치마다 늘린다.** 저작된 Task만 올린다(점진적 롤아웃 —
/// `content_enrichment_test`·`aif_doc_format_test` 패턴). 문항 가드
/// `scs_questions_test.dart`가 생기면 **두 파일의 목록을 모두** 늘려야 한다
/// (MLA에서 한쪽만 늘려 빠뜨린 적이 있다 — CLAUDE.md 기준선 메모).
///
/// ⚠️ `content_enrichment_test`는 **명시 허용 목록**(clf·saa·soa)이라 SCS를
/// 강제하지 않는다. 그래서 `###` 서브섹션마다 `> 🧠 원리:`를 요구하는 규칙은
/// 이 자격증에 적용되지 않는다(MLA·DVA·AIF도 그렇다).
void main() {
  // 2026-11-09 도메인 1·2·3·4·5 배치 — 공식 Task 16개 중 13개.
  const scsTaskIds = [
    'scs-t1-1', 'scs-t1-2', 'scs-t1-3',
    'scs-t2-1', 'scs-t2-2',
    'scs-t3-1', 'scs-t3-2', 'scs-t3-3',
    'scs-t4-1', 'scs-t4-2',
    'scs-t5-1', 'scs-t5-2', 'scs-t5-3',
  ];
  const maxObjectives = 8;
  const maxSummaryBullets = 10;

  // 공식 도메인 이름 (`SCS-C03.json` = 공식 가이드 전사, 2026-11-08 실측).
  const domainNames = <String, String>{
    '1': '탐지',
    '2': '인시던트 대응',
    '3': '인프라 보안',
    '4': 'ID 및 액세스 관리',
    '5': '데이터 보호',
    '6': '보안 기반 및 거버넌스',
  };

  for (final taskId in scsTaskIds) {
    group(taskId, () {
      final path = 'assets/content/scs/$taskId.md';
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
                '"${domainNames[domain]}"이다(`SCS-C03.json`이 정본)');
      });
    });
  }

  // 공식 답안 유형 4종 설명은 **도메인 1 첫 편에만** 둔다(AIF 저작 결정 D-05의 SCS 판).
  // 16편에 반복하면 소음이 되고, 빠지면 응시자가 시험장에서 처음 본다.
  test('시험 형식 안내는 scs-t1-1에만 있다', () {
    const marker = '## 🧭 시험 형식';
    final t11 = File('assets/content/scs/scs-t1-1.md').readAsStringSync();
    expect(t11.contains(marker), isTrue,
        reason: 'scs-t1-1: 시험 형식 절이 없다 — 답안 유형 4종과 채점 규칙은 '
            '도메인 1 첫 편에서 한 번 설명한다');

    for (final taskId in scsTaskIds.where((t) => t != 'scs-t1-1')) {
      final text = File('assets/content/scs/$taskId.md').readAsStringSync();
      expect(text.contains(marker), isFalse,
          reason: '$taskId: 시험 형식 절이 중복됐다 — scs-t1-1에만 둔다');
    }
  });

  // 2026-11-08 조사가 찾은 두 가지를 저작 규율로 고정한다. 둘 다 "공식 가이드가
  // 드는 예시 자체가 낡았거나 갈린" 자리라 저작자가 무심코 틀리기 쉽다.
  //
  // ① `Security Hub`는 두 제품이다(저작 결정 D-09 — 조사 노트 93 §2).
  //    CSPM은 ASFF·표준 점검, 신 Security Hub는 OCSF·노출 조사 결과다.
  // ② 공식 `기술 1.2.2`가 드는 "CloudWatch Logs 에이전트"는 **폐지된 구 에이전트**다
  //    (2026-11-08 실측: "The older logs agent is deprecated" · IMDSv2에서는 통합
  //    에이전트 필수 · AL2023에는 패키지가 없다). 축은 **통합 CloudWatch 에이전트**다.
  group('도메인 1 저작 규율', () {
    test('Security Hub를 CSPM과 신 제품으로 갈라 쓴다', () {
      for (final taskId in scsTaskIds) {
        final text = File('assets/content/scs/$taskId.md').readAsStringSync();
        if (!text.contains('Security Hub')) continue;
        expect(text.contains('Security Hub CSPM'), isTrue,
            reason: '$taskId: `Security Hub`를 언급하면서 `Security Hub CSPM`을 '
                '한 번도 쓰지 않았다 — 표준 점검·ASFF 층과 노출·OCSF 층을 가른다'
                '(저작 결정 D-09)');
      }
    });

    test('구 CloudWatch Logs 에이전트를 현행처럼 적지 않는다', () {
      final t12 = File('assets/content/scs/scs-t1-2.md').readAsStringSync();
      expect(t12.contains('통합 CloudWatch 에이전트'), isTrue,
          reason: 'scs-t1-2: 로깅 에이전트의 축은 **통합 CloudWatch 에이전트**다');
      // 구 에이전트를 언급하는 것 자체는 옳다(가이드가 예시로 들기 때문이다).
      // 다만 **폐지 상태를 적어야** 한다 — D-04-b의 "상태를 적는다" 규율.
      if (t12.contains('CloudWatch Logs 에이전트')) {
        expect(RegExp(r'폐지|더 이상 지원').hasMatch(t12), isTrue,
            reason: 'scs-t1-2: 구 `CloudWatch Logs 에이전트`를 언급하면 '
                '**폐지 상태를 함께 적는다**(공식 가이드가 예시로 드는 기능이 '
                '이미 폐지된 자리다 — 저작 결정 D-04-b)');
      }
    });
  });

  // 2026-11-08 도메인 3 배치의 G-29 실측이 찾은 셋을 저작 규율로 고정한다.
  // 셋 다 **공식 시험 가이드가 예시로 드는 이름 자체가 닫혔거나 부분 종료된**
  // 자리라, 상태를 적지 않으면 학습자가 "지금 이것을 쓰라"로 읽는다.
  //
  // ⚠️ 규칙은 **자격증 전수 집계**다. 2026-11-06 AIF 「PT 필수」가 파일별
  //    리터럴 가드를 어형 하나로 뚫고 라이브에 남은 사고 뒤로, 사실 단정은
  //    해당 Task 파일만 보지 않고 **저작된 전 문서**를 센다.
  group('도메인 3 저작 규율', () {
    String? docOf(String taskId) {
      final f = File('assets/content/scs/$taskId.md');
      return f.existsSync() ? f.readAsStringSync() : null;
    }

    test('Classic 계열을 현행처럼 적지 않는다', () {
      // `AWS WAF Classic`은 2026-10-07, `Amazon Inspector Classic`은
      // 2026-05-20 **완전 종료**(SHUTDOWN)다 — 공식 `AWS Lifecycle Changes`
      // 실측(96-service-status-audit §7-2). "Classic vs 현행" 대비를 그냥
      // 쓰면 **없는 것과 비교**하게 된다.
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        for (final name in ['WAF Classic', 'Inspector Classic']) {
          if (!text.contains(name)) continue;
          expect(RegExp(r'종료').hasMatch(text), isTrue,
              reason: '$taskId: `$name`을 언급하면 **종료 상태를 함께 적는다**'
                  '(저작 결정 D-04-b)');
        }
      }
    });

    test('CodeGuru 보안은 지원 종료 사실만 적는다', () {
      // 사용자 안내서가 통째로 **404**이고 공지는 SDK 참조에만 남았다(G-02·§8).
      // 그래서 **기능 서술을 할 근거가 없다** — 상태만 적는다(D-04).
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        if (!text.contains('CodeGuru')) continue;
        expect(text.contains('지원 종료'), isTrue,
            reason: '$taskId: `CodeGuru`를 언급하면 **지원 종료 사실**을 '
                '함께 적는다 — 공식 문서가 404라 기능 서술의 근거가 없다'
                '(저작 결정 D-04)');
      }
    });

    test('Amazon Q Developer의 종료 범위를 IDE 플러그인으로 한정한다', () {
      // ⚠️ 종료 대상은 **IDE 플러그인**이고 서비스 전체가 아니다
      // (Sunset 공지 2026-04-30 → 지원 종료 2027-04-30 · 대안 `Kiro`).
      // "Q Developer가 종료된다"로 적으면 거짓이 된다.
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        if (!text.contains('Q Developer')) continue;
        expect(text.contains('IDE 플러그인'), isTrue,
            reason: '$taskId: `Amazon Q Developer`를 언급하면 **IDE 플러그인** '
                '한정을 함께 적는다 — 서비스 전체 종료가 아니다(저작 결정 D-04)');
      }
    });
  });

  // 2026-11-09 도메인 4 배치. 앞 셋은 **G-29 규율**(저작할 때마다 그 기술이 드는
  // 예시 서비스의 상태를 확인한다)의 네 번째 적용이고, 넷째는 **G-23 실측**이
  // 뒤집은 가설을 고정한다.
  //
  // ⚠️ 규칙은 전부 **자격증 전수 집계**다(도메인 3 배치와 같은 이유 —
  //    2026-11-06 AIF 「PT 필수」가 파일별 리터럴 가드를 어형 하나로 뚫었다).
  group('도메인 4 저작 규율', () {
    String? docOf(String taskId) {
      final f = File('assets/content/scs/$taskId.md');
      return f.existsSync() ? f.readAsStringSync() : null;
    }

    Iterable<String> authoredDocs() => scsTaskIds
        .map(docOf)
        .whereType<String>();

    test('SMS 문자 기반 MFA를 현행 선택지처럼 적지 않는다', () {
      // ⚠️⚠️ 공식 MFA 유형은 **셋**(패스키·보안 키 / 가상 인증자 앱 / 하드웨어
      //    TOTP 토큰)이고 **SMS는 지원이 종료됐다**("AWS ended support for
      //    enabling SMS multi-factor authentication" — `id_credentials_mfa.html`).
      // ⚠️ 이 항목은 공식 `AWS Lifecycle Changes` 집계표에 **없다** — G-16
      //    (「목록에 없다 ≠ 살아 있다」)이 그대로 재현된 자리다.
      // 트리거를 「같은 줄에 SMS와 MFA」로 좁힌다 — SNS의 SMS 전송 같은
      // 다른 문맥을 거짓 양성으로 잡지 않기 위해서다.
      var triggered = 0;
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        for (final line in text.split('\n')) {
          if (!line.contains('SMS') || !line.contains('MFA')) continue;
          triggered++;
          expect(line.contains('종료'), isTrue,
              reason: '$taskId: SMS MFA를 언급한 줄에 **지원 종료**가 없다 — '
                  '공식 MFA 유형은 셋이고 SMS는 종료됐다(저작 결정 D-04-b)\n'
                  '  문제의 줄: $line');
        }
      }
      expect(triggered, greaterThanOrEqualTo(1),
          reason: 'SMS MFA 상태를 적은 줄이 한 곳도 없다 — `기술 4.1.1`이 MFA를 '
              '예시로 드는데 종료된 유형을 다루지 않으면 규칙이 공허해진다');
    });

    test('Simple AD를 언급하면 유지 관리 상태를 함께 적는다', () {
      // ⚠️⚠️ `AWS Directory Service`의 **Simple AD는 유지 관리**(MAINT
      //    2026-06-30, 공식 `AWS Lifecycle Changes` 실측 —
      //    96-service-status-audit §7-2)인데 **서비스 what-is 페이지는 그 상태를
      //    적지 않고** 세 디렉터리 유형 중 하나로 그대로 소개한다.
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        if (!text.contains('Simple AD')) continue;
        expect(text.contains('유지 관리'), isTrue,
            reason: '$taskId: `Simple AD`를 언급하면 **유지 관리 상태**를 함께 '
                '적는다 — 서비스 페이지에는 상태가 없다(저작 결정 D-04-b)');
      }
      expect(authoredDocs().where((t) => t.contains('Simple AD')).length,
          greaterThanOrEqualTo(1),
          reason: '`기술 4.1.3`이 AWS Directory Service를 예시로 드는데 '
              'Simple AD의 상태를 다룬 문서가 없다');
    });

    test('Cognito Sync를 언급하면 유지 관리 상태를 함께 적는다', () {
      // ⚠️ `Amazon Cognito`의 **Cognito Sync는 유지 관리**(MAINT 2026-06-30)다.
      //    사용자 풀·ID 풀은 정상이므로 **기능 단위로** 갈라 적는다.
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        if (!text.contains('Cognito Sync')) continue;
        expect(text.contains('유지 관리'), isTrue,
            reason: '$taskId: `Cognito Sync`를 언급하면 **유지 관리 상태**를 '
                '함께 적는다 — 사용자 풀·ID 풀과 같은 층이 아니다');
      }
      expect(authoredDocs().where((t) => t.contains('Cognito Sync')).length,
          greaterThanOrEqualTo(1),
          reason: '`기술 4.1.1`이 Amazon Cognito를 예시로 드는데 유지 관리 '
              '기능을 가르지 않으면 학습자가 셋을 같은 층으로 읽는다');
    });

    test('정책 시뮬레이터가 RCP를 평가하는 것처럼 적지 않는다', () {
      // ⚠️⚠️ **G-23 실측이 가설을 넓혔다.** 공식
      //    `access_policies_testing-policies.html`은 시뮬레이터가 ID 기반 정책·
      //    권한 경계·**SCP**·내가 제공한 리소스 기반 정책을 평가하지만
      //    **"does not support resource control policies (RCPs)"**라고 적는다.
      //    반대로 **Access Analyzer 정책 검증에는 RCP 전용 검사가 있다**
      //    (`Error – Policy size exceeds RCP quota` 등). 둘의 가장 날카로운
      //    갈림길이라 "시뮬레이터로 RCP 영향을 본다"는 서술을 막는다.
      //
      // ⚠️ 트리거는 **약어와 한국어 전체 이름을 함께** 본다. 처음 `RCP` 만 보게
      //    썼더니 「리소스 제어 정책」으로 적은 줄이 비켜 갔다 — 2026-11-06 AIF
      //    「PT 필수」가 어형 한 글자로 뚫린 것과 같은 계열이다.
      // ⚠️ 자가 점검 **질문 줄**은 예외다. 질문은 "개발자가 시뮬레이터로
      //    돌려 보니 전부 허용이었다"처럼 **틀린 믿음을 제시**하고 바로 아래
      //    정답이 그것을 정정한다 — 문서의 단정이 아니다. 예외가 모든 줄을
      //    삼키지 않도록 **예외 줄 수를 대조군으로 고정**한다.
      var triggered = 0;
      var exempted = 0;
      final rcp = RegExp(r'RCP|리소스 제어 정책');
      final states = RegExp(r'지원하지 않|못|does not support|안 됩니다');
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        for (final line in text.split('\n')) {
          if (!line.contains('시뮬레이터') || !rcp.hasMatch(line)) continue;
          if (line.startsWith('**Q') && line.contains('.**')) {
            exempted++;
            continue;
          }
          triggered++;
          expect(states.hasMatch(line), isTrue,
              reason: '$taskId: 시뮬레이터와 RCP가 같은 줄에 있는데 '
                  '**지원하지 않는다**는 서술이 없다 — 공식은 '
                  '"does not support resource control policies (RCPs)"다\n'
                  '  문제의 줄: $line');
        }
      }
      expect(triggered, greaterThanOrEqualTo(1),
          reason: '시뮬레이터의 RCP 미지원을 적은 줄이 없다 — `기술 4.2.4`가 '
              '시뮬레이터와 Access Analyzer를 함께 들므로 이 갈림길은 필수다');
      expect(exempted, 1,
          reason: '자가 점검 질문 예외가 $exempted줄이다 — 예외가 늘면 '
              '규칙이 조용히 느슨해진다(1줄로 고정)');
    });
  });

  // 2026-11-09 도메인 5 배치. **G-29 규율의 다섯 번째 적용**이고, 이 도메인에서
  // 가장 날카롭다 — 공식 `기술 5.2.2`가 데이터 무결성 수단으로 드는
  // **`S3 Glacier 저장소 잠금`(Vault Lock)이 신규 고객에게 닫힌 서비스의 기능**이다.
  //
  // ⚠️ 네 규칙 모두 **자격증 전수 집계**다(도메인 3·4와 같은 이유).
  group('도메인 5 저작 규율', () {
    String? docOf(String taskId) {
      final f = File('assets/content/scs/$taskId.md');
      return f.existsSync() ? f.readAsStringSync() : null;
    }

    Iterable<String> authoredDocs() =>
        scsTaskIds.map(docOf).whereType<String>();

    test('Glacier 저장소 잠금을 언급하면 신규 고객 차단 상태를 적는다', () {
      // ⚠️⚠️ **금고(vault)와 저장소 잠금은 「원래의 독립 Glacier 서비스」의 것**이고
      //    그 서비스는 **신규 고객을 받지 않는다**(공식 Glacier 개발자 안내서의 모든
      //    페이지가 `This page is only for existing customers of the Amazon Glacier
      //    service using Vaults and the original REST API from 2012.` 배너를 단다).
      // ⚠️ **S3 Glacier 스토리지 클래스**(Instant Retrieval·Flexible Retrieval·
      //    Deep Archive)는 정상이므로 트리거를 `Glacier` 전체로 두지 않는다 —
      //    「저장소 잠금 / Vault Lock」으로 좁힌다.
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        if (!text.contains('저장소 잠금') && !text.contains('Vault Lock')) continue;
        expect(text.contains('신규 고객'), isTrue,
            reason: '$taskId: `Glacier 저장소 잠금`을 언급하면 **신규 고객 차단 상태**를 '
                '함께 적는다 — 공식 가이드가 데이터 무결성 수단으로 드는 기능이 '
                '닫힌 서비스의 것이다(저작 결정 D-04-b)');
      }
      expect(authoredDocs().where((t) => t.contains('저장소 잠금')).length,
          greaterThanOrEqualTo(1),
          reason: '`기술 5.2.2`가 `S3 Glacier 저장소 잠금`을 예시로 드는데 그 상태를 '
              '다룬 문서가 없다 — 규칙이 공허해진다');
    });

    test('SNS 메시지 데이터 보호를 언급하면 신규 고객 차단 상태를 적는다', () {
      // ⚠️⚠️ 공식 `기술 5.3.4`가 **예시로 드는 바로 그 기능**인데
      //    `sns-message-data-protection-configure.html`이 스스로
      //    `Amazon SNS message data protection is no longer available to new
      //    customers.`를 Important 로 적는다(G-15·G-28).
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        if (!text.contains('메시지 데이터 보호')) continue;
        expect(text.contains('신규 고객'), isTrue,
            reason: '$taskId: `Amazon SNS 메시지 데이터 보호`를 언급하면 '
                '**신규 고객 차단 상태**를 함께 적는다 — 공식 문서가 그 상태를 '
                '페이지 머리에 적는다');
      }
      expect(authoredDocs().where((t) => t.contains('메시지 데이터 보호')).length,
          greaterThanOrEqualTo(1),
          reason: '`기술 5.3.4`의 두 예시 중 하나를 다루지 않았다');
    });

    test('DataSync Discovery를 언급하면 지원 종료를 적는다', () {
      // ⚠️ `AWS DataSync` 자체는 정상이고 **Discovery 기능만** 2025-05-20
      //    지원 종료다(96-service-status-audit §7-2). `기술 5.2.4`가 DataSync 를
      //    예시로 들므로 기능 단위로 갈라 적는다.
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        if (!text.contains('DataSync Discovery')) continue;
        expect(text.contains('지원 종료'), isTrue,
            reason: '$taskId: `DataSync Discovery`를 언급하면 **지원 종료**를 '
                '함께 적는다 — 서비스 전체가 아니라 그 기능만 닫혔다');
      }
      expect(authoredDocs().where((t) => t.contains('DataSync Discovery')).length,
          greaterThanOrEqualTo(1),
          reason: '`기술 5.2.4`가 DataSync 를 예시로 드는데 닫힌 기능을 가르지 않으면 '
              '학습자가 둘을 같은 층으로 읽는다');
    });

    test('CloudWatch Logs 데이터 보호 정책의 비소급 성질을 함께 적는다', () {
      // ⚠️⚠️ **보존 가드**다(2026-11-06 AIF 배치에서 처음 쓴 종류) — 금지가 아니라
      //    **참인 문장이 사라지는 것**을 막는다. 공식 문구:
      //    `log events ingested to the log group before that time are not masked.`
      //    AIF 트랙이 먼저 실측했고(00-overview §10) 이 도메인의 핵심 사실이다.
      var triggered = 0;
      for (final taskId in scsTaskIds) {
        final text = docOf(taskId);
        if (text == null) continue;
        if (!text.contains('데이터 보호 정책') || !text.contains('CloudWatch Logs')) {
          continue;
        }
        triggered++;
        expect(text.contains('소급'), isTrue,
            reason: '$taskId: CloudWatch Logs 데이터 보호 정책을 가르치면 '
                '**이미 수집된 로그에는 소급 적용되지 않는다**를 함께 적는다 — '
                '마스킹은 수집 시점에 일어난다');
      }
      expect(triggered, greaterThanOrEqualTo(1),
          reason: 'CloudWatch Logs 데이터 보호 정책을 가르치는 문서가 없다 — '
              '`기술 5.3.4`의 축이 그쪽이다(SNS 쪽은 닫혔다)');
    });
  });
}
