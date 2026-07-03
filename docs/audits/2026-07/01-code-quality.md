# ① 코드 품질·아키텍처 감사 종합 — 2026-07

- 입력 샤드: `raw/01-code-a.md`(pages, 25건) · `raw/01-code-b.md`(data, 12건) · `raw/01-code-c.md`(content·models·theme·util, 12건) · `raw/01-code-d.md`(widgets·루트·DESIGN 전역 스윕, 12건)
- 상세 근거·전체 표는 각 샤드가 정본. 이 문서는 중복 통합 + 심각도 정렬 + Phase 편성 뷰.

## 요약

`flutter_app/lib` 110파일 전수 감사. **발견 61건 = H 3 · M 24 · L 32 · 정보 2.** 컨트롤러가 H 3건 전부 소스 재확인 완료(실재).

- **H-1 `CODE-C-001` 파서 불릿 0-소비 무한루프(잠복)** — `markdown_parser.dart:166 vs 183` 정규식 비대칭. `- [ ]`(빈 체크박스)·`- [x]텍스트`(공백 누락) 입력에서 페이지 멈춤. 실콘텐츠에 체크리스트 203회 사용 — **콘텐츠 오탈자 1건이면 라이브 발화**. PR#27이 고친 H4 사고와 동일 클래스. 컨트롤러 소스 재확인 완료.
- **H-2 `CODE-P-001` 홈 히어로 CTA 2개 완전 무동작** — `HomeButton`에 onTap 자체가 없고 호출부도 const. 첫 화면의 가짜 어포던스(DESIGN.md 인터랙티브 규율 위반). 컨트롤러 재확인 완료(`home_bits.dart`에 onTap 0건).
- **H-3 `CODE-D-001` 현행 플랜(v2)이 클라우드 백업에서 제외** — SyncService는 `awsdocs.plan.v1`만 화해하는데 StudyPlanStore는 v2에 기록. 동기화가 v1 잔재만 왕복. 테스트도 v1만 검증해 gap 미탐지.

구조 부채의 중심: 250줄 초과 12파일(최대 exam_page 683줄), 복붙 계열 10건(뱅크 로드 루프 4벌, KV store 보일러플레이트 6~7벌, 행 링크 카드 5벌 등). 규율 준수는 양호 — GestureDetector 단독 0건, Wght 병기 전 파일 일치(단 자동 게이트 부재 `CODE-W-002`), 색 하드코딩은 테마 내부 1쌍뿐.

## 중복 통합(샤드 간 동일/동계열 발견)

| 통합 | 항목 | 처리 |
|---|---|---|
| onError 하드코딩 | `CODE-C-010` ≡ `CODE-W-007` (`app_theme.dart:275-277`) | 1건으로 계수(위 합계 반영: C-010을 대표로) |
| 간격 리터럴 산재 | `CODE-P-022` ≈ `CODE-W-006` (관점: pages vs 전역 스윕) | 로드맵에서 1개 항목으로 편성 |
| 포커스 링 누락 InkWell | `CODE-P-005` · `CODE-P-006` | 동일 계열 — 일괄 수정 1PR |
| 필/칩/원형버튼 위젯 중복 | `CODE-P-016` · `CODE-W-004` · `CODE-W-005` | 공용 프리미티브 수렴으로 묶음 |

## H·M 통합 표 (심각도·Phase 정렬)

