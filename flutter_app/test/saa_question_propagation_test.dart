import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 학습문서(md)에서 정정된 구식 서술이 **파생 문항(`*.questions.json`)에도 남아 있지
/// 않은지** 검사하는 전파 가드 (2026-10-20).
///
/// ## 왜 필요한가
///
/// 2026-10-19 PR#137~#140이 SAA 학습문서의 사실을 공식 문서로 재확인해 정정하면서
/// md 전용 가드(`saa_t1_facts_test.dart`·`saa_t12_t13_facts_test.dart`·
/// `saa_t2_t4_facts_test.dart`)를 붙였다. 그런데 **문항은 md에서 파생되는데도 같은
/// 정정이 전파되지 않았다.** 구식 서술이 문항에 그대로 남았고(실측 7건, 그중
/// `saa-t4-2`는 이미 flip돼 라이브 노출 중이었다), md 가드는 md만 읽기 때문에 아무것도
/// 잡지 못했다. 같은 계열 사고가 2026-07에도 있었다(학습문서 정정이 오디오 대본에
/// 미전파). 이 테스트가 그 구멍을 막는다.
///
/// ## 운영 — md를 정정할 때마다 할 일
///
/// md 가드에 `expect(md.contains('<구식 문장>'), isFalse)` 를 새로 추가했다면, **그 문장을
/// 아래 `_rules` 에 한 줄 추가**하고 어느 가드의 어느 단정에서 왔는지를 `origin` 에,
/// 공식 사실을 `why` 에 적는다. 목록은 테스트 소스를 파싱해 만들지 않는다 — 파싱은
/// 가드 파일의 사소한 서식 변화에 깨지므로, 사람이 고른 명시적 상수 목록으로 둔다.
///
/// ## 검사 범위 — 오답 보기는 제외한다
///
/// `stem` · `skill` · `options[correct]` · `explanation` · `wrongExplanations` 만 본다.
/// **오답 보기(`options[i != correct]`)는 일부러 틀린 서술**이므로 금지 문장이 거기 있는
/// 것은 결함이 아니다. 반대로 `wrongExplanations` 는 "왜 그 보기가 틀렸는지"를 설명하는
/// 사실 서술이므로 검사한다 — 실제로 `saa-t4-4-q4` 의 오류가 거기 있었다.
///
/// `wrongExplanations` 가 틀린 주장을 **인용해 반박**하다 금지 문장과 겹쳐 터지는 날이
/// 오면, 그 항목을 지우지 말고 **반박문이 쓰지 않는 더 좁은 문구로 바꿔라.** 같은 이유로
/// "유일한 …" 류의 과장 표현(G-3.2-15)은 애초에 목록에 넣지 않았다 — 반박문이 그대로
/// 인용하기 쉬운 형태다.
///
/// ## 목록에 넣지 않은 것 (의도적)
///
/// - **md의 부분 구간만 잘라 쓰는 단정.** `saa_t1_facts_test.dart` 의 G-1.1-08은
///   `saa-t1-2.md` 자가 점검 Q1 **구간 안에서만** `ap-northeast-2` 를 금지한다(질문의
///   허용 리전과 해설의 허용 리전이 어긋나는 것을 막는 단정). 리전 이름 자체는 어디서든
///   정당하므로 전역 금지로 올리면 거짓양성이다 — 실제로 문항 6파일이 오탐됐다.
/// - **md 표·코드블록 형식 문자열.** `| **GWLB** (Gateway LB) | L3/4 |` 처럼 마크다운
///   구조에만 존재하는 문자열은 문항 JSON에 나타날 수 없다.
/// - **일반 어휘·짧은 수치 조각.** `신뢰한다`·`< 1ms`·`자동 고가용성`·`두 가지 엔진 지원`
///   등은 다른 서비스 맥락에서 정당하다(Aurora는 실제로 "두 가지 엔진"이다).
///
/// `Aurora Serverless v2` 는 이 파일이 처음 생길 때(2026-10-20 PR#165) **적재 키가 고아가
/// 된다**는 이유로 제외돼 있었다. **그 판단은 틀렸고 2026-10-20에 바로잡아 목록에 넣었다**
/// — 근거는 해당 항목 주석에 있다.
void main() {
  final files = Directory('assets/content/saa')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.questions.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  // 문항별로 "사실이어야 하는 텍스트"만 모아 둔다(오답 보기 제외).
  final scanned = <({String file, String id, String text})>[];
  // 그중 **정답으로 권하는 쪽**(`options[correct]` + `explanation`)만 따로 모아 둔다.
  // 아래 조건부 단정의 트리거는 "이 서비스를 답으로 권했는가"이므로 분류 라벨인
  // `skill` 과 오답 반박인 `wrongExplanations` 는 넣지 않는다.
  final answerSide = <({String file, String id, String text})>[];
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
      final parts = <String>[
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
        text: parts.join('\n'),
      ));
      answerSide.add((
        file: name,
        id: q['id'] as String? ?? '(id 없음)',
        text: [
          if (correct is int && correct >= 0 && correct < options.length)
            options[correct],
          q['explanation'] as String? ?? '',
        ].join('\n'),
      ));
    }
  }

  test('SAA 문항 파일과 문항이 읽혔다', () {
    expect(files.length, greaterThanOrEqualTo(24),
        reason: '파일이 줄었다면 이 가드의 검사 범위도 다시 보라');
    expect(scanned.length, greaterThanOrEqualTo(24 * 15));
  });

  group('md 가드가 금지한 문장이 문항에 전파되지 않았다', () {
    for (final rule in _rules) {
      final label = rule.text.length <= 28
          ? rule.text
          : '${rule.text.substring(0, 28)}…';
      test('${rule.origin} "$label"', () {
        final hits = scanned
            .where((s) => s.text.contains(rule.text))
            .map((s) => '${s.file} ${s.id}')
            .toList();
        expect(hits, isEmpty,
            reason: '${rule.origin}이 md에서 금지한 문장이 문항에 남아 있다.\n'
                '공식: ${rule.why}\n'
                '문장: "${rule.text}"');
      });
    }
  });

  // ── 조건부 단정 — 금지 문장 목록으로는 표현할 수 없는 모순 ──────────────
  //
  // `_rules` 는 "이 문장이 있으면 안 된다"만 표현한다. 그런데 `saa-t3-9-q11` 의
  // 결함은 **금지 문장이 있어서**가 아니라 **있어야 할 단서가 없어서** 생겼다 —
  // 대역폭 부족 500 TB 이전의 정답으로 Snow 패밀리를 권하면서 "신규 고객은 주문할
  // 수 없다"는 제약을 한 마디도 하지 않았고, 같은 문서 md(`saa-t3-9.md` §10)는 그
  // 제약 때문에 "Snow 패밀리는 신규 주문이 불가하므로 신규 설계의 정답이 아닙니다"
  // 라고 못박고 있다. 부분 문구만 보는 단정으로는 이 모순이 잡히지 않아 이 가드가
  // 처음 생길 때(PR#165) 놓쳤다.
  //
  // 그래서 **금지는 고정하고 요구는 느슨하게** 쓴다: 트리거는 "정답 쪽에서 Snow 를
  // 언급했는가"(`Snow` — `Snowball`·`Snow 패밀리`·`Snowball Edge` 를 모두 포함),
  // 요구는 핵심 키워드 `신규 고객` 하나뿐이다. 어떤 문장으로 쓰든 공식 사실("no
  // longer available to new customers")을 한국어로 옮기면 이 키워드가 들어간다.
  //
  // 오답 보기와 `wrongExplanations` 는 트리거에서 제외했다 — "Snowball 은 스키마
  // 변환 도구가 아니다" 같은 반박문에 가용성 단서를 요구하는 것은 거짓양성이다.
  test('saa_t2_t4 G-3.5-09 — Snow 패밀리를 정답으로 권하면 "신규 고객" 제약을 함께 말한다',
      () {
    final hits = answerSide
        .where((s) => s.text.contains('Snow') && !s.text.contains('신규 고객'))
        .map((s) => '${s.file} ${s.id}')
        .toList();
    expect(hits, isEmpty,
        reason: 'Snow 패밀리를 정답으로 권하면서 신규 고객 주문 불가를 말하지 않았다.\n'
            '공식: "AWS Snowball Edge is no longer available to new customers" — '
            '신규 고객은 어떤 Snow Family 디바이스도 주문할 수 없고(기존 고객은 계속 사용), '
            '대안은 온라인 DataSync·물리 AWS Data Transfer Terminal·파트너, 엣지는 Outposts다.\n'
            'md: saa-t3-9.md \u00a7 10 "Snow 패밀리는 신규 주문이 불가하므로 신규 설계의 정답이 아닙니다"');
  });
}

