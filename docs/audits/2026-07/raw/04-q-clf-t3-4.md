# ④ 문항 품질 감사 샤드 — 04-q-clf-t3-4 — 2026-07

## 요약
- 대상 15문항(clf-t3-4-q1~q15) 전수에 7개 점검(정답 유일성·해설-정답 일치·wrongExplanations 논리·section 앵커·skill/difficulty 태그·AWS 사실·스키마 위생)을 수행 — **15/15 전 점검 통과, 정답 오류(H)·해설 오류(M) 0건, 발견 2건(모두 L·품질 관찰)**.
- 스키마 위생: id 유일 15/15 · correct 전부 0~3 범위 · verified 전부 true · 옵션 4개 균일 · wrongExplanations 키가 각 문항의 비정답 인덱스 3개와 정확히 일치(누락·정답키 침범 없음). 사용된 section 값 5종(relational·dynamodb·elasticache·dms·managed-vs-ec2) 모두 t3-4.md 실존 앵커(72·92·113·129·143행)와 일치.
- **DOC-CLF-201 전파 없음**: 문항 파일에 비용·무료·과금 서술 0건(grep 실측). q3·q13 해설은 자동 확장만 언급하고 "트래픽 없으면 비용 없음" 주장을 옮기지 않았다.
- 정답 인덱스 분포는 0×12·1·2·3 각 1로 편중돼 있으나, 퀴즈·복습·모의고사 모두 렌더 시 `randomOptionOrders`로 보기 순서를 셔플(quiz_page.dart:40-41, review_page.dart:81, mock_exam.dart:123)하므로 실노출 영향 없음 — 비발견 처리.
- 사실 대조: 전 문항 해설이 인용된 AWS 공식 문서 서술(RDS 관리 범위, Aurora 5배/3배, DynamoDB 한 자릿수 ms·JOIN 미지원, ElastiCache Valkey/Memcached/Redis OSS, DMS+SCT, Redshift DW, Neptune 3개 쿼리언어, DocumentDB MongoDB 호환, MemoryDB Multi-AZ 트랜잭션 로그, Multi-AZ 동기 standby, Read Replica 읽기 분산)과 부합 — 사실의심 0건.

## 발견 항목
| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t3-4-01 | t3-4.questions.json:clf-t3-4-q7·q8·q9·q10 | 4문항이 출제한 서비스(Redshift·Neptune·DocumentDB·MemoryDB)가 대응 학습문서 t3-4.md에 전혀 등장하지 않음 — CLF 콘텐츠 폴더 전체에서도 이 questions.json에만 존재(grep 실측). section이 비어 있어 앵커 규칙(빈 값 통과)은 충족하나, 오답 복습 시 개념 딥링크·문서 근거가 없어 학습 루프가 끊긴다(15문항 중 4문항, 27%) | L | 높 | t3-4.md에 "그 밖의 데이터베이스(DW·그래프·문서·내구 인메모리)" 절 + `{#앵커}` 신설 후 4문항 section 연결, 또는 현행 무링크 유지를 사람이 결정 | B | N |
| Q-CLF-t3-4-02 | t3-4.questions.json:clf-t3-4-q14 | 정답 보기(인덱스 0)가 오답 3개 대비 현저히 긴 상세 서술(근거 2문장 포함)이라 "가장 긴 보기=정답" 시험요령 단서를 제공. q12도 정답 보기에만 괄호 부연("대기 복제본을 다른 AZ에 두고 자동 장애 조치")이 붙는 경미한 동일 패턴 | L | 중 | q14 정답 보기를 1문장으로 압축(상세 근거는 explanation으로 이전)하거나 오답 보기에도 근거를 병기해 길이 균형; q12는 괄호 부연 축약 검토. verified 문항 자구 변경이므로 사람 검수 후 반영 | B | N |
