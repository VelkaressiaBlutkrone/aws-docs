import { test } from 'node:test';
import assert from 'node:assert/strict';
import { resolveCert } from './review.mjs';
import {
  domainOfTaskId,
  bankScopeFlags,
  questionScopeFlags,
  buildPrescreen,
} from './prescreen.mjs';

const saa = resolveCert('saa');
const soa = resolveCert('soa');

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
  certCode: 'SAA-C03',
  domain: 1,
  questions: [q()],
  ...over,
});

test('domainOfTaskId: 정상 추출 / 형식 이상 null', () => {
  assert.equal(domainOfTaskId('saa-t3-9', saa), 3);
  assert.equal(domainOfTaskId('saa-t4-5', saa), 4);
  assert.equal(domainOfTaskId('clf-t1-1', saa), null); // 다른 자격증 접두
  assert.equal(domainOfTaskId('saa-x', saa), null);
  assert.equal(domainOfTaskId('', saa), null);
  assert.equal(domainOfTaskId(undefined, saa), null);
});

test('⚠️ domainOfTaskId: 도메인 범위는 자격증별이다 — SOA는 5개', () => {
  // 옛 SAA 전용 판은 `^saa-t([1-4])-\d+$` 였다. 4로 못 박으면 SOA 의 D5 Task
  // 20문항 중 60문항(t5-1~t5-4)이 "형식 이상"으로 오탐된다.
  assert.equal(soa.domains, 5);
  assert.equal(domainOfTaskId('soa-t5-4', soa), 5);
  assert.equal(domainOfTaskId('soa-t6-1', soa), null); // 범위 밖
  // 같은 taskId 를 4도메인 자격증으로 보면 범위 밖이다(접두가 달라 애초에 null).
  assert.equal(saa.domains, 4);
  assert.equal(domainOfTaskId('saa-t5-1', saa), null);
});

test('bankScopeFlags: 정상 뱅크는 빈 배열', () => {
  assert.deepEqual(bankScopeFlags(bank(), saa), []);
});

test('bankScopeFlags: domain 불일치 플래그', () => {
  assert.ok(bankScopeFlags(bank({ domain: 2 }), saa).some((f) => f.includes('domain')));
});

test('bankScopeFlags: taskId 형식 이상 플래그에 자격증·도메인 수가 들어간다', () => {
  const flags = bankScopeFlags(bank({ examGuideTaskId: 'saa-x' }), saa);
  assert.ok(flags.some((f) => f.includes('형식')));
  assert.ok(flags.some((f) => f.includes('saa-t{1-4}')));
  const soaFlags = bankScopeFlags(
    { examGuideTaskId: 'soa-x', certCode: 'SOA-C03', domain: 1, questions: [q()] },
    soa,
  );
  assert.ok(soaFlags.some((f) => f.includes('soa-t{1-5}')));
});

test('bankScopeFlags: certCode 불일치 플래그 / 미설정은 통과', () => {
  assert.ok(
    bankScopeFlags(bank({ certCode: 'SOA-C03' }), saa).some((f) => f.includes('certCode')),
  );
  const noCode = bank();
  delete noCode.certCode;
  assert.deepEqual(bankScopeFlags(noCode, saa), []);
});

test('bankScopeFlags: questions 비어있으면 플래그', () => {
  assert.ok(bankScopeFlags(bank({ questions: [] }), saa).some((f) => f.includes('questions')));
});

test('questionScopeFlags: 뱅크와 다른 examGuideTaskId면 플래그, 미설정이면 정상', () => {
  assert.ok(questionScopeFlags(q({ examGuideTaskId: 'saa-t2-1' }), 'saa-t1-1').length > 0);
  assert.deepEqual(questionScopeFlags(q(), 'saa-t1-1'), []);
});

test('buildPrescreen: 정상 뱅크 → flaggedCount 0, 문항 레코드 + cert 라벨 보유', () => {
  const pre = buildPrescreen(bank(), saa);
  assert.equal(pre.cert, 'SAA-C03');
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
  const pre = buildPrescreen(bank({ questions: [q({ options: ['a', 'b', 'c'] })] }), saa);
  assert.equal(pre.flaggedCount, 1);
  assert.ok(pre.questions[0].structuralFlags.some((f) => f.includes('options')));
});

test('buildPrescreen: 문항 examGuideTaskId 불일치는 scopeFlags + flaggedCount 반영', () => {
  const pre = buildPrescreen(bank({ questions: [q({ examGuideTaskId: 'saa-t2-2' })] }), saa);
  assert.equal(pre.flaggedCount, 1);
  assert.ok(pre.questions[0].scopeFlags.length > 0);
});

test('buildPrescreen: SOA D5 뱅크가 정상으로 통과한다(자격증 일반화 회귀 가드)', () => {
  const pre = buildPrescreen(
    {
      examGuideTaskId: 'soa-t5-4',
      certCode: 'SOA-C03',
      domain: 5,
      questions: [q({ id: 'soa-t5-4-q1', examGuideTaskId: 'soa-t5-4' })],
    },
    soa,
  );
  assert.equal(pre.cert, 'SOA-C03');
  assert.deepEqual(pre.bankFlags, []);
  assert.equal(pre.flaggedCount, 0);
});
