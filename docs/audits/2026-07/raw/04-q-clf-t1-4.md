# ④ 문항 품질 감사 샤드 — 04-q-clf-t1-4 — 2026-07

## 요약

- 대상: `flutter_app/assets/content/clf/t1-4.questions.json` **15문항**(예상 15와 일치) × 7개 점검 축 전수 수행. 대조 문서 `t1-4.md`(클라우드 경제학).
- 전 점검 통과 집계: 스키마 위생 **15/15**(id 유일·옵션 4개·correct 0~3 범위·verified true) · section 앵커 **15/15**(사용된 6개 앵커 capex-opex/rightsizing/licensing/automation/managed-services/autoscaling 모두 t1-4.md에 실존) · 정답 유일성 **15/15** · 해설-정답 일치 **15/15** · wrongExplanations 키 완전성·오답 반박 정합 **15/15**(비정답 3키 전부 존재, 각 키가 실제 해당 옵션 텍스트를 반박).
- **발견 3건(H 0 · M 0 · L 3)**: 출처 제목 과대 기술 1건(q8), skill 태그 용어 불일치 1건(q11), 정답 옵션 길이 단서 관찰 1건(q1·q10·q14 묶음).
- 문항·해설 본문의 AWS 사실 오류 **0건**. 병렬 문서 감사 지적 DOC-CLF-001(ECS·EKS를 관리형 패치 일반화에 묶음)은 문항에 **미전파** — q5·q10·q14는 RDS·DynamoDB만 예시로 사용.
- correct=0 편중(11/15)은 런타임 옵션 셔플로 학습자에게 비노출임을 코드로 확인(`quiz_page.dart` L40-41 `applyOptionOrders`/`randomOptionOrders` · `review_page.dart` L81 · `mock_exam.dart` L123) — 발견에서 제외.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t1-4-01 | t1-4.questions.json:clf-t1-4-q8 | sources[0] 제목이 "AWS Pricing Calculator 사용 설명서 — TCO 추정·온프레미스 대비 비용 비교(직접·간접 비용 포함)"라고 기술하나, 인용된 공식 페이지(what-is-pricing-calculator.html, 2026-07-02 실측 확인)는 TCO·온프레미스 비교를 전혀 언급하지 않음(명시 용도: 솔루션 모델링·단가 탐색·산출 근거 확인·지출 계획·절감 기회 탐색). 문항 본문·해설은 무영향(TCO 개념은 sources[1] what-is-cloud-computing으로 뒷받침). 앱 UI는 문항 sources를 렌더링하지 않아 유지보수 메타데이터에 한정 | L | 높 | 출처 제목을 실제 문서 내용("AWS 사용 비용 견적 도구")으로 정정하거나, TCO·온프렘 비교 근거가 실제로 있는 출처(예: how-aws-pricing-works 백서, what-is-cloud-computing)로 교체 | A | Y |
| Q-CLF-t1-4-02 | t1-4.questions.json:clf-t1-4-q11 | skill 태그 "종량 과금 활용 (미사용 시 **종료**)"의 '종료(terminate)'가 정답 옵션·해설의 '**중지**(stop)'와 EC2 용어 불일치(종료=인스턴스 삭제, 중지=보존+재시작 가능 — 과금 함의도 다름). 약점 리포트 개념 칩(wrongSkills) 등 태그 노출 경로에서 오개념 소지. 문항 본문·해설 자체는 '중지'로 일관·정확("컴퓨팅 비용"으로 한정해 중지 중 EBS 스토리지 과금과도 모순 없음) | L | 높 | skill을 "종량 과금 활용 (미사용 시 중지)"로 자구 정정 | A | N |
| Q-CLF-t1-4-03 | t1-4.questions.json:clf-t1-4-q1·q10·q14 | 정답 옵션이 오답 대비 2~3배 길어(예: q14 정답 약 90자 vs 오답 25~35자) '가장 긴 보기=정답' 시험요령 단서 형성 — 옵션 위치 셔플로도 소거되지 않는 길이 단서. 정답성·사실 결함은 아니며 판별력 저하 관찰 항목 | L | 중 | 오답 보기에 짧은 근거 구절을 덧붙여 길이 균형화할지 사람 판단(정답에 뉘앙스가 필요한 문형 특성상 현행 유지 결정도 가능) | B | N |
