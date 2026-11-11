// 문항 사전심사(prescreen) — 결정적(deterministic) 구조·정합성 플래그 생성기.
// 의미·정답·출처 정확성(품질) 판단은 사람/AI 패스(T2)의 몫. 여기선 기계적 검사만.
// review.mjs의 CERTS·questionFlags를 재사용(DRY). 순수 함수는 export(테스트용);
// main()은 import.meta.url 가드로 직접 실행 시만.
//
// 사용법: node tool/prescreen.mjs build <cert>
//   ⚠️ <cert>는 `review.mjs`의 CERTS 키이고 **여기에 목록을 적지 않는다** —
//   2026-11-10 실측에서 이 줄과 아래 오류 메시지가 `clf·saa·soa·dea·mla`로 멈춰
//   있어 그 뒤 등록한 **aif·scs가 빠져** 있었다. 오류 메시지는 CERTS에서 유도한다.
// 산출: build/<cert>_review/<taskId>.prescreen.json (문항id별 구조·정합성 플래그).
//       뷰어(`review.mjs build <cert>`)와 같은 디렉터리라 자격증별로 한곳에 모인다.
//       T2(AI 의미+출처 패스)와 사람 검수가 이 위에 의미 판단을 얹는다.
//
// 2026-10-29에 SAA 전용(`saa_prescreen.mjs`)에서 자격증 일반형으로 넓혔다.
// ⚠️ 도메인 수가 자격증마다 다르다 — **SOA-C03은 5개**다. 그래서 taskId의 도메인
// 범위를 4로 못 박지 않고 `CERTS[<cert>].domains`에서 읽는다(그 값이 공식 시험
// 가이드의 도메인 수와 맞는지는 `review.test.mjs`가 기계로 검사한다).

import { readFileSync, writeFileSync, mkdirSync, readdirSync } from 'node:fs';
import { appPath, CERTS, questionFlags, resolveCert } from './review.mjs';

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

// ════════════════════════════════════════════════════════════════════════
// 품질 신호(quality signals) — 2026-11-11 외부 검수 보고 P-1
//
// ⚠️⚠️ **`flaggedCount`에 섞지 않는다.** 그 수는 「구조·정합성 **결함**」으로 쓰여
// 왔고 「SCS 240문항 플래그 0건」처럼 **측정 기록의 기준**이다. 품질 신호는 결함
// 단정이 아니라 **사람이 읽을 후보**이므로 `qualityFlags`와 `qualitySignalCount`로
// 나눠 둔다. 섞으면 그 기록이 의미를 잃는다.
//
// 보고가 든 근거: 이 뱅크의 가장 큰 문제인 **정답이 유일하게 가장 긴 문항
// 227/240(94.6%)** 과 메타 문항·저작 메모·중복이 **기존 플래그 0건을 그대로
// 통과**했다. 검사 항목에 없었기 때문이다.
//
// ⚠️ 각 신호는 **거짓 양성이 있다** — 금지가 아니라 신호다:
//   - `외우` : 「지원 유형 목록은 외우지 않고 공식 CLI 조회 절차로 확인한다」처럼
//     공식 절차를 안내하는 정당한 서술이 섞인다(2026-11-11 §4 2단계 실측).
//   - `공식` : 출처를 귀속하는 정당한 서술에도 쓰인다. 지문·정답에 들어갔을 때만
//     센다(해설의 출처 귀속은 세지 않는다).
//   - `자리` : **일부러 넣지 않았다.** 「빈자리」·「그 자리에서」 같은 정상 용례가
//     섞여 12문항이 걸리는데 그중 결함은 둘뿐이었다(2026-11-11 실측).

/** 지문·정답 보기의 메타 표현(문서 암기·시험 가이드 자체를 묻는 신호). */
const META_PHRASES = ['공식', '시험 가이드', '단정하지'];

/** 해설·오답 근거의 저작 메모(저작자의 판정 기준·학습 지시·출제 예측). */
const MEMO_PHRASES = ['교재', '출제', '외우', '공부 시간', '정본'];

/** 정답 길이가 최장 오답의 이 배수를 넘으면 신호. 보고 P-1 제안값. */
export const ANSWER_LENGTH_RATIO = 1.3;

/** 해설이 이 길이를 넘으면 신호. 보고 P-1 제안값. */
export const EXPLANATION_MAX = 400;

