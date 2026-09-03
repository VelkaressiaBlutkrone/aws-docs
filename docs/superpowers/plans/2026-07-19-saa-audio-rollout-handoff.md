# SAA 오디오 강사체 롤아웃 — 핸드오프 (2026-07-19)

CLF 강사체 오디오 파이프라인을 **SAA-C03 24문서**로 확장하는 작업의 세션 이관 문서.

- **브랜치:** `feat/2026-07-saa-audio-pilot` (develop에서 분기, 원격 푸시됨)
- **✅ 블로커 해소(2026-09-03):** Anthropic API 크레딧 복구 실측(HTTP 200). 이전 블로커 기록: **Anthropic API 크레딧 소진.** `enrich`(강사체 변환) 호출이 400 `credit balance too low`로 실패. `flutter_app/tool/.env`의 `ANTHROPIC_API_KEY` 계정 충전 전에는 재개 불가.
- **사용자 결정(고정):** enrich 모델=**Opus 유지**, 영문 서비스명(Shield·Cognito 등)=**영문 그대로**(Polly 발음 수용), 청취 게이트=사람. `audioApproved` flip은 사용자 청취 후(미완).

## 진행 상태 (2026-09-03)

| 문서 | 상태 | 비고 |
|------|------|------|
| saa-t1-1 ~ t1-5 | ✅ 완료 커밋 | 도메인1 전체. enrich·synth·gate·verify 통과 |
| saa-t2-1 | ✅ 완료 커밋 | 느슨한 결합(SQS·SNS·EventBridge·Step Functions) |
| saa-t2-2 | ✅ 완료 커밋 | 2026-09-03 크레딧 복구 후 enrich 35세그·verify 3플래그(전부 인접세그 뒷받침 양성)·synth 7섹션/6챕터·gate PASS(hard 0) |
| saa-t2-3 ~ t2-5 | ✅ pre-enrich 스캐폴드 커밋 | 앵커·표요약·lexicon·script gate PASS. enrich·synth 미실행(크레딧) |
| saa-t3-1 | ✅ pre-enrich 스캐폴드 커밋 | S3 Express One Zone 반영, 앵커·표요약·lexicon·script gate PASS. enrich·synth 미실행(크레딧) |
| saa-t3-2 | ✅ pre-enrich 스캐폴드 커밋 | EFS Archive·FSx OpenZFS 현행화, 앵커·표요약·lexicon·script gate PASS. enrich·synth 미실행(크레딧) |
| saa-t3-3 | ✅ pre-enrich 스캐폴드 커밋 | Precision time 배치 전략 현행화, 앵커·표요약·lexicon·script gate PASS. enrich·synth 미실행(크레딧) |
| saa-t3-4 | ✅ pre-enrich 스캐폴드 커밋 | ECS Managed Instances·EKS Auto Mode 출처 보강, 앵커·표요약·script gate PASS. enrich·synth 미실행(크레딧) |
| saa-t3-5 | ✅ pre-enrich 스캐폴드 커밋 | RDS Read Replica 한도·Multi-AZ DB cluster·Aurora/RDS 스토리지 현행화, 앵커·표요약·lexicon·script gate PASS. enrich·synth 미실행(크레딧) |
| saa-t3-6 ~ t3-9 | ⬜ 대기 | 다음 스캐폴드 대상 |
| saa-t4-1 ~ t4-5 | ⬜ 대기 | |

**남은 완성 작업: 13개** (t2-3~t2-5·t3-1~t3-5 enrich/synth 재개 + t3-6~t3-9·t4-1~t4-5 스캐폴드부터).
**크레딧 충전 전 가능한 작업:** `saa-t3-6`부터 같은 방식으로 앵커·lexicon·표요약·script gate PASS까지 선행.

모든 완료분은 `reviewStatus=needs_human_review`, content_index/pubspec 미등록 → **라이브 미노출**(번들 무영향).

## 재개 절차 (크레딧 충전 후)

**먼저 t2-2 완성:**
```sh
cd flutter_app
S=assets/audio/saa/saa-t2-2/script.json
py tool/gen_lecture_audio.py generate --md assets/content/saa/saa-t2-2.md --out-dir assets/audio/saa/saa-t2-2 --lexicon tool/lexicon.json
py tool/gen_lecture_audio.py descaffold --script $S
py tool/gen_lecture_audio.py connectors --script $S
py tool/apply_audio_summary.py saa-t2-2      # 표요약 이미 SUMMARIES에 있음
py tool/gen_lecture_audio.py gate --script $S --md assets/content/saa/saa-t2-2.md --lexicon tool/lexicon.json   # HARD 0 확인
py tool/gen_lecture_audio.py enrich --script $S --lexicon tool/lexicon.json
py tool/gen_lecture_audio.py gate --script $S --md assets/content/saa/saa-t2-2.md --lexicon tool/lexicon.json   # enrich가 약어 드롭 시 발음형 손보정
py tool/gen_lecture_audio.py verify --script $S    # ★합성 전 검사★ 음차/약어변경=실결함 수정, 사실단정=대개 양성
py tool/gen_lecture_audio.py synthesize --script $S --out assets/audio/saa/saa-t2-2/lecture.mp3
py tool/gen_lecture_audio.py gate --script $S --md assets/content/saa/saa-t2-2.md --audio-meta assets/audio/saa/saa-t2-2/audio_meta.json --lexicon tool/lexicon.json
# 커밋: md+apply_audio_summary+lexicon(변경시)+assets/audio/saa/saa-t2-2/  (enrich_report/verify는 .gitignore)
```

