// SAA 문항 사전심사(prescreen) — 결정적(deterministic) 구조·정합성 플래그 생성기.
// 의미·정답·출처 정확성(품질) 판단은 사람/AI 패스(T2)의 몫. 여기선 기계적 검사만.
// saa_review.mjs의 questionFlags를 재사용(DRY). 순수 함수는 export(테스트용);
// main()은 import.meta.url 가드로 직접 실행 시만.
//
// 산출: build/saa_review/<taskId>.prescreen.json (문항id별 구조·정합성 플래그).
//       T2(AI 의미+출처 패스)와 사람 검수가 이 위에 의미 판단을 얹는다.

import { readFileSync, writeFileSync, mkdirSync, readdirSync } from 'node:fs';
import { questionFlags } from './saa_review.mjs';

const SAA_DIR = 'assets/content/saa';
const OUT_DIR = 'build/saa_review';

/** taskId 'saa-t{D}-{n}'에서 도메인 D(1~4) 추출. 형식 안 맞으면 null. */
export function domainOfTaskId(taskId) {
  const m = /^saa-t([1-4])-\d+$/.exec(String(taskId ?? ''));
  return m ? Number(m[1]) : null;
}

/** 뱅크 단위 정합성 플래그(빈 배열=정상). 품질 판단 아님. */
export function bankScopeFlags(bank) {
  const flags = [];
  const taskId = bank?.examGuideTaskId;
  const d = domainOfTaskId(taskId);
  if (d === null) {
    flags.push(`examGuideTaskId '${taskId}' 형식 이상(saa-t{1-4}-N 아님)`);
  } else if (bank.domain !== d) {
    flags.push(`domain ${bank.domain} ≠ taskId 도메인 ${d}`);
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
export function buildPrescreen(bank) {
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
    taskId,
    domain: bank?.domain,
    count: questions.length,
    bankFlags: bankScopeFlags(bank),
    flaggedCount,
    questions,
  };
}

function loadBanks() {
  return readdirSync(SAA_DIR)
    .filter((f) => f.endsWith('.questions.json'))
    .sort()
    .map((f) => JSON.parse(readFileSync(`${SAA_DIR}/${f}`, 'utf8')));
}

function cmdBuild() {
  mkdirSync(OUT_DIR, { recursive: true });
  const banks = loadBanks();
  let totalFlagged = 0;
  for (const bank of banks) {
    const pre = buildPrescreen(bank);
    totalFlagged += pre.flaggedCount;
    writeFileSync(
      `${OUT_DIR}/${pre.taskId}.prescreen.json`,
      `${JSON.stringify(pre, null, 2)}\n`,
    );
  }
  console.log(
    `prescreen: ${banks.length} Task → ${OUT_DIR}/*.prescreen.json ` +
      `(구조·정합성 플래그 문항 ${totalFlagged}건). 의미·정답·출처 정확성은 T2/사람 패스.`,
  );
}

export function main(argv) {
  const [cmd] = argv;
  if (cmd === 'build') return cmdBuild();
  console.error('사용법: node tool/saa_prescreen.mjs build');
  process.exit(1);
}

if (
  import.meta.url === `file://${process.argv[1]}` ||
  process.argv[1]?.endsWith('saa_prescreen.mjs')
) {
  main(process.argv.slice(2));
}
