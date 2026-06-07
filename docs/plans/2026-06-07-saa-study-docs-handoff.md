# SAA-C03 학습문서 완주 Handoff (다음 세션 이관)

> 한 줄 상태: **SAA-C03 학습문서 24/24 작성·등록·배포 완료(라이브 검증됨).** verified 문항은 CLF 합격 게이트로 보류. 다음 작업 = (게이트 후) SAA 문항 생산 또는 다른 비-CLF 자격증 학습문서.

## 0. 지금 어디인가 (2026-06-07 기준)

- **라이브:** https://velkaressiablutkrone.github.io/aws-docs/ · 저장소 `VelkaressiaBlutkrone/aws-docs` · 브랜치 `main`(직접 커밋·push). 최신 커밋 `ffb73f9`.
- **이번 세션 산출물:** SAA-C03 학습문서 선행 생산. 설계→플랜→노출 가드(코드)→매핑→24문서 작성→배포→실브라우저 검증까지 완주.
- **CLF-C02:** 문항 포함 완성(verified 118문항). 모의고사·약점 루프 활성.
- **SAA-C03:** **학습문서 24개 전부 라이브**("학습문서 24 · 문항 준비 중"). verified 문항 0 → 모의고사·리포트·약점 카드 숨김(노출 가드).

## 1. 이번 세션에 한 일

### 1.1 설계·플랜 (커밋됨)
- 스펙: `docs/superpowers/specs/2026-06-07-saa-c03-study-docs-design.md`
- 플랜: `docs/superpowers/plans/2026-06-07-saa-c03-study-docs.md`
- 결정: verified 문항(게이트 위험의 핵심)은 CLF 합격 후로 분리, **출처 기반 학습문서만 선행**. 사용자가 게이트 예외로 명시 결정.

### 1.2 노출 가드 (코드, 2단계 리뷰 통과 — `0a09788`~`e060819`)
"문항 0 학습문서만" 상태를 1급으로 지원:
- `lib/data/content_index.dart`: `certHasVerifiedQuestions(certCode)` = `certContentSummary(certCode).questions > 0`.
- `lib/pages/home_page.dart` `_StudyDocsSection`: 문항 0이면 라벨 "학습문서 N · 문항 준비 중"(>0이면 기존 "검증 학습문서 N · 총 M문항").
- `lib/pages/home_page.dart` `_ExamsSection`: `withContent`를 `certHasVerifiedQuestions` 기준으로 → 문항 보유 cert만 모의고사 카드/약점 줄. 학습문서만 cert는 모의고사 섹션에서 제외(준비 중도 아님).
- `lib/pages/cert_detail_page.dart` `_LearningContent`: `hasQuestions = entries.any((e)=>e.questionCount>0)`. 문항 0이면 Task 카드 "검증 문항 N" 배지·약점 리포트·약점 모의고사 카드 숨김. 학습문서 링크·진행률 배너는 유지. 오답노트 카드는 기존 가드(weakByTask>0) 유지.
- 테스트: `test/content_index_test.dart`(`certHasVerifiedQuestions`, SAA 학습문서만 상태), `test/home_sections_test.dart`("문항 준비 중" 노출). SAA 하드코딩 예시는 `DVA-C02`로 교체(여전히 콘텐츠 미보유).

### 1.3 콘텐츠 (24문서, `2fb2409`·`5e4c946`·`0970999`·`42ec22b`·`331b808`)
| 도메인 | 비중 | 문서 | taskId |
|---|---|---|---|
| D1 보안 | 30% | 5 | saa-t1-1 IAM · t1-2 다계정 · t1-3 VPC보안 · t1-4 앱보안 · t1-5 데이터보안 |
| D2 복원력 | 26% | 5 | saa-t2-1 디커플링 · t2-2 서버리스 · t2-3 ELB+ASG · t2-4 HA · t2-5 DR |
| D3 고성능 | 24% | 9 | saa-t3-1 S3 · t3-2 EBS/EFS/FSx · t3-3 EC2 · t3-4 컨테이너/배치 · t3-5 RDS/Aurora · t3-6 DynamoDB/캐싱 · t3-7 Route53/CF/GA · t3-8 하이브리드 · t3-9 분석 |
| D4 비용 | 20% | 5 | saa-t4-1 스토리지 · t4-2 컴퓨팅 · t4-3 DB · t4-4 네트워크 · t4-5 비용도구 |

