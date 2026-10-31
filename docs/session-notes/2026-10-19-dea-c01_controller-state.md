# DEA-C01 리서치 — 컨트롤러 상태 노트 (자기 인수인계용, 2026-10-17 17:20 기준)

## 사실
- 임무: DEA-C01 원자료 수집. 산출물은 `D:/workspace/awc-docs/docs/content-research/DEA-C01/` 아래 `00-overview.md`, `tasks/<n>.md`(17개), `99-gaps.md` 뿐. git/flutter 금지, 다른 경로 쓰기 금지.
- 공식 가이드 = v1.1 (2025-12-12), HTML이 정본(docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/…). Task 17 / Skill 120. 레포 JSON과 8건 약칭 차이(00-overview §7).
- `00-overview.md` **작성·인용 41개 검증 완료**(check_notes.py --overview).
- 스켈레톤 17개 생성 완료(헤더+Skill 원문 EN/KO). 헤더 스냅샷: scratchpad/headers/<n>.txt.
- 공통 브리프: 이 폴더의 `dea-c01_research-brief.md`.

## 스크립트 (scratchpad = C:/Users/deepe/AppData/Local/Temp/claude/D--workspace-awc-docs/a637dbb9-e935-4830-9010-f3184e9c8c4e/scratchpad)
- `build_skeletons.py [--write]` : 가이드 EN/KO 페치 → JSON 비교 → 스켈레톤 생성(기존 파일은 skip).
- `check_notes.py [--no-net] [--overview] <file>...` : 헤더무결성·섹션·[S]태그·사실표 인용 원문대조(네트워크)·URL 도달성·문항후보 구조. 실행: `py -3 -I check_notes.py <절대경로>`.
- semgrep 플러그인 PreToolUse 훅이 간헐적으로 패닉(OTel context deadline) → 같은 호출 1회 재시도하면 통과(00-overview Write, check Bash에서 1회씩 발생). 최종 보고에 언급.

## Wave 1 (2026-10-17 17:00 발송, 백그라운드 서브에이전트, general-purpose)
| Task | agentId | gaps 파일 |
|---|---|---|
| 1.1 | a91964770b81ed089 | dea-gaps-1-1.md |
| 1.2 | ad96b6724d150dfaf | dea-gaps-1-2.md |
| 1.3 + 3.1 | a52362f8c03361923 | dea-gaps-1-3_3-1.md |
| 2.1 | a92169ee0658884f2 | dea-gaps-2-1.md |
| 2.2 + 2.3 | a64d57f98c284b068 | dea-gaps-2-2_2-3.md |

## Wave 2a (2026-10-17 17:20 발송 — 보안·운영 3묶음, 같은 브리프)
| Task | agentId | gaps 파일 |
|---|---|---|
| 3.3 + 4.4 | ad4a6f39b7bf70c8f | dea-gaps-3-3_4-4.md |
| 4.1 + 4.2 | a423c2c2128043bbc | dea-gaps-4-1_4-2.md |
| 4.3 + 4.5 | a64f1075edbf39eb4 | dea-gaps-4-3_4-5.md |

## Wave 2b (2026-10-17 17:25 발송 — Wave 1의 2.2 첫 섹션 품질 확인 후)
| Task | agentId | gaps 파일 |
|---|---|---|
| 1.4 + 3.4 | a71df1cd7c949e3af | dea-gaps-1-4_3-4.md |
| 2.4 + 3.2 | a5a2abdea059b11fa | dea-gaps-2-4_3-2.md |
(→ 17개 Task 전부 10개 에이전트에 배정 완료. 이제 완료 알림 대기·검증 단계.)
- 아래 힌트는 발송에 사용한 요약
- 힌트(조사 대상 주제)는 skill 문구 기준으로 작성. 3.2는 Amazon Quick(구 QuickSight)·DataBrew·Athena Spark 노트북·Redshift/Athena SQL(뷰·윈도우·PIVOT), 프로비저닝 vs 서버리스 트레이드오프. 2.4는 Redshift/DynamoDB/LF 스키마 설계, 스키마 진화(Schema Registry·Iceberg), SCT vs DMS Schema Conversion(SCT 범위 제거 이슈), 계보(SageMaker ML Lineage Tracking·SageMaker Catalog), 파티셔닝·압축·인덱싱, 벡터화(Bedrock Knowledge Bases). 1.4는 Lambda 동시성/성능/EFS·S3 마운트, SAM, CloudFormation/CDK, CI/CD(CodePipeline/CodeBuild/CodeDeploy), 언어·프레임워크, SW 공학 모범 사례, 분산 컴퓨팅, 자료구조(그래프/트리), 코드 최적화. 3.4는 Glue Data Quality(DQDL)·DataBrew 품질 규칙/프로파일, 샘플링, 스큐.

