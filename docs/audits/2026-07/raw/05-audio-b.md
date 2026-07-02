# ⑤ 오디오 대본 감사 샤드 — 05-audio-b (clf-t2-1~t2-4) — 2026-07

## 요약 (3~5줄)
CLF 도메인 2(보안) 4문서의 강의 대본(enrichedScriptText 실합성분)·메타·원문을 대조했다. **enrich가 새로 지어낸 '추가 환각'은 발견되지 않았다** — 강사체 확장은 원문 사실 범위 안에 충실히 머물렀고, 전환·격려 문구만 추가됐다. 실질 발견 2건은 모두 **원문 유래 사실 오류를 대본이 그대로 낭독**한 것(대본이 확대·왜곡하진 않음): (a) t2-2 Audit Manager 신규 중단 시점을 "2024년"으로 낭독(실제 2026-04-30), (b) t2-3가 "Support 플랜 변경·취소 = 루트 전용"을 2개 발화 세그먼트에서 낭독(현행 AWS 루트 전용 목록에 없음). 챕터↔앵커 정합은 4문서 모두 완전 일치, 발음 병기도 lexicon과 일관되어 별도 발견이 없다. 대본은 이미 청취 승인(approved) 상태이므로 두 건 모두 원문 수정 후 재합성·재승인이 필요하다.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| AUD-101 | audio/clf/clf-t2-2/script.json (seg051, enrichedScriptText) | "에이더블유에스 Audit Manager는 2024년 이후 신규 고객 등록을 중단했습니다"를 대본이 그대로 낭독. 실제 신규 온보딩 중단 고지 시점은 2026-04-30(원문 유래, 병렬 감사 DOC-CLF-101 M와 동일 사실). enrich는 원문을 확대·왜곡하지 않고 충실히 읽음 → 심각도 원문 수준 유지. | M | 중 | 원문 t2-2.md(정직성 메모)의 "2024년"을 정정한 뒤 해당 세그먼트 재합성·재승인. 원문 수정이 선행이므로 대본 단독 수정 불가. | B | Y |
| AUD-102 | audio/clf/clf-t2-3/script.json (seg023 line 266 · seg056 line 646, 둘 다 enrichedScriptText, skip=false) | "에이더블유에스 서포트 플랜 변경·취소 = 루트 전용 작업"을 2개 발화 세그먼트(루트 전용 목록 + 시험 포인트)에서 낭독. 현행 AWS 루트 전용 작업 목록에는 없음(원문 유래, 병렬 감사 DOC-CLF-102 H). 대본은 원문을 그대로 읽었을 뿐 확대·왜곡 없음 → 원문 심각도(H) 유지. 자가 점검 Q1(line 745)에도 있으나 skip=true라 미낭독. | H | 중 | 원문 t2-3.md(§3 루트 목록·시험 포인트·자가 점검 3곳)를 현행 루트 전용 목록 기준으로 정정 후, 낭독되는 2개 세그먼트 재합성·재승인. AWS 공식 루트 전용 작업 목록으로 사실 확인은 사람 검수 필요. | B | Y |

### 점검했으나 발견 없음(정상 확인)
- **추가 환각(핵심 사각지대)**: 4문서 enrichedScriptText 전 세그먼트에서 원문에 없는 AWS 사실 오류를 새로 지어낸 사례 **없음**. 확장분은 비유("상자/내용물")·재진술·시험 팁 강조뿐이며 모두 원문 사실 범위 내. t2-4의 WAF 보호 리소스 목록(CloudFront·ALB·API Gateway REST·AppSync·Cognito·App Runner·Verified Access·Amplify), HTTP 403, WAF↔Shield 구분, Trusted Advisor Support 플랜 게이팅, SG/NACL stateful·stateless 모두 정확히 낭독.
- **원문 의미 왜곡**: 단정 강화·조건 탈락 사례 없음. 예: t2-1 S3 기본 암호화(2023-01 이후 신규 객체 SSE-S3)의 "신규 객체" 조건, RDS/Lambda 책임 경계, t2-2 Shield Standard '무료·자동' 등 조건이 enrich에서도 보존됨.
- **발음 병기 일관성**: lexicon.json 대조상 불일치 없음. 약어는 우리말 발음형으로 일관 병기(AWS→에이더블유에스, IAM→아이엠, EC2→이씨투, RDS→알디에스, S3→에스쓰리, KMS→케이엠에스 등). AZ는 lexicon firstSay="가용 영역"과 일치(t2-1 seg017). 서비스 고유명(GuardDuty→가드듀티, Macie→메이시, Config→컨피그 등)은 lexicon 미등재로 TTS 자연 발음 — 일관되며 문제 아님.
- **chapters 정합**: 4문서 모두 audio_meta.json chapters의 anchor·title이 원문 {#앵커} 헤딩과 완전 일치. 앵커 없는 H3(t2-1 "한 문장 요약", t2-3 "IAM이란")은 chapters에서 올바르게 제외됨. 불일치 0건.
