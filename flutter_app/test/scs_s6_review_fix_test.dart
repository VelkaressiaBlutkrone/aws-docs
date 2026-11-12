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
      for (final taskId in const ['scs-t2-2', 'scs-t3-2', 'scs-t3-3']) {
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
}
