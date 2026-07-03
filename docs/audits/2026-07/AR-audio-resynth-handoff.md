# AR 트랙(오디오 재합성) — ✅ 완료 기록

> 착수 2026-07-03 · 완료·릴리스 2026-07-03 · 브랜치 `fix/2026-07-clf-audio-resynth`(머지·정리됨)
> 이 문서는 원래 "다음 세션 이관용 핸드오프"였으나, 해당 세션에서 트랙이 **완결·프로덕션 배포**되어 완료 기록으로 갱신되었다. 재합성 절차(§5)는 향후 오디오 작업의 참조로 남긴다.

---

## 0. 결과 요약 (완료)

- **AR 오디오 재합성 트랙 전부 완료 → main 릴리스·배포 성공**(2026-07-03, `f7ca98c`, Deploy GitHub Pages success).
- 정정된 CLF 사실이 이제 **강의 음성(mp3)에 반영되어 라이브 재생**된다.
- 릴리스 PR 체인: **#108**(텍스트 검토·라이브무영향) → **#109**(오디오 8문서 재합성·라이브 노출) → **#110**(develop→main 릴리스).
- **청취 게이트는 사용자가 면제 승인**(청취 생략 릴리스 결정). 자동화 불가한 사람 단계였음.

### 🔴 착수 시 발견한 핸드오프 전제 오류 (중요 교훈)

원래 핸드오프 §0은 *"텍스트(대본)는 고쳤으나 음성 재합성이 미완"*이라고 요약했으나 **이는 부정확했다**:

- `b618d4a`(대본 전수검토)는 **텍스트 품질 결함만** 고쳤다(조사 오류·오타·생성기 아티팩트).
- **Phase A 사실 정정(묶음 A/B/C·배치A)은 낭독 대본에 전파되지 않은** 상태였다. 즉 "대본은 이미 고쳐졌다"는 전제가 틀렸고, 재합성은 기계적 작업이 아니라 **사실 정정을 강의체로 저작하는 콘텐츠 작업**이었다.
- 반면 `ROADMAP.md` A-1의 "오디오 대본 정정 주의"는 재합성+청취 재승인 필요를 **정확히** 명시하고 있었다(핸드오프 요약만 오류).
- **교훈**: "대본 정정 완료"와 "사실 전파 완료"는 다르다. 재합성 전 반드시 *현재 script.json 낭독 텍스트 vs 현재 md 사실*을 직접 대조할 것.

---

## 1. 실제 처리 내역 (8문서)

| 문서 | 세그먼트 | 저작한 정정 | 처리 |
|---|---|---|---|
| t2-1 | seg009 | 서버리스 정의 확장(Fargate·S3·DynamoDB·SQS 포함) | 재합성 |
| t2-3 | seg023·056 | "Support 플랜 변경=루트 전용" → 2022년 이후 IAM 가능, 목록서 제외 | 재합성 |
| t3-4 | seg025 | 서버리스 "트래픽 없으면 비용 0" → 요청비용 0이나 스토리지 비용 계속 | 재합성 |
| t3-6 | seg009·030 | 11나인스 비유 정밀화(1만 년) + EBS 종료 시 루트볼륨 기본삭제 | 재합성 |
| t3-8 | seg016·034 | SNS 재시도·DLQ 존재 + 고객지원(Customer Enablement)·Activate | 재합성 |
| t4-1 | seg012·023·025 | SP 66~72%(Compute/EC2 Instance SP 분리) + Glacier 클래스별 복원시간 | 재합성 |
| t4-3 | seg009 | 컴플라이언스 정의(파일럿 후 seg009 미반영분) + PR#107 정합 | 재합성 |
| t3-3 | — | scale up/down→out/in: **낭독에 없어 음성 무변경** | sourceHash refresh만 |

- **t3-3**은 정정 대상이었으나 해당 용어가 낭독 대본에 등장하지 않았고(낭독은 "인스턴스 대수 증감"으로 이미 정확), gate PASS(hard 0)로 정합 확인 → 재합성·재청취 불필요, stale sourceHash만 refresh하고 approved 유지.

