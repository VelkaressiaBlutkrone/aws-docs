# SAA md→문항 전파 실패 — 완료 (PR #165, 머지 전)

- PR: https://github.com/VelkaressiaBlutkrone/aws-docs/pull/165 (base `develop`, head `saa-review/propagation`)
- 커밋: `dcbdaa1` · 분기 base `fb0088c` (= `origin/develop`, PR #164 머지 직후)
- 세션: trusting-turing-2955d7
- 1단계 판정 근거 전문: [saa-propagation-step1-verdicts.md](saa-propagation-step1-verdicts.md)
- 검수지: `docs/saa-review/2026-10-20-propagation-review-sheet.md`

## 결과

히트 실측 **15건**(PR #164 머지 후) → **fix 5 · rewrite 2 · 제외 8**.
`correct` 인덱스 · 보기 개수 · 문항 id · `verified` 플래그 · `questionCount` **전부 무변경**.

| 문항 | verified | 판정 |
|---|---|---|
| `saa-t1-1-q10` AD=SAML IdP | false | `fix` (해설 + **정답 보기** — 보기만 두면 내부 모순) |
| `saa-t4-2-q14` Graviton3 기준 | **true · 라이브** | `fix` (약 20% → **최대 20%**, 패밀리 기준) |
| `saa-t4-1-q8` Terminate 과금 | false | `fix` (+ 기존 오답근거[3]과의 내부 모순 정리) |
| `saa-t4-1-q2` 절감액 초과 | false | `fix` (128KB 미만은 모니터링 요금 자체가 없음) |
| `saa-t4-4-q4` 시간당 ENI | false | `fix` (엔드포인트·AZ별 시간 요금) |
| `saa-t3-9-q14` 샤드 자동 증가 | false | **`rewrite`** (stem에 프로비저닝 모드 한정) |
| `saa-t2-2-q3` Lambda 15분 | false | **`rewrite`** (기본 용량 모드 한정 + LMI 90분) |

## 게이트 실측

| 게이트 | 결과 |
|---|---|
| `flutter test` | **1,288 그린** (exit 0). base `fb0088c` 1,242 + 신규 가드 46 |
| `flutter analyze` | **No issues found!** (0건) |
| `node tool/saa_prescreen.mjs build` | 24 Task **구조 플래그 0건** |
| 신규 가드 RED | 수정 **전** `+39 -7` — 실패 7건이 타깃 7건과 정확히 일치 |

## 다른 세션이 알아야 할 것

1. **전파 가드 설계의 핵심: 오답 보기를 검사 범위에서 빼야 한다.** 오답 보기는 일부러
   틀린 서술이라 금지 문장이 거기 있는 것은 결함이 아니다. `saa_question_propagation_test.dart`
   는 `stem`·`skill`·`options[correct]`·`explanation`·`wrongExplanations`만 본다. 이 설계 덕에
   RED가 정확히 타깃 7건으로 떨어졌다(거짓양성 0). 다른 계열(SOA·DEA) 가드를 만들 때도
   같은 범위를 쓸 것.
2. **`wrongExplanations`는 검사해야 하지만 반박 인용 위험이 있다.** 실제 오류가 거기 있던
   사례(`saa-t4-4-q4`)가 있어 범위에 넣었다. 대신 반박문이 그대로 인용하기 쉬운 과장
   표현(`유일한 …` 류)은 금지 목록에서 뺐다. 나중에 반박 인용으로 터지면 **항목을 지우지
   말고 더 좁은 문구로 바꿀 것**(파일 주석에 적어 뒀다).
3. **md 가드 리터럴을 그대로 전역 금지로 올리면 안 된다.** `saa_t1_facts_test.dart`
   G-1.1-08처럼 **md의 부분 구간만 잘라 쓰는 단정**이 있다(`ap-northeast-2`를 자가점검 Q1
   구간에서만 금지). 69건 중 24건을 제외했고 기준은 파일 상단 주석에 있다.
4. **`skill` 라벨은 사용자 데이터다.** 약점 리포트(`wrongSkills`)가 `skill` 문자열을 키로
   적재하므로 라벨을 바꾸면 기존 적재 키가 고아가 된다. `Aurora Serverless v2` 명칭 정리를
   이 PR에서 뺀 결정적 이유다(아래).
5. **JSON 수정은 원문 바이트 치환으로.** `sources` 배열에 항목을 **끝에** 삽입해야 한다 —
   첫 항목 뒤에 넣으면 항목이 2개 이상인 파일(`saa-t4-4`)에서 `},,` 가 생겨 JSON이 깨진다
   (이번에 실제로 만들었다가 되돌렸다). 스크립트는 전부 치환 성공한 뒤에만 파일을 쓰게
   만들 것(중간 실패 시 아무것도 안 써야 한다).
6. **Windows 콘솔은 cp949다.** 파이썬 스크립트가 em dash(`—`)를 print하면
   `UnicodeEncodeError`로 죽는다. `PYTHONIOENCODING` 환경변수는 `py` 런처에서 듣지 않았고,
   스크립트 안에서 `sys.stdout.reconfigure(encoding="utf-8")` 로 해결했다.
7. **SOA에는 같은 전파 실패가 없다.** `soa_facts_test.dart` 금지 15건 × 문항 20파일
   **히트 0건**으로 실측했다. DEA는 확인하지 않았다(가드 파일이 있는지도 안 봤다).

## 남은 것 (사람 전용)

- 7문항 판정 확정, 특히 `rewrite` 2건의 **출제 의도 변경 승인**
- `saa-t4-2-q14` 라이브 문구 변경 확인
- PR #165 머지 — 이 세션은 머지하지 않았다

## 별건으로 분리한 것

**`Aurora Serverless v2` 명칭 현대화** — `saa-t3-5` 1문항 · `saa-t4-3` 5문항, **두 Task 모두
15/15 flip = 라이브**. `stem`·`options`·`explanation`·`wrongExplanations`·**`skill` 라벨**·
출처 `title` 에 걸려 있다. 공식 RDS 가이드 제목·본문은 "Aurora serverless"로 바뀌었지만 URL
슬러그와 AWS 블로그는 여전히 `v2`를 쓴다 — **사실 오류가 아니다.** `skill` 라벨
마이그레이션 방침이 정해진 뒤 별도 PR로 처리하고, 그때 `_rules`에 그 문장을 추가하면 된다.

## 확인하지 못한 주장 (손대지 않음)

- `saa-t2-2-q3` 오답근거[0] "Lambda 메모리 128 MB ~ 10,240 MB" (기존 서술, 범위 밖)
- `saa-t4-2-q14` 오답근거[2]의 **ElastiCache** Graviton 지원 (다른 서비스는 공식 확인)
- `saa-t4-4-q4` 해설의 NAT 처리 요금 `$0.045/GB` (기존 서술, 범위 밖)
- `saa-t3-9-q14`의 "이전 30일 피크 2배"는 1차 가이드가 아니라 AWS 비용 모델링 백서 서술
