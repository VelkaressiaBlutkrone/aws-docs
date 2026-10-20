# SAA-C03 `saa-t1-5` 검수 체크시트 — 2026-10-20

> 대상 batch: `saa-t1-5` (도메인 1 · 공식 **Task 1.3 데이터 보호를 위한 보안 제어 결정**).
> 전체 문항 원문과 선택지는 `flutter_app/build/saa_review/index.html`을 정본 뷰어로 본다.
> 이 문서는 사람 검수자가 판정을 확정하고 flip하기 위한 작업표다.
> 선행 batch는 [2026-08-06-weighted-ready-review-sheet.md](2026-08-06-weighted-ready-review-sheet.md),
> 운영 가이드는 [review-rubric.md](review-rubric.md).

**이 시트의 판정 열은 전부 「AI 권고 — 검수자 확정 필요」다.** `verified` flip과 최종 정답
판정은 사람만 한다(루브릭 머리말).

## 왜 이 batch인가

`saa-t1-5`는 **1순위 보강 batch**다. 선행 3 Task(`saa-t1-1`·`saa-t1-4`·`saa-t2-5`)를 flip하면
수량 게이트(`certExamHasWeightedCapacity`)는 D1 30/19·D2 30/17로 열리지만, **그 시점 D1 노출
문항은 공식 Task 1.3(데이터 보안 제어)을 전혀 다루지 않는다** — 그 Task에 해당하는 이 문서가
verified 0으로 남기 때문이다([batch 문서](2026-08-06-weighted-ready-batch.md) 리스크 항목).

## 검수 메타 (루브릭 §5 승인 로그의 근거)

| 항목 | 값 |
|---|---|
| 검수자 | _(기입)_ |
| 검수일 | _(기입)_ |
| 브랜치 | `saa-review/t1-5` |
| 기준 커밋 | `e306b45` (분기 base = `origin/develop`) |
| AI 재검수 수행 | 2026-10-20 · 공식 문서 대조 |
| advisory | [prescreen/saa-t1-5.json](prescreen/saa-t1-5.json) (`needsReview` 11건 — **참고값**) |

## 이 batch의 원인 — 문서는 고쳐졌고 문항은 안 고쳐졌다

`saa-t1-5.md`는 **2026-10-19에 8건 정정**됐다(md 끝 정정 로그). 그 정정이 파생 문항에
전파되지 않아, 문항이 **구식 사본**으로 남아 있었다. 내용 결함 5건이 전부 md가 이미
바로잡은 항목이다:

| md 2026-10-19 정정 | md 현재 서술 | 문항이 들고 있던 구식 서술 |
|---|---|---|
| ③ AWS 관리형 키 ≠ AWS 소유 키 | 관리형 키는 "내 계정에 있어 보이고 감사할 수 있지만" | `q2` "AWS 소유로 고객이 정책을 변경하는 것이 불가능" |
| ① 키 정책·IAM 관계(위임/직접 허용/암시적 거부) | 계정 위임 문장 기준으로 서술 | `q4` "IAM 정책과 키 정책의 **교집합**" |
| ② FIPS 결정 규칙 → 단일 테넌트 기준 | "FIPS Level 3만으로는 CloudHSM이 정답이 아니다" | `q5` "KMS는 **멀티테넌트**라 AWS가 키에 접근" |
| ⑥ ACM 자동 갱신(DNS 검증·45일) | "이메일 검증 인증서는 소유자가 갱신 메일에 응답" | `q7` "DNS 검증 **또는** 이메일 검증이 유효해야 자동 갱신" |
| ⑦ Vault Lock 유예 = 사용자 지정 최소 3일 | "최소 3일(72시간)·최대 36,500일" | `q13` "쿨다운(**기본** 3일)" |

→ 반영은 **문항을 이미 검증된 md 기준으로 맞춘 것**이고, md 출처 목록(5·6·7·9·11·12번)을
문항 출처로 재사용했다.

## 공통 체크