## ★ 2026-10-19 09:55 재개 상황 (이 섹션이 최신 — 위 표는 10-17 기준)
- 10-17 17:50경 10개 에이전트 전부 계정 한도(429)로 중단. 10-19 부모 세션이 "17개 전부 작성 완료(5,158행)·남은 건 99-gaps뿐"이라 알렸으나 **실측과 불일치**: 5,158행 = 스켈레톤 포함 줄 수 합. 실제 완성(TODO 0) 9개: 1-1,1-2,1-3,2-1,2-2,2-3,3-3,4-1,4-3. 부분: 1-4(문항후보·출처 비어있음), 2-4(출처 비어있음), 3-1(문항후보·출처 비어있음). 스켈레톤: 3-2,3-4,4-2,4-4,4-5. → 최종 보고에 이 정정을 명시할 것.
- 기존 gaps 파일: 1-3_3-1(1.3분만), 2-1(26건), 2-2_2-3(2.2분만), 4-1_4-2(4.1분만), 4-3_4-5(4.3분만). 없음: 1-1, 1-2, 2-3, 3-1, 3-3, 4-4, 1-4, 2-4, 3-2, 3-4, 4-2, 4-5분.
- 검증 완료(자동 대조): 1-3(120/120), 2-1(163/163), 2-2(96/96), 4-1(97/97), 4-3(116/116). 미검증: 1-1,1-2,2-3,3-3.
- 1차 재개(SendMessage, 09:52): a71df1cd7c949e3af(1-4 마무리+3-4 전체+gaps), a5a2abdea059b11fa(2-4 출처+3-2 전체+gaps), a423c2c2128043bbc(4-2 전체+4.2 gaps 덧붙임), ad4a6f39b7bf70c8f(4-4 전체+3.3/4.4 gaps 신규), a64f1075edbf39eb4(4-5 전체+4.5 gaps 덧붙임).
- 2차 재개 예정(마무리·gaps만): a52362f8c03361923(3-1 문항후보·출처+3.1 gaps 덧붙임), a91964770b81ed089(1.1 gaps+자가점검), ad96b6724d150dfaf(1.2 gaps+자가점검), a64d57f98c284b068(2.3 gaps 덧붙임).
- checker는 날짜 2026-10-17/19/20 허용으로 수정됨.
- 99-gaps.md: 각 gaps 파일 + 위 G-0-xx 취합. 2.1 gaps의 G-2.1-22(in-scope 페이지 URL 미확보)는 컨트롤러가 해결(overview §6)이라고 99-gaps에 명시.

## ★★ 2026-10-19 10:58 최종 상태
- 10개 에이전트 전부 완료 보고. 17개 task 노트 전수 자동 검증 통과(인용 1,945/1,945, 오류·경고 0). `00-overview.md`(§9 현황표·§10 출처 추가, 인용 41/41), `99-gaps.md` 작성(274건 = 전역 11 + Task 263, 분할제안 18, 수정제안 13). 빌드 스크립트: scratchpad/build_gaps.py --write (gaps_highlights.md 포함).
- 남은 일: (1) check_gaps_quotes.py 결과 확인 (2) 최종 보고(정정 사항 명시: 지시 시점 완성 9/17) 후 정지.

## 완료 후 할 일
1. 각 task 파일: `check_notes.py`로 검증 → 실패 인용 행 삭제/수정, 헤더 변경 여부 확인, TODO 잔존 확인, 인접 레포(git 금지이므로 파일 목록만) 이상 여부.
2. 상충 교차검증: Lambda 15분/메모리, Step Functions 한도, Kinesis 한도 등 파일 간 값 일치 grep.
3. `99-gaps.md` 작성: 서브에이전트 gaps 파일 취합 + 아래 사전 확보 항목.
4. 최종 요약 보고(파일 목록, Task별 출처 개수, gaps 건수) 후 정지.

## 99-gaps 사전 확보 항목 (컨트롤러 확인분)
- G-0-01 [수정제안] DEA-C01.json 8개 Skill 문구가 약칭↔전체명으로 다름(00-overview §7).
- G-0-02 [수정제안] JSON에 guideVersion(1.1)/guidePublished(2025-12-12) 없음.
- G-0-03 [개명·종료] 범위 내 목록의 구명칭: Amazon Kinesis Data Firehose(→Amazon Data Firehose, 2024-02-12), Amazon MemoryDB for Redis, Skill 3.2.1 "Amazon QuickSight"(→Amazon Quick 안의 Quick Sight).
- G-0-04 [불확실] Skill 2.4.3 예시에 AWS SCT가 남아 있으나 v1.1이 범위 내 목록에서 SCT를 제거.
- G-0-05 [불확실] 가이드 PDF 렌더(docs.aws.amazon.com/pdfs/…, ko_kr/…pdf) Last-Modified가 2026-10-16/15 — 개정 이력(v1.1=2025-12-12)과 달리 최근 갱신. 본문 미파싱(PDF 파서 없음) → 버전 변화 여부 미확인.
- G-0-06 [확인필요] 구 PDF(d1.awsstatic.com, Last-Modified 2025-02-14, 19쪽, 메타 생성일 2023-10-31) 본문 미파싱 — v1.0 추정이며 v1.1 내용 없음(날짜상).
- G-0-07 [불확실] 범위 내 목록에 "Amazon S3 Tables"가 두 번 나옴(EN·KO 동일).
- G-0-08 [확인필요] 시험 Help 버튼의 약칭↔전체명 목록은 공개 페이지에 없음 → 시험 약칭 표기 확인 불가.
- G-0-09 [정보] Task 단위 비중은 가이드에 없음(도메인 비중만).