## 문서당 레시피 (t3-6부터 반복)

1. **열거:** 헤딩(`grep '^#'`) + `generate`로 표·미등록토큰(unmapped) 확인
2. **lexicon 갭 추가** (`tool/lexicon.json`) — **약어만, 서비스명 추가 금지**(영문 정책). SG류 다발 약어는 `{firstSay,thenSay}`(enrich가 풀어써도 토큰보존 통과, 예: SG=보안그룹/에스지)
3. **헤딩 `{#slug}` 앵커** 추가 — `## 📖 핵심 개념`(H2) + 그 아래 `### N)`(H3들) + `## ⚠️ 흔한 함정`. CLF 관례. → 오디오 챕터 생성원
4. **표 음성요약 저작** → `tool/apply_audio_summary.py`의 `SUMMARIES["saa-tN-M"] = {segID: "..."}`. 원문 표 근거·lexicon **say형 병기**(토큰보존)·평문(→ ≠ ↓ § | URL `](` 금지). 3열+ 표는 HARD 게이트 필수. 2열 auto-draft(table-summary-draft)도 영문잔재 있으면 override. **audioSummary는 apply_lexicon 미경유 → 약어를 최종 한글로 직접 표기.**
5. `generate → descaffold → connectors → apply_audio_summary → gate`(HARD 0)
6. `enrich`(Opus, ~30~45콜) → `gate`(HARD 0; enrich가 약어 드롭 시 그 세그 enrichedScriptText에 발음형 병기 손보정) → **`verify` 합성 전 검사** → `synthesize`(Polly neural·-16 LUFS·챕터) → 최종 `gate`
7. **커밋**(문서 단위, §5 브랜치 검증 후)

## 비자명 교훈 (겪은 함정)

- **enrich 툴체인은 소실 아님** — `gen_lecture_audio.py`(1931줄)에 서브커맨드 전부 내장·추적(generate/descaffold/connectors/enrich/verify/gate/synthesize/chapters). gitignore된 `_*.py`는 일회성 헬퍼.
- **SAA 학습문서엔 `{#slug}` 앵커 없음**(유예됨) → 챕터 0. 앵커 추가가 필수. 앵커는 스피치 무영향(scriptText서 스트립)이나 script.json 헤딩 sourceExcerpt에서 챕터 파생(`chapters_from_segments` L941). 앵커 추가로 connectors 수 늘어 스피치 변함 → 재합성 필요.
- **verify는 synthesize 전에.** t1-5 seg006서 enrich가 CloudHSM을 "케이에스에이치에스엠"으로 오음차 → 커밋 후 발견·amend. 플래그 `음차/약어변경`=실결함, `사실단정`=대개 인접세그 뒷받침 양성.
- **enrich HARD 손보정 패턴:** enrich가 약어를 우리말로 풀며 발음형 드롭(예 SAA→에스에이에이, AD→에이디 누락) → 해당 세그 enrichedScriptText에 발음형 병기(python 인라인 치환 후 재gate).
- **NACL→나클**(네트워크에이씨엘 아님), FIFO→피포, NAT→냇 등 기존 lexicon 발음형과 표요약 일치 필수(원문에 ACL·NACL 둘 다면 에이씨엘·나클 모두 포함).
- **회귀 게이트:** 콘텐츠(앵커)·lexicon 변경 후 `flutter test`(782)·`flutter analyze`(0) 확인. (t1-* 완료 시 확인함.)

## 도구 인프라 변경 (이 브랜치서 완료)

- `apply_audio_summary.py`: CLF 하드코딩(`CLF=.../clf` 경로+SUMMARIES) → `_cert_dir(doc_id)` 접두어 파생 일반화 + `--self-test` 추가.
- `.gitignore`: enrich 스크래치 무시 규칙 clf 전용 → 전 자격증(`flutter_app/assets/audio/*/*/enrich_report.md` 등).
- `lexicon.json`: SAA 약어 다수 추가(도메인1~3). 린터가 multi-line(indent 2) 포맷 적용.

관련 메모리: `saa-audio-rollout`, [[content-review-pipeline-planned]], [[audio-instructor-script-planned]], [[audio-runtime-gate-shipped]].
