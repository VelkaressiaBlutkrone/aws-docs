// 문항 직렬화 라운드트립 가드(Task 1).
//
// 스냅샷 설계(`docs/superpowers/specs/2026-10-24-exam-session-snapshot-design.md`)는
// 출제 문항을 통째로 세션에 저장한다. 그러려면 `Question`·`StudySource`에 `toJson`이
// 있어야 하는데 지금은 `fromJson`만 있다 — 이 파일이 그 왕복을 고정한다.
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/models/study_content.dart';

Question _q({bool verified = true}) => Question(
      id: 'q1',
      examGuideTaskId: 'clf-t2-3',
      skill: '최소 권한',
      section: 'iam',
      difficulty: 'medium',
      stem: '루트 전용 작업은?',
      options: const ['EC2 시작', '계정 해지'],
      correct: 1,
      explanation: '계정 해지는 루트 전용.',
      wrongExplanations: const {0: 'EC2는 일상.'},
      sources: const [
        StudySource(title: 'IAM', url: 'https://docs.aws.amazon.com/iam/'),
      ],
      verified: verified,
    );

void main() {
  test('Question 라운드트립: 모든 필드 보존', () {
    final q = _q();
    final back = Question.fromJson(q.toJson());
    expect(back.id, q.id);
    expect(back.examGuideTaskId, q.examGuideTaskId);
    expect(back.skill, q.skill);
    expect(back.section, q.section);
    expect(back.difficulty, q.difficulty);
    expect(back.stem, q.stem);
    expect(back.options, q.options);
    expect(back.correct, q.correct);
    expect(back.explanation, q.explanation);
    expect(back.wrongExplanations, q.wrongExplanations); // int 키 복원
    expect(back.sources.single.title, q.sources.single.title);
    expect(back.sources.single.url, q.sources.single.url);
    expect(back.verified, isTrue);
  });

  test('verified:false도 toJson/fromJson에서 보존된다', () {
    // 스냅샷은 철회 문항을 그대로 들고 가야 하므로 이 플래그가 살아야 한다(설계 §4.2).
    final back = Question.fromJson(_q(verified: false).toJson());
    expect(back.verified, isFalse);
  });

  test('StudySource 라운드트립', () {
    const s = StudySource(title: 'EC2', url: 'https://aws.amazon.com/ec2/');
    final back = StudySource.fromJson(s.toJson());
    expect(back.title, s.title);
    expect(back.url, s.url);
  });
}
