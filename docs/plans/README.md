# 계획 문서 (Plans)

2026-06-05 /office-hours → /plan-eng-review → /plan-ceo-review 세션 산출물.

| 문서 | 내용 | 상태 |
|------|------|------|
| [2026-06-05-design-aws-cert-site.md](2026-06-05-design-aws-cert-site.md) | 설계 문서: 문제 정의, 전제, 접근(C+최소 B), 엔지니어링 리뷰 결정 D1~D16 | APPROVED |
| [2026-06-05-eng-review-test-plan.md](2026-06-05-eng-review-test-plan.md) | 테스트 플랜: 대상 라우트, 인터랙션, 엣지케이스, 크리티컬 패스 | 확정 |
| [tasks-eng-review-20260605.jsonl](tasks-eng-review-20260605.jsonl) | 구현 태스크 T1~T8 (기반: 가짜 콘텐츠 폐기, 레지스트리, 테스트 인프라) | 대기 |
| [tasks-ceo-review-20260605.jsonl](tasks-ceo-review-20260605.jsonl) | 구현 태스크 T9~T14 (학습 루프: 오답노트, 약점리포트, 타이머, 플래그, 진행률, 가중출제) | 대기 |
| [../designs/clf-learning-loop.md](../designs/clf-learning-loop.md) | CEO 플랜: 비전, E1~E6 확장 결정, 구현 사양 | PROMOTED |
| [clf-c02-task-mapping.md](clf-c02-task-mapping.md) | CLF-C02 Task/Skill 매핑표 (공식 Exam Guide 전사, 19 Tasks) — T8 데이터 원본 | 검수 대기 |

## 구현 순서
T0(기존 스테이징 작업 커밋) → T1~T8 → T9~T12 → T13 → T14. 상세 사양은 설계 문서의 ENG REVIEW DECISIONS와 CEO 플랜의 E-세트 구현 사양 참조.

## 핵심 게이트
- SAA 콘텐츠 작업은 CLF 합격 후 (코드 공통화 최소 이전은 예외)
- 검증 문항 65개 미만 자격증은 모의고사 시작 비활성
- 과제: 이번 주 CLF-C02 접수 + Task/Skill 매핑표 완성
