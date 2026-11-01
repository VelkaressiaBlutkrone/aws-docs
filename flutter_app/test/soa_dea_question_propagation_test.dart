import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 학습문서(md)에서 정정된 구식 서술이 **파생 문항(`*.questions.json`)에도 남아 있지
/// 않은지** 검사하는 전파 가드 — SOA-C03 · DEA-C01 판 (2026-10-29).
///
/// ## 왜 필요한가
///
/// `saa_question_propagation_test.dart`와 같은 구멍을 막는다. 2026-10-19에 SAA
/// 학습문서의 사실을 공식 문서로 재확인해 정정하면서 md 전용 가드를 붙였는데,
/// **문항은 md에서 파생되는데도 같은 정정이 전파되지 않았다**(실측 7건, 그중 하나는
/// 이미 flip돼 **라이브 노출 중**이었다). md 가드는 md만 읽기 때문에 아무것도 잡지
/// 못했다. SOA·DEA에는 그 가드의 판이 없어 같은 사고가 같은 구조로 재현될 수 있었다.
///
/// **첫 실행에서 실제 결함을 찾았다**: 구식 명칭 「적합성 팩」이 `soa-t4-2.md`에서는
/// 공식 v1.1 KO 명칭 「규정 준수 팩」으로 13개소 정정돼 있는데, 파생 문항
/// `soa-t4-2.questions.json`에는 7개소 · `soa-t5-4.questions.json`에 1개소가 그대로
/// 남아 있었다(그 파일의 「규정 준수 팩」은 0개소였다). 같은 PR에서 정정했다.
///
/// ## 운영 — md를 정정할 때마다 할 일
///
/// md 가드에 `expect(md.contains('<구식 문장>'), isFalse)` 를 새로 추가했다면,
/// **그 문장을 아래 `_factRules`(또는 명칭이면 `_nameRules`)에 한 줄 추가**하고 어느
/// 가드에서 왔는지를 `origin` 에, 공식 사실을 `why` 에 적는다. 목록은 테스트 소스를
/// 파싱해 만들지 않는다 — 파싱은 가드 파일의 사소한 서식 변화에 깨지므로, 사람이 고른
/// 명시적 상수 목록으로 둔다.
///
/// ## 검사 범위가 둘이다
///
/// - **`_factRules`** — `stem` · `skill` · `options[correct]` · `explanation` ·
///   `wrongExplanations` 만 본다. **오답 보기(`options[i != correct]`)는 일부러 틀린
///   서술**이므로 금지 문장이 거기 있는 것은 결함이 아니다. 반면
///   `wrongExplanations` 는 "왜 그 보기가 틀렸는지"를 설명하는 **사실 서술**이므로
///   검사한다.
/// - **`_nameRules`** — 구식·오표기 **제품 명칭**은 문항 **전체**(오답 보기와
///   `sources[].title` 까지)를 본다. 오답 보기도 서비스 이름은 바르게 불러야 하고,
///   실제로 「적합성 팩」 8개소 중 1개소가 오답 보기, 1개소가 출처 제목이었다
///   (사실 영역만 보면 둘을 놓친다).
///
/// `wrongExplanations` 가 틀린 주장을 **인용해 반박**하다 금지 문장과 겹쳐 터지는 날이
/// 오면, 그 항목을 지우지 말고 **반박문이 쓰지 않는 더 좁은 문구로 바꿔라.**
///
/// ## 목록에 넣지 않은 것 (의도적)
///
/// - **md 표·코드블록 형식 문자열.** `| 항목 | Redis (ElastiCache for Redis/Valkey) |
///   Memcached |` · `| **스케줄 규칙** | **cron/rate 식**에 따라 주기적으로 |` 처럼
///   마크다운 구조에만 존재하는 문자열은 문항 JSON에 나타날 수 없다.
/// - **마크다운 표기가 든 문장.** `공인 TLS 인증서는 **무료**` 는 `**` 때문에 문항에
///   그대로 나타나지 않는다(해설은 평문 렌더다). 같은 사실은 `ACM 공인 인증서 무료`
///   항목이 덮는다.
/// - **시험 가이드 JSON 동기화 단정.** `soa_guide_v11_test` 의 `AWS 사용자 알림`·
///   `오토 스케일링` 은 `assets/exam_guides/SOA-C03.json` 본문을 보는 단정이고
///   학습문서 사실이 아니다. 그리고 `오토 스케일링` 은 일반 어휘다.
/// - **구조 단정.** `</content>` · `"verified": true` 는 목적이 다르다.
void main() {
  final files = [
    for (final cert in ['soa', 'dea'])
      ...Directory('assets/content/$cert')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json')),
  ]..sort((a, b) => a.path.compareTo(b.path));

  // 사실 영역(오답 보기 제외)과 문항 전체를 따로 모아 둔다.
  final scanned = <({String file, String id, String text, String all})>[];
  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    final questions =
        (data['questions'] as List?)?.whereType<Map<String, dynamic>>() ??
            const <Map<String, dynamic>>[];
    for (final q in questions) {
      final options =
          (q['options'] as List?)?.whereType<String>().toList() ??
              const <String>[];
      final correct = q['correct'];
      final wrong = q['wrongExplanations'];
      final factParts = <String>[
        q['stem'] as String? ?? '',
        q['skill'] as String? ?? '',
        q['explanation'] as String? ?? '',
        if (correct is int && correct >= 0 && correct < options.length)
          options[correct],
        if (wrong is Map) ...wrong.values.whereType<String>(),
      ];
      scanned.add((
        file: name,
        id: q['id'] as String? ?? '(id 없음)',
        text: factParts.join('\n'),
        all: json.encode(q),
      ));
    }
  }

  test('대조군: SOA·DEA 문항 파일과 문항이 읽혔다', () {
    // 0건 통과가 "파일을 못 읽어서"일 수 있다 — 먼저 센다.
    expect(files.length, 37, reason: 'SOA 20 + DEA 17 Task. 바뀌었다면 검사 범위를 다시 보라');
    expect(scanned.length, greaterThanOrEqualTo(37 * 15));
  });

  group('md 가드가 금지한 사실 서술이 문항에 전파되지 않았다', () {
    for (final rule in _factRules) {
      final label =
          rule.text.length <= 28 ? rule.text : '${rule.text.substring(0, 28)}…';
      test('${rule.origin} "$label"', () {
        final hits = scanned
            .where((s) => s.text.contains(rule.text))
            .map((s) => '${s.file} ${s.id}')
            .toList();
        expect(hits, isEmpty,
            reason: '${rule.origin}이 md에서 금지한 서술이 문항에 남아 있다.\n'
                '공식 사실: ${rule.why}\n'
                '해당 문항: $hits');
      });
    }
  });

  group('구식·오표기 명칭이 문항 어디에도 없다 (오답 보기·출처 제목 포함)', () {
    for (final rule in _nameRules) {
      test('${rule.origin} "${rule.text}"', () {
        final hits = scanned
            .where((s) => s.all.contains(rule.text))
            .map((s) => '${s.file} ${s.id}')
            .toList();
        expect(hits, isEmpty,
            reason: '${rule.origin}이 md에서 금지한 구식 명칭이 문항에 남아 있다.\n'
                '정본: ${rule.why}\n'
                '⚠️ 오답 보기도 서비스 이름은 바르게 불러야 한다.\n'
                '해당 문항: $hits');
      });
    }
  });

  test('DEA에 md 사실 가드가 생기면 이 파일의 규칙을 채운다', () {
    // 2026-10-29 실측: DEA에는 md 사실 가드가 **없다**(`dea_questions_test.dart` 는
    // 구조·밀도 가드다). 그래서 전파할 금지 문장도 아직 없다 — 위 목록이 SOA 전용인
    // 것은 누락이 아니라 그 사실의 반영이다.
    //
    // 누군가 DEA 학습문서 사실 가드를 추가하면 이 테스트가 먼저 깨진다. 그때
    // 그 가드의 금지 문장을 위 목록에 옮기고 이 테스트를 지워라 — 그러지 않으면
    // 2026-10-20 SAA 사고(md만 고치고 문항에 미전파)가 DEA에서 재현된다.
    final deaGuards = Directory('test')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.startsWith('dea_') && n != 'dea_questions_test.dart')
        .toList()
      ..sort();
    expect(deaGuards, isEmpty,
        reason: 'DEA md 가드가 생겼다 — 그 금지 문장을 '
            'soa_dea_question_propagation_test.dart 의 목록에 옮겨라: $deaGuards');
  });
}

