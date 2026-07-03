# ④ 문항 품질 감사 샤드 — 04-q-clf-t3-1 — 2026-07

## 요약 (3~5줄)

- 19문항 전수를 7개 항목(정답 유일성·해설-정답 일치·wrongExplanations·section 앵커·skill/difficulty·AWS 사실·스키마 위생)으로 점검. 정답 유일성 19/19, 해설-정답 일치 19/19, wrongExplanations 키 정합 19/19(기계 검증: 비정답 인덱스 3개와 정확히 일치), skill/difficulty 19/19, 스키마 19/19(id 유일·correct 0~3·verified 전부 true·옵션 4개, ConvertFrom-Json 파스 통과). **발견 3건(전부 L, H/M 0건), 전 점검 통과 15/19문항**(발견 걸린 문항: q3·q8·q9·q20).
- DOC-CLF-105 연계 주의점(VPN "빠르고 저렴" 오독) 확인 결과 문항에는 없음: q6은 문항·해설 모두 "빠르고 비용 효율적으로 … 연결을 **구축**"으로 속도를 구축 시간에 한정하고, DX 오답 해설도 "구축에 시간이 더 걸리고 비용이 큽니다"로 서술. q11(DX)도 "일관된 대역폭·안정적 지연"으로 정확히 대비 — VPN/DX·CLI/SDK·CFN/Beanstalk 구분 문항 전부 정답 유일성 유지.
- 저장 데이터상 correct=0 편중(17/19, 나머지 q7=1·q10=2)이 있으나, 세 노출 경로 모두 렌더 시 보기 순서를 셔플함을 코드로 확인(quiz_page.dart:40-41 randomOptionOrders/applyOptionOrders, review_page.dart:81, mock_exam.dart:123 옵션 순서 셔플) → 사용자 노출 편향 없음, 발견에서 제외.
- section 앵커: 18/19가 t3-1.md 실존 앵커({#access-methods}·{#iac-cloudformation}·{#oneoff-vs-repeat}·{#deployment-models}·{#connectivity}·{#deployment-ops-tools})와 일치, q8만 필드 자체가 없음(스펙상 빈 값 통과이나 완결성 결함으로 L 플래그). id 결번 1건(q16 없음, q15→q17)은 19문항 기대치와 일치하고 유일성 위반이 아니라 참고만.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t3-1-01 | t3-1.questions.json:clf-t3-1-q8 | 19문항 중 유일하게 `section` 필드 부재(빈 값 통과 규정이라 앵커 점검 위반은 아님). Elastic Beanstalk는 t3-1.md §6 `{#deployment-ops-tools}`(실존 앵커)에서 다루고, 같은 절의 q17~q20은 전부 이 값을 사용 — 개념 딥링크·약점 리포트의 문서 섹션 연결이 이 문항만 누락됨 | L | 높 | `"section": "deployment-ops-tools"` 추가(데이터 1줄) | A | N |
| Q-CLF-t3-1-02 | t3-1.questions.json:clf-t3-1-q3, clf-t3-1-q9 | SDK·Query API 일반 서술(서명 계산·재시도·오류 처리, HTTPS 호출)의 출처가 "AWS Site-to-Site VPN User Guide"(vpn/latest/s2svpn/VPC_VPN.html)로 표기 — AWS 서비스 가이드 공통 'Accessing' 보일러플레이트에 있는 내용으로 알고 있어 사실 오류 주장은 아니나, SDK/API 문항에 무관해 보이는 VPN 가이드 인용이라 재검수·링크 유지보수 시 혼란 소지 | L | 중 | SDK 공식 문서(예: AWS SDKs and Tools Reference Guide)로 출처 교체 검토 — 대체 URL은 사람이 실페이지 확인 후 결정 | B | N |
| Q-CLF-t3-1-03 | t3-1.questions.json:clf-t3-1-q20 | CodeCommit은 2024-07-25부로 신규 고객 제공 중단(기존 고객은 계속 사용 가능). 문항·해설 서술 자체는 여전히 참이고 CodeCommit이 CLF-C02 시험 가이드 범위 내 서비스라 시험 대비 정답으로 유지하는 것이 맞음 — 다만 "정직함" 브랜드 기준에서 실무 맥락 한 줄 병기 여부는 결정 필요 | L | 높 | 해설 또는 t3-1.md §6에 "신규 고객 제공 중단(2024-07)" 한 줄 병기 여부 사람 결정(문항 정답·구조 변경 불필요) | B | Y (근거: AWS 공지 기준 2024-07-25부터 CodeCommit 신규 고객 액세스가 중단된 것으로 알고 있음 — 웹 미검증) |
