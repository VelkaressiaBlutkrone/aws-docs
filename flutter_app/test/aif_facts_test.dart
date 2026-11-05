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
    test('도메인 1 학습문서 3편이 있고 비어 있지 않다', () {
      for (final taskId in ['aif-t1-1', 'aif-t1-2', 'aif-t1-3']) {
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
