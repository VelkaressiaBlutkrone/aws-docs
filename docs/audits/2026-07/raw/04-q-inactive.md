# ④ 문항 품질 감사 샤드 — 04-q-inactive (SAA 드래프트 18파일) — 2026-07

## 요약

SAA-C03 비활성 드래프트 문항 파일 18개(활성 6개 제외) 전수를 PowerShell JSON 파싱으로 기계 검증했다.
18파일 전부 파싱 정상, 각 15문항 균일로 총 270문항. 전 문항 `verified:false` — verified:true 혼입(노출 게이트 위반) 0건.
필수 필드(id·stem·options·correct·explanation·wrongExplanations·verified) 누락 0건, id 중복(파일 내·드래프트 파일 간·활성 6파일 90문항 대비) 0건, correct 범위 위반 0건, 옵션 4개 아닌 문항 0건, 빈 문자열 필드(stem·explanation·옵션·오답해설) 0건.
wrongExplanations 키는 270문항 전부 정답 제외 오답 인덱스 3개와 정확히 일치. content_index.dart의 questionCount=0(18개)·파일 존재 구조도 정합.
**발견 항목 0건 — 구조 관점에서 flip 후보 풀은 깨끗한 상태다.** (내용 정답성은 본 샤드 범위 밖 — flip 시점 사람 검수 몫)

## 검증 방법

- 검증 스크립트(세션 스크래치패드, 레포 외부)로 18파일 × 15문항을 기계 점검: JSON 파싱 → 필수 필드 존재 → verified 불리언/값 → id 유일성(파일 내 + 파일 간 + 활성 90문항 충돌) → id 패턴(`<taskId>-q<n>`) → 옵션 4개·옵션 텍스트 중복·빈 옵션 → correct 타입·범위(0..3) → wrongExplanations 키 = 오답 인덱스 집합 → 빈 문자열 → 문항·톱레벨 examGuideTaskId 일치.
- **검증기 자체를 음성 테스트로 확인**: 결함 13종(verified:true, 필드 누락, id 중복, correct 범위/타입 위반, 옵션 3개, 옵션 중복, 빈 stem, 빈 오답해설, wrongExplanations 키 불일치, id 패턴 위반, taskId 불일치 등)을 심은 합성 파일에서 전 종 검출됨 → 실데이터 0건 결과는 검증기 미작동이 아님.
- content_index 정합: `flutter_app/lib/data/content_index.dart` L244–457 직접 확인 — 활성 6개만 questionCount=15, 나머지 18개 전부 questionCount=0.

## 인벤토리 (파일별 문항 수·verified 상태)

| 파일 | 문항 수 | verified:false | verified:true | 난이도(foundational/applied) | content_index questionCount | 크기(bytes) |
|---|---|---|---|---|---|---|
| saa-t1-1.questions.json | 15 | 15 | 0 | 6/9 | 0 | 26,492 |
| saa-t1-2.questions.json | 15 | 15 | 0 | 7/8 | 0 | 31,188 |
| saa-t1-3.questions.json | 15 | 15 | 0 | 7/8 | 0 | 31,175 |
| saa-t1-4.questions.json | 15 | 15 | 0 | 7/8 | 0 | 29,981 |
| saa-t1-5.questions.json | 15 | 15 | 0 | 8/7 | 0 | 31,340 |
| saa-t2-2.questions.json | 15 | 15 | 0 | 5/10 | 0 | 30,892 |
| saa-t2-3.questions.json | 15 | 15 | 0 | 6/9 | 0 | 33,605 |
| saa-t2-4.questions.json | 15 | 15 | 0 | 5/10 | 0 | 29,458 |
| saa-t2-5.questions.json | 15 | 15 | 0 | 7/8 | 0 | 32,276 |
| saa-t3-1.questions.json | 15 | 15 | 0 | 7/8 | 0 | 31,531 |
| saa-t3-3.questions.json | 15 | 15 | 0 | 8/7 | 0 | 28,409 |
| saa-t3-6.questions.json | 15 | 15 | 0 | 6/9 | 0 | 33,686 |
| saa-t3-7.questions.json | 15 | 15 | 0 | 6/9 | 0 | 32,646 |
| saa-t3-8.questions.json | 15 | 15 | 0 | 7/8 | 0 | 29,329 |
| saa-t3-9.questions.json | 15 | 15 | 0 | 8/7 | 0 | 33,498 |
| saa-t4-1.questions.json | 15 | 15 | 0 | 6/9 | 0 | 31,111 |
| saa-t4-4.questions.json | 15 | 15 | 0 | 7/8 | 0 | 27,210 |
| saa-t4-5.questions.json | 15 | 15 | 0 | 9/6 | 0 | 31,814 |
| **합계 (18파일)** | **270** | **270** | **0** | **122/148** | — | — |

flip 계획 참고 (비결함 인벤토리 노트):
- 전 파일 15문항 균일 — flip 시 content_index questionCount를 15로 올리는 기존 패턴(활성 6개와 동일)이 그대로 적용 가능.
- 난이도 태그는 드래프트·활성 공통 2종(foundational/applied)만 사용 — 드래프트만의 이질 태그 없음. 활성 6파일 분포(8/7·7/8·7/8·6/9·9/6·9/6)와 유사한 균형.
- 도메인별 드래프트 분포: 도메인1(보안) 5파일/75문항 — **현재 활성 0개인 유일한 도메인**, 도메인2 4파일/60(활성 1), 도메인3 6파일/90(활성 3), 도메인4 3파일/45(활성 2). 도메인 균형 관점의 flip 우선순위 판단에 참고.
- id 체계가 `<taskId>-q1~q15`로 일관 — taskId 접두 덕에 전역 유일성이 구조적으로 보장되며, 실측으로도 드래프트 270 + 활성 90 = 360개 id 전량 무충돌.

## 발견 항목

**발견 없음.** (H 0건 / M 0건 / L 0건)

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| — | — | 발견 없음 — 18파일 270문항 전부 구조 점검 통과 (verified:true 혼입 0·스키마 깨짐 0·id 중복 0·correct 범위 위반 0·옵션 수 위반 0) | — | 높 | 조치 불요. flip 시점에 내용 정답성 사람 검수만 수행 | — | N |
