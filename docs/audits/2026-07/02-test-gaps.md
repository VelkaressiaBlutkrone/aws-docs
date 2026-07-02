# ② 테스트 갭 감사 종합 — 2026-07

- 입력 샤드: `raw/02-test-gaps.md`(단일 샤드 승격 — 내용 동일)

## 요약 (3~5줄)

lib 110개 / test 77개. 순수 로직 계층(샘플링·병합·스케줄러·오디오 상태기계·스토어)은 파일명 1:1 + 엣지까지 밀도 높게 커버돼 있고, ExamView/QuizView는 SelectionArea 제약을 View-레벨 위젯테스트로 우회해 실제 렌더 검증까지 하고 있다. 가장 큰 실질 공백은 **CertExamPage._load()의 세션 복원 판정 체인**(부품은 전부 테스트됐지만 조립이 페이지 내부에 갇혀 무검증, TEST-001)과 **review/report 페이지의 세션·리포트 조립 글루**(TEST-010/011)다. 오디오 쪽은 ended 이중전진 가드까지 테스트돼 있으나 cert 전환·큐 동일성(identity 의존)·ended 후 재개 같은 확장 시 발현될 엣지가 비어 있다(TEST-003/004/005). 테스트 냄새는 경미: 픽스처 헬퍼 중복(AttemptRecord 10파일), sync_controller_test의 실시간 20ms sleep 4곳, 의도적 실디스크 콘텐츠 게이트 9파일.

## lib↔test 대응 맵 (테스트 없는 lib 파일 목록 포함)

판정 기준: 파일명 매칭 + 테스트 파일의 `package:aws_docs/` import 전수 추적(77파일 전체).

### 직접 테스트 있음 (파일명/전용 테스트 1:1 이상) — 55개

