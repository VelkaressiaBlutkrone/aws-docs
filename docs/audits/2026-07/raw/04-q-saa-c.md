# ④ 문항 품질 감사 샤드 — 04-q-saa-c (saa-t4-2·saa-t4-3) — 2026-07

## 요약 (파일별 문항 수·통과 수·발견 수)

- **saa-t4-2.questions.json**: 15문항. 스키마 위생 15/15 통과(id 유일·correct 0~3·옵션 4개·verified true·wrongExplanations 오답 3키 전부 커버). 문항 자체 발견 2건(q1 L, q2 M — 단 q2는 문항이 옳고 **문서가 틀린** 교차 모순) + 출처 불일치 1건(q11·q13·q14 묶음, L). 나머지 10문항 무발견 통과.
- **saa-t4-3.questions.json**: 15문항. 스키마 위생 15/15 통과(동일 기준). 문항 자체 발견 1건(q9 H, 정답 경합) + 교차 모순 1건(q3, 문서측 오류 M) + 출처 불일치 1건(q6·q7·q11·q12·q14 묶음, L). 나머지 8문항 무발견 통과.
- **section 앵커**: 두 파일 모두 `section` 필드 자체가 없음 — SAA 문항 디렉터리 전체에 `"section"` 0건(레포 관례)이므로 "빈 값 통과" 규칙으로 전 문항 통과 처리.
- **총 발견 6건**: H 1 / M 2 / L 3. AWS 사실 검증은 2026-07-02 공식 페이지 라이브 실측(HEAD/GET)으로 수행 — 출처 URL 12종 전부 200 정상.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-SAA-c-01 | saa-t4-3.questions.json:saa-t4-3-q9 | **정답 경합 + 해설-지문 불일치.** 지문은 "평일 낮 초당 수십만 건, 야간·주말 거의 없음"이라는 **예측 가능한** 일일 패턴에 명시적 "비용 최적화" 목표를 제시하는데 정답은 온디맨드(보기 0). 이 규모(주 45시간 상시 고볼륨)에서는 온디맨드 요청 단가가 프로비저닝 대비 수 배라 프로비저닝+Auto Scaling(보기 2)이 총비용에서 유리할 수 있어 전문가 기준 정답이 다툼 가능. 해설은 "트래픽이 **불규칙**하고"라고 지문과 다른 전제를 서술. 보기 2 오답 해설("최솟값 이하로 줄이지 않아 야간에 온디맨드보다 비쌀 수 있다")도 최소 용량을 1 단위 수준으로 낮추면 야간 비용이 미미해 논거가 약함. 초당 수십만 건은 온디맨드 테이블 기본 처리량 한도(조정 필요)와도 긴장. 대응 문서(saa-t4-3.md:275 마무리 퀴즈)는 같은 시나리오에서 "프로비저닝이 더 유리할 수 있다"는 유보를 명시하는데 문항에는 그 유보가 없음 | H | 중 | 지문을 "급증 시점·규모를 예측할 수 없다"로 고치고 "초당 수십만 건" 규모 문구를 완화하거나 삭제 + 해설의 "불규칙" 전제를 지문과 일치시킴. 키 유지 여부 포함 사람 결정 | B | Y |
| Q-SAA-c-02 | saa-t4-2.questions.json:saa-t4-2-q2 ↔ saa-t4-2.md:77·286 | **문서-문항 교차 모순(문항이 옳고 문서가 구버전 수치).** 문항은 Convertible RI 최대 **66%**를 정답 키로 출제 — 현행 공식과 일치(2026-07-02 실측: aws.amazon.com/ec2/pricing/reserved-instances/ "Convertible RIs: up to 66% off On-Demand"). 그러나 학습문서 saa-t4-2.md는 두 곳(§1 표 77행 "최대 54%", 오해 교정 286행 "최대 54%")에서 구버전 수치를 가르침 → 문서로 학습한 사용자가 정답 보기(66%)를 오답으로 판단하게 됨. 문서 자체도 내부 모순(Compute SP 66%는 Convertible RI와 동일 단가 설계인데 표에서 54%로 상이). **문서 감사의 saa-t4-2.md '발견 0(수치 전부 정확)' 판정이 이 항목을 놓침** — 판정 보정 필요 | M | 높 | saa-t4-2.md 77행·286행의 54% → 66% 정정(문항은 무변경). 문서 감사 결과에 본 건 반영 | A | Y |
| Q-SAA-c-03 | saa-t4-3.questions.json:saa-t4-3-q3 ↔ saa-t4-3.md:118 | **문서-문항 교차 모순(문항이 옳고 문서가 존재하지 않는 상품 기재).** 문항 wrongExplanations["1"]은 "No Upfront는 RDS에서 1년 예약으로 제공"이라 서술 — 현행 공식과 일치(2026-07-02 실측: RDS 문서 "This option is only available as a one-year reservation"). 그러나 학습문서 RDS RI 할인율 표(saa-t4-3.md:118)에 RDS에 존재하지 않는 "3년 No Upfront ~45%" 행이 있음 → 문서-문항 직접 모순, 문서측 오류(병렬 문서 감사 DOC-SAA-406/407에 미포함으로 보이는 신규 항목) | M | 높 | saa-t4-3.md 118행(3년 No Upfront 행) 삭제 또는 "RDS는 3년 No Upfront 미제공" 명시(문항은 무변경) | A | Y |
| Q-SAA-c-04 | saa-t4-2.questions.json:saa-t4-2-q1 | **정답 방어력 경미 이슈.** 지문에 '중단 불가' 조건이 없어 Spot(보기 2)도 방어 가능 — AWS Spot 공식 사용 사례에 "test & development workloads"가 명시돼 있음. 온디맨드 공식 사용 사례 문구("단기·불규칙, 개발·테스트")와 지문이 일치해 의도 정답(온디맨드)은 성립하나, wrongExplanations["2"]의 "일반 개발·테스트에는 부적합" 단정은 공식 가이드와 어긋나는 과장 | L | 중 | 지문에 "작업이 중단되면 안 된다" 한 구절 추가 + Spot 오답 해설을 "중단 허용이 명시되지 않은 한 선택하지 않는다" 톤으로 완화 | B | Y |
| Q-SAA-c-05 | saa-t4-2.questions.json:saa-t4-2-q11·q13·q14 | **출처(sources) 주제 불일치(기본값 복붙 추정).** q11(오토스케일링 전략)의 출처가 EC2 예약 인스턴스 문서, q13(Lambda 과금)·q14(Graviton)의 출처가 Savings Plans 개요 문서 — 문항 주제와 무관. 링크 자체는 전부 200 정상이나 '근거 있는 검증 문항' 신뢰를 약화 | L | 높 | q11→EC2 Auto Scaling 스케일링 옵션 문서, q13→Lambda 요금 페이지, q14→AWS Graviton 페이지로 교체 | A | N |
| Q-SAA-c-06 | saa-t4-3.questions.json:saa-t4-3-q6·q7·q11·q12·q14 | **출처(sources) 주제 불일치(동일 패턴 5건).** 5개 문항의 출처가 전부 rds-reserved-instances.html(RDS RI 문서)인데 실제 주제는 스토리지 자동 확장(q6)·ElastiCache 캐싱(q7)·백업 보존 비용(q11)·수동 스냅샷(q12)·Compute Optimizer(q14)로 무관 | L | 높 | 각 주제의 공식 문서로 교체(q6→RDS Storage Autoscaling, q7→ElastiCache 캐싱 전략, q11·q12→RDS 백업/스냅샷 문서, q14→Compute Optimizer 문서) | A | N |