- [x] `saa-review/*` 브랜치에서 작업 (`saa-review/t1-5` — SAA 콘텐츠 freeze 규약)
- [x] `node tool/saa_prescreen.mjs build` 구조 플래그 0건 (반영 **전**)
- [x] `fix` 반영 후 `saa_prescreen.mjs build` **재실행** → 구조 플래그 0 재확인
- [x] 각 문항에 `review-rubric.md` C1~C6 적용 (AI 권고)
- [x] `correct`(정답 인덱스)·보기 개수 무변경 — 회귀 가드로 고정
- [ ] `node tool/saa_review.mjs build` 결과 HTML 뷰어 열람 (**사람**)
- [ ] 15문항 판정 확정 (**사람**)
- [ ] `node tool/saa_review.mjs flip saa-t1-5` (**사람 전용**)
- [ ] flip 후 자동 실행되는 `saa_questions_test` / `content_index_test` 통과 확인

## 집중 확인 문항 (내용이 바뀐 6건)

내용이 바뀐 문항만 싣는다. **정답 인덱스는 하나도 바뀌지 않았다.**

- [ ] `saa-t1-5-q2` — KMS 키 유형(AWS 관리형 vs CMK)
  - 현재 정답: 고객 관리형 키(CMK) — 인덱스 2 **(무변경)**
  - **판정: `fix` + `resource`.** 오답근거[1]이 AWS 관리형 키를 "AWS 소유"로 적어 **별개
    키 유형과 혼동**시켰다. 공식: AWS 관리형 키는 **내 계정에 존재**해 조회·감사되지만
    "수명 주기나 권한은 아무것도 관리할 수 없다". AWS 소유 키는 서비스 계정에 있다.
    연 1회 자동 교체는 사실이라 유지(공식: "KMS always rotates ... every year").
  - 출처 교체: KMS 개요 → `kms/latest/developerguide/concepts.html`

- [ ] `saa-t1-5-q4` — KMS 키 정책 필수성
  - 현재 정답: 키 정책에도 허용이 있어야 한다 — 인덱스 1 **(무변경)**
  - **판정: `fix` + `resource`.** 해설의 "키 정책에 역할이 **Principal로 명시되지 않으면**
    차단"이 과단정이었다. 공식: "키 정책이 명시적으로 허용하지 않으면 IAM 정책의 Allow는
    효력이 없다" + "**기본 키 정책은 IAM 정책을 활성화한다**". 허용 경로가 ①직접 허용
    ②계정 주체 위임 두 가지라 해설을 그렇게 고쳤다. 보기 1은 네 보기 중 유일하게 옳다.
  - 출처: `kms/.../key-policies.html` + `kms/.../control-access.html`

- [ ] `saa-t1-5-q5` — KMS vs CloudHSM 선택
  - 현재 정답: AWS CloudHSM — 인덱스 0 **(무변경)**
  - **판정: `fix` + `resource`.** 정답을 가르는 근거가 틀렸었다. 해설·오답근거가 "KMS는
    멀티테넌트라 AWS가 키에 접근"이라고 했지만, AWS는 **모든 키 저장소가 "AWS 운영자를
    포함해 누구도 평문 키에 접근하지 못하게" 설계됐다**고 명시한다. 진짜 갈림길은
    **단일 테넌트**다 — 공식: KMS 표준 키 저장소는 "테넌트 구분이 없는(tenant-agnostic)
    HSM 플릿"이고, "규정이 **단일 테넌트 HSM**에서의 키 보호를 명시적으로 요구할 때만"
    사용자 지정 키 저장소를 쓰라고 안내한다. 오답근거[2]가 **KMS도 FIPS 140-3 Level 3
    검증임을 인정**하는 서술은 사실이므로 유지했다(가드로 고정).
  - 출처 교체: KMS 개요 → `kms/.../key-store-overview.html`

