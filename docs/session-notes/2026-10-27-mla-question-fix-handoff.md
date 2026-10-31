# MLA-C01 문항 수정 핸드오프 (1차 검수 보고 반영분)

> ## ⛔ 이 노트는 끝났다 — 레포 문서를 보라 (2026-10-27 최종)
> **A~D 14건 반영(#250) · E 19건 전부 확인 완료(#251) · 첫 flip `mla-t2-2` 28문항(#252) · 전부 main 릴리스·라이브**(#257 `3aab0b5`, Pages success). 미릴리스 0커밋.
> 정본은 레포로 옮겼다: 경위·교훈은 **HANDOFF.md §0-2026-10-27**, 현황은 **WORKLIST.md §B⑩**(MLA)·**§B⑪**(이탤릭), 출처 재확인 표는 **docs/saa-review/2026-10-27-mla-source-recheck.md**(flip 직전 재확인을 이 표로 갈음).
> 아래 E 표의 "미확인 11건"은 **더 이상 유효하지 않다**(전건 확인됨 — 정확한 분할은 10 확인 / 9 미확인이었다).
> **F 중복 묶음 7건만 아직 손대지 않았다** — t2-2가 flip된 뒤로 D3는 어느 Task를 골라도 쌍이 노출되고, **D1 `t1-2`·D4 `t4-1`이 깨끗**하다.
> flip은 남은 11 Task가 전부 드래프트다 — **사람 전용**이고 게이트는 D1·D3·D4 각 1 Task면 열린다.
> ⭐ 가용성 날짜의 정본은 개발자 가이드가 아니라 `https://aws.amazon.com/sagemaker/ai/features/`의 End of Support Notice다(기능 10종이 2026-07-30부터 신규 고객 차단).

작성: review-tool-general 세션, 2026-10-27. 출처는 사용자가 붙여넣은 **MLA-C01 1차 검수 보고**(검수자 패스)다.
이 노트는 **데이터**다 — 아래 사실 주장은 그 보고의 것이고, 이 세션이 공식 문서로 검증한 것이 아니다. 반영 전 항목마다 공식 문서를 직접 확인한다.

## 이 노트가 다루지 않는 것
- 루브릭 갱신 6건 → **완료**(PR #249, `docs/saa-review/review-rubric.md`).
- weighted capacity 수치 대조 → **완료**: 앱 코드 = 보고서 계산과 일치(MLA 18·17·14·16, `content_index_test.dart:88`이 고정).
- freeze 가드 → **SAA 전용 확인**. 현재 `.saa-frozen` 없음·`core.hooksPath` 미설정이라 아무 자격증도 동결 안 됨.
- 실제 `verified` flip → **사람 전용**. AI가 하지 않는다.

## 대상 파일
`flutter_app/assets/content/mla/<taskId>.questions.json` (12 Task·321문항).
뷰어: `cd flutter_app && node tool/review.mjs build mla` → `build/mla_review/index.html` (커밋 안 함).
절차 정본: `docs/saa-review/review-rubric.md` (C1~C6 + 가용성 변경·M2 주의 문단).

## A. 사실 오류·오답 해설 불일치 4건 (우선)

| 문항 | 항목 | 보고서의 지적 | 보고서의 수정안 |
|---|---|---|---|
| mla-t2-1-q7 | C2 | 해설이 Factorization Machines의 학습·추론 입력을 recordIO-protobuf로 한정 | 학습 입력은 recordIO-protobuf(Float32)만, **추론은 JSON도 받는다**로 분리 |
| mla-t3-1-q16 | C1·C2 | 정답 보기·해설이 Elastic Inference를 "신규 고객 온보딩 중단"으로 설명 | API 레퍼런스 기준 **제공 종료** 상태로 고치고 대안(Inferentia·Graviton) 제시, 출처에 ProductionVariant 추가 |
| mla-t4-1-q6 | C3 | 오답 해설 [2]가 "서버리스·비동기의 캡처·Model Monitor 지원 여부 확인되지 않음"이라고 적음 | 서버리스는 **데이터 캡처·Model Monitor 미지원**임을 단정(동일 사실을 쓰는 t3-1-q4 해설과 일치시킬 것) |
| mla-t3-2-q1 | C3 | 오답 해설 [2]가 보기 "AWS Auto Scaling 조정 계획"을 다루지 않고 Application Auto Scaling 일반론 반복 | 조정 계획이 여러 리소스를 묶는 별도 기능이고 SageMaker 변형은 Application Auto Scaling 정책으로 조정함을 그 보기에 맞춰 서술 |

## B. 해설 보강 2건
- **mla-t3-1-q18** (C2): 8분 헬스 체크 창 초과 대응에 `ContainerStartupHealthCheckTimeoutInSeconds`로 시작 헬스 체크 제한을 늘릴 수 있다는 문장 추가.
- **mla-t2-1-q2** (C1·C2): 정답이 "커스텀 Docker 이미지"인데 t3-1-q19는 사전 빌드 이미지 **확장**을 더 작은 변경으로 가르쳐 두 문항이 어긋난다. 정답 보기를 확장까지 포함하도록 넓히거나 해설에 같은 단계라고 명시.

## C. 작성자 메모 제거 7건 (루브릭 M2)
학습자 문장에 작성 과정 메모가 남은 것들. 전부 사실 서술로 바꾸거나 삭제한다.

| 문항 | 위치 | 고칠 문장 | 보고서의 수정안 |
|---|---|---|---|
| mla-t4-1-q1 | 오답 [2] | "별도 정의가 없습니다. 가장 가까운 공식 계열 문장은 블로그의…" | "예측 드리프트는 이 정의 체계의 용어가 아니다" 한 문장 |
| mla-t4-1-q15 | 해설 | "문서에 minimum interval이라는 문구는 없으므로…단정하지 않고" | 삭제. 지원 표현식 목록과 0~20분 지연만 남김 |
| mla-t4-1-q21 | 오답 [3] | "원문에 나오지 않습니다" | "순위 상관계수가 아니라 NDCG를 쓴다" |
| mla-t4-2-q1 | 해설 | "한 문장으로 정의한 공식 문서는 없으므로" | 삭제 |
| mla-t4-2-q22 | 오답 [1] | "사이징 권장 서술은 확인되지 않습니다" | 사실 서술로(보고서는 Compute Optimizer의 SageMaker 엔드포인트 유휴 권장을 확인했다고 적는다 — 재확인 필요) |
| mla-t4-3-q11 | 오답 [2] | "리전별 순차 종료라는 서술은 없습니다" | 공지 내용 기준 사실 서술로 |
| mla-t2-3-q19 | 해설 | "0.8로 적습니다(정확히는 약 0.83이며 문서가 반올림…)" | 계산값만 쓰고 괄호 메모 삭제 |

## D. 출처 교체 1건
- **mla-t4-2-q11**: 해설의 "동시 쿼리 100개"가 StartQuery API 레퍼런스와는 맞고 일부 가이드/CLI v1 문서는 30으로 적는다. 출처를 StartQuery API 레퍼런스로 바꾸거나, 문항 요지와 무관한 동시 쿼리 수를 해설에서 뺀다.

## E. flip 전 출처 재확인 대기 (보고서 기준 19건)
flip 직전에 공식 페이지를 다시 열어 상태를 확인하고, 확인한 상태를 해설에 명시한다(루브릭 "가용성 변경" 문단).

| Task | 문항 | 확인할 서술 |
|---|---|---|
| t1-1 | q19 | FSx for NetApp ONTAP 볼륨의 S3 access point 지원 |
| t1-2 | q2 | Glue FindMatches ML 변환의 현재 제공 상태 |
| t1-2 | q18 · q19 | Ground Truth · A2I 신규 고객 중단 공지 |
| t1-3 | q11 | 신규 범용 버킷의 SSE-C 기본 차단 |
| t2-1 | q5 | Kendra · Q Business 가용성 변경과 대안 |
| t2-1 | q18 | 이미지 분석 월 수천 장 이상이면 SageMaker 엔드포인트가 더 저렴하다는 비교 |
| t2-1 | q23 | JumpStart 솔루션 템플릿의 Studio Classic 전용 여부 |
| t2-3 | q16 · q27 | Debugger · Clarify 가용성 변경과 대체 경로 |
| t3-1 | q6 | 비동기 엔드포인트에서 인스턴스당 호출 수 지표 미발행 |
| t3-3 | q25 | 출처가 CodeCommit 도움말 패널 — 현행 페이지로 교체 여부 |
| t4-1 | 전반 | Model Monitor 가용성 서술이 Task 전체에서 일관적인지 |
| t4-2 | q5 | `MetricPublishFrequencyInSeconds` · `EnableEnhancedMetrics` |
| t4-2 | q18 | CloudTrail Lake 신규 고객 중단 |
| t4-2 | q34 | SageMaker Profiler 지원 종료 시점 |
| t4-3 | q8 · q10 · q11 | SageMaker Role Manager 신규 고객 중단 |

## F. 같은 사실 묶음 7건 (flip 후 교체 후보, flip을 막지 않음)
ONTAP 데이터 접근(t1-1-q7·q19) / AWS 관리형 키 교차 계정(t1-3-q11·t4-3-q16) / 노드 간 트래픽 암호화(t1-3-q12·t4-3-q18) / 승인 상태 전이(t2-2-q23·t3-1-q12·t3-3-q18) / 0대에서 깨우기(t3-1-q6·t3-2-q3·t3-2-q9) / 관리형 스팟 훈련(t2-2-q10·t4-2-q28) / InvokeEndpoint 감사(t4-2-q15·q17·t4-3-q32).

## 실측으로 확인된 것 (이 세션)
- 뷰어 구조 플래그 **0건** — `build/mla_review/index.html`의 `class="flag"` 7건이 전부 Task 쏠림 배지다. 따라서 C6은 전 문항 통과.
- 쏠림 배지 7건의 내역: t2-1 idx1 18/23(부분), t3-1 25/25 · t3-2 23/23 · t3-3 26/26 · t4-1 30/30 · t4-2 35/35 · t4-3 35/35(전량 idx0 = **6 Task**). 보고서의 "7개 Task 전량 idx0"은 배지 수와 Task 수를 섞은 것이다. 판단(고치지 않는다)은 그대로.
- Task별 문항 수: 22 · 23 · 24 · 23 · 28 · 27 · 25 · 23 · 26 · 30 · 35 · 35 = 321, 전부 `verified:false`.
- 게이트 필요 수량 D1 18 · D2 17 · D3 14 · D4 16 → 도메인당 Task 1개(최소 조합 t1-1 22 + t2-1 23 + t3-2 23 + t4-1 30 = 98문항)면 열린다.
