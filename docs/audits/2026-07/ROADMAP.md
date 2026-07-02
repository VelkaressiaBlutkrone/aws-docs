# 개선 로드맵 — 2026-07 전면 감사 기반

> 8개 차원(①코드 ②테스트갭 ③학습문서 사실성 ④문항 품질 ⑤오디오 대본 ⑥재생 코드 ⑦의존성 ⑧관리위생) 1단 감사 + 2단 반박 검증(12클러스터) 결과를 실행 로드맵으로 편성한다.
> **정본 상세**: 콘텐츠 사실 항목은 [`human-review-list.md`](human-review-list.md)(105건, 시험영향순 + 정정금지 11계열), 차원별 원자료는 `raw/`·`03-docs-facts.md`.
> **편입 기준**: Phase A = 학습을 직접 방해하는 결함(콘텐츠 사실 오류·플로우/재생 버그)이면서 리스크 낮음. 그 외 전부 Phase B. 시험은 2~4주 내 **CLF-C02** — CLF 항목이 최우선.

## 감사 총괄 (규모·신뢰도)

- **1단 발견 ~300건**(①코드 61 · ②테스트 18 · ③문서 134 · ④문항 다수 · ⑤오디오 · ⑥재생 17 · ⑦의존성 5 · ⑧위생 12).
- **2단 반박 검증**: 사실의심 82계열 → **CONFIRMED 71 · REFUTED 11 · UNCERTAIN 0**.
  - **REFUTED 11건은 문서가 옳음**(정정 금지) — 대부분 감사자 지식 컷오프(2026-01) 밖의 2025 하반기 AWS 변경을 문서가 정확히 반영. 가장 강하게 의심했던 교차패턴 **P1 Aurora 256TiB·P2 Cost Explorer 18개월**이 여기 포함 → 검증 없이 고쳤으면 라이브 콘텐츠를 구식화할 뻔함.
- **시험 버전 리스크 없음**: CLF-C02·SAA-C03·SOA-C03 모두 2026-07 현행(웹 실측). 사용자 CLF 응시에 영향 없음.
- **문항 은행 건강**: 활성 385문항 + 드래프트 270문항 전수 점검 — 정답 뒤집힘 H는 SAA 1건(경합, 사람 결정)뿐. 드래프트 verified:true 혼입 0(노출 게이트 안전).

---

## Phase A (시험 전 ~4주 — 안정성 우선)

> CLF 시험 직결 콘텐츠 정정 + 사용자 가시 플로우 결함 + 이미 준비된 위생 수정. 전부 저리스크. **콘텐츠 정정의 사실 근거·정정 방향은 human-review-list.md가 정본**(여기선 편성만).

### A-1. CLF 콘텐츠 사실 정정 (시험 최우선, 사람 검수)

| 항목 | 근거(리포트 ID) | 크기 | 리스크 | 권장 시점 |
|---|---|---|---|---|
| Enterprise Support "프로덕션 15분"→"비즈니스 크리티컬 다운" (문서+문항 3곳 동시) | DOC-CLF-309, Q-CLF-t4-3-01·02, AUD-401 (V1 CONFIRMED) | S | 낮음(자구, 수치 15분 유지) | 즉시 |
| "Support 플랜 변경=루트 전용" 낡은 단정 제거 (문서 3곳+문항 해설) | DOC-CLF-102, Q-CLF-t2-3-01 (V1 CONFIRMED) | M | 낮음(레거시 기출 관례는 사람 판단) | 즉시 |
| SNS "저장·재시도 없음"→"재시도·DLQ 존재" | DOC-CLF-301 (V5) | S | 낮음 | 즉시 |
| Savings Plans "72%+완전유연" 분리 (72%=EC2 Instance SP) | DOC-CLF-305 (V4 교차) | M | 낮음 | 즉시 |
| 11 9s 내구성에 기간("1만 년") 복원 | DOC-CLF-203 (V12) | S | 낮음 | 즉시 |
| DynamoDB "트래픽 없으면 비용 없음"→스토리지 과금 단서 | DOC-CLF-201 (V12) | S | 낮음 | 즉시 |
| EBS "종료해도 유지"→루트 볼륨 기본 삭제 구분 | DOC-CLF-202 (V12) | S | 낮음 | 즉시 |
| scale up/down → out/in 정정 | DOC-CLF-204 (V12) | S | 낮음 | 즉시 |
| Glacier 복원시간 클래스별 병기(Instant=밀리초) | DOC-CLF-306 (V12) | S | 낮음 | 즉시 |
| ECS/EKS 관리형 패치 일반화 완화 · 서버리스 정의 확장 · Customer Enablement 범주명 | DOC-CLF-001·003·304 | S | 낮음 | 선택 |