/// 금지 문장 목록. `origin` = 이 문장을 금지한 md 가드의 단정, `why` = 공식 사실.
final List<({String text, String origin, String why})> _rules = [
  // ── saa_t1_facts_test.dart (Task 1.1) ──────────────────────────────────
  (
    text: 'MFA 필수, 액세스 키 발급 금지, 일상 작업에 사용 금지',
    origin: 'saa_t1 G-1.1-10',
    why: '루트 현행 정책은 첫 로그인 후 35일 유예·중앙 루트 접근 관리까지 포함한다',
  ),
  (
    text: 'Active Directory 등 SAML 2.0 IdP',
    origin: 'saa_t1 G-1.1-09',
    why: 'AD는 외부 SAML IdP가 아니라 AWS Directory Service로 연결하는 별도 ID 소스다',
  ),

  // ── saa_t12_t13_facts_test.dart (Task 1.2·1.3) ────────────────────────
  (
    text: 'us-east-1 제한 없음',
    origin: 'saa_t12_t13 G-1.2-06',
    why: 'CLOUDFRONT 스코프 웹 ACL은 us-east-1에서만 만든다',
  ),
  (
    text: '첫 번째로 매칭된 규칙의 액션(Allow/Block/Count/CAPTCHA)을 실행',
    origin: 'saa_t12_t13 G-1.2-07',
    why: 'Count는 비종료 액션이라 매칭돼도 평가가 계속된다',
  ),
  (
    text: 'IAM 정책만으로는 CMK 접근이 불가',
    origin: 'saa_t12_t13 G-1.3-06',
    why: '키 정책에 계정 위임 문장이 있으면 IAM 정책만으로 접근이 성립한다',
  ),
  (
    text: '키 정책의 **교집합**에서 접근이 허용',
    origin: 'saa_t12_t13 G-1.3-06',
    why: '교집합이 아니라 키 정책의 IAM 위임 여부가 갈림길이다',
  ),
  (
    text: 'IAM 정책과 키 정책 모두 Allow 상태여야',
    origin: 'saa_t12_t13 G-1.3-06',
    why: '교집합이 아니라 키 정책의 IAM 위임 여부가 갈림길이다',
  ),
  (
    text: '"FIPS Level 3 감사" 키워드 → CloudHSM',
    origin: 'saa_t12_t13 G-1.3-07',
    why: 'KMS 표준 HSM도 FIPS 140-3 Level 3 검증을 받았다 — 갈림길은 단일 테넌트 요건이다',
  ),
  (
    text: 'KMS는 멀티테넌트 환경이고 AWS 관리형이므로 "전용 하드웨어 + 단독 통제" 요건을 충족하지 못합니다',
    origin: 'saa_t12_t13 G-1.3-07',
    why: 'AWS는 어떤 키 저장소에서도 운영자가 평문 키에 접근하지 못하도록 설계했다고 명시한다',
  ),
  (
    text: 'ACM이 발급하는 인증서는 추가 요금 없음',
    origin: 'saa_t12_t13 G-1.3-10',
    why: '내보내기 가능 인증서는 유료다',
  ),
  (
    text: 'DNS 검증 또는 이메일 검증이 유효한 상태여야',
    origin: 'saa_t12_t13 G-1.3-11',
    why: '관리형 갱신 자동화는 DNS 검증으로 발급한 인증서 기준이다',
  ),
  (
    text: '쿨다운(기본 3일)',
    origin: 'saa_t12_t13 G-1.3-12',
    why: 'Vault Lock 유예는 ChangeableForDays로 사용자가 지정한다(최소 3일)',
  ),
  (
    text: '민감정보(PII — 주민번호·신용카드·여권번호 등)를 머신러닝으로 자동 탐지',
    origin: 'saa_t12_t13 G-1.3-13',
    why: 'Macie는 머신러닝 + 패턴 매칭이고 사용자 정의 식별자는 정규식 기반이다',
  ),

  // ── saa_t2_t4_facts_test.dart (Task 2.1~4.4) ──────────────────────────
  (
    text: '제한된 횟수만 재시도하고 이후 메시지를 버립니다',
    origin: 'saa_t2_t4 G-2.1-10',
    why: 'AWS 관리형 엔드포인트(SQS·Lambda)는 23일에 걸쳐 100,015회 재시도한다',
  ),
  (
    text: 'SNS는 Push 후 재시도가 제한적입니다',
    origin: 'saa_t2_t4 G-2.1-10',
    why: 'SNS DLQ는 토픽이 아니라 구독 단위로 붙고 재시도는 23일·100,015회다',
  ),
  (
    text: 'Step Functions(Durable Lambda)',
    origin: 'saa_t2_t4 G-2.1-11',
    why: 'Durable functions는 Lambda의 기능군이고 Step Functions와 별개다',
  ),
  (
    text: '기존 EC2-Classic 환경만',
    origin: 'saa_t2_t4 G-2.2-13',
    why: 'CLB는 EC2-Classic 전용이 아니라 이전 세대 로드밸런서다',
  ),
  (
    text: '단일 객체 최대 5TB',
    origin: 'saa_t2_t4 G-3.1-09',
    why: '멀티파트 업로드로 단일 객체 최대 50 TB다(단일 PUT은 5 GB)',
  ),
  (
    text: '5 GB 이상 필수',
    origin: 'saa_t2_t4 G-3.1-10',
    why: '단일 PUT 상한이 5 GB라 멀티파트는 5 GB 초과에서 필수다',
  ),
  (
    text: '수천 인스턴스가 동시 접근하는 빅데이터 분석',
    origin: 'saa_t2_t4 G-3.1-11',
    why: 'EFS Max I/O는 이전 세대 성능 모드이고 Elastic 처리량·One Zone에서는 쓸 수 없다',
  ),
  (
    text: '없음=Intel',
    origin: 'saa_t2_t4 G-3.2-10',
    why: '프로세서 접미사는 i=Intel이다 — 접미사가 없는 것이 Intel을 뜻하지 않는다',
  ),
  (
    text: 'n=네트워크 강화, b=EBS 최적화',
    origin: 'saa_t2_t4 G-3.2-11',
    why: 'b=블록 스토리지 최적화, n=네트워크·EBS 최적화다',
  ),
  (
    text: '범용 SSD(gp2/gp3)는 버스트 크레딧 방식',
    origin: 'saa_t2_t4 G-3.3-10',
    why: 'gp3는 버스트를 쓰지 않고 프로비저닝 성능을 무기한 유지한다(버스트는 gp2만)',
  ),
  // `skill` 라벨에 들어 있어 사용자 데이터 호환이 걸린다고 보고 PR#165에서 미뤘던
  // 항목이다. 코드를 확인한 결과 `skill` 은 **적재 키가 아니다** — 로컬 키는
  // `awsdocs.history.v1`(history_store), 클라우드 키는 `certId|examId|date`(sync_merge)이고,
  // `WrongSkill.skill` 은 "stale 문항에도 개념 보존"을 위한 비정규화 스냅샷이다
  // (attempt_record). 소비처 5곳은 전부 표시·Task별 dedup이고 딥링크는 `section` 을 쓴다.
  // 남는 영향은 리포트가 문자열로 dedup하므로 옛 라벨과 새 라벨이 두 줄로 보일 수 있다는
  // 것뿐이다(손실 없음·마이그레이션 불필요). 그래서 2026-10-20에 목록에 넣었다.
  (
    text: 'Aurora Serverless v2',
    origin: 'saa_t2_t4 G-3.3-13',
    why: '공식 문서가 "Aurora serverless"로 표기한다 — v2 표기는 구식이다',
  ),
  (
    text: '수평 확장, 무제한 처리량',
    origin: 'saa_t2_t4 G-3.3-15',
    why: 'DynamoDB는 파티션당 읽기 3,000·쓰기 1,000 단위 한도가 있다',
  ),
  (
    text: 'CloudFront 앞에 Global Accelerator',
    origin: 'saa_t2_t4 G-3.4-10',
    why: 'GA 표준 액셀러레이터 엔드포인트는 NLB·ALB·EC2 인스턴스·Elastic IP뿐이다',
  ),
  (
    text: '**Global Accelerator** + CloudFront 조합',
    origin: 'saa_t2_t4 G-3.4-10',
    why: 'GA 표준 액셀러레이터 엔드포인트는 NLB·ALB·EC2 인스턴스·Elastic IP뿐이다',
  ),
  (
    text: 'Snowball Edge는 엣지 컴퓨팅도 가능합니다',
    origin: 'saa_t2_t4 G-3.5-09',
    why: 'Snow Family는 신규 고객 주문이 불가하고 엣지 컴퓨팅 대안은 Outposts다',
  ),
  (
    text: '샤드 수는 자동으로 증가하지 않습니다',
    origin: 'saa_t2_t4 G-3.5-10',
    why: '온디맨드 모드는 샤드를 자동 관리한다 — 모드를 한정하지 않으면 틀린 단정이다',
  ),
  (
    text: '**여러 컨슈머가 동시에 독립적으로** 읽을 수 있습니다',
    origin: 'saa_t2_t4 G-3.5-11',
    why: '기본 소비자는 샤드당 2 MB/s를 공유하고 전용 처리량은 EFO다',
  ),
  (
    text: 'Athena, EMR(Apache Spark), Redshift Spectrum, Glue ETL 전반에 Lake Formation 권한이 일관되게 적용됩니다',
    origin: 'saa_t2_t4 G-3.5-12',
    why: '엔진별로 지원 범위가 다르다(Hive on EMR 행/셀 미지원, Glue ETL 열/행은 5.0 이상)',
  ),
  (
    text: '**Java·Scala·SQL**',
    origin: 'saa_t2_t4 G-3.5-15',
    why: 'Managed Service for Apache Flink는 Python도 지원한다',
  ),
  (
    text: '완전히 삭제(Terminate)해야 볼륨 요금이 멈춥니다',
    origin: 'saa_t2_t4 G-4.1-13',
    why: 'Terminate는 DeleteOnTermination=true인 볼륨만 지우고 보존된 볼륨은 계속 과금된다',
  ),
  (
    text: '절감액을 초과',
    origin: 'saa_t2_t4 G-4.1-14',
    why: '128 KB 미만 객체에는 모니터링·자동화 요금이 붙지 않는다(손해가 아니라 절감이 없는 것)',
  ),
  (
    text: '실시간(갱신 주기 8~12시간)',
    origin: 'saa_t2_t4 G-4.1-21',
    why: 'AWS Budgets는 하루 최대 3회 갱신된다',
  ),
  (
    text: '해당 월 6~7일에 반영',
    origin: 'saa_t2_t4 G-4.1-24',
    why: '근거 없는 수치 — 현행 플랜은 Basic·Business Support+·Enterprise·Unified Operations다',
  ),
  (
    text: 'CloudWatch 지표 14일 이상 수집',
    origin: 'saa_t2_t4 G-4.1-25',
    why: 'Compute Optimizer 룩백은 기본 14일이고 향상 인프라 지표에서 최대 93일이다',
  ),
  (
    text: '최대 54%',
    origin: 'saa_t2_t4 G-4.2-12',
    why: 'Convertible RI는 최대 66%, Standard RI는 최대 72%다',
  ),
  (
    text: '(Graviton3 기준)',
    origin: 'saa_t2_t4 G-4.2-17',
    why: '공식 수치는 Graviton 패밀리 기준 "최대 20%"이고 세대를 한정하는 근거가 없다',
  ),
  (
    text: '사용한 시간만 밀리초 단위로 과금 — 유휴 시 비용 없음',
    origin: 'saa_t2_t4 G-4.2-19',
    why: 'Fargate는 초 단위·최소 1분이고 Lambda 프로비저닝 동시성은 유휴에도 과금된다',
  ),
  (
    text: 'RDS 비용 절감은 RDS 예약 인스턴스로만 가능합니다',
    origin: 'saa_t2_t4 G-4.3-12',
    why: 'Database Savings Plans가 RDS·Aurora에 적용된다',
  ),
  (
    text: '구성 속성이 하나라도 달라지면 할인이 적용되지 않습니다',
    origin: 'saa_t2_t4 G-4.3-13',
    why: 'RDS RI는 엔진에 따라 사이즈 유연하고 Multi-AZ·Single-AZ 모두에 적용된다',
  ),
  (
    text: '관계형 DB 대비 1/10 비용',
    origin: 'saa_t2_t4 G-4.3-15',
    why: 'Timestream for LiveAnalytics는 신규 고객 접근이 닫혔고 대안은 InfluxDB다',
  ),
  (
    text: '프로비저닝 스토리지 크기까지는 무료(RDS 기본 제공 범위)',
    origin: 'saa_t2_t4 G-4.3-20',
    why: 'RDS 백업 스토리지는 리전 전체의 자동 백업 + 수동 스냅샷 합계 기준이다',
  ),
  (
    text: '\$0.01/GB + \$0.02/GB',
    origin: 'saa_t2_t4 G-4.4-12',
    why: 'TGW를 통과하는 AZ 간 트래픽에는 별도 AZ 전송 요금이 없다',
  ),
  (
    text: '\$0.01/GB + 시간당 ENI 요금',
    origin: 'saa_t2_t4 G-4.4-16',
    why: '인터페이스 엔드포인트 시간 요금은 ENI가 아니라 엔드포인트·AZ별로 붙는다',
  ),
  // 2026-10-21 갭 배치 B5. `saa-t2-1.md` 를 메시지 1 MiB 로 보강하면서 전수 대조한
  // 결과, `saa-t2-1-q6` 의 `wrongExplanations` 가 구식 256KB 를 그대로 들고 있었다
  // (verified:true — 라이브 노출 중이었다). 같은 계열의 재발을 막는다.
  (
    text: '크기 제한(256KB)',
    origin: 'saa_gaps_b5 G-2.1-05',
    why: 'SQS 최대 메시지 크기는 2025-08에 256 KiB에서 1 MiB로 상향됐다',
  ),
  // 2026-10-21 갭 배치 B6. `saa-t2-4` 에 Aurora 장애 조치 시간을 공식 문구로 적고
  // 전수 대조하니 `saa-t3-5-q12`(verified:true)가 "30초 미만"만 적어 상한을
  // 빠뜨리고 있었다. 같은 파일 `q6` 은 정확히 적고 있어 문서 내부도 어긋났다.
  (
    text: '30초 미만 페일오버',
    origin: 'saa_gaps_b6 G-2.2-08',
    why: '공식 Aurora 사용자 가이드는 "통상 60초 미만, 흔히 30초 미만"으로 적는다',
  ),
];
