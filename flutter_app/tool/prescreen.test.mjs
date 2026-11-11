import { test } from 'node:test';
import assert from 'node:assert/strict';
import { resolveCert } from './review.mjs';
import {
  domainOfTaskId,
  bankScopeFlags,
  questionScopeFlags,
  buildPrescreen,
  qualityFlags,
  duplicatePairs,
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

// ════════════════════════════════════════════════════════════════════════
// 품질 신호(2026-11-11 외부 검수 보고 P-1)
//
// ⚠️⚠️ 이 신호들은 **결함 단정이 아니다.** `flaggedCount` 와 분리돼 있고 각
// 테스트가 **거짓 양성을 통과시키는지**까지 고정한다 — 신호가 과민하면 사람이
// 읽을 후보로서 쓸모가 없어진다.

test('qualityFlags: 정상 문항은 신호 없음(대조군)', () => {
  const ok = q({
    stem: '어떤 구성을 선택합니까?',
    options: ['가장 긴 오답 보기를 여기에 둔다 열두 글자', 'b 보기', 'c 보기', 'd 보기'],
    correct: 1,
    explanation: '짧은 해설입니다.',
    wrongExplanations: { 0: 'x', 2: 'y', 3: 'z' },
  });
  assert.deepEqual(qualityFlags(ok), []);
});

test('qualityFlags: length-cue 는 정답 > 최장 오답 × 1.3 에서만 걸린다', () => {
  // 1.4배 — 10 × 1.3 = 13 < 14 이므로 걸린다.
  const over = q({ options: ['a'.repeat(10), 'b'.repeat(14), 'c', 'd'], correct: 1 });
  assert.ok(qualityFlags(over).some((f) => f.startsWith('length-cue')));
  // 1.2배 — 12 < 13 이므로 걸리지 않는다(임계 아래).
  const under = q({ options: ['a'.repeat(10), 'b'.repeat(12), 'c', 'd'], correct: 1 });
  assert.deepEqual(
    qualityFlags(under).filter((f) => f.startsWith('length-cue')),
    [],
    '정답이 조금 더 긴 것만으로는 신호가 아니다 — 그러면 거의 전 문항이 걸린다',
  );
});

test('qualityFlags: length-cue 수치가 메시지에 들어간다', () => {
  const cue = q({ options: ['a'.repeat(10), 'b'.repeat(40), 'c', 'd'], correct: 1 });
  const f = qualityFlags(cue).find((x) => x.startsWith('length-cue'));
  assert.ok(f, '정답 40자 > 최장 오답 10자 × 1.3');
  assert.match(f, /정답 40자/);
  assert.match(f, /최장 오답 10자/);
  // 경계: 정확히 1.3배면 걸리지 않는다(> 이지 >= 가 아니다).
  const edge = q({ options: ['a'.repeat(10), 'b'.repeat(13), 'c', 'd'], correct: 1 });
  assert.deepEqual(qualityFlags(edge).filter((x) => x.startsWith('length-cue')), []);
});

test('qualityFlags: meta-phrasing 은 지문·정답만 본다(해설의 출처 귀속은 정당하다)', () => {
  const inAsked = q({ stem: '공식 서술로 올바른 것은?', options: ['a', 'b', 'c', 'd'] });
  assert.ok(qualityFlags(inAsked).some((f) => f.startsWith('meta-phrasing')));
  const inExplanation = q({
    stem: '어떤 구성을 선택합니까?',
    explanation: '공식 문서가 그렇게 적습니다.',
  });
  assert.deepEqual(
    qualityFlags(inExplanation).filter((f) => f.startsWith('meta-phrasing')),
    [],
    '해설에서 출처를 귀속하는 것은 정당하다 — 세면 거의 전 문항이 걸린다',
  );
});

test('qualityFlags: authoring-memo 는 해설·오답 근거를 본다', () => {
  const memo = q({ explanation: '옛 교재가 거꾸로 적는 자리입니다.' });
  const f = qualityFlags(memo).find((x) => x.startsWith('authoring-memo'));
  assert.ok(f);
  assert.match(f, /교재/);
  const inWrong = q({ wrongExplanations: { 0: '이 점이 자주 출제됩니다.', 2: 'y', 3: 'z' } });
  assert.ok(qualityFlags(inWrong).some((x) => x.startsWith('authoring-memo')));
});

test('⚠️ qualityFlags: `자리` 는 일부러 넣지 않았다(정상 용례가 섞인다)', () => {
  // 2026-11-11 실측 — SCS 12문항이 걸리는데 그중 결함은 둘뿐이었다.
  const normal = q({ explanation: '절차 표준화와 중복 축소가 그 자리입니다.' });
  assert.deepEqual(
    qualityFlags(normal).filter((f) => f.startsWith('authoring-memo')),
    [],
  );
});

test('qualityFlags: explanation-long 은 400자 초과에서 걸린다', () => {
  assert.deepEqual(
    qualityFlags(q({ explanation: '가'.repeat(400) })).filter((f) =>
      f.startsWith('explanation-long'),
    ),
    [],
    '400자는 경계이고 초과가 아니다',
  );
  const over = qualityFlags(q({ explanation: '가'.repeat(401) }));
  assert.ok(over.some((f) => f.startsWith('explanation-long')));
});

test('duplicatePairs: 출처를 공유하지 않으면 보지 않는다', () => {
  const a = q({ id: 'x-q1', options: ['같은 정답 문구입니다', 'b', 'c', 'd'], correct: 0,
    sources: [{ title: 't', url: 'https://example.invalid/a' }] });
  const b = q({ id: 'x-q2', options: ['같은 정답 문구입니다', 'b', 'c', 'd'], correct: 0,
    sources: [{ title: 't', url: 'https://example.invalid/b' }] });
  assert.deepEqual(duplicatePairs([a, b]), []);
});

test('duplicatePairs: 출처를 공유하고 정답이 같으면 후보 + identicalAnswer', () => {
  const src = [{ title: 't', url: 'https://example.invalid/same' }];
  const a = q({ id: 'x-q1', options: ['안정성 Reliability', 'b', 'c', 'd'], correct: 0, sources: src });
  const b = q({ id: 'x-q2', options: ['안정성 Reliability', 'b', 'c', 'd'], correct: 0, sources: src });
  const pairs = duplicatePairs([a, b]);
  assert.equal(pairs.length, 1);
  assert.equal(pairs[0].jaccard, 1);
  assert.equal(pairs[0].identicalAnswer, true);
  // ⚠️ 정답이 짧으면 자카드가 과민하다 — 토큰 수를 함께 남긴다.
  assert.deepEqual(pairs[0].tokens, [2, 2]);
});

test('⚠️ duplicatePairs: 지표는 하한이다 — 다르게 쓴 같은 사실은 임계 아래로 빠진다', () => {
  const src = [{ title: 't', url: 'https://example.invalid/same' }];
  const a = q({ id: 'x-q1', correct: 0, sources: src,
    options: ['재무 가치 분류에 해당합니다', 'b', 'c', 'd'] });
  const b = q({ id: 'x-q2', correct: 0, sources: src,
    options: ['비즈니스 성과 지표로 묶입니다', 'b', 'c', 'd'] });
  assert.deepEqual(duplicatePairs([a, b]), [],
    '2026-11-06 AIF 에서 6쌍 중 2쌍이 이렇게 임계 아래였다 — 사람이 읽어야 한다');
});

test('buildPrescreen: 품질 신호가 flaggedCount 를 오염시키지 않는다', () => {
  // ⚠️⚠️ 이 분리가 이 배치의 설계다 — `flaggedCount` 는 「구조·정합성 결함」으로
  // 쓰여 왔고 「SCS 240문항 플래그 0건」처럼 측정 기록의 기준이다.
  const cue = q({ options: ['a'.repeat(10), 'b'.repeat(40), 'c', 'd'], correct: 1 });
  const pre = buildPrescreen(bank({ questions: [cue] }), saa);
  assert.equal(pre.flaggedCount, 0, '품질 신호는 결함 수에 들어가지 않는다');
  assert.equal(pre.qualitySignalCount, 1);
  assert.ok(pre.questions[0].qualityFlags.length > 0);
  assert.ok(Array.isArray(pre.duplicateCandidates));
});
