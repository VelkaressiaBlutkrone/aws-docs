# DEA-C01 도메인 2 출고 — 핸드오프 (2026-10-20)

작성: 도메인 2 세션 (worktree `pensive-lalande-712f14`, 브랜치 `feat/2026-10-20-dea-content-domain2`)
PR: https://github.com/VelkaressiaBlutkrone/aws-docs/pull/148 (base=develop, **머지 안 함 — 사용자 몫**)

## 결과

- 학습문서 4편: `flutter_app/assets/content/dea/dea-t2-1.md` ~ `dea-t2-4.md` (402·315·320·357행)
- 문항 드래프트: Task당 15개 = **총 60개, 전부 `verified: false`**
- `content_index.dart` 도메인 2 엔트리 4줄(`questionCount: 0`), `test/dea_questions_test.dart`에 t2-1~t2-4 누적
- 게이트 실측: `flutter test` **1,088 그린**(기준선 1,076 + 신규 12) · `flutter analyze` **0건**
- 라이브 노출 변화 0 (verified:false + questionCount 0)

## 도메인 3·4 담당 세션에게 — 레시피에서 실제로 중요한 것

1. **`pubspec.yaml`은 건드리지 말 것.** 에셋이 `assets/content/dea/`(190행) **디렉터리 단위로 등록**돼 있어 신규 md·json이 자동 포함된다. 도메인 1에서도 pubspec 변경은 t1-1 때 디렉터리 1줄 추가가 전부였다(t1-2~t1-4는 무변경). 개별 파일 8개 등록을 요구하는 지시를 받더라도 그건 전제가 틀린 것이니 확인하고 보고할 것.
2. **신규 테스트 수 = 문서 수 × 1 + Task 수 × 2.** `all_content_parse_test`가 `assets/content` 전체를 순회해 문서당 1건, `dea_questions_test`가 Task당 2건(파일 존재 · 스키마/밀도)을 만든다. 도메인 2는 4 + 8 = 12건 → 1,076 + 12 = 1,088.
3. **`content_index_test`의 동적 불변식**(`questionCount == JSON의 verified 수`)이 있으므로 `questionCount: 0`과 `verified: false`는 반드시 짝으로 유지.
4. **문항은 4지선다만.** `dea_questions_test`가 `options.length == 4`를 단정하므로 복수응답형(5지 이상)은 만들 수 없다. `wrongExplanations` 키는 비정답 인덱스 **전부**(3개).
5. 학습문서 템플릿 마커 8개(`커버하는 공식 Task`, `## ✅ 학습 목표 체크리스트`, `## 🎯 왜 중요한가`, `## 📖 핵심 개념`, `## ✍️ 시험 포인트`, `## ⚠️ 흔한 함정`, `## 🧪 자가 점검`, `### 📌 출처`)는 DEA에 강제 테스트가 없지만 도메인 1·2가 모두 지켰으니 유지 권장(SOA는 `soa_content_structure_test`가 강제).
6. 파서는 md 하위집합 — `#{1,6}` 헤딩만. 새 문법 쓰지 말 것.

## 노트에서 발견한 문제 (고치지 않고 보고만)

**`docs/content-research/DEA-C01/tasks/2-1.md` 사실 #55 — S3 Vectors 지연 서술이 인용과 반대.**
영어 인용은 `"Sub-100 ms query latency that is optimized for long-term storage and infrequent access patterns"`인데 한국어 서술은 "100 ms **이상** 지연 허용"으로 뜻이 뒤집혀 있다. 같은 오류가 `99-gaps.md`에도 전파됐을 수 있다(§4의 G-2.1-17 주변). 어느 쪽이 옳은지 공식 문서로 확정하지 못해 학습문서에서는 **지연 수치를 아예 쓰지 않고** "인덱스당 최대 20억 벡터·장기 저장과 드문 조회에 최적화"로만 서술했다. `[의심]` 항목 보존 원칙에 따라 노트는 그대로 뒀다.
→ 도메인 3·4에서 S3 Vectors를 다룰 일이 있으면 공식 문서를 직접 열어 확인할 것.

## 정답 근거로 쓰면 안 되는 것 (99-gaps 기준, 도메인 2에서 실제로 배제한 목록)

Redshift 기본 격리 수준(G-2.1-08) · MV 자동 새로 고침 우선순위(G-2.1-09) · Serverless 최대 RPU 512/1024(G-2.1-15) · Aurora 볼륨 최대 크기(G-2.1-10) · KDS on-demand 상한(G-2.1-11, 기본값 4/8 MB/s만 사용) · RDS 엔진별 읽기 복제본 수(G-2.1-12) · pgvector 성능 배수 8×/9×(G-2.1-13) · S3 Tables 기본 compaction 전략(G-2.1-16) · IVF/HNSW 메모리 트레이드오프(G-2.1-18) · AS2↔EFS 조합(G-2.1-21) · S3 Standard→IA 30일 선행 조건(G-2.3-01) · 128KB 전환 제한 적용 기준(G-2.3-02) · Glacier FR/DA "최소 청구 40KB"(G-2.3-03, "객체당 40KB 오버헤드"로 서술) · RTC SLA 수치(G-2.3-04) · TTL "즉시 삭제"(G-2.3-05) · COPY 클라이언트 측 암호화(G-2.3-07, 오답/함정으로만) · Schema Registry 기본 호환성 모드(G-2.4-11, "BACKWARD 권장"까지만) · "작은 디멘션 = ALL"(G-2.4-05, 단독 정답 금지) · Snowball Edge·Amazon Glacier 독립 서비스(G-2.1-03·04, 함정으로만) · Redshift RG 노드(G-2.1-05) · Lake Formation 계보(G-2.4-04, 오답 선택지로만) · Bedrock KB의 "EMR Serverless"(G-2.1-14).

도메인 3·4 gaps는 `99-gaps.md` 994행 이후(§4 Task 3.1~4.5)에 있다. 착수 전 §1.2(개명·종료)·§1.3(수치 상충)·§1.6(문항 작성 공통 주의)을 먼저 읽을 것.

## 워크트리 주의

`origin/develop`이 내 분기 이후 e9c7b0f로 전진했다(다른 세션의 HANDOFF/TODOS/WORKLIST 상태 문서 커밋). 내 PR과 겹치는 파일은 없어 `MERGEABLE`. 로컬 `develop`·`docs/2026-10-20-status-drift` 브랜치는 다른 세션이 쓰는 중이니 강제 이동·reset 금지(CLAUDE.md §5).
