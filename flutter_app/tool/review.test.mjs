import { test } from 'node:test';
import assert from 'node:assert/strict';
import { questionFlags, taskAnswerSkew } from './review.mjs';

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

import { flipVerified, setQuestionCount } from './review.mjs';

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

import { renderHtml } from './review.mjs';

const sampleTask = {
  taskId: 'saa-t1-1', taskTitle: 'IAM', domain: 1,
  questions: [{
    id: 'saa-t1-1-q1', skill: 'IAM', difficulty: 'foundational',
    stem: '문제 본문', options: ['A', 'B', 'C', 'D'], correct: 1,
    explanation: '정답 해설', wrongExplanations: { '0': 'wa', '2': 'wc', '3': 'wd' },
    sources: [{ title: '공식', url: 'https://aws.amazon.com/x' }], verified: false,
  }],
};

test('renderHtml: stem·옵션·해설·출처 포함', () => {
  const html = renderHtml([sampleTask]);
  assert.ok(html.includes('문제 본문'));
  assert.ok(html.includes('정답 해설'));
  assert.ok(html.includes('https://aws.amazon.com/x'));
  assert.ok(html.startsWith('<!doctype html>') || html.startsWith('<!DOCTYPE html>'));
});

test('renderHtml: 정답 옵션에 correct 마킹 클래스', () => {
  const html = renderHtml([sampleTask]);
  assert.match(html, /class="opt correct"[^>]*>\s*B/);
});

test('renderHtml: 플래그 있는 문항은 배지 노출', () => {
  const bad = { ...sampleTask, questions: [{ ...sampleTask.questions[0], options: ['A', 'B', 'C'] }] };
  const html = renderHtml([bad]);
  assert.ok(html.includes('flag'));
});

test('renderHtml: 넘긴 label을 title·h1에 반영', () => {
  const html = renderHtml([sampleTask], 'MLA-C01');
  assert.match(html, /<title>[^<]*MLA-C01[^<]*<\/title>/);
  assert.match(html, /<h1>[^<]*MLA-C01[^<]*<\/h1>/);
});

test('renderHtml: label 없으면 자격증명을 박지 않는다', () => {
  const html = renderHtml([sampleTask]);
  assert.ok(!html.includes('SAA-C03'), 'SAA 하드코딩이 남아 있다');
  assert.match(html, /<title>[^<]*검수[^<]*<\/title>/);
});

// ── 자격증 레지스트리 ──────────────────────────────────────────────

import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { CERTS, resolveCert, addToAllowlist, appPath, questionFilePath } from './review.mjs';

test('resolveCert: mla는 dir·label·tests·flipAllowlist를 반환', () => {
  const cert = resolveCert('mla');
  assert.equal(cert.dir, 'assets/content/mla');
  assert.equal(cert.label, 'MLA-C01');
  assert.ok(cert.tests.includes('test/mla_questions_test.dart'));
  assert.equal(cert.flipAllowlist.file, 'test/mla_questions_test.dart');
  assert.equal(cert.flipAllowlist.symbol, 'flipApprovedTaskIds');
});

test('resolveCert: 모르는 코드는 throw', () => {
  assert.throws(() => resolveCert('nope'), /nope/);
});

test('CERTS: 자격증 5종이 등록돼 있다', () => {
  assert.deepEqual(Object.keys(CERTS).sort(), ['clf', 'dea', 'mla', 'saa', 'soa']);
});

test('CERTS: 각 dir가 실재하는 디렉터리다', () => {
  for (const [code, cert] of Object.entries(CERTS)) {
    assert.ok(existsSync(appPath(cert.dir)), `${code}: ${cert.dir} 없음`);
  }
});

