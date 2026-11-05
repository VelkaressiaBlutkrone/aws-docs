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
    test('도메인 1·2 학습문서 6편이 있고 비어 있지 않다', () {
      for (final taskId in [
        'aif-t1-1', 'aif-t1-2', 'aif-t1-3',
        'aif-t2-1', 'aif-t2-2', 'aif-t2-3',
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
    test('aif-t3-3: 은퇴한 AWS CAF for AI 인용에 경고가 붙어 있다', () {
      final raw = read('aif-t3-3');
      expect(raw, contains('aws-caf-for-ai'),
          reason: '대조군 — 그 인용이 아직 문서에 있다');
      expect(raw, contains('이 가이드가 은퇴했습니다'),
          reason: '은퇴 사실을 참고자료에 적어야 한다');
      expect(raw, contains('MLSEC03-BP04'),
          reason: '살아 있는 인접 출처를 함께 적어 후속 작업을 돕는다');
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
}
