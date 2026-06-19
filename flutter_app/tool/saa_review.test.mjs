import { test } from 'node:test';
import assert from 'node:assert/strict';
import { questionFlags, taskAnswerSkew } from './saa_review.mjs';

const ok = {
  options: ['a', 'b', 'c', 'd'], correct: 1,
  wrongExplanations: { '0': 'x', '2': 'y', '3': 'z' },
  sources: [{ title: 't', url: 'https://aws.amazon.com/x' }],
};

test('questionFlags: 정상 문항은 빈 배열', () => {
  assert.deepEqual(questionFlags(ok), []);
});

test('questionFlags: options≠4', () => {
  assert.ok(questionFlags({ ...ok, options: ['a', 'b', 'c'] }).some((f) => f.includes('options')));
});

test('questionFlags: correct 범위 밖', () => {
  assert.ok(questionFlags({ ...ok, correct: 4 }).some((f) => f.includes('correct')));
});

test('questionFlags: wrongExplanations 키 불일치(누락)', () => {
  assert.ok(questionFlags({ ...ok, wrongExplanations: { '0': 'x', '2': 'y' } })
    .some((f) => f.includes('wrongExplanations')));
});

test('questionFlags: sources 없음', () => {
  assert.ok(questionFlags({ ...ok, sources: [] }).some((f) => f.includes('sources')));
});

test('questionFlags: sources url non-http', () => {
  assert.ok(questionFlags({ ...ok, sources: [{ url: 'ftp://x' }] }).some((f) => f.includes('sources')));
});

test('taskAnswerSkew: 60% 미만이면 null', () => {
  const qs = [0, 1, 2, 3, 0, 1, 2, 3, 0, 1].map((c) => ({ correct: c }));
  assert.equal(taskAnswerSkew(qs), null);
});

test('taskAnswerSkew: 한 인덱스 ≥60%면 객체', () => {
  const qs = Array.from({ length: 10 }, (_, i) => ({ correct: i < 7 ? 0 : 1 }));
  const skew = taskAnswerSkew(qs);
  assert.equal(skew.index, 0);
  assert.equal(skew.count, 7);
});

import { flipVerified, setQuestionCount } from './saa_review.mjs';

test('flipVerified: verified false→true, 포맷 보존', () => {
  const src = '{\n  "questions": [\n    { "id": "q1", "verified": false },\n    { "id": "q2", "verified": false }\n  ]\n}\n';
  const out = flipVerified(src);
  assert.ok(!out.includes('"verified": false'));
  assert.equal((out.match(/"verified": true/g) || []).length, 2);
  assert.ok(out.includes('"id": "q1"'));
});

test('setQuestionCount: 해당 taskId 블록의 questionCount만 교체', () => {
  const dart = `
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t1-1',
      questionsAsset: 'assets/content/saa/saa-t1-1.questions.json',
      questionCount: 0,
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t1-2',
      questionCount: 0,
    ),`;
  const out = setQuestionCount(dart, 'saa-t1-1', 15);
  assert.match(out, /taskId: 'saa-t1-1',[\s\S]*?questionCount: 15,/);
  assert.match(out, /taskId: 'saa-t1-2',[\s\S]*?questionCount: 0,/);
});

test('setQuestionCount: 미발견 taskId는 throw', () => {
  assert.throws(() => setQuestionCount('// empty', 'saa-t9-9', 15));
});