## 특별 주의 교차 점검 결과 (발견 아님 — 전파 여부 확인)

1. **Aurora "최대 256TiB(2025년 상향)" 환각(DOC-SAA-406) → 문항 전파 없음.** saa-t4-3.questions.json 전수 점검 결과 256TiB 언급 0건. 유일한 관련 서술인 saa-t4-3-q6 wrongExplanations["2"]는 "최대 **128TB**"로 공식 상한(128TiB)과 일치. 단 문서(saa-t4-3.md:136)와 문항이 현재 **수치 모순 상태**이므로 DOC-SAA-406 문서 정정 시 자동 해소됨.
2. **RDS RI "속성 하나라도 다르면 미적용" 절대 단정(DOC-SAA-407) → 문항 전파 없음(오히려 문항이 정확).** saa-t4-3-q4는 사이즈 플렉스의 실제 규칙 — 같은 인스턴스 클래스 타입·리전·엔진 내에서 Multi-AZ↔Single-AZ 자유 이동, 리전 불일치 시 미적용 — 을 정확히 출제. 2026-07-02 실측 공식 문구("Reserved DB instance benefits apply to both Multi-AZ and Single-AZ configurations. …move freely between configurations within the same DB instance class type")와 일치. 시나리오가 MySQL이라 사이즈 플렉스 제외 엔진(SQL Server·Oracle LI) 이슈도 없음. 문서 120·123·289행이 DOC-SAA-407대로 수정되면 문서-문항 모순 해소.
3. **saa-t4-2 문서 감사 '발견 0' 대비**: 문항은 전 수치(Standard 72%·Compute SP 66%·Spot 90%·2분 알림·14일/93일·Graviton 약 20%·capacityOptimized) 문서와 정합·공식 일치. 단 Convertible 54%(문서)만 예외로 확인됨 — Q-SAA-c-02 참조.

## 통과 집계 (요약)

- 정답 유일성: 28/30 통과(예외: q9 H 경합, q1 L 경미). 해설-정답 일치: 29/30(예외: q9 해설 전제 불일치). wrongExplanations 논리: 각 문항 오답 3키 전부 서술·논리 정합(예외: q9 보기2 논거 약함, q1 보기2 과장). AWS 사실: 30/30 문항 본문 오류 0건(교차 모순 2건은 모두 문서측 오류). 스키마 위생: 30/30. skill·difficulty 태그: 30/30 적합(foundational 9+applied 6 × 2파일, 시나리오형 비중 어소시에이트 수준 부합).