/// md 가드의 금지 **사실 서술**. `origin` 은 어느 가드에서 왔는지.
const _factRules = <({String text, String origin, String why})>[
  // ── soa_facts_test.dart ─────────────────────────────────────────────
  (
    text: 'REJECT로 잘 드러나지 않',
    origin: 'soa_facts',
    why: '보안 그룹 거부는 Flow Logs에 REJECT로 기록된다',
  ),
  (text: 'REJECT로 잘 안 보임', origin: 'soa_facts', why: '같음 — REJECT로 기록된다'),
  (text: 'REJECT 부재', origin: 'soa_facts', why: '같음 — REJECT로 기록된다'),
  (
    text: 'REJECT 로그를 남기지 않습니다',
    origin: 'soa_facts',
    why: '같음 — REJECT로 기록된다',
  ),
  (
    text: 'SG 거부는 Flow Log에 잘 안 보이고',
    origin: 'soa_facts',
    why: '같음 — REJECT로 기록된다',
  ),
  (
    text: '키 정책 + IAM 정책의 교집합',
    origin: 'soa_facts',
    why: 'KMS 권한은 교집합이 아니다 — 키 정책이 IAM에 위임하면 IAM 정책만으로 접근할 수 있다',
  ),
  (
    text: 'IAM 정책만으로는 CMK에 접근할 수 없고',
    origin: 'soa_facts',
    why: '같음 — 키 정책의 위임이 있으면 가능하다',
  ),
  (
    text: 'IAM 정책과 교집합이 적용되어',
    origin: 'soa_facts',
    why: '같음 — 교집합 모델이 아니다',
  ),
  (
    text: 'ACM 공인 인증서 무료',
    origin: 'soa_facts',
    why: '공인 인증서 발급·갱신은 무료지만 조건이 있다 — md 가드의 정정 문구를 쓴다',
  ),
  (
    text: 'Business/Enterprise Support 플랜',
    origin: 'soa_facts',
    why: 'Support 플랜 열거가 불완전하다 — md 가드의 정정 목록을 쓴다',
  ),
  (
    text: 'Business/Enterprise 지원 플랜',
    origin: 'soa_facts',
    why: '같음 — 열거가 불완전하다',
  ),
  (
    text: '멀티 리전 활성·활성, 최종 일관성',
    origin: 'soa_facts',
    why: 'md 가드가 정정한 일관성 서술을 쓴다',
  ),
  // ── soa_v11_topics_test.dart ────────────────────────────────────────
  (
    text: 'Lambda도 세부 모니터링',
    origin: 'soa_v11_topics',
    why: '세부 모니터링(1분)은 EC2의 설정이다 — Lambda·Bedrock 지표에 그 개념을 적용하지 않는다',
  ),
  (text: 'Bedrock 지표도 세부 모니터링', origin: 'soa_v11_topics', why: '같음'),
  (
    text: 'Bedrock 지표는 에이전트',
    origin: 'soa_v11_topics',
    why: 'Bedrock 지표는 CloudWatch 에이전트가 필요하지 않다',
  ),
  (
    text: '모델 호출 로깅은 기본적으로 활성',
    origin: 'soa_v11_topics',
    why: 'Bedrock 모델 호출 로깅은 **켜야** 한다',
  ),
  (text: 'Bedrock은 별도 설정 없이 호출 로그', origin: 'soa_v11_topics', why: '같음 — 설정이 필요하다'),
  (
    text: 'DevOps Agent가 CloudWatch를 대체',
    origin: 'soa_v11_topics',
    why: '신규 AI 에이전트는 기존 서비스를 대체하지 않는다',
  ),
  (text: 'Kiro가 Systems Manager를 대체', origin: 'soa_v11_topics', why: '같음 — 대체가 아니다'),
  (
    text: 'EFS와 FSx 두 가지',
    origin: 'soa_v11_topics',
    why: '공유 스토리지 선택지를 둘로 못 박지 않는다(md 가드의 정정 서술을 쓴다)',
  ),
  (text: 'EFS·FSx 중에서', origin: 'soa_v11_topics', why: '같음 — 둘로 한정하지 않는다'),
  (text: '공유 스토리지는 EFS와 FSx', origin: 'soa_v11_topics', why: '같음 — 둘로 한정하지 않는다'),
  (
    text: '제어 영역(control plane) 작업으로 장애 조치',
    origin: 'soa_v11_topics',
    why: 'md 가드가 정정한 장애 조치 서술을 쓴다',
  ),
  (
    text: '가중치를 바꾸는 것이 가장 안전',
    origin: 'soa_v11_topics',
    why: '같음 — 가장 안전하다고 단정하지 않는다',
  ),
  (
    text: 'CDK는 CloudFormation을 대체합니다',
    origin: 'soa_v11_topics',
    why: 'CDK는 CloudFormation 템플릿을 합성한다 — 대체가 아니다',
  ),
  (text: 'CDK는 CloudFormation을 대체하며', origin: 'soa_v11_topics', why: '같음'),
  (text: 'CDK는 CloudFormation 없이', origin: 'soa_v11_topics', why: '같음 — CloudFormation을 거친다'),
  (
    text: '대상 수에는 제한이 없',
    origin: 'soa_v11_topics',
    why: 'EventBridge 규칙의 대상 수에는 상한이 있다',
  ),
  (
    text: 'DevOps Agent는 EventBridge와 연동되지 않',
    origin: 'soa_v11_topics',
    why: 'md 가드가 정정한 연동 서술을 쓴다',
  ),
  (
    text: 'SCP는 기본적으로 모든 것을 거부',
    origin: 'soa_v11_topics',
    why: 'SCP는 가드레일이고 기본값은 FullAWSAccess 허용이다',
  ),
  (
    text: 'SCP는 통합 결제만으로',
    origin: 'soa_v11_topics',
    why: 'SCP는 전체 기능(all features)이 켜져 있어야 쓴다',
  ),
  (
    text: '글로벌 서비스까지 차단',
    origin: 'soa_v11_topics',
    why: 'aws:RequestedRegion은 글로벌 서비스 엔드포인트에 같은 방식으로 적용되지 않는다',
  ),
  (
    text: 'aws:RequestedRegion으로 모든 리전 영향을 통제',
    origin: 'soa_v11_topics',
    why: '같음 — 모든 리전 영향을 통제하지는 못한다',
  ),
  (
    text: 'Security Agent는 Security Hub의 기능',
    origin: 'soa_v11_topics',
    why: '신규 에이전트는 기존 서비스의 하위 기능이 아니다',
  ),
  (text: 'Security Agent는 GuardDuty의', origin: 'soa_v11_topics', why: '같음'),
  (
    text: 'PrivateLink는 AWS 서비스 전용입니다',
    origin: 'soa_v11_topics',
    why: 'PrivateLink로 사용자 서비스도 엔드포인트 서비스로 노출할 수 있다',
  ),
  (text: '사용자 서비스는 노출할 수 없', origin: 'soa_v11_topics', why: '같음 — 노출할 수 있다'),
  // 출제 추측 금지(V-14). 가이드 Revisions 표는 비중·빈도를 말하지 않는다.
  (
    text: '출제 비중',
    origin: 'soa_v11_topics V-14',
    why: '공식 근거 없는 출제 추측을 학습자용 문장에 쓰지 않는다',
  ),
  (text: 'Kiro는 자주 출제', origin: 'soa_v11_topics V-14', why: '같음 — 출제 추측 금지'),
  (text: 'DevOps Agent는 자주 출제', origin: 'soa_v11_topics V-14', why: '같음'),
  (text: 'Security Agent는 자주 출제', origin: 'soa_v11_topics V-14', why: '같음'),
  // EventBridge 는 경보 작업이 아니다(soa_facts F-8, 2026-11-01). 공식
  // alarm-actions 의 작업 표에 EventBridge 행이 없고, 같은 페이지가 "Alarms
  // also emit events to Amazon EventBridge when they change state" 라고 적는다.
  // soa-t1-1.md §4 표가 EventBridge 를 작업 대상으로 싣고 있었고 거기서 파생된
  // soa-t1-1-q11 이 같은 전제를 물려받았다 — 그 계열이 다시 번지지 않게 한다.
  (
    text: 'Systems Manager, EventBridge',
    origin: 'soa_facts F-8',
    why: 'EventBridge 는 경보 작업 목록에 들어가지 않는다 — 경보가 이벤트를 내보내는 곳이다',
  ),
  (
    text: '경보 작업 대상에는',
    origin: 'soa_facts F-8',
    why: '같음 — 작업 목록을 열거하면서 EventBridge 를 끼워 넣던 어구',
  ),
];

/// 구식·오표기 **제품 명칭**. 문항 전체(오답 보기·출처 제목 포함)를 본다.
const _nameRules = <({String text, String origin, String why})>[
  (
    text: '적합성 팩',
    origin: 'soa_v11_topics',
    why: 'v1.1 공식 KO 명칭은 「규정 준수 팩」이다(Conformance Pack). '
        '공식 ko_kr 도메인 4 Skill 4.1.5 문구이자 assets/exam_guides/SOA-C03.json 표기와 같다',
  ),
];
