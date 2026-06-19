# SAA 검수 전용 뷰 (saa_review 도구) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** node 도구 `tool/saa_review.mjs`로 SAA 360문항(verified:false 드래프트)을 검수용 HTML로 읽고, Task 단위로 `verified:true` flip + content_index 동기화한다.

**Architecture:** 순수 함수(`questionFlags`·`taskAnswerSkew`·`flipVerified`·`setQuestionCount`·`renderHtml`)를 `saa_review.mjs`에 export하고 `node:test`로 단위 검증한다. 얇은 `main()`이 argv를 디스패치해 fs IO(에셋 읽기·HTML 쓰기·flip)를 담당하며 `import.meta.url` 가드로 직접 실행 시에만 동작한다.

**Tech Stack:** Node.js ESM(`.mjs`, `verify_splash.mjs` 선례), `node:test`+`node:assert` 내장 러너, 기존 Dart `saa_questions_test`(회귀 가드).

## Global Constraints

- 모든 node 명령은 **`flutter_app/` 기준**(cwd=flutter_app). 에셋=`assets/content/saa/`, content_index=`lib/data/content_index.dart`, 출력=`build/saa_review/`.
- **철칙: AI flip 금지** — 도구는 사용자가 검수 후 직접 실행한다. flip 커밋은 이 plan 범위 밖(도구만 만든다).
- TDD(절대조건 2): 순수 함수는 `node:test` 실패 테스트 선작성 → 최소 구현.
- 기존 `test/saa_questions_test.dart`(Dart 구조·밀도 가드)는 변경하지 않는다(회귀 가드 유지).
- flip은 원본 JSON 포맷을 보존한다(정규식 치환, `JSON.stringify` 재포맷 금지 — 불필요한 diff 방지).

## File Structure

- Create: `flutter_app/tool/saa_review.mjs` — 순수 함수 5종 export + `main()` CLI(build·flip 디스패치)
- Create: `flutter_app/tool/saa_review.test.mjs` — `node:test` 단위 테스트
- (flip 실행 시 수정 대상, 이 plan에선 미변경) `assets/content/saa/*.questions.json` · `lib/data/content_index.dart`

---

### Task 1: 기계적 플래그 순수 함수

**Files:**
- Create: `flutter_app/tool/saa_review.mjs`
- Create: `flutter_app/tool/saa_review.test.mjs`

**Interfaces:**
- Produces:
  - `questionFlags(q)` → `string[]` — 문항 1개의 구조 플래그(빈 배열=정상)
  - `taskAnswerSkew(questions)` → `{index, count, ratio}|null` — 정답 인덱스 ≥60% 쏠림이면 객체, 아니면 null

- [ ] **Step 1: 실패 테스트 작성** — `tool/saa_review.test.mjs`:

```js
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
```

- [ ] **Step 2: 실패 확인** — Run: `cd flutter_app && node --test tool/saa_review.test.mjs`. Expected: FAIL(`saa_review.mjs` 없음 / export 미정의).

- [ ] **Step 3: 최소 구현** — `tool/saa_review.mjs` 생성:

```js
// SAA 문항 검수 도구 — 읽기 HTML 뷰어 + Task 단위 flip CLI.
// 순수 함수는 export(테스트용), main()은 import.meta.url 가드로 직접 실행 시만.

/** 문항 1개의 기계적 구조 플래그(빈 배열=정상). 품질 판단 아님. */
export function questionFlags(q) {
  const flags = [];
  const opts = Array.isArray(q.options) ? q.options : [];
  if (opts.length !== 4) flags.push(`options ${opts.length}개(≠4)`);
  if (typeof q.correct !== 'number' || q.correct < 0 || q.correct > 3) {
    flags.push(`correct ${q.correct} 범위 밖`);
  }
  const expected = [0, 1, 2, 3].filter((i) => i !== q.correct).map(String);
  const actual = Object.keys(q.wrongExplanations || {});
  const norm = (a) => [...a].sort().join(',');
  if (norm(expected) !== norm(actual)) {
    flags.push(`wrongExplanations 키 [${norm(actual)}] ≠ [${norm(expected)}]`);
  }
  const sources = Array.isArray(q.sources) ? q.sources : [];
  if (sources.length === 0) flags.push('sources 없음');
  else if (sources.some((s) => !/^https?:\/\//.test((s && s.url) || ''))) {
    flags.push('sources url이 http(s) 아님');
  }
  return flags;
}

/** Task의 정답 인덱스 쏠림(한 인덱스 ≥60%)이면 {index,count,ratio}, 아니면 null. */
export function taskAnswerSkew(questions) {
  const counts = [0, 0, 0, 0];
  for (const q of questions) {
    if (typeof q.correct === 'number' && q.correct >= 0 && q.correct <= 3) counts[q.correct]++;
  }
  const total = questions.length;
  let maxIdx = 0;
  for (let i = 1; i < 4; i++) if (counts[i] > counts[maxIdx]) maxIdx = i;
  const ratio = total ? counts[maxIdx] / total : 0;
  return ratio >= 0.6 ? { index: maxIdx, count: counts[maxIdx], ratio } : null;
}
```