/** 문항 단위 품질 신호(빈 배열=신호 없음). **결함 단정이 아니다.** */
export function qualityFlags(q) {
  const flags = [];
  const options = Array.isArray(q?.options) ? q.options.map(String) : [];
  const correct = Number.isInteger(q?.correct) ? q.correct : -1;

  // ① 길이 단서 — 「제일 긴 것 고르기」로 맞출 수 있는 문항.
  if (options.length > 1 && correct >= 0 && correct < options.length) {
    const c = options[correct].length;
    const others = options.filter((_, i) => i !== correct).map((o) => o.length);
    const longest = Math.max(...others);
    if (longest > 0 && c > longest * ANSWER_LENGTH_RATIO) {
      flags.push(
        `length-cue: 정답 ${c}자 > 최장 오답 ${longest}자 × ${ANSWER_LENGTH_RATIO}`,
      );
    }
  }

  // ② 메타 표현 — 지문과 정답 보기만 본다(해설의 출처 귀속은 정당하다).
  const asked = [String(q?.stem ?? ''), options[correct] ?? ''].join('\n');
  const meta = META_PHRASES.filter((p) => asked.includes(p));
  if (meta.length) flags.push(`meta-phrasing: ${meta.join('·')} (지문·정답)`);

  // ③ 저작 메모 — 해설과 오답 근거를 본다.
  const told = [
    String(q?.explanation ?? ''),
    ...Object.values(q?.wrongExplanations ?? {}).map(String),
  ].join('\n');
  const memo = MEMO_PHRASES.filter((p) => told.includes(p));
  if (memo.length) flags.push(`authoring-memo: ${memo.join('·')} (해설·오답 근거)`);

  // ⑤ 해설 길이.
  const expLen = String(q?.explanation ?? '').length;
  if (expLen > EXPLANATION_MAX) {
    flags.push(`explanation-long: ${expLen}자 > ${EXPLANATION_MAX}`);
  }
  return flags;
}

/** 토큰 집합(자카드용). 2자 이상 낱말만 센다. */
function tokensOf(text) {
  return new Set(
    String(text ?? '')
      .split(/[^0-9A-Za-z가-힣]+/)
      .filter((w) => w.length >= 2),
  );
}

/** 두 집합의 자카드. */
function jaccard(a, b) {
  if (!a.size || !b.size) return 0;
  let inter = 0;
  for (const x of a) if (b.has(x)) inter++;
  return inter / (a.size + b.size - inter);
}

/** 중복 후보 임계. 2026-11-06 AIF·MLA 배치가 쓴 값과 같다. */
export const DUPLICATE_JACCARD = 0.33;

/** ④ 같은 Task 안에서 출처를 공유하는 쌍의 정답 자카드가 임계를 넘으면 후보.
 *
 *  ⚠️⚠️ **이 지표는 하한이다.** 2026-11-10 SCS 전수 측정은 임계 이상 **0건**이었는데
 *  2026-11-11 외부 검수는 **사람이 읽어 13묶음**을 찾았다(2026-11-06 AIF 에서도 6쌍
 *  중 2쌍이 임계 아래였다). **0건이 「중복 없음」이 아니다.**
 *  ⚠️ 그리고 prescreen 은 뱅크(Task) 단위로 돌아 **교차 Task 중복을 보지 못한다** —
 *  보고의 13묶음은 대부분 교차 Task 다. 전수 쌍 비교는 별 스크립트가 필요하다.
 */
