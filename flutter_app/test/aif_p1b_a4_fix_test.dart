import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// AIF-C01 §P1b-A4 가드 — `aif-t4-1-q11`의 Data Wrangler 구현 세부 제거.
/// 2026-11-06 전 콘텐츠 2단 검토의 **마지막 중복·겹침 트랙 항목**이다.
///
/// ## 무엇이 결함이었는가 — 사실 오류가 아니다
///
/// 인용된 세 서술은 **공식 페이지에 글자 그대로 실재한다**(직접 실측):
/// `data-wrangler-transform.html`의 Balance Data 절이 `The interpolated sample
/// has a value of 0.7A + 0.3B.`와 `You can't balance datasets containing column
/// vectors.`를 적고, 거리 계산이 수치 특징만 쓴다는 것도 그 절에 있다. 따라서
/// **「거짓을 고쳤다」가 아니고 「등급을 올렸다」**다.
///
/// 결함은 셋이었다 — ⓐ 해설이 `0.7A + 0.3B`라는 **구현 수준 수치**까지
/// 내려가고, ⓑ 오답 근거가 「열 벡터 데이터세트는 균형 불가」라는 **도구 제품
/// 제약**에 기대며, ⓒ 그 도구의 현재 접근 경로가 바뀌었다. AIF-C01 목표
/// **4.1.5는 데이터세트의 편향·큐레이션**을 묻는 자리이고 특정 도구의 보간
/// 가중치를 묻는 자리가 아니다.
///
/// ## 비자명한 공식 사실
///
/// ⚠️ **Data Wrangler의 클래식 UI는 새 Studio 경험에서 지원되지 않는다** —
/// `studio-updated-migrate-ui.html`이 `The new Studio experience doesn't support
/// the classic Data Wrangler UI, and you must create a Canvas application if you
/// want to continue using Data Wrangler.`로 적고, `Canvas provides data
/// preparation features powered by Data Wrangler.`로 대체 경로를 준다. 서비스가
/// **닫힌 것이 아니라 접근 경로가 Canvas로 접힌 것**이므로 처리는 「인용 유지 +
/// 상태 명시」다(2026-11-06 AIF CAF 판정과 같은 계열).
///
/// ⚠️ **공식 시험 가이드 v1.1도 같은 방향으로 움직였다** — 목표 1.3.4의 예시가
/// SageMaker 하위 기능(Data Wrangler·Feature Store·Model Monitor)에서
/// Bedrock·Amazon Quick·Kiro·SageMaker AI로 **교체**됐다
/// (`docs/content-research/AIF-C01/97-repo-json-diff.md`). 등급 판정의 보강 근거다.
///
/// ⚠️ **공식 「데이터 균형 맞추기」 연산자는 정확히 셋**이고 셋 다 **샘플 수를
/// 바꾼다** — 무작위 오버샘플링(복제) · 무작위 언더샘플링(제거) · SMOTE(보간).
/// 그래서 새 오답 보기를 **손실 가중치 조정**으로 두었다: 그것은 학습 알고리즘
/// 쪽 기법이라 이 연산자 목록에 들지 않는다. ⚠️ 「AWS에 범주별 손실 가중치가
/// 없다」고 적지 않는다(XGBoost `scale_pos_weight` 등이 있어 거짓이 된다) —
/// 단정의 범위는 **이 연산자 목록**이다.
///
/// ## 비자명한 규율
///
/// ⚠️ **보고서 범위가 또 하한이었다.** 보고서는 문항 1건만 들었지만 같은
/// 구현 세부가 **라이브 학습문서 `aif-t4-1.md`에도** 있었다(본문 §5 ③ + 참고자료
/// 항목 제목). **문항 가드는 `.md`를 보지 않는다.** 그래서 금지 단정을
/// 자격증 14편 **전수 집계**로 둔다(2026-11-06 AIF 「PT 필수」 교훈 — 한 파일에서
/// 찾으면 그 문구로 레포 전역을 쓸고 가드도 전역으로 건다).
///
/// ⚠️ **탐지기에 대조군을 붙인다.** 「0건」이 탐지기가 고장 나서 0건인지
/// 정말 0건인지 구별해야 한다(합성 입력 단위 테스트).
///
/// ⚠️ **정답 인덱스·`skill`·`section`·`difficulty`·`verified`는 전부 불변**이다.
/// `aif_questions_test.dart`가 Task별 목표 전수 커버리지를 단정하므로 `skill`을
/// 잃으면 그 단정이 먼저 깨진다. 그리고 **AI는 `verified: true`를 쓰지 않는다.**
void main() {
  final questionFile =
      File('assets/content/aif/aif-t4-1.questions.json');
  final docFile = File('assets/content/aif/aif-t4-1.md');
  final aifDir = Directory('assets/content/aif');

  Map<String, dynamic> q11() {
    final data =
        json.decode(questionFile.readAsStringSync()) as Map<String, dynamic>;
    final list = (data['questions'] as List).cast<Map<String, dynamic>>();
    return list.firstWhere((q) => q['id'] == 'aif-t4-1-q11');
  }

  /// 문항 전체(지문·보기·해설·오답 근거·출처)를 한 덩어리로 본다 —
  /// 같은 오류가 보기와 `wrongExplanations` 양쪽에 있던 사례가 반복됐다.
  String allText() => json.encode(q11());

  /// 제거 대상 — 도구 구현 세부. 탐지기 본체를 함수로 빼서 대조군을 붙인다.
  List<String> implementationDetails(String text) {
    const needles = <String>[
      '0.7A',
      '0.3B',
      '열 벡터',
      'R-squared',
    ];
    return needles.where(text.contains).toList();
  }

  test('대조군: q11이 읽히고 구조가 성립한다', () {
    final q = q11();
    expect((q['options'] as List).length, 4);
    expect(
      (q['wrongExplanations'] as Map).keys.map((k) => k.toString()).toSet(),
      {'0', '1', '3'},
    );
    expect(allText().length, greaterThan(400));
  });

  test('§P1b-A4: 정답 인덱스·skill·section·difficulty·verified 불변', () {
    final q = q11();
    expect(q['correct'], 2, reason: '정답은 2 자리에 그대로 둔다');
    expect(q['skill'], '4.1.5');
    expect(q['section'], 'datasets');
    expect(q['difficulty'], 'foundational');
    expect(q['verified'], false, reason: 'AI는 verified: true를 쓰지 않는다');
  });

  test('§P1b-A4: 문항에서 도구 구현 세부가 사라졌다', () {
    expect(implementationDetails(allText()), isEmpty);
  });

  test('§P1b-A4: 대조군 — 같은 탐지기가 정정 전 문구를 잡는다', () {
    expect(
      implementationDetails('보간된 샘플의 값은 0.7A + 0.3B가 됩니다'),
      contains('0.7A'),
    );
    expect(
      implementationDetails('열 벡터를 포함하는 데이터세트는 균형을 맞출 수 없습니다'),
      contains('열 벡터'),
    );
    expect(
      implementationDetails('세 연산자는 모두 샘플 수를 바꿔 비율을 맞춥니다'),
      isEmpty,
      reason: '정정문 자신이 걸리면 안 된다',
    );
  });

  test('§P1b-A4: 시험 수준의 세 연산 구분이 남아 있다', () {
    final text = allText();
    for (final required in <String>[
      '무작위 오버샘플링',
      '무작위 언더샘플링',
      'SMOTE',
      '복제',
      '제거',
      '보간',
    ]) {
      expect(text.contains(required), isTrue, reason: '빠진 문구: $required');
    }
  });

  test('§P1b-A4: 새 오답 보기는 손실 가중치이고 범위가 연산자 목록으로 한정된다', () {
    final q = q11();
    final option3 = (q['options'] as List)[3] as String;
    final wrong3 = (q['wrongExplanations'] as Map)['3'] as String;
    expect(option3.contains('손실'), isTrue);
    expect(option3.contains('가중치'), isTrue);
    expect(wrong3.contains('손실'), isTrue);
    expect(
      wrong3.contains('연산자'),
      isTrue,
      reason: '단정의 범위는 공식 「데이터 균형 맞추기」 연산자 목록이다',
    );
  });

  test('§P1b-A4: 문항이 Data Wrangler의 현재 접근 경로를 적고 출처가 실재한다', () {
    final q = q11();
    final explanation = q['explanation'] as String;
    expect(explanation.contains('Canvas'), isTrue);
    expect(explanation.contains('클래식'), isTrue);
    final urls = (q['sources'] as List)
        .cast<Map<String, dynamic>>()
        .map((s) => s['url'] as String)
        .toList();
    expect(
      urls.any((u) => u.contains('studio-updated-migrate-ui.html')),
      isTrue,
      reason: '상태 서술의 근거 페이지가 출처에 있어야 한다',
    );
    expect(
      urls.any((u) => u.contains('data-wrangler-transform.html')),
      isTrue,
      reason: '세 연산자의 정본은 그대로 남긴다',
    );
  });

  test('§P1b-A4: 라이브 학습문서도 같은 층으로 맞춰졌다', () {
    final md = docFile.readAsStringSync();
    expect(implementationDetails(md), isEmpty);
    expect(md.contains('Canvas'), isTrue);
    expect(
      md.contains('studio-updated-migrate-ui.html'),
      isTrue,
      reason: '상태 서술의 근거 페이지가 참고자료에 있어야 한다',
    );
    for (final required in <String>['무작위 오버샘플링', '무작위 언더샘플링', 'SMOTE']) {
      expect(md.contains(required), isTrue, reason: '빠진 문구: $required');
    }
  });

  test('§P1b-A4: AIF 학습문서 전수에서 구현 세부가 0건이다', () {
    final docs = aifDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList();
    expect(docs.length, greaterThanOrEqualTo(14), reason: '전수 대조군 — 비공허');
    final offenders = <String>[];
    for (final f in docs) {
      final hits = implementationDetails(f.readAsStringSync());
      if (hits.isNotEmpty) {
        offenders.add('${f.uri.pathSegments.last}: ${hits.join(", ")}');
      }
    }
    expect(offenders, isEmpty);
  });

  test('§P1b-A4: AIF 문항 전수에서도 구현 세부가 0건이다', () {
    final banks = aifDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.questions.json'))
        .toList();
    expect(banks.length, greaterThanOrEqualTo(14), reason: '전수 대조군 — 비공허');
    final offenders = <String>[];
    for (final f in banks) {
      final hits = implementationDetails(f.readAsStringSync());
      if (hits.isNotEmpty) {
        offenders.add('${f.uri.pathSegments.last}: ${hits.join(", ")}');
      }
    }
    expect(offenders, isEmpty);
  });
}