| lib | test |
|---|---|
| app_errors.dart | app_errors_test |
| app_router.dart | app_router_test, page_transitions_test, home_schedule_section_test, home_sections_test |
| main.dart | widget_test, cloud/boot_init_test, theme_persistence_test |
| content/anchor_scroll.dart | anchor_scroll_test |
| content/markdown_parser.dart | markdown_parser_test, all_content_parse_test(전 md 회귀 게이트), section_anchor_link_test |
| content/prescription_hub.dart | prescription_hub_test |
| content/quiz_widgets.dart | results_view_test |
| content/study_deep_link.dart | study_deep_link_test |
| content/study_markdown_view.dart | study_markdown_view_test, study_markdown_view_heading_slot_test |
| data/attempt_presented.dart | attempt_presented_test(직접은 taskFromExamId만 — TEST-009 참고) |
| data/audio_asset_url.dart | audio_asset_url_test |
| data/audio_chapters.dart | audio_chapters_test |
| data/audio_controller.dart | audio_controller_test(16 케이스: 동기 play 진입·거부·stalled·dispose·dedup·seek·position) |
| data/audio_nav.dart | audio_nav_test(메뉴 게이트·redirect 순수함수) |
| data/audio_runtime.dart | audio_runtime_test(stub 경로 + shouldShowLecturePlayer 4조건 전수) |
| data/cert_lookup.dart | cert_lookup_test 외 4파일 |
| data/concept_report.dart | concept_report_test |
| data/content_index.dart | content_index_test, content_index_audio_test(approvedAudioEntries 19문서 SSOT) |
| data/exam_session_store.dart | exam_session_test(저장/복원/손상/왕복), study_reset_test |
| data/history_store.dart | history_store_test, study_reset_test(clearCert/clearAll) |
| data/lecture_playlist.dart | lecture_playlist_test(18 케이스: ended 이중전진 가드 포함), lecture_transport_bar_test, study_audio_player_test |
| data/media_session_binder.dart | media_session_binder_test(잠금화면 액션·상태 동기화·dispose) |
| data/mock_exam.dart | mock_exam_test(17 케이스: 배분 합·결정성·백필·빈 풀·선택지 셔플·분포 스모크) |
| data/plan_check_store.dart | plan_check_store_test, study_reset_test |
| data/plan_month.dart | plan_month_test |
| data/plan_progress.dart | plan_progress_test(반복형 rank·done 우선·생성일 게이팅·overdue) |
| data/plan_progress_store.dart | plan_progress_store_test 외 3파일 |
| data/plan_progress_view.dart | plan_progress_view_test |
| data/plan_scheduler.dart | plan_scheduler_test(15 케이스: 결정성·경계·redistribute·manual) |
| data/site_data.dart | official_sources_test |
| data/study_plan_store.dart | study_plan_store_test 외 2파일 |
| data/study_progress.dart | study_progress_test |
| data/study_reset.dart | study_reset_test |
| data/task_score_report.dart | task_score_report_test(최신결과 갱신·70% 경계·레거시 폴백·review 제외) |
| data/theme_pref_store.dart | theme_pref_store_test |
| data/viewed_docs_store.dart | viewed_docs_store_test, study_reset_test |
| data/weighted_exam.dart | weighted_exam_test(가중 공식·3회 게이트·타 cert 제외) |
| data/wrong_answer_index.dart | wrong_answer_index_test(졸업·리셋·개정 삭제·레거시 폴백) |
| data/wrong_skills.dart | wrong_skills_test |
| data/cloud/auth_service.dart | cloud/auth_service_test 외 2파일 |
| data/cloud/cloud_store.dart | cloud/cloud_store_test 외 3파일 |
| data/cloud/firebase_bootstrap.dart | cloud/firebase_bootstrap_test |
| data/cloud/sync_controller.dart | cloud/sync_controller_test(15 케이스: fakeAsync 주기/고아 타이머/dispose 인터리브) |
| data/cloud/sync_merge.dart | sync_merge_attempts/lww/viewed_test(3파일) |
| data/cloud/sync_service.dart | cloud/sync_service_test(4종 화해·멱등·손상 stamp) |
| models/exam_session.dart | exam_session_test |
| models/question.dart | question_model_test 외 6파일 |
| models/study_content.dart | markdown_parser_test 외 3파일 |
| models/study_plan.dart | study_plan_model_test 외 9파일 |
| models/exam_guide.dart | cert_detail_sections_test |
| pages/audio_hub_page.dart | audio_hub_page_test |
| pages/cert_detail/*(5파일) | cert_detail_sections_test |
| pages/home/schedule_section.dart | home_schedule_section_test |
| pages/plan/plan_agenda.dart · plan_create_form.dart · plan_summary.dart · plan_page.dart | plan_page_test, plan_agenda_summary_test, plan_create_form_test |
| pages/sync_entry.dart | cloud/sync_entry_test |
| theme/app_theme.dart · theme_scope.dart | theme_scope_test, theme_persistence_test 외 다수 |
| widgets/app_header.dart · audio_progress_bar.dart · focus_ring.dart · lecture_transport_bar.dart · state_views.dart · study_audio_player.dart | 각 전용 테스트(app_header_test 등 6파일) |

### 간접 커버만 있음 (전용 테스트 없음, 상위 렌더/사용 경유)

- `models/certification.dart` — site_data 경유(official_sources_test)
- `models/attempt_record.dart` — 전용 파일 없음. 12개 테스트 파일에서 생성·직렬화 사용(history_store_test가 JSON 왕복 간접 커버)
- `pages/home_page.dart` + `pages/home/`(hero/levels/paths/roadmap/study_docs/exams/footer/home_bits/home_header/content_cert_card) — app_router_test·home_sections_test의 HomePage 전체 렌더 경유. home_due_banner_test는 dueIcon 순수함수만
- `pages/plan/plan_list_view.dart` — plan_page_test 렌더 경유
- `data/local_kv.dart` — MemoryBackend 계약이 study_reset_test(keys)+14파일 사용으로 커버. WebBackend(localStorage)는 web 전용
- `data/audio_runtime_stub.dart` — 조건부 import의 VM 경로로 audio_runtime_test가 간접 검증(audioRuntime == null)

### 테스트가 전혀 없는 lib 파일

**(a) 테스트 가능한데 없음 — 실질 공백 6개**

1. `lib/pages/review_page.dart` (~280줄, 오답노트 복습 세션 조립) → TEST-010
2. `lib/pages/report_page.dart` (~330줄, 약점 리포트 조립) → TEST-011
3. `lib/pages/cert_audio_page.dart` (오디오 페이지 글루) → TEST-012
4. `lib/content/reset_dialog.dart` (초기화 확인 다이얼로그; 하부 study_reset은 커버) → TEST-013
5. `lib/widgets/badges.dart` (표시용 배지) → TEST-013
6. `lib/util/open_link.dart` (링크 열기 래퍼, 조건부 import 껍데기) → TEST-013

**(b) 렌더 불가 제약 페이지 — 대체 커버 상태는 "발견 항목 앞 절" 참조**

- `lib/pages/cert_exam_page.dart`, `lib/pages/exam_page.dart`(외곽), `lib/pages/quiz_page.dart`(외곽), `lib/pages/study_doc_page.dart`, `lib/pages/cert_detail_page.dart`

**(c) 설계상 테스트 예외(웹 전용/실서비스 구현/설정) — 11개**

- web 전용(VM 컴파일 불가, build web + 라이브 dogfood로 검증): `data/audio_runtime_web.dart`, `data/web_audio_backend.dart`, `data/web_backend_web.dart`, `util/open_link_web.dart`, `data/cloud/app_resume_web.dart`
- Firebase 실구현(에뮬레이터 없인 불가; Fake로 계약만 검증 중): `data/cloud/firebase_auth_service.dart`, `data/cloud/firestore_cloud_store.dart`
- trivial 스텁/껍데기: `data/web_backend_stub.dart`, `util/open_link_stub.dart`, `data/cloud/app_resume_stub.dart`, `data/cloud/app_resume.dart`
- 설정 상수: `firebase_options.dart`

참고: web_audio_backend.dart는 mp3 404 실사고(PR#67) 이력이 있는 파일 — 순수 URL 로직은 audio_asset_url.dart로 추출·테스트됐고, 남은 DOM 래퍼는 라이브 검증만 가능(현 구조에서 타당).

## 제약 반영: SelectionArea+비동기 페이지의 대체 커버 평가 (점검 항목 3)

| 페이지 | 대체 커버 | 남은 공백 |
|---|---|---|
| CertDetail | 섹션 5개 위젯테스트(cert_detail_sections_test) + 라우터 redirect(app_router_test) | 사실상 없음(페이지 조립은 얇음) |
| StudyDoc | 파서·뷰·앵커·딥링크·heading slot·**shouldShowLecturePlayer 순수 게이트**·audio_nav 전부 단위 커버 | openDoc/nowPlaying 연결(90~93행)·미니플레이어 조립·섹션 시크 글루 — TEST-003/004와 연동 |
| Quiz | **QuizView 자체는 위젯테스트 렌더 가능**(quiz_view_test: 해설 공개·review 레코드 기록) | QuizPage 외곽(rootBundle 로드) 얇은 글루만 |
| Exam | **ExamView 렌더 테스트 두꺼움**(exam_view_test 8 케이스: 시간 만료 단일 제출·다이얼로그 중 만료·복원·세션 기록) | ExamPage 외곽(가이드 로드·폴백 페이스) |
| CertExam | ExamView 공유로 View는 커버, 부품(mock_exam/weighted_exam/exam_session) 전부 단위 커버 | **_load() 조립 로직 전체 — 최대 공백(TEST-001/002)** |

결론: "View 분리 + 순수함수 추출" 대체 전략이 Quiz/Exam/CertDetail/StudyDoc에는 실효적으로 작동 중. **CertExamPage만 조립 로직이 State 내부에 남아 대체가 없다.**

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| TEST-001 | `lib/pages/cert_exam_page.dart` 101~113행 `_load()` | 진행 중 모의고사 **세션 복원/폐기 판정 체인**(restoreOrdered→ordersCoverQuestions→불일치 시 store.clear)이 페이지 State 내부에 갇혀 어떤 테스트도 조립을 검증하지 않음. 부품 함수는 각각 테스트됐지만 "뱅크 개정 후 복원 거부+세션 폐기", "구버전 세션(optionOrders 없음) 폐기", "정상 복원" 시나리오의 연결이 무검증. 시험 직전 진행 저장·복원 신뢰성에 직결 | H | 높 | 판정부를 순수 함수로 추출(예: `decideRestore(ExamSession?, Map<String,Question>) → restorable/discard/none`) 후 3분기 단위테스트. 렌더 불가 제약과 무관하게 테스트 가능해짐 | A | N |
| TEST-002 | `lib/pages/cert_exam_page.dart` 55~67행 `_load()` | 개별 문항 뱅크 로드 실패를 **catch(_)로 무시하고 부분 풀로 진행** — 자산 누락/JSON 오염 시 문항 수 감소·도메인 편향이 조용히 발생. 테스트·사용자 노출(경고) 모두 없음 | M | 높 | 실패 뱅크 수를 _MockLoad에 노출하고 시작 화면에 경고 표시 + 추출 함수 단위테스트(1개 뱅크 오염 → 나머지로 진행 + 실패 카운트) | A | N |
| TEST-003 | `lib/data/lecture_playlist.dart` 58~69행 `openDoc` | **cert 전환 엣지 미테스트**: 재생/일시정지 중 다른 cert의 승인 문서 진입 시 setQueue가 큐·certCode·index를 교체하지만 컨트롤러는 이전 트랙을 계속 재생 → current/currentTitle(트랜스포트 바·잠금화면 메타)이 실재생 음원과 불일치. 현재는 CLF만 audioApproved라 미발현이나 두 번째 cert 승인 즉시 도달 가능한 경로 | M | 높(갭)·중(발현) | "재생 중 타 cert openDoc" 계약을 결정(큐 유지 or 교체+표시 정합)하고 lecture_playlist_test에 케이스 추가. 비-CLF 오디오 승인 전 필수 | A | N |
| TEST-004 | `lib/data/lecture_playlist.dart` 47~54행 `setQueue` + `lib/data/content_index.dart` ContentEntry | 같은 cert 재-setQueue 시 위치 보존 early-return이 `listEquals` + **ContentEntry의 identity 동등성(== 미구현)**에 의존 — 현재는 content_index 정적 인스턴스라 동작하지만 이 보존 계약 자체가 미테스트. 엔트리를 동적 생성(JSON 로드 등)으로 바꾸면 문서 진입마다 큐 리셋(재생 위치 이탈)이 조용히 회귀 | M | 높 | lecture_playlist_test에 "동일 cert·동일 트랙 재-setQueue → index·재생 비중단" 테스트 추가(회귀 가드). 장기적으로 ContentEntry에 값 동등성 or taskId 비교 | A | N |
| TEST-005 | `lib/data/lecture_playlist.dart` 106~112행 `playPause` + `lib/data/audio_controller.dart` | **ended 상태에서 playPause() 동작 계약 미규정·미테스트** — single 모드로 트랙이 끝난 뒤 재생 버튼을 누르면 controller.play()만 호출(재로드 없음). 브라우저 `<audio>`의 ended 후 play() 동작(처음부터/그 자리)이 상태기계 테스트에 계약으로 없음 | M | 중 | ended→playPause 기대 동작을 결정(재시작이면 load+play)하고 테스트로 고정 | A | N |
| TEST-006 | `lib/data/cloud/sync_controller.dart` 149~154행 `_startWatches` | **watch 트리거 양성 경로 미테스트**: 로그인 중 클라우드 컬렉션 변경 수신 → sync() 재실행이 테스트에 없음(음성 케이스 "signOut 후 미발화"만 존재). 멀티 디바이스 수렴의 핵심 트리거 | M | 높 | sync_controller_test에 "signed-in 중 spy.setDoc → loads 증가" 케이스 추가 | A | N |
| TEST-007 | `lib/data/cloud/sync_merge.dart` 70~79행 `mergeLww` | 클라우드 doc에 updatedAt 결손(cloudMs=-1) + 로컬에 해당 cert 부재 조합 → **merged에서 cert가 통째로 탈락(데이터 드롭)**하는 경로 미테스트. 자사 코드는 항상 updatedAt을 쓰지만 부분 쓰기/타 클라이언트 오염 시 도달 가능 | M | 높(갭)·중(발현) | 케이스 테스트로 현 계약을 명문화(드롭 의도면 주석+테스트, 아니면 updatedAt 결손 시 0 간주로 수정) | B | N |
| TEST-008 | `test/cloud/sync_merge_viewed_test.dart` | mergeViewed 테스트가 1건뿐 — 빈 입력 경계(로컬만/클라우드만), `taskIds` 필드 결손·비문자열 오염 캐스트 경로 미테스트(attempts는 경계 테스트 있음, 비대칭) | L | 높 | attempts 테스트와 동형의 경계 2~3건 추가 | B | N |
| TEST-009 | `lib/data/attempt_presented.dart` 6~16행 `resolvePresented` | 3번째 폴백(**집계시험 examId(-mock/-weak) + presented 빈 레거시 레코드 → wrongQuestionIds만 반영**)이 어디서도 테스트되지 않음. 직접 테스트는 taskFromExamId만, 소비자 테스트(wrong_answer_index·task_score_report)는 단일 Task 폴백까지만 커버. 구버전 모의고사 레코드의 오답노트/약점 리포트 집계 정확성이 무검증 | M | 높 | attempt_presented_test에 resolvePresented 3분기 직접 테스트 추가(특히 mock 레코드: 정답 문항이 집계에서 제외되는 현 동작 명문화) | A | N |
| TEST-010 | `lib/pages/review_page.dart` (전체, _ReviewLoad/_ReviewRun) | **오답노트 복습 세션 조립 무테스트** — weak 문항 선별→퀴즈 구성→복습 기록의 연결 글루. 하부(wrong_answer_index 졸업 로직, QuizView review 레코드 기록)는 커버됨. Review는 SelectionArea 제약 목록(CertDetail/StudyDoc/Quiz/Exam/CertExam)에 없는 페이지인데도 테스트 부재 | M | 높 | 세션 구성부(weak entries → 출제 문항 리스트) 순수 함수 추출 + 단위테스트, 또는 렌더 가능 여부 확인 후 위젯테스트 | A | N |
| TEST-011 | `lib/pages/report_page.dart` (전체, _ReportLoad) | 약점 리포트 페이지 조립 무테스트(하부 task_score_report·concept_report·wrong_skills는 전부 커버). 표시 조립 위주라 위험도는 review보다 낮음 | L | 높 | 조립 로직이 커지기 전 _ReportLoad 구성부 추출·테스트(현재는 후순위 허용) | B | N |
| TEST-012 | `lib/pages/cert_audio_page.dart` | 페이지 글루(트랙 리스트→playlist.select 연결, _TrackRow 상태 표시) 무테스트. 하부 LecturePlaylist·TransportBar·AudioHub는 전부 테스트됨 | L | 높 | audio_hub_page_test 패턴으로 얇은 위젯테스트 1~2건(트랙 탭→select 호출) | B | N |
| TEST-013 | `lib/widgets/badges.dart`, `lib/content/reset_dialog.dart`, `lib/util/open_link.dart`, `lib/models/certification.dart`(간접만), `lib/pages/plan/plan_list_view.dart`(간접만) | 직접 테스트 없는 표시용/얇은 파일 묶음. reset_dialog는 파괴적 동작(초기화)의 확인 UI라 이 중 우선순위 최상 | L | 높 | reset_dialog만 위젯테스트(확인/취소 → study_reset 호출 여부) 추가 권장, 나머지는 수용 가능 | B | N |
| TEST-014 | test 전반 (10파일) | **픽스처 헬퍼 중복**: AttemptRecord 로컬 팩토리(_rec/_r)가 10개 파일에 재정의(생성 19곳), Question 7파일, ContentEntry 5파일. 모델 필드 추가 시 다중 파일 수정 비용(presentedQuestionIds 추가 때 실제 발생 패턴) | L | 높 | `test/helpers/fixtures.dart` 공용 팩토리로 통합(동작 변경 없음, 기계적) | B | N |
| TEST-015 | `test/cloud/sync_controller_test.dart` 127·142·218·224행 | **실시간 sleep 의존**: 스트림 전파 대기를 `Future.delayed(20ms)` 벽시계로 처리(4곳). 같은 파일의 다른 케이스는 fakeAsync로 결정적 — 비일관. 현재는 안정적이나 CI 부하 시 플레이크 여지 | L | 높 | fakeAsync + flushMicrotasks로 통일(또는 pumpEventQueue) | B | N |
| TEST-016 | `test/` 9파일 (all_content_parse, saa/soa/clf 콘텐츠, question_model, markdown_parser, section_anchor_link, content_index, content_enrichment) | **실디스크 I/O**: dart:io로 실제 콘텐츠 md/json을 읽음. 콘텐츠 회귀 게이트(전 md 파싱, verified 카운트)로는 의도된 설계라 수용. 단 question_model_test·markdown_parser_test 같은 단위테스트까지 실파일 의존이라 콘텐츠 수정이 단위테스트 결과에 결합됨(게이트/단위 역할 혼재) | L | 높 | 정보성. 신규 단위테스트는 인라인 픽스처 우선, 실파일 의존은 게이트 테스트에 한정하는 관례 문서화 | B | N |
| TEST-017 | `lib/data/plan_scheduler.dart` 29~70행·147~150행 | redistribute의 **examDate 모드**(lastDay=endIso-1) 미테스트(모든 redistribute 테스트가 period 모드) — 시험일 당일 제외 경계 무검증. _mockCount 상한 clamp(6) 미테스트(장기 플랜) | L | 높 | examDate 재분배 1건(시험 전날까지만 배치) + 장기 플랜 mock 6회 상한 1건 추가 | B | N |
| TEST-018 | `lib/pages/home_page.dart` 92행, `lib/pages/plan_page.dart` 39행 | todayIso를 `DateTime.now()` 직접 호출 — clock 주입 시임이 없어 due 배너/어젠다 "오늘" 양성 케이스를 위젯 레벨에서 결정적으로 테스트할 수 없음(현 테스트는 플랜 없음·상대 날짜 구성으로 회피, 자정 경계 이론상 플레이크). 순수부(planDueCounts 등)는 todayIso 파라미터라 문제 없음 | L | 높 | 페이지에 `nowIso`/clock 주입 파라미터(테스트 전용 기본값 DateTime.now) 추가하면 due 양성 위젯테스트 가능 | B | N |

### 잘 되어 있는 것(참고 — 유지할 패턴)

- **ended 이중전진 가드**: lecture_playlist_test '연속 ended emit 시 next() 1회만' — _lastState 갱신 순서(재진입) 주석과 테스트가 짝을 이룸. 과제에서 지목한 이 엣지는 이미 커버됨.
- **인터리브 하드닝**: sync_controller_test의 fakeAsync 고아 타이머/dispose 추월 케이스는 이 규모 앱에서 드물게 성실한 커버리지.
- **선택지 셔플 분포 스모크**(mock_exam_test): correct=0 쏠림 데이터 재현 후 95% 독점 부정 — 실데이터 결함을 테스트로 각인.
- **시간 주입 규율**: SyncService(nowMs)·plan 순수함수(todayIso)·샘플러(rng 주입) — 테스트 대상 계층엔 벽시계/난수 시임이 일관 적용돼 있음(페이지 계층만 예외, TEST-018).
