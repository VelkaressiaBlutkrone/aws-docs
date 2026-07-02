# ④ 문항 품질 감사 샤드 — 04-q-clf-t3-3 — 2026-07

## 요약

- 대상 16문항(clf-t3-3-q1~q16) 전수 점검. **정답 유일성·해설-정답 일치·wrongExplanations 논리·AWS 사실·스키마 위생(①②③⑥⑦)은 16/16 통과** — 정답 오류(H)·해설 오류(M) 0건, 사실 오류 0건(Lambda 15분 한도·Fargate=서버리스 컨테이너·ALB L7/NLB L4/GWLB 어플라이언스·Spot/RI/DH 특성 모두 공식 문서 서술과 부합).
- 스키마: id 16개 유일, correct 전부 0~3 범위, verified 전부 true, 옵션 전부 4개, wrongExplanations 키는 전 문항에서 비정답 3개 인덱스와 정확히 일치(누락·잉여 0).
- section 채운 12문항의 앵커(ec2×2, serverless×2, containers×2, autoscaling, elb×3, spectrum, registry-batch)는 전부 t3-3.md에 실존. 미기재 4문항(q8·q9·q10·q12)은 규칙상 통과이나 q9는 실존 앵커(`{#registry-batch}`)가 있어 연결 누락으로 별도 기재.
- 발견 **6건 — 전부 L(태그·자구·배치)**: 핵심은 q8·q12(EC2 구매 옵션)가 t3-3에 배치된 태스크 오정렬(구매 옵션은 t4-1 「요금 모델 (구매 옵션·데이터 전송·스토리지)」 문서·문항[Spot q3/q14, RI q5/q7/q15, DH q11]이 전담 — t3-3.md에는 관련 서술 전무).
- 병렬 문서 감사 DOC-CLF-204(scale up 용어 오매핑) 관련: 문항 측에는 수평/수직 스케일링 용어 혼동 **없음**(q5 "인스턴스를 추가하고/제거", q1 "크기 조절 가능" 등 모두 정확한 표현). 경계 사례 q6(ELB vs Global Accelerator)·q12(Dedicated Host 예약 존재)는 wrongExplanations가 뉘앙스를 적절히 처리해 정답 유일성 통과로 판정.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t3-3-01 | t3-3.questions.json:clf-t3-3-q8 | EC2 구매 옵션(Spot) 문항이 t3-3(컴퓨팅 서비스)에 배치. t3-3.md에 구매 옵션 서술이 전혀 없어 학습문서로 복습 불가(section도 빈 값일 수밖에 없음). 구매 옵션은 t4-1 문서·문항(구매 옵션 Spot q3/q14)이 전담 — 통합 모의고사에서 유사 Spot 문항 중복 출제 소지 | L | 높 | t4-1 이관 또는 t3-3 존치 여부 사람 결정(이관 시 questionCount·하드코딩 테스트 동기화 필요). 존치 시 t3-3.md에 구매 옵션 한 단락+앵커 추가 검토 | B | N |
| Q-CLF-t3-3-02 | t3-3.questions.json:clf-t3-3-q12 | Q-CLF-t3-3-01과 동일 유형: EC2 구매 옵션(RI) 문항의 t3-3 배치. t4-1 문항(RI q7, Convertible RI q15, SP vs RI q5)과 스킬 영역 중복 | L | 높 | Q-CLF-t3-3-01과 일괄 결정 | B | N |
| Q-CLF-t3-3-03 | t3-3.questions.json:clf-t3-3-q8 | explanation 자구: "온디맨드 가격보다 **최대 큰 폭으로** 할인된" — '최대'가 수치 없이 걸린 비문(초안에서 '최대 90%'가 일반화되며 남은 흔적으로 추정) | L | 높 | "온디맨드 대비 최대 90%까지 할인된"(공식 문서 표현) 또는 '최대' 삭제 | A | N |
| Q-CLF-t3-3-04 | t3-3.questions.json:clf-t3-3-q9 | section 미기재이나 t3-3.md에 AWS Batch를 직접 다루는 `{#registry-batch}` 앵커가 실존 — 딥링크(약점 리포트 개념 칩) 연결 기회 누락. 규칙상(빈 값 통과) 위반은 아님 | L | 높 | `"section": "registry-batch"` 추가 | A | N |
| Q-CLF-t3-3-05 | t3-3.questions.json:clf-t3-3-q10 | section 미기재. Lightsail은 t3-3.md에서 `{#ec2}` 섹션 말미 참고 한 줄로만 등장해 앵커 매칭이 약함(연결 시 EC2 제목으로 스크롤되어 오히려 어색할 수 있음) | L | 중 | 빈 값 유지 또는 `"ec2"` 연결 중 사람 결정(문서에 Lightsail 소절을 둘지와 연동) | B | N |
| Q-CLF-t3-3-06 | t3-3.questions.json:clf-t3-3-q15 | 스템은 "가장 적합한 **Elastic Load Balancing 유형**은?"을 묻는데 보기 3(Amazon EC2 Auto Scaling)은 ELB 유형이 아닌 별개 서비스 — 범주 이탈 보기로 사실상 3지선다가 되어 변별력 저하(정답 오류는 아님) | L | 높 | 보기 3을 ELB 유형(예: Classic Load Balancer)으로 교체할지 존치할지 사람 결정 | B | N |
