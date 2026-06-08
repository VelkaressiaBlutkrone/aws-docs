# 설계: 모바일 햄버거 네비게이션

- **날짜:** 2026-06-08
- **상태:** 승인됨 (/superpowers:brainstorming)
- **범위:** 홈 페이지 헤더(`flutter_app/lib/pages/home_page.dart`의 `_Header`)만. 단일 파일.

## 1. 문제

홈 상단 네비게이션(`_Header`)이 `Row`에 브랜드 + `Spacer` + 5개 nav 링크(단계/추천 순서/로드맵/학습 문서/모의고사) + 테마 토글을 한 줄로 배치한다. 줄바꿈·스크롤이 없어 좁은 화면(모바일)에서 폭을 넘으면 뒤쪽 링크와 테마 토글이 잘려 보이지 않는다.

## 2. 결정 요약

| 항목 | 결정 |
|---|---|
| 메뉴 방식 | 드롭다운(`PopupMenuButton`) — 드로어(슬라이드) 기각. 절제된 에디토리얼 톤·구현 간단 |
| 테마 토글 | 모바일에서도 햄버거 밖에 유지(자주 쓰는 기능) |
| 브레이크포인트 | 가용 폭 **768px** 미만이면 햄버거. `LayoutBuilder` 사용 |

## 3. 설계

### 3.1 브레이크포인트
헤더 폭 측정: 브랜드(~200px) + 5개 한글 링크+간격(~450px) + 테마 토글(~50px) + 좌우 패딩(48px) ≈ 750px에서 오버플로. 안전 여유를 두고 **768px**(태블릿 기준) 미만에서 햄버거로 전환. `_Header.build`에서 `LayoutBuilder`로 `constraints.maxWidth`를 보고 분기한다(헤더 실제 폭 기준 — `MediaQuery`보다 정확).

상수: `_Header` 내부 또는 파일 상단에 `static const _navBreakpoint = 768.0;`

### 3.2 레이아웃 분기 (`_Header.build`)
- **공통(항상)**: `_Brand` → `Spacer` → (분기 영역) → `_ThemeToggle`
- **≥768px**: 기존대로 `...onNav.entries.map(_NavLink)` 나열
- **<768px**: 5개 링크 대신 `_NavMenuButton` 하나. 순서 `[햄버거][테마토글]`

`_ThemeToggle`은 분기 밖에 두어 두 경우 모두 노출. `Spacer`와 `SizedBox(width: Gap.lg)` 간격은 유지.

### 3.3 새 컴포넌트 `_NavMenuButton`
```
class _NavMenuButton extends StatelessWidget {
  const _NavMenuButton({required this.onNav});
  final Map<String, VoidCallback> onNav;
  ...
}
```
- `PopupMenuButton<String>` 사용. 트리거는 `Icons.menu`를 `_ThemeToggle`과 동일한 알약형 컨테이너(`c.surface2` + `Border.all(c.border)` + `Radii.full`, padding 8)로 감싸 시각 통일
- `itemBuilder`: `onNav.keys`를 `PopupMenuItem<String>(value: key, child: Text(key))`로 렌더
- `onSelected: (key) => onNav[key]?.call()`
- 팝업 외형은 테마 토큰 준수: `color: c.surface`, `surfaceTintColor: Colors.transparent`, `shape: RoundedRectangleBorder(side: BorderSide(color: c.border), borderRadius: Radii.md)`. 기본 페이드만(커스텀 모션 없음 — DESIGN.md)
- 항목 텍스트 스타일은 `_NavLink`와 일관(fontSize 14, w600, `c.text`)

### 3.4 데이터 흐름
`_Header`는 이미 `onNav: Map<String, VoidCallback>`를 받는다. 데스크톱 `_NavLink`들과 모바일 `_NavMenuButton`이 **같은 맵을 공유**한다. 새 상태·인자 없음. `HomePage.build`는 무변경.

## 4. 테스트 (`test/home_sections_test.dart`에 추가)

폭 설정은 `tester.view.physicalSize` + `tester.view.devicePixelRatio`로 하고, `addTearDown(tester.view.resetPhysicalSize)` 등으로 복원.

1. **좁은 폭(360px)**: 펌프 후 `find.text('로드맵')` 등 nav 링크 없음 + `find.byIcon(Icons.menu)` 1개
2. **넓은 폭(1200px)**: nav 링크 텍스트 보임 + `Icons.menu` 없음
3. **햄버거 동작**: 좁은 폭에서 `Icons.menu` 탭 → 메뉴 항목('모의고사' 등) 표시 → 항목 탭 → 해당 콜백 호출 확인(스파이 콜백)

## 5. 비범위 (YAGNI)

- 드로어/슬라이드 패널
- 커스텀 애니메이션
- 다른 페이지의 AppBar — 홈 전용 `_Header`만 다단 nav를 가지며, 나머지 페이지는 단순 타이틀 AppBar라 오버플로 없음
- 데스크톱 nav 링크의 디자인 변경(기존 유지)
