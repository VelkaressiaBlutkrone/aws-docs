# DEA-C01 도메인 4 완료 — PR #155 (머지 대기)

작성: 2026-10-20 · 세션: dea-c01-4 (워크트리 elegant-borg-836521)

## 상태

- **PR**: https://github.com/VelkaressiaBlutkrone/aws-docs/pull/155
- base `develop` ← head `feat/2026-10-20-dea-content-domain4` (커밋 `815386a`)
- `CI / test` **SUCCESS**, `MERGEABLE` / `CLEAN`
- **머지하지 않았다** — 사용자 몫. 이 레포는 `gh pr merge --auto` 예약이 거부된다(Allow auto-merge 꺼짐).

## 산출물

- 학습문서 5편: `flutter_app/assets/content/dea/dea-t4-1.md` ~ `dea-t4-5.md`
- 문항 75개(Task당 15): `dea-t4-N.questions.json`, **전부 `verified: false`**
- 공식 Skill 29개(7+6+4+5+7) 전부 커버. 정답 분포 19/20/21/15.
- `content_index.dart` domain 4 엔트리 5개(`questionCount: 0` 유지), `dea_questions_test.dart` `deaTaskIds` 누적
- `pubspec.yaml` 무변경 (디렉터리 단위 등록이라 자동 포함 — 2026-10-20 실측 재확인)

## 게이트 실측 (로컬)

```
flutter test     → 1,135 그린  (기준선 1,120 + 신규 15 = 파서 가드 5 + 문항 가드 10)
flutter analyze  → No issues found!
```

## ⚠️ 다음 세션이 알아야 할 것

1. **이 PR이 develop에 머지되기 전까지 `content_index.dart`·`dea_questions_test.dart`를 건드리는 작업을 병렬로 돌리지 말 것.**
   D2·D3에서 both-added 충돌이 난 바로 그 두 지점(파일 끝 엔트리 블록 / `deaTaskIds` 배열)에 D4 엔트리가 들어가 있다.
   GitHub은 각 PR을 **현재 develop 기준으로만** 판정해 양쪽 다 CLEAN으로 표시하므로, 순차 머지 전에 **로컬 시험 머지**로 확인해야 한다(경위 정본: HANDOFF.md §0-2026-10-20).

2. **DEA 콘텐츠 트랙은 이 PR로 Task 17개(D1~D4) 전부 완료**다. 학습문서 17편 · 문항 드래프트 256개(181 + 75).

3. **남은 일(사람 전용)**: 문항 `verified: true` flip은 사람 검수 전용이다. AI가 하지 않는다.
   flip 시 `content_index`의 `questionCount`와 하드코딩 테스트를 함께 동기화해야 한다(메모리 `question-bank-verified-workflow`).

4. **현황 문서 부기 미수행**: HANDOFF.md·기준선(1,120 → 1,135) 갱신은 이 작업 범위 밖이라 손대지 않았다. D2·D3는 별도 docs PR(#152 등)로 처리했으니 같은 방식이 필요하다.

## 본문에 단정하지 않고 상태를 표기한 항목 (노트 `[의심]`·`[상충]` 미수정)

- SageMaker IAM 기반 도메인 개수(계정당 1 vs 계정·리전당 1) — 문서 간 차이 명시
- 솔트(salt) 일반 정의 — AWS 공식 문서에서 확인 안 됨을 명시
- "before transit"(4.3.4 v1.1 개정) — 공식 문서에 표현 없음, 보안 블로그 근거로 클라이언트 측 암호화로 해석
- CloudTrail Lake 2026-05-31 신규 고객 중단 — Skill 4.4.3이 Lake를 요구하는 상충을 함께 표기
- Macie–Lake Formation 연동 — 근거가 참조 아키텍처(블로그)뿐임을 명시
- Redshift datashare 읽기/쓰기 서술 시차, AWS Backup 교차 리전 복사 차단 통제 미확인, KMS 요청 쿼터 수치 불일치, CloudWatch Delivery 클래스 보존 일수 불일치 — 수치 미기재 또는 상태 표기
