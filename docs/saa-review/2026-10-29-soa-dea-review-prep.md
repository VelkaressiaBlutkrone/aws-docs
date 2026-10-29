# SOA-C03 · DEA-C01 문항 검수 — 착수 이관 노트 (2026-10-29)

_SAA-C03(360)·MLA-C01(321) 검수와 전 문항 공개가 끝난 뒤, 남은 두 자격증의 검수를 **처음부터** 맡는 세션을 위한 노트. 경위는 [HANDOFF.md](../../HANDOFF.md) §0-2026-10-29, 현황 인덱스는 [WORKLIST.md](../../WORKLIST.md) §B⑫, 루브릭은 [review-rubric.md](review-rubric.md)._

> **이 노트의 역할:** SAA·MLA에서 **실측으로 드러난 함정**을 같은 자리에서 다시 밟지 않게 하는 것. 아래 수치·줄 번호는 전부 2026-10-29에 측정했고, 추측은 없다. 측정 명령을 함께 적었으니 시간이 지났으면 다시 재라.

---

## 0. 지금의 사실 (2026-10-29 실측, develop `b5b02e8`)

| 자격증 | 학습문서 | Task | 드래프트 문항 | `verified` | 모의고사 게이트 |
|---|---|---|---|---|---|
| **SOA-C03** | 20편 | 20 | **300** | **0** | 🔒 locked |
| **DEA-C01** | 17편 | 17 | **256** | **0** | 🔒 locked |
| (참고) SAA-C03 | 24편 | 24 | 360 | **360** | ✅ 개방 |
| (참고) MLA-C01 | 12편 | 12 | 321 | **321** | ✅ 개방 |

`verified`가 0이라 **두 자격증은 사이트에 문항이 한 건도 노출되지 않는다**(`content_index`의 `questionCount`도 전부 0). 학습문서 37편은 이미 라이브다 — 그래서 **문서 본문을 고치면 즉시 라이브에 반영되고, 문항을 고치는 것은 노출이 없다.** 이 비대칭이 SAA에서 반복해서 문제가 됐다(§4-③).

```sh
# 수치 재측정 — flutter_app에서
node -e 'const fs=require("fs"),p=require("path");
for (const c of ["soa","dea"]) { const dir="assets/content/"+c; let t=0,v=0,n=0;
  for (const f of fs.readdirSync(dir).filter(f=>f.endsWith(".questions.json"))) {
    const q=JSON.parse(fs.readFileSync(p.join(dir,f),"utf8")).questions||[];
    n++; t+=q.length; v+=q.filter(x=>x.verified===true).length; }
  console.log(c, "tasks="+n, "total="+t, "verified="+v); }'
```

---

## 1. 게이트 산술 — 몇 Task를 flip하면 열리나

