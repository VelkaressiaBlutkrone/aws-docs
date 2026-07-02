# ⑧ 관리위생·문서 감사 샤드 — 08-hygiene — 2026-07

## 요약 (3~5줄)
현재 감사 브랜치(`docs/2026-07-02-full-audit-roadmap`) 기준 위생 상태를 점검했다. 위생 수정용 chore 커밋(`13f3ce3` analyze 0, `11db0e2` 기준선 778)은 git 히스토리에 존재하나 **현재 HEAD의 조상이 아니다**(별도 미머지 chore 브랜치) — 따라서 CLAUDE.md·TODOS.md의 stale 서술과 analyze 잔존 3건은 이 브랜치 작업 트리에서 **여전히 실재하는 발견**이다(단, 수정이 이미 준비돼 있음 → 대부분 M/L·확신 높음). 가장 실질적 위험은 pubspec 오디오 에셋을 디렉터리 나열로 바꿀 경우다: 오디오 트리에 gitignore된 스크래치 파일 38개(enrich_report.md·enrich_verify.md 각 18 + review_notes·_migrate 등)가 있어, 디렉터리 나열 전환 시 이들이 웹 빌드에 번들된다(Flutter 에셋 번들은 .gitignore를 무시). TROUBLESHOOTING.md는 "pubspec에 assets/audio/ 미등록" 원칙을 여전히 서술하나 현재 pubspec은 19개 문서×4파일을 등록해 상충한다. 총 발견 12건(전부 사실의심 N — 문서·설정 위생).

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| HYG-001 | TODOS.md:4 | 코드 스플리팅 TODO의 `src/content/index.ts` 경로가 Flutter 이전 Vite/TS 잔재. 실재 경로는 `flutter_app/lib/data/content_index.dart`(존재 확인). 파일 말미(37-38행)에 자기 stale-flag 주석까지 있으나 본문 미수정 | M | 높 | What 줄 경로를 `flutter_app/lib/data/content_index.dart`로 교체(+37-38행 stale-flag 주석 제거). 로드맵 Task 3 Step 1에 동일 수정 계획됨 | A | N |
| HYG-002 | TODOS.md:23-35 | "C-중량: 개념→학습문서 섹션 앵커 딥링크" + "AttemptRecord.wrongSkills[] 비정규화" 두 섹션이 미완료 TODO로 남아 있으나 실제로는 출고 완료(메모리 concept-deeplink: Phase 1+2 PR#21 main 릴리스, wrongSkills 포함). stale 미완료 항목 | M | 높 | 두 섹션 전체 + 말미 stale-flag 주석 삭제. 로드맵 Task 3 Step 1에 계획됨 | A | N |
| HYG-003 | CLAUDE.md:50 | `flutter test` 주석 "현재 기준선 499 그린" — 실제 기준선 778(로드맵 플랜 Global Constraints·메모리 work-priority-roadmap-phase0 모두 778). 279 문항 과소 표기 | M | 높 | "499 그린"→"778 그린". 로드맵 Task 3 Step 2에 계획됨 | A | N |
| HYG-004 | CLAUDE.md:51,55 | analyze 게이트 서술이 "신규 0건이 게이트(기존 잔존 3건: plan_agenda cacheExtent·sync_controller_test 2건)". 잔존 3건은 chore `13f3ce3`에서 해소돼 목표 상태는 "0건이 게이트". 단 이 커밋은 현재 HEAD 미포함(아래 HYG-011 참조)이라 **현 작업트리에선 여전히 3건 실재** — 서술과 코드가 함께 stale | M | 높 | HYG-011(analyze 3건 해소)과 함께 문구를 "0건이 게이트"로 갱신. 로드맵 Task 3 Step 2에 계획됨 | A | N |
| HYG-005 | flutter_app/README.md:1-17 | Flutter 기본 생성 스텁 그대로("aws_docs / A new Flutter project. / codelab 링크"). 프로젝트 실제 내용(한국어 학습 로드맵·모의고사, 빌드·배포, base-href /aws-docs/) 미반영. 유입 채널 실행 시 첫인상 문서(TODOS 유입 채널 TODO가 "README 랜딩 정비" 언급) | L | 높 | 프로젝트 README로 교체(또는 루트 문서로 대체 명시). CLF 완성/유입 채널 착수 전 정비 권장 | B | N |
| HYG-006 | flutter_app/pubspec.yaml:69-144 | 오디오 에셋 19개 문서 × 4파일(script.json·lecture.mp3·audio_meta.json·review_checklist.md) = 76줄 수동 나열. 디렉터리 나열(`assets/audio/clf/{docId}/`)로 축약 가능하나 **리스크 있음**(HYG-007). 유지보수 부담·신규 문서 추가 시 누락 위험 | L | 높 | 축약은 HYG-007 스크래치 정리를 선행해야 안전. 정본 파일 4종만 유지된다는 보장이 서면 디렉터리 나열 전환 | B | N |
| HYG-007 | flutter_app/assets/audio/clf/ (트리 전체) | 오디오 트리에 gitignore된 스크래치 38개 존재: `enrich_report.md`×18, `enrich_verify.md`×18, `review_notes.py`·`review_notes.md`(clf-t1-1), 루트 `_apply_review.py`·`_corpus_scan_report.md`·`_migrate_t1_1_enriched.py`. 전부 git 미추적(확인). **pubspec을 디렉터리 나열로 바꾸면 Flutter 에셋 번들이 .gitignore를 무시하고 이들을 웹 빌드에 포함**(원치 않는 파일 배포·번들 비대) | M | 높 | 디렉터리 나열 전환 시 사전 정리 필수: (a) 스크래치를 오디오 트리 밖으로 이동하거나 (b) 파일 4종만 명시 유지. 현 수동 나열은 이 위험을 회피하고 있으므로 정리 전 축약 금지 | B | N |
| HYG-008 | docs/TROUBLESHOOTING.md:81-85 | "커밋하면 안 되는 로컬 파일" 절이 "`pubspec.yaml`에 `assets/audio/`를 등록하지 않는다 / lecture.mp3·audio_meta.json은 approved 전까지 커밋 안 함"을 현행 원칙으로 서술. 그러나 CLF19는 이미 approved·pubspec 등록·커밋됨(pubspec:69-144, PR#62/#64). M1 시점 원칙이 stale — 신규 작업자 오도 소지 | M | 중 | "오디오 M1 작업 기준" 시점 한정임을 명시하거나, approved 후 등록됨을 반영해 갱신 | B | N |
| HYG-009 | docs/TROUBLESHOOTING.md:92-102 | analyze "최근 확인된 기존 이슈"로 3건(plan_agenda cacheExtent:226, sync_controller_test fake_async:4, onAppResume:51) 나열. chore `13f3ce3` 해소 계획과 어긋남(단 현 HEAD엔 미반영이라 문서·코드 함께 stale) | L | 높 | HYG-011 해소 후 이 절도 "해소됨(2026-07-02)"으로 갱신 | B | N |
| HYG-010 | docs/plans/README.md:9-12 | 플랜 인덱스 상태 컬럼이 초기값 유지: tasks-eng/ceo-review "대기", clf-c02-task-mapping "검수 대기". T1~T14·학습루프·CLF 콘텐츠가 전부 출고된 현재와 불일치(메모리 다수 확인). 인덱스 문서 stale | L | 중 | 상태 컬럼을 완료/출고로 갱신하거나 README를 "초기 계획 아카이브"로 표기 | B | N |
| HYG-011 | flutter_app/lib/pages/plan/plan_agenda.dart:226; flutter_app/pubspec.yaml:43-45; flutter_app/test/cloud/sync_controller_test.dart:51 | 현재 감사 브랜치 작업트리에 analyze 잔존 3건 실재: `cacheExtent: 1200`(deprecated), pubspec dev_dependencies에 `fake_async` 미선언, `_ProbeController`의 미사용 `super.onAppResume`. 해소 커밋 `13f3ce3`은 존재하나 현 HEAD 조상 아님(미머지 chore 브랜치) | M | 높 | chore/2026-07-audit-hygiene를 develop 경유로 머지하면 해소(로드맵 Task 2·5). 이 샤드 관점에선 "위생 수정이 아직 이 브랜치에 반영 안 됨" 기록 | A | N |
| HYG-012 | docs/ 트리(164 .md; superpowers/specs 41 + plans 43) | 2026-06~07 대량 작업으로 스펙/플랜 84개(superpowers) + plans/designs 21개 누적. 다수가 릴리스 완료(오디오·학습루프·시각리팩토링·concept-deeplink). 아카이브 디렉터리·인덱스 부재로 현행 문서와 완료 문서가 평면 혼재 → 탐색성 저하 | L | 중 | `docs/superpowers/archive/`(또는 완료 인덱스) 신설 후 완료 스펙/플랜 이동. 아래 "아카이브 후보 목록" 참조. 삭제 아님 | B | N |

## 아카이브 후보 목록 (별도 절)

기준: git 히스토리·메모리(MEMORY.md)로 **릴리스 완료가 확인/강하게 추정**되는 스펙·플랜. 삭제가 아니라 `docs/superpowers/archive/` 이동(또는 완료 인덱스 표기) 후보다. 확신도는 완료 근거의 강도.

| # | 문서 | 완료 근거(요약) | 확신도 |
|---|---|---|---|
| 1 | docs/superpowers/plans/2026-06-06-learning-loop-e1.md + specs/…-e1-design.md | 학습루프 E1~E6 전부 종료(메모리 work-priority-roadmap-phase0) | 높 |
| 2 | docs/superpowers/plans/2026-06-06-ia-reconcile-routing.md + design | Spec 1 IA 라우팅 출고(메모리 ia-routing-shipped) | 높 |
| 3 | docs/superpowers/plans/2026-06-06-cert-wide-exam.md + design | Spec 2 통합 모의고사 구현·push 완료(메모리 ia-routing-shipped) | 높 |
| 4 | docs/superpowers/plans/2026-06-07-phase0-cleanup.md | Phase 0 정리 완료 | 높 |
| 5 | docs/superpowers/plans/2026-06-07-phase1-e1a-data-foundation.md / e1b-review-ui.md / e2-weakness-report.md | Phase 1(오답노트·약점리포트) 배포 | 높 |
| 6 | docs/superpowers/plans/2026-06-07-phase2-progress-weighted-exam.md + design | Phase 2(진행률·가중 모의고사) 배포 | 높 |
| 7 | docs/superpowers/plans/2026-06-08-md-table-inline-and-appbar-title.md + design | 출고(후속 PR4 appbar에서 대체·확장) | 중 |
| 8 | docs/superpowers/plans/2026-06-08-mobile-hamburger-nav.md + design | 모바일 내비 출고(PR4 AppHeader) | 중 |
| 9 | docs/superpowers/plans/2026-06-08-option-shuffle-question-sampling.md + design | 옵션 셔플·샘플링 출고 | 중 |
| 10 | docs/superpowers/plans/2026-06-10-cloud-sync-core.md / -integration.md + design | 클라우드 동기화 인프라 완료(메모리 다수) | 중 |
| 11 | docs/superpowers/plans/2026-06-10-study-plan-calendar.md + design | 스터디 플랜 캘린더 출고 | 중 |
| 12 | docs/superpowers/plans/2026-06-11-content-enrichment-pilot.md / -rollout.md + design | 대본 강사화 enrichment 확대·릴리스(메모리 audio-instructor-script) | 높 |
| 13 | docs/superpowers/plans/2026-06-12·15-clf-question-density-15.md + design | CLF 15샤드 문항 밀도 작업(진행분 커밋 존재; 완료 여부는 ④샤드가 판단) | 낮 |
| 14 | docs/superpowers/plans/2026-06-18-concept-deeplink-phase1.md / phase2.md + design | concept-deeplink Phase 1+2 main 릴리스, 브랜치 정리(메모리 concept-deeplink) | 높 |
| 15 | docs/superpowers/plans/2026-06-19-phase1-develop-main-release.md | 릴리스 실행 문서(1회성) | 높 |
| 16 | docs/superpowers/plans/2026-06-20-saa-review-tool.md + design + docs/saa-review/* | SAA 재검토 인프라 T1~T8 완료(메모리 question-bank-verified-workflow) | 높 |
| 17 | docs/superpowers/plans/2026-06-20-section-anchors.md + design | 섹션 앵커(제목별 타임스탬프·딥링크 기반) 출고 | 중 |
| 18 | docs/superpowers/plans/2026-06-20·21-clf-c02-content-supplement*.md + design | CLF-C02 보강 작업 문서 | 중 |
| 19 | docs/superpowers/plans/2026-06-23-content-review-pipeline.md + design | M2 오디오 검수 파이프라인 완료(메모리 content-review-pipeline-planned) | 높 |
| 20 | docs/superpowers/specs/2026-06-21-study-audio-m1-handoff.md / -failure-taxonomy.md / 2026-06-20-study-audio-lecture-review.md / 2026-06-21-clf-t1-1-tts-audio-correction.md | 오디오 M1 핸드오프·수정 완료(PR#53~54 릴리스) | 높 |
| 21 | docs/superpowers/plans/2026-06-26-audio-runtime-review-gate.md + design | 런타임 노출 게이트 ①+② 완료(메모리 audio-runtime-gate-shipped, PR#64~65) | 높 |
| 22 | docs/superpowers/plans/2026-06-26-audio-loudness-normalization.md + design | ③음질(-16 LUFS) 적용·라이브(PR#68~77) | 높 |
| 23 | docs/superpowers/plans/2026-06-26-audio-hallucination-guard.md + design | ④환각가드 완료·릴리스(PR#70~73) | 높 |
| 24 | docs/superpowers/plans/2026-06-27-cert-audio-page.md + design / -audio-timebar-modes.md + design | 자격증별 오디오 페이지·타임바 출고(PR#78→#84, 메모리 cert-audio-page-feature) | 높 |
| 25 | docs/superpowers/plans/2026-06-28-audio-section-timestamps.md / -accuracy.md + design | 제목별 타임스탬프 실측 정확화 릴리스(PR#85→#88, 메모리 audio-section-timestamps-shipped) | 높 |
| 26 | docs/superpowers/plans/2026-06-29-audio-descaffold-stage-a1.md / -connectors-stage-a2.md / -instructor-pilot-stage-b.md / -instructor-stage-b-scaleup.md + designs | 대본 강사화 A1·A2·B 라이브(메모리 audio-instructor-script) | 높 |
| 27 | docs/superpowers/plans/2026-06-30-home-top-due-sources.md + design | 홈 상단 due 소스(커밋 존재; 라이브 여부 미확정) | 낮 |
| 28 | docs/plans/2026-06-05-design-aws-cert-site.md / -eng-review-test-plan.md / README.md 인덱스 | 초기 설계·T1~T14 구현 완료(APPROVED/확정 표기, 전부 출고) | 중 |
| 29 | docs/plans/2026-06-10-firebase-fcm-feasibility.md / 2026-06-09-assets-official-audit.md | 타당성·감사 1회성 조사 문서 | 낮 |

주: 위 로드맵 자신의 스펙·플랜(`2026-07-02-full-audit-roadmap*`)은 현재 진행 중이므로 아카이브 대상 아님. 완료 여부가 낮/중 확신인 항목(#13·#27 등)은 아카이브 전 해당 차원 샤드(④문항·⑥재생) 결론 또는 사람 확인을 권장한다.
