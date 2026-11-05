import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// AIF-C01 공식 시험 가이드 v1.1 동기화 가드.
///
/// 2026-11-03 조사에서 레포 JSON(2026-06-11 수집)이 **목표 69건 중 17건**을
/// 공식 v1.1과 다르게 적고 있는 것이 적발됐다. v1.0 스냅샷이 아니라
/// **v1.0 잔재 + 개정 표에만 있는 문구 + 공식에 없는 서비스 예시 + 기계번역
/// 음차**가 섞인 하이브리드였다. 그중 9건은 서비스·지표 목록이 실제로 달라
/// **레포 JSON만 보고 저작하면 범위 밖 서비스를 정답 보기로 쓰게 된다.**
///
/// 근거: `docs/content-research/AIF-C01/00-overview.md` §3(공식 ko_kr 본문 전사)
/// · `97-repo-json-diff.md`(기계 대조 — 일치 52 · 불일치 17) · 저작 결정 D-06.
/// 공식 가이드가 다시 개정되면 이 테스트를 근거 문서와 함께 갱신한다.
///
/// ## 왜 「금지 문구」까지 세는가
///
/// 목표 본문을 공식으로 교체하면 그 17건은 맞아지지만, **다시 섞여 들어오는
/// 것**을 막지는 못한다. 공식 범위 목록에 **없는** 서비스 4종과 기계번역
/// 잔재는 파일 전체에서 0건으로 고정한다.
///
/// ⚠️ **두 패턴은 부분 문자열 함정이 있다.** `Amazon Q`는 공식이 쓰는
/// `Amazon Quick`의 접두사이고, `AgentCore ID`는 공식 `AgentCore Identity`의
/// 접두사다. 그래서 단순 `contains`로 세면 **교체한 공식 문구가 스스로 가드에
/// 걸린다.** 음성 전방탐색으로 가르고, 그 가름이 실제로 되는지 대조군으로
/// 먼저 단정한다.
void main() {
  final raw = File('assets/exam_guides/AIF-C01.json').readAsStringSync();
  final guide = json.decode(raw) as Map<String, dynamic>;
  final domains = (guide['domains'] as List).cast<Map<String, dynamic>>();

  /// `{Task번호}.{순번}` → 목표 문구. AIF 가이드는 Task 아래 「목표」 한 층만
  /// 두고 **Skill 계층이 없다**(저작 결정 D-01·D-04). 그 목표가 JSON의
  /// `knowledge` 배열이다.
  Map<String, String> objectivesByNumber() {
    final out = <String, String>{};
    for (final d in domains) {
      for (final t in (d['tasks'] as List).cast<Map<String, dynamic>>()) {
        final objectives = (t['knowledge'] as List).cast<String>();
        for (var i = 0; i < objectives.length; i++) {
          out['${t['no']}.${i + 1}'] = objectives[i];
        }
      }
    }
    return out;
  }

  Map<String, String> titlesByNumber() {
    final out = <String, String>{};
    for (final d in domains) {
      for (final t in (d['tasks'] as List).cast<Map<String, dynamic>>()) {
        out['${t['no']}'] = t['title'] as String;
      }
    }
    return out;
  }

  group('가이드 버전 메타', () {
    test('v1.1 버전·발행일·공식 자격증명이 기록돼 있다', () {
      expect(guide['guideVersion'], '1.1',
          reason: '공식 가이드 버전을 JSON에 남겨야 다음 개정을 감지할 수 있다');
      expect(guide['guidePublished'], '2026-04-30',
          reason: 'v1.1 게시일(v1.0은 2026-03-26)');
      expect(guide['officialName'], 'AWS Certified AI Practitioner',
          reason: 'SOA-C03과 같은 스키마로 공식명을 남긴다');
    });
  });

  group('대조군: 가드의 입력이 실제로 만들어지는가', () {
    // 이것이 없으면 아래 「공식 v1.1 전문 일치」가 **빈 맵**을 상대로 조용히
    // 통과할 수 있다. 분해는 00-overview §3 「목표 수 집계」 표의 실측이다.
    test('목표 69개가 5·6·6 / 6·4·4 / 6·5·3·5 / 7·4 / 5·3으로 유도된다', () {
      final objectives = objectivesByNumber();
      expect(objectives.length, 69,
          reason: '목표 유도가 깨졌다 — 가이드 JSON 구조가 바뀌었는지 본다');

      const perTask = <String, int>{
        '1.1': 5, '1.2': 6, '1.3': 6,
        '2.1': 6, '2.2': 4, '2.3': 4,
        '3.1': 6, '3.2': 5, '3.3': 3, '3.4': 5,
        '4.1': 7, '4.2': 4,
        '5.1': 5, '5.2': 3,
      };
      expect(perTask.values.reduce((a, b) => a + b), 69);
      perTask.forEach((task, count) {
        // 번호가 1부터 빈틈 없이 이어지는지 — 한 항목이 밀리면 뒤가 전부
        // 거짓 불일치로 보인다(97 §1의 대조군과 같은 이유).
        for (var i = 1; i <= count; i++) {
          expect(objectives, contains('$task.$i'),
              reason: '$task.$i이 없다 — 목표가 밀렸다');
        }
        expect(objectives.keys.where((k) => k.startsWith('$task.')).length,
            count,
            reason: '$task: 목표 수가 $count이 아니다');
      });
    });
  });

  group('개정에서 바뀌지 않은 구조', () {
    test('도메인 5개 · 비중 20·24·28·14·14(합 100) · Task 3·3·4·2·2', () {
      // ⚠️ AIF는 **도메인이 5개**다(SOA-C03에 이어 두 번째). 4개로 보는
      // 코드·가드가 있으면 도메인 5가 조용히 비켜 간다.
      expect(domains.length, 5);
      expect([for (final d in domains) d['no']], [1, 2, 3, 4, 5]);
      expect([for (final d in domains) d['weightPct']], [20, 24, 28, 14, 14]);
      expect(
          [for (final d in domains) d['weightPct'] as int]
              .reduce((a, b) => a + b),
          100);
      expect([for (final d in domains) (d['tasks'] as List).length],
          [3, 3, 4, 2, 2]);
    });

    test('도메인 이름이 공식 도메인 페이지 제목이다 (저작 결정 D-02)', () {
      // ⚠️ 공식이 도메인 3을 한 페이지 안에서 두 가지로 적는다 — 도메인 페이지
      // 제목은 "파운데이션 모델의 적용", 「내용 개요」는 "파운데이션 모델 적용".
      // D-02가 **도메인 페이지 제목**을 정본으로 정했고
      // `aif_doc_format_test.dart`의 `domainNames` 표도 같은 값을 쓴다.
      expect([for (final d in domains) d['name']], [
        'AI 및 ML의 기초',
        'GenAI의 기초',
        '파운데이션 모델의 적용',
        '책임 있는 AI에 대한 가이드라인',
        'AI 솔루션의 보안, 규정 준수 및 거버넌스',
      ]);
    });

    test('overview: 합격 700 · 채점 50 + 비채점 15 = 65 · 90분', () {
      final overview = guide['overview'] as Map<String, dynamic>;
      expect(overview['level'], 'Foundational');
      expect(overview['passingScore'], 700);
      expect(overview['scoredQuestions'], 50);
      expect(overview['unscoredQuestions'], 15);
      expect(
          (overview['scoredQuestions'] as int) +
              (overview['unscoredQuestions'] as int),
          65,
          reason: '인증 페이지 "Exam format 65 questions"와 맞아야 한다');
      // ⚠️ **시험 시간은 가이드 본문에 없다**(99-gaps G-01 — 해소). 근거는
      // 공식 인증 페이지의 "Exam duration 90 minutes"다. 값은 옳으므로 97 §5의
      // 「확정하거나 제거」를 **확정**으로 닫는다.
      expect(overview['durationMinutes'], 90);
    });

    test('Task 제목 14개가 공식 본문과 전문 일치한다', () {
      // 97의 기계 대조는 **목표 본문만** 봤다. 제목 전수 대조는 이 PR에서
      // 처음 했고 **차이는 2.1의 마침표 하나**였다(공식은 서술형 문장이라
      // 마침표가 있고, 나머지 13개는 명사형 종결이라 없다).
      expect(titlesByNumber(), {
        '1.1': '기본 AI 개념과 용어 설명',
        '1.2': 'AI의 실제 사용 사례 파악',
        '1.3': 'ML 개발 수명 주기 설명',
        '2.1': '생성형 AI(Gen AI)의 기본 개념을 설명합니다.',
        '2.2': '비즈니스 문제 해결을 위한 GenAI의 기능과 한계 이해',
        '2.3': 'GenAI 애플리케이션을 구축하기 위한 AWS 인프라 및 기술 설명',
        '3.1': '파운데이션 모델(FM)을 사용하는 애플리케이션의 설계 고려 사항 설명',
        '3.2': '효과적인 프롬프트 엔지니어링 기법 선택',
        '3.3': '파운데이션 모델의 훈련과 미세 조정 프로세스 설명',
        '3.4': 'FM 성능을 평가하는 방법 설명',
        '4.1': '책임감 있는 AI 시스템 개발 설명',
        '4.2': '투명하고 설명 가능한 모델의 중요성 이해',
        '5.1': 'AI 시스템의 보안 방법 설명',
        '5.2': 'AI 시스템의 거버넌스 및 규정 준수 이해',
      });
    });

    test('Task마다 목표가 있고 skills는 빈 배열이다', () {
      // AIF 가이드에는 Skill 계층이 **없다**(D-01). SOA-C03.json이 반대로
      // `knowledge: []`를 비워 두므로, 빈 배열을 남기는 것이 이 레포의 관례다
      // (`ExamTask.fromJson`이 양쪽 다 `const []`로 기본값을 준다).
      // 97 §5 ⑥의 「빈 배열 처리 방침」을 **유지**로 닫는다.
      for (final d in domains) {
        for (final t in (d['tasks'] as List).cast<Map<String, dynamic>>()) {
          expect((t['knowledge'] as List), isNotEmpty,
              reason: 'Task ${t['no']}: 목표가 비었다');
          expect((t['skills'] as List), isEmpty,
              reason: 'Task ${t['no']}: AIF에는 Skill 계층이 없다');
        }
      }
    });
  });

  group('v1.1과 어긋났던 목표 17건이 공식 전문이다', () {
    // 공식 ko_kr 본문 전사(00-overview §3)를 **기계로 찍어** 옮겼다. 손으로
    // 69건을 베끼면 오타가 섞이고, 그 오타가 그대로 가드가 된다.
    const officialV11 = <String, String>{
      '1.1.1':
          '기본 AI 용어(예: AI, ML, 딥 러닝, 신경망, 컴퓨터 비전, 자연어 처리(NLP), '
              '모델, 알고리즘, 훈련 및 추론, 편향, 공정성, 적합성, 대규모 언어 모델(LLM), 생성형 AI(GenAI), '
              '에이전틱 AI) 정의',
      '1.1.2': 'AI, ML, GenAI, 딥 러닝, 에이전틱 AI 간의 유사점과 차이점 설명',
      '1.2.4':
          '실제 AI 애플리케이션의 예시 식별(예: 컴퓨터 비전, NLP, 음성 인식, 추천 시스템, '
              '사기 행위 탐지, 예측, 지식 기반, 에이전틱 AI)',
      '1.2.5':
          'AWS 관리형 AI/ML 서비스의 기능 설명(예: Amazon SageMaker AI, '
              'Amazon Transcribe, Amazon Translate, Amazon Comprehend, Amazon '
              'Lex, Amazon Polly)',
      '1.2.6':
          '기존 ML 모델 또는 파운데이션 모델(FM)이 특정 사용 사례에 적합한 경우 식별(예: 규제 '
              '문제, 설명 가능성 요구 사항, 운영 제약 조건)',
      '1.3.1': 'AI/ML 파이프라인의 구성 요소 설명 및 구분',
      '1.3.4':
          'AI/ML 파이프라인의 각 단계에 대한 관련 AWS 서비스 및 기능 식별(예: Amazon '
              'Bedrock, Amazon Quick, Kiro, SageMaker AI)',
      '1.3.6':
          '모델을 평가하기 위한 모델 성능 지표 설명(예: 정확도, 정밀도, 재현율, F1 점수) 및 '
              '비즈니스 지표(예: 사용자당 비용, 개발 비용, 고객 피드백, 투자 수익률(ROI))',
      // ⚠️ 2.1.6·2.2.1은 97이 「일치」로 센 항목이다 — 그 대조가 **공백을 제거**해
      // 비교했기 때문이다(97 §1). 바이트로 세면 기계번역 띄어쓰기 잔재가 남아
      // 있었다: `개념 (예:` · `프로토콜 (MCP)` · `능력) 을`. 교체는 공식 전문을
      // 그대로 넣는 것이므로 바이트 기준이 맞다.
      '2.1.6':
          '기본 에이전트 AI 개념(예: 복잡한 AI 애플리케이션을 위한 다중 에이전트 시스템 패턴, '
              '모델 컨텍스트 프로토콜(MCP) 및 에이전트를 외부 시스템에 연결하는 역할, 다중 에이전트 통신 패턴, 메모리 '
              '관리, 도구 사용, 워크플로 오케스트레이션)을 정의',
      '2.2.1': 'GenAI의 장점(예: 적응성, 반응성, 대화 기능, 콘텐츠 생성 능력)을 설명',
      '2.3.1':
          'GenAI 애플리케이션 개발을 위한 AWS 서비스 및 기능 식별(예: Amazon '
              'Bedrock, Amazon SageMaker AI, SageMaker JumpStart, Amazon Quick, '
              'Kiro, Strands Agents, Amazon Bedrock AgentCore)',
      '4.1.4':
          '생성형 AI(GenAI) 사용에 따른 법적 위험 식별(예: 지적 재산권 침해 클레임, 편향된 '
              '모델 출력, 고객 신뢰 상실, 최종 사용자 위험, 할루시네이션)',
      '4.1.7':
          '편향, 신뢰성 및 진실성을 감지하고 모니터링하는 도구 설명(예: 라벨 품질 분석, 인간 감사, '
              '하위 그룹 분석)',
      '4.2.1': '투명하고 설명 가능한 모델과 투명하지 않고 설명 불가능한 모델의 차이점 설명',
      '4.2.2':
          '투명하고 설명 가능한 모델을 식별하는 도구를 설명(예: Amazon SageMaker '
              'Model Cards, Amazon Bedrock 모델 평가, 오픈 소스 모델, 데이터, 라이선스)',
      '5.1.1':
          'AI 시스템 보안을 위한 AWS 서비스 및 기능 식별(예: IAM 역할, 정책 및 권한, '
              '암호화, Amazon Macie, AWS PrivateLink, AWS 공동 책임 모델, Amazon Bedrock '
              'AgentCore Identity, AgentCore의 정책, Amazon Bedrock Guardrails)',
      '5.1.4':
          'AI 시스템의 보안 및 개인 정보 보호 고려 사항 설명(예: 애플리케이션 보안, 위협 탐지, '
              '취약성 관리, 인프라 보호, 프롬프트 인젝션, 저장 및 전송 중 암호화, 데이터 유출 방지, 출력 필터링 및 검증, '
              'AI 상호 작용에 대한 감사 추적 및 로깅 요구 사항, 독성)',
      '5.1.5':
          '출력 정확도를 개선하기 위한 할루시네이션 감지 방법 및 접지 기법 설명(예: 검색 증강 '
              '생성(RAG) 근거 기반, 출력 유효성 검사, 신뢰도 점수)',
      '5.2.1':
          '거버넌스 및 규정 준수를 지원하는 AWS 서비스 및 기능 파악(예: AWS Config, '
              'Amazon Inspector, AWS Artifact, AWS CloudTrail, AWS Trusted '
              'Advisor)',
    };

    test('대조군: 교체 대상이 바이트 기준 19건이다 (97의 17 + 공백 2)', () {
      // 97-repo-json-diff.md §1은 **공백을 제거해** 비교했으므로 「공백만 다른」
      // 2건(2.1.6 · 2.2.1)을 일치로 세었다. 이 PR에서 바이트로 다시 세어
      // **19건**임을 확인했다. 97의 17건이 틀린 것이 아니라, 그 문서가
      // 「문체·조사 차이를 눈으로 분류하려고」 공백을 뺀 결과다.
      expect(officialV11.length, 19,
          reason: '교체 대상 수가 달라졌다 — 공식 전사와 다시 대조한다');
      expect(officialV11.keys.where((k) => k.startsWith('2.')).length, 3,
          reason: '도메인 2는 2.1.6 · 2.2.1 · 2.3.1 셋이다');
    });

    final actual = objectivesByNumber();
    officialV11.forEach((no, text) {
      test('목표 $no 가 v1.1 전문이다', () {
        expect(actual[no], isNotNull, reason: '목표 $no 가 JSON에 없다');
        expect(actual[no], text);
      });
    });
  });

  group('공식에 없는 서비스·기계번역 잔재가 0건이다', () {
    // 전체 파일 텍스트를 본다 — 목표뿐 아니라 제목·도메인 이름에 섞여도 잡는다.
    //
    // ⚠️ 쓰지 않은 항목을 금지로 걸지 않는다. 아래는 모두 **공식 v1.1 본문에
    // 없음이 실측된** 것이거나(범위 내 목록에도 없다 — 00-overview §4.1)
    // 기계번역 잔재다. "근거가 뒤에 확인될 수도 있는" 서술은 넣지 않는다.
    const forbidden = <String, String>{
      'AWS Audit Manager':
          '공식 5.2.1에 없고 범위 내 목록에도 없다. 게다가 2026-04-30부터 '
              '신규 계정에서 설정할 수 없다(저작 결정 D-07)',
      'Augmented AI': '공식 4.1.7에 없고 범위 내 목록에도 없다',
      'A2I': '공식 4.1.7에 없고 범위 내 목록에도 없다',
      'SageMaker Model Monitor': '공식 4.1.7에 없고 범위 내 목록에도 없다',
      'SageMaker Clarify':
          '공식 4.1.7·4.2.2에 없다. 신규 고객에게 더 이상 열려 있지 않다(D-07)',
      '아마존': '서비스명 한글 음차는 기계번역 잔재다 — 레포 전체가 영문 서비스명을 쓴다',
      'BedRock': '오표기 — 공식은 Amazon Bedrock이다',
      '신속한 삽입': 'prompt injection의 기계번역 오역 — 공식은 프롬프트 인젝션이다',
      '기초 모델': '공식 한국어 본문은 파운데이션 모델로 적는다(D-09)',
      '환각': '공식 한국어 본문은 2.2.2·4.1.4·5.1.5에서 모두 할루시네이션으로 적는다',
      '곡선 밑부분 면적': 'v1.0 지표 — v1.1의 1.3.6은 정밀도·재현율로 바뀌었다',
      '사기 탐지': 'v1.0 문구 — v1.1의 1.2.4는 사기 행위 탐지다',
      // ── 기계번역 띄어쓰기 잔재 ──────────────────────────────────────
      // 공식 전사(목표 69 + 제목 14)에서 아래 패턴은 **전부 0건**이다(실측).
      // 97이 「공백 제거」로 대조해 2.1.6·2.2.1의 이 잔재를 못 셌으므로,
      // 다시 섞여 들어오는 것을 패턴으로 막는다.
      ' (': '괄호 앞 공백 — 공식은 `개념(예:`처럼 앞 단어에 붙인다',
      ') 을': '괄호 뒤 조사 앞 공백 — 공식은 `능력)을`이다',
      ') 를': '괄호 뒤 조사 앞 공백',
      ') 이': '괄호 뒤 조사 앞 공백 — 공식은 `모델(FM)이`다',
      ') 에': '괄호 뒤 조사 앞 공백',
      '  ': '연속 공백',
    };

    forbidden.forEach((needle, why) {
      test('`$needle`이 없다', () {
        expect(raw.contains(needle), isFalse, reason: why);
      });
    });

    // ── 부분 문자열 함정 둘 ────────────────────────────────────────────
    //
    // 공식이 쓰는 문구가 금지 문구를 **포함**하는 경우라, `contains`로 세면
    // 교체한 공식 문구가 스스로 가드에 걸린다. 음성 전방탐색으로 가르고 그
    // 가름이 실제로 되는지 먼저 단정한다.
    final amazonQ = RegExp(r'Amazon Q(?![A-Za-z])');
    final agentCoreId = RegExp(r'AgentCore ID(?!entity)');

    test('대조군: `Amazon Q` 탐지가 공식 `Amazon Quick`에 걸리지 않는다', () {
      expect(amazonQ.hasMatch('예: Amazon Bedrock, Amazon Quick, Kiro'), isFalse);
      expect(amazonQ.hasMatch('예: Amazon Bedrock, Amazon Q, Amazon Quick'), isTrue);
    });

    test('대조군: `AgentCore ID` 탐지가 공식 `AgentCore Identity`에 걸리지 않는다', () {
      expect(agentCoreId.hasMatch('Amazon Bedrock AgentCore Identity, AgentCore의 정책'),
          isFalse);
      expect(agentCoreId.hasMatch('Amazon Bedrock AgentCore ID, AgentCore의 정책'),
          isTrue);
    });

    test('`Amazon Q` 단독이 없다', () {
      // ⚠️ 공식 가이드 **개정 표**는 Amazon Q를 범위 내 추가·1.3.4 예시로
      // 적지만 **본문에는 둘 다 없다**(공식 내부 어긋남 5계열 중 하나).
      // 본문을 정본으로 쓴다(D-06). 게다가 Q Developer는 2027-04-30 종료이고
      // Amazon Quick은 QuickSight의 개명이라 둘은 **다른 서비스**다(G-07).
      expect(amazonQ.hasMatch(raw), isFalse);
    });

    test('`AgentCore ID` 단독이 없다', () {
      expect(agentCoreId.hasMatch(raw), isFalse,
          reason: '공식 5.1.1은 AgentCore Identity다');
    });
  });
}
