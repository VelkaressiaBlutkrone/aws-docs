# ④ 문항 품질 감사 샤드 — 04-q-clf-t4-3 — 2026-07

## 요약

- 대상: `flutter_app/assets/content/clf/t4-3.questions.json` 15문항(전부 `verified:true`) × 7개 점검 항목(정답 유일성·해설-정답 일치·wrongExplanations·앵커·태그·AWS 사실·스키마) 전수 수행. 스키마 위생(id 유일·correct 범위·옵션 4개·wrongExplanations 키 정합 — q8·q10의 correct=2 포함)·해설-정답 일치·section 앵커 실존은 이상 없음(q10은 section 부재이나 "빈 값 통과" 정책상 통과).
- 발견 8건 = H 1·M 3·L 4. **정답 유일성은 15/15 유지** — 아래 발견들은 정답 선택 자체를 뒤집지 않음. 문항 단위 무결(발견 0건) 8/15: q1·q4·q5·q6·q8·q12·q14·q15 (파일 수준 발견 1건 제외 집계).
- 특별 점검 ①(프로덕션+15분 결합, DOC-CLF-309 연계): **발견됨** — q3(스템·해설·출처 제목 3곳)·q13(스템)이 Enterprise를 "프로덕션 중요 케이스 15분 응답"으로 서술. 공식 응답 목표는 '비즈니스 크리티컬 시스템 다운' <15분이고 프로덕션 시스템 다운은 Enterprise도 <1시간 — 문서 오류(DOC-CLF-309, H)의 문항 전파 확인.
- 특별 점검 ②(2026 Support 재편 전제 여부): q2·q7 해설, q11 정답 옵션 자구·해설이 "Business Support+ 전환·Developer/Business 2027-01-01 단종"을 사실로 단정 서술. 다만 네 문항 모두 전통 분류(Basic·Developer·Business·Enterprise)만으로 정답이 성립하므로 **재편 내용이 정답의 전제는 아님** — 문서 정직성 메모의 2단 검증 결과에 연동해 유지/삭제 결정 필요.
- 그 외: q9 구명칭(Personal Health Dashboard) 디스트랙터, q10 section 부재(문서에 Support API 절 자체가 없음), correct=0 편중(13/15), q2 중복 디스트랙터 — 하단 표 참조.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t4-3-01 | t4-3.questions.json:clf-t4-3-q3 | 스템·explanation·sources[0].title 3곳이 Enterprise를 "프로덕션 중요 케이스에 대한 가장 빠른(약 15분) 응답"으로 서술. 공식 응답 목표는 **'비즈니스 크리티컬 시스템 다운' <15분**이며, 프로덕션 시스템 다운은 Enterprise도 <1시간(문서 감사 DOC-CLF-309와 동일 유형의 문항 전파, t4-3.md L70과 같은 소스). 정답(Enterprise) 유일성은 유지되나, 응답 목표 케이스 구분을 묻는 실제 시험 문항에서 오답을 유도할 수 있는 요구사항 서술 오사실 | H | 높 | 3곳 자구 정정: "프로덕션 중요 케이스" → "비즈니스 크리티컬(시스템 다운) 케이스" (wrongExplanations의 '15분 응답' 부정 언급은 정정 후에도 논리 유지됨). 문서 DOC-CLF-309 정정과 동시 반영 | A | Y |
| Q-CLF-t4-3-02 | t4-3.questions.json:clf-t4-3-q13 | 스템 시나리오 전제가 동일 결합 오기를 반복: "전담 TAM과 **프로덕션 중요 케이스 15분 응답**이 포함된 최상위 Support 플랜". 출제 개념(워크로드 적정 플랜 다운그레이드 판단)과 정답 성립에는 영향 없음 — 시나리오 배경 서술 수준의 전파 | M | 높 | 스템 자구 정정("비즈니스 크리티컬 케이스 15분 응답"으로 교체 또는 응답 목표 언급 삭제) | A | Y |
| Q-CLF-t4-3-03 | t4-3.questions.json:clf-t4-3-q2·q7 (explanation) | 해설이 컷오프 밖 2026 Support 재편 주장을 사실로 단정: q2 "현행 공식 명칭으로는 Business Support+ … Developer·Business 플랜을 2027-01-01 단종하고 전환 중", q7 "현행 공식 명칭은 Business Support+. … 2027-01-01 단종 예정". 정답 성립에는 불필요(전통 분류만으로 충분)하며, t4-3.md 정직성 메모(2단 검증 대기)와 동일 소스의 주장 | M | 낮 | 문서 측 2단 검증 결과에 연동: 확인되면 유지, 미확인·상이하면 재편 문구 삭제하고 전통 분류 서술만 남김 | B | Y |
| Q-CLF-t4-3-04 | t4-3.questions.json:clf-t4-3-q11 | 정답 옵션 자구 자체가 재편 명칭을 포함: "Business Support(현 Business Support+) 또는 그 이상" + 해설도 "현재 … Business Support+로 표시되며"로 동일 주장. 재편 주장이 검증에서 무너지면 **정답 옵션 텍스트가 오기**가 됨(정답 식별 가능성은 유지되나 해설보다 노출 수위 높음). 참고로 해설의 응답 목표 서술은 "짧은 응답 시간 목표"로 수치 미기재라 15분/1시간 오류는 없음 | M | 낮 | 2단 검증 결과에 연동: 미확인 시 옵션을 "Business Support 또는 그 이상"으로 축약하고 해설 동기 수정 | B | Y |
| Q-CLF-t4-3-05 | t4-3.questions.json:clf-t4-3-q9 | 오답 옵션(인덱스 1)이 구명칭 "AWS Personal Health Dashboard" 사용 — 2022년 "AWS Health Dashboard"로 통합·개명됐고 CLF-C02 시험 가이드 표기도 AWS Health Dashboard, 같은 파일 q12 옵션 표기와도 불일치. 디스트랙터 기능·정답에는 지장 없음(wrongExplanations["1"]의 기능 설명은 정확) | L | 높 | 옵션·wrongExplanations["1"] 자구를 "AWS Health Dashboard"로 통일(q12와 정합) 또는 "(구 Personal Health Dashboard)" 병기 | A | N |
| Q-CLF-t4-3-06 | t4-3.questions.json:clf-t4-3-q10 | 15문항 중 유일하게 section 필드 부재("빈 값 통과" 정책상 앵커 점검은 통과) — t4-3.md에 AWS Support API 내용 자체가 없어 연결할 앵커가 없는 상태. 문항은 문서 미커버 주제(Support API 접근 = Business/Enterprise On-Ramp/Enterprise, 사실 자체는 공식 문서와 일치)를 출제하고 있어 문서-문항 커버리지 비대칭 | L | 높 | t4-3.md에 Support API 한 줄 보강+앵커 신설 후 section 연결할지, 앵커 없이 유지할지 결정 | B | N |
| Q-CLF-t4-3-07 | t4-3.questions.json:파일 전체 | correct 인덱스 편중: 15문항 중 13문항이 correct=0(예외 q8·q10=2). 렌더 시 옵션 셔플이 없다면 "첫 번째 보기" 위치 단서로 노출 편향 발생 가능(SAA 문항 감사에서 균형 게이트를 둔 전례가 있는 리스크 유형). 앱의 셔플 여부는 본 샤드(콘텐츠 파일) 범위 밖이라 미확인 | L | 중 | 앱 옵션 셔플 여부 확인 → 셔플 없으면 정답 위치 재배치(내용 무변경 데이터 정정) | B | N |
| Q-CLF-t4-3-08 | t4-3.questions.json:clf-t4-3-q2 | 오답 옵션(1) "Basic Support"와 옵션(3) "무료 Basic으로 충분하다"가 실질 동일 의미의 중복 디스트랙터 — 유효 선택지가 사실상 3개로 줄어 변별력 소폭 저하. 정답 유일성·채점에는 영향 없음(둘 다 오답으로 정합) | L | 중 | 옵션(3)을 의미가 겹치지 않는 다른 오답으로 교체 검토(주의: Enterprise On-Ramp는 24x7+전체 TA를 충족해 복수정답이 되므로 디스트랙터로 부적합) | B | N |

## 점검 통과 집계 (요약 근거)

- 스키마 위생: 15/15 통과 — id 유일(q1~q15), correct 전부 0~3 범위, 옵션 4개 고정, verified 15/15 true.
- wrongExplanations: 15/15 키 정합 — correct=0 문항은 {1,2,3}, correct=2 문항(q8·q10)은 {0,1,3}; 누락·정답 인덱스 충돌 없음, 각 키의 반박 논리도 실제 해당 옵션을 반박함.
- 해설-정답 일치: 15/15 — explanation 서술 대상과 correct 인덱스의 옵션 텍스트 전부 일치.
- section 앵커: 사용된 값 support-plans(7)·tech-resources(4)·apn(2)·health-dashboard(1) 모두 t4-3.md `{#id}` 실존, q10은 필드 부재(정책상 통과, Q-CLF-t4-3-06 참고).
- skill·difficulty: 15/15 채움·내용 정합(foundational 12·applied 3, applied는 시나리오형 q13~q15에 부여).
- 정답 유일성: 15/15 — 플랜별 포함 항목(24x7=Business+, 전체 TA=Business+, TAM=Enterprise, Support API=Business+) 기준으로 복수 정답 소지 없음.
