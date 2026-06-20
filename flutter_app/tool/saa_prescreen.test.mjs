import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  domainOfTaskId,
  bankScopeFlags,
  questionScopeFlags,
  buildPrescreen,
} from './saa_prescreen.mjs';

const q = (over = {}) => ({
  id: 'saa-t1-1-q1',
  options: ['a', 'b', 'c', 'd'],
  correct: 1,
  wrongExplanations: { '0': 'x', '2': 'y', '3': 'z' },
  sources: [{ title: 't', url: 'https://aws.amazon.com/x' }],
  verified: false,
  skill: 'IAM',
  section: 'iam',
  ...over,
});

const bank = (over = {}) => ({
  examGuideTaskId: 'saa-t1-1',
  taskTitle: 'IAM',
  domain: 1,
  questions: [q()],
  ...over,
});

test('domainOfTaskId: 정상 추출 / 형식 이상 null', () => {
  assert.equal(domainOfTaskId('saa-t3-9'), 3);
  assert.equal(domainOfTaskId('saa-t4-5'), 4);
  assert.equal(domainOfTaskId('clf-t1-1'), null);
  assert.equal(domainOfTaskId('saa-t5-1'), null); // 도메인 5 없음(SAA는 1~4)
  assert.equal(domainOfTaskId(''), null);
});

test('bankScopeFlags: 정상 뱅크는 빈 배열', () => {
  assert.deepEqual(bankScopeFlags(bank()), []);
});

test('bankScopeFlags: domain 불일치 플래그', () => {
  assert.ok(bankScopeFlags(bank({ domain: 2 })).some((f) => f.includes('domain')));
});

test('bankScopeFlags: taskId 형식 이상 플래그', () => {
  assert.ok(bankScopeFlags(bank({ examGuideTaskId: 'saa-x' })).some((f) => f.includes('형식')));
});

test('bankScopeFlags: questions 비어있으면 플래그', () => {
  assert.ok(bankScopeFlags(bank({ questions: [] })).some((f) => f.includes('questions')));
});

test('questionScopeFlags: 뱅크와 다른 examGuideTaskId면 플래그, 미설정이면 정상', () => {
  assert.ok(questionScopeFlags(q({ examGuideTaskId: 'saa-t2-1' }), 'saa-t1-1').length > 0);
  assert.deepEqual(questionScopeFlags(q(), 'saa-t1-1'), []);
});

test('buildPrescreen: 정상 뱅크 → flaggedCount 0, 문항 레코드 보유', () => {
  const pre = buildPrescreen(bank());
  assert.equal(pre.taskId, 'saa-t1-1');
  assert.equal(pre.domain, 1);
  assert.equal(pre.count, 1);
  assert.equal(pre.flaggedCount, 0);
  assert.deepEqual(pre.bankFlags, []);
  assert.equal(pre.questions[0].id, 'saa-t1-1-q1');
  assert.deepEqual(pre.questions[0].structuralFlags, []);
  assert.deepEqual(pre.questions[0].scopeFlags, []);
});

test('buildPrescreen: 구조 결함 문항은 structuralFlags + flaggedCount 반영', () => {
  const pre = buildPrescreen(bank({ questions: [q({ options: ['a', 'b', 'c'] })] }));
  assert.equal(pre.flaggedCount, 1);
  assert.ok(pre.questions[0].structuralFlags.some((f) => f.includes('options')));
});

test('buildPrescreen: 문항 examGuideTaskId 불일치는 scopeFlags + flaggedCount 반영', () => {
  const pre = buildPrescreen(bank({ questions: [q({ examGuideTaskId: 'saa-t2-2' })] }));
  assert.equal(pre.flaggedCount, 1);
  assert.ok(pre.questions[0].scopeFlags.length > 0);
});