---

## 2. 커밋·PR 체인

- `32f55f5` t4-3 재재합성 · `feced87` AR-2 6문서 재합성 · `4327df4` t3-3 refresh · `cb909a8` 7문서 approved flip
- PR **#108**(fix/2026-07-clf-script-text-review → develop) · PR **#109**(fix/2026-07-clf-audio-resynth → develop) · PR **#110**(develop → main 릴리스)
- 검증: 6→7문서 gate PASS(hard 0) · `flutter test` 782 그린 · `flutter analyze` 0 · 동기화 테스트(audioApproved↔reviewStatus) 통과 · CI Deploy success.

---

## 3. 확립된 재합성 절차 ★향후 오디오 작업 참조

정정 대상 세그먼트만 손대는 **부분 정정 + 전체 재합성** 워크플로. 도구 `flutter_app/tool/gen_lecture_audio.py`(서브커맨드 `--help`가 정답).

1. **대상 판별**: 현재 script.json 낭독 텍스트(`_spoken_body` 우선순위 enriched → scriptText → audioSummary)를 현재 md 사실과 직접 대조. 낭독에 없으면 재합성 불요(t3-3처럼 sourceHash refresh만).
2. **대본 저작**: 대상 세그먼트의 낭독 필드를 강의체로 정정(포맷·CRLF 보존 위해 raw 문자열 치환 권장).
3. **sourceHash 갱신**: `read_text(utf-8)` 방식(CRLF→LF 정규화) 해시를 script.json `sourceHash`에, `reviewStatus`를 `needs_human_review`로.
   - `py -c "import hashlib; print(hashlib.sha256(open('<md>',encoding='utf-8').read().encode('utf-8')).hexdigest())"`
   - ❌ `open(...,'rb')` raw 바이트 금지(CRLF로 gate stale hard fail).
   - 참고: `synthesize`는 audio_meta의 `source.sha256`를 **md 파일에서 직접 재계산**하고 reviewStatus를 `needs_human_review`로 하드코딩한다(`build_audio_meta`). script.json sourceHash는 gate·기록용.
4. **synthesize** `--script --out`(Polly Seoyeon neural, ap-northeast-2, loudnorm -16 LUFS, ID3 strip). 자격증명 `~/.aws`.
5. **chapters** `--script --audio-meta`(⚠️ `--md` 없음).
6. **gate** `--script --md --audio-meta --lexicon` → **hard 0** 필수(sourceHash 불일치는 여기서 hard).
7. **content_index** `flutter_app/lib/data/content_index.dart` 해당 `audioApproved: false`(청취 재승인 전 비노출).
8. **동기화 테스트**: `flutter_app/test/content_index_test.dart` 그린(audioApproved ↔ audio_meta.reviewStatus=approved + mp3 존재; md sha256은 미검사).
9. **청취 승인(사람)**: mp3 청취 후 reviewStatus=approved(script+audio_meta) + audioApproved=true flip → 라이브 노출.

### ❌ 절대 금지
- 이미 강의화된 문서에 `generate`(재생성) 실행 금지(수동 enriched/connector/audioSummary 덮어씀). 부분 정정은 script.json 직접 편집만.
- `.env` 비밀 값 열람 금지(키 이름만).

---

## 4. 참조 파일

- 대본 `flutter_app/assets/audio/clf/clf-<doc>/script.json` · 메타 `audio_meta.json` · 음성 `lecture.mp3` · 원문 `assets/content/clf/<doc>.md`
- 노출 게이트 `flutter_app/lib/data/content_index.dart`(`audioApproved`) · 도구 `flutter_app/tool/gen_lecture_audio.py`
- 관련 메모리: `full-audit-2026-07`, `clf-audio-text-review-2026-07`, `audio-instructor-script-planned`, `audio-runtime-gate-shipped`
