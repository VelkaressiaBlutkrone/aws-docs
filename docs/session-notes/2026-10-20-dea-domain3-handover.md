# DEA-C01 도메인 3 출고 — 핸드오프 (2026-10-20)

작성: 도메인 3 세션 (worktree `elegant-williamson-c7d423`, 브랜치 `feat/2026-10-20-dea-content-domain3`)
PR: https://github.com/VelkaressiaBlutkrone/aws-docs/pull/151 (base=develop) — **머지 완료**(2026-10-20). 머지 전 #148과 충돌이 나 `develop`을 병합해 해결했고, 해결 후 실측 **test 1,120 그린 · analyze 0건**.

## 결과

- 학습문서 4편: `flutter_app/assets/content/dea/dea-t3-1.md` ~ `dea-t3-4.md`
- 문항 드래프트: Task당 15개 = **총 60개, 전부 `verified: false`**
- `content_index.dart` 도메인 3 엔트리 4줄(`questionCount: 0`), `test/dea_questions_test.dart`에 t3-1~t3-4 누적
- 게이트 실측: `flutter test` **1,088 그린**(착수 시점 develop 기준선 1,076 + 신규 12) · `flutter analyze` **0건**
- 라이브 노출 변화 0 (verified:false + questionCount 0), pubspec 무변경

도메인 2 세션의 핸드오프 노트(`local_cc1e804c-…/dea-domain2-handover.md`) 6개 항목은 **전부 그대로 유효**했다. 추가로 확인·주의할 점만 아래에 적는다.

## 도메인 4 담당 세션에게 — 이번에 실제로 겪은 것

1. **기준선은 착수 시점 `origin/develop`에서 직접 재세요 — DEA 트랙 밖의 PR이 테스트 수를 바꿉니다.** 실측 경과:
   - 내 분기점 `e9c7b0f` = **1,076**
   - `develop`이 그 뒤 세 번 전진: #149(docs, 0) · **#150 SAA weighted-ready(`test/saa_question_facts_test.dart` 신규 20건)** · #148 도메인 2(+12) → `febe9ff` = **1,108**
   - #151(도메인 3, +12) 머지 후 → **1,120** (실측, 2026-10-20)

   즉 **도메인 4 기준선은 1,120에서 출발하되 그대로 믿지 말 것.** 나는 "1,076+12+12=1,100"으로 예상했다가 20건 어긋났는데, 원인은 DEA와 무관한 SAA 리뷰 PR이었다. 분기 직후 `flutter test`를 한 번 돌려 숫자를 직접 확보하고, 그 값을 PR 본문의 기준선으로 쓸 것.