- [ ] `saa-t1-5-q7` — ACM 인증서 자동 갱신 조건
  - 현재 정답: 인덱스 2 **(무변경)** — **보기 문구는 공식 기준으로 다듬었다**
  - **판정: `fix` + `resource`.** "DNS 검증 **또는** 이메일 검증이 유효해야 자동 갱신"은
    두 경로를 같게 취급해 틀렸다. 공식: ACM은 "**DNS 검증을 쓰는 경우** 자동 갱신하거나,
    아니면 만료 임박 **알림 메일을 보낸다**". 적격 조건에 "AWS 서비스에 연결돼 있음"도
    있고, **가져온(imported) 인증서와 만료된 인증서는 비적격**이다. 보기 2를 공식 기준
    문구로 고치고 해설에 45일·CNAME 확인 2조건을 넣었다.
  - 출처 교체: ACM 개요 → `acm/.../managed-renewal.html` + `acm/.../dns-renewal-validation.html`

- [ ] `saa-t1-5-q8` — ACM CloudFront 리전 제약
  - 현재 정답: us-east-1에서 발급해야 한다 — 인덱스 2 **(무변경)**
  - **판정: `fix`.** 해설이 "CloudFront **컨트롤 플레인**이 us-east-1을 거점으로 배포
    설정을 전 세계 엣지 PoP에 복제한다"는 기전을 댔는데 **공식 근거를 찾지 못했다.**
    공식 문구는 "us-east-1의 ACM 인증서가 CloudFront 배포에 연결되면 **그 배포에 설정된
    모든 지리적 위치로 배포된다**"까지다. 요구사항 자체(us-east-1 발급)는 공식이라 그대로
    두고 기전만 공식 문구로 교체했다. 출처(ACM 개요)는 이 문장을 직접 담고 있어 유지.
  - **같은 주장이 `saa-t1-5.md` §5·흔한 함정에도 있어 함께 제거했다** — 라이브 학습문서
    변경이다(아래 「라이브 영향」).

