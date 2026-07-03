# ⑤ 오디오 대본 감사 샤드 — 05-audio-a (clf-t1-1~t1-4) — 2026-07

## 요약 (3~5줄)

- 4개 문서의 `enrichedScriptText` 전 세그먼트를 원문(`sourceExcerpt`)·`scriptText`와 전수 대조. **AWS 사실을 정면으로 위배하는 추가 환각은 없음.** enrich가 새로 넣은 비유(t1-1 택시·공공자전거 등)와 부연은 대부분 사실 부합. **t1-1은 발견 0건.**
- 사실의심 Y는 2건뿐이며 모두 경미(L): NFS·SMB를 "파일 시스템"으로 지칭(t1-3), ECS·EKS 패치 일반화(t1-4 — **원문 유래**, 문서 감사 기발견 건의 상속+소폭 증폭).
- 의미 수위 변경(단정 강화·카운팅 추가) M 2건: t1-3 "기술이 문제인 경우는 많지 않다"(원문은 "기술만이 아니라"), t1-2 "이 다섯 가지 방향이 핵심"(6대 기둥·"기둥 5개" 함정과 청취 간섭 위험).
- 발음·표기 L 다수: 영문 서비스명 음역 혼용(스노우볼↔Snowball 등), CapEx/OpEx 이중 음역, draft 표 요약("보호은/개선은" 조사 오류) 합성 잔존. scriptText 자체의 발음 병기는 lexicon과 일치(AZ firstSay/thenSay 포함).
- **chapters 정합: 4문서 19챕터 전부 md 헤딩·{#앵커}와 일치**(이모지·★ 제거는 정상 정규화, 앵커 없는 헤딩은 정상적으로 제외). Phase A 항목은 대본 수정 시 **재합성 + 사람 청취 재승인 필요**(재합성이 reviewStatus를 리셋하므로 approved 재플립 절차 포함).

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| AUD-001 | audio/clf/clf-t1-2/script.json seg012(enriched) | 원문에 없는 카운팅 "이 다섯 가지 방향이 핵심이라고 기억해 두시면 됩니다" 추가(정의문의 형용사 5개를 셈). 같은 강의의 핵심 암기 수가 "6대 기둥"이고 함정 1번이 "기둥은 5개다→❌"라서 청취 시 숫자 간섭으로 오개념 유발 위험 | M | 중 | "다섯 가지" 카운팅 삭제 또는 "정의 문장에 나온 다섯 형용사(기둥 6개와 별개)"로 명시. 수정 시 재합성·재승인 | A | N |
| AUD-002 | audio/clf/clf-t1-2/script.json seg022(enriched) | 원문 "쪼갠 각 조각은 한 기둥으로 귀속됩니다"를 "한 조각이 두 기둥에 걸치는 일은 없다는 점"으로 절대 단정화(단정 강화) | L | 중 | 원문 수위("각 조각은 한 기둥으로 귀속")로 완화. 수정 시 재합성·재승인 | A | N |
| AUD-003 | audio/clf/clf-t1-2/script.json seg026(enriched) | Well-Architected Framework를 "잘 구성된 프레임워크"로 즉흥 국문화 — 강의 전체에서 유일한 표기(다른 곳은 전부 "웰 아키텍티드"). 청취자가 별개 용어로 오인 가능 | L | 높 | "웰 아키텍티드 프레임워크"로 통일. 수정 시 재합성·재승인 | A | N |
| AUD-004 | audio/clf/clf-t1-3/script.json seg016(enriched) | 원문 "실패하는 이유는 기술만이 아니라 …비기술 영역이 준비되지 않아서인 경우가 많습니다" → "의외로 기술이 문제인 경우는 많지 않습니다 …훨씬 많습니다"로 단정 강화(원문은 '기술 외 요인도 많다', enrich는 '기술은 거의 문제 아님') | M | 높 | 원문 수위로 되돌림. 수정 시 재합성·재승인 | A | N |
| AUD-005 | audio/clf/clf-t1-3/script.json seg021(enriched) | 원문에 없는 출제범위 단정 "씨엘에프 시험에서는 이런 등록 제한 여부까지 묻지 않습니다" 추가(검증 불가한 시험 주장) | L | 중 | 삭제하거나 원문 수준("씨엘에프에선 개념으로 유효")으로 완화. 수정 시 재합성·재승인 | A | N |
| AUD-006 | audio/clf/clf-t1-3/script.json seg025(enriched) | NFS·SMB를 "파일 시스템"으로 지칭 — 공식 DataSync 문서 기준 파일 공유 '프로토콜'(원문도 "온프레미스 스토리지(NFS·SMB 등)"로만 표기). 경미한 개념 부정확 | L | 중 | "엔에프에스나 에스엠비 같은 파일 공유 프로토콜"로 정정. 수정 시 재합성·재승인 | A | Y |
| AUD-007 | audio/clf/clf-t1-3/script.json seg020~022 vs seg029·seg031(enriched); audio/clf/clf-t1-4/script.json seg024·seg031 vs seg042(enriched) | 영문 서비스명 음역 혼용(대표 사례): t1-3 "스노우볼"(seg020~022)↔"Snowball"(seg029·031), "데이터싱크"(seg025~026)↔"DataSync"(seg031); t1-4 "Dedicated Hosts"(seg024·031)↔"데디케이티드 호스트"(seg042). 같은 문서 안에서 TTS 발음이 달라짐 | L | 높 | 문서 내 단일 표기로 통일(음역 권장), 자주 쓰는 서비스명은 lexicon 등재 검토. 수정 시 재합성·재승인 | A | N |
| AUD-008 | audio/clf/clf-t1-4/script.json seg012 vs seg040(enriched) | CapEx/OpEx 음역 불일치: seg012 "캐펙스/오펙스" vs seg040 "캡엑스/옵엑스". lexicon 방침은 음역이 아니라 우리말 치환("자본 지출"/"운영 지출") | L | 높 | 한 가지 음역으로 통일하거나 lexicon 방침대로 우리말+1회 병기. 수정 시 재합성·재승인 | A | N |
| AUD-009 | audio/clf/clf-t1-4/script.json seg026(enriched) | 원문의 타 문서 상호참조 "(3.1)"을 "자세한 내용은 뒤에서 다시 살펴보겠습니다"로 변환 — 이 강의 뒤에는 해당 상세(CloudFormation 심화) 없음(3.1은 별도 문서). 같은 문서 seg031은 "3.3과 3.4에서"로 참조를 유지해 처리 불일치 | L | 중 | "3.1 문서에서 자세히 다룹니다"로 정정. 수정 시 재합성·재승인 | A | N |
| AUD-010 | audio/clf/clf-t1-4/script.json seg034(enriched) | 원문 조건문 "단가가 높더라도"를 "관리형 서비스는 단가가 더 높은데"로 단정화 — 같은 문서 함정 절("항상 더 비싸다"→⚠️ 단가만 보면 그럴 수 있으나)과 긴장. 문단 말미 "높아 보여도"로 일부 상쇄됨 | L | 중 | 조건형("단가가 더 높더라도")으로 복원. 수정 시 재합성·재승인 | A | N |
| AUD-011 | audio/clf/clf-t1-4/script.json seg031(enriched) | 관리형 서비스 예시에 ECS·EKS를 포함한 채 "패치·백업·확장·고가용성 …대신 처리" 일반화 — **원문(md) 유래**(병렬 문서 감사 기발견: EKS 등은 노드/버전 관리 책임이 고객에 일부 남음). enrich가 "우리가 직접 손대지 않아도 되는 부분들을 알아서 관리해 주는 것"으로 소폭 증폭 | L | 중 | 원문 t1-4.md 정정(문서 감사 건)과 연동해 대본 동시 수정 — 대본만 고치면 토큰보존 게이트·원문 불일치 발생. 사람 결정 필요 | B | Y |
| AUD-012 | audio/clf/clf-t1-2/script.json seg021(audioSummary, issues: table-summary-draft) | 표 요약 초안이 그대로 합성됨 — "운영을 개선은 운영 우수성입니다", "보호은 보안입니다", "설계은 안정성입니다", "효율적으로은 성능 효율성입니다" 등 조사 오류 다수(청취 품질). t1-4 seg022에도 동일 플래그(table-summary-draft) 잔존(문장은 상대적으로 무난) | L | 높 | 요약 문장을 자연문으로 다듬고 issues 플래그 해소 후 재합성·재승인 | A | N |

### 점검 항목별 결과 (문서당)

| 문서 | 1) 추가 환각 | 2) 의미 왜곡 | 3) 발음 병기 | 4) chapters 정합 |
|---|---|---|---|---|
| clf-t1-1 | 없음(택시·공공자전거 비유 등 모두 사실 부합) | 없음 | 일치(에이더블유에스·씨엘에프 씨 공이·이아르피, AZ firstSay "가용 영역"→thenSay "에이제트") | 5/5 일치(core-concepts·core-benefits·ha-elasticity·global-infra·pitfalls) |
| clf-t1-2 | AUD-001(간섭성 카운팅) | AUD-002 | AUD-003, AUD-012 | 3/3 일치(well-architected·six-pillars·pitfalls; 무앵커 헤딩 "3) 시나리오→기둥" 제외는 정상 |
| clf-t1-3 | AUD-005, AUD-006 | AUD-004 | AUD-007 | 4/4 일치(caf·migration-tools·datasync-7r·pitfalls) |
| clf-t1-4 | AUD-011(원문 유래 상속) | AUD-009, AUD-010 | AUD-007, AUD-008 | 7/7 일치(capex-opex·rightsizing·licensing·automation·managed-services·autoscaling·pitfalls) |

주: Phase A 항목은 enrichedScriptText 자구 수정으로 해소 가능하나, **수정 → 재합성 → reviewStatus 리셋 → 사람 청취 재승인(approved 재플립)** 절차가 필수(동기화 테스트 게이트). AUD-011만 원문 md 수정과 연동해야 하므로 Phase B.
