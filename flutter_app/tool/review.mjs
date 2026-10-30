// 자격증 문항 검수 도구 — 읽기 HTML 뷰어 + Task 단위 flip CLI.
// 순수 함수는 export(테스트용), main()은 import.meta.url 가드로 직접 실행 시만.
//
//   node tool/review.mjs build <cert>
//   node tool/review.mjs flip  <cert> <taskId> [--force]
//
// <cert>는 아래 CERTS의 키(clf·saa·soa·dea·mla).

import { readFileSync, writeFileSync, mkdirSync, readdirSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';

/** flutter_app 루트(이 파일의 상위 디렉터리). cwd와 무관하게 경로를 고정한다. */
const APP_DIR = fileURLToPath(new URL('..', import.meta.url));

/** flutter_app 기준 상대경로를 절대경로로. */
export function appPath(rel) {
  return join(APP_DIR, rel);
}

/**
 * 자격증 레지스트리. dir·label은 뷰어가, tests는 flip 끝의 검증이,
 * domains는 사전심사(`prescreen.mjs`)의 taskId 도메인 범위 검사가 쓴다.
 *
 * `flipAllowlist`가 있는 자격증은 flip이 그 Dart 집합에도 taskId를 넣는다 —
 * 목록 밖의 `verified: true`를 테스트가 막기 때문에(AI flip 금지 가드),
 * 집합을 갱신하지 않으면 flip 직후 그 테스트가 깨진다. 사람이 flip 명령을
 * 직접 실행하고 결과가 diff에 드러나므로 "사람의 서명"이라는 의미는 유지된다.
 *
 * ⚠️ tests·flipAllowlist에 적는 파일은 실재해야 한다 — 없는 파일을 적으면
 * flip 마지막 단계가 깨지므로 `review.test.mjs`가 존재를 기계로 검사한다.
 *
 * ⚠️ **domains는 자격증마다 다르다 — SOA-C03은 5개다.** 4로 못 박으면 SOA의
 * `soa-t5-*` Task가 "형식 이상"으로 오탐된다(옛 `saa_prescreen.mjs`의
 * `^saa-t([1-4])-\d+$`가 그랬다). 이 값이 공식 시험 가이드
 * (`assets/exam_guides/<label>.json`)의 도메인 수와 맞는지는 `review.test.mjs`가
 * 기계로 검사한다.
 */
export const CERTS = {
  clf: {
    dir: 'assets/content/clf',
    label: 'CLF-C02',
    domains: 4,
    // CLF 전용 문항 가드는 보강 문항 테스트뿐이다(수량 정합은 content_index).
    tests: ['test/clf_supplement_questions_test.dart', 'test/content_index_test.dart'],
  },
  saa: {
    dir: 'assets/content/saa',
    label: 'SAA-C03',
    domains: 4,
    tests: ['test/saa_questions_test.dart', 'test/content_index_test.dart'],
  },
  soa: {
    dir: 'assets/content/soa',
    label: 'SOA-C03',
    domains: 5, // ⚠️ 유일한 5도메인 자격증(공식명 CloudOps Engineer, 가이드 v1.1)
    tests: ['test/soa_questions_test.dart', 'test/content_index_test.dart'],
    flipAllowlist: { file: 'test/soa_questions_test.dart', symbol: 'flipApprovedTaskIds' },
  },
  dea: {
    dir: 'assets/content/dea',
    label: 'DEA-C01',
    domains: 4,
    tests: ['test/dea_questions_test.dart', 'test/content_index_test.dart'],
    flipAllowlist: { file: 'test/dea_questions_test.dart', symbol: 'flipApprovedTaskIds' },
  },
  mla: {
    dir: 'assets/content/mla',
    label: 'MLA-C01',
    domains: 4,
    tests: [
      'test/mla_questions_test.dart',
      'test/mla_doc_format_test.dart',
      'test/content_index_test.dart',
    ],
    flipAllowlist: { file: 'test/mla_questions_test.dart', symbol: 'flipApprovedTaskIds' },
  },
};

/** 자격증 코드 → 레지스트리 항목(+code). 모르는 코드는 throw. */
export function resolveCert(code) {
  const cert = CERTS[code];
  if (!cert) {
    throw new Error(`모르는 자격증 '${code}' — 가능: ${Object.keys(CERTS).join(', ')}`);
  }
  return { code, ...cert };
}

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

/**
 * Dart `const <symbol> = <String>{...};` 집합에 taskId를 추가한다.
 * 이미 있으면 원문 그대로 반환하고, 선언을 못 찾으면 throw.
 * 기존 항목·주석·들여쓰기는 보존한다(끝에 덧붙이는 방식).
 */
export function addToAllowlist(dartText, symbol, taskId) {
  const re = new RegExp(`(const\\s+${symbol}\\s*=\\s*<String>\\{)([\\s\\S]*?)(\\};)`);
  const m = dartText.match(re);
  if (!m) throw new Error(`허용 목록 선언 'const ${symbol} = <String>{...}'을 찾지 못했다`);
  const body = m[2];
  const entries = [...body.matchAll(/'([^']*)'/g)].map((e) => e[1]);
  if (entries.includes(taskId)) return dartText;
  const kept = body.replace(/\s*,?\s*$/, '');
  const next = kept.trim() ? `${kept}, '${taskId}'` : `'${taskId}'`;
  return dartText.replace(re, (_all, open, _mid, close) => `${open}${next}${close}`);
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

/** tasks=[{taskId,taskTitle,domain,questions}] → 단일 HTML 문자열. label=자격증명. */
export function renderHtml(tasks, label = '') {
  const heading = label ? `${label} 문항 검수` : '문항 검수';
  const sections = tasks.map((t) => {
    const skew = taskAnswerSkew(t.questions);
    const skewBadge = skew
      ? `<span class="flag">⚠ 정답 쏠림 idx${skew.index} ${skew.count}/${t.questions.length}</span>`
      : '';
    return `<section class="task"><h2>D${esc(t.domain)} · ${esc(t.taskId)} — ${esc(t.taskTitle)} (${t.questions.length}) ${skewBadge}</h2>
      ${t.questions.map(renderQuestion).join('\n')}</section>`;
  }).join('\n');
  return `<!doctype html><html lang="ko"><head><meta charset="utf-8">
<title>${esc(heading)}</title><style>
body{font:15px/1.6 system-ui,sans-serif;max-width:900px;margin:2rem auto;padding:0 1rem;color:#1a1a1a}
.task{margin:2rem 0;border-top:2px solid #0E8175;padding-top:1rem}
.q{border:1px solid #ddd;border-radius:8px;padding:1rem;margin:1rem 0}
.meta{font-size:13px;color:#666}
.opts .correct{background:#d6f5e8;font-weight:600;border-radius:4px}
.wrong{color:#555;font-size:14px}.src{font-size:13px;color:#0E8175}
.flag{background:#fde2e2;color:#a00;padding:1px 6px;border-radius:4px;font-size:12px}
</style></head><body><h1>${esc(heading)} (${tasks.reduce((n, t) => n + t.questions.length, 0)}문항)</h1>
${sections}</body></html>`;
}

const INDEX_PATH = 'lib/data/content_index.dart';

/**
 * 그 Task의 .questions.json 절대경로. 파일명 규칙이 자격증마다 달라서
 * (clf는 't1-1.questions.json', 나머지는 '<cert>-t1-1.questions.json')
 * 파일명 → 내용의 examGuideTaskId 순으로 찾는다.
 */
export function questionFilePath(cert, taskId) {
  const files = readdirSync(appPath(cert.dir)).filter((f) => f.endsWith('.questions.json'));
  const direct = `${taskId}.questions.json`;
  if (files.includes(direct)) return appPath(`${cert.dir}/${direct}`);
  for (const f of files.sort()) {
    const p = appPath(`${cert.dir}/${f}`);
    if (JSON.parse(readFileSync(p, 'utf8')).examGuideTaskId === taskId) return p;
  }
  throw new Error(`${cert.code}: taskId '${taskId}' 문항 파일 미발견(${cert.dir})`);
}

function loadTasks(cert) {
  const dir = appPath(cert.dir);
  const files = readdirSync(dir).filter((f) => f.endsWith('.questions.json')).sort();
  return files.map((f) => {
    const j = JSON.parse(readFileSync(join(dir, f), 'utf8'));
    return { taskId: j.examGuideTaskId, taskTitle: j.taskTitle, domain: j.domain, questions: j.questions };
  });
}

function cmdBuild(code) {
  const cert = resolveCert(code);
  const tasks = loadTasks(cert);
  const rel = `build/${cert.code}_review`;
  mkdirSync(appPath(rel), { recursive: true });
  writeFileSync(appPath(`${rel}/index.html`), renderHtml(tasks, cert.label));
  const n = tasks.reduce((a, t) => a + t.questions.length, 0);
  console.log(`${rel}/index.html 생성 — ${tasks.length} Task, ${n}문항`);
}

function cmdFlip(code, taskId, force) {
  const cert = resolveCert(code);
  const path = questionFilePath(cert, taskId);
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
  const indexPath = appPath(INDEX_PATH);
  writeFileSync(indexPath, setQuestionCount(readFileSync(indexPath, 'utf8'), taskId, count));
  console.log(`${taskId}: verified ${count}문항 true, content_index questionCount=${count}`);
  if (cert.flipAllowlist) {
    const { file, symbol } = cert.flipAllowlist;
    const before = readFileSync(appPath(file), 'utf8');
    const after = addToAllowlist(before, symbol, taskId);
    if (after === before) console.log(`${file}: ${symbol}에 ${taskId} 이미 있음`);
    else {
      writeFileSync(appPath(file), after);
      console.log(`${file}: ${symbol}에 ${taskId} 추가`);
    }
  }
  execSync(`flutter test ${cert.tests.join(' ')}`, { stdio: 'inherit', cwd: APP_DIR });
  console.log(`${cert.tests.join('·')} 통과. flip 커밋은 검수자가 직접 하세요.`);
}

const USAGE = `사용법: node tool/review.mjs build <cert> | flip <cert> <taskId> [--force]
  <cert>: ${Object.keys(CERTS).join(' | ')}`;

export function main(argv) {
  const [cmd, ...rest] = argv;
  const pos = rest.filter((a) => !a.startsWith('--'));
  if ((cmd !== 'build' && cmd !== 'flip') || !pos[0] || (cmd === 'flip' && !pos[1])) {
    console.error(USAGE);
    process.exit(1);
  }
  if (!CERTS[pos[0]]) {
    console.error(`모르는 자격증 '${pos[0]}'\n${USAGE}`);
    process.exit(1);
  }
  return cmd === 'build'
    ? cmdBuild(pos[0])
    : cmdFlip(pos[0], pos[1], rest.includes('--force'));
}

if (import.meta.url === `file://${process.argv[1]}` || /[\\/]review\.mjs$/.test(process.argv[1] ?? '')) {
  main(process.argv.slice(2));
}