- [ ] `saa-t1-5-q13` — Backup Vault Lock(WORM)
  - 현재 정답: Vault Lock Compliance 모드 — 인덱스 1 **(무변경)**
  - **판정: `fix` + `resource`.** "쿨다운(**기본** 3일)"이 틀렸다. 공식: 유예 시간은
    **내가 지정**하며(`ChangeableForDays`) AWS Backup이 **72시간 쿨오프를 강제**하므로
    **3 이상**이어야 하고 최대 36,500일이다. "계정 루트 및 **AWS Support** 포함"에서
    AWS Support를 따로 열거한 공식 문장은 못 찾아 공식 문구("고객·계정 소유자는 물론
    **AWS**도" / "**루트 사용자**가 시도해도 거부")로 바꿨다.
  - 출처 추가: `aws-backup/.../vault-lock.html`

## 출처만 교체한 문항 (내용 무변경 5건)

인용 URL이 **주장을 뒷받침하지 않던** 것들이다. `q9`·`q10`·`q14`·`q15`는 전부 KMS 개요가
붙어 있었다 — `q9`·`q10`(Macie/Inspector)과 `q14`(RDS)는 **주제가 다른 복붙 오류**다.

| 문항 | 주제 | 교체 전 | 교체 후 (공식) |
|---|---|---|---|
| `q3` | 봉투 암호화·4KB 상한 | KMS 개요 | `kms/.../kms-cryptography.html` + `kms/latest/cryptographic-details/encrypt-operation.html` |
| `q6` | CloudHSM 서비스 통합 | CloudHSM 소개만 | + `kms/.../keystore-cloudhsm.html` |
| `q9` | Macie PII 탐지 | **KMS 개요(무관)** | `macie/latest/user/what-is-macie.html` |
| `q10` | Macie vs Inspector | **KMS 개요(무관)** | `inspector/latest/user/what-is-inspector.html` + Macie |
| `q14` | RDS 암호화 전환 | **KMS 개요(무관)** | `AmazonRDS/.../Overview.Encryption.html` + `USER_CopySnapshot.html` |
| `q15` | KMS CloudTrail 감사 | KMS 개요(상세 없음) | `kms/.../logging-using-cloudtrail.html` |

인용한 URL은 **전부 실제로 열어 문구를 확인**했다 — 슬러그를 추측하지 않았다.
`concepts.html#enveloping`은 **현재 그 페이지에 없어서**(TOC 실측: 키 유형·키 계층·키
식별자 절만 있음) `kms-cryptography.html`을 썼다.

## 15행 판정표

| 문항 | C1 | C2 | C3 | C4 | C5 | C6 | 판정 (AI 권고 — 검수자 확정 필요) | 메모 |
|---|:-:|:-:|:-:|:-:|:-:|:-:|---|---|
| `saa-t1-5-q1` | ✅ | ✅ | ✅ | △ | ✅ | ✅ | **pass** | 저장/전송 매핑 무중의. ACM 개요가 TLS 절반을 직접 뒷받침 |
| `saa-t1-5-q2` | ✅ | ✅ | **fix** | **fix** | ✅ | ✅ | **fix + resource** | 관리형 키를 "AWS 소유"로 오분류 → 내 계정 존재로 정정 |
| `saa-t1-5-q3` | ✅ | ✅ | ✅ | **fix** | ✅ | ✅ | **resource** | 4KB·봉투 암호화를 적은 페이지로 교체 |
| `saa-t1-5-q4` | ✅ | **fix** | ✅ | **fix** | ✅ | ✅ | **fix + resource** | "교집합"·"Principal 명시 필수" 과단정 → 계정 위임 경로 추가 |
| `saa-t1-5-q5` | ✅ | **fix** | **fix** | **fix** | ✅ | ✅ | **fix + resource** | 갈림길을 단일 테넌트로. "AWS가 키에 접근" 근거 제거 |
| `saa-t1-5-q6` | ✅ | ✅ | ✅ | **fix** | ✅ | ✅ | **resource** | custom key store 기전 출처 추가 |
| `saa-t1-5-q7` | ✅ | **fix** | **fix** | **fix** | ✅ | ✅ | **fix + resource** | 완전 자동 갱신은 DNS 검증. 보기 2 문구도 공식 기준으로 |
| `saa-t1-5-q8` | ✅ | **fix** | ✅ | ✅ | ✅ | ✅ | **fix** | 확인 못 한 컨트롤 플레인 기전 제거 (md도 함께) |
| `saa-t1-5-q9` | ✅ | ✅ | ✅ | **fix** | ✅ | ✅ | **resource** | 출처 복붙 오류(KMS 개요 → Macie) |
| `saa-t1-5-q10` | ✅ | ✅ | ✅ | **fix** | ✅ | ✅ | **resource** | 출처 복붙 오류(KMS 개요 → Inspector·Macie) |
| `saa-t1-5-q11` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **pass** | 백업 플랜 = 주기·보존·수명주기. 공식 뒷받침 |
| `saa-t1-5-q12` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **pass** | 교차 리전·교차 계정 복사 규칙. 공식 뒷받침 |
| `saa-t1-5-q13` | ✅ | **fix** | ✅ | **fix** | ✅ | ✅ | **fix + resource** | 유예는 사용자 지정·최소 3일(72시간). AWS Support 열거 제거 |
| `saa-t1-5-q14` | ✅ | ✅ | ✅ | **fix** | ✅ | ✅ | **resource** | 출처 복붙 오류(KMS 개요 → RDS 암호화) |
| `saa-t1-5-q15` | ✅ | ✅ | ✅ | **fix** | ✅ | ✅ | **resource** | KMS 개요에 CloudTrail 상세 없음 → 로깅 페이지 |

판정값: `pass` / `fix` / `rewrite` / `resource` / `drop` (루브릭 §3).
C6은 `saa_prescreen.mjs build`의 구조 플래그 0으로 갈음한다.

**집계**: `pass` 3 · `fix` 6 · `resource` 11(중복 포함) · **`rewrite` 0 · `drop` 0.**
**`correct`는 15문항 전부 무변경** — 회귀 가드 `saa_t1_5_facts_test.dart`가 15개 인덱스를
고정한다.

## 확인 못 한 주장 (본문에서 뺐다)

2026-07 감사에서 의심 82건 중 11건이 REFUTED였다. 근거를 못 찾은 하위 주장은 적지 않는다.

1. **CloudFront 컨트롤 플레인이 us-east-1을 거점으로 배포 설정을 전 세계 엣지 PoP에
   복제한다** — `q8` 해설 + `saa-t1-5.md` §5·흔한 함정. ACM 공식 문서는 "us-east-1 인증서가
   배포에 연결되면 그 배포에 설정된 모든 지리적 위치로 **배포된다**"까지만 말한다.
   요구사항(us-east-1 발급) 자체는 공식이라 유지, 기전만 제거.
2. **"AWS Support 포함"** — `q13` 해설. 공식 문구는 "by any user or **by AWS**"와
   "If any user (**including the root user**) attempts to delete ... will deny"까지다.
   → "AWS도" / "루트 사용자"로 바꿨다.
3. **"멀티테넌트"** — `q5`. 공식 표현은 "**tenant-agnostic** fleet of HSMs"이고, 같은 공식
   문서가 "Each AWS KMS HSM is a **dedicated, standalone** hardware appliance"라고도 쓴다.
   공식 표현("테넌트 구분이 없는 공용 플릿")으로 바꿨다.

## 게이트 실측값 (2026-10-20 · `saa-review/t1-5`)

| 게이트 | 명령 | 결과 |
|---|---|---|
| 테스트 | `flutter test` | **1,242 그린** (실패 0 · exit 0) |
| 분석 | `flutter analyze` | **No issues found!** (0건) |
| 구조 | `node tool/saa_prescreen.mjs build` | 24 Task **구조 플래그 0건** |

기준선 귀속: 분기 base(`origin/develop` `e306b45`) **1,185 그린** + 이번에 추가한 회귀 가드
`flutter_app/test/saa_t1_5_facts_test.dart` **57건** = **1,242**. 1,185는 CLAUDE.md
「빌드·테스트」절의 기준선 수치와 일치한다(그 줄이 정본이므로 숫자를 복사해 두지 않는다).

## 라이브 영향

둘로 나뉜다.

| 변경 | 라이브 노출 |
|---|---|
| `saa-t1-5.questions.json` 15문항 | **노출 변화 0** — `verified:false`이고 `content_index` questionCount도 0 유지. 앱은 `verified:true`만 노출한다 |
| `saa-t1-5.md` (§5·흔한 함정·정정 로그·`lastVerified`) | **라이브 학습문서 본문 변경** — 근거 없는 기전 서술 제거 |

오디오 재합성·`reviewStatus` 리셋 걱정은 없다: **`saa-t1-5`에는 오디오 자산이 없다**
(실측 — `flutter_app/assets` 내 `saa-t1-5*` 파일은 `.md`와 `.questions.json` 둘뿐).

## 판정 확정 후 (사람)

- [ ] 15문항 판정 확정 — 위 표의 "AI 권고"를 그대로 받을지 결정
- [ ] flip 실행

```powershell
cd flutter_app
node tool/saa_review.mjs flip saa-t1-5
```

- [ ] `flutter test` 그린 확인 (flip CLI가 `saa_questions_test`·`content_index_test` 실행)
- flip 커밋 해시: _(기입)_

## flip 후 readiness

선행 3 Task(`saa-t1-1`·`saa-t1-4`·`saa-t2-5`)와 함께 flip하면 SAA-C03은
**D1 45/19 · D2 30/17 · D3 45/16 · D4 30/13**이 되어 `certExamHasWeightedCapacity`가
true가 되고, **D1이 공식 Task 1.3을 포함한 상태**로 통합 모의고사가 열린다.
약점 집중 모의고사는 여기에 **비검토 응시 3회**가 더 필요하다(`certWeightedExamUnlocked`).
