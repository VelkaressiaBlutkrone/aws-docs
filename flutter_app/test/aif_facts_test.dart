import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// AIF-C01 학습문서 사실 가드.
///
/// 도메인 1 **문항 저작 중에 공식 문서를 다시 읽어** 찾은 라이브 학습문서
/// 결함을 고정한다(2026-11-05). SAA·SOA 판(`saa_*_facts_test` ·
/// `soa_facts_test`)과 같은 형태로 **「옛 문구 0건 + 공식 사실 있음」 쌍**을 쓴다.
///
/// ⚠️ **문항 가드는 `.md`를 보지 않는다.** 2026-10-28 `saa-t4-3.md`에서 같은
/// 구멍으로 죽은 링크가 남았고(#262가 `.questions.json`만 고쳤다), 이 트랙에서도
/// 학습문서 쪽은 별 가드가 필요하다.
///
/// ⚠️ **쓰지 않은 주장을 금지로 걸지 않는다.** 아래는 모두 공식 페이지를 직접
/// 열어 실측한 것이다(근거가 뒤에 확인될 수 있는 서술을 0건으로 박으면 옳은
/// 문장이 막힌다 — 갭 배치 B11의 가드 설계 교훈).
void main() {
  String read(String taskId) =>
      File('assets/content/aif/$taskId.md').readAsStringSync();

  group('대조군: 가드의 입력이 실재하는가', () {
    // 이것이 없으면 아래 「0건」 단정들이 **빈 문자열**을 상대로 통과할 수 있다.
    test('AIF 학습문서 14편이 있고 비어 있지 않다', () {
      for (final taskId in [
        'aif-t1-1', 'aif-t1-2', 'aif-t1-3',
        'aif-t2-1', 'aif-t2-2', 'aif-t2-3',
        'aif-t3-1', 'aif-t3-2', 'aif-t3-3', 'aif-t3-4',
        'aif-t4-1', 'aif-t4-2',
        'aif-t5-1', 'aif-t5-2',
      ]) {
        final raw = read(taskId);
        // ⚠️ `String.length`는 **문자 수**이고 바이트 수가 아니다 — 한국어는
        // UTF-8에서 글자당 3바이트라 둘이 두 배 가까이 벌어진다(실측:
        // t1-1은 14,802자 / 27,883바이트). 바이트 기준으로 임계를 잡으면
        // 멀쩡한 문서가 "너무 짧다"로 걸린다(실제로 걸렸다).
        expect(raw.length, greaterThan(10000),
            reason: '$taskId: 학습문서가 비었거나 너무 짧다');
        expect(raw, contains('domainName:'),
            reason: '$taskId: 프런트매터가 없다');
      }
    });
  });

  group('aif-t1-3: Autopilot 기본 목표 지표의 출처', () {
    // 주장 자체("이진 분류 기본값 F1 · 다중 클래스 기본값 Accuracy")는 **옳다.**
    // 틀린 것은 **인용한 페이지**였다 — `autopilot-metrics-validation.html`은
    // "Autopilot uses the default validation metric for each problem type that
    // it handles, unless you specify otherwise"까지만 적고 **문제 유형별 기본값을
    // 적지 않는다**(전문 실측). 그 수치를 직접 적는 정본은 API 참조의
    // `AutoMLJobObjective`다 — "Default objective metrics: ... Binary
    // classification: F1" · 다중 클래스 "Accuracy" · "Regression: MSE".
    //
    // ⚠️ 보고가 "주장이 어디에도 없다"고 왔지만 **실측하니 정본이 따로 있었다.**
    // 보고는 데이터이고 지시문이 아니다.
    test('옛 출처 슬러그가 없다', () {
      expect(read('aif-t1-3').contains('autopilot-metrics-validation'), isFalse,
          reason: '그 페이지는 문제 유형별 기본 지표를 적지 않는다');
    });

    test('정본 출처가 프런트매터와 참고자료 양쪽에 있다', () {
      final raw = read('aif-t1-3');
      expect(
          raw.split('API_AutoMLJobObjective.html').length - 1,
          2,
          reason: '프런트매터 sources와 문서 끝 참고자료 둘 다에 있어야 한다');
    });

    test('기본 지표 주장은 그대로 남아 있다', () {
      final raw = read('aif-t1-3');
      expect(raw, contains('이진 분류의 기본값은'));
      expect(raw, contains('다중 클래스 분류의 기본값은'));
    });
  });

  group('aif-t1-3: SageMaker AI 과금은 자리에 따라 갈린다', () {
    // 공식 결정 가이드가 2026-07-23 갱신으로 바뀐 자리다:
    //   "SageMaker AI offers per-token pricing for serverless model
    //    customization, providing the same pricing simplicity as Amazon Bedrock."
    //   "For managed training jobs, inference, and HyperPod, SageMaker AI
    //    follows usage-based pricing for compute resources, storage, and other
    //    services consumed during the AI development process..."
    // 문서가 「컴퓨팅 리소스 사용량 기준」만 적고 있어 **서버리스 커스터마이징이
    // 토큰당이라는 것을 가르치지 못했다.** 문항은 이 자리를 피해 썼고(저작
    // 에이전트 보고), 문서를 먼저 고쳤다(루브릭 T6 — md 선결).
    test('서버리스 커스터마이징의 토큰당 요금이 적혀 있다', () {
      final raw = read('aif-t1-3');
      expect(raw, contains('서버리스 모델 커스터마이징'));
      expect(
          raw.split('서버리스 모델 커스터마이징').length - 1,
          greaterThanOrEqualTo(3),
          reason: '비교 표 · 흔한 함정 · 자가 점검 정답 세 자리에 반영한다');
    });

    test('관리형 훈련 작업·추론·HyperPod 쪽 사용량 기준도 함께 적혀 있다', () {
      final raw = read('aif-t1-3');
      expect(raw, contains('HyperPod'));
      expect(raw, contains('컴퓨팅·스토리지 사용량 기준'));
    });

    test('옛 단정("과금 모델은 같다" 대비 문구)이 남아 있지 않다', () {
      final raw = read('aif-t1-3');
      expect(raw.contains('관리형 API든 자체 호스팅이든 과금 모델은 같다'), isFalse,
          reason: '이 함정 문구는 서버리스 커스터마이징에서 거짓이 됐다');
      expect(raw.contains('과금은 **컴퓨팅 리소스 사용량 기준**입니다'), isFalse,
          reason: 'SageMaker AI 전체가 그렇다는 단정은 틀렸다');
    });
  });

  group('aif-t2-3: 사용자 지정 모델의 추론 설정은 둘이다', () {
    // ⚠️ **라이브 학습문서가 틀린 것을 단정하고 있었다** — "사용자 지정 모델은
    // 프로비저닝 처리량 없이 쓸 수 없다"가 **다섯 자리**에 있었다(시험 직전 요약 ·
    // 용어 표 · §4 서빙 비용 · 숨은 비용 · 흔한 함정 · 자가 점검 Q2 정답).
    //
    // 공식 `model-customization-use.html`은 설정을 **둘**로 적는다 —
    // ① "Purchase Provisioned Throughput" ② "Deploy custom model for
    // on-demand inference ... With on-demand inference, you only pay for what
    // you use and **you don't need to set up provisioned compute resources**".
    //
    // G-19가 2026-11-03에 같은 오류를 `aif-t3-3`에서 바로잡았는데 **t2-3은
    // 라이브인 채로 남아 있었다**(G-22 때 같은 파일의 「차원 8개」만 고쳤다).
    // 조사 노트 `96-fm-cost-eval-guardrails.md` §3에도 한 줄 남아 있어 함께 고쳤다.
    //
    // ⚠️ **저작 에이전트는 네 자리로 보고했고 실제로는 다섯이었다** — 용어 표의
    // "사용자 지정 모델에는 **필수**입니다"를 놓쳤다. 보고의 개수를 그대로
    // 믿지 않고 컨트롤러가 `grep`으로 전수 센 것이 이것을 잡았다.
    test('"프로비저닝 처리량 없이 쓸 수 없다"류 단정이 0건이다', () {
      final raw = read('aif-t2-3');
      for (final forbidden in [
        '프로비저닝 처리량 없이 쓸 수 없',
        '프로비저닝 처리량을 구매해야 한다',
        '사용자 지정 모델에는 **필수**',
        'PT 규칙이 그대로 따라붙',
      ]) {
        expect(raw.contains(forbidden), isFalse,
            reason: '공식은 온디맨드 추론용 배포 경로를 함께 적는다: $forbidden');
      }
    });

    test('온디맨드 배포 경로가 공식 문구로 적혀 있다', () {
      final raw = read('aif-t2-3');
      expect(raw, contains('온디맨드 추론용 배포'));
      expect(
          raw.split('프로비저닝된 컴퓨팅 리소스를 설정할 필요가 없').length - 1,
          greaterThanOrEqualTo(3),
          reason: '시험 직전 요약 · §4 · 흔한 함정 · 자가 점검 정답에 반영한다');
    });

    test('자가 점검 Q2 정답이 "가능합니다"로 바뀌었다', () {
      final raw = read('aif-t2-3');
      expect(raw.contains('**불가능합니다.** 공식 문장이 단정합니다'), isFalse,
          reason: '온디맨드 배포가 가능하므로 이 정답은 틀렸다');
      expect(raw, contains('**가능합니다.** 공식은 사용자 지정 모델의 추론 설정을'));
    });

    test('정본 출처가 프런트매터와 참고자료 양쪽에 있다', () {
      expect(
          read('aif-t2-3').split('model-customization-use.html').length - 1,
          2,
          reason: '프런트매터 sources와 문서 끝 참고자료 둘 다에 있어야 한다');
    });

    // ⚠️ **같은 오류가 다른 파일에도 있었다.** t2-3을 고친 뒤 레포 전역을
    // `grep`으로 쓸자 `aif-t2-1.md`의 「시험 직전 요약」에 "사용자 지정 모델은
    // **PT 필수**"가 한 줄 더 있었다(저작 에이전트 보고에는 없던 자리다).
    // 그래서 한 파일이 아니라 **aif 디렉터리 전수**를 집계형으로 고정한다 —
    // 새 학습문서가 같은 단정을 들고 들어오면 이 테스트가 먼저 깨진다.
    test('aif 학습문서 전수에서 「PT 필수」류 단정이 0건이다', () {
      final dir = Directory('assets/content/aif');
      final docs = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .toList();
      // 대조군: 전수 대상이 실제로 있는가(빈 목록을 상대로 통과하지 않게).
      expect(docs.length, 14, reason: 'AIF 학습문서는 공식 Task 14편이다');

      const forbidden = ['PT 필수', '프로비저닝 처리량 없이 쓸 수 없', '프로비저닝 처리량을 구매해야 한다'];
      final hits = <String>[];
      for (final f in docs) {
        final raw = f.readAsStringSync();
        for (final needle in forbidden) {
          if (raw.contains(needle)) hits.add('${f.uri.pathSegments.last}: $needle');
        }
      }
      expect(hits, isEmpty,
          reason: '공식은 프로비저닝 처리량 구매와 온디맨드 추론용 배포 둘을 적는다');
    });

    test('「계속 사전 훈련」은 t3-3의 번역 메모 한 곳에만 있다', () {
      // D-09·G-20이 공식 가이드 표기 「지속적인 사전 훈련」으로 통일했다.
      // ⚠️ 다만 `aif-t3-3.md`의 용어 표가 "「계속 사전 훈련」으로도 번역됩니다"로
      // **의도적으로** 병기한다(학습자가 다른 교재에서 만날 표기다). 그래서
      // 0건이 아니라 **그 한 곳만**으로 고정한다 — `aif-t2-2.md`가 그 낱말을
      // 용어 자체로 쓰고 있어 이번에 고쳤다.
      final dir = Directory('assets/content/aif');
      final hits = <String>[];
      for (final f in dir.listSync().whereType<File>().where((f) => f.path.endsWith('.md'))) {
        if (f.readAsStringSync().contains('계속 사전 훈련')) {
          hits.add(f.uri.pathSegments.last);
        }
      }
      expect(hits, ['aif-t3-3.md'],
          reason: '병기는 t3-3 용어 표에서만 한다 — 다른 곳은 「지속적인 사전 훈련」');
    });
  });

  group('도메인 3: 공식에서 사라진 서술을 되살리지 않는다', () {
    // ⚠️ **두 건 모두 "출처가 죽었거나 그 사실을 더 이상 담지 않는" 경우**이고,
    // 도메인 3 문항 저작 중 공식 재실측으로 드러났다(2026-11-05). 문항은 네
    // Task 모두 이 영역을 **피해서** 썼고(전수 0건 확인), 학습문서를 고쳤다.

    // ① AgentCore 내장 평가자의 **개수(13개)와 ID 이름**이 공식에서 사라졌다.
    // 개요 페이지는 목록을 싣지 않는 1,500자 소개 문서로 재구성됐고 남은 예시
    // ID는 `Builtin.Helpfulness` 하나다. 관련 여섯 페이지에서 세션·도구 호출
    // 수준 ID는 0건이다(대조군: 같은 추출이 `Builtin.Helpfulness`와 새 갈래
    // `Builtin.SkillSelectionAccuracy`를 잡아낸다 — 추출 실패가 아니다).
    //
    // **사라진 것은 이름과 수뿐이고 세 축은 그대로다** — 목표 달성 정확성 ·
    // 호출한 도구의 정확성 · 사용자 지정 지표(`how-it-works-evaluations.html`).
    test('aif-t3-4: 사라진 평가자 ID 이름과 「13개」가 없다', () {
      final raw = read('aif-t3-4');
      for (final gone in [
        'GoalSuccessRate',
        'ToolSelectionAccuracy',
        'ToolParameterAccuracy',
        '내장 평가자는 **13개**',
      ]) {
        expect(raw.contains(gone), isFalse,
            reason: '공식 문서에서 확인되지 않는 서술이다: $gone');
      }
    });

    test('aif-t3-4: 현행 공식이 적는 세 축이 남아 있다', () {
      final raw = read('aif-t3-4');
      expect(raw, contains('종단 간 작업 완료(목표 달성)'));
      expect(raw, contains('사용자 지정 지표'));
      expect(raw, contains('개수와 ID 이름은 외우지 않습니다'),
          reason: '개수·이름에 기대지 말라는 주의가 있어야 한다');
    });

    test('aif-t3-4: 문항이 사라진 ID에 기대지 않는다', () {
      final bank =
          File('assets/content/aif/aif-t3-4.questions.json').readAsStringSync();
      for (final gone in ['GoalSuccessRate', 'ToolSelectionAccuracy', 'ToolParameterAccuracy']) {
        expect(bank.contains(gone), isFalse, reason: '$gone은 공식에서 확인되지 않는다');
      }
      // ⚠️ G-39: 은퇴 슬러그를 쓰지 않았는지도 함께 본다. 이 Task가 평가
      // 페이지를 가장 많이 인용하므로 여기가 그 함정의 자리다.
      expect(bank.contains('userguide/model-evaluation.html'), isFalse,
          reason: '정본은 userguide/evaluation.html이다');
      expect(bank, contains('userguide/evaluation.html'),
          reason: '대조군 — 정본 출처가 실제로 쓰였는지');
    });

    // ② `AWS CAF for AI` 가이드가 **통째로 은퇴**했다. `aws-caf-for-ai/` 아래
    // 모든 슬러그가 ML 렌즈 인덱스로 리다이렉트되고 **일부러 틀린 슬러그도
    // 같은 곳으로 간다**(→ 이름 변경이 아니라 가이드 소멸). 그 렌즈 인덱스에는
    // `aif-t3-3.md` §5 ①·②가 인용하는 문장이 없다(실측).
    //
    // 인용 문장의 대체 출처를 찾는 것은 후속 과제이므로, 지금은 **은퇴 사실을
    // 참고자료에 명시**하는 것까지 고정한다 — 죽은 링크를 아무 표시 없이 두면
    // 학습자가 그 페이지를 찾으러 간다.
    // ⚠️ **2026-11-06 정정:** 이 가드는 원래 `'이 가이드가 은퇴했습니다'`를
    // 단정했는데, **그 판정 자체가 틀렸다.** 아래 「G-43 정정」 그룹의 주석에
    // 경위를 적었다 — 문서는 그 URL에 그대로 있고 **브라우저로만 못 열린다.**
    // 그래서 단정을 상태 서술로 바꾸고, 「은퇴」 문구 금지는 그쪽 그룹이 맡는다.
    test('aif-t3-3: 열리지 않는 CAF 인용에 상태와 대체 경로가 붙어 있다', () {
      final raw = read('aif-t3-3');
      expect(raw, contains('aws-caf-for-ai'),
          reason: '대조군 — 그 인용이 아직 문서에 있다');
      expect(raw, contains('302'),
          reason: '브라우저가 어디로 튕기는지를 참고자료에 적어야 한다');
      expect(raw, contains('MLSEC03-BP04'),
          reason: '살아 있는 인접 출처를 함께 적어 학습자가 열 곳을 준다');
    });

    test('aif-t3-3: 문항이 은퇴한 CAF 가이드를 출처로 쓰지 않는다', () {
      final bank =
          File('assets/content/aif/aif-t3-3.questions.json').readAsStringSync();
      expect(bank.contains('aws-caf-for-ai'), isFalse,
          reason: '그 가이드는 은퇴했다 — 살아 있는 페이지를 인용한다');
    });
  });

  group('aif-t1-2: 1.2.1 사실의 정본이 출처 목록에 있다', () {
    // md §1이 적는 두 사실("사람 개입 없이 필터링·정렬·분류하고 보고서 요약·문서
    // 스캔·오디오 전사·콘텐츠 태깅을 대신한다" · "대용량 데이터를 빠르게 처리해
    // 런타임 결정을 돕는다")의 정본은 `what-is/machine-learning/`의
    // 「Benefits of machine learning」(영문: Enhanced decision making /
    // Automation of routine tasks — 실측 일치)인데 **출처 목록에만 빠져 있었다.**
    // 사실은 전부 옳았다.
    test('what-is/machine-learning 출처가 프런트매터와 참고자료 양쪽에 있다', () {
      final raw = read('aif-t1-2');
      expect(
          raw.split('aws.amazon.com/what-is/machine-learning/').length - 1,
          2,
          reason: '프런트매터 sources와 문서 끝 참고자료 둘 다에 있어야 한다');
    });
  });

  // ── 도메인 4·5 문항 저작(2026-11-06)에서 찾은 것 ──────────────────────
  //
  // ⚠️ 이 배치의 큰 교훈: **「없다」 규율 3부를 다 해도 표 구조로 표현된 사실은
  // 못 잡는다.** 한 에이전트가 `glue-data-quality.html`에서 「실패 레코드 식별은
  // ETL 쪽만」을 "공식에 없다"고 보고했는데(추출 둘 · 대조군 · 다른 표현까지
  // 적용했다), 실측하면 그 사실은 **Data Catalog 열과 ETL 열을 가진 비교 표**에
  // `Not supported / Supported`로 들어 있다. 산문 문구 검색으로는 영원히 0건이다.
  // 보고를 믿고 md를 "고쳤다면 참인 문장을 지웠을" 자리였다 → 아래 마지막 그룹이
  // 그 문장을 **지우지 못하게** 고정한다(금지 가드가 아니라 **보존 가드**다).
  group('aif-t4-1: 모범 사례가 「차원 하나당 하나씩」은 아니다', () {
    // 실측(2026-11-06): `raibr02.html`은 BP01~BP09이고 **BP09는 차원이 아닌
    // 교차 전략**(`Choose multiple strategies to identify potential harmful
    // events`), `rairc03.html`은 BP01~BP05·BP07~BP10 **아홉 항목으로 BP06이
    // 번호에서 빈다.** md가 "차원 하나당 하나씩"으로 단정하고 있었다.
    test('「차원 하나당 하나씩」 일반화가 0건이다', () {
      final raw = read('aif-t4-1');
      expect(raw.contains('차원 하나당 하나씩'), isFalse,
          reason: 'RAIBR02는 BP09가 차원이 아니고 RAIRC03은 BP06이 빈다');
    });

    test('모범 사례 개수도 외우지 말라는 단서와 두 근거가 있다', () {
      final raw = read('aif-t4-1');
      expect(raw, contains('모범 사례 개수도 외우지 않습니다'));
      expect(raw, contains('Choose multiple strategies'),
          reason: 'RAIBR02-BP09가 차원이 아니라는 근거');
      expect(raw, contains('`BP06`에서 빕니다'),
          reason: 'RAIRC03 번호 공백이라는 근거');
    });

    test('측정 쪽에는 제어 가능성이 있다는 것이 함께 적혀 있다', () {
      // "유해 사건에는 제어 가능성·거버넌스가 없고, 측정에는 거버넌스가 없다"는
      // **참**이다(RAIRC03-BP07이 제어 가능성). 거꾸로 읽히지 않게 못박는다.
      expect(read('aif-t4-1'),
          contains('Measure user controllability of system behavior'));
    });
  });

  group('aif-t4-1: AI 서비스 카드 접두사는 목록 페이지가 아니다', () {
    // 실측(2026-11-06, 내장 브라우저로 직접 열어 확인): `https://docs.aws.
    // amazon.com/ai/responsible-ai/`는 **403**이고 AWS의 "the web address you
    // entered is not a functioning page on our site" 오류 페이지가 돌아온다.
    // 개별 카드(`.../nova-2-lite/overview.html` 등)는 전부 `200 r=0`이다.
    //
    // ⚠️ **403이 봇 차단인지 실제 미제공인지는 상태 코드로 갈라지지 않는다** —
    // `repost.aws`의 403은 봇 차단이었다(SOA·DEA 감사). 그래서 브라우저로 열었다.
    test('그 접두사를 「아래에 게시된다」로 안내하지 않는다', () {
      final raw = read('aif-t4-1');
      expect(raw.contains('`docs.aws.amazon.com/ai/responsible-ai/` 아래에'),
          isFalse,
          reason: '그 경로는 제공되지 않아 목록 페이지로 열 수 없다');
    });

    test('제공되지 않는 경로라는 경고가 있다', () {
      expect(read('aif-t4-1'), contains('제공되지 않는 경로'));
    });
  });

  group('aif-t5-1: 태그 예측 불가능성은 공식 문구가 아니다', () {
    // 실측(2026-11-06): `guardrails-prompt-attack.html` ·
    // `guardrails-use-independent-api.html` · `guardrails-use-converse-api.html`
    // 세 페이지 전부에서 `tagSuffix` · `unpredictable` · `guess` · `random`이
    // 본문·원시 HTML 양쪽 **0건**이고, 대조군 "If there are no tags, prompt
    // attacks for those use cases will not be filtered"는 **1건**이다.
    // 즉 추출은 작동했고 그 서술이 실제로 없다. md의 🧠 원리 블록은 올바른
    // 층이었지만 **시험 직전 요약과 자가 점검 Q2가 사실처럼** 적고 있었다.
    test('「예측 불가능해야 하는 이유」로 단정하지 않는다', () {
      expect(read('aif-t5-1').contains('예측 불가능해야 하는 이유'), isFalse,
          reason: '공식 문구가 아니라 저작자 추론이다');
    });

    test('원리임을 밝히면서도 공식이 적는 선은 그대로 인용한다', () {
      final raw = read('aif-t5-1');
      expect(raw, contains('공식 문구가 아니라'));
      expect(
          raw,
          contains(
              'If there are no tags, prompt attacks for those use cases will not be filtered'),
          reason: '공식이 실제로 적는 한 줄은 유지한다');
    });

    test('프롬프트 공격 미평가 필드가 공식 경로 표기다', () {
      // 공식 원문: "Content in messages[].content[].toolResult is not assessed
      // for prompt attacks, and neither are the tool definitions in
      // toolConfig.tools[].toolSpec." md가 `toolSpec`만 적어 상위 경로가 빠져
      // 있었다(틀린 서술은 아니지만 시험에서 갈리는 자리다).
      expect(read('aif-t5-1'), contains('`toolConfig.tools[].toolSpec`'));
    });
  });

  group('보존 가드: 표에만 있는 참인 사실을 지우지 않는다', () {
    // 위 머리말의 경위 그대로다. `glue-data-quality.html`의 비교 표가
    // "Data Quality rule recommendations: Supported / Not supported"와
    // "Identifying records that failed data quality checks: Not supported /
    // Supported"를 Data Catalog 열·ETL 열로 적는다(실측). md가 옳다.
    test('aif-t5-1: Glue DQ 진입점별 지원 차이가 남아 있다', () {
      final raw = read('aif-t5-1');
      expect(raw, contains('실패한 레코드 식별은'));
      expect(raw, contains('규칙 추천은'));
    });

    // 같은 배치에서 **네 번째** 거짓 「없다」가 나왔다. 한 에이전트가
    // "안전 조치 계층 미지정 시 Classic"의 근거를 못 찾았다고 보고했는데,
    // 그 문장은 에이전트가 찾아본 **바로 그 페이지**에 있다 —
    // `guardrails-contextual-grounding-check.html`의
    // "If you don't specify a tier, your guardrail uses Classic tier."
    // 탐침이 `If you do not` · `defaults to` · `Classic tier is`였고 실제
    // 문구가 `If you don't specify a tier`여서 셋 다 빗나갔다.
    //
    // ⚠️ **md가 영문을 직접 인용하고 있으면 그 인용문으로 먼저 검색한다.**
    // (덧붙여 API 참조의 `tierName`은 `Required: Yes`인데 이것과 모순이
    // 아니다 — 필수인 것은 `TierConfig` **안쪽** 필드이고, 그 객체를 통째로
    // 빼면 Classic이 된다. 두 사실이 함께 성립한다.)
    test('aif-t4-1: 계층 기본값의 공식 인용이 남아 있다', () {
      expect(
          read('aif-t4-1'),
          contains(
              "If you don't specify a tier, your guardrail uses Classic tier."),
          reason: '공식 원문 확인(2026-11-06) — 근거 없다는 보고로 지우지 않는다');
    });
  });

  group('전파: 고친 md 주장이 문항으로 새지 않았다', () {
    // SAA·SOA 판(`saa_question_propagation_test` ·
    // `soa_dea_question_propagation_test`)과 같은 계약이다 — 학습문서 정정이
    // 파생 문항에 전파되지 않는 것을 막는다. AIF는 아직 전용 전파 가드 파일이
    // 없으므로 이 배치의 세 주장만 여기서 센다.
    test('AIF 문항 14파일 전수에서 금지 주장이 0건이다', () {
      final files = Directory('assets/content/aif')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))
          .toList();
      expect(files.length, 14,
          reason: 'AIF 공식 Task 14개 전부 문항이 들어와 있다');
      const forbidden = [
        '차원 하나당 하나씩',
        '예측 불가능해야 하는 이유',
      ];
      for (final f in files) {
        final raw = f.readAsStringSync();
        for (final needle in forbidden) {
          expect(raw.contains(needle), isFalse,
              reason: '${f.uri.pathSegments.last}: 「$needle」이 전파됐다');
        }
      }
    });
  });

  // ── 미해결 보고사항 정리 (2026-11-06) ────────────────────────────────
  //
  // 네 문항 배치가 「보강 후보」·「후속 과제」로 남긴 항목을 공식 페이지
  // 재실측으로 닫았다. ⚠️ 이 정리에서 **갭 노트 자신이 틀린 것을 두 건**
  // 찾았다 — 아래 각 그룹의 주석에 적는다.
  group('G-43 정정: CAF for AI는 「소멸」이 아니라 「브라우저로 못 열림」이다', () {
    // ⚠️⚠️ **갭 노트 G-43의 「가이드 통째로 은퇴」가 부정확했다.**
    // curl은 `302`(임시)로 머신 러닝 렌즈 인덱스로 보내고 실제 브라우저도
    // 그렇게 튕기지만, **AWS 문서 리더로 같은 URL을 읽으면 본문이 그대로
    // 나온다**(거버넌스 14,909자 · 보안 19,086자). 「Data curation」 절
    // (7,030~9,564자)과 「Data protection」 절(14,971~17,706자)이 md가
    // 인용하는 문장을 담고 있다.
    //
    // 즉 **인용은 유효하고 사람이 열 수 없을 뿐**이다. 「문서가 사라졌다」와
    // 「사람이 열 수 없다」는 다른 판정이고, 전자로 적으면 다음 작업자가
    // 참인 인용을 지우려 든다.
    //
    // ⚠️ **틀린 슬러그 대조군은 이 둘을 구분하지 못한다** — 가이드가 은퇴한
    // 경우와 사람 대상 서빙만 꺼진 경우가 같은 신호를 준다. 그래서 판정에
    // **AWS 문서 리더를 두 번째 방법으로** 쓴다.
    test('은퇴 단정이 사라지고 정확한 상태가 적혀 있다', () {
      final raw = read('aif-t3-3');
      expect(raw.contains('이 가이드가 은퇴했습니다'), isFalse,
          reason: '문서는 사라지지 않았다 — 브라우저로 열리지 않을 뿐이다');
      expect(raw.contains('가이드 자체의 소멸'), isFalse);
      expect(raw, contains('브라우저로는 열리지 않습니다'));
      expect(raw, contains('문서가 사라진 것은 아닙니다'));
    });

    test('사람이 열 수 있는 인접 정본이 적혀 있다', () {
      final raw = read('aif-t3-3');
      expect(raw, contains('overview-aws-cloud-adoption-framework/governance-perspective.html'));
      expect(raw, contains('MLSEC-07: Keep only relevant data'),
          reason: '공식 자신이 머신 러닝 렌즈로 가는 길을 준다');
      expect(raw, contains('MLSEC03-BP03'));
    });
  });

  group('재구성된 페이지의 귀속 정정', () {
    // 전부 두 방법(본문 추출 + AWS 문서 리더)으로 확인했고 대조군을 함께 뒀다.
    test('aif-t3-3: custom-models.html이 적는 방법은 세 가지다 (G-45)', () {
      final raw = read('aif-t3-3');
      expect(raw, contains('이 페이지가 적는 사용자 지정 방법은 세 가지입니다'));
      expect(raw, contains('hp-custom-models-create-continued-pre-training-job.html'),
          reason: '지속적 사전 훈련의 살아 있는 정본');
    });

    test('aif-t2-3: 「서버리스」·「단일 API」는 개요 페이지가 아니다 (G-40)', () {
      final raw = read('aif-t2-3');
      expect(raw, contains('Quickstart 중심의 「Overview」로 재구성'));
      expect(raw, contains('genai-guide.html`의 `model-independent, single API access'));
    });

    test('aif-t3-1: 지식 기반은 두 유형이고 옛 귀속이 지워졌다 (G-47)', () {
      final raw = read('aif-t3-1');
      expect(raw, contains('현행 지식 기반 페이지에 더 이상 없습니다'));
      expect(raw, contains('관리형이냐 고객 관리형이냐'));
    });

    test('aif-t1-2: 지식 기반 두 유형이 적혀 있다 (G-34)', () {
      expect(read('aif-t1-2'), contains('지식 기반은 이제 두 종류입니다'));
    });

    test('vector-databases의 실제 제목이 쓰인다 (G-47)', () {
      // h1은 `Choosing a database for your generative AI applications`다.
      // 낡은 별칭 「Vector databases on AWS」를 제목처럼 쓰지 않는다.
      final md = read('aif-t3-1');
      expect(md, contains('Choosing a database for your generative AI applications'));
      expect(md.contains('title: Vector databases on AWS'), isFalse);
      final bank = File('assets/content/aif/aif-t3-1.questions.json')
          .readAsStringSync();
      expect(bank.contains('(Vector databases on AWS)'), isFalse,
          reason: '문항 출처 제목의 낡은 별칭도 지웠다');
    });
  });

  group('보강: md가 덮지 않아 반쪽이던 공식 사실 (G-41·G-48·G-56)', () {
    test('aif-t2-1: 컨텍스트 안티패턴은 다섯 가지다', () {
      final raw = read('aif-t2-1');
      expect(raw, contains('안티패턴**으로 드는 **다섯 가지'));
      expect(raw, contains('버전 관리나 나란히 비교 평가 없이'));
    });

    test('aif-t2-1: 프롬프트 캐싱 TTL과 서버 지역성', () {
      final raw = read('aif-t2-1');
      expect(raw, contains('1시간 TTL'), reason: '5분만이 아니다');
      expect(raw, contains('서버 지역성'));
    });

    // ⚠️⚠️ **갭 노트 G-41의 이 항목이 틀렸다.** 「반환 결과 수가 요청보다
    // 적을 수 있다」가 계층형 전용이 아니라고 적었는데, 계층형 절도 그 말을
    // 한다 — 다만 표현이 다르다: 계층형은 `the returned number of results
    // might be **less than** the requested amount`, 표·그림 절은 `the number
    // of results can be **fewer than** the number that you requested`.
    // 그래서 md의 계층형 귀속은 **옳고**, 빠진 것은 **두 번째 경로**였다.
    // 고치지 않고 더하는 것이 맞는 처리다.
    test('aif-t2-1: 결과 수가 줄어드는 경로가 둘로 적혀 있다', () {
      final raw = read('aif-t2-1');
      expect(raw, contains('경로는 둘입니다'));
      expect(raw, contains('최대 토큰 한도를 두는 모든 청킹 전략'));
      expect(raw, contains('10,000자 이하'));
      // 계층형 귀속은 공식 서술이므로 **지우지 않는다**(보존 가드).
      expect(raw, contains('계층형 청킹은 자식 청크가 부모로 교체되므로'),
          reason: '공식 Note가 그대로 적는 사실이다 — 지우면 안 된다');
    });

    test('aif-t2-2: 설명 페이지의 한계 목록 넷이 적혀 있다', () {
      final raw = read('aif-t2-2');
      expect(raw, contains('「한계」 목록이 두 개라'));
      expect(raw, contains('창의성'));
    });

    test('aif-t2-3: SageMaker AI의 전문성이 두 층으로 적혀 있다', () {
      final raw = read('aif-t2-3');
      expect(raw, contains('안내형 UI와 AI 에이전트 지원 워크플로'));
      expect(raw, contains('무엇을 통제하려 하느냐'));
    });

    test('aif-t5-1: 공동 책임 모델의 통제 묶음은 셋이다', () {
      final raw = read('aif-t5-1');
      expect(raw, contains('통제를 가르는 묶음은 **셋**입니다'));
      expect(raw, contains('Customer Specific'));
      expect(raw, contains('영역 보안'));
    });

    test('aif-t3-3: FAQ의 CPT 수혜는 Titan 한정이다', () {
      expect(read('aif-t3-3'),
          contains('이 FAQ 답변의 주어는 `Amazon Titan` 기본 모델입니다'));
    });

    test('aif-t3-2: 싱글샷·간접 인젝션의 귀속이 갈려 있다', () {
      final raw = read('aif-t3-2');
      expect(raw, contains('「싱글샷·원샷」이라는 **낱말은 그 페이지에 없고'));
      expect(raw, contains('정본은 보안 백서가 아니라'));
    });

    test('aif-t1-3: 드리프트 두 정의의 정본이 갈려 있다', () {
      final raw = read('aif-t1-3');
      expect(raw, contains('드리프트 두 종류를 한 문장에 정의하는 정본'));
      expect(raw, contains('이 페이지는 데이터 드리프트만 정의합니다'));
    });
  });
}
