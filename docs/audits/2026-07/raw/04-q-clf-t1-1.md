# ④ 문항 품질 감사 샤드 — 04-q-clf-t1-1 — 2026-07

## 요약

- 대상: `flutter_app/assets/content/clf/t1-1.questions.json` 15문항(clf-t1-1-q1~q15) × 점검 7항목 전수 수행. 대조 문서: `flutter_app/assets/content/clf/t1-1.md`.
- **전 점검 통과 집계**: 스키마 위생 15/15(id 유일·correct 0..3 범위·verified 전부 true·옵션 4개), 정답 유일성 15/15, 해설-정답 인덱스 일치 15/15, wrongExplanations 15/15(오답 키 45개 전수 — 누락·오지목 0, 각 해설이 해당 보기를 실제 반박), skill·difficulty 태그 15/15 충전·내용 일치(foundational 9·applied 6), AWS 사실 오류 0건.
- section 앵커: 지정 6문항(q2·q4=core-benefits, q5·q11=global-infra, q6·q8=ha-elasticity) 전부 t1-1.md 실존 앵커({#core-concepts, #core-benefits, #ha-elasticity, #global-infra, #pitfalls} 중). 미지정 9문항은 스펙상 통과.
- **발견 2건(모두 L)** — 정답 오류·해설 오류·앵커 끊김 등 H/M급 0건. 발견 2건은 자구 단순화 1건 + 정보성 기록 1건으로, 시험 대비 정확성에 영향 없음.
- 보조 확인: 원본 correct 인덱스 편중은 렌더 시 보기 셔플(`quiz_page.dart:41`, `review_page.dart:81`, `mock_exam.dart:123`의 randomOptionOrders)로 사용자에게 노출되지 않음을 코드로 실측.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t1-1-01 | t1-1.questions.json:clf-t1-1-q8(stem) · clf-t1-1-q15(explanation) | AZ를 "한 데이터센터(가용 영역)"(q8 stem), "물리적으로 별도의 건물"(q15 해설)로 단수 등가 표기. AWS 공식 정의는 "AZ = 하나 이상의 개별 데이터센터(one or more discrete data centers)"라 단일 건물/데이터센터 등가는 단순화(학습문서 t1-1.md §4 원리 문단의 표현을 그대로 계승한 것). CLF 수준의 정답 판별에는 영향 없고 물리적 분리·독립 전력이라는 핵심 사실은 정확함 | L | 중 | 원하면 "가용 영역(하나 이상의 데이터센터)" 식으로 자구 정밀화 — 선택적 손질, 미수정도 무방 | A | N |
| Q-CLF-t1-1-02 | t1-1.questions.json:전체(correct 분포) | 원본 데이터 차원의 정답 인덱스 편중: correct=0이 9/15(60%), 특히 q1~q6 여섯 문항 연속 0. 단, 앱이 렌더 시 randomOptionOrders로 보기 순서를 셔플함(quiz_page.dart:41 · review_page.dart:81 · mock_exam.dart:123 실측)이라 사용자 노출 편향은 없음 — 정보성 기록 | L | 높 | 무조치 가능(셔플 계약 유지 전제). 원본 재배치 여부는 사람 판단 사항 | B | N |
