# 설계: 학습 오디오 런타임 노출 게이트 + audio_lecture 활성화

- 날짜: 2026-06-26
- 상태: 설계 승인됨(brainstorming) → 구현 계획(writing-plans) 대기
- 범위: 후속 마일스톤 ①(런타임 reviewStatus 게이트) + ②(audio_lecture 활성화). ③음질·④환각가드는 별도 spec.

## 배경

학습 문서 오디오 강의(주머니 라디오)의 콘텐츠 검수(M2)가 완료되어 CLF 19문서가 `reviewStatus=approved`로 repo에 등록·배포됨(PR #62·#63). 그러나 **런타임은 `reviewStatus`를 전혀 읽지 않고**, `audioLectureEnabled = bool.fromEnvironment('audio_lecture')`(기본 false) 빌드 플래그 하나로 전체 on/off만 한다. 현재 미니플레이어는 `study_doc_page._miniPlayer`에서 `audioLectureEnabled && doc != null && runtime != null`로만 게이트되어, 플래그를 켜면 approved 여부와 무관하게 전체 노출된다.

목표: **approved된 문서만 노출**하는 런타임 게이트를 도입하고, 프로덕션에서 기능을 활성화한다.

## 결정사항 (brainstorming)

1. **reviewStatus 판정 = (A) 정적 필드 + 동기화 테스트.** `ContentEntry`에 `audioApproved` 필드를 두고 빌드 타임에 확정한다(런타임 fetch 없음). SSOT(`audio_meta.json`의 `reviewStatus`)와 일치하는지 동기화 테스트로 가드한다 — 이 repo의 verified 문항 게이트 패턴 재사용.
2. **플래그 정책 = (가) 마스터 유지 + CI 활성화.** `audio_lecture`는 전체 기능 마스터(긴급 끄기·점진 롤아웃)로 남기고, `pages.yml` 빌드에 `--dart-define=audio_lecture=true`를 추가해 프로덕션 활성화한다. 게이트는 마스터 AND 문서별 이중 안전.
3. **동기화 SSOT = `audio_meta.json`.** `script.json`도 `reviewStatus`를 갖지만, mp3 메타인 `audio_meta.json`(top-level + script 둘 다 approved)을 출처로 본다.

## 게이트 규칙 (단일)

`study_doc_page`의 `_miniPlayer`와 `_onDocReady`(nowPlaying)에 동일 적용:

```
audioLectureEnabled && entry.audioApproved && doc != null && runtime != null
```

| 조건 | 의미 | 역할 |
|---|---|---|
| `audioLectureEnabled` | `--dart-define=audio_lecture` | 전체 마스터(긴급 끄기·롤아웃) |
| `entry.audioApproved` | 정적 필드(신규) | 문서별 approved 게이트 |
| `runtime != null` | web 전용 | VM/test 미노출(기존) |
| `doc != null` | 문서 로드 완료 | 기존 |

## 컴포넌트

1. **`lib/data/content_index.dart`**
   - `ContentEntry`에 `audioApproved`(기본 `false`) 필드 추가.
   - CLF 19개 엔트리(`clf-t1-1`~`clf-t4-3`)에 `audioApproved: true` 등록. 그 외 cert(SAA·SOA 등)는 기본 false.
   - `lectureAudioSrc` 주석의 "placeholder(실제 mp3·메타는 T6·T9)" 문구를 실제 등록 상태로 갱신.
2. **`lib/pages/study_doc_page.dart`**
   - `_miniPlayer`(99행 근처)와 `_onDocReady`(68행 근처) 게이트에 `&& widget.entry.audioApproved` 추가.
   - 게이트 불리언을 순수 함수/getter로 분리해 단위 테스트 가능하게 한다(위젯 렌더 회피, 아래 테스트 참조).
3. **`.github/workflows/pages.yml`**
   - `flutter build web` 스텝에 `--dart-define=audio_lecture=true` 추가(프로덕션 활성화).

## 동기화 테스트 (핵심 안전장치)

데이터 테스트로 빌드 전에 불일치를 차단한다(verified 문항 동기화 패턴 재사용):

- **정방향:** `audioApproved=true`인 모든 `ContentEntry` ↔ `assets/audio/<family>/<taskId>/audio_meta.json`의 `reviewStatus == "approved"` 일치.
- **자산 존재:** 해당 `lecture.mp3`가 실제로 존재(404 방지).
- **역방향(누락 방지):** `audio_meta.json`이 approved인데 `audioApproved=false`면 실패(노출 누락 경보).

불일치 시 `flutter test`가 실패 → 잘못된 노출·404 빌드를 막는다.

## 에러·엣지

- `audioApproved=true`인데 meta 비-approved 또는 mp3 없음 → 동기화 테스트가 차단.
- web 아님(VM/test) → `runtime == null`, 미노출(기존 동작 유지).
- `audio_lecture` off(개발 기본) → 전체 미노출(기존).

## 테스트 전략 (TDD — 절대조건 2)

- **동기화 테스트**(데이터, `test/` 신규): 위 정/역방향 + 자산 존재. 실패 테스트 먼저 작성.
- **게이트 로직 단위 테스트**: 게이트 불리언을 순수 함수로 분리해 `audioApproved=false`→미노출 등 진리표 검증. `study_doc_page`를 위젯 렌더하면 `SelectionArea`+비동기 페이지가 "RenderBox was not laid out"로 크래시하므로(메모리 [[flutter-selectionarea-widget-test-pitfall]]) **위젯 렌더 대신 로직 분리 단위 테스트**로 검증.
- 게이트: `flutter test` 전부 통과, `flutter analyze` 신규 0(기존 잔존 3건).

## 라이브 영향

배포 시(`audio_lecture=true`) CLF 19문서에 미니플레이어가 **실제 사용자에게 노출**된다(현재 0 → 활성화). 이것이 ②활성화의 본질이다. develop→main 릴리스로 반영되며, CI(pages.yml)가 web build + 배포를 수행한다.

## 비목표 (별도 spec)

- ③ 음질(PCM·loudness 정규화) — Python 도구(`gen_lecture_audio.py`) 영역.
- ④ 환각 가드(TTS 대본 원문 왜곡 자동 검출) — 검수 도구 영역.
- 런타임 `audio_meta.json` 동적 fetch(옵션 B/C) — 본 설계는 정적 필드(A) 채택.

## 정본·관련

- 콘텐츠 검수 파이프라인: `docs/superpowers/specs/2026-06-23-content-review-pipeline-design.md`
- 청취 검수 가이드: `docs/audio-content-review-guide.md`
- M1 핸드오프: `docs/superpowers/specs/2026-06-21-study-audio-m1-handoff.md`
