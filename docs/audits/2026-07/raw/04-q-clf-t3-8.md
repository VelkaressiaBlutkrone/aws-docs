# ④ 문항 품질 감사 샤드 — 04-q-clf-t3-8 — 2026-07

## 요약

- 대상: `flutter_app/assets/content/clf/t3-8.questions.json` 16문항(예상 16과 일치) · 대조 문서 `t3-8.md`. 전 문항에 7개 점검(정답 유일성·해설-정답 일치·wrongExplanations 정합·앵커 실존·태그·AWS 사실·스키마 위생) 수행.
- 스키마 위생 전원 통과: id 유일(q1~q16)·correct 0~3 범위·verified 전부 true·옵션 4개·wrongExplanations 키가 정답 제외 3개 인덱스와 정확히 일치(16/16). 비어 있지 않은 section 값 6종(messaging·euc·iot·other-services·sqs-types·appstream-mq)은 모두 t3-8.md 앵커에 실존.
- correct=0 편중(13/16)은 소스 JSON 수준 현상일 뿐, 런타임에서 `quiz_page.dart:40-41`·`review_page.dart:81`이 `randomOptionOrders`로 문항별 보기 순서를 셔플함을 코드로 확인 — 사용자 비노출이라 발견 제외.
- DOC-CLF-301(문서의 SNS "저장·재시도 메커니즘 없음" 주장) 전파 여부 전수 점검: q14 해설 1곳에서 "메시지를 보관하지 않으므로"로 부분 전파 확인(재시도 부정 주장은 없음). q13 오답 해설은 "내구성 버퍼가 핵심 역할이 아니다"로 한정 서술되어 통과.
- 결과: 전 점검 통과 12문항 / 발견 4건(M 1·L 3, H 0). 정답 오류·정답 모호(H)는 0건 — 16문항 모두 정답 유일성과 해설-정답 일치 확인.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t3-8-01 | t3-8.questions.json:clf-t3-8-q14 | 해설(explanation)의 "SNS는 발행 즉시 구독자에게 푸시할 뿐 **메시지를 보관하지 않으므로**"가 DOC-CLF-301과 같은 부정확 주장(저장 없음)을 전파. 근거: SNS는 발행 메시지를 다중 서버/AZ에 내구 저장하고 프로토콜별 전송 재시도 정책(SQS·Lambda 엔드포인트 최대 23일)·구독별 DLQ를 제공 — 없는 것은 "소비자가 폴링해 가져가는 큐형 보관"임. 정답 선택(0)·오답 구조에는 영향 없음(오답 보기 1은 "큐에 쌓아 두므로"라 여전히 명백히 오답) | M | 높 | 해설 자구를 "SNS는 소비자가 나중에 폴링해 가져가도록 메시지를 큐에 보관하는 서비스가 아니므로"류로 한정 서술로 정정(문서 DOC-CLF-301 정정과 동일 방향으로 일괄 처리) | A | Y |
| Q-CLF-t3-8-02 | t3-8.questions.json:clf-t3-8-q7 | Step Functions 문항이나 대응 학습문서 t3-8.md에 Step Functions 서술이 전무(grep 결과 CLF 학습문서 전체에서 0회). section도 빈 값(스펙상 통과)이라 오답 시 학습문서로 되돌아갈 연결 고리가 없음. 문항 자체(정답·해설·사실)는 정확 | L | 높 | t3-8.md 앱 통합 절에 Step Functions 한 줄 역할(상태 머신 워크플로 오케스트레이션) 보강 후 section 부여 여부 결정 — CLF-C02 앱 통합 범주(EventBridge·SNS·SQS·Step Functions)라 Task 3.8 매핑 자체는 타당 | B | N |
| Q-CLF-t3-8-03 | t3-8.questions.json:clf-t3-8-q9 | API Gateway 문항이나 t3-8.md에 API Gateway 서술이 전무(CLF 문서 전체에서 t2-4.md WAF 보호 대상 나열 1회뿐). 추가로 CLF-C02 시험 가이드 부록 범주상 API Gateway는 '네트워킹 및 콘텐츠 전송'으로 분류되는 것으로 기억되어 Task 3.5(네트워크 서비스) 소속이 더 자연스러울 수 있음 — 가이드 원문 대조 필요. 문항 자체(정답·해설·사실)는 정확 | L | 중 | 시험 가이드 부록에서 API Gateway 범주 확인 후 (a) t3-5로 문항 이동(questionCount 동기화 필요) 또는 (b) t3-8 잔류 + 문서에 한 줄 보강 중 택일 | B | Y |
| Q-CLF-t3-8-04 | t3-8.questions.json:clf-t3-8-q8 | WorkSpaces Applications(구 AppStream 2.0) 문항의 section이 누락(빈 값 통과)이지만, 정확히 대응하는 앵커 `{#appstream-mq}`가 t3-8.md에 실존(q16은 이미 사용 중) — deep-link 기회 상실 | L | 높 | `"section": "appstream-mq"` 추가(데이터 정정만으로 즉시 가능) | A | N |

### 부기 — 통과 확인 집계(발견 외)

- 정답 유일성 16/16: SNS/SQS/EventBridge/MQ 4자 구분(q1·q2·q3·q16), WorkSpaces vs WorkSpaces Applications(q4·q8), IoT Core(q5), SQS 표준 vs FIFO(q12) 모두 정답 외 보기가 요구사항(푸시 vs 폴링, 전체 데스크톱 vs 앱 스트리밍, 순서·정확히 한 번, 프로토콜 호환 이전)을 충족하지 못함을 확인. q13·q14는 SNS 재시도·DLQ를 감안해도 "자신의 속도로 가져가 처리"(풀 시맨틱)·"내구 버퍼" 요구로 SQS 정답 유일성 유지.
- 해설-정답 일치 16/16(correct 인덱스의 실제 옵션 텍스트와 해설 서술 일치, q7=1·q8=2·q9=3 포함).
- wrongExplanations 16/16: 키 정합(정답 제외 3개)·실제 반박 서술·누락 없음.
- skill·difficulty 16/16 채움·정합(foundational 12·applied 4).
- AWS 사실 대조: Q-CLF-t3-8-01 외 오류 없음 — AppStream 2.0→WorkSpaces Applications 개명, MQ=ActiveMQ Classic·RabbitMQ 관리형 브로커, FIFO=순서 보장+정확히 한 번, SES=비즈니스 앱 범주(Connect·SES) 등 확인.