2. **`content_index.dart`·`dea_questions_test.dart`는 배치마다 충돌 지점이다.** 도메인 2(#148)와 도메인 3(#151)이 같은 두 파일의 인접 줄을 각각 늘렸고, 실제로 #148이 먼저 머지되면서 **#151에 머지 충돌이 났다**(GitHub가 Auto-fix로 보고). **해결 방향은 언제나 "양쪽 추가분을 모두 남기기"** — 엔트리 줄도 `deaTaskIds` 배열도 합집합이다. 해결 후 현재 `develop`에는 DEA 엔트리 12줄(t1·t2·t3)과 `deaTaskIds` 12개가 모두 들어 있다. 도메인 4도 같은 자리를 건드리므로 같은 충돌을 예상할 것.
3. **노트 4개를 한 번에 Read하지 말 것.** `tasks/4-1.md`(76KB)처럼 큰 노트는 Read 한 번에 25k 토큰 캡에 걸려 잘린다. Task 하나씩 (핵심 개념 → 시험에서 묻는 방식 → 흔한 함정) 읽고, **출처 목록(S1~Sn)은 `sed -n '/^## 출처 목록/,$p'`로 따로 뽑는 편이 빠르다.** 사실·숫자 표에는 URL이 인라인으로 들어 있어 출처 목록 없이도 대부분 인용 가능하다.
4. **`99-gaps.md` §4는 49KB라 Bash로 통째 출력하면 persisted-output으로 빠진다.** 저장된 파일을 Read로 읽으면 된다. 도메인 4 gaps는 1226행(Task 4.1)부터 1501행 끝까지.
5. **정답 인덱스 분포는 파일마다 0:4 / 1:4 / 2:4 / 3:3으로 맞췄다.** 15문항·4지선다라 완전 균등이 안 되므로 이 패턴을 그대로 쓰면 편하다. 작성 후 아래 한 줄로 전수 검증하면 `flutter test` 전에 스키마 오류를 잡을 수 있다(실제로 유용했다):

```sh
py -c "
import json,glob,collections
for p in sorted(glob.glob('flutter_app/assets/content/dea/dea-t4-*.questions.json')):
    d=json.load(open(p,encoding='utf-8')); qs=d['questions']
    dist=collections.Counter(q['correct'] for q in qs)
    bad=[q['id'] for q in qs if len(q['options'])!=4 or set(q['wrongExplanations'].keys())!={str(i) for i in range(4) if i!=q['correct']} or q['verified'] is not False or not q['sources'] or any(not s['url'].startswith('http') for s in q['sources'])]
    print(p, len(qs), dict(sorted(dist.items())), bad)
"
```

6. **Skill 커버리지를 15문항에 다 담으려면 Task당 Skill 수를 먼저 세라.** Task 3.1은 Skill 9개라 Skill당 1~2문항으로 간신히 덮었고, Task 3.4는 Skill 5개라 여유가 있었다. 도메인 4는 4.1(7)·4.2(6)·4.3(4)·4.4(5)·4.5(7)이다. Skill 7개짜리는 문항 배분을 먼저 표로 적고 쓰는 편이 낫다.

## 정답 근거로 쓰면 안 되는 것 (도메인 3에서 실제로 배제한 목록)

boto3 기본 재시도 모드(G-3.1-01, 모드별 특성만 사용) · Glue `MaxRetries` 기본값(G-3.1-02) · Glue 잡 타임아웃 "기본 48시간"(G-3.1-03·G-3.3-08, 버전별로만) · EventBridge 재시도 24시간·185회(G-3.1-04, 규칙 Classic·Scheduler로 한정) · Redshift MV Auto REFRESH 동작(G-3.1-07, "결정적이면 수동·예약"까지만) · Athena DML 타임아웃 기본값·활성 쿼리 한도(G-3.1-08, 미기재) · "Athena 페더레이션=항상 Lambda"(G-3.1-09) · Lambda 900초(G-3.1-11, "일반 함수"로 한정) · Quick 사용자 단가(G-3.2-03, 미기재) · Athena 피벗 방법(G-3.2-04) · 표준 Athena 뷰의 저장 위치(G-3.2-05) · Quick SPICE 한도 수치(G-3.2-10, 미기재) · Athena SQL vs Spark 요금 비교(G-3.2-13, 제외) · CloudWatch 구독 필터 개수(G-3.3-01) · Logs Insights 동시 쿼리 수(G-3.3-02, 미기재) · IA 로그 클래스의 S3 내보내기(G-3.3-03, 제외) · CreateExportTask 활성 작업 수(G-3.3-06, 숫자 없이) · Redshift 동시성 확장 1~10·Athena 128MB(G-3.3-12) · EMR `S3LoggingConfiguration`(G-3.3-13, 미기재) · 일반 샘플링 기법명(G-3.4-01, 서비스별 틀만) · Glue Studio "Fail job after loading data to target"(G-3.4-03, 미사용) · DataBrew 프로파일 행 수 20,000(G-3.4-05, 문항 근거 미사용).

**최신성 함정으로만 쓴 것**: Redshift Python UDF 2026-06-30 지원 종료 · QuickSight → Amazon Quick 개명 · "CloudWatch Events" → EventBridge · Kinesis `PutRecords.Records` deprecated · Centralized Logging with OpenSearch 솔루션 2026-12 종료(솔루션이지 OpenSearch Service가 아님) · Athena PySpark engine v3 2027-04-01 수명 종료.

## 도메인 4에서 겹칠 내용 (경계 주의)

- **Task 4.4(감사용 로그 준비)는 Task 3.3과 Skill이 사실상 같다.** `99-gaps.md` G-3.3-16·G-4.4-11이 이를 지적한다: 3.3.5의 영문 원문은 4.4.1과 **똑같고**("Use AWS CloudTrail to track API calls."), 3.3.7≈4.4.2, 3.3.8≈4.4.4, 3.3.8의 EMR 예시≈4.4.5.
  → 내 `dea-t3-3.md`는 **"운영·알림·분석"** 관점으로 썼고, 문서 머리말에 "감사용 로그의 보존·무결성·중앙화는 도메인 4 Task 4.4가 다룬다"고 명시했다. **도메인 4는 "감사 준비·보존·무결성·중앙화" 관점으로 쓰면 중복 없이 맞물린다.** 내가 t3-3에 이미 쓴 것: CloudTrail 이벤트 유형 4종·이벤트 선택기·중복 `eventID`, 멀티 리전/조직 trail, CloudWatch Logs 구독 vs 내보내기, 로그 클래스, 메트릭 필터, 로그 분석 도구 4종 비교. **CloudTrail Lake·로그 파일 무결성 검증·KMS 암호화·교차 계정 보존은 일부러 남겨 뒀다.**
- **AWS Config**: 내 t3-3은 "구성 변경 이력을 남기는 서비스"라는 수준까지만 썼다. Skill 4.5.4가 AWS Config를 직접 요구하므로 **상세는 도메인 4 몫**이다(G-3.3-16도 같은 정리를 권고).
- **Task 4.3(마스킹·암호화)**: 도메인 3에서는 다루지 않았다. 겹침 없음.
- **CloudTrail Lake 주의**: G-4.4-01·G-4.4-03 — **2026-05-31부터 신규 고객 중단(maintenance)인데 Skill 4.4.3은 Lake를 그대로 요구**한다. 가이드 원문은 유지하되 학습문서에서 상태를 표시하는 쪽이 안전하다.

## 워크트리·git 주의

- 내 분기 기준은 `origin/develop` = **e9c7b0f**. 로컬 `develop` 브랜치와 다른 세션의 브랜치는 건드리지 않았다(CLAUDE.md §5).
- 커밋 직전 `git branch --show-current`로 검증했고, 변경 파일은 의도한 10개뿐이었다(인접 레포 오염 없음).
- 모든 git 명령에 `-C <워크트리 절대경로>`를 썼다. Bash 호출 사이 cwd가 리셋되므로 도메인 4도 같은 방식을 권한다.
