# SOA-C03 원자료 수집 — 진행 노트 (res-soa 세션, 2026-10-17)

> 최종 산출물 위치: `D:/workspace/awc-docs/docs/content-research/SOA-C03/` (00 / 97 / 98 / 99 / tasks/*.md). 이 노트는 진행 중 핵심 발견만 적는다. 상세·근거 URL은 산출물 참조.

## 이미 확정된 핵심 발견 (2026-10-17 실측)
1. **v1.0→v1.1 공식 변경은 Skill 10건**(감사 GUIDE-001의 "11건"은 오기). 근거: https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html
   변경 Skill: 1.1.1 · 1.2.1 · 1.3.4 · 2.3.4 · 3.1.2 · 3.2.2 · 4.1.3 · 4.1.5 · 4.2.5 · 5.1.2. Skill 총 53개·Task 13개·도메인 5개(22/22/22/16/18) 불변. 시험 형식(65문항=채점 50+비채점 15, 130분, 합격선 720) 불변.
2. **v1.0 원문 기준선**: 공식 PDF 가이드(Wayback 2025-09-10/2025-12-01 캡처, 본문 동일)와 v1.1 docs 페이지를 53 Skill 전수 기계 비교 → 공식 표 10건 외 실질 변경 없음. EN 표기만 바뀐 것(서비스 짧은 이름): 1.1.2·1.1.5·1.3.2·1.3.5·2.1.2·4.1.1·4.2.2. KO는 레포 JSON(v1.0)과 v1.1 공식 KO가 30건 다름(공식 변경 10 + 표기 20) → JSON 재동기화 대상.
3. **공식 PDF 가이드는 v1.1 미반영(stale)**: d1.awsstatic.com PDF(Last-Modified 2026-09-01)의 본문은 v1.0 문구인데 푸터는 "Version 1.1". 2025-09-10 캡처에서도 동일 푸터 → PDF 자체 번호일 뿐 docs 사이트 v1.1과 무관. 정본은 docs 사이트(HTML).
4. **한국어 시험 종료 예정**: 공식 자격증 페이지 "The AWS Certified CloudOps Engineer - Associate exam in Simplified Chinese and Korean will be retired after November 19, 2026." (조회 2026-10-17). 한국어로 응시하려면 2026-11-19 이전.
5. in-scope +5(Amazon Bedrock·AWS DevOps Agent·AWS Health Dashboard·Kiro·AWS Security Agent), out-of-scope −6(AppStream 2.0·A2I·AppSync·Cloud Directory·Kendra·Q Developer). 단 AppStream 2.0은 새 이름 「Amazon WorkSpaces applications」로 out-of-scope에 여전히 있음(공식 Revisions 표엔 '제거'로만 표기). Q Developer는 2027-04-30 지원 종료 예정(Kiro로 이전).
6. 앱 쪽: `flutter_app/lib/data/site_data.dart:72`는 이미 'AWS Certified CloudOps Engineer - Associate' 표기 → 감사 GUIDE-002는 앱에서는 해소 상태(읽기 확인).

## 최종 상태 (2026-10-19 갱신 — 연구 작업 완료, 정지)
산출물 전부 `D:/workspace/awc-docs/docs/content-research/SOA-C03/` 아래에만 있다: `00-overview.md` · `97-guide-v11-diff.md` · `98-existing-gap.md` · `99-gaps.md` · `tasks/1-1.md … 5-3.md`(13개). 중간 산출물(스크립트·다운로드·조각)은 세션 scratchpad에만 있고 레포에는 없다.

| 항목 | 결과 |
|---|---|
| 공식 Task 커버 | **13 / 13** (Skill 53개 전부 Task 파일 §1에 원문 수록) — 파일당 사실 행 29~30개, 자가점검 문항 후보 5개(총 65) |
| v1.0→v1.1 차이 (97) | 공식 Skill 변경 **10건** + EN 표기만 변경 7건 + KO가 JSON과 다른 표기 정비 20건 + in-scope 추가 5 + out-of-scope 제거 6(+1) |
| 기존 문서 차이 (98) | 문서 주장 대조 **312건**(오류확정 7 · 구식 36 · 의심 48 · 확인필요 62 · 문제없음 159) · v1.1 항목 반영 점검 94 · 검수대기 수치 재대조 24 · Skill 커버 충분 1/부분 45/없음 7 · URL 110개 전부 200(이동 7) |
| 상충·불확실·확인필요 (99) | **140건**(상충 22 · 불확실 26 · 확인필요 12 · 범위해석 47 · JSON제안 11 · 기타 22 / 미해결 115 · 해결 22 · 제안 3) + `SOA-C03.json` 30줄 패치표 |
| 기계 검증 | (URL, 인용) 1,066쌍 전부 OK·NOT-FOUND 0·FETCH-FAIL 0·15단어 초과 0 / Task 파일 구조 검사 13개 이슈 0 |
| 금지 준수 | git·flutter 명령 0회, 레포 쓰기는 위 폴더뿐(비-git 수정시각 점검: 세션 중 폴더 밖 변경 없음), 기존 학습문서·JSON·앱 코드 무수정 |

## 사람이 바로 알아야 할 것 (자세히는 `99-gaps.md` §1)
1. **한국어 시험은 2026-11-19 이후 종료** — 한국어 응시 계획이면 일정 결정 필요(G-01).
2. 공식 PDF 가이드는 v1.0 문구 그대로(stale) — 정본은 docs 사이트 HTML(G-02). 감사 GUIDE-001 "11건"은 10건이 맞다(G-03).
3. 기존 학습문서 즉시 결함: 말미 `</content>`/`</invoke>` 잔재 8개 파일(G-15), 공식과 어긋난 서술 7건, 이동·소멸한 출처 URL 7건(98 §5·§7).
4. `SOA-C03.json`은 아직 v1.0 문구 — 갱신안은 99 §4(정확한 JSON 경로·줄 번호 포함). 콘솔·계정으로만 확인되는 항목 10개는 99 §1.1.
5. 문항(`verified:true`)은 여전히 0 — AI는 승격하지 않는다. Task 파일 §6의 후보 65개는 사람 검수 후에만 사용.

## 운영 교훈 (부모 세션이 필요하면 메모리로 승격)
- 2026-10-17에 병렬 에이전트 7개를 동시에 돌리다 **계정 전체 사용 한도**에 걸려 전원이 끊겼다. 재개 때는 좁은 범위의 에이전트 4개로 쪼개 쓰고, 조각을 디스크에 즉시 저장해 중간 소실을 막았다. 이후 시험(SAA/DVA/DEA/MLA 포함)도 동시 에이전트 수를 3~4개로 제한하는 편이 안전하다.
- 에이전트 보고만 믿지 않고 컨트롤러가 직접 돌린 검증(구조 검사 + (URL, 인용) 기계 대조)이 가장 많은 오류(검색 도구 요약문의 의역 인용, 한글 인용 오탐, 끊긴 `[C##]` 참조)를 잡았다. 스크립트는 세션 scratchpad에만 있어 세션이 끝나면 사라진다.
