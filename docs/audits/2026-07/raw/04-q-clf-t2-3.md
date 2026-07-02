# ④ 문항 품질 감사 샤드 — 04-q-clf-t2-3 — 2026-07

## 요약

- 대상: `flutter_app/assets/content/clf/t2-3.questions.json` 18문항(예상 18 일치) · 대조 문서 `t2-3.md`(접근 관리 — IAM).
- 스키마 위생 **18/18 전 통과**(프로그램 검증): id 유일 18/18, 옵션 4개, correct 0~3 범위, verified 전부 true, wrongExplanations 키 = 비정답 3개 정확 일치, skill·difficulty 전 문항 채움.
- section 앵커 **18/18 실존**(문서 앵커 9종 대비 매핑 전부 유효), 정답 유일성·해설-정답 일치 **18/18 통과**.
- 발견 **2건**: q1 해설이 DOC-CLF-102와 동일한 "AWS Support 플랜 변경/취소 = 루트 전용" 낡은 주장을 전파(M, 단 **정답 근거는 아님** — 정답 '계정 해지'는 여전히 유효), q13 오답 해설의 "일회용" STS 자구 부정확(L).
- 특별 주의 점검 결과: Support 플랜 루트 전용 주장을 **정답 근거로 삼는 문항은 없음** — 유일한 정답 접점인 q1의 correct는 "AWS 계정을 해지(close)한다"로 현행 공식 루트 전용 목록에 실존(단독 계정 기준 hedge도 해설에 있음).

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t2-3-01 | t2-3.questions.json:clf-t2-3-q1 | explanation의 루트 전용 작업 열거에 "AWS Support 플랜 변경/취소" 포함 — DOC-CLF-102와 동일한 낡은 주장(2022년부터 IAM 주체도 Support Plans 콘솔 권한으로 변경 가능, 현행 공식 root-only 목록(id_root-user.html)에 없음). **정답 근거는 아님**: correct(인덱스 2 "AWS 계정을 해지(close)한다")는 현행 루트 전용 작업으로 유효하고 해설에 "(단독 계정 기준)" hedge도 있음. 오염은 해설 부연 열거에 한정 | M | 높 | explanation에서 "AWS Support 플랜 변경/취소" 항목 삭제(또는 "과거 루트 전용이었으나 현재는 IAM 권한으로도 가능" 부연으로 교체). t2-3.md DOC-CLF-102 정정과 동시 반영해 문서-문항 일관성 유지 | A | Y |
| Q-CLF-t2-3-02 | t2-3.questions.json:clf-t2-3-q13 | wrongExplanations["2"]의 "일회용 단기 자격증명은 IAM 역할(STS 임시 자격증명)의 특성이며" — STS 임시 자격증명은 세션 유효 기간(기본 약 1시간) 동안 여러 요청에 **재사용 가능**한 단기 자격증명이지 '매 요청 일회용'이 아님. 오답(옵션 2) 반박 자체는 성립하나, 역할 자격증명을 일회용으로 오인시킬 수 있는 자구 | L | 중 | "일회용 단기 자격증명은 IAM 역할의 특성" → "짧은 유효 기간 후 자동 만료되는 세션 자격증명은 IAM 역할(STS)의 특성" 류로 자구 교체 | A | Y |

### 참고(범위 밖 메모)

- `t2-3.md` L284 자가 점검 안내문이 "정식 검증 문항 **7개**는 t2-3.questions.json 참조"라고 표기하나 실제 파일은 verified 18문항 — 문서 측 낡은 카운트(문서 감사 샤드 03-docs-clf 범위, 교차 참조용으로만 기재).

### 점검 통과 집계 (발견 외 전 항목)

- 정답 유일성 18/18: 루트 전용(q1)·MFA(q4, q10)·역할 vs 사용자(q8, q15)·Cognito/Identity Center/Directory Service 경계(q16~q18) 전부 정답 단일 성립, 복수 정답 소지 없음. q17(AD Connector)은 스템의 "동기화·별도 AD 운영 배제" 조건이 Managed Microsoft AD를 명시적으로 배제해 유일성 확보.
- 해설-정답 일치 18/18: explanation 서술 대상 = correct 인덱스의 실제 옵션 텍스트 전 문항 일치.
- wrongExplanations 18/18: 키 정합(비정답 3개) 및 실제 반박 성립(q13 자구 건은 위 표), 누락 없음.
- 사실 대조(발견 2건 외 이상 없음): 계정 해지=루트 전용(단독 계정), 암호 정책=IAM 사용자 전용·루트/액세스 키 미적용(q9), SMS MFA 지원 종료(q10), Identity Center 2022-07-26 리네이밍(q5), IAM 글로벌(q12), Cognito User Pool/Identity Pool 분담(q16), AD Connector 프록시(q17) 모두 공식 문서 서술과 부합.