export function duplicatePairs(questions) {
  const answerOf = (q) =>
    Array.isArray(q?.options) && Number.isInteger(q?.correct)
      ? String(q.options[q.correct] ?? '')
      : '';
  const recs = (questions ?? []).map((q) => {
    const text = answerOf(q);
    return {
      id: q?.id,
      urls: new Set((q?.sources ?? []).map((s) => String(s?.url ?? ''))),
      text: text.replace(/\s+/g, ' ').trim(),
      answer: tokensOf(text),
    };
  });
  const pairs = [];
  for (let i = 0; i < recs.length; i++) {
    for (let j = i + 1; j < recs.length; j++) {
      const shared = [...recs[i].urls].some((u) => recs[j].urls.has(u));
      if (!shared) continue;
      const score = jaccard(recs[i].answer, recs[j].answer);
      if (score < DUPLICATE_JACCARD) continue;
      pairs.push({
        a: recs[i].id,
        b: recs[j].id,
        jaccard: Number(score.toFixed(3)),
        // ⚠️ 정답이 짧으면 자카드가 과민하다 — 토큰 수를 함께 적어 사람이 판단한다.
        // 2026-11-11 실측: CLF 는 「안정성(Reliability)」처럼 정답이 2토큰인 문항이
        // 많아 그런 쌍의 자카드가 1.0 으로 나온다(그중 실제 중복도 있다).
        tokens: [recs[i].answer.size, recs[j].answer.size],
        // 정답 문자열이 같은 쌍은 자카드보다 강한 증거다.
        identicalAnswer: recs[i].text === recs[j].text && recs[i].text !== '',
      });
    }
  }
  return pairs;
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
    // ⚠️ 품질 신호는 **결함 단정이 아니다** — `flaggedCount`와 분리해 둔다.
    qualityFlags: qualityFlags(q),
  }));
  const flaggedCount = questions.filter(
    (q) => q.structuralFlags.length || q.scopeFlags.length,
  ).length;
  const qualitySignalCount = questions.filter((q) => q.qualityFlags.length).length;
  return {
    cert: cert.label,
    taskId,
    domain: bank?.domain,
    count: questions.length,
    bankFlags: bankScopeFlags(bank, cert),
    flaggedCount,
    qualitySignalCount,
    duplicateCandidates: duplicatePairs(bank?.questions),
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
  let totalQuality = 0;
  let totalDup = 0;
  let totalIdentical = 0;
  let totalQuestions = 0;
  const byKind = {};
  for (const bank of banks) {
    const pre = buildPrescreen(bank, cert);
    totalFlagged += pre.flaggedCount;
    totalQuality += pre.qualitySignalCount;
    totalDup += pre.duplicateCandidates.length;
    totalIdentical += pre.duplicateCandidates.filter((p) => p.identicalAnswer).length;
    totalQuestions += pre.count;
    for (const q of pre.questions) {
      for (const fl of q.qualityFlags) {
        const kind = fl.split(':')[0];
        byKind[kind] = (byKind[kind] ?? 0) + 1;
      }
    }
    if (pre.bankFlags.length) totalBankFlagged++;
    writeFileSync(
      appPath(`${rel}/${pre.taskId}.prescreen.json`),
      `${JSON.stringify(pre, null, 2)}\n`,
    );
  }
  const pct = (n) =>
    totalQuestions ? ` (${((n / totalQuestions) * 100).toFixed(0)}%)` : '';
  const kinds = ['length-cue', 'meta-phrasing', 'authoring-memo', 'explanation-long']
    .map((k) => `${k} ${byKind[k] ?? 0}${pct(byKind[k] ?? 0)}`)
    .join(' · ');
  console.log(
    `prescreen(${cert.label}): ${banks.length} Task → ${rel}/*.prescreen.json ` +
      `(구조·정합성 플래그 문항 ${totalFlagged}건, 뱅크 플래그 ${totalBankFlagged} Task). ` +
      `의미·정답·출처 정확성은 T2/사람 패스.\n` +
      `  품질 신호 ${totalQuality}/${totalQuestions}문항${pct(totalQuality)} — ${kinds}\n` +
      `  Task 내 중복 후보 ${totalDup}쌍(정답 문자열 동일 ${totalIdentical}쌍).\n` +
      `  ⚠️ 신호는 결함 단정이 아니라 사람이 읽을 후보이고 거짓 양성이 있다 ` +
      `(비율이 높으면 결함이 아니라 저작 스타일일 수 있다).\n` +
      `  ⚠️ 중복은 Task 내만 보고 지표는 하한이다 — 교차 Task 와 임계 아래 중복은 ` +
      `사람이 읽어야 한다(2026-11-11 외부 검수가 임계 0건인 SCS 에서 13묶음을 찾았다).`,
  );
}

export function main(argv) {
  const [cmd, code] = argv;
  if (cmd === 'build' && code) return cmdBuild(code);
  console.error(
    `사용법: node tool/prescreen.mjs build <cert>   (${Object.keys(CERTS).join('·')})`,
  );
  process.exit(1);
}

if (
  import.meta.url === `file://${process.argv[1]}` ||
  process.argv[1]?.endsWith('prescreen.mjs')
) {
  main(process.argv.slice(2));
}
