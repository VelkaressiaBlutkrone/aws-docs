import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// SCS-C03 공식 시험 가이드 동기화 가드 (P-03).
///
/// 레포 `exam_guides/SCS-C03.json`은 2026-06-11 수집분인데, 2026-11-06 조사와
/// **2026-11-08 재측정**에서 공식 한국어 가이드(v1.0 · 2026-03-26)와 **기술
/// 본문 2건**이 다른 것이 확인됐다. 나머지 **68건은 바이트 일치**다.
///
/// 근거: `docs/content-research/SCS-C03/97-repo-json-diff.md` §2·§3.
///
/// ## ⭐ 이 JSON은 AIF와 정반대로 「신뢰할 수 있는」 쪽이다
///
/// AIF-C01.json은 목표 69건 중 19건이 틀렸고 범위 밖 서비스·기계번역 음차가
/// 섞인 하이브리드였다. SCS-C03.json은 **사실상 공식 그대로**이고 차이는 번역을
/// 손본 한 자리와 마침표 하나뿐이다. **원인은 개정 이력이다** — AIF는 v1.1
/// 개정이 있어 수집분이 섞였고 SCS는 v1.0뿐이다. 그래서 「레포 JSON을 믿지
/// 말라」는 **자격증마다 다르고**, 판정은 **① 개정 이력 ② 바이트 대조** 둘로만
/// 한다(97 §1).
///
/// ⚠️ **그래도 개정 표가 한 줄이어도 번역은 바뀐다** — `기술 1.2.1`이 그
/// 증거다(공식 개정 표에는 이 변경이 없다). **개정 표만 보고 대조를 생략하면
/// 안 된다.** 2026-11-08 재측정에서도 차이는 정확히 그 2건이었고 세 번째는
/// 생기지 않았다(대조군 68건 일치).
///
/// ## ⚠️⚠️ `기술 6.2.4`는 금지 가드를 쓸 수 없다 — 옛 문구가 새 문구의 부분 문자열이다
///
/// 공식은 끝에 **마침표가 있고** 레포 수집분에는 없다. 즉 옛 문구가 새 문구의
/// **접두사**라서, 다른 배치들이 쓰던 「옛 문구 `contains` 0건」 가드를 그대로
/// 쓰면 **교체한 공식 문구가 스스로 가드에 걸린다.** AIF의 `Amazon Q` ⊂
/// `Amazon Quick` 함정과 같은 형태다. 그래서 이 건은 **정확한 일치(`equals`)**
/// 로 고정하고, 부분 문자열 관계 자체를 대조군으로 먼저 단정한다.
///
/// ## ⚠️ 공식 쪽 오기는 그대로 넣는다
///
/// 공식 `기술 6.2.4`의 `(AWSRAM)`은 **공백이 빠진 오기**다(같은 가이드의 범위 내
/// 서비스 목록은 `AWS Resource Access Manager(AWS RAM)`으로 바르게 적는다).
/// JSON은 **가이드 전사**이므로 공식 그대로 넣고, 학습문서·문항에서 서비스를
/// 부를 때만 `AWS RAM`을 쓴다(저작 결정 **D-05**). 층이 다르다.
void main() {
  final raw = File('assets/exam_guides/SCS-C03.json').readAsStringSync();
  final guide = json.decode(raw) as Map<String, dynamic>;
  final domains = (guide['domains'] as List).cast<Map<String, dynamic>>();

  /// 공식 가이드의 `기술 X.Y.Z` 번호 → 본문. SCS는 계층이 하나(Task → 「관련
  /// 기술」)이고 그 기술이 JSON의 `skills` 배열이다. 번호는 **Task 번호 +
  /// 배열 순번**으로 유도된다(AIF처럼 추정할 필요가 없다 — 공식 본문이
  /// `기술 2.1.1` 형태로 직접 적는다).
  Map<String, String> skillsByNumber() {
    final out = <String, String>{};
    for (final d in domains) {
      for (final t in (d['tasks'] as List).cast<Map<String, dynamic>>()) {
        final skills = (t['skills'] as List).cast<String>();
        for (var i = 0; i < skills.length; i++) {
          out['${t['no']}.${i + 1}'] = skills[i];
        }
      }
    }
    return out;
  }

  Map<String, String> titlesByNumber() {
    final out = <String, String>{};
    for (final d in domains) {
      for (final t in (d['tasks'] as List).cast<Map<String, dynamic>>()) {
        out[t['no'] as String] = t['title'] as String;
      }
    }
    return out;
  }

  // ── 공식 전문 (2026-11-08 재측정 — `…/security-specialty-03-domain{1,6}.md`) ──
  const official121 = '요구 사항에 따라 로그 수집과 스토리지를 확보할 소스 파악';
  const repoOld121 = '요구 사항에 따라 로그 수집과 스토리지를 보장할 소스 파악';
  const official624 =
      'AWS 계정 간에 리소스를 안전하게 공유(예: AWS Service Catalog, AWS Resource Access Manager(AWSRAM)).';
  const repoOld624 =
      'AWS 계정 간에 리소스를 안전하게 공유(예: AWS Service Catalog, AWS Resource Access Manager(AWSRAM))';

  group('대조군: 가드의 입력이 실제로 만들어지는가', () {
    test('JSON이 읽히고 code·slug·sourceUrl이 공식 가이드를 가리킨다', () {
      // ⚠️⚠️ **길이 임계는 줄끝에 독립이어야 한다.** `readAsStringSync()` 는
      // `\r` 를 **포함한** 문자열을 준다. 이 레포는 **blob 이 LF · 작업트리가
      // CRLF** 라(97 의 2026-11-08 정정 절) 같은 파일의 `String.length` 가
      // **줄 수만큼 달라진다** — 실측 **CRLF 10,189자 ↔ LF 9,951자**.
      //
      // 이 가드는 처음 `greaterThan(10000)` 으로 썼고, 그 값이 **두 변종
      // 사이에 놓여** Windows 로컬에서는 통과하고 **CI(Linux 체크아웃 = LF)
      // 에서만 실패**했다. 임계를 눈대중으로 잡은 것이 원인이다.
      // → **CR 을 걷어낸 길이로 센다.** 그러면 두 환경에서 같은 값이 나온다.
      //
      // ⚠️ `String.length` 는 **문자 수**이고 바이트 수가 아니다(한국어는
      // UTF-8 에서 글자당 3바이트). 바이트로 임계를 잡으면 또 어긋난다.
      final rawLf = raw.replaceAll('\r', '');
      expect(rawLf.length, greaterThan(9000),
          reason: '파일이 비었거나 경로가 틀렸다 (줄끝 독립 길이)');
      // 줄끝 변종 사이의 차이가 「줄 수」라는 것 자체를 고정한다 — 누가 다시
      // `raw.length` 로 바꾸면 이 단정이 왜 안 되는지 알려 준다.
      expect(raw.length - rawLf.length, anyOf(0, raw.split('\n').length - 1),
          reason: 'CR 수가 줄 수와 다르다 — 줄끝이 균일하지 않다');
      expect(guide['code'], 'SCS-C03');
      expect(guide['slug'], 'security-specialty-03');
      expect(guide['sourceUrl'],
          'https://docs.aws.amazon.com/ko_kr/aws-certification/latest/security-specialty-03/security-specialty-03.html',
          reason: '한국어 가이드 루트. 2026-11-08 실측 200 r=0');
    });

    test('기술 70개가 Task별 실측 분해로 유도된다', () {
      final skills = skillsByNumber();
      expect(skills.length, 70,
          reason: '기술 유도가 깨졌다 — JSON 구조가 바뀌었는지 본다');

      // ⚠️ 2026-11-08 공식 실측값이다. 조사 노트(99-gaps G-05 · 98 D-01)가
      // `1.3`·`4.1`·`4.2`를 「각 4개」로 적었는데 **공식은 2·3·5**다.
      // 가장 많은 것은 `3.2`(7개)이고 **가장 적은 것은 `1.3`(2개)**이다.
      const perTask = <String, int>{
        '1.1': 5, '1.2': 6, '1.3': 2,
        '2.1': 4, '2.2': 5,
        '3.1': 4, '3.2': 7, '3.3': 5,
        '4.1': 3, '4.2': 5,
        '5.1': 3, '5.2': 4, '5.3': 5,
        '6.1': 5, '6.2': 4, '6.3': 3,
      };
      expect(perTask.length, 16, reason: '공식 Task는 16개다');
      expect(perTask.values.reduce((a, b) => a + b), 70);
      perTask.forEach((task, count) {
        // 번호가 1부터 빈틈 없이 이어지는지 — 한 항목이 밀리면 뒤가 전부
        // 거짓 불일치로 보인다.
        for (var i = 1; i <= count; i++) {
          expect(skills, contains('$task.$i'), reason: '$task.$i이 없다 — 기술이 밀렸다');
        }
        expect(skills.keys.where((k) => k.startsWith('$task.')).length, count,
            reason: '$task: 기술 수가 $count이 아니다');
      });
    });

    test('옛 6.2.4 문구는 공식 문구의 부분 문자열이다 — 그래서 금지 가드를 쓸 수 없다', () {
      // 이 단정이 아래 「equals로 고정한다」는 설계의 근거다. 누가 이 건을
      // 다른 배치들처럼 「옛 문구 contains 0건」으로 바꾸면 **교체한 공식
      // 문구가 스스로 걸려** 영원히 레드가 된다.
      expect(official624.contains(repoOld624), isTrue,
          reason: '마침표만 추가된 관계가 깨졌다 — 공식 문구를 다시 확인한다');
      expect(official624.length, repoOld624.length + 1);
      // 반대로 1.2.1은 낱말이 달라 부분 문자열 관계가 아니다 → 금지 가드가 통한다.
      expect(official121.contains(repoOld121), isFalse);
      expect(repoOld121.contains(official121), isFalse);
    });
  });

  group('개정에서 바뀌지 않는 구조 (손대지 않는다 — 97 §3)', () {
    test('도메인 6개·비중 16·14·18·20·18·14(합 100)', () {
      expect(domains.length, 6, reason: 'SCS는 도메인이 6개다');
      final weights = domains.map((d) => d['weightPct'] as int).toList();
      expect(weights, <int>[16, 14, 18, 20, 18, 14]);
      expect(weights.reduce((a, b) => a + b), 100);
      // ⚠️ 비중이 가장 높은 도메인 4는 Task가 2개뿐이다(D-01이 받아들인 비용).
      expect((domains[3]['tasks'] as List).length, 2,
          reason: 'D4는 비중 20%인데 Task 2개 — 저작 분량을 비중으로 맞춘다');
    });

    test('도메인 이름 6개가 공식 도메인 페이지 표기다', () {
      final names = domains.map((d) => d['name'] as String).toList();
      expect(names, <String>[
        '탐지',
        '인시던트 대응',
        '인프라 보안',
        'ID 및 액세스 관리',
        '데이터 보호',
        '보안 기반 및 거버넌스',
      ]);
    });

    test('Task 제목 16개가 공식 도메인 페이지 표기다 (부록 B가 아니다)', () {
      // ⚠️ 부록 B의 재분류 절은 「경보 기능」·「로깅」으로 적지만 정본은
      // **도메인 페이지**의 「경보 솔루션」·「로깅 솔루션」이다(저작 결정 D-02).
      expect(titlesByNumber(), <String, String>{
        '1.1': 'AWS 계정 또는 조직용 모니터링 및 경보 솔루션 설계 및 구현',
        '1.2': '로깅 솔루션 설계 및 구현',
        '1.3': '보안 모니터링, 로깅 및 경보 솔루션 문제 해결',
        '2.1': '인시던트 대응 계획 설계 및 테스트',
        '2.2': '보안 이벤트에 대응',
        '3.1': '네트워크 엣지 서비스의 보안 제어 설계, 구현 및 문제 해결',
        '3.2': '컴퓨팅 워크로드에 대한 보안 제어 설계, 구현 및 문제 해결',
        '3.3': '네트워크 보안 제어 설계 및 문제 해결',
        '4.1': '인증 전략 설계, 구현 및 문제 해결',
        '4.2': '권한 부여 전략 설계, 구현 및 문제 해결',
        '5.1': '전송 중인 데이터에 대한 제어 설계 및 구현',
        '5.2': '저장 데이터에 대한 제어 설계 및 구현',
        '5.3': '기밀 데이터, ID, 보안 암호, 암호화 키 자료를 보호하기 위한 제어 기능 설계 및 구현',
        '6.1': 'AWS 계정을 중앙에서 배포하고 관리하기 위한 전략 개발',
        '6.2': '클라우드 리소스를 안전하고 일관성 있게 배포할 수 있는 전략 구현',
        '6.3': 'AWS 리소스의 규정 준수 평가',
      });
    });

    test('overview 5필드와 knowledge 빈 배열 관례', () {
      final overview = guide['overview'] as Map<String, dynamic>;
      expect(overview['level'], 'Specialty');
      expect(overview['passingScore'], 750);
      expect(overview['scoredQuestions'], 50);
      expect(overview['unscoredQuestions'], 15);
      // ⚠️ 170분은 **가이드 본문에 없고 인증 페이지가 근거**다(저작 결정 D-07).
      expect(overview['durationMinutes'], 170);
      expect(
          (overview['scoredQuestions'] as int) +
              (overview['unscoredQuestions'] as int),
          65);

      // SCS는 계층이 하나라 `skills`만 쓴다 — `knowledge`는 빈 배열이 관례다
      // (SOA는 반대로 `knowledge`를 채우고 `skills`를 비운다).
      for (final d in domains) {
        for (final t in (d['tasks'] as List).cast<Map<String, dynamic>>()) {
          expect((t['knowledge'] as List), isEmpty,
              reason: 'Task ${t['no']}: SCS는 knowledge를 비워 둔다');
          expect((t['skills'] as List), isNotEmpty,
              reason: 'Task ${t['no']}: skills가 비었다');
        }
      }
    });
  });

  group('공식과 어긋났던 기술 본문 2건이 공식 전문이다', () {
    test('기술 1.2.1 — 「확보할」(공식) 이고 「보장할」(수집분) 이 아니다', () {
      expect(skillsByNumber()['1.2.1'], official121);
    });

    test('기술 1.2.1 옛 문구가 파일 전체에서 0건이다', () {
      // 이 건은 낱말이 달라 부분 문자열 함정이 없다(위 대조군이 단정한다).
      expect(raw.contains(repoOld121), isFalse,
          reason: '「보장할 소스 파악」이 남아 있다 — 영문 `secure`의 공식 번역은 「확보할」이다');
    });

    test('기술 6.2.4 — 공식은 마침표로 끝난다', () {
      expect(skillsByNumber()['6.2.4'], official624);
    });

    test('어떤 기술도 마침표 없는 `(AWSRAM))` 로 끝나지 않는다', () {
      // 금지 가드를 쓸 수 없는 자리의 대체 단정(위 대조군 참조).
      final offenders = skillsByNumber().entries
          .where((e) => e.value.endsWith('(AWSRAM))'))
          .map((e) => e.key)
          .toList();
      expect(offenders, isEmpty,
          reason: '공식 문구는 마침표로 끝난다 — 수집분이 되살아났다: $offenders');
    });
  });

  group('섞여 들어오면 안 되는 것 (AIF에서 실제로 섞였던 종류)', () {
    test('기계번역 음차·오표기가 0건이다', () {
      // AIF-C01.json에는 `아마존 베드락`·`아마존 퀵` 같은 음차가 있었다.
      // SCS 수집분은 처음부터 0건이고(97 §1) 그 상태를 고정한다.
      for (final bad in <String>['아마존', '베드락', 'BedRock', '기초 모델', '환각']) {
        expect(raw.contains(bad), isFalse, reason: '기계번역 잔재 「$bad」가 들어왔다');
      }
    });

    test('공식 「범위 외」 서비스 2종이 0건이다', () {
      // SCS의 범위 외 목록은 단 둘이다(00-overview §7).
      for (final bad in <String>['MWAA', 'Payment Cryptography']) {
        expect(raw.contains(bad), isFalse, reason: '범위 외 서비스 「$bad」가 들어왔다');
      }
    });
  });
}
