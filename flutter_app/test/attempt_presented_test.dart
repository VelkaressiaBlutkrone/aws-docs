import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/attempt_presented.dart';

void main() {
  test('단일 Task examId → taskId', () {
    expect(taskFromExamId('practice:clf-t2-1'), 'clf-t2-1');
    expect(taskFromExamId('exam:clf-t2-1'), 'clf-t2-1');
    expect(taskFromExamId('review:clf-t2-1'), 'clf-t2-1');
  });

  test('집계 시험(-mock/-weak) → null', () {
    expect(taskFromExamId('exam:CLF-C02-mock'), isNull);
    expect(taskFromExamId('exam:CLF-C02-weak'), isNull);
  });

  test('구분자 없음/빈 값 → null', () {
    expect(taskFromExamId('nocolon'), isNull);
    expect(taskFromExamId('exam:'), isNull);
  });
}
