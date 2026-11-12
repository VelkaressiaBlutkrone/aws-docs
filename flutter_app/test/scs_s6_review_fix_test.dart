import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// SCS **6단계 — 보류 문항 교체·정정 회귀 가드** (2026-11-12, 배치 1).
///
/// ## 보고가 보류로 분류한 이유
///
/// 2026-11-11 외부 검수 §4 는 12문항을 **보류(재작성·교체)**로 두었다. 공통 결함은
/// 「**Skill 이 묻는 층이 아닌 것을 묻는다**」다 — 솔루션의 내부 구현(어느 Lambda 가
/// 무엇을 호출하는지), 서비스 제공 상태 자체(메타 문항), 보안이 아닌 네트워크 성능.
///
/// 배치 1은 그중 **다섯 자리**를 닫았다(교체 4 + 정정 1).
///
/// | id | 전 | 후 |
/// |---|---|---|
/// | `t2-2-q2` | 어느 Lambda 가 SSM 문서를 넘기는지 | **격리 후 보존·부작용**(증거 보존) |
/// | `t2-2-q3` | 격리 플래그와 120초 재확인 | **스냅샷 두 단계 복사의 이유** |
/// | `t2-2-q15` | 정답이 「…단정하지 않습니다」(메타) | **단정문**으로 바꾸고 귀속 정정 |
/// | `t3-2-q13` | Q Developer 종료 범위(메타) | **파이프라인 도구 선택** |
/// | `t3-3-q12` | Transit Gateway ECMP 대역폭(성능) | **Network Firewall 미지원 셋** |
///
/// ## ⚠️⚠️ `t2-2-q15` 는 출처가 사실을 담지 않던 자리였다
///
/// 옛 해설이 「**Security Lake 가 기본 지원하는 소스**로 공식은 CloudTrail 관리 이벤트·VPC
/// 흐름 로그·EKS 감사 로그 셋을 듭니다」로 적고 `what-is-security-lake.html` 을 출처로
/// 달았는데, **그 페이지에는 그 목록이 없다**(2026-11-12 실측: 본문이 「소스 관리」 페이지로
/// 넘긴다). 셋을 적는 것은 **Detective 페이지**이고 거기서도 「통합으로 수집할 수 있는
/// 소스」이지 Security Lake 의 기본 지원 소스 **전체 목록**이 아니다. 같은 페이지가 바로
/// 다음 문장에서 「통합 뒤 Detective 가 당겨오기 시작하는 원시 로그는 CloudTrail 관리
/// 이벤트와 VPC 흐름 로그 관련」이라고 적는다.
///
/// ⚠️ **「Security Lake 기본 지원 소스는 그보다 많다」고 적지 않았다** — 전체 목록을 담은
/// 페이지가 이 Task 의 md 출처에 없어 **미확보 사실을 새로 단정하지 않는다**는 규율에
/// 걸린다(2026-11-11 CLF 프리 티어·SAA DX 단가 선례). 적은 것은 **두 범위가 다르다**는
/// 측정된 사실까지다.
///
/// ## ⭐ 교체 문항의 재료는 전부 그 Task 의 md 출처에서 측정했다
///
/// G-84(문항 출처 ⊆ 학습문서 출처)를 지키려고 새 URL 을 들이지 않았다. 세 파일의 문항
/// 출처 전수가 md 안에 있는 것을 기계로 확인했다(위반 0건).
void main() {
  const dir = 'assets/content/scs';

  Map<String, Map<String, dynamic>> bank(String taskId) {
    final raw = jsonDecode(File('$dir/$taskId.questions.json').readAsStringSync());
    final list = (raw is Map<String, dynamic> ? raw['questions'] : raw) as List;
    return {
      for (final q in list.cast<Map<String, dynamic>>()) q['id'] as String: q,
    };
  }

  Map<String, dynamic> q(String id) {
    final taskId = id.substring(0, id.lastIndexOf('-'));
    final found = bank(taskId)[id];
    expect(found, isNotNull, reason: '$id 가 없다 — 교체가 id 를 바꿨는가');
    return found!;
  }

  /// 문항 전체(지문·보기·해설·오답 근거·출처 제목)를 이어 붙인다.
  String allText(Map<String, dynamic> e) => [
        e['stem'],
        e['skill'],
        ...(e['options'] as List),
        e['explanation'],
        ...(e['wrongExplanations'] as Map).values,
        ...(e['sources'] as List).map((s) => '${s['title']} ${s['url']}'),
      ].join(' ');

  String correctOf(Map<String, dynamic> e) =>
      (e['options'] as List)[e['correct'] as int] as String;

  group('6단계 배치 1 — 보류 5문항 (보고 §4)', () {
    test('대조군: 다섯 문항이 읽히고 전부 드래프트다', () {
      for (final id in const [
        'scs-t2-2-q2', 'scs-t2-2-q3', 'scs-t2-2-q15',
        'scs-t3-2-q13', 'scs-t3-3-q12',
      ]) {
        final e = q(id);
        expect((e['options'] as List).length, 4, reason: id);
        expect(e['verified'], isFalse, reason: '$id 는 드래프트다 (flip 은 사람만)');
      }
    });

    test('정답 인덱스·skill·section·difficulty 가 전부 불변이다', () {
      // ⚠️ 교체는 문항을 다시 쓰는 것이지 **자리를 옮기는 것이 아니다**.
      //    skill 이 바뀌면 `scs_questions_test` 의 Task 커버리지 단정이 먼저 깨진다.
      const expected = <String, List<Object>>{
        'scs-t2-2-q2': [1, '2.2.1', 'capture', 'applied'],
        'scs-t2-2-q3': [2, '2.2.1', 'capture', 'applied'],
        'scs-t2-2-q15': [2, '2.2.5', 'root-cause', 'applied'],
        'scs-t3-2-q13': [0, '3.2.6', 'pipeline', 'foundational'],
        'scs-t3-3-q12': [3, '3.3.4', 'segmentation', 'applied'],
      };
      for (final entry in expected.entries) {
        final e = q(entry.key);
        expect([e['correct'], e['skill'], e['section'], e['difficulty']],
            entry.value,
            reason: '${entry.key} 의 보존 필드가 바뀌었다');
      }
    });

    test('t2-2-q2: 격리 후 보존·부작용을 묻고 내부 호출 주체를 묻지 않는다', () {
      final e = q('scs-t2-2-q2');
      final c = correctOf(e);
      expect(c, contains('종료 방지'));
      expect(c, contains('EBS 볼륨이 보존'));
      expect(c, contains('무효화'));
      // 공식이 함께 적는 부작용 — 같은 역할을 쓰는 다른 인스턴스가 영향을 받는다.
      expect(e['explanation'], contains('같은 역할'));
      expect(e['explanation'], contains('AWS CLI'));
      // 옛 문항의 구현 세부가 되살아나지 않는다.
      expect(allText(e), isNot(contains('Run Command')));
      expect(allText(e), isNot(contains('메타 데이터 태그')));
    });

    test('t2-2-q3: 두 단계 복사의 이유를 묻고 120초 재확인을 묻지 않는다', () {
      final e = q('scs-t2-2-q3');
      final c = correctOf(e);
      expect(c, contains('침해'));
      expect(c, contains('삭제'));
      expect(c, contains('포렌식 계정'));
      // 기제는 해설 쪽에 둔다 — 공식이 적는 두 키를 모두 적는다.
      expect(e['explanation'], contains('공유한 AWS KMS 키'));
      expect(e['explanation'], contains('포렌식 KMS 키'));
      // 옛 문항의 격리 플래그 분기는 q2 로도 가지 않는다(주제가 다르다).
      expect(allText(e), isNot(contains('격리 플래그')));
    });

    test('t2-2-q15: 단정문이고 틀린 귀속이 사라졌다', () {
      final e = q('scs-t2-2-q15');
      final c = correctOf(e);
      expect(c, contains('CloudTrail 관리 이벤트'));
      expect(c, contains('VPC 흐름 로그'));
      expect(c, isNot(contains('단정하지')), reason: '메타 표현을 지웠다');
      // ⚠️ 셋을 「Security Lake 기본 지원 소스」로 귀속하던 문장이 0건이다.
      expect(allText(e), isNot(contains('Security Lake가 기본 지원하는 소스로 공식은')));
      expect(e['explanation'], contains('Detective 통합이'));
      // 출처는 셋을 실제로 적는 페이지 하나만 남긴다.
      final urls = (e['sources'] as List).map((s) => s['url'] as String).toList();
      expect(urls, hasLength(1));
      expect(urls.single, contains('detective/latest/userguide/what-is-detective'));
    });

    test('t3-2-q13: 파이프라인 도구 선택을 묻고 수명 주기를 묻지 않는다', () {
      final e = q('scs-t3-2-q13');
      final c = correctOf(e);
      expect(c, contains('Inspector Code Security'));
      // 공식이 적는 스캔 대상 셋.
      expect(e['explanation'], contains('1자 애플리케이션 소스 코드'));
      expect(e['explanation'], contains('3자 애플리케이션 의존성'));
      expect(e['explanation'], contains('코드형 인프라'));
      // ⚠️ 「종료된 이름이 보기에 나오면 정답이 아닐 가능성이 높다」는 위험한 조언이었다.
      expect(allText(e), isNot(contains('정답이 아닐 가능성')));
      expect(allText(e), isNot(contains('Kiro')));
    });

    test('t3-3-q12: 미지원 셋을 묻고 ECMP 대역폭을 묻지 않는다', () {
      final e = q('scs-t3-3-q12');
      final c = correctOf(e);
      expect(c, contains('VPC 피어링'));
      expect(c, contains('Global Accelerator'));
      expect(c, contains('AmazonProvidedDNS'));
      expect(allText(e), isNot(contains('ECMP')),
          reason: '네트워크 성능 주제를 보안 Skill 에서 뺐다');
    });

    test('⚠️ 새 출처가 그 Task 의 학습문서에 실재한다 (G-84)', () {
      for (final taskId in const [
        'scs-t2-2', 'scs-t3-2', 'scs-t3-3',
        'scs-t3-1', 'scs-t5-3', 'scs-t6-1', 'scs-t6-3',
      ]) {
        final md = File('$dir/$taskId.md').readAsStringSync();
        for (final e in bank(taskId).values) {
          for (final s in (e['sources'] as List)) {
            expect(md, contains(s['url'] as String),
                reason: '${e['id']} 의 출처가 $taskId.md 에 없다');
          }
        }
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // 6단계 배치 2 — 보류 잔여 5문항 (2026-11-12)
  //
  // 이 배치로 **보고의 보류 10문항이 전부 닫혔다**. 배치 1과 같은 판정을 썼다 —
  // 묻는 층을 올리고 같은 Skill·같은 정답 자리를 유지한다.
  //
  // ⭐ `t3-1-q4` 는 **보고 §1-3 이 「0문항」으로 적은 빈 주제를 채웠다** — 공식 기술
  // 3.1.2 가 이름까지 드는 `AWS IoT 정책` 이 240문항에 없었다. 교체 주제를 고를 때
  // **그 Task 의 형제 문항 전수를 먼저 확인**했고, 보고가 제안한 「전략 선택」 축에서
  // 아직 안 쓰인 것이 IoT 뿐이었다(지리·속도·핑거프린팅은 `q9`~`q12`, Marketplace·
  // GovCloud 는 `q15`, 제품 역할·보호 대상·과금은 `q1`~`q3` 가 이미 쓴다).
  //
  // ⚠️ `t6-1-q11` 의 보고 수정안(「보안 계정이 Config 애그리게이터·Security Hub CSPM·
  // Firewall Manager 를 운영하려면 각각 무엇이 필요한가」)은 **같은 Task 의 `q10` 이
  // 이미 묻는다**(위임된 관리자 등록 + 지원 여부 + 신뢰 액세스). 그래서 그 제안을
  // 그대로 쓰지 않고 **받는 권한의 범위**로 축을 옮겼다 — 보고가 지적한 결함(「자주
  // 쓰이는 대상」이라는 주관적 기준)은 그대로 해소된다.
  group('6단계 배치 2 — 보류 잔여 5문항 (보고 §4)', () {
    test('대조군: 다섯 문항이 읽히고 전부 드래프트다', () {
      for (final id in const [
        'scs-t3-1-q4', 'scs-t5-3-q12',
        'scs-t6-1-q9', 'scs-t6-1-q11', 'scs-t6-3-q14',
      ]) {
        final e = q(id);
        expect((e['options'] as List).length, 4, reason: id);
        expect(e['verified'], isFalse, reason: '$id 는 드래프트다 (flip 은 사람만)');
      }
    });

    test('정답 인덱스·skill·section·difficulty 가 전부 불변이다', () {
      const expected = <String, List<Object>>{
        'scs-t3-1-q4': [3, '3.1.1', 'strategy', 'applied'],
        'scs-t5-3-q12': [3, '5.3.4', 'masking', 'applied'],
        'scs-t6-1-q9': [2, '6.1.3', 'org-policies', 'applied'],
        'scs-t6-1-q11': [1, '6.1.4', 'delegated-admin', 'foundational'],
        'scs-t6-3-q14': [1, '6.3.3', 'well-architected', 'applied'],
      };
      for (final entry in expected.entries) {
        final e = q(entry.key);
        expect([e['correct'], e['skill'], e['section'], e['difficulty']],
            entry.value,
            reason: '${entry.key} 의 보존 필드가 바뀌었다');
      }
    });

    test('t3-1-q4: IoT 사물 정책 변수 전략을 묻고 제품 개명을 묻지 않는다', () {
      final e = q('scs-t3-1-q4');
      final c = correctOf(e);
      expect(c, contains('사물 정책 변수'));
      expect(c, contains('클라이언트 ID'));
      // 공식이 함께 못박는 전제 둘.
      expect(e['explanation'], contains('MQTT 또는 WebSocket 기반 MQTT'));
      expect(e['explanation'], contains('AttachThingPrincipal'));
      // 옛 메타 문항(제품 이름이 개명인지)이 되살아나지 않는다.
      expect(allText(e), isNot(contains('network security director')));
      expect(allText(e), isNot(contains('시험 가이드')));
    });

    test('t5-3-q12: 정책 계층·식별자·탐지 지표를 묻고 제공 상태를 묻지 않는다', () {
      final e = q('scs-t5-3-q12');
      final c = correctOf(e);
      expect(c, contains('계정 정책과 로그 그룹 정책을 함께'));
      expect(c, contains('사용자 지정 데이터'));
      expect(e['explanation'], contains('LogEventsWithFindings'));
      expect(e['explanation'], contains('30,720자'));
      expect(e['explanation'], contains('logs:Unmask'));
      // 옛 문항은 SNS 메시지 데이터 보호의 **제공 상태**를 정답 근거로 썼다.
      expect(allText(e), isNot(contains('신규 고객')));
      expect(allText(e), isNot(contains('SNS')));
    });

    test('t6-1-q9: 분리 시 롤백만 묻고 유형 개수를 묻지 않는다', () {
      final e = q('scs-t6-1-q9');
      final c = correctOf(e);
      expect(c, contains('롤백'));
      // ⚠️ 정답 후반부의 「유형의 개수는 … 단정하지 않는다」가 사라졌다.
      expect(allText(e), isNot(contains('개수')));
      expect(allText(e), isNot(contains('Shield Network Security Director')));
      // 남긴 교육 가치 — 요청을 평가하는 정책이 아니라 구성을 선언하는 정책이다.
      expect(e['explanation'], contains('제어 플레인'));
      expect(e['explanation'], contains('서비스 연결 역할'));
    });

    test('t6-1-q11: 받는 권한의 범위를 묻고 주관적 기준을 쓰지 않는다', () {
      final e = q('scs-t6-1-q11');
      final c = correctOf(e);
      expect(c, contains('일부 관리 권한'));
      expect(c, contains('Organizations 읽기 전용'));
      expect(c, contains('서비스마다'));
      // 「자주 쓰이는 대상」이라는 주관적 기준이 사라졌다.
      expect(allText(e), isNot(contains('자주')));
      // q10 과 축이 겹치지 않는다 — 전제(지원 여부·신뢰 액세스)는 해설 쪽에만 둔다.
      expect(correctOf(e), isNot(contains('신뢰 액세스')));
    });

    test('t6-3-q14: Tool 의 엔티티·출력·병행을 묻고 프리뷰 상태를 묻지 않는다', () {
      final e = q('scs-t6-3-q14');
      final c = correctOf(e);
      expect(c, contains('워크로드'));
      expect(c, contains('높은 위험 항목'));
      expect(c, contains('함께 쓸 수'));
      expect(e['explanation'], contains('서로 보완'));
      // 프리뷰 상태는 q13 이 다룬다 — 정답 표식이 되지 않게 이 문항에서 뺀다.
      expect(allText(e), isNot(contains('프리뷰')));
    });
  });
}
