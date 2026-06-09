# TODOS

## 자격증별 문항 데이터 코드 스플리팅 (P3)
- **What:** 콘텐츠 레지스트리(`src/content/index.ts`)를 자격증 상세 진입 시 dynamic import로 전환
- **Why:** 문항 데이터(~100KB/자격증)가 전부 메인 번들에 포함됨. 12개면 홈 방문자도 ~1.2MB 다운로드
- **Trigger:** **3번째 자격증 콘텐츠 추가 시점** (2개까지는 premature optimization)
- **Context:** 2026-06-05 /plan-eng-review D8 결정. 레지스트리(3A)가 자연스러운 분할 지점이라 전환 비용 낮음. 렌더 흐름이 async로 바뀌는 것이 주된 작업
- **Depends on:** 콘텐츠 레지스트리 구현 완료

## 외부 검증자 블라인드 테스트 (CLF 합격 후)
- **What:** 외부 학습자 2~3명이 이 사이트만으로 학습→모의고사→실제 응시(또는 공식 샘플 문항)하는 블라인드 검증 + 후기 수집
- **Why:** 제작자 본인은 콘텐츠 제작 중 외부 자료를 봤으므로 "이 사이트만으로"의 깨끗한 표본이 아님 (학습/평가 데이터 오염). 제품 가설은 외부인만 검증 가능
- **Context:** 2026-06-05 Codex outside-voice 지적, D17 수용. 후기는 첫 마케팅 자산이 됨
- **Depends on:** CLF 콘텐츠 완성 + 본인 실제 합격

## 유입 채널 실행 (CLF 완성 + 본인 합격 후)
- **What:** 한국어 검색 키워드 최적화(타이틀/메타), 커뮤니티 공유(OKKY/커리어리/AWSKRUG), README 랜딩 정비 중 최소 1개 실행
- **Why:** 배포 ≠ 도달. "모든 사람들이" 쓰려면 발견 경로 필요
- **Cons/시점:** 콘텐츠가 CLF 1개일 때 홍보하면 "준비 중 11개"가 첫인상 — 반드시 CLF 완성 후
- **Context:** 2026-06-05 Codex outside-voice 지적, D18 수용
- **Depends on:** CLF 완성, 외부 검증자 테스트와 연계 가능

## C-중량: 개념→학습문서 섹션 앵커 딥링크 (P3)
- **What:** report_page를 Task→개념 중첩 구조로 개조 + `study_doc_page.dart`에 마크다운 섹션 앵커/스크롤 인프라 + `concept_step_map.dart`(개념→stepId 매핑)
- **Why:** 현재 개념 라벨은 Task 문서로만 보낸다(스크롤은 사용자 몫). 앵커가 있으면 "이 개념 → 바로 그 문단"으로 정밀 처방. Codex outside-voice도 "앵커 없으면 skill은 라벨/필터 단서지 정밀 내비 타깃이 아니다"라고 지적
- **Cons:** 마크다운 파서·라우트 파싱·스크롤 타이밍·콘텐츠 매핑까지 PR이 7~8파일로 번짐. 가치 증명 전 인프라 선건축 위험
- **Context:** 2026-06-09 /plan-eng-review D5. A+C-경량(이번 PR)이 동선·개념 라벨을 깐 뒤, 라벨 클릭/스크롤 마찰이 실제 문제로 드러나면 착수. 개념 태그(`Question.skill`)는 이미 채워져 데이터는 준비됨
- **Depends on:** A+C-경량 출고 + 개념 라벨 사용 관찰

## AttemptRecord.wrongSkills[] 비정규화 (P3)
- **What:** 응시 레코드에 오답 개념(skill) 목록을 저장해 report/review에서 다회차 누적 "약점 개념" 추세를 파생
- **Why:** 현재 개념 진단은 단일 응시(결과 화면)뿐. 다회차 누적은 wrongQuestionIds→뱅크 조인으로만 가능한데, 개정으로 사라진 문항은 개념이 유실됨. 비정규화하면 stale 문항에도 개념 보존
- **Cons:** 스키마 확장 + 마이그레이션(레거시 레코드는 빈 배열). C-중량과 함께여야 의미
- **Context:** 2026-06-09 /plan-eng-review D6. C-중량(위 TODO)과 짝
- **Depends on:** C-중량 방향 확정

<!-- 참고(stale flag, 2026-06-09): 상단 "코드 스플리팅" TODO의 `src/content/index.ts`는
     Flutter 마이그레이션 이전 Vite/TS 경로. 현재는 lib/data/content_index.dart. 경로 갱신 필요(미수정 — 별도 결정). -->>
