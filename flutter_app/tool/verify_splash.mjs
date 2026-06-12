#!/usr/bin/env node
// tool/verify_splash.mjs — 스플래시(WS1) 검증 도구 (설계 T3)
//
// 빌드(PowerShell 불필요 — cmd 경유라 MSYS 경로 변환 없음) → node 정적 서브 →
// browse(gstack) DOM 어서션(스플래시 존재 → 소멸) + 스크린샷 + 네트워크 타이밍 기록.
//
// 사용:
//   node tool/verify_splash.mjs                 # 빌드 + 측정
//   node tool/verify_splash.mjs --skip-build    # 기존 build/web 재사용
//   node tool/verify_splash.mjs --throttle 800  # 대형 리소스 응답 지연(ms) — 느린 회선 모사
//   node tool/verify_splash.mjs --theme dark    # 저장 테마 dark 주입 후 측정
//   node tool/verify_splash.mjs --label before  # 보고서 라벨(전/후 비교 누적 기록용)
//
// 스플래시 없는 빌드(전 측정)에서도 동작: splashSeen=false로 기록되고
// flutter-view 등장 시각만 측정된다 — 전/후 비교 축.

import { spawn, spawnSync } from 'node:child_process';
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';

const appDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const webRoot = path.join(appDir, 'build', 'web');
const outDir = path.join(appDir, 'build', 'verify_splash');

const args = process.argv.slice(2);
const flag = (name) => args.includes(name);
const opt = (name, dflt) => {
  const i = args.indexOf(name);
  return i >= 0 && args[i + 1] ? args[i + 1] : dflt;
};
const throttleMs = Number(opt('--throttle', '0'));
const port = Number(opt('--port', '8123'));
const theme = opt('--theme', 'light');
const label = opt('--label', 'run');

const browseBin = path.join(os.homedir(), '.claude', 'skills', 'gstack', 'browse', 'dist', 'browse');

// 비동기 필수: 이 프로세스가 정적 서버도 돌리므로 spawnSync로 browse를 부르면
// 이벤트 루프가 멈춰 서버가 browse의 요청에 응답하지 못한다(데드락).
function browse(...cmd) {
  return new Promise((resolve, reject) => {
    const c = spawn(browseBin, cmd, { timeout: 60000 });
    let out = '';
    c.stdout.on('data', (d) => { out += d; });
    c.stderr.on('data', () => {});
    c.on('error', reject);
    c.on('close', () => resolve(out.trim()));
  });
}

// browse 출력은 UNTRUSTED 마커로 감싸일 수 있다 — 마커/장식 줄을 걷어내고 페이로드만.
function payload(raw) {
  return raw
    .split('\n')
    .filter((l) => !/UNTRUSTED EXTERNAL CONTENT|^---/.test(l))
    .join('\n')
    .trim();
}

function step(msg) {
  process.stdout.write(`[verify_splash] ${msg}\n`);
}

// ---- 1) 빌드 ---------------------------------------------------------------
if (!flag('--skip-build')) {
  step('flutter build web --base-href / (로컬 서브용 루트 base-href)');
  // 인자는 전부 상수(외부 입력 없음). Windows에서 flutter.bat은 직접 spawn이
  // 막혀 있어(EINVAL) cmd.exe를 명시 실행 파일로 지정한다 — shell 옵션 미사용.
  const BUILD_CMD = 'flutter build web --base-href /';
  const b = process.platform === 'win32'
    ? spawnSync('cmd.exe', ['/d', '/s', '/c', BUILD_CMD],
        { cwd: appDir, stdio: 'inherit', timeout: 600000 })
    : spawnSync('flutter', ['build', 'web', '--base-href', '/'],
        { cwd: appDir, stdio: 'inherit', timeout: 600000 });
  if (b.status !== 0) {
    console.error('[verify_splash] 빌드 실패'); process.exit(1);
  }
} else {
  step('빌드 생략(--skip-build)');
}
if (!fs.existsSync(path.join(webRoot, 'index.html'))) {
  console.error(`[verify_splash] ${webRoot}/index.html 없음 — 먼저 빌드하세요`); process.exit(1);
}

// ---- 2) 정적 서버 (대형 리소스 스로틀 옵션) ---------------------------------
const MIME = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.css': 'text/css', '.json': 'application/json', '.wasm': 'application/wasm',
  '.png': 'image/png', '.ico': 'image/x-icon', '.svg': 'image/svg+xml',
  '.otf': 'font/otf', '.ttf': 'font/ttf', '.frag': 'application/octet-stream',
};
const HEAVY = /\.(wasm|otf|ttf)$|main\.dart\.js$|canvaskit/;

const server = http.createServer((req, res) => {
  const urlPath = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  let file = path.normalize(path.join(webRoot, urlPath));
  if (!file.startsWith(webRoot)) { res.writeHead(403).end(); return; }
  if (urlPath === '/' || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
    file = path.join(webRoot, 'index.html');
  }
  const send = () => {
    res.writeHead(200, { 'content-type': MIME[path.extname(file)] || 'application/octet-stream' });
    fs.createReadStream(file).pipe(res);
  };
  if (throttleMs > 0 && HEAVY.test(file)) setTimeout(send, throttleMs); else send();
});

await new Promise((ok) => server.listen(port, '127.0.0.1', ok));
const base = `http://127.0.0.1:${port}/`;
step(`서브 시작: ${base} (throttle=${throttleMs}ms)`);

