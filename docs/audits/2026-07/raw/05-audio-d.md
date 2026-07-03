# ⑤ 오디오 대본 감사 샤드 — 05-audio-d (clf-t3-5~t3-8) — 2026-07

## 요약 (3~5줄)
clf-t3-5(네트워크)·t3-6(스토리지)·t3-7(AI/ML·분석)·t3-8(메시징·EUC·IoT) 4개 문서의 실제 합성 대본(`enrichedScriptText`)을 원문·AWS 사실·lexicon·chapters와 대조했다. LLM 풍부화가 원문 의미에 충실해 **추가 환각(원문에 없는 새 사실 오류)은 발견되지 않았다**. 다만 원문 자체 오류가 대본에 그대로 낭독되어 승계된 사항 2건(t3-6 EBS 종료 시 데이터 유지, t3-8 SNS 저장·재시도 없음), 풍부화가 덧붙인 경미한 부연 1건(t3-6 객체=블록 아님 설명), 그리고 발음 병기 비일관 3건(Route 53 "피프티스리"↔"Route 53" 혼용, SageMaker "에스에이지이메이커" 철자낭독, AppStream 2.0 "이점영")을 확인했다. chapters↔원문 헤딩/앵커 정합은 4문서 모두 일치. 심각도는 대부분 L, 원문 승계 2건은 원문 오류에 종속(M/사실의심 Y).

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| AUD-301 | audio/clf/clf-t3-6/script.json (seg030 enrichedScriptText) | 원문(t3-6.md L140)의 "EBS=영속적(인스턴스를 중지·종료해도 데이터 유지)"를 대본이 그대로 낭독: "이비에스는 영속적입니다 … 인스턴스를 중지하거나 종료해도 데이터가 그대로 유지된다". 병렬 원문 감사 DOC-CLF-202 지적(루트 EBS 볼륨은 기본 DeleteOnTermination=true라 종료 시 삭제) 사안이 음성에 승계됨. 추가 확대·왜곡은 없음(원문 유래). | M | 중 | 원문 DOC-CLF-202 확정 후 원문 수정→재합성·재승인. 원문 미확정 시 대본 단독 수정 불가. | B | Y |
| AUD-302 | audio/clf/clf-t3-8/script.json (seg016 enrichedScriptText) | 원문(t3-8.md L95)의 "SNS는 메시지를 저장하거나 재시도하는 메커니즘 없이 전달"을 대본이 낭독: "메시지를 따로 저장하거나 재시도하는 메커니즘 없이, 발행되는 순간 바로 전달". 병렬 원문 감사 DOC-CLF-301 지적(SNS는 재시도 정책·DLQ 지원)이 음성에 승계됨. 원문 표현을 벗어난 추가 단정은 없음. | M | 중 | 원문 DOC-CLF-301 확정 후 원문 수정→재합성·재승인. | B | Y |
| AUD-303 | audio/clf/clf-t3-6/script.json (seg016 enrichedScriptText) | 원문에 없는 부연이 추가됨: "파일을 블록 단위로 쪼개서 저장하는 방식이 아니라, 데이터를 하나의 객체 단위로 저장하는 방식". 객체 스토리지 대(對) 블록 스토리지 대비로 AWS 사실과 부합(오류 아님). 추가 문장이나 사실 왜곡은 없으나 원문 범위를 벗어난 창작 부연이라 기록. | L | 높 | 유지 가능(사실 정확). 재합성 시 참고만. | A | N |
| AUD-304 | audio/clf/clf-t3-5/script.json (seg027·seg030 enrichedScriptText vs seg026/seg029/seg041 scriptText) | Route 53 발음 병기 비일관. enriched는 "라우트 피프티스리"(seg027·seg030·seg035류), 비-enriched scriptText는 "Route 53"을 영문 그대로("Amazon Route 53은…" seg026, "한 줄: Route 53" seg029). 같은 문서 내 한 서비스가 한국어 숫자낭독과 영문표기로 혼재. lexicon에 Route 53 항목 없음. 사실 오류 아님(자구·발음). | L | 높 | lexicon에 "Route 53"→"라우트 피프티스리" 등록해 표준화 후 재합성 시 일관화(선택). | A | N |
| AUD-305 | audio/clf/clf-t3-7/script.json (seg028 enrichedScriptText) | SageMaker 철자낭독 오류: "세이지메이커, 즉 에스에이지이메이커". 앞선 seg011·seg013 등은 "세이지메이커"로 자연 발음. "에스에이지이메이커"(S-A-G-E-메이커 철자읽기)는 잘못된 발음 병기로 청취 시 혼란. 사실 오류 아님. | L | 높 | 재합성 시 해당 병기 삭제("세이지메이커"로 통일). | A | N |
| AUD-306 | audio/clf/clf-t3-8/script.json (seg024 audioSummary) · audio/clf/clf-t3-5/script.json 등 | 버전·숫자 낭독 관용 비일관: t3-8 seg024 audioSummary "앱스트림 이점영"(AppStream 2.0→"이점영"). 단, 해당 seg024는 table(scriptText 공백, audioSummary는 미합성 텍스트일 수 있음)—실제 합성 대상 확인 필요. enriched(seg023 등)에서는 "앱스트림 2.0"으로 자연 낭독됨. 표 요약과 본문 낭독 간 숫자 표기 관용 차이. 사실 오류 아님. | L | 낮 | 표 audioSummary 합성 여부 확인 후, 합성 대상이면 "이점영"→"이 점 영/이쩜영" 표준화(선택). | A | N |

## 비고 (판정 근거 · 확인 사항)
- **추가 환각 없음**: 4문서의 모든 `enrichedScriptText`를 원문 문단과 1:1 대조. 원문에 없는 AWS 서비스 사실(수치·한계·기능)을 새로 만든 사례 없음. 풍부화는 강사체 연결·재진술·부연에 그침.
- **원문 유래 오류(승계)**: t3-6 11-9s 내구성은 원문이 "1,000만 개 중 1개 미만"(DOC-CLF-203의 '1만 년' 누락 지적)으로 서술하나, 대본 seg017은 수치를 굳이 부연하지 않고 "사실상 데이터를 잃지 않도록"으로만 낭독 → 대본에 추가 오류 없음(무기록). Storage Gateway FSx File GW(DOC-CLF-205)는 대본 seg038이 4유형을 사실대로 나열 → 무기록.
- **chapters↔원문 정합(4문서 전부 일치)**: 각 audio_meta.json chapters의 anchor·title이 원문 헤딩 {#앵커}와 일치. t3-5(vpc/vpc-security/flow-logs-privatelink/route53/onprem-connect/edge/pitfalls), t3-6(storage-types/s3/s3-classes/s3-lifecycle/ebs/efs/hybrid-backup/pitfalls), t3-7(ai-ml/analytics/scenario/language-ai/applied-ai-services/pitfalls), t3-8(messaging/euc/appstream-mq/iot/other-services/sqs-types/pitfalls) 모두 원문 순서·레벨 부합. fraction 단조 증가 정상.
- **메타 정합**: 4문서 모두 reviewStatus=approved, loudness normalized:true(-16 LUFS), id3Count=1, script.reviewStatus=approved. sourceHash가 script.json/audio_meta.json 간 일치(t3-5 6c9133…, t3-6 558e35…, t3-7 1e33cf…, t3-8 a6274f…).
