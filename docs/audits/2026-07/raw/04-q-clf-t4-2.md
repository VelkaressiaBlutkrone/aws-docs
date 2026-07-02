# ④ 문항 품질 감사 샤드 — 04-q-clf-t4-2 — 2026-07

## 요약

- 대상: `flutter_app/assets/content/clf/t4-2.questions.json` **15문항**(전원 `verified:true`) · 대조 문서 `t4-2.md`(결제·예산·비용 관리 도구).
- 스키마 위생 전수 통과: id 유일 15/15 · correct 전부 0~3 범위 내 · 옵션 4개 15/15 · wrongExplanations 키가 전 문항에서 비정답 인덱스 3개와 정확히 일치(누락·오키 0건) · section 값은 모두 실존 앵커(q10은 필드 자체 부재 — 규칙상 통과, 별도 L 기재).
- 정답 유일성 15/15 · 해설-정답 일치 15/15 · skill/difficulty 채움 15/15. **발견 4건** = M 1건 + L 3건. **전 점검 무결 통과 11/15**.
- 특별 주의(Cost Explorer 예측 기간) 점검 결과: **q2에서 "향후 약 18개월 예측" 주장 검출**(해설 본문 + source title 동시) — DOC-CLF-308(문서 M)의 오류가 verified 문항까지 침투한 교차 패턴 P2 확인. forecast 전용 문항 q12는 기간 미주장으로 무영향.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t4-2-01 | t4-2.questions.json:clf-t4-2-q2 | 해설이 "최근 약 13개월의 과거 데이터를 보고 **향후 약 18개월**의 지출을 예측"이라 서술하고, source title도 "과거 ~13개월·**향후 ~18개월 예측**"으로 반복. 공식 Cost Explorer 문서(ce-what-is)는 예측 기간을 **향후 12개월**로 명시(과거 13개월은 정확). DOC-CLF-308(t4-2.md L72 표)과 동일 오류가 문항 해설·출처 제목까지 침투한 교차 패턴 P2. 정답 자체(Cost Explorer)는 무영향, 해설 사실 오류. | M | 높 | 해설·source title의 18개월→**12개월** 정정(문서 DOC-CLF-308 정정과 원자적으로 함께 반영해 문서-문항 재불일치 방지) | A | Y |
| Q-CLF-t4-2-02 | t4-2.questions.json:clf-t4-2-q10 | `section` 필드가 15문항 중 유일하게 부재(빈 값 통과 규칙상 위반은 아님). 원인: 대조 문서 t4-2.md에 **Billing Conductor 내용이 전혀 없어** 걸 앵커가 없음. Billing Conductor는 CLF-C02 범위 내 서비스로 문항 사실 자체는 정확하나, 오답 시 약점 리포트 개념 칩 딥링크가 이 문항만 작동하지 않고 학습문서로 복습할 수 없는 커버리지 갭. | L | 높 | 문서에 Billing Conductor 단락(예: 커스텀 청구 소절) 보강 후 앵커 연결할지, 문서 범위 밖(문항 단독 커버)으로 유지할지 결정 | B | N |
| Q-CLF-t4-2-03 | t4-2.questions.json:clf-t4-2-q11 | 스템이 "…Cost Anomaly Detection**이 아니라**, 임계값 기반 알림에 가장 적합한 것은?"으로 오답 후보를 명시 배제하는데, 배제된 CAD가 옵션 1에 그대로 존재 — 실질 3지선다로 변별력 저하. 정답 유일성·사실성엔 문제 없음(Budgets 정답 확정). 의도된 대비 교육일 수 있음. | L | 높 | 스템에서 CAD 배제 문구를 제거하고 순수 시나리오("미리 정한 임계값 초과 시 알림")로 다듬을지 결정(대비 교육 의도면 유지 가능) | B | N |
| Q-CLF-t4-2-04 | t4-2.questions.json:clf-t4-2-q12 | skill이 "Cost Explorer 예측(forecast)"인데 `section: cost-tools`. cost-tools 표에도 예측 언급은 있어 앵커 자체는 유효하나, forecast를 전담 서술하는 더 정밀한 앵커 `{#anomaly-forecast}`(q8이 사용)가 존재 — 딥링크가 덜 정밀한 위치로 착지. | L | 중 | 선택적: section을 `anomaly-forecast`로 교체 고려(유지해도 무방) | A | N |

## 점검 상세 (요약 집계)

| 점검 항목 | 결과 |
|---|---|
| 1. 정답 유일성 | 15/15 통과 — Pricing Calculator/Cost Explorer/Budgets/CUR/Billing Conductor/CAD/SCP 역할 경계 전 문항 명확, 복수 정답 소지 없음 |
| 2. 해설-정답 일치 | 15/15 통과 — explanation 서술과 correct 인덱스 옵션 텍스트 전부 일치 |
| 3. wrongExplanations 논리 | 15/15 통과 — 키=비정답 인덱스 3개 정합, 각 오답을 실제 반박, 누락 0 |
| 4. section 앵커 실존 | 14/14 실존(cost-tools·organizations·cost-tracking·anomaly-forecast), q10은 필드 부재로 규칙상 통과(→ Q-CLF-t4-2-02) |
| 5. skill·difficulty | 15/15 채움·내용 정합(foundational 12·applied 3) |
| 6. AWS 사실 오류 | 1건 — q2 예측 기간 18개월(→ Q-CLF-t4-2-01, 사실의심 Y). 그 외 통합결제 볼륨할인·CUR S3 전달·CAD ML 탐지·태그 활성화 절차 등 사실 서술 이상 없음 |
| 7. 스키마 위생 | 15/15 통과 — id 유일·correct 범위·verified true·옵션 4개 |