게이트는 `certExamHasWeightedCapacity(cert)`이고, **공식 도메인 비중을 앱의 연습 65문항에 배분한 값**을 도메인별로 채워야 열린다. **정책은 두 자격증 모두 이미 들어가 있다**(#254) — 추가 작업 없음. ⚠️ 정책이 없으면 `hasPolicy:false → ready:false`로 **fail closed**라, 사람이 전 문항을 flip해도 영원히 잠긴 채다(MLA가 #246 전까지 그랬다).

**SOA-C03 — 도메인이 5개다**(공식명 CloudOps Engineer, 가이드 v1.1). 비중 22·22·22·16·18 → 필요 **D1 14 · D2 14 · D3 14 · D4 11 · D5 12**(합 65).

| 도메인 | Task (문항 수) | 필요 | 최소 Task |
|---|---|---|---|
| D1 | `soa-t1-1`~`t1-5` (각 15) | 14 | **1** |
| D2 | `soa-t2-1`~`t2-4` (각 15) | 14 | **1** |
| D3 | `soa-t3-1`~`t3-4` (각 15) | 14 | **1** |
| D4 | `soa-t4-1`~`t4-3` (각 15) | 11 | **1** |
| D5 | `soa-t5-1`~`t5-4` (각 15) | 12 | **1** |

→ **도메인당 1 Task, 5 Task 75문항**이면 열린다.

**DEA-C01** — 비중 34·26·22·18 → 필요 **D1 22 · D2 17 · D3 14 · D4 12**.

| 도메인 | Task (문항 수) | 필요 | 최소 Task |
|---|---|---|---|
| D1 | `dea-t1-1`(16) `t1-2`~`t1-4`(각 15) | 22 | **2** |
| D2 | `dea-t2-1`~`t2-4` (각 15) | 17 | **2** |
| D3 | `dea-t3-1`~`t3-4` (각 15) | 14 | **1** |
| D4 | `dea-t4-1`~`t4-5` (각 15) | 12 | **1** |

→ **6 Task 91문항**이면 열린다(D1·D2는 15 < 필요라 2 Task씩).

⚠️ **부분 flip은 "열림"이 아니다.** Task 하나만 flip하면 `certHasVerifiedQuestions`가 true가 되어 **약점 모의고사 줄이 잠긴 채로 노출**되고 통합 모의고사는 "준비 중"으로 남는다(MLA의 t2-2 단독 flip에서 실측). 도메인 하나라도 미달이면 게이트는 닫힌 채다.

---

## 2. ⚠️ flip 선결 — **사람이 flip하기 전에** 바꿔야 하는 테스트 단정

`review.mjs flip`은 파일을 **다 쓴 뒤** 마지막에 `flutter test <cert.tests>`를 돌린다(`tool/review.mjs` `cmdFlip` 끝). `cert.tests`는 SOA가 `soa_questions_test.dart` + **`content_index_test.dart`**, DEA가 `dea_questions_test.dart` + **`content_index_test.dart`**다. 그래서 `content_index_test.dart`에 상태를 박은 단정이 남아 있으면 **flip 명령이 레드로 끝나고, 파일은 이미 바뀐 상태로 남는다.**

> 2026-10-28에 실제로 일어났다 — 검수자가 `review.mjs flip saa saa-t2-5`를 돌렸고 `content_index_test.dart`의 `'SAA-C03: 현재는 locked (D2 미달)'`에서 멈췄다. `--force`는 **쓰기 전** 구조 플래그 검사만 건너뛰므로 소용없다.

### 게이트가 열리는 순간 깨지는 단정

| 파일 | 줄(2026-10-29) | 단정 | 언제 깨지나 |
|---|---|---|---|
| `test/content_index_test.dart` | 303~306 | `'SOA-C03·DEA-C01: 정책 추가 후에도 현재는 locked'` — 두 cert 모두 `isFalse` | **어느 쪽이든 게이트 개방 시** |
| `test/cert_exam_restore_test.dart` | 110 | `certExamHasWeightedCapacity('DEA-C01')` = `isFalse` (+ 잠금 화면 렌더 3건: 118·120·127·265·267) | **DEA 개방 시** |
| `test/home_sections_test.dart` | 113·115·120·135 | DEA가 `'통합 모의고사 · 준비 중'`·`'DEA-C01 통합 모의고사는 아직 준비 중입니다.'` | **DEA 개방 시** |
| `test/weighted_exam_test.dart` | 112~137 | DEA `certWeightedExamUnlocked` = `isFalse` | **DEA 개방 시** |

**순서는 ① 선언 변경 → ② 사람 flip → ③ 커밋·PR.** 선언 변경은 AI가 해도 되는 코드 작업이고, flip만 사람 몫이다.

### 깨지지 않도록 이미 유도형으로 바꿔 둔 것 (건드리지 말 것)

| 파일 | 어떻게 |
|---|---|
| `content_index_test.dart:260` | `availableByDomain`을 **`contentFor(code)`에서 계산**해 대조 — flip 상호형이라 어느 Task를 flip해도 통과한다 |
| `content_index_test.dart:290` | `examWeightedCapacityStatus(code, entries: const [])` — 빈 엔트리를 주입하므로 실제 verified 수량과 무관 |
| `home_sections_test.dart:139` | 진행 라벨을 `domainProgressLabel`에서 **계산**해 대조(`'D1 0/19'` 같은 리터럴을 박지 않는다) |
| `cert_detail_sections_test.dart:94` | **합성 `ContentEntry`**(`questionCount: 15`)를 직접 만들어 "문항은 있는데 비중 미달" 상태를 재현 — 표본 cert의 flip에 묶이지 않는다 |

⚠️ **상태 숫자를 테스트에 박지 마라.** 2026-10-27~29에 이 한 가지가 flip을 세 번 막았다(`content_index_test`의 locked 선언 2회 + `home_sections`의 `'D1 0/19'` + `saa_t1_facts_test`의 `'35일'`). **정책값만 리터럴로 남긴다.**

---

## 3. ⚠️ "잠긴 cert" 표본 — **다음에 옮길 곳이 없다**

위 4개 파일 중 3개는 "게이트가 잠긴 자격증"을 표본으로 써서 잠금 화면·준비 중 라벨을 검증한다. 그 표본은 이미 두 번 이사했다:

```
SAA-C03  --(2026-10-28 SAA 게이트 개방)-->  MLA-C01  --(2026-10-29 MLA 개방)-->  DEA-C01
```

**DEA를 열면 콘텐츠가 있는 5종(CLF·SAA·SOA·DEA·MLA)이 전부 개방된다 → 옮길 cert가 남지 않는다.** 그래서 DEA 개방 PR은 표본을 **구조적으로** 풀어야 한다. 측정해 둔 제약:

- **정책 없는 cert로 대체할 수 없다.** `ExamReadinessStatus.domainProgressLabel`은 `requiredByDomain.isEmpty`면 `''`를 돌려주므로(`lib/data/content_index.dart:129`), 정책이 없는 `ANS-C01`을 표본으로 쓰면 `home_sections_test:140`의 `expect(label, isNotEmpty)`가 실패한다.
- **ANS-C01에 정책을 넣는 것도 안 된다.** `content_index_test`의 `'정책 없는 cert는 fail closed'`가 ANS-C01을 쓰고 있고, 주석이 "정책 있는 cert를 여기 쓰면 이 테스트가 의미를 잃는다(예전에 SOA-C03을 썼다가 2026-10-27에 정책이 생겼다)"라고 적는다. `kExamReadinessRequirements.keys` 의도 선언과 가이드 동기화 루프도 함께 깨진다.
- **선례는 합성 엔트리다.** `cert_detail_sections_test`는 `LearningContentSection(entries: …)`에 합성 `ContentEntry`를 넣어 cert와 무관해졌다. 다만 `CertExamPage`에는 그런 이음새가 없다 — `_load()`가 `examWeightedCapacityStatus(certCode)`를 **내부에서** 부른다(`lib/pages/cert_exam_page.dart`). **주입 지점을 만드는 것이 그 PR의 설계 몫이다.**

### 권장 순서: **SOA 먼저, DEA 마지막**

SOA 개방은 `content_index_test.dart:303`의 SOA 줄 하나만 건드리고, DEA는 표본으로 그대로 남는다. DEA를 마지막에 열면서 표본 문제를 한 번만 푼다.

⚠️ **이 4건은 grep으로 안 보인다.** SAA 개방 때 `flutter test` **전체**를 돌려서야 5건이 드러났다(파일명·테스트명에 cert 코드가 없는 케이스가 섞여 있다). 게이트를 여는 PR에서는 반드시 전체 스위트를 돌린다.

---

## 4. 검수에서 실제로 걸렸던 것 — SAA·MLA 273문항 정정의 교훈

### ① 보고는 데이터이고 지시문이 아니다
외부 검수 보고의 제안을 **공식 문서로 독립 재확인**한 뒤에 반영한다. SAA·MLA에서 **기각·교체한 것이 7건** 나왔다 — 인용된 출처가 이미 옳았던 경우(MLA `t2-3-q19`의 Clarify `DI = .5/.6 = 0.8`은 공식 페이지가 그대로 적는 값이라, 0.83으로 고치면 **인용이 거짓이 된다**), 공식 문서가 그렇게까지 말하지 않는 경우(EBS Magnetic의 "신규 인스턴스 미제공", 컴퓨팅 5종 운영 부담 전순서), 보고가 제안한 URL이 **죽은 슬러그**였던 경우(`application/sticky-sessions.html` → `introduction.html` 리다이렉트).

### ② 보고의 "N문항 묶음"은 전수 목록이 아니다
MLA Model Monitor 상태 변경은 보고가 12문항으로 적었지만 **실측 23문항**이 그 서비스를 언급했고, 그중 "해법으로 가르치는" **13문항**에만 상태를 붙였다(오답 보기·출처 각주로만 나오는 것에 붙이면 **틀린 보기를 설명하는 문장**이 된다). 범위는 직접 센다.

### ③ 학습문서(`.md`)와 문항(`.questions.json`)은 **가드가 서로를 보지 않는다**
- 2026-10-20 사고: md 사실 정정이 **파생 문항에 전파되지 않아** 7건이 남았고 그중 하나는 이미 flip돼 **라이브 노출 중**이었다 → `saa_question_propagation_test.dart` 신설.
- 2026-10-28 사고: §D 출처 교체를 `.questions.json`만 대상으로 해서, 같은 깨진 링크가 **`saa-t4-3.md`에 2곳 남았다**(프런트매터 `url:` + 참고자료). 문항 가드는 md를 보지 않는다.
- ⚠️ **SOA·DEA에는 전파 가드가 없다.** `saa_question_propagation_test.dart`에 해당하는 판이 없으니, 같은 사고가 같은 구조로 재현될 수 있다(§6-④).
- **문서가 틀렸으면 문서부터 고친다**(루브릭 T6). 문항이 md에서 파생됐는데 md가 원인이면, 문항만 고치면 다음 파생에서 되살아난다.

### ④ 정정이 연쇄한다
SAA `t3-5-q2`의 "읽기 복제본 5개 → 15개" 정정이 `q12`의 참인 보기 B를 구분 불가로 만들어, `q12` 지문에 **페일오버 시간 최소화** 요건을 함께 넣어야 했다. 한 문항을 고치면 **같은 사실을 쓰는 다른 문항**을 함께 본다.

### ⑤ 참인 보기를 오답으로 두면 정답이 둘이 된다
"정답 모호" 판정의 실제 원인은 대개 **지문이 갈림길을 말하지 않음** 또는 **오답 보기가 참**이었다. SAA 2차 검수에서 **정답 인덱스가 바뀐 것은 전체 273문항 중 1건**(`saa-t2-3-q4`, 사용자 승인)이고, 나머지는 전부 지문·보기·해설 수정으로 닫혔다. ⚠️ **정답 인덱스를 바꾸는 건은 사용자 승인을 받는다.**

### ⑥ 문항 교체는 옛 가드를 지운다
문항을 통째로 교체하면 그 `qid`를 참조하던 가드가 사라진다(2026-10-29에 7건). 교체 전에 `grep -rn "<qid>" test`로 세고, 옮길 수 있는 단정은 새 문항으로 옮긴다.

### ⑦ 작성 과정 메모를 문항 본문에 남기지 않는다
"공식 문서에서 확인되지 않았으므로…", "원문에 나오지 않지만…" 같은 **작성자의 검증 상태** 서술이 문항 본문에 섞여 있었다(SAA·MLA 합계 8개소 + 출처 **제목**에 숨은 2건). MLA 가드 **M2**가 이것을 0으로 고정한다 — SOA·DEA 판은 없다. ⚠️ 출처 제목에 든 것은 본문 집계로 안 잡혀 **집계형 테스트**가 따로 필요했다.

---

## 5. 도구와 프로토콜

```sh
cd flutter_app
node tool/review.mjs build soa      # build/SOA-C03_review/index.html 생성 (20 Task, 300문항)
node tool/review.mjs build dea      # build/DEA-C01_review/index.html 생성 (17 Task, 256문항)
node tool/review.mjs flip soa soa-t1-1   # ⚠️ 사람만. 실행 자체가 검수자의 서명이다
```

- `flip`이 하는 일: 해당 Task 문항의 `verified`를 true로 + `content_index.dart`의 `questionCount`를 실제 수로 + (MLA에만 있는) `flipApprovedTaskIds` 갱신 → 끝에 `cert.tests`를 돌린다.
- **`flipAllowlist`는 MLA에만 있다.** SOA·DEA는 Dart 허용 목록이 없으므로, MLA처럼 "목록 밖의 `verified:true`를 막는 가드"가 없다. 같은 가드를 둘지는 미결정.
- **`verified:true` flip은 사람 전용이다(AI flip 금지).** 이것이 이 레포의 최상위 규율이고, 이관받는 세션도 예외가 아니다.
- 루브릭 [review-rubric.md](review-rubric.md)의 §0(착수 전)·§2(문항별 루브릭)·§3(수정 루프)·§5(승인 로그)를 따른다.

---

## 6. 검수 **전에** AI가 할 수 있는 준비 작업

사람 검수를 기다리지 않고 지금 할 수 있는 것들. 우선순위순이고, 각각 별건 PR이다.

1. **루브릭 자격증 확장** — [review-rubric.md](review-rubric.md)는 제목이 `SAA-C03 · MLA-C01`이고 §1 권장 순서가 SAA 비중(D1 30%…)으로 적혀 있다. **SOA(5도메인!)·DEA의 비중 표와 권장 순서**를 넣는다. §1의 자격증별 weighted capacity 표도 두 자격증을 더한다.
2. **flip 선결 — 선언 정리** (§2) — `content_index_test.dart:303`을 자격증별로 분리해 SOA 개방 PR이 DEA 줄을 건드리지 않게 하고, DEA 표본 문제(§3)의 구조적 해소를 설계한다. **게이트를 열기 전에 미리** 해 두면 flip이 레드로 끝나지 않는다.
3. **구조 전수 사전심사** — `soa_questions_test`·`dea_questions_test`는 구조(파일·수량·`correct` 범위·`wrongExplanations` 키·`sources` http 시작)만 본다. ⚠️ **출처 URL이 실재하는지는 어느 가드도 보지 않는다** — MLA 도메인 3에서 작성 URL 23건이 실제 오류였고, SAA에서 `rds-reserved-instances.html`이 **6문항에서** 죽은 링크였다. SOA 300 + DEA 256의 `sources`를 전수 수집해 실측(`curl -o /dev/null -w '%{http_code} %{url_effective}'`)하는 것이 가장 값싼 사전심사다.
4. **전파 가드 SOA·DEA 판 신설** (§4-③) — md 가드의 금지 문장 목록과 문항 전수를 대조하는 테스트. SAA 판이 그대로 본이 된다.
5. **prescreen 도구 자격증 일반형** — `tool/saa_prescreen.mjs`는 SAA 전용이다. `review.mjs`가 이미 `CERTS` 레지스트리로 일반화돼 있으니(#247) 같은 방식으로 돌린다.
6. **이탤릭 평문화** (§7) — 검수와 **같은 `.md`를 건드리므로** 검수 착수 전에 끝내 두는 쪽이 충돌이 없다.

---

## 7. 인접 트랙 — 같은 파일을 건드리므로 순차로

- **평문 표기 이탤릭 잔여** — `soa 145 · dea 194`(코드 스팬 제외 정밀 계수, 2026-10-27 실측. 가드 레시피 기준으로는 `soa 144 · dea 194`). 괄호 주석 비중이 **soa 134/145**로 높아 대부분 "별표만 지우기"로 끝나지만 **dea는 3/194**라 건별 판단이 거의 전부다. 기준·함정은 [WORKLIST.md](../../WORKLIST.md) §B⑪.
- **SOA 갭 노트 §3 「없음」 6개** — 배치 대상(「부분」 45는 커버리지 등급이라 제외). 정본 `docs/content-research/SOA-C03/98-existing-gap.md`.
- **DVA-C03 전환** — 가이드 공개 확인 후 `exam_guides/DVA-C03.json` 신설 + `site_data.dart`·`web/index.html`의 `DVA-C02` 하드코딩 동시 교체.

---

## 8. 레포 환경 함정 (시간을 가장 많이 먹은 것들)

메모리 `repo-toolchain-gotchas`가 정본이고, 검수 작업에서 반복해 걸린 것만 옮긴다.

- **`grep -P`가 이 환경에서 실패한다**(`-P supports only unibyte and UTF-8 locales`) — **0건을 돌려주므로 "이미 끝났다"고 오판하게 된다.** 0건이 나오면 **대조군을 먼저 세운다.**
- **문항 JSON은 작업트리 CRLF · git blob LF**다 — `JSON.parse` → `stringify` 왕복을 하면 **전 파일이 변경으로 잡힌다.** 바이트 블록 치환 + **치환 횟수 1 단정**으로 고친다.
- **`python`은 exit 49**(스토어 스텁), **`python3 -V`는 node 버전**을 뱉는다 → **`py`를 쓴다.**
- **치환 스크립트에 단정을 넣는다.** 2026-10-28에 `saa-t4-3.md` 치환이 **단정 두 번에 두 번 막혔다**(대체 URL이 이미 1건 있었다 → 중복 발견 / 참고자료가 11개가 아니라 27개였다). 단정이 없었으면 둘 다 조용히 잘못 썼다.
- **라이브 검증:** 에셋 경로는 `/aws-docs/assets/assets/content/<cert>/…`(`assets` 두 번), md5는 **git blob과** 대조(워킹 카피는 CRLF), **대조군은 머지 전에** 잡아야 "일치"가 전파의 증거가 된다.
- **`gh … --watch | tail`은 종료 코드를 가린다** — 파이프라인 exit는 `tail`의 것이라 **CI가 빨개도 exit 0**이다. 판정은 `gh run view --json conclusion,headSha`로.
- **`gh pr merge` 후 로컬 `origin/main`은 머지 전** 상태다 — `git fetch` 먼저.