test('CERTS: domains가 공식 시험 가이드의 도메인 수와 같다', () => {
  // ⚠️ 도메인 수를 4로 못 박으면 **SOA-C03의 D5 Task(t5-1~t5-4, 60문항)**가
  // 사전심사에서 "형식 이상"으로 오탐된다 — 옛 `saa_prescreen.mjs`의
  // `^saa-t([1-4])-\d+$`가 그랬다. 정본은 `assets/exam_guides/<label>.json`이므로
  // 레지스트리 값이 그것과 어긋나면 여기서 먼저 깨진다.
  for (const [code, cert] of Object.entries(CERTS)) {
    const guidePath = appPath(`assets/exam_guides/${cert.label}.json`);
    assert.ok(existsSync(guidePath), `${code}: ${cert.label}.json 없음`);
    const guide = JSON.parse(readFileSync(guidePath, 'utf8'));
    assert.equal(cert.domains, guide.domains.length,
      `${code}: domains ${cert.domains} ≠ 가이드 ${guide.domains.length}`);
  }
});

test('CERTS: 실제 문항 뱅크의 examGuideTaskId 도메인이 domains 범위 안이다', () => {
  // 레지스트리 값이 가이드와 같아도 콘텐츠가 그 범위를 넘으면 사전심사가 오탐한다.
  //
  // ⚠️ **파일명으로 보면 안 된다** — CLF만 `t1-1.questions.json`(접두 없음)이고
  // saa·soa·dea·mla는 `<cert>-t{D}-{n}.questions.json`이다(2026-10-29 실측).
  // 그래서 `questionFilePath`도 파일명 직접 매칭이 실패하면 뱅크의
  // `examGuideTaskId`로 다시 찾는다. 사전심사가 쓰는 것도 그 필드이므로
  // 여기서도 그것을 본다.
  for (const [code, cert] of Object.entries(CERTS)) {
    const files = readdirSync(appPath(cert.dir)).filter((f) => f.endsWith('.questions.json'));
    assert.ok(files.length > 0, `${code}: 문항 파일 없음`);
    for (const f of files) {
      const bank = JSON.parse(readFileSync(appPath(`${cert.dir}/${f}`), 'utf8'));
      const m = new RegExp(`^${code}-t(\\d+)-\\d+$`).exec(String(bank.examGuideTaskId ?? ''));
      assert.ok(m,
        `${code}: ${f}의 examGuideTaskId '${bank.examGuideTaskId}'가 ${code}-t{D}-{n} 형식이 아니다`);
      const d = Number(m[1]);
      assert.ok(d >= 1 && d <= cert.domains,
        `${code}: ${f}의 도메인 ${d}이 domains ${cert.domains} 범위 밖이다`);
      assert.equal(bank.domain, d,
        `${code}: ${f}의 domain ${bank.domain} ≠ taskId 도메인 ${d}`);
    }
  }
});

test('CERTS: tests에 적힌 테스트 파일이 실재한다', () => {
  // 없는 파일을 적어두면 flip 마지막 단계가 깨진다 — 기계로 잡는다.
  for (const [code, cert] of Object.entries(CERTS)) {
    assert.ok(cert.tests.length > 0, `${code}: tests 비어 있음`);
    for (const t of cert.tests) {
      assert.ok(existsSync(appPath(t)), `${code}: ${t} 없음`);
    }
  }
});

test('CERTS: flipAllowlist의 파일·심볼이 실재한다', () => {
  for (const [code, cert] of Object.entries(CERTS)) {
    if (!cert.flipAllowlist) continue;
    const { file, symbol } = cert.flipAllowlist;
    assert.ok(existsSync(appPath(file)), `${code}: ${file} 없음`);
    assert.match(readFileSync(appPath(file), 'utf8'), new RegExp(`const\\s+${symbol}\\s*=`),
      `${code}: ${file}에 ${symbol} 선언 없음`);
  }
});

test('addToAllowlist: 빈 집합에 첫 Task를 넣는다', () => {
  const src = '  const flipApprovedTaskIds = <String>{};\n';
  assert.equal(addToAllowlist(src, 'flipApprovedTaskIds', 'mla-t1-1'),
    "  const flipApprovedTaskIds = <String>{'mla-t1-1'};\n");
});

