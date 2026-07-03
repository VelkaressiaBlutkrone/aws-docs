# ④ 문항 품질 감사 샤드 — 04-q-clf-t3-7 — 2026-07

## 요약

- 대상: `flutter_app/assets/content/clf/t3-7.questions.json` 17문항(q1~q15·q17·q19, 전부 verified:true) — id q16·q18 공백은 2026-06-21 문항검토 리포트(`docs/superpowers/plans/2026-06-21-clf-c02-supplement-qreview-report.md`)에서 q8·q10 중복으로 **의도적 보류**된 결번(정상).
- 7개 점검(정답 유일성·해설-정답 일치·wrongExplanations·section 앵커·skill/difficulty·AWS 사실·스키마 위생) 전 문항 수행: **정답 유일성 17/17, 해설-정답 일치 17/17, wrongExplanations 키·반박 17/17, 스키마 위생 17/17 통과**(id 유일·correct 0~3·옵션 4개·sources 존재, content_index.dart questionCount=17 일치). AWS 사실 오류 0건(SageMaker AI 개명 주석·Forecast 신규중단·Kinesis put-to-get <1초·Athena 스캔량 과금 모두 공식 문서와 부합).
- section 앵커: 값이 있는 15문항 전부 t3-7.md 실존 앵커(ai-ml·analytics·language-ai·applied-ai-services)와 일치(`section_anchor_link_test.dart`가 상시 가드). q8·q10만 section 누락(테스트상 허용이나 적합 앵커 존재).
- **발견 3건(전부 L, H/M 0건)**: section 누락 2문항 묶음 1건, SageMaker 구명칭 표기 비일관 1건, 원본 correct 인덱스 편중(정보성·런타임 셔플로 실노출 없음) 1건. 문항 단위로는 13/17이 무결점 통과.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t3-7-01 | t3-7.questions.json:clf-t3-7-q8, clf-t3-7-q10 | `section` 필드 누락(두 문항만). q8=Rekognition, q10=Comprehend 모두 t3-7.md `{#applied-ai-services}` 표에 정확히 대응하는 앵커가 실존하는데 미연결 — 오답 시 개념 딥링크(약점 리포트 개념 칩)가 이 두 문항만 생성되지 않음. 테스트는 "미연결 허용(점진)"이라 그린. | L | 높 | 두 문항에 `"section": "applied-ai-services"` 추가(형제 문항 q17·q19와 동일 값) | A | N |
| Q-CLF-t3-7-02 | t3-7.questions.json:clf-t3-7-q2(옵션2·wrongExplanations.2), clf-t3-7-q7(옵션3·wrongExplanations.3) | 오답 보기·해설이 구명칭 "Amazon SageMaker" 단독 표기. 현행 CLF 가이드 task 3.7 표기는 "Amazon SageMaker AI"(GUIDE-003)이고, 2024-12 개명 후 무수식 "SageMaker"는 통합 플랫폼 명칭으로 의미가 이동 — "ML 모델을 구축·훈련·배포하는 서비스"라는 해설 서술과 미세 불일치. 같은 파일 q1("Amazon SageMaker (SageMaker AI)")·q19("Amazon SageMaker AI")와 표기 비일관. 정답 판정에는 영향 없음. | L | 중 | q2·q7의 보기·해설을 "Amazon SageMaker (AI)" 병기로 정렬(q1 방식) | A | N |
| Q-CLF-t3-7-03 | t3-7.questions.json:(파일 전체) | 원본 correct 인덱스 편중: 17문항 중 14문항이 correct=0 (q8=3·q9=1·q10=2 외 전부 0). 단, 노출 3경로(quiz_page.dart:40-41 applyOptionOrders, review_page.dart:81, mock_exam.dart:123 randomOptionOrders) 모두 표시 시 옵션 순서를 셔플하므로 **실사용 노출·게이밍 위험 없음**(정보성). SAA에 도입된 균형 게이트류를 CLF 원본에도 둘지는 정책 판단. | L | 높 | 조치 필수 아님. 선택 시 원본 인덱스 리밸런스(correct·wrongExplanations 키 동반 수정 필요) 또는 현상 유지 결정 | B | N |

## 점검 상세 (집계)

| 점검 | 결과 |
|---|---|
| 1. 정답 유일성 | 17/17 통과 — 서비스 역할이 상호배타적(SageMaker/Lex/Kendra, Athena/Kinesis/Glue/QuickSight, Rekognition/Comprehend/Textract/Polly/Transcribe/Translate/Personalize)이라 복수 정답 소지 없음. q13(파이프라인 순서)·q14(인플레이스 쿼리)도 제약("실시간 수집→정제→시각화", "최소 비용·즉시 시작")이 대안 배제 |
| 2. 해설-정답 일치 | 17/17 통과 — explanation 서술 서비스와 correct 인덱스의 옵션 텍스트 전부 일치 |
| 3. wrongExplanations | 17/17 통과 — 키 = 비정답 인덱스 전체와 정확히 일치(누락·정답키 없음), 각 해설이 해당 보기 텍스트를 실제 반박 |
| 4. section 앵커 | 값 보유 15문항 전부 실존 앵커(ai-ml×3, analytics×7, language-ai×3, applied-ai-services×2). 누락 2건은 Q-CLF-t3-7-01 |
| 5. skill·difficulty | 17/17 통과 — skill 전부 채움·내용 정합(서비스명 명시), difficulty foundational×12/applied×5로 문항 성격과 일치(q13~q19 시나리오형=applied) |
| 6. AWS 사실 | 오류 0건 — SageMaker AI 개명(q1)·Lex ASR+NLU(q2)·Athena 서버리스/스캔량 과금(q4·q14)·Kinesis put-to-get 1초 미만(q5)·Comprehend 감정 4분류(q10)·Textract 필기 지원(q17)·Personalize 세그먼트(q19)·Forecast 신규 고객 중단(q19) 모두 공식 문서 부합. 명칭 표기 비일관만 Q-CLF-t3-7-02 |
| 7. 스키마 위생 | 17/17 통과 — id 유일·correct 0~3·verified true×17·옵션 4개×17·sources 전부 http URL. content_index.dart:197 questionCount=17 일치. 결번 q16/q18은 문서화된 의도적 보류 |