// ---- 3) browse 측정 ---------------------------------------------------------
fs.mkdirSync(outDir, { recursive: true });
const shot = (name) => path.join(outDir, `${label}-${theme}-${name}.png`);
const result = {
  label, theme, throttleMs, when: new Date().toISOString(),
  splashSeen: false, splashSeenAtMs: null, splashGoneAtMs: null,
  flutterViewAtMs: null, consoleErrors: [], resources: [], nav: null,
};

try {
  if (theme === 'dark') {
    // 저장 테마 주입: 같은 오리진에 먼저 진입해야 localStorage에 닿는다.
    await browse('goto', base);
    await browse('storage', 'set', 'awsdocs.theme.v1', 'dark');
    step('localStorage awsdocs.theme.v1=dark 주입');
  } else {
    // 라이트 기본 검증: 이전 실행의 키 잔존 제거.
    await browse('goto', base);
    await browse('js', "localStorage.removeItem('awsdocs.theme.v1')");
  }

  const t0 = Date.now();
  await browse('goto', base);

  // 폴링: 스플래시 존재/소멸 + flutter-view 등장 시각. 첫 관찰에서 스플래시를 잡으면 스크린샷.
  const PROBE = "JSON.stringify({s:!!document.getElementById('splash'),f:!!document.querySelector('flutter-view,flt-glass-pane')})";
  const deadline = t0 + 90000;
  let shotTaken = false;
  while (Date.now() < deadline) {
    const t = Date.now() - t0;
    let probe;
    try { probe = JSON.parse(payload(await browse('js', PROBE))); } catch { probe = null; }
    if (probe) {
      if (probe.s && !result.splashSeen) {
        result.splashSeen = true;
        result.splashSeenAtMs = t;
        if (!shotTaken) { await browse('screenshot', shot('splash')); shotTaken = true; step(`스플래시 확인 +${t}ms → ${shot('splash')}`); }
      }
      if (probe.f && result.flutterViewAtMs == null) result.flutterViewAtMs = t;
      if (!probe.s && (result.splashSeen || probe.f)) {
        // 소멸(또는 splash 없는 전 빌드에서 flutter 등장) — 측정 종료 조건.
        if (result.splashSeen) result.splashGoneAtMs = t;
        break;
      }
    }
    await new Promise((ok) => setTimeout(ok, 100));
  }

  await browse('screenshot', shot('after'));
  step(`최종 화면 → ${shot('after')}`);

  // 네트워크 타이밍(임계 경로 리소스만) + 콘솔 에러.
  const timingJs = "JSON.stringify((()=>{const nav=performance.getEntriesByType('navigation')[0]||{};const rs=performance.getEntriesByType('resource').filter(r=>/main\\.dart|canvaskit|\\.otf|\\.ttf|flutter_bootstrap|\\.wasm/.test(r.name)).map(r=>({name:r.name.split('/').pop().slice(0,48),durMs:Math.round(r.duration),bytes:r.transferSize||r.decodedBodySize||0}));return {nav:{dclMs:Math.round(nav.domContentLoadedEventEnd||0),loadMs:Math.round(nav.loadEventEnd||0)},rs};})())";
  try {
    const t = JSON.parse(payload(await browse('js', timingJs)));
    result.nav = t.nav; result.resources = t.rs;
  } catch { /* 타이밍 수집 실패는 비치명 */ }
  const errs = payload(await browse('console', '--errors'));
  if (errs && !/^\s*(\[\]|\(?no (console )?(errors?|messages?)\)?)?\s*$/i.test(errs)) {
    result.consoleErrors = errs.split('\n').slice(0, 20);
  }
} finally {
  server.close();
}

// ---- 4) 보고 -----------------------------------------------------------------
const reportPath = path.join(outDir, `${label}-${theme}.json`);
fs.writeFileSync(reportPath, JSON.stringify(result, null, 2));

const fmtKB = (b) => (b > 1048576 ? `${(b / 1048576).toFixed(1)}MB` : `${Math.round(b / 1024)}KB`);
step('—— 결과 ——');
step(`splash seen: ${result.splashSeen}${result.splashSeenAtMs != null ? ` (+${result.splashSeenAtMs}ms)` : ''}`);
step(`splash gone: ${result.splashGoneAtMs != null ? `+${result.splashGoneAtMs}ms` : 'n/a'}`);
step(`flutter view: ${result.flutterViewAtMs != null ? `+${result.flutterViewAtMs}ms` : '미등장(타임아웃)'}`);
step(`console errors: ${result.consoleErrors.length === 0 ? '없음' : result.consoleErrors.length + '건(보고서 참조)'}`);
for (const r of result.resources) step(`  ${r.name}  ${fmtKB(r.bytes)}  ${r.durMs}ms`);
step(`보고서: ${reportPath}`);

// 어서션: 스플래시 빌드에서는 존재→소멸이 모두 관측돼야 성공.
const isSplashBuild = fs.readFileSync(path.join(webRoot, 'index.html'), 'utf8').includes('id="splash"');
if (isSplashBuild && !(result.splashSeen && result.splashGoneAtMs != null)) {
  step('FAIL — 스플래시 존재→소멸 어서션 실패');
  process.exit(1);
}
if (result.flutterViewAtMs == null) {
  step('FAIL — flutter-view가 등장하지 않음');
  process.exit(1);
}
step('PASS');
