# ⑤ 오디오 대본 감사 샤드 — 05-audio-e (clf-t4-1~t4-3) — 2026-07

## 요약 (3~5줄)
- 대상 3문서(요금 모델·비용 관리 도구·Support 플랜)의 **enrichedScriptText**(실제 합성 대본)를 원문·audioSummary와 대조. 세 문서 모두 reviewStatus=approved, chapters↔원문 헤딩/{#앵커} **완전 정합**(불일치 0).
- **추가 환각(원문에 없는데 대본이 새로 지어낸 오류)은 사실상 없음**. 대본은 원문에 충실하게 풀어 읽었고, 새 수치·새 사실을 지어내 삽입한 사례를 찾지 못함.
- 다만 **원문 유래 오류가 음성으로 그대로 낭독**됨: t4-1 Savings Plans "최대 72%+유연" 결합(72%는 EC2 Instance SP·고정), t4-2 Cost Explorer "향후 18개월 예측"(공식 12개월), t4-3 Enterprise "프로덕션 중요 케이스 15분 응답"(공식은 비즈니스 크리티컬 다운 15분/프로덕션 다운 1시간). 이들은 **병렬 원문 감사(DOC-CLF-305/308/309)에서 이미 채번**된 항목의 음성 반영분으로, 원문 수정→재합성 시 자동 해소.
- **1건 의미 왜곡 승격**: t4-3 seg013 enriched가 원문 "15분 응답"을 **"15분 응답이 보장된다"로 단정 강화**(원문+공식 모두 응답 '목표'이지 보장 아님). 원문 오류 위에 대본이 강화를 얹어 심각도 상향.
- 발음/자구: 비-lexicon 영단어(Organizations·Dedicated·Glacier)의 한글 표기가 세그먼트 간 흔들림(L). "Business Support+"의 "+→그리고" 정규화 깨짐은 **fallback scriptText에만** 존재하고 실제 합성 필드(enrichedScriptText)는 "플러스"로 정상 → 음성 영향 없음.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| AUD-401 | audio/clf/clf-t4-3/script.json seg013 enrichedScriptText | 원문 "15분 응답"을 **"15분 응답이 보장된다"**로 낭독(단정 강화). 공식 AWS Support는 응답 '목표(objective/target)'이지 보장이 아니며, 15분 목표는 비즈니스 크리티컬 시스템 다운 케이스에 해당(프로덕션 시스템 다운은 1시간 목표). 원문 오류(DOC-CLF-309) 위에 "보장"이 얹혀 왜곡 심화. 같은 문서 seg026 enriched는 오히려 정확("프로덕션 다운 1시간…Enterprise 비즈니스 크리티컬 더 짧은 목표")이라 문서 내 모순. | H | 높 | seg013 enriched에서 "15분 응답이 보장된다"→"프로덕션 중요 케이스에 15분 응답 목표를 제공"(또는 seg026 표현에 맞춰 "비즈니스 크리티컬 케이스 15분 응답 목표")로 완화. **재합성·재승인 필요**. 단, 근본 수치 배정 오류는 원문(DOC-CLF-309)에서 함께 교정해야 완결. | A(대본 완화) + B(원문 수치 배정은 사람 결정) | Y |
| AUD-402 | audio/clf/clf-t4-3/script.json seg012 audioSummary(표 요약) | "엔터프라이즈는…프로덕션 중요 케이스 15분 응답" — 원문 표(DOC-CLF-309)의 잘못된 티어 배정을 그대로 음성화. 공식은 프로덕션 다운=1시간, 15분은 비즈니스 크리티컬 다운. 원문 유래(대본이 추가 왜곡하진 않음). | M | 높 | 원문 표 수정 후 audioSummary/enriched 재생성·재합성. 대본 단독 수정보다 원문 정정이 선행. | B | Y |
| AUD-403 | audio/clf/clf-t4-2/script.json seg012 audioSummary(표 요약) | "코스트 익스플로러는…향후 약 18개월 예측을 제공" — 원문 표(DOC-CLF-308)의 "향후 ~18개월 예측"을 음성화. 공식 Cost Explorer forecast는 **최대 12개월**. 원문 유래(추가 왜곡 없음). seg025 enriched의 예측 서술에는 개월 수 미언급이라 확산은 제한적. | M | 중 | 원문 "향후 ~18개월"→"향후 최대 12개월" 정정 후 재생성·재합성. Phase B(원문 정정 선행). | B | Y |
| AUD-404 | audio/clf/clf-t4-1/script.json seg025 enrichedScriptText (+seg012 audioSummary) | "세이빙스 플랜입니다. …최대 72퍼센트까지 할인…핵심은 유연하다…이씨투·파게이트·람다까지 적용" — 원문(DOC-CLF-305)의 "72%(고정형 EC2 Instance SP 수치)+완전 유연(Compute SP·66%)" 결합을 음성으로 재현. 대본이 새로 만든 게 아니라 원문 표·시험포인트를 충실히 낭독. | M | 중 | 원문에서 72%(EC2 Instance SP)와 유연성(Compute SP)을 분리 서술하도록 정정 후 재합성. 대본 단독으로는 근거가 원문이라 Phase B. | B | Y |
| AUD-405 | audio/clf/clf-t4-1/script.json seg009 audioSummary | Glacier "데이터 복원에 수 분에서 수 시간이 걸립니다" — 원문(DOC-CLF-306) 일반화("수 분~수 시간")를 음성화. 실제 복원 시간은 스토리지 클래스/검색 티어별로 상이(분~12시간+). 원문 유래·저위험. | L | 중 | 원문 정정 시 함께 반영. 대본 단독 조치 불요. | B | Y |
| AUD-406 | audio/clf/clf-t4-1/script.json seg006·seg012·seg009 (enriched/audioSummary) | Dedicated Hosts 한글 표기 불일치: seg006/seg013/seg026 enriched "**데**디케이티드", seg009/seg012 audioSummary "**디**디케이티드". 같은 용어 청취 시 혼동 가능. 비-lexicon 자유표기 변주(lexicon.json엔 "Dedicated" 항목 없음). | L | 높 | lexicon.json에 "Dedicated Hosts"/"Dedicated" say 표준화 항목 추가하거나 대본 표기 통일("데디케이티드"). 재생성·재합성 시 반영. | A | N |
| AUD-407 | audio/clf/clf-t4-2/script.json seg006 vs seg016~019 (enriched) | Organizations 한글 표기 불일치: seg006 "**오가니제이션스**", seg016~019 "**오거나이제이션스**", audioSummary "**오거니제이션스**" 혼재. 비-lexicon 자유표기(스펠아웃 단어라 lexicon 미등록). | L | 높 | 대본 표기 통일 또는 lexicon에 "Organizations" say 추가. 재합성 시 반영. | A | N |
| AUD-408 | audio/clf/clf-t4-1/script.json seg009 vs seg021~023 (audioSummary/enriched) | Glacier 한글 표기 불일치: seg009 audioSummary "**글레이셔**", seg021~023 enriched "**글래시어**". 저위험 자구. | L | 높 | 표기 통일("글래시어" 권장) 후 재생성. | A | N |
| AUD-409 | audio/clf/clf-t4-3/script.json seg014·seg031 등 fallback scriptText | "Business Support+"가 plain scriptText에서 "비즈니스 서포트 **그리고**"로 정규화 깨짐(+→그리고). **단, 해당 세그먼트 전부 enrichedScriptText 보유**하고 그 필드는 "비즈니스 서포트 **플러스**"로 정상 → **실제 합성 음성엔 영향 없음**. 관찰 기록용. | L | 높 | 조치 선택: 파이프라인의 "+" 정규화 규칙 보정(향후 enriched 미보유 세그먼트 대비). 현 음성은 무영향이라 긴급도 낮음. | A | N |
| AUD-410 | audio/clf/clf-t4-3/script.json seg014·seg031 enrichedScriptText | Support 플랜 재편 "정직성 메모"(Developer·Business·Enterprise On-Ramp 2027-01-01 단종, Business Support+/Unified Operations 도입)를 음성으로 단정 낭독. 지시문상 **모델 컷오프(2026-01) 밖 사실로 2단 검증 대기** 항목 — 진위 미확정. 대본은 "시험은 전통 4단계로" 안전장치를 병기해 학습 위험은 완화됨. | L | 낮 | 재편 사실 자체를 별도 2단 검증(공식 문서 실측)으로 확정. 미확정 상태면 대본 유지 가능(안전장치 존재). 사람 결정 필요. | B | N(검증 대기) |

발견 요약: 총 10건 (사실의심 Y 5건 = AUD-401~405; 나머지 5건은 발음·자구·검증대기). 추가 환각(원문에 없는 신규 사실 오류)=0건. 왜곡 승격 1건(AUD-401). chapters 불일치=0건.
