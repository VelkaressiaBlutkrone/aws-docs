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
