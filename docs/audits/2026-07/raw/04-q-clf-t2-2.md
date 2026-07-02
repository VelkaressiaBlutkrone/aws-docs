# ④ 문항 품질 감사 샤드 — 04-q-clf-t2-2 — 2026-07

## 요약

- **문항 수 18 / 전 점검(7항목) 통과 17 / 발견 1건(L)** — 대상: `flutter_app/assets/content/clf/t2-2.questions.json`, 대조 문서: `flutter_app/assets/content/clf/t2-2.md`.
- 스키마 위생 전부 통과: id 18개 유일(q1~q18), correct 전부 0..3 범위, verified 18/18 true, 옵션 4개/문항, wrongExplanations 키는 전 문항에서 오답 인덱스 3개와 정확히 일치(누락·정답키 오염 없음), 해설-정답 인덱스 어긋남 0건(q10 correct=2 포함 전수 대조).
- section 앵커 6종(detection-trio·securityhub-shield·artifact·audit-trio·encryption·certificates-hsm) 모두 t2-2.md `{#id}`에 실존. 단골 함정 페어(Artifact vs Audit Manager, GuardDuty/Inspector/Macie, CloudTrail vs Config, Shield Standard vs Advanced, KMS vs CloudHSM, CloudFront ACM us-east-1)의 정답 유일성 전수 확인 — 모호 문항 없음.
- AWS 사실 오류 0건. 병렬 문서 감사 지적(DOC-CLF-101, Audit Manager 신규중단 연도 2024 오기)은 **문항·해설에는 해당 주장 자체가 없음**(q6·q10 어디에도 중단 연도 언급 없음) — 문항 측 전파 없음 확인.
- 참고(발견 아님): correct 인덱스가 18문항 중 17문항에서 0에 몰려 있으나, 렌더 시 옵션 셔플이 3개 노출 경로 전부에 적용됨을 코드로 확인(quiz_page.dart:40-41, review_page.dart:81, mock_exam.dart:123 `randomOptionOrders`/`applyOptionOrders`) — 사용자 노출 편향 없음. 데이터 차원의 편중은 유지보수 관점 참고만.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t2-2-01 | t2-2.questions.json:clf-t2-2-q12 | 스템이 "리소스의 구성 변경 이력을 평가하는 **Config가 아니라**, 이 목적에 맞는 서비스는?"이라고 오답 후보를 명시적으로 배제하는데, 배제된 AWS Config가 그대로 보기 1번에 존재 — 죽은 오답지(dead distractor)로 실질 3지선다가 됨. 같은 사실을 묻는 q7(식별형)·q13(적용형)이 이미 있어 변별력 손실이 아깝다. 정답·해설·wrongExplanations 자체는 모두 정합(오류 아님, 문항 설계 이슈) | L | 높 | 스템에서 "Config가 아니라" 절을 제거해 순수 시나리오형으로 바꾸거나, 배제 문구를 유지하려면 보기 1번을 Config 외 다른 서비스(예: AWS Audit Manager)로 교체 — 어느 쪽이든 출제 의도(대비 학습 vs 변별) 결정 필요 | B | N |
