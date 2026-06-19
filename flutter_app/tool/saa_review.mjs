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