**오디오 대본 정정 주의**: 위 문서 정정 중 t4-3(15분)·t4-1(SP)·t3-4(DynamoDB)·t3-6(EBS)·t3-3(scale) 등은 대본이 낭독 중이므로, 원문 정정 → 재합성 → reviewStatus 리셋 → **사람 청취 재승인**이 필수(동기화 게이트). AUD-401(대본 "보장" 단정강화)만 대본 단독 수정 가능하나 역시 재합성.

### A-2. 사용자 가시 플로우·접근성 결함 (코드)

| 항목 | 근거 | 크기 | 리스크 | 권장 시점 |
|---|---|---|---|---|
| 홈 히어로 CTA 2개 완전 무동작(클릭·Tab·Enter 불가) → onTap 배선+FocusTap | CODE-P-001 (H) | S | 낮음 | 즉시(첫 화면 신뢰) |
| 통합 모의고사 카드 "준비 중" 상시 거짓 라벨 → 검증 문항 수 표기 | CODE-P-002 (M) | S | 낮음 | 즉시(정직성) |
| SAA 상세 Task 라벨 'clf-t' 하드코딩 → 깨진 라벨 일반화 | CODE-P-003 (M) | S | 낮음 | SAA 노출 중이면 즉시 |
| SAA "시험처럼 풀기" 시간이 CLF 페이스 하드코딩 → per-cert 조회 | CODE-P-004 (M) | S | 낮음 | 즉시 |
| report/cert_exam 맨 InkWell 포커스링 누락(DESIGN L124) | CODE-P-005·006 (M) | S | 낮음 | 즉시 |
| 잠금화면 MediaSession 제목이 트랙 전환에 미갱신 | PLAY-101 (M) | S | 낮음 | 오디오 사용자 대상 |
| 트랙행 재생 InkWell 접근성 라벨 부재 | PLAY-107 (M) | S | 낮음 | 즉시 |

### A-3. 잠복 크래시 가드 (저리스크, 콘텐츠 안전망)

| 항목 | 근거 | 크기 | 리스크 | 권장 시점 |
|---|---|---|---|---|
| markdown_parser 불릿 분기 0-소비 무한루프(잠복) — 체크박스 오탈자 1건이면 페이지 멈춤. 정규식 통일+루프 진전보장 승격 + 실패테스트 선작성 | CODE-C-001 (H, 잠복) | S | 낮음(현 자산 미발화) | 즉시(콘텐츠 편집 안전망) |
| 표 파서 조용한 콘텐츠 소실/열-시프트 | CODE-C-002 (M) | S | 낮음 | 선택 |

### A-4. 관리 위생 (이미 준비됨)

| 항목 | 근거 | 크기 | 리스크 | 권장 시점 |
|---|---|---|---|---|
| **위생 PR#103 머지**(analyze 3건 해소·기준선 갱신) — 현 감사 브랜치 조상 아님 | HYG-011, P5 | S | 낮음 | 즉시(사용자 승인) |
| TODOS.md stale 정정(src/content/index.ts→content_index.dart, C-중량·wrongSkills 완료 표기) | HYG-001·002 | S | 없음 | 즉시 |
| CLAUDE.md 기준선 "499→778", analyze "0 게이트" | HYG-003·004 | S | 없음 | 즉시 |

---

## Phase B (시험 후)

### B-1. SAA/SOA 콘텐츠 사실 정정 (시험 무관 — 확장 준비)

