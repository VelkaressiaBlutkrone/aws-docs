# ④ 문항 품질 감사 샤드 — 04-q-clf-t3-6 — 2026-07

## 요약

- **15문항 × 7항목 전수 점검** — 13문항 전 항목 통과, **발견 2건(모두 L, 자구·문항설계 수준)**, H/M 0건. 정답 유일성 15/15 · 해설-정답 일치 15/15 · wrongExplanations 키 정합(정답 제외 3키 전부 존재·실제 반박) 15/15 · section 앵커 실존 15/15(t3-6.md 앵커 8개 대조: storage-types/s3/s3-classes/s3-lifecycle/ebs/efs/hybrid-backup 전부 실존) · skill/difficulty 채움·정합 15/15 · 스키마(id 유일, correct 0~3, 옵션 4개, verified true ×15) 15/15.
- **DOC-CLF-202(EBS "종료해도 데이터 유지") 전파 점검**: q8 해설은 "(루트 볼륨의 종료 시 삭제 설정 제외)" 단서를 포함해 **미전파** — 오히려 학습문서(t3-6.md L140)보다 정확. 다만 q2 해설에 단서 없는 인접 표현 1건(아래 01, L).
- **DOC-CLF-203(11-9s 내구성 "1만 년" 기간 누락) 전파 점검**: 문항·해설 어디에도 "1,000만 개 중 1개" 손실확률 주장 자체가 없어 **미전파**(q1·q11은 "11 nines로 설계"까지만 서술).
- 정답 위치 분포가 인덱스 0에 11/15로 쏠리나, 런타임에 보기 순서를 셔플(`randomOptionOrders` — quiz_page.dart:40·review_page.dart:81·mock_exam.dart:123)하므로 노출 편향 없음 — 발견 제외.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t3-6-01 | t3-6.questions.json:clf-t3-6-q2 | 해설 "데이터는 인스턴스와 독립적으로 유지되며"가 스템의 OS(=루트 볼륨) 시나리오에서 루트 볼륨 기본 DeleteOnTermination(종료 시 삭제) 단서 없이 서술 — DOC-CLF-202의 약화된 인접 표현. 단, "인스턴스와 독립적으로 유지"는 AWS 공식 문구("persist independently from the running life of an instance")와 동일 계열이고 "종료해도 유지"를 직접 주장하지 않아 사실 오류는 아님. 같은 파일 q8 해설은 단서를 병기하고 있어 문항 간 일관성도 어긋남 | L | 중 | q8 방식대로 해설에 "(루트 볼륨은 기본 설정상 종료 시 삭제)" 단서 병기 | A | N |
| Q-CLF-t3-6-02 | t3-6.questions.json:clf-t3-6-q10 | 스템이 "Amazon EFS는 Linux 워크로드용이라 Windows 환경에는 적합하지 않다"고 명시해 보기 0(Amazon EFS)을 스스로 소거 — 오답 보기 1개가 변별력을 상실(사실상 3지선다). 정답(3, FSx for Windows File Server)·해설·사실관계는 모두 정확해 정오에는 영향 없음 | L | 높 | 스템에서 해당 문장을 삭제하거나, 보기 0을 다른 오답(예: Amazon FSx for Lustre)으로 교체 — verified 문항 재작성이므로 사람 결정 필요 | B | N |