- 식별자 `saa-t{도메인}-{순번}`(학습 주제 순번, 공식 Task no 아님), `coversTasks`로 공식 Task 앵커.
- 형식 정본: `assets/content/saa/saa-t1-1.md`(CLF 6섹션 템플릿 — ✅🎯📖✍️⚠️🧪 + 프런트매터 + 📌출처). 나머지 23개가 이 틀을 복제.
- 모든 사실 진술 AWS 공식 문서 WebFetch 대조, `sources[]`에 실URL. files.zip(`D:\Download\saa_src\`) 초안을 템플릿 변환.
- 매핑·진척: `docs/plans/saa-c03-task-mapping.md` — 24행 전부 ☑.

### 1.4 검증
- 도메인 묶음마다 `flutter analyze` 무이슈 + `flutter build web --release --base-href /aws-docs/` 성공 + SAA 관련 테스트 7/7 green + main push 자동 배포.
- **실브라우저 검증(gstack):** 라이브 `#/cert/SAA-C03/study/saa-t1-1` 전 마크다운 블록(헤더 칩·인용·체크리스트·표 6·코드블록·인라인코드·콜아웃 틴트·`<details>` 토글·출처 링크) 정상. cert 상세에 24문서 목록 노출 + 문항 배지/모의고사 카드 미노출(가드 작동) + "1/24" 열람 진행 배너 동작.
- README 갱신(`ffb73f9`): CLF(문항 완성)/SAA(학습문서 선행) 구분 + `content/saa/` 트리.

## 2. 절대 잊지 말 환경 (매 세션 함정)
- **폴더:** git 루트 `D:\workspace\awc-docs`, Flutter `flutter_app\`(중간 폴더 없음). 콘텐츠 `flutter_app\assets\content\<cert>\`.
- **명령:** flutter/test/analyze는 **PowerShell**에서 `flutter_app` 기준. **Git Bash로 flutter 금지**(`--base-href` 망가짐). git은 `git -C D:/workspace/awc-docs`.
- **pubspec.lock:** `flutter pub get`/`build`가 추이 의존성 버전을 자주 건드린다. 기능과 무관하면 `git checkout -- flutter_app/pubspec.lock`으로 되돌리고 커밋(이번 세션 내내 그렇게 함).
- **로컬 테스트 함정:** `flutter test` 전체 실행 시 `study_markdown_view_test`·`theme_scope_test`가 `ink_sparkle.frag` 셰이더 포맷 불일치(로컬 SDK 환경)로 1~2개 실패 — **이번 작업과 무관, CI(fresh stable)에선 green**. 셰이더 2개 외 실패만 조사.
- **커밋:** `main` 직접 커밋·push(사용자 선택).

## 3. 콘텐츠 배치 생산 레시피 (이번 세션에서 검증된 패턴)
한 도메인(5개 안팎)을 한 묶음으로:
1. **병렬 작성 에이전트 N개** 디스패치 — 각자 `assets/content/saa/<taskId>.md` **하나만 생성**. git 커밋·content_index·pubspec·build **금지**(충돌·git 경쟁 방지). 각 프롬프트에 정본(`saa-t1-1.md`) 정독 + files.zip 초안 경로 + 공식 출처 URL + 프런트매터 + 6섹션 + 파서 미지원 문법(링크/이탤릭/중첩리스트) 금지 명시.
2. **조율자(메인)가 일괄 처리:** 구조 점검(H1 1개·`<details>`·`badlink:0`) → `content_index.dart`에 `ContentEntry(questionCount:0)` N줄 → 매핑표 ☑ → `pubspec.lock` 되돌림 → `flutter analyze` + `build web` → 한 커밋 → push.
- pubspec `assets/content/saa/`는 이미 등록됨(첫 부트스트랩). 새 cert면 그 줄 추가 필요.

## 4. 다음 작업 후보
1. **(게이트 후) SAA verified 문항 생산** — 각 `saa-tX-Y`에 `<taskId>.questions.json`(`verified:true`, 출처 필수) 작성 + `content_index`의 `questionCount`만 실제 수로 갱신. **코드 변경 없이** 모의고사·약점 리포트·약점 가중 모의고사가 자동 활성(노출 가드가 문항 보유로 판정 전환). 단 **본인 CLF 합격 게이트** 유지. 문항 품질 규율은 `2026-06-07-phase3-content-handoff.md` §3.6 + [[question-bank-verified-workflow]].
2. **다른 비-CLF 자격증 학습문서** — 같은 레시피로 DVA-C02/SOA-C03 등. 새 cert면 pubspec `assets/content/<cert>/` 1줄 + content_index 키 + 매핑 문서.
3. **보류 결정(콘텐츠 아님):** `quiz_widgets` 폰트 크기 토큰화(DESIGN.md 타입스케일 vs 코드 실제값 불일치) — 사용자 결정 대기.

## 5. 참고 문서
- 스펙/플랜: `docs/superpowers/specs/2026-06-07-saa-c03-study-docs-design.md`, `docs/superpowers/plans/2026-06-07-saa-c03-study-docs.md`
- SAA 매핑·진척: `docs/plans/saa-c03-task-mapping.md`
- 직전 핸드오프(복제 레시피·부트스트랩·문항 규율): `docs/plans/2026-06-07-phase3-content-handoff.md`
- 콘텐츠 플레이북: `docs/plans/2026-06-06-content-production-playbook.md`
- 형식 정본: `flutter_app/assets/content/saa/saa-t1-1.md`(SAA), `flutter_app/assets/content/clf/t1-1.md`(CLF)
- files.zip 초안(압축 해제됨): `D:\Download\saa_src\`

## 6. 한 줄 요약 (다음 작업자에게)
> SAA 학습문서 24개가 라이브에 정직하게(문항 0 → 모의고사·배지 숨김) 떠 있다. 다음은 **CLF 합격 후** SAA 문항을 채우면 `questionCount`만 갱신해도 모의고사·약점 루프가 코드 변경 없이 켜진다. 배치 레시피(§3)는 도메인 단위 병렬 작성 → 조율자 일괄 등록·빌드·push로 검증됐다.