- **SAA 문서 41건 + SAA 활성 문항 10건**: NAT HA·Interface EP(P4)·SNS 필터·gp3 크레딧·GA 체이닝·Budget Actions·RDS 15개·KMS 교집합(P3)·Geoproximity(P5)·WAF 등. 역방향 2건(Convertible RI 66%·No Upfront 1년) 문서 정정. **정정 방향은 human-review-list ④⑤ 절**.
- **SOA 문서 38건**: 문항 0이라 시험 영향 최저(미래 대비). Flow Log REJECT 전면 재작성(L 규모, DOC-SOA-315)·경보 작업·CloudWatch/ASG·CFN/거버넌스·가이드 v1.1.
- **교차계열 동시수정**: P3 KMS(6곳)·P4 Interface EP·P5 Geoproximity(6곳, 시점 2024-01-10)·P7 Firehose 개명·P9 단종메모. **Route 53 8종**(saa-t3-7·soa-t5-3 동시 — SAA 감사 오탐 정정).
- **자구 통일(N)**: P6 "DX over VPN"→"VPN over Direct Connect" 8곳, "(원리 §N)" 참조 깨짐 7문서, 발음 병기 비일관.

### B-2. 코드 리팩토링 (구조 — 상위 후보)

| 항목 | 근거 | 크기 |
|---|---|---|
| exam_page.dart 683줄 3분할(러너·위젯·로더) | CODE-P-007 | M |
| CertExamPage `_load()` 세션 복원 판정 순수함수 추출 + 3분기 단위테스트 | TEST-001 (H, 최대 공백) | M |
| 뱅크 로드 루프 4벌·PrescriptionHub 배선 2벌·_resetCert 2벌 공용화 | CODE-P-012·013·018 | M |
| content_index.dart 511줄 cert별 분리 | CODE-D-005 | M |
| KV store 보일러플레이트 공용 헬퍼 | CODE-D-006 | M |
| study_markdown_view·quiz_widgets 분해, _LinkCard·필/칩 위젯 수렴 | CODE-C-004·005, CODE-P-014·016 | M |

### B-3. 클라우드 동기화 정합 (데이터 — 조사 필요)

| 항목 | 근거 | 크기 |
|---|---|---|
| 플랜 저장 키 v1/v2 불일치 — 현행 플랜이 클라우드 백업 안 됨 | CODE-D-001 (H) | M |
| 로컬 초기화가 reconcile로 부활(tombstone 부재) | CODE-D-003 (M) | M |
| reconcile read-modify-write 레이스 | CODE-D-004 (M) | M |

### B-4. 인프라·전략

| 항목 | 근거 | 크기 |
|---|---|---|
| **의존성 업그레이드** go_router 16→17(ShellRoute 미사용→영향0)·Firebase 트리오 마이너 | DEP-001~004 | S |
| Flutter SDK: 업그레이드 불요(현 SDK가 최신 요구 충족) | DEP (07-deps) | — |
| **174MB 오디오 자산 전략**: mp3 별도 호스팅/CDN·SW 캐시(반복방문 재다운로드) — 현재 preload=metadata라 초기로드 무영향 | PLAY-105 | L |
| **기계 게이트 스크립트화**: fontWeight↔fontVariations Wght 1:1 게이트 테스트, 문항 correct 범위 불변식 | CODE-W-002, CODE-C-009 | S |
| 테스트 갭 보강: watch 트리거·mergeLww 결손·resolvePresented 3분기·reset_dialog | TEST-006·007·009·013 | M |
| 문서 아카이브: docs/superpowers 완료 스펙/플랜 29건 이동 | HYG-012 | S |

### B-5. 콘텐츠 확장·검증 (CLF 합격 후 게이트)

| 항목 | 근거 | 크기 |
|---|---|---|
| SAA 드래프트 18파일 270문항 flip(도메인1 우선 — 현재 활성 0) | 04-q-inactive | L |
| 외부 검증자 블라인드 테스트(2~3명) | TODOS | L |
| 유입 채널 실행(한국어 SEO·커뮤니티·README 정비) | TODOS, HYG-005 | M |

---

*집계: Phase A ~30항목(CLF 콘텐츠 16 + 코드/재생 9 + 위생 5) · Phase B 나머지 전부. 콘텐츠 사실 정정은 전건 사람 검수(원칙: 사실 환각 최종 판정은 사람). 본 로드맵은 감사·검증 결과의 편성이며 새 판정을 추가하지 않았다.*
