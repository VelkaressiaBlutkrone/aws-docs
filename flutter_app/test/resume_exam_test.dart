import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/history_store.dart' show MemoryBackend;
import 'package:aws_docs/data/resume_exam.dart';
import 'package:aws_docs/models/exam_snapshot.dart';
import 'package:aws_docs/models/question.dart';

/// UX-4 가드 — 진행 중인 모의고사를 홈·자격증 상세에서 되찾는다.
///
/// 리뷰(2026-09-22 §UX-4): `ExamSessionStore` 사용처가 시험 페이지 2곳뿐이라, 탭을 닫은
/// 학습자는 세션이 남아 있는지 모른 채 처음부터 시작하거나 잊었다.

Question _q(String id) => Question(
      id: id,
      examGuideTaskId: 'clf-t1-1',
      stem: '지문 $id',
      options: const ['A', 'B'],
      correct: 0,
      explanation: 'e',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
    );

ExamSnapshot _snap(
  String examId, {
  required String startedAtIso,
  int durationSec = 5400,
  String certId = 'CLF-C02',
}) =>
    ExamSnapshot(
      examId: examId,
      certId: certId,
      taskId: examId.replaceFirst('exam:', ''),
      nonce: 'n1',
      startedAtIso: startedAtIso,
      durationSec: durationSec,
      questions: [_q('q1'), _q('q2')],
    );

final _t0 = DateTime.utc(2026, 10, 30, 9, 0, 0);
DateTime _at(int sec) => _t0.add(Duration(seconds: sec));

void main() {
  group('remainingExamLabel', () {
    test('한 시간 이상이면 시·분으로 읽는다 — 카드는 흘깃 보는 곳이다', () {
      expect(remainingExamLabel(5370), '남은 1시간 29분');
    });

    test('한 시간 미만이면 분만', () {
      expect(remainingExamLabel(42 * 60 + 10), '남은 42분');
    });

    test('정시는 분을 적지 않는다', () {
      expect(remainingExamLabel(7200), '남은 2시간');
    });

    test('1분 미만은 숫자로 속이지 않는다', () {
      expect(remainingExamLabel(30), '남은 1분 미만');
    });
  });

  group('resumableExamsForCert', () {
    test('통합·약점 둘 다 찾고 선언 순서(통합 먼저)로 돌려준다', () {
      final b = MemoryBackend();
      final s = ExamSessionStore(backend: b)
        ..saveSnapshot(
            _snap('exam:CLF-C02-mock', startedAtIso: _t0.toIso8601String()))
        ..saveSnapshot(
            _snap('exam:CLF-C02-weak', startedAtIso: _t0.toIso8601String()));
      expect(s.loadSnapshot('exam:CLF-C02-mock'), isNotNull);

      final found = resumableExamsForCert('CLF-C02',
          backend: b, now: () => _at(600));

      expect(found.map((e) => e.examId),
          ['exam:CLF-C02-mock', 'exam:CLF-C02-weak']);
      expect(found.first.weighted, isFalse);
      expect(found.last.weighted, isTrue);
      expect(found.first.remainingSec, 4800); // 5400 - 600
      expect(found.first.route, '/cert/CLF-C02/exam');
      expect(found.last.route, '/cert/CLF-C02/exam/weak');
    });

    test('⚠️ 만료 세션은 돌려주지 않는다 — "남은 0분" 카드를 띄우면 거짓말이다', () {
      // clearExpired는 시험 페이지 진입에서만 돈다(cert_exam_page). 홈·상세는 그
      // 경로를 타지 않으므로 남은 시간을 직접 봐야 한다.
      final b = MemoryBackend();
      ExamSessionStore(backend: b).saveSnapshot(
          _snap('exam:CLF-C02-mock', startedAtIso: _t0.toIso8601String()));

      expect(
        resumableExamsForCert('CLF-C02', backend: b, now: () => _at(5400)),
        isEmpty,
      );
      expect(
        resumableExamsForCert('CLF-C02', backend: b, now: () => _at(5399))
            .single
            .remainingSec,
        1,
      );
    });

    test('⚠️ 시작 시각을 읽을 수 없으면 남긴다 — 판단 불가를 숨김 근거로 쓰지 않는다', () {
      final b = MemoryBackend();
      ExamSessionStore(backend: b)
          .saveSnapshot(_snap('exam:CLF-C02-mock', startedAtIso: '엉터리'));

      final found =
          resumableExamsForCert('CLF-C02', backend: b, now: () => _at(600));
      expect(found.single.remainingSec, isNull,
          reason: '남은 시간을 모르면 라벨에서 생략한다');
    });

    test('세션이 없으면 빈 목록', () {
      expect(
        resumableExamsForCert('CLF-C02',
            backend: MemoryBackend(), now: () => _at(0)),
        isEmpty,
      );
    });

    test('Task 단위 세션은 보지 않는다 — 홈에서 전 자격증을 돌아도 조회가 2키로 묶인다', () {
      final b = MemoryBackend();
      ExamSessionStore(backend: b).saveSnapshot(
          _snap('exam:clf-t1-1', startedAtIso: _t0.toIso8601String()));

      expect(
        resumableExamsForCert('CLF-C02', backend: b, now: () => _at(600)),
        isEmpty,
      );
    });
  });

  group('resumableExamsAll', () {
    test('콘텐츠가 있는 자격증만 돌고 자격증 선언 순서를 지킨다', () {
      final b = MemoryBackend();
      ExamSessionStore(backend: b)
        ..saveSnapshot(
            _snap('exam:SAA-C03-mock', startedAtIso: _t0.toIso8601String()))
        ..saveSnapshot(
            _snap('exam:CLF-C02-mock', startedAtIso: _t0.toIso8601String()))
        // 콘텐츠가 없는 자격증 코드의 세션은 홈에서 보이지 않는다(열 수 없는 카드).
        ..saveSnapshot(
            _snap('exam:ZZZ-X00-mock', startedAtIso: _t0.toIso8601String()));

      final found = resumableExamsAll(backend: b, now: () => _at(600));
      final codes = found.map((e) => e.certCode).toList();

      expect(codes, contains('CLF-C02'));
      expect(codes, contains('SAA-C03'));
      expect(codes, isNot(contains('ZZZ-X00')));
      expect(codes.indexOf('CLF-C02'), lessThan(codes.indexOf('SAA-C03')),
          reason: 'certifications 선언 순서(CLF가 먼저)를 따른다');
    });
  });
}
