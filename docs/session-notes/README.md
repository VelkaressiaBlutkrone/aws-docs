# 세션 노트 아카이브

2026-10-16 ~ 2026-10-31에 여러 Claude 세션이 **레포 바깥**(`%APPDATA%\Claude\side-session-notes\local_<세션ID>\`)에 남긴 작업 노트를 모아 둔 곳이다.

## 왜 여기로 옮겼나

그 폴더는 **세션 가족 ID로 이름이 붙어** 있어 다른 세션에서는 열리지 않는다. 실제로 2026-11-01에 새 세션이 핸드오버 노트를 찾지 못했다. 레포에 두면 경로 하나로 어디서든 열린다.

## 이 문서들의 성격

**작업 당시의 원본 기록이고, 큐레이션된 레포 문서가 아니다.** 원본 그대로 옮겼다(md5 대조로 바이트 동일 확인). 그래서:

- **내용이 낡았을 수 있다.** 일부 노트는 스스로 "⛔ 이 노트는 끝났다 — 레포 문서를 보라"고 적고 있다.
- **지금 사실의 정본이 아니다.** 현재 상태는 `CLAUDE.md`(기준선·게이트), `docs/content-research/<자격증>/`(조사 산출물), `docs/saa-review/`(검수 기록)를 본다.
- 날짜 접두는 **파일 수정 시각**이고, 이미 날짜가 있던 파일명은 그대로 뒀다.

## 목록

### 외부 검수 보고 (정본 보관)

| 문서 | 내용 |
|---|---|
| `2026-10-27-saa-c03-question-review.md` | SAA-C03 문항 검수 보고 전문 |
| `2026-10-27-mla-c01-second-review.md` | MLA-C01 2차 검수 보고 전문 |

검수 보고는 붙여넣기로만 들어와 전사에만 남으므로 전문을 보관한다. 반영 결과는 `docs/saa-review/`와 각 PR에 있다.

### DEA-C01 원자료 조사 (2026-10-17 ~ 10-19)

`2026-10-17-dea-c01_research-brief.md`(서브에이전트 공통 브리프) · `2026-10-19-dea-c01_controller-state.md`(컨트롤러 상태) · `2026-10-19-dea-gaps-*.md`(Task별 gap 11편)

gap 노트는 `docs/content-research/DEA-C01/tasks/*.md`를 대상으로 하고, 정리된 결과는 같은 폴더의 `99-gaps.md`에 있다.

### DEA-C01 콘텐츠 출고 (2026-10-20)

`2026-10-20-dea-domain2-handover.md` · `dea-domain3-handover.md` · `dea-domain4-done.md`

### SAA·SOA 검수·정정 (2026-10-20)

`saa-t1-5-step1-verdicts.md` · `saa-t1-5-done.md` · `saa-propagation-step1-verdicts.md` · `saa-propagation-done.md` · `saa-aurora-naming-done.md` · `t3-9-q11-snow.md` · `saa-soa-gaps-step1-inventory.md`

### SOA-C03

`2026-10-19-soa-c03-research-notes.md`(원자료 수집 진행 노트) · `2026-10-20-soa-v11-topics-mapping.md`(v1.1 신규 주제 매핑)

### MLA-C01 (2026-10-26)

`mla-c01-recipe-notes.md`(콘텐츠 레시피 함정) · `mla-c01-d2-notes.md` · `mla-c01-d3-notes.md` · `2026-10-27-mla-question-fix-handoff.md`

### 그 외

`2026-10-30-design-decisions-analysis.md` — 2026-09-22 리뷰 디자인 결정 4건의 읽기 전용 실측 분석(반영은 PR #294).

## 여기 없는 것

같은 폴더에 있었지만 **다른 프로젝트**(TlToybox 4편 · CTAToybox 1편)의 노트는 옮기지 않았다. 그 문서들은 원래 위치에 그대로 있다.

flip 트랙 인수인계는 이 폴더가 아니라 `docs/saa-review/2026-10-31-soa-flip-handover.md`에 있다.