- [ ] **Step 4: 통과 확인** — Run: `cd flutter_app && node --test tool/saa_review.test.mjs`. Expected: PASS(8 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/saa_review.mjs flutter_app/tool/saa_review.test.mjs
git commit -m "feat(saa-review): 기계적 플래그 순수 함수(questionFlags·taskAnswerSkew)"
```

---

### Task 2: flip 순수 변환 함수

**Files:**
- Modify: `flutter_app/tool/saa_review.mjs`
- Modify: `flutter_app/tool/saa_review.test.mjs`

**Interfaces:**
- Produces:
  - `flipVerified(jsonText)` → `string` — `"verified": false`를 모두 `true`로(포맷 보존)
  - `setQuestionCount(dartText, taskId, count)` → `string` — content_index의 그 taskId ContentEntry `questionCount` 교체(미발견 시 throw)

- [ ] **Step 1: 실패 테스트 추가** — `tool/saa_review.test.mjs`에 추가:

```js
import { flipVerified, setQuestionCount } from './saa_review.mjs';

test('flipVerified: verified false→true, 포맷 보존', () => {
  const src = '{\n  "questions": [\n    { "id": "q1", "verified": false },\n    { "id": "q2", "verified": false }\n  ]\n}\n';
  const out = flipVerified(src);
  assert.ok(!out.includes('"verified": false'));
  assert.equal((out.match(/"verified": true/g) || []).length, 2);
  assert.ok(out.includes('"id": "q1"')); // 나머지 포맷 그대로
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
  assert.match(out, /taskId: 'saa-t1-2',[\s\S]*?questionCount: 0,/); // 다른 Task 불변
});

test('setQuestionCount: 미발견 taskId는 throw', () => {
  assert.throws(() => setQuestionCount('// empty', 'saa-t9-9', 15));
});
```

- [ ] **Step 2: 실패 확인** — Run: `cd flutter_app && node --test tool/saa_review.test.mjs`. Expected: FAIL(`flipVerified`/`setQuestionCount` 미정의).

- [ ] **Step 3: 최소 구현** — `tool/saa_review.mjs`에 추가:

```js
/** "verified": false → true 전부(정규식 치환으로 원본 포맷 보존). */
export function flipVerified(jsonText) {
  return jsonText.replace(/"verified":\s*false/g, '"verified": true');
}

/** content_index.dart에서 그 taskId ContentEntry의 questionCount를 count로 교체. */
export function setQuestionCount(dartText, taskId, count) {
  const re = new RegExp(`(taskId: '${taskId}',[\\s\\S]*?questionCount: )\\d+`);
  if (!re.test(dartText)) throw new Error(`content_index에서 taskId '${taskId}' 미발견`);
  return dartText.replace(re, `$1${count}`);
}
```

- [ ] **Step 4: 통과 확인** — Run: `cd flutter_app && node --test tool/saa_review.test.mjs`. Expected: PASS(11 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/saa_review.mjs flutter_app/tool/saa_review.test.mjs
git commit -m "feat(saa-review): flip 순수 변환(flipVerified·setQuestionCount)"
```

---

### Task 3: HTML 렌더 순수 함수

**Files:**
- Modify: `flutter_app/tool/saa_review.mjs`
- Modify: `flutter_app/tool/saa_review.test.mjs`

**Interfaces:**
- Consumes: `questionFlags`, `taskAnswerSkew`(Task 1)
- Produces: `renderHtml(tasks)` → `string` — `tasks` = `[{taskId, taskTitle, domain, questions}]`

- [ ] **Step 1: 실패 테스트 추가** — `tool/saa_review.test.mjs`에 추가:

```js
import { renderHtml } from './saa_review.mjs';

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
  // 정답(인덱스 1='B')이 correct 클래스로 강조
  assert.match(html, /class="opt correct"[^>]*>\s*B/);
});

test('renderHtml: 플래그 있는 문항은 배지 노출', () => {
  const bad = { ...sampleTask, questions: [{ ...sampleTask.questions[0], options: ['A', 'B', 'C'] }] };
  const html = renderHtml([bad]);
  assert.ok(html.includes('flag'));
});
```

- [ ] **Step 2: 실패 확인** — Run: `cd flutter_app && node --test tool/saa_review.test.mjs`. Expected: FAIL(`renderHtml` 미정의).

- [ ] **Step 3: 최소 구현** — `tool/saa_review.mjs`에 추가:

```js
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => (
  { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

function renderQuestion(q) {
  const flags = questionFlags(q);
  const badge = flags.length ? `<span class="flag">⚠ ${flags.map(esc).join(' · ')}</span>` : '';
  const opts = (q.options || []).map((o, i) => {
    const cls = i === q.correct ? 'opt correct' : 'opt';
    return `<li class="${cls}">${esc(o)}</li>`;
  }).join('');
  const wrong = Object.entries(q.wrongExplanations || {})
    .map(([k, v]) => `<li><b>[${esc(k)}]</b> ${esc(v)}</li>`).join('');
  const srcs = (q.sources || [])
    .map((s) => `<a href="${esc(s.url)}" target="_blank" rel="noopener">${esc(s.title || s.url)}</a>`)
    .join(' · ');
  return `<article class="q">
    <div class="meta">${esc(q.id)} · ${esc(q.skill)} · ${esc(q.difficulty)} · verified:${q.verified} ${badge}</div>
    <p class="stem">${esc(q.stem)}</p>
    <ol class="opts" type="A">${opts}</ol>
    <p class="exp"><b>해설:</b> ${esc(q.explanation)}</p>
    <ul class="wrong">${wrong}</ul>
    <div class="src">${srcs}</div>
  </article>`;
}

/** tasks=[{taskId,taskTitle,domain,questions}] → 단일 HTML 문자열. */
export function renderHtml(tasks) {
  const sections = tasks.map((t) => {
    const skew = taskAnswerSkew(t.questions);
    const skewBadge = skew
      ? `<span class="flag">⚠ 정답 쏠림 idx${skew.index} ${skew.count}/${t.questions.length}</span>`
      : '';
    return `<section class="task"><h2>D${esc(t.domain)} · ${esc(t.taskId)} — ${esc(t.taskTitle)} (${t.questions.length}) ${skewBadge}</h2>
      ${t.questions.map(renderQuestion).join('\n')}</section>`;
  }).join('\n');
  return `<!doctype html><html lang="ko"><head><meta charset="utf-8">
<title>SAA 문항 검수</title><style>
body{font:15px/1.6 system-ui,sans-serif;max-width:900px;margin:2rem auto;padding:0 1rem;color:#1a1a1a}
.task{margin:2rem 0;border-top:2px solid #0E8175;padding-top:1rem}
.q{border:1px solid #ddd;border-radius:8px;padding:1rem;margin:1rem 0}
.meta{font-size:13px;color:#666}
.opts .correct{background:#d6f5e8;font-weight:600;border-radius:4px}
.wrong{color:#555;font-size:14px}.src{font-size:13px;color:#0E8175}
.flag{background:#fde2e2;color:#a00;padding:1px 6px;border-radius:4px;font-size:12px}
</style></head><body><h1>SAA-C03 문항 검수 (${tasks.reduce((n, t) => n + t.questions.length, 0)}문항)</h1>
${sections}</body></html>`;
}
```

- [ ] **Step 4: 통과 확인** — Run: `cd flutter_app && node --test tool/saa_review.test.mjs`. Expected: PASS(14 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/saa_review.mjs flutter_app/tool/saa_review.test.mjs
git commit -m "feat(saa-review): 검수 HTML 렌더(renderHtml) — 정답 강조·플래그 배지·출처"
```

---

### Task 4: CLI 엔트리 (build·flip 디스패치 + fs)

**Files:**
- Modify: `flutter_app/tool/saa_review.mjs`

**Interfaces:**
- Consumes: 전 함수(Task 1~3)
- Produces: `main(argv)` — `build`(에셋→renderHtml→파일) / `flip <taskId>`(심각 플래그 검사→flipVerified·setQuestionCount→파일→flutter test). `import.meta.url` 가드.

- [ ] **Step 1: 구현** — `tool/saa_review.mjs` 끝에 추가:

```js
import { readFileSync, writeFileSync, mkdirSync, readdirSync } from 'node:fs';
import { execSync } from 'node:child_process';

const SAA_DIR = 'assets/content/saa';
const INDEX_PATH = 'lib/data/content_index.dart';

function loadTasks() {
  const files = readdirSync(SAA_DIR).filter((f) => f.endsWith('.questions.json')).sort();
  return files.map((f) => {
    const j = JSON.parse(readFileSync(`${SAA_DIR}/${f}`, 'utf8'));
    return { taskId: j.examGuideTaskId, taskTitle: j.taskTitle, domain: j.domain, questions: j.questions };
  });
}

function cmdBuild() {
  const tasks = loadTasks();
  mkdirSync('build/saa_review', { recursive: true });
  writeFileSync('build/saa_review/index.html', renderHtml(tasks));
  const n = tasks.reduce((a, t) => a + t.questions.length, 0);
  console.log(`build/saa_review/index.html 생성 — ${tasks.length} Task, ${n}문항`);
}

function cmdFlip(taskId, force) {
  const path = `${SAA_DIR}/${taskId}.questions.json`;
  const text = readFileSync(path, 'utf8');
  const data = JSON.parse(text);
  // 심각 구조 플래그 검사(쏠림은 경고만)
  const severe = data.questions.flatMap((q) => questionFlags(q));
  if (severe.length && !force) {
    console.error(`중단: ${taskId}에 구조 플래그 ${severe.length}건 — ${severe.slice(0, 3).join(' / ')} ...`);
    console.error('수정 후 재시도하거나 --force로 강행하세요.');
    process.exit(1);
  }
  const count = data.questions.length;
  writeFileSync(path, flipVerified(text));
  writeFileSync(INDEX_PATH, setQuestionCount(readFileSync(INDEX_PATH, 'utf8'), taskId, count));
  console.log(`${taskId}: verified ${count}문항 true, content_index questionCount=${count}`);
  execSync('flutter test test/saa_questions_test.dart', { stdio: 'inherit' });
  console.log('saa_questions_test 통과. flip 커밋은 검수자가 직접 하세요.');
}

export function main(argv) {
  const [cmd, ...rest] = argv;
  if (cmd === 'build') return cmdBuild();
  if (cmd === 'flip') {
    const taskId = rest.find((a) => !a.startsWith('--'));
    if (!taskId) { console.error('사용법: flip <taskId> [--force]'); process.exit(1); }
    return cmdFlip(taskId, rest.includes('--force'));
  }
  console.error('사용법: node tool/saa_review.mjs build | flip <taskId> [--force]');
  process.exit(1);
}

if (import.meta.url === `file://${process.argv[1]}` || process.argv[1]?.endsWith('saa_review.mjs')) {
  main(process.argv.slice(2));
}
```

- [ ] **Step 2: build 수동 검증** — Run: `cd flutter_app && node tool/saa_review.mjs build`. Expected: `build/saa_review/index.html 생성 — 24 Task, 360문항`. 브라우저로 열어 문항·정답 강조·플래그 확인(선택).

- [ ] **Step 3: 단위 테스트 회귀 확인** — Run: `cd flutter_app && node --test tool/saa_review.test.mjs`. Expected: PASS(14 tests — main 추가가 export 함수를 깨지 않음).

- [ ] **Step 4: Dart 회귀 확인** — Run(PowerShell): `cd flutter_app; flutter test test/saa_questions_test.dart`. Expected: PASS(도구 추가가 기존 가드에 영향 없음). flip은 검수 전이라 **실행하지 않는다**(verified 변경 = 사용자 검수 후).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/saa_review.mjs
git commit -m "feat(saa-review): build/flip CLI 디스패치 + 안전장치(심각 플래그 중단)"
```

---

## Self-Review

- **Spec 커버리지**: §3 구성(build·flip = Task 4) · §4 HTML 뷰어(renderHtml = Task 3) · §5 기계적 플래그 5종(questionFlags·taskAnswerSkew = Task 1) · §6 flip(flipVerified·setQuestionCount = Task 2, 안전장치·flutter test = Task 4) · §7 테스트(node:test = Task 1~3, Dart 회귀 = Task 4 Step 4). 전 항목 커버.
- **No Placeholders**: 모든 순수 함수에 완전한 구현 코드·테스트. CLI도 완전 코드.
- **타입 일관성**: `questionFlags(q)→string[]` · `taskAnswerSkew(questions)→{index,count,ratio}|null` · `flipVerified(text)→string` · `setQuestionCount(text,taskId,count)→string` · `renderHtml(tasks)→string`이 Task 간 일치. CLI가 동일 시그니처로 호출.
- **AI flip 금지 준수**: 도구만 만들고 실제 flip은 실행하지 않음(Task 4 Step 4 명시). flip 커밋은 검수자 몫.
- **회귀**: Dart `saa_questions_test` 미변경, Task 4 Step 4에서 통과 확인.

## 비범위
- 실제 360문항 검수·flip 실행(사용자 작업).
- 체크·메모·진행률 · 문항 자동 수정 · 다른 cert 일반화.
