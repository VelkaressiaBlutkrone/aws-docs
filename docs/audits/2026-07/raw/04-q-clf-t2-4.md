# ④ 문항 품질 감사 샤드 — 04-q-clf-t2-4 — 2026-07

## 요약

- 대상 15문항(clf-t2-4-q1~q15) 전수 점검. 통과 집계: 정답 유일성 15/15 · 해설-정답 인덱스 일치 15/15 · wrongExplanations 키 정합(비정답 3키 전부 존재, correct=1·2·3 문항 포함) 15/15 · section 앵커 실존(지정 11문항 모두 t2-4.md `{#id}`에 실존, 끊김 0) · skill/difficulty 채움·정합 15/15 · 스키마(id 유일, correct 0..3 범위, verified true 15개, 옵션 4개) 15/15.
- 발견 3건: H 0 · M 1(q12 오답해설이 틀린 절반을 반박하지 않음) · L 2(q12 '기본 보안 그룹' 자구 충돌, q11 q3와 사실상 중복 + 스템이 Shield 보기를 선배제). 정답 오류·인덱스 어긋남·앵커 끊김은 없음. 13/15 문항은 전 점검 항목 무결 통과.
- AWS 사실 대조: 정답·해설의 사실 서술(SG stateful/allow-only·NACL stateless/번호순 평가·WAF L7·GuardDuty 로그 3종·Inspector EC2/ECR/Lambda CVE·Macie S3 PII·Secrets Manager 교체·Config 구성 이력·Knowledge Center how-to)은 공식 문서 서술과 부합. 사실의심 1건은 q12 오답해설 자구가 VPC '기본 보안 그룹(default security group)' 실제 동작(동일 SG 소스 인바운드 허용 규칙 보유)과 충돌하는 조건부 건.
- 참고(발견 아님): q7~q10은 section 필드 자체가 없음 — 해당 주제(GuardDuty·Inspector·Macie·KMS/Secrets Manager)가 t2-4.md에 다뤄지지 않아 부여할 앵커가 없고, 스펙상 '빈 값 통과'로 처리(오답 리뷰 딥링크만 미제공). Trusted Advisor 무료/유료 범위 서술은 어떤 문항·해설에도 등장하지 않아 해당 위험 영역 비해당(q4·q14는 기능 구분만 다룸).

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t2-4-01 | t2-4.questions.json:clf-t2-4-q11 | q3와 사실상 중복 — 동일 핵심 사실(SQLi·XSS 방어→WAF), 동일 정답 텍스트(AWS WAF), 동일 1차 오답 축(AWS Shield Standard). 또한 스템이 "DDoS 보호용 Shield가 아니라"라고 명시해 보기 1(Shield Standard)을 문면에서 선배제 → 실질 3지선다로 변별력 저하 | L | 중 | 스템의 Shield 배제 문구를 제거하고 WAF vs Shield 판단이 실제로 필요한 시나리오로 개작하거나, q11을 다른 하위 스킬(예: WAF 적용 가능 리소스 식별)로 차별화 | B | N |
| Q-CLF-t2-4-02 | t2-4.questions.json:clf-t2-4-q12 (wrongExplanations["1"]) | "기본 보안 그룹은 인바운드를 허용하지 않습니다"가 AWS 공식 용어 '기본 보안 그룹(default security group)'과 자구 충돌. 문항 취지는 '새로 만든(커스텀) 보안 그룹'의 기본 상태인데, 이 문장을 용어 그대로 읽으면 VPC 기본 보안 그룹에 대한 틀린 진술이 됨 | L | 중 | "새로 만든 보안 그룹은 기본적으로 인바운드를 허용하지 않습니다 — 필요한 인바운드는 규칙을 추가해야 합니다"로 자구 수정 | A | Y — VPC 기본 보안 그룹은 동일 SG에 연결된 소스로부터의 인바운드를 허용하는 self-reference 규칙을 기본 포함(docs.aws.amazon.com/vpc/latest/userguide/default-security-group.html) |
| Q-CLF-t2-4-03 | t2-4.questions.json:clf-t2-4-q12 (wrongExplanations["2"]) | 보기 2("인바운드·아웃바운드 모두 전부 거부로 시작")에 대한 해설이 "기본 인바운드는 거부 상태입니다(규칙 없음)"뿐 — 보기의 참인 절반(인바운드 거부)만 재확인하고 틀린 절반(아웃바운드도 거부)을 반박하지 않음. 이 보기를 고른 학습자가 왜 틀렸는지 알 수 없는 미반박 해설 | M | 높 | "인바운드는 거부(규칙 없음)가 맞지만, 아웃바운드는 기본 허용 규칙이 있어 '모두 거부'는 틀립니다"로 반박 보강 | A | N |
