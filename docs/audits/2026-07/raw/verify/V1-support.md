# 2단 반박 검증 — V1 Support 플랜 — 2026-07

검증자: 독립 검증(반박 우선). 근거는 AWS 공식 페이지 실측(docs.aws.amazon.com·aws.amazon.com). 각 항목 1회 판정.

## 조회 출처 (URL 목록)

- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html — "Tasks that require root user credentials" 현행 전체 목록 (DOC-CLF-102)
- https://aws.amazon.com/premiumsupport/plans/ — 현행 Support 플랜 비교(심각도별 응답 목표·현행 플랜명) (DOC-CLF-309·310·311)
- https://docs.aws.amazon.com/awssupport/latest/user/support-plans-eos.html — "Developer, Business, and Enterprise On-Ramp end of support" (DOC-CLF-310·311)
- https://aws.amazon.com/premiumsupport/plans/enterprise-onramp/ — Enterprise On-Ramp 전용 플랜 페이지(실재 확인) (DOC-CLF-311)
- https://aws.amazon.com/blogs/aws/new-and-enhanced-aws-support-plans-add-ai-capabilities-to-expert-guidance/ — Business Support+ 신설·2027-01-01 재편 공지 (DOC-CLF-310)

## 판정

| ID | 판정(REFUTED/CONFIRMED/UNCERTAIN) | 근거(3줄 이내) |
|---|---|---|
| DOC-CLF-102 | CONFIRMED | 현행 IAM `id_root-user.html`의 "Tasks that require root user credentials" 전체 목록(Account Management·Billing·GovCloud·EC2·KMS·MTurk·S3·SQS)에 **Support 플랜 변경·취소 항목이 없다**. Billing 절도 "Activate IAM access to Billing console" + "일부 Billing 작업은 root 한정(별도 문서 참조)"뿐, Support 플랜 변경은 미열거. 문서 t2-3가 이를 "루트 전용 작업"으로 3곳(L127·L241·시험포인트) 단정한 것은 현행 공식 목록과 불일치 → 의심 타당. |
| DOC-CLF-309 | CONFIRMED | 현행 플랜 페이지 실측: 15분 응답 목표는 **"Business/Mission-critical system down"** 심각도에 걸리고, **"Production system down"은 Enterprise도 <1시간**. 문서 t4-3 L70·L134가 Enterprise를 "**프로덕션** 중요 케이스 15분 응답"으로 서술한 것은 심각도 라벨 오류(프로덕션↔비즈니스크리티컬 혼동). 15분 수치 자체는 맞으나 걸리는 케이스 등급이 틀림 → 의심 타당. |
| DOC-CLF-310 | REFUTED | 재편은 **실재**한다: 공식 `support-plans-eos.html`가 **Developer·Business·Enterprise On-Ramp를 2027-01-01 단종**하고 **Business Support+**로 이관함을 명시(플랜 페이지에 Business Support+·Enterprise·Unified Operations 표기, Blog 공지 일치). 문서 L77의 재편 서술은 공식과 부합 → 문서가 옳음(오탐). 단 사소 정합: 문서는 "On-Ramp 단종"을 Developer·Business와 함께 정확히 포함함. |
| DOC-CLF-311 | REFUTED | Enterprise On-Ramp는 실재 플랜(전용 페이지 `plans/enterprise-onramp/` 존재, 2021 출시). 문서 t4-3는 학습 체크리스트·표에서 전통 4분류(Basic·Developer·Business·Enterprise)를 가르치고 On-Ramp가 2027-01-01 단종 대상임을 정직성 메모로 명시 — CLF-C02 시험 대비상 On-Ramp를 주 교습표에서 생략한 것은 사실 오류가 아니며(단종 예정 플랜) 시험 가이드의 전통 티어 프레이밍과도 정합 → 오탐. |

## 부기(교차 확인)

- DOC-CLF-309의 "15분" 수치는 재편 후 Enterprise Support에도 유지됨(eos 공지: Enterprise Support = 지정 TAM·15분 응답). 따라서 309의 정정 포인트는 **수치가 아니라 심각도 라벨**("프로덕션" → "비즈니스 크리티컬/미션 크리티컬 시스템 다운")임이 확정.
- DOC-CLF-310/311이 REFUTED이므로, 이에 연동된 문항 감사 발견 Q-CLF-t4-3-03·04(재편 문구 사실성)는 "재편 실재 확인됨 → 유지" 방향으로 귀결. Q-CLF-t4-3-01·02(프로덕션+15분)는 DOC-CLF-309 CONFIRMED에 따라 정정 대상 유지.