| ID | 위치 | 요지 | 심각도 | Phase |
|---|---|---|---|---|
| CODE-C-001 | content/markdown_parser.dart:179-189 | 불릿 0-소비 무한루프 잠복(체크리스트 정규식 비대칭) — 실패 테스트 선작성 후 정규식 통일+공통 진전보장 | H | A |
| CODE-P-001 | pages/home/hero_section.dart:46-53 | 히어로 CTA 2개 무동작 — onTap 배선+FocusTap 또는 버튼 스타일 제거 | H | A |
| CODE-D-001 | data/cloud/sync_service.dart:24 | 플랜 v2 클라우드 백업 누락 — plans 키 v2 전환+병합 규칙·테스트 | H | B* |
| CODE-P-002 | pages/home/exams_section.dart:41 | 라이브 통합 모의고사에 상시 '준비 중' 거짓 라벨 | M | A |
| CODE-P-003 | pages/cert_detail/learning_content_section.dart:71 | 'clf-t' 하드코딩 — SAA Task 라벨 깨짐 | M | A |
| CODE-P-004 | pages/study_doc_page.dart:335-343 | '시험처럼 풀기 (~N분)' CLF 페이스 하드코딩 — SAA에서 거짓 시간 | M | A |
| CODE-P-005/006 | report_page.dart:243 · cert_exam_page.dart:302 | 맨 InkWell(포커스 링 규율 위반) 2건 | M | A |
| CODE-C-002 | content/markdown_parser.dart:133-154 | 표 분기 3중 degrade 결함(1줄 표 소실·구분행 무검증·빈 셀 열-시프트) | M | A |
| CODE-D-002 | data/cloud/sync_service.dart:66-71 | plan progress 동기화 제외 — 기기 간 완료 표시 분기 | M | B |
| CODE-D-003 | data/study_reset.dart:26-52 | 로컬 초기화가 다음 reconcile에서 부활(tombstone 부재) | M | B |
| CODE-D-004 | data/cloud/sync_service.dart:73-123 | reconcile read-modify-write 레이스(await 중 사용자 쓰기 유실 창) | M | B |
| CODE-D-005 | data/content_index.dart(511줄) | 정적 테이블+모델+헬퍼 혼재 — cert별 분리 | M | B |
| CODE-D-006 | data/*store 6~7파일 | KV 보일러플레이트 복붙 — 공용 헬퍼 추출 | M | B |
| CODE-P-007~010 | exam_page(683)·plan_agenda(502)·cert_exam(400)·study_doc(393) | 대형 페이지 4파일 분해 | M | B |
| CODE-P-012 | 4페이지 | 뱅크 로드 루프 4벌 복붙(+hasQuestions 가드 드리프트 이미 발생) — 공용 로더 | M | B |
| CODE-P-013 | exam_page:633 ≒ cert_exam_page:232 | PrescriptionHub 배선 복붙 | M | B |
| CODE-P-014 | learning_content_section 외 | 행 링크 카드 5벌 인라인 — 위젯 추출 | M | B |
| CODE-P-015 | home/home_header.dart | 메뉴 아이템·원형 트리거 중복 구현 | M | B |
| CODE-P-018 | review_page ≒ report_page | _resetCert 2벌 복붙(경고 문구 드리프트 위험) | M | B |
| CODE-C-004 | content/study_markdown_view.dart(333) | 헤딩 trailing 중복 2벌 + 3책임 — 분해 | M | B |
| CODE-C-005 | content/quiz_widgets.dart(319) | 위젯 6개 혼재·PrimaryButton 역-의존 | M | B |
| CODE-W-001 | widgets/app_header.dart(377) | 7책임 동거 — 분리 | M | B |
| CODE-W-002 | (게이트 부재) | Wght 1:1 규율의 자동 게이트 없음 — 정적 테스트 추가 | M | B |

\* CODE-D-001은 H이지만 동기화 프로토콜 변경이라 시험 전 리스크 대비 이득이 낮아 Phase B 배치(스펙 §7 기준). 단기 완화는 없음 — 로드맵에서 Phase B 최상단.

## L·정보 (32+2건 — 샤드 참조)

- pages: CODE-P-011, 016, 017, 019(A 후보: '3회' 하드코딩 보간), 020~025 → `raw/01-code-a.md`
- data: CODE-D-007~012 → `raw/01-code-b.md`
- content·theme: CODE-C-003, 006~012(008은 A 후보: 가짜 링크 어포던스) → `raw/01-code-c.md`
- widgets·전역: CODE-W-003~012 → `raw/01-code-d.md`

## 사실의심(2단 검증행) 항목

없음(코드 차원 — 전부 N).
