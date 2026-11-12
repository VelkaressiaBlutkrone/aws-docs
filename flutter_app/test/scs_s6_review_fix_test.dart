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
        'scs-t1-2', 'scs-t2-1', 'scs-t4-1', 'scs-t5-2', 'scs-t6-2',
        'scs-t1-1', 'scs-t3-3',
        'scs-t1-3', 'scs-t4-2', 'scs-t5-1', 'scs-t5-3',
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

  // ══════════════════════════════════════════════════════════════════
  // 6단계 배치 3 — 🟡 잔여 13문항 + 전수 스캔으로 찾은 `t4-1-q4` (2026-11-12)
  //
  // 보고 §4 의 🟡 두 표(「정답 모호·용어·시나리오」 4건과 「메타 문항·수명주기」
  // 9건)에서 1~3단계·6단계 배치 1~2 가 닫지 않은 잔여다. 공통 처방은 보고가 적은
  // 그대로다 — **상태 정보는 해설 끝 한 줄로 내리고 정답 근거에서 뺀다.**
  //
  // ⚠️⚠️ **보고 범위가 또 하한이었다.** 「정답 보기마다 상태 문구가 붙어 정답
  // 표식이 된다」는 지적을 240문항 전수로 세니 **8건**이었고 보고 목록에 없는
  // `t4-1-q4`(SMS MFA 지원 종료)가 끼어 있었다. 같은 결함 계열이라 함께 닫고
  // **전수 집계 가드**로 고정했다 — 리터럴 가드는 자기가 본 문항만 안다.
  //
  // ⚠️ `t2-1-q15` 는 보고의 두 처방 중 **전제 추가**를 골랐다. 「수집 → 격리
  // 순서만 묻는다」로 가면 같은 보고가 중복으로 지목한 `t2-2-q1` 과 겹쳐진다.
  //
  // ⚠️ `t6-2-q15` 의 교체 주제는 **그 Task 의 형제 문항 전수를 먼저 확인**해
  // 골랐다. 보고가 제안한 「Service Catalog 포트폴리오 공유·제약 조건」은 공식
  // 소개 페이지의 네 이점을 `q14` 가 이미 다 쓴다(표준화·세분화된 액세스 제어·
  // 확장성과 버전 관리). 그래서 같은 Task md 출처 안에서 아직 안 쓰인
  // **RAM 관리형 권한의 최대 권한 성질**로 갔다.
  group('6단계 배치 3 — 🟡 잔여 13문항 + t4-1-q4 (보고 §4)', () {
    const ids = <String>[
      'scs-t1-2-q12', 'scs-t2-1-q2', 'scs-t2-1-q14', 'scs-t2-1-q15',
      'scs-t3-2-q3', 'scs-t4-1-q4', 'scs-t4-1-q9',
      'scs-t5-2-q7', 'scs-t5-2-q15', 'scs-t6-1-q1', 'scs-t6-2-q15',
      'scs-t6-3-q9', 'scs-t6-3-q10', 'scs-t6-3-q12',
    ];

    test('대조군: 열네 문항이 읽히고 전부 드래프트다', () {
      for (final id in ids) {
        final e = q(id);
        expect((e['options'] as List).length, 4, reason: id);
        expect(e['verified'], isFalse, reason: '$id 는 드래프트다 (flip 은 사람만)');
      }
    });

    test('정답 인덱스·skill·section·difficulty 가 전부 불변이다', () {
      const expected = <String, List<Object>>{
        'scs-t1-2-q12': [3, '1.2.5', 'correlate', 'foundational'],
        'scs-t2-1-q2': [1, '2.1.1', 'runbooks', 'applied'],
        'scs-t2-1-q14': [1, '2.1.4', 'automate', 'applied'],
        'scs-t2-1-q15': [2, '2.1.4', 'automate', 'applied'],
        'scs-t3-2-q3': [2, '3.2.2', 'authorize', 'applied'],
        'scs-t4-1-q4': [3, '4.1.1', 'identity', 'applied'],
        'scs-t4-1-q9': [0, '4.1.2', 'temp', 'foundational'],
        'scs-t5-2-q7': [0, '5.2.2', 'integrity', 'applied'],
        'scs-t5-2-q15': [2, '5.2.4', 'backup', 'applied'],
        'scs-t6-1-q1': [0, '6.1.1', 'organizations', 'applied'],
        'scs-t6-2-q15': [2, '6.2.4', 'sharing', 'applied'],
        'scs-t6-3-q9': [0, '6.3.2', 'evidence', 'applied'],
        'scs-t6-3-q10': [1, '6.3.2', 'evidence', 'applied'],
        'scs-t6-3-q12': [3, '6.3.2', 'evidence', 'applied'],
      };
      expect(expected.keys.toSet(), ids.toSet());
      for (final entry in expected.entries) {
        final e = q(entry.key);
        expect([e['correct'], e['skill'], e['section'], e['difficulty']],
            entry.value,
            reason: '${entry.key} 의 보존 필드가 바뀌었다');
      }
    });

    test('⚠️ 전수: 정답 보기에 수명주기 상태 문구가 없다', () {
      // ⚠️⚠️ 보고 지적의 정체 — 「신규 고객에게 열려 있지 않습니다」가 정답
      //    보기마다 붙으면 **그 문구가 정답 표식**이 된다. 상태는 알아 둬야 하는
      //    사실이므로 지우지 않고 **해설로 내린다**(바로 아래 대조군이 그것을
      //    확인한다). 레포 관례인 「정직성 메모」와 어긋나지 않는다 — 메모는
      //    해설에 둔다는 것이 그 관례다.
      // ⚠️ 탐지기를 `열려 있지 않`만으로 두지 않는다 — 보안 문항에서 「포트가
      //    열려 있지 않습니다」처럼 정당한 용례가 생길 수 있다.
      final re = RegExp(r'신규 고객|지원 종료|유지 관리 상태|완전 종료');
      var total = 0;
      for (final f in Directory(dir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))) {
        final taskId = f.uri.pathSegments.last.split('.').first;
        for (final e in bank(taskId).values) {
          total++;
          expect(re.hasMatch(correctOf(e)), isFalse,
              reason: '${e['id']}: 수명주기 상태 문구가 정답 보기에 있다 — '
                  '해설로 내린다');
        }
      }
      expect(total, 240, reason: 'SCS 문항 전수를 돌지 않았다');
    });

    test('대조군: 같은 탐지기가 해설에서는 상태 문구를 찾는다', () {
      // 위 단정이 「탐지기가 아무것도 못 찾는다」로 거짓 통과하지 않게 한다.
      final re = RegExp(r'신규 고객|지원 종료|유지 관리 상태|완전 종료');
      final hits = <String>[];
      for (final f in Directory(dir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))) {
        final taskId = f.uri.pathSegments.last.split('.').first;
        for (final e in bank(taskId).values) {
          if (re.hasMatch(e['explanation'] as String)) hits.add(e['id'] as String);
        }
      }
      expect(hits.length, greaterThanOrEqualTo(5),
          reason: '상태를 해설에 적은 문항이 거의 없다 — 위 단정이 공허해진다');
    });

    test('⚠️ 전수: 「공식 기술·가이드가 예시로 드는」 메타 문구가 없다', () {
      // 보고: 「공식 기술이 예시로 드는 수단」 문구를 지우고 **요구사항으로**
      // 묻는다. 시험은 가이드의 문장을 묻지 않는다.
      final re = RegExp(r'공식 (기술|가이드)[^.?]{0,40}예시로');
      expect(re.hasMatch('공식 기술이 상관 관계 분석의 예시로 드는 수단은'), isTrue,
          reason: '탐지기가 그 형태를 못 잡는다');
      for (final f in Directory(dir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))) {
        final taskId = f.uri.pathSegments.last.split('.').first;
        for (final e in bank(taskId).values) {
          expect(re.hasMatch(allText(e)), isFalse,
              reason: '${e['id']}: 가이드 문장을 묻지 않고 요구사항으로 묻는다');
        }
      }
    });

    test('t1-2-q12: 세 요구로 묻고 가이드 예시 문구를 쓰지 않는다', () {
      final e = q('scs-t1-2-q12');
      expect(e['stem'], contains('세 요구에 맞게'));
      expect(e['stem'], isNot(contains('공식 기술이')));
      expect(correctOf(e), contains('변환은 Lambda'));
    });

    test('t2-1-q2: 두 요구로 묻고 오답 근거의 메타 표현이 사라졌다', () {
      final e = q('scs-t2-1-q2');
      expect(e['stem'], contains('두 요구에 각각 맞는'));
      expect(e['stem'], isNot(contains('공식 가이드가')));
      expect((e['wrongExplanations'] as Map)['2'],
          isNot(contains('공식 예시')));
    });

    test('t2-1-q14: 정답은 임계 경로까지만이고 상태는 해설에 있다', () {
      final e = q('scs-t2-1-q14');
      final c = correctOf(e);
      expect(c, contains('임계 경로'));
      expect(c, contains('라우팅 컨트롤'));
      expect(c, isNot(contains('유지 관리')));
      expect(e['explanation'], contains('유지 관리 상태'));
    });

    test('t2-1-q15: 조직 방침이 전제로 들어가고 공식 분류가 아님을 적는다', () {
      // ⚠️ 보고: 「자격 증명 폐기·종료는 승인」이라는 구분은 **공식 분류가 아니다**.
      //    공식 포렌식 솔루션은 격리까지 자동으로 수행한다.
      final e = q('scs-t2-1-q15');
      expect(e['stem'], contains('되돌릴 수 없는 조치에는 사람 승인'));
      expect(e['explanation'], contains('공식 분류가 아니라 조직의 방침'));
      expect(e['explanation'], contains('격리까지 자동'));
      // 공식이 고정하는 것은 순서다.
      expect(e['explanation'], contains('캡처해 저장한 뒤'));
    });

    test('t3-2-q3: 지문이 역할 교체이고 해설과 같은 상황을 본다', () {
      // ⚠️ 보고: 지문은 「권한을 바꿨다」인데 해설은 「역할을 교체했다」의 지연을
      //    설명했다. 공식이 최종 일관성 지연을 적는 것은 **역할 교체** 쪽이다.
      final e = q('scs-t3-2-q3');
      expect(e['stem'], contains('역할을 다른 역할로 교체'));
      expect(e['stem'], isNot(contains('역할의 권한을 바꿨')));
      final c = correctOf(e);
      expect(c, contains('최종 일관성'));
      expect(c, contains('분리하고'));
      expect(e['explanation'], contains('최대 1시간'));
    });

    test('t4-1-q4: 현행 유형만 묻고 정답에 상태 문구가 없다', () {
      // ⚠️ 보고 목록 밖에서 전수 스캔으로 찾은 8번째다.
      final e = q('scs-t4-1-q4');
      final c = correctOf(e);
      expect(c, contains('하드웨어 TOTP 토큰'));
      expect(c, isNot(contains('지원 종료')));
      expect(e['stem'], isNot(contains('그 상태')));
      expect(e['explanation'], contains('지원이 종료'));
    });

    test('t4-1-q9: 정답은 원인까지만이고 해설이 공식 권고를 적는다', () {
      // ⚠️ 보고: 「7일을 보장하려면 IAM 사용자 자격 증명으로 서명」이 보안 시험의
      //    정답 문구로 나가면 안 된다. 공식 FAQ 의 권고는 **자격 증명 갱신 로직**과
      //    **세션 기간 확인**이고, CloudFront 서명 URL 은 이 페이지에 없으므로
      //    쓰지 않았다(G-84 와 「미확보 사실을 새로 단정하지 않는다」).
      final e = q('scs-t4-1-q9');
      final c = correctOf(e);
      expect(c, contains('먼저 오는 쪽'));
      expect(c, isNot(contains('IAM 사용자 자격 증명으로 서명')));
      expect(e['explanation'], contains('갱신 로직'));
      expect(e['explanation'], contains('s3:signatureAge'));
      expect(allText(e), isNot(contains('CloudFront')));
    });

    test('t5-2-q7: 저장소 잠금 절차를 묻고 상태는 해설에 있다', () {
      final e = q('scs-t5-2-q7');
      final c = correctOf(e);
      expect(c, contains('24시간'));
      expect(c, contains('바꾸거나 지울 수 없습니다'));
      expect(c, isNot(contains('신규 고객')));
      expect(e['stem'], isNot(contains('시험 가이드')));
      // 상태와 새 설계의 대안은 해설에 남는다.
      expect(e['explanation'], contains('신규 고객에게 열려 있지 않'));
      expect(e['explanation'], contains('Object Lock 준수 모드'));
      // 공식 권고 순서 — 잠금을 완료한 뒤 업로드한다.
      expect(e['explanation'], contains('저장소 잠금 정책을 완료한 뒤 아카이브'));
    });

    test('t5-2-q15: 전송 보안을 묻고 Discovery 는 해설로 내려갔다', () {
      final e = q('scs-t5-2-q15');
      final c = correctOf(e);
      expect(c, contains('VPC 엔드포인트'));
      expect(c, contains('무결성 검증'));
      expect(c, contains('IAM 역할'));
      expect(c, isNot(contains('Discovery')));
      expect(e['explanation'], contains('Discovery'));
      expect(e['explanation'], contains('2025-05-20'));
    });

    test('t6-1-q1 계열: CloudTrail 「계정 전체에 활성화」 오역이 전수에서 0건이다', () {
      // ⚠️⚠️ 보고: 「계정 전체에 활성화」는 공식 `activate AWS CloudTrail
      //    **across accounts**` 의 오역이다. 그리고 옛 해설이 조직의 기능을
      //    **넷**으로 적었는데 공식 기능 목록은 일곱이다.
      // ⚠️ **이 단정은 배치 4 의 교체에 한 번 걸렸다.** 처음에는 `t6-1-q1` 의
      //    정답 문구를 리터럴로 묶었는데, 배치 4 가 중복 해소로 그 문항의 관점을
      //    바꾸자 레드가 됐다. 배치의 의도는 「오역이 다시 들어오지 않는다」이므로
      //    **문항 하나가 아니라 전수를 세는 형태**로 다시 썼다 — 교체에 묶이지
      //    않는다.
      var cloudtrail = 0;
      for (final f in Directory(dir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))) {
        final taskId = f.uri.pathSegments.last.split('.').first;
        for (final e in bank(taskId).values) {
          final all = allText(e);
          if (!all.contains('CloudTrail')) continue;
          cloudtrail++;
          expect(all.contains('계정 전체에 활성화'), isFalse,
              reason: '${e['id']}: 공식은 「조직의 모든 계정에 걸쳐」다');
        }
      }
      expect(cloudtrail, greaterThanOrEqualTo(10),
          reason: 'CloudTrail 을 다루는 문항이 거의 없다 — 단정이 공허해진다');
      // 「조직이 주는 것은 넷」이라는 틀린 개수도 돌아오지 않는다.
      for (final taskId in const ['scs-t6-1']) {
        final text = File('$dir/$taskId.questions.json').readAsStringSync();
        expect(text.contains('중앙 감사와 리소스 공유 넷'), isFalse,
            reason: '$taskId: 공식 기능 목록은 일곱이다 — 개수를 단정하지 않는다');
      }
      // 그 사실의 소유자는 `t1-2-q4` 다(배치 4 묶음 8).
      expect(correctOf(q('scs-t1-2-q4')), contains('로깅 중단'));
    });

    test('t6-2-q15: RAM 관리형 권한을 묻고 수명주기를 묻지 않는다', () {
      final e = q('scs-t6-2-q15');
      final c = correctOf(e);
      expect(c, contains('최대 권한'));
      expect(c, contains('ID 기반 정책'));
      // 수명주기 문항이 아니므로 AppRegistry 가 나오지 않는다.
      // (상태 자체는 `scs-t6-2.md` §4-3 범위 메모가 계속 가르치고, 그 Task 의
      //  저작 규율 가드는 md 와 문항을 합쳐 보므로 그대로 통과한다.)
      expect(allText(e), isNot(contains('AppRegistry')));
      expect(e['explanation'], contains('서비스 제어 정책도 공유 리소스에 계속'));
      expect(e['explanation'], contains('완전한 소유권'));
      expect((e['sources'] as List).single['url'],
          'https://docs.aws.amazon.com/ram/latest/userguide/what-is.html');
    });

    test('t6-3-q9: 두 서비스를 가르는 축을 묻고 상태는 해설에 있다', () {
      final e = q('scs-t6-3-q9');
      final c = correctOf(e);
      expect(c, contains('AWS Artifact'));
      expect(c, contains('AWS Audit Manager'));
      expect(c, contains('축은'));
      expect(c, isNot(contains('신규 고객')));
      expect(e['explanation'], contains('신규 고객'));
    });

    test('t6-3-q10: 준수 평가 한계를 묻고 상태는 해설에 있다', () {
      final e = q('scs-t6-3-q10');
      final c = correctOf(e);
      expect(c, contains('준수 자체를 평가하지 않'));
      expect(c, contains('모든 정보를 담지 않을 수도'));
      expect(c, isNot(contains('신규 고객')));
      expect(e['explanation'], contains('신규 고객'));
    });

    test('t6-3-q12: 평가 운영·협업을 묻고 상태는 해설에 있다', () {
      final e = q('scs-t6-3-q12');
      final c = correctOf(e);
      expect(c, contains('비활성'));
      expect(c, contains('위임'));
      expect(c, isNot(contains('신규 고객')));
      expect(e['explanation'], contains('신규 고객'));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // 6단계 배치 4 — 중복 13묶음 (2026-11-12)
  //
  // 보고의 중복 표를 **현 상태로 다시 재서** 판정했다. 자카드(정답 보기 토큰)는
  // 13묶음 16쌍 전부 임계 아래였다(최고 0.308) — **지표는 하한이고 사람이 읽어
  // 판정한다.** 읽어 보니 **정답 문장에 같은 사실이 든 것이 7묶음**이고 나머지
  // 6묶음은 주제만 같았다.
  //
  // 관점을 바꾼 7묶음:
  //  1. CSPM 소급 — `t1-2-q11` 을 1.2.4 의 「Logs Insights 가 닿지 못하는 것」으로.
  //     ⚠️ Athena 축은 같은 Task 의 `q2` 가 이미 쓴다(형제 전수 확인).
  //  2. Logs Insights 동시 실행 한도 — 두 정답에서 함께 걷었다(보고 🟢 의
  //     「개수 암기 제거」와 같은 처방이다).
  //  5. 「한 객체는 같은 OCSF 이벤트 클래스」 — `t1-2-q7` 을 상한·전송 간격
  //     축으로. 형식 축은 `t3-1-q14` 가 소유한다.
  //  6. 「규칙과 수정을 YAML 로 묶는다」 — `t1-1-q15` 를 저장·배포 경로 축으로.
  //     묶음의 정체는 `t6-3-q5` 가 소유한다.
  //  7. 「네트워크 도달성은 EC2 전용 12시간」 — `t3-3-q15` 를 조사 결과의 의미와
  //     평가 구성 축으로. ⚠️ Network Access Analyzer 축은 같은 Task 의 `q13`·
  //     `q14` 가 이미 쓴다(형제 전수 확인이 두 번째로 값을 했다).
  //  8. 「멤버가 끄거나 수정할 수 없다」 — `t6-1-q1` 을 계정 경계·보안팀 중앙
  //     제공 축으로. 추적 상세는 `t1-2-q4` 가 소유한다.
  // 13. Tool 의 출력이 세 정답에 모두 있었다 — `q13`·`q14` 에서 걷고 `q15` 가
  //     소유한다.
  //
  // 중복이 아니라고 판정한 6묶음(정답 문장에 공통 사실이 없다):
  //  3. 알람 누락 데이터 — `t1-1-q13` 은 **AWS/DynamoDB 예외와 데이터 포인트
  //     규칙**, `t1-3-q14` 는 **일반 기본값과 선택 기준**이다(자카드 0.024).
  //  4. 평가 상태 — `t1-1-q6` 은 PARTIAL_DATA·EVALUATION_FAILURE,
  //     `t1-3-q15` 는 IN_WARM_UP 이다(0.000).
  //  9. 포렌식 순서 — **6단계 배치 3 이 이미 해소했다.** `t2-1-q15` 는 조직
  //     방침에 따른 승인·자동화 구분이고 순서는 해설에만 있다(0.125).
  // 10. Nitro 암호화 — `t5-1-q11` 은 **계층 축**(중간 홉), `t5-1-q12` 는
  //     **조건 축**(같은 리전)이다(0.000).
  // 11. SCP 와 관리 계정 — `t6-1-q2` 는 리소스를 어디 둘지, `t6-1-q10` 은
  //     위임된 관리자 등록 전제다(0.000).
  // 12. 두 「사전」 — `t6-1-q4` 는 Control Tower 사전 **제어**(후크 경로),
  //     `t6-3-q1` 은 Config 사전 **평가**(막지 않는다)다(0.067).
  //
  // ⚠️⚠️ **보고 목록 밖에서 하나를 더 찾았고 그것은 6단계 배치 1 이 만든
  // 중복이다.** 배치 1 이 `t2-2-q3` 를 「두 단계 복사의 **이유**」로 다시 쓰면서
  // 같은 Task 의 `q12` 정답과 근거 문장이 겹쳤다(자카드 0.222 — 보고가 든 13묶음
  // 어느 쌍보다 높다). **교체는 새 중복을 만들 수 있으므로 배치마다 전수로 다시
  // 센다.** 근거는 `q3` 가 소유하고 `q12` 는 무엇을 하는가만 묻게 좁혔다.
  group('6단계 배치 4 — 중복 묶음 해소 (보고 §4)', () {
    const ids = <String>[
      'scs-t1-1-q15', 'scs-t1-2-q7', 'scs-t1-2-q9', 'scs-t1-2-q11',
      'scs-t2-2-q5', 'scs-t2-2-q12', 'scs-t3-3-q15', 'scs-t6-1-q1',
      'scs-t6-3-q13', 'scs-t6-3-q14',
    ];

    /// 정답 보기 토큰의 자카드 — 보고 §0-3 이 쓴 지표와 같은 셈이다.
    double jaccard(String a, String b) {
      final re = RegExp(r'[0-9A-Za-z가-힣]+');
      final sa = re.allMatches(a).map((m) => m[0]!).toSet();
      final sb = re.allMatches(b).map((m) => m[0]!).toSet();
      if (sa.isEmpty || sb.isEmpty) return 0;
      return sa.intersection(sb).length / sa.union(sb).length;
    }

    test('대조군: 열 문항이 읽히고 전부 드래프트다', () {
      for (final id in ids) {
        final e = q(id);
        expect((e['options'] as List).length, 4, reason: id);
        expect(e['verified'], isFalse, reason: '$id 는 드래프트다 (flip 은 사람만)');
      }
    });

    test('정답 인덱스·skill·section·difficulty 가 전부 불변이다', () {
      const expected = <String, List<Object>>{
        'scs-t1-1-q15': [2, '1.1.5', 'automation', 'applied'],
        'scs-t1-2-q7': [1, '1.2.3', 'lake', 'applied'],
        'scs-t1-2-q9': [0, '1.2.4', 'analyze', 'applied'],
        'scs-t1-2-q11': [1, '1.2.4', 'analyze', 'applied'],
        'scs-t2-2-q5': [0, '2.2.2', 'search', 'applied'],
        'scs-t2-2-q12': [3, '2.2.4', 'contain', 'applied'],
        'scs-t3-3-q15': [2, '3.3.5', 'identify', 'applied'],
        'scs-t6-1-q1': [0, '6.1.1', 'organizations', 'applied'],
        'scs-t6-3-q13': [0, '6.3.3', 'well-architected', 'applied'],
        'scs-t6-3-q14': [1, '6.3.3', 'well-architected', 'applied'],
      };
      expect(expected.keys.toSet(), ids.toSet());
      for (final entry in expected.entries) {
        final e = q(entry.key);
        expect([e['correct'], e['skill'], e['section'], e['difficulty']],
            entry.value,
            reason: '${entry.key} 의 보존 필드가 바뀌었다');
      }
    });

    test('묶음 1: CSPM 소급은 t2-1-q5 가 소유하고 t1-2-q11 은 다른 것을 묻는다', () {
      final a = q('scs-t1-2-q11');
      expect(correctOf(a), contains('로그 그룹 생성 시각'));
      expect(allText(a), isNot(contains('소급 적용되지 않')));
      // 같은 Task 의 q2 가 쓰는 Athena 축과도 겹치지 않는다.
      expect(allText(a), isNot(contains('Athena')));
      final b = q('scs-t2-1-q5');
      expect(correctOf(b), contains('소급 적용되지 않'));
    });

    test('묶음 2: 동시 실행 한도가 두 정답에서 사라지고 기능 축만 남았다', () {
      final a = q('scs-t1-2-q9');
      final b = q('scs-t2-2-q5');
      for (final e in [a, b]) {
        expect(correctOf(e), isNot(contains('동시 실행 한도')),
            reason: '${e['id']}: 개수 암기는 보고 🟢 의 제거 대상이다');
        expect(correctOf(e), isNot(contains('100개')));
        expect(correctOf(e), isNot(contains('15개')));
      }
      expect(correctOf(a), contains('filterIndex'));
      expect(correctOf(b), contains('OpenSearch SQL'));
      expect(jaccard(correctOf(a), correctOf(b)), lessThan(0.15));
    });

    test('묶음 5: 이벤트 클래스는 t3-1-q14 가 소유하고 t1-2-q7 은 상한·간격을 묻는다',
        () {
      final a = q('scs-t1-2-q7');
      expect(correctOf(a), contains('50개'));
      // ⚠️ 비자명한 예외 — 256MB 를 넘으면 5분보다 자주 보낼 수 있다.
      expect(correctOf(a), contains('256MB'));
      expect(allText(a), isNot(contains('OCSF 이벤트 클래스')));
      final b = q('scs-t3-1-q14');
      expect(correctOf(b), contains('OCSF 이벤트 클래스'));
    });

    test('묶음 6: 묶음의 정체는 t6-3-q5 가 소유하고 t1-1-q15 는 배포 경로를 묻는다',
        () {
      final a = q('scs-t1-1-q15');
      expect(correctOf(a), contains('Systems Manager 문서'));
      expect(correctOf(a), contains('AWS CLI'));
      expect(correctOf(a), isNot(contains('개선 조치')));
      final b = q('scs-t6-3-q5');
      expect(correctOf(b), contains('수정 작업'));
    });

    test('묶음 7: EC2 전용 12시간은 t3-2-q5 가 소유하고 t3-3-q15 는 의미를 묻는다',
        () {
      final a = q('scs-t3-3-q15');
      expect(correctOf(a), contains('VPC 경계'));
      expect(correctOf(a), contains('네트워크 ACL'));
      expect(correctOf(a), isNot(contains('12시간')));
      expect(correctOf(a), isNot(contains('EC2 인스턴스 전용')));
      // ⚠️ NAA 축은 같은 Task 의 q13·q14 가 소유한다 — 정답에 끌어오지 않는다.
      expect(correctOf(a), isNot(contains('Network Access Analyzer')));
      final b = q('scs-t3-2-q5');
      expect(correctOf(b), contains('12시간'));
    });

    test('묶음 8: 「끄거나 수정할 수 없다」는 t1-2-q4 가 소유한다', () {
      final a = q('scs-t6-1-q1');
      expect(correctOf(a), contains('자연스러운 경계'));
      expect(correctOf(a), contains('읽기 전용'));
      expect(allText(a), isNot(contains('끄거나 수정할 수 없')));
      final b = q('scs-t1-2-q4');
      expect(correctOf(b), contains('로깅 중단'));
    });

    test('묶음 13: Tool 의 출력은 t6-3-q15 만 정답으로 가진다', () {
      for (final id in const ['scs-t6-3-q13', 'scs-t6-3-q14']) {
        expect(correctOf(q(id)), isNot(contains('개선 계획')), reason: id);
      }
      expect(correctOf(q('scs-t6-3-q15')), contains('개선 계획'));
      // q14 는 위험 분류를, q13 은 쓰는 때를 소유한다.
      expect(correctOf(q('scs-t6-3-q14')), contains('중간 위험 항목'));
      expect(correctOf(q('scs-t6-3-q13')), contains('마일스톤'));
    });

    test('⚠️ 보고 목록 밖: 두 단계 복사의 근거는 t2-2-q3 만 가진다', () {
      final a = q('scs-t2-2-q12');
      expect(correctOf(a), contains('포렌식 KMS 키'));
      expect(correctOf(a), isNot(contains('침해')));
      expect(correctOf(a), isNot(contains('삭제돼도')));
      final b = q('scs-t2-2-q3');
      expect(correctOf(b), contains('침해'));
      expect(jaccard(correctOf(a), correctOf(b)), lessThan(0.15));
    });

    test('⚠️ 보고 13묶음 전수: 정답 자카드가 0.15 아래다', () {
      const groups = <List<String>>[
        ['scs-t1-2-q11', 'scs-t2-1-q5'],
        ['scs-t1-2-q9', 'scs-t2-2-q5'],
        ['scs-t1-1-q13', 'scs-t1-3-q14'],
        ['scs-t1-1-q6', 'scs-t1-3-q15'],
        ['scs-t1-2-q7', 'scs-t3-1-q14'],
        ['scs-t1-1-q15', 'scs-t6-3-q5'],
        ['scs-t3-2-q5', 'scs-t3-3-q15'],
        ['scs-t1-2-q4', 'scs-t6-1-q1'],
        ['scs-t2-1-q15', 'scs-t2-2-q1'],
        ['scs-t5-1-q11', 'scs-t5-1-q12'],
        ['scs-t6-1-q2', 'scs-t6-1-q10'],
        ['scs-t6-1-q4', 'scs-t6-3-q1'],
        ['scs-t6-3-q13', 'scs-t6-3-q14', 'scs-t6-3-q15'],
      ];
      // 탐지기가 실제로 높은 값을 낸다는 대조군 — 없으면 0.15 단정이 공허하다.
      expect(jaccard('같은 문장입니다', '같은 문장입니다'), 1.0);
      var pairs = 0;
      for (final g in groups) {
        for (var i = 0; i < g.length; i++) {
          for (var j = i + 1; j < g.length; j++) {
            pairs++;
            expect(jaccard(correctOf(q(g[i])), correctOf(q(g[j]))),
                lessThan(0.15),
                reason: '${g[i]} ↔ ${g[j]} 의 정답이 다시 겹쳤다');
          }
        }
      }
      // 12묶음 × 1쌍 + 세 항 묶음 1개 × 3쌍 = 15쌍.
      expect(pairs, 15, reason: '보고 13묶음은 15쌍이다');
    });

    test('⚠️ SCS 전수: 같은 출처를 공유하는 쌍의 정답 자카드가 0.33 아래다', () {
      // ⚠️ 지표는 하한이다 — 이 단정이 초록이어도 의미 중복은 사람이 읽어야
      //    찾는다(보고가 든 13묶음은 전부 0.33 아래였다). 그래도 **글자까지 같은
      //    정답**이 다시 들어오는 것은 이 불변식이 막는다.
      final all = <String, String>{};
      for (final f in Directory(dir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))) {
        final taskId = f.uri.pathSegments.last.split('.').first;
        for (final e in bank(taskId).values) {
          all[e['id'] as String] = correctOf(e);
        }
      }
      expect(all.length, 240);
      final srcs = <String, Set<String>>{};
      for (final f in Directory(dir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))) {
        final taskId = f.uri.pathSegments.last.split('.').first;
        for (final e in bank(taskId).values) {
          srcs[e['id'] as String] = (e['sources'] as List)
              .map((s) => s['url'] as String)
              .toSet();
        }
      }
      final keys = all.keys.toList();
      var shared = 0;
      for (var i = 0; i < keys.length; i++) {
        for (var j = i + 1; j < keys.length; j++) {
          if (srcs[keys[i]]!.intersection(srcs[keys[j]]!).isEmpty) continue;
          shared++;
          expect(jaccard(all[keys[i]]!, all[keys[j]]!), lessThan(0.33),
              reason: '${keys[i]} ↔ ${keys[j]} 의 정답이 너무 비슷하다');
        }
      }
      expect(shared, greaterThanOrEqualTo(200),
          reason: '출처 공유 쌍이 거의 없다 — 이 단정이 공허해진다');
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // 🏁 6단계 배치 5-A — 길이 단서 잔여 33문항 + 겹치는 🟢 항목 (2026-11-12)
  //
  // 보고 🟢 의 **「개수 암기 제거」와 「무관한 세부 삭제」가 정답 보기를 길게 만들던
  // 바로 그 텍스트**라, 길이 교정과 같은 편집으로 닫혔다. 이로써 **전수 길이 단서
  // cue 가 227 → 0** 이다.
  //
  // ⚠️ 보고 🟢 의 **「해설에 남은 저작 메모 삭제」는 §4 2단계가 이미 전부
  // 닫았다**(일곱 계열 문항 전수 0건). 반영 전에 레포 실상태를 세는 규율이 없었다면
  // 같은 자리를 두 번 손댔다.
  //
  // ⚠️⚠️ **한국어 길이는 눈으로 추정하면 체계적으로 짧다.** 초안 34문항 중 **23건**
  // 이 1.3배를 넘었고, `정답 ÷ 1.3` 을 계산해 최장 오답을 그 길이까지 올려 닫았다.
  group('🏁 6단계 배치 5-A — 길이 단서 전수 종료 (보고 §4 P-2 · 🟢)', () {
    test('대조군: 서른넷이 읽히고 전부 드래프트다', () {
      for (final id in const [
        'scs-t1-1-q1', 'scs-t1-1-q13', 'scs-t1-3-q13', 'scs-t1-3-q14',
        'scs-t2-1-q13', 'scs-t2-2-q7', 'scs-t2-2-q10',
        'scs-t3-1-q2', 'scs-t3-1-q13', 'scs-t3-1-q14', 'scs-t3-2-q14',
        'scs-t3-3-q8',
        'scs-t4-1-q2', 'scs-t4-1-q5', 'scs-t4-1-q7', 'scs-t4-2-q2',
        'scs-t4-2-q8', 'scs-t4-2-q13', 'scs-t4-2-q15',
        'scs-t5-1-q2', 'scs-t5-1-q6', 'scs-t5-1-q10', 'scs-t5-2-q2',
        'scs-t5-2-q4', 'scs-t5-3-q3', 'scs-t5-3-q15',
        'scs-t6-1-q5', 'scs-t6-1-q6', 'scs-t6-1-q7', 'scs-t6-1-q13',
        'scs-t6-1-q15', 'scs-t6-2-q6', 'scs-t6-2-q13', 'scs-t6-3-q8',
      ]) {
        final e = q(id);
        expect((e['options'] as List).length, 4, reason: id);
        expect(e['verified'], isFalse, reason: '$id 는 드래프트다 (flip 은 사람만)');
      }
    });

    test('정답 인덱스·skill·section 이 전부 불변이다', () {
      // ⚠️ `difficulty` 는 뺀다 — `t1-3-q13` 만 보고 🟢 의 「자체 프레임 의존 문항은
      //    foundational 전용」에 따라 바뀐다(아래 별 테스트가 고정한다).
      const expected = <String, List<Object>>{
        'scs-t1-1-q1': [0, '1.1.1', 'requirements'],
        'scs-t1-1-q13': [0, '1.1.4', 'detection'],
        'scs-t1-3-q13': [2, '1.3.2', 'fix'],
        'scs-t1-3-q14': [0, '1.3.2', 'fix'],
        'scs-t2-1-q13': [0, '2.1.4', 'automate'],
        'scs-t2-2-q7': [2, '2.2.3', 'scope'],
        'scs-t2-2-q10': [1, '2.2.4', 'contain'],
        'scs-t3-1-q2': [1, '3.1.1', 'strategy'],
        'scs-t3-1-q13': [0, '3.1.4', 'third-party'],
        'scs-t3-1-q14': [1, '3.1.4', 'third-party'],
        'scs-t3-2-q14': [1, '3.2.7', 'genai'],
        'scs-t3-3-q8': [3, '3.3.3', 'verified-access'],
        'scs-t4-1-q2': [1, '4.1.1', 'identity'],
        'scs-t4-1-q5': [0, '4.1.1', 'identity'],
        'scs-t4-1-q7': [2, '4.1.2', 'temp'],
        'scs-t4-2-q2': [1, '4.2.1', 'controls'],
        'scs-t4-2-q8': [3, '4.2.3', 'least-privilege'],
        'scs-t4-2-q13': [0, '4.2.5', 'unintended'],
        'scs-t4-2-q15': [2, '4.2.5', 'unintended'],
        'scs-t5-1-q2': [1, '5.1.1', 'enforce-tls'],
        'scs-t5-1-q6': [1, '5.1.2', 'private-access'],
        'scs-t5-1-q10': [2, '5.1.2', 'private-access'],
        'scs-t5-2-q2': [1, '5.2.1', 'encrypt-at-rest'],
        'scs-t5-2-q4': [3, '5.2.2', 'integrity'],
        'scs-t5-3-q3': [2, '5.3.1', 'secrets'],
        'scs-t5-3-q15': [2, '5.3.5', 'multi-region'],
        'scs-t6-1-q5': [3, '6.1.2', 'control-tower'],
        'scs-t6-1-q6': [1, '6.1.2', 'control-tower'],
        'scs-t6-1-q7': [0, '6.1.3', 'org-policies'],
        'scs-t6-1-q13': [2, '6.1.5', 'root-credentials'],
        'scs-t6-1-q15': [3, '6.1.5', 'root-credentials'],
        'scs-t6-2-q6': [1, '6.2.2', 'tags'],
        'scs-t6-2-q13': [0, '6.2.4', 'sharing'],
        'scs-t6-3-q8': [3, '6.3.1', 'config-rules'],
      };
      for (final entry in expected.entries) {
        final e = q(entry.key);
        expect([e['correct'], e['skill'], e['section']], entry.value,
            reason: '${entry.key} 의 보존 필드가 바뀌었다');
      }
    });

    test('🟢 자체 프레임 의존 문항 셋은 foundational 이다', () {
      // 보고: 「요구 사항을 정하는 순서」·「세 질문」·「네 층」은 학습문서의 틀을
      // 알아야 풀린다. 학습용으로는 좋지만 모의고사 풀에서는 foundational 로 둔다.
      for (final id in const [
        'scs-t1-1-q1', 'scs-t1-2-q1', 'scs-t1-3-q13',
      ]) {
        expect(q(id)['difficulty'], 'foundational', reason: id);
      }
    });

    test('🟢 명칭: 「신 Security Hub」가 문항 전수에서 0건이다', () {
      // 보고: 「신 Security Hub」 대신 **AWS Security Hub** 로 쓰고 Security Hub
      // CSPM 과 구분한다는 주석을 한 번 둔다. 시험 가이드 표기는 여전히
      // 「Security Hub」다.
      var total = 0;
      for (final f in Directory(dir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))) {
        final taskId = f.uri.pathSegments.last.split('.').first;
        for (final e in bank(taskId).values) {
          total++;
          expect(allText(e).contains('신 Security Hub'), isFalse,
              reason: '${e['id']}: 「AWS Security Hub」로 쓴다');
          expect(allText(e).contains('신 AWS Security Hub'), isFalse,
              reason: '${e['id']}: 「AWS Security Hub」로 쓴다');
        }
      }
      expect(total, 240);
      // 구분 주석은 그 자리에 남아 있다.
      expect(q('scs-t3-1-q13')['explanation'],
          contains('Security Hub CSPM'));
      expect(correctOf(q('scs-t3-1-q13')), contains('AWS Security Hub'));
    });

    test('🟢 명칭: t4-1-q2 가 계정 액세스 관리자를 영문과 병기한다', () {
      // ⚠️ 영문 병기는 **해설**에 둔다 — 정답 보기에 넣으면 그 보기가 최장이 되어
      //    길이 단서를 다시 만든다(같은 문항이 P-2 대상이었다).
      final e = q('scs-t4-1-q2');
      expect(e['explanation'], contains('계정 액세스 관리자(account access manager)'));
      expect(correctOf(e), contains('계정 액세스 관리자'));
      expect(correctOf(e), isNot(contains('account access manager')));
    });

    test('🟢 개수 암기: 자주 바뀌는 값을 세지 않고 열거한다', () {
      // 보고: t4-2-q13 「기능 6종」, t4-2-q15 「리소스 유형 15종」, t6-3-q8 「전제
      // 다섯」, t6-1-q7 첨부 한도 숫자 나열, t5-1-q2 백엔드 정책 이름 여섯 나열.
      for (final pair in const [
        ['scs-t4-2-q13', '6종'],
        ['scs-t4-2-q15', '15종'],
        ['scs-t6-3-q8', '전제는 다섯'],
        ['scs-t6-1-q7', '10,240'],
        ['scs-t5-1-q2', 'RFC9151-INTEROP4-FIPS-2023-07'],
      ]) {
        expect(allText(q(pair[0])).contains(pair[1]), isFalse,
            reason: '${pair[0]}: 「${pair[1]}」을 세지 않고 열거한다');
      }
      // 대조군 — 열거 자체는 남아 있어야 한다(세는 것만 걷었다).
      expect(correctOf(q('scs-t4-2-q13')), contains('미사용 액세스 분석기'));
      expect(correctOf(q('scs-t6-3-q8')), contains('IAM 역할'));
      // t5-1-q2 는 시험에서 걸리는 매핑 하나만 남긴다.
      expect(q('scs-t5-1-q2')['explanation'],
          contains('ELBSecurityPolicy-2016-08'));
    });

    test('🟢 무관한 세부: 묻는 축이 아닌 세부를 걷었다', () {
      // 보고: t6-1-q13 `MinimumSessionTokenSize`, t5-2-q4 Cohasset 평가,
      // t5-3-q15 ML-DSA 문단.
      for (final pair in const [
        ['scs-t6-1-q13', 'MinimumSessionTokenSize'],
        ['scs-t5-2-q4', 'Cohasset'],
        ['scs-t5-3-q15', 'ML-DSA'],
        ['scs-t5-3-q15', 'ML_DSA_44'],
      ]) {
        expect(allText(q(pair[0])).contains(pair[1]), isFalse,
            reason: '${pair[0]}: 「${pair[1]}」은 이 문항이 묻는 축이 아니다');
      }
      // 대조군 — 묻는 축은 그대로다.
      expect(allText(q('scs-t6-1-q13')), contains('TaskPolicyArn'));
      expect(allText(q('scs-t5-2-q4')), contains('준수 모드'));
      expect(allText(q('scs-t5-3-q15')), contains('리전 리소스'));
    });

    test('🟢 보강: t5-2-q2 가 기본값을 SSE-S3 기준으로 적는다', () {
      // 보고: 「기본 암호화로 설정할 수 있는 것은 SSE-KMS·DSSE-KMS뿐」은 기본값이
      // SSE-S3 라는 사실을 가린다 → 「SSE-S3 외에 바꿀 수 있는 기본값은」으로.
      final e = q('scs-t5-2-q2');
      expect(e['explanation'], contains('기본 암호화는 SSE-S3'));
      expect(e['explanation'], contains('SSE-KMS와 DSSE-KMS'));
      expect(e['explanation'], isNot(contains('설정할 수 있는 것은 SSE-KMS와 DSSE-KMS뿐')));
    });

    test('🏁 전수: 길이 단서가 0건이고 이 배치의 손댄 문항이 모두 그 안이다', () {
      var over = <String>[];
      var total = 0;
      for (final f in Directory(dir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))) {
        final taskId = f.uri.pathSegments.last.split('.').first;
        for (final e in bank(taskId).values) {
          total++;
          final c = correctOf(e);
          final others = <String>[];
          final opts = (e['options'] as List).cast<String>();
          for (var i = 0; i < opts.length; i++) {
            if (i != e['correct']) others.add(opts[i]);
          }
          final mx = others.map((o) => o.length).reduce((a, b) => a > b ? a : b);
          if (c.length / mx > 1.3) over.add(e['id'] as String);
        }
      }
      expect(total, 240);
      expect(over, isEmpty,
          reason: '정답 ÷ 최장 오답이 1.3배를 넘는 문항이 다시 생겼다');
    });
  });
}
