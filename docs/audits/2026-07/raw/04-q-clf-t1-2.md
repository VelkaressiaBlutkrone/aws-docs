# ④ 문항 품질 감사 샤드 — 04-q-clf-t1-2 — 2026-07

## 요약

- 대상: `D:\workspace\awc-docs\flutter_app\assets\content\clf\t1-2.questions.json` — 15문항(clf-t1-2-q1~q15, AWS Well-Architected Framework), 예상 문항 수(15)와 일치. 대조 문서: `t1-2.md`.
- 7개 점검(①정답 유일성 ②해설-정답 일치 ③wrongExplanations 논리 ④section 앵커 실존 ⑤skill·difficulty 태그 ⑥AWS 사실 오류 ⑦스키마 위생) **전 문항 통과 15/15, 발견 0건**.
- 스키마 기계 검증(PowerShell ConvertFrom-Json): id 15개 유일·correct 전부 0~3 범위 내·옵션 각 4개(문항 내 중복 옵션 0)·verified 전부 true·wrongExplanations 키 집합이 오답 인덱스 보집합과 15문항 전부 정확히 일치(45키/45), 각 키의 서술이 해당 옵션 텍스트를 실제 반박함을 수동 대조.
- section 앵커: `well-architected`(q1·q6·q10·q12·q13)·`six-pillars`(나머지 10문항) 모두 t1-2.md 실존 앵커(`{#well-architected}` L64, `{#six-pillars}` L77)와 일치. AWS 사실 대조: 6대 기둥 명칭·지속 가능성 2021년 추가·"감사 아님(건설적 점검)"·WA Tool 무료·GuardDuty/CloudFormation/Inspector/Trusted Advisor 역할 서술 모두 공식 문서 정의와 부합, 사실의심 0건.
- 참고(비발견): 원본 데이터의 correct=0 편중(11/15)은 런타임 선택지 셔플로 노출이 중화됨을 코드로 확인(quiz_page.dart L40-41·review_page.dart L81·mock_exam.dart randomOptionOrders) — 데이터 결함 아님. difficulty 보정(q3·q5 foundational vs q7·q8 applied)은 "단일 정의 재진술" vs "복수 실천 신호 종합"으로 구분이 성립해 정합으로 판단.

## 발견 항목

발견 없음(전 문항 통과)
