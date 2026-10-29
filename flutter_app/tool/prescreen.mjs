// 문항 사전심사(prescreen) — 결정적(deterministic) 구조·정합성 플래그 생성기.
// 의미·정답·출처 정확성(품질) 판단은 사람/AI 패스(T2)의 몫. 여기선 기계적 검사만.
// review.mjs의 CERTS·questionFlags를 재사용(DRY). 순수 함수는 export(테스트용);
// main()은 import.meta.url 가드로 직접 실행 시만.
//
// 사용법: node tool/prescreen.mjs build <cert>   (<cert>: clf·saa·soa·dea·mla)
// 산출: build/<cert>_review/<taskId>.prescreen.json (문항id별 구조·정합성 플래그).
//       뷰어(`review.mjs build <cert>`)와 같은 디렉터리라 자격증별로 한곳에 모인다.
//       T2(AI 의미+출처 패스)와 사람 검수가 이 위에 의미 판단을 얹는다.
//
// 2026-10-29에 SAA 전용(`saa_prescreen.mjs`)에서 자격증 일반형으로 넓혔다.
// ⚠️ 도메인 수가 자격증마다 다르다 — **SOA-C03은 5개**다. 그래서 taskId의 도메인
// 범위를 4로 못 박지 않고 `CERTS[<cert>].domains`에서 읽는다(그 값이 공식 시험
// 가이드의 도메인 수와 맞는지는 `review.test.mjs`가 기계로 검사한다).

import { readFileSync, writeFileSync, mkdirSync, readdirSync } from 'node:fs';
import { appPath, questionFlags, resolveCert } from './review.mjs';

/** taskId `<cert>-t{D}-{n}`에서 도메인 D 추출. 형식·범위가 안 맞으면 null. */
export function domainOfTaskId(taskId, cert) {
  const m = new RegExp(`^${cert.code}-t(\\d+)-\\d+$`).exec(String(taskId ?? ''));
  if (!m) return null;
  const d = Number(m[1]);
  return d >= 1 && d <= cert.domains ? d : null;
}

/** 뱅크 단위 정합성 플래그(빈 배열=정상). 품질 판단 아님. */
export function bankScopeFlags(bank, cert) {
  const flags = [];
  const taskId = bank?.examGuideTaskId;
  const d = domainOfTaskId(taskId, cert);
  if (d === null) {
    flags.push(
      `examGuideTaskId '${taskId}' 형식 이상(${cert.code}-t{1-${cert.domains}}-N 아님)`,
    );
  } else if (bank.domain !== d) {
    flags.push(`domain ${bank.domain} ≠ taskId 도메인 ${d}`);
  }
  if (bank?.certCode != null && bank.certCode !== cert.label) {
    flags.push(`certCode '${bank.certCode}' ≠ '${cert.label}'`);
  }
  if (!Array.isArray(bank?.questions) || bank.questions.length === 0) {
    flags.push('questions 비어있음');
  }
  return flags;
}

/** 문항 단위 정합성 플래그(빈 배열=정상). 뱅크와 다른 examGuideTaskId 등. */
export function questionScopeFlags(q, bankTaskId) {
  const flags = [];
  if (q?.examGuideTaskId != null && q.examGuideTaskId !== bankTaskId) {
    flags.push(`문항 examGuideTaskId '${q.examGuideTaskId}' ≠ 뱅크 '${bankTaskId}'`);
  }
  return flags;
}

/** 뱅크 → 사전심사 결과. 문항id별 구조(questionFlags 재사용)·정합성 플래그.
 *  의미·정답·출처 정확성은 포함하지 않는다(T2/사람). */
export function buildPrescreen(bank, cert) {
  const taskId = bank?.examGuideTaskId;
  const questions = (bank?.questions ?? []).map((q) => ({
    id: q.id,
    verified: q.verified === true,
    skill: q.skill ?? '',
    section: q.section ?? '',
    structuralFlags: questionFlags(q),
    scopeFlags: questionScopeFlags(q, taskId),
  }));
  const flaggedCount = questions.filter(
    (q) => q.structuralFlags.length || q.scopeFlags.length,
  ).length;
  return {
    cert: cert.label,
    taskId,
    domain: bank?.domain,
    count: questions.length,
    bankFlags: bankScopeFlags(bank, cert),
    flaggedCount,
    questions,
  };
}

function loadBanks(cert) {
  const dir = appPath(cert.dir);
  return readdirSync(dir)
    .filter((f) => f.endsWith('.questions.json'))
    .sort()
    .map((f) => JSON.parse(readFileSync(`${dir}/${f}`, 'utf8')));
}

function cmdBuild(code) {
  const cert = resolveCert(code);
  const rel = `build/${cert.code}_review`;
  mkdirSync(appPath(rel), { recursive: true });
  const banks = loadBanks(cert);
  let totalFlagged = 0;
  let totalBankFlagged = 0;
  for (const bank of banks) {
    const pre = buildPrescreen(bank, cert);
    totalFlagged += pre.flaggedCount;
    if (pre.bankFlags.length) totalBankFlagged++;
    writeFileSync(
      appPath(`${rel}/${pre.taskId}.prescreen.json`),
      `${JSON.stringify(pre, null, 2)}\n`,
    );
  }
  console.log(
    `prescreen(${cert.label}): ${banks.length} Task → ${rel}/*.prescreen.json ` +
      `(구조·정합성 플래그 문항 ${totalFlagged}건, 뱅크 플래그 ${totalBankFlagged} Task). ` +
      `의미·정답·출처 정확성은 T2/사람 패스.`,
  );
}

export function main(argv) {
  const [cmd, code] = argv;
  if (cmd === 'build' && code) return cmdBuild(code);
  console.error('사용법: node tool/prescreen.mjs build <cert>   (clf·saa·soa·dea·mla)');
  process.exit(1);
}

if (
  import.meta.url === `file://${process.argv[1]}` ||
  process.argv[1]?.endsWith('prescreen.mjs')
) {
  main(process.argv.slice(2));
}