test('addToAllowlist: 기존 항목을 보존하고 뒤에 붙인다', () => {
  const src = "const flipApprovedTaskIds = <String>{'mla-t1-1'};";
  assert.equal(addToAllowlist(src, 'flipApprovedTaskIds', 'mla-t2-1'),
    "const flipApprovedTaskIds = <String>{'mla-t1-1', 'mla-t2-1'};");
});

test('addToAllowlist: 이미 있으면 그대로 둔다(중복 추가 금지)', () => {
  const src = "const flipApprovedTaskIds = <String>{'mla-t1-1', 'mla-t2-1'};";
  assert.equal(addToAllowlist(src, 'flipApprovedTaskIds', 'mla-t2-1'), src);
});

test('addToAllowlist: 여러 줄 집합의 주석·들여쓰기를 보존한다', () => {
  const src = "const flipApprovedTaskIds = <String>{\n    // D1 검수 완료\n    'mla-t1-1',\n  };";
  const out = addToAllowlist(src, 'flipApprovedTaskIds', 'mla-t1-2');
  assert.ok(out.includes('// D1 검수 완료'));
  assert.ok(out.includes("'mla-t1-1'"));
  assert.ok(out.includes("'mla-t1-2'"));
});

test('addToAllowlist: symbol을 못 찾으면 throw', () => {
  assert.throws(() => addToAllowlist('// empty', 'flipApprovedTaskIds', 'mla-t1-1'));
});

test('questionFilePath: 파일명 규칙이 다른 clf도 taskId로 찾는다', () => {
  // clf는 't1-1.questions.json'인데 content_index·examGuideTaskId는 'clf-t1-1'이다.
  const clf = questionFilePath(resolveCert('clf'), 'clf-t1-1');
  assert.match(clf, /[\\/]t1-1\.questions\.json$/);
  const mla = questionFilePath(resolveCert('mla'), 'mla-t1-1');
  assert.match(mla, /[\\/]mla-t1-1\.questions\.json$/);
});

test('questionFilePath: 없는 taskId는 throw', () => {
  assert.throws(() => questionFilePath(resolveCert('mla'), 'mla-t9-9'), /mla-t9-9/);
});

test('addToAllowlist: 실제 mla_questions_test.dart의 선언 스타일에 적용된다', () => {
  // 선언 스타일이 바뀌면(한 줄 → 여러 줄 등) 여기서 먼저 깨진다.
  //
  // ⚠️ **목록의 현재 내용을 박지 않는다.** 전에는 결과가
  // `<String>{'mla-t1-1'}`과 같기를 요구했는데, 그것은 목록이 비어 있던
  // 시점의 상태였다 — 2026-10-29에 사람이 MLA 12 Task를 전부 flip하자
  // 이 테스트가 레드가 됐고, node 테스트가 CI에 없어 **조용히** 레드로 남아
  // 있었다(2026-10-29 실측). 상태가 아니라 **동작**을 본다: 기존 항목을
  // 보존하면서 새 Task 하나를 뒤에 붙이는가.
  const { file, symbol } = resolveCert('mla').flipAllowlist;
  const src = readFileSync(appPath(file), 'utf8');
  const decl = new RegExp(`const\\s+${symbol}\\s*=\\s*<String>\\{([\\s\\S]*?)\\};`);
  const before = decl.exec(src);
  assert.ok(before, `${file}에서 ${symbol} 선언을 찾지 못했다 — 선언 스타일이 바뀌었다`);

  const fresh = 'mla-t9-9'; // 실재하지 않는 Task — 목록 내용과 무관하게 새 항목이다
  const after = decl.exec(addToAllowlist(src, symbol, fresh));
  assert.ok(after, '적용 결과에서 선언을 다시 찾지 못했다');
  const kept = before[1].replace(/\s*,?\s*$/, '');
  assert.equal(after[1], kept.trim() ? `${kept}, '${fresh}'` : `'${fresh}'`);
});
