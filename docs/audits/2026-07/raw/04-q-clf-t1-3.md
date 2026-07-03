# ④ 문항 품질 감사 샤드 — 04-q-clf-t1-3 — 2026-07

## 요약
- 대상: `flutter_app/assets/content/clf/t1-3.questions.json` 15문항(클라우드 마이그레이션·AWS CAF) — 예상 문항 수 15와 일치.
- 7개 점검 항목(정답 유일성·해설-정답 인덱스 일치·wrongExplanations 논리·section 앵커 실존·skill/difficulty 태그·AWS 사실 오류·스키마 위생) 전 문항 수행.
- **전 점검 통과 13문항, 발견 2건(전부 L·태그 자구, Phase A)** — H/M 0건, 사실의심 0건.
- 스키마: id 15개 유일, correct 전부 0..3 범위, verified 전부 true, 옵션 전부 4개. wrongExplanations는 15문항 모두 정답 외 3개 키 완비·실제 반박 확인(부정형 문항 q2·q6은 "이점/관점에 해당" 형식으로 정합). section 값(caf·migration-tools·datasync-7r)은 t1-3.md의 `{#caf}`·`{#migration-tools}`·`{#datasync-7r}` 앵커에 전부 실존.
- 사실 대조: 7R 명칭(Rehost·Replatform·Refactor·Repurchase·Retire·Retain·Relocate, q10 해설), CAF 6관점(Business·People·Governance·Platform·Security·Operations, q6·q13), DMS(풀로드+진행 중 변경 복제=최소 다운타임, q4·q15)·SCT(이기종 전용, q7)·Snowball(오프라인 물리 전송, q3·q8·q14)·DataSync(온라인 자동화, q12) 구분 모두 학습문서·CLF-C02 관례와 일치, 오류 없음.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t1-3-01 | t1-3.questions.json:clf-t1-3-q3 | skill 태그가 "마이그레이션 전략 (Snowball)"인데 문항 내용은 전략(7R)이 아니라 전송 도구 선택. 같은 파일의 도구 문항들은 "DMS vs Snowball"(q4)·"마이그레이션 도구 조합"(q9)·"대량 데이터 전송 도구 선택"(q14) 등 도구 계열 명칭 사용 — "전략" 표기는 7R 문항(q10·q11)과 의미가 섞여 약점 리포트 표시 시 혼동 소지 | L | 중 | skill을 "마이그레이션 도구 (Snowball)" 등 도구 계열 명칭으로 정정 | A | N |
| Q-CLF-t1-3-02 | t1-3.questions.json:clf-t1-3-q10, clf-t1-3-q11 | skill 태그 표기 불일치: q10 "마이그레이션 전략 (7 R - Rehost)"(공백 있는 "7 R"+하이픈) vs q11 "마이그레이션 전략 (7R — Refactor)"(붙여 쓴 "7R"+전각 대시). 같은 7R 계열인데 자구가 달라 노출 시 일관성 저하 | L | 높 | "7R"·대시 표기를 한쪽으로 통일(예: "마이그레이션 전략 (7R — …)") | A | N |

## 점검 집계(통과 확인)

| 점검 항목 | 결과 |
|---|---|
| 1. 정답 유일성(CLF-C02 관례, CAF 6관점·7R 구분 포함) | 15/15 통과 — 부정형(q2·q6)·조합형(q9)·응용형(q13~q15) 포함 복수 정답 소지 없음 |
| 2. 해설-정답 인덱스 일치 | 15/15 통과 — correct≠0인 q6(3)·q7(2)·q8(1)·q10(2) 포함 어긋남 없음 |
| 3. wrongExplanations 키 정합·반박 논리 | 15/15 통과 — 누락 키 0, 각 키가 해당 옵션 텍스트를 실제 반박 |
| 4. section 앵커 실존 | 15/15 통과 — caf(5)·migration-tools(7)·datasync-7r(3) 모두 t1-3.md에 실존 |
| 5. skill·difficulty 태그 | 13/15 통과 — 자구 2건(상기 표), difficulty(foundational 12·applied 3)는 내용과 정합 |
| 6. AWS 사실 오류 | 15/15 통과 — 7R 명칭·CAF 관점 구성·DMS/SCT·Snowball/DataSync 구분 오류 없음 |
| 7. 스키마 위생(id 유일·correct 범위·verified·옵션 4개) | 15/15 통과 |
