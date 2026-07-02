# ⑦ 의존성 감사 샤드 — 07-deps — 2026-07

## 요약
- SDK: Flutter 3.44.1 / Dart 3.12.1 (pubspec 제약 `sdk: ^3.10.8`, lock `dart >=3.10.8 <4.0.0`, `flutter >=3.29.0`). `flutter pub outdated` 정상 완료(2분 내).
- 직접 의존성 6개 중 4개가 밀림: **패치/마이너 3개**(firebase_core 4.10.0→4.11.0, firebase_auth 6.5.2→6.5.4, cloud_firestore 6.5.0→6.6.0) + **메이저 1개**(go_router 16.3.0→17.3.0). cupertino_icons·web은 사실상 현행(패치 lock 여유만).
- **Flutter SDK 자체 업그레이드 후보 없음** — 현재 SDK가 모든 최신 패키지 요구(최고 요구는 go_router 17.3.0의 Flutter 3.38/Dart 3.10)를 이미 충족. SDK 교체 불요.
- discontinued/retracted/보안 취약점 표시 **없음**(outdated 출력 기준) → Phase A 승격 항목 0건.
- **최우선(그래도 Phase B)**: go_router 16→17 메이저. 단, 이 앱은 hash 라우팅 기본·`redirect:` 콜백·`ShellRoute` 미사용이라 17.x 유일 BREAKING(ShellRoute observer 알림)의 영향 반경이 0으로 확인됨. 안정성 우선 원칙에 따라 전 항목 **시험 후(Phase B)** 배치.

## 의존성 현황
| 패키지 | 현재 | 최신 | 분류 | 비고 |
|---|---|---|---|---|
| go_router | 16.3.0 | 17.3.0 | **메이저** | 유일 메이저 밀림. 17.0.0 BREAKING=ShellRoute observer 알림(본 앱 ShellRoute 미사용→무영향). URL 전략/redirect 시그니처/GoRouter 생성자 변경 없음(changelog 확인). |
| firebase_core | 4.10.0 | 4.11.0 | 마이너 | Firebase 트리오 상호 호환(아래) |
| firebase_auth | 6.5.2 | 6.5.4 | 패치 | |
| cloud_firestore | 6.5.0 | 6.6.0 | 마이너 | |
| cupertino_icons | 1.0.9 | 1.0.9 | — | 현행(pubspec `^1.0.8`) |
| web | 1.1.1 | 1.1.1 | — | 현행(pubspec `^1.1.0`) |
| flutter_lints (dev) | 6.0.0 | 6.0.0 | — | dev 전부 현행 |
| _flutterfire_internals (T) | 1.3.72 | 1.3.73 | 패치 | Firebase 트리오 동반 |
| cloud_firestore_platform_interface (T) | 8.0.2 | 8.0.3 | 패치 | |
| cloud_firestore_web (T) | 5.5.0 | 5.6.0 | 마이너 | |
| firebase_auth_platform_interface (T) | 9.0.2 | 9.0.3 | 패치 | |
| firebase_auth_web (T) | 6.2.2 | 6.2.3 | 패치 | |
| firebase_core_platform_interface (T) | 7.0.1 | 7.1.0 | 마이너 | |
| firebase_core_web (T) | 3.8.0 | 3.9.0 | 마이너 | |
| matcher (T) | 0.12.19 | 0.12.20 | 패치 | SDK 고정(flutter_test 경유), 수동 불가 |
| meta (T) | 1.18.0 | 1.18.3 | 패치 | SDK 고정 |
| test_api (T) | 0.7.11 | 0.7.13 | 패치 | SDK 고정 |
| vector_math (T) | 2.2.0 | 2.4.0 | 마이너 | SDK 고정 |

(T)=transitive. matcher/meta/test_api/vector_math는 Flutter SDK가 핀 고정 → 개별 업그레이드 불가(SDK 갱신 시에만 이동, 현재 밀림은 정상).

## 점검 항목 결과
- **1. 업그레이드 분류**: (a) 패치/마이너 호환 = firebase_core·firebase_auth·cloud_firestore(+ Firebase 계열 transitive 7개). (b) 메이저 = go_router 16.3.0→17.3.0 단 1건. (c) Flutter SDK 자체 업그레이드 = **불요**(현 SDK가 모든 최신 요구 충족). SDK 핀 고정 transitive(matcher/meta/test_api/vector_math)는 어느 그룹에도 수동 배치 불가.
- **2. go_router 16→17 특별 점검**: 웹 changelog(pub.dev) + GitHub 원문 CHANGELOG 교차 확인. 17.x 유일 BREAKING은 17.0.0 "ShellRoute's navigating changes notify GoRouter's observers by default" + `notifyRootObserver` 신규 파라미터 — **ShellRoute 전용**. 본 앱(app_router.dart)은 단일 `GoRouter(...)`에 `GoRoute`만 사용, **ShellRoute 없음** → 무영향. **hash 라우팅**: `setUrlStrategy`/`usePathUrlStrategy` 미사용(기본 hash, GitHub Pages 딥링크용, app_router.dart:21 주석 확인) — 17.x에 URL 전략 관련 변경 라인 없음 → 영향 없음. **redirect 가드**: 표준 `(context, state) => String?` 콜백 5곳(cert/:code·audio·study·audio hub 등) — 17.x에 redirect 콜백 시그니처/제거 변경 없음(17.2.0은 `Block.then()`/`Allow.then()` 재진입 수정으로, 본 앱 미사용 imperative onExit 계열). GoRouter 생성자 API 변경 없음. 결론: 16→17 브레이킹의 앱 영향 **확인된 범위 내 0건**(단, 실제 승격 시 flutter test 499 그린 회귀 확인 필수).
- **3. Firebase 계열 호환**: firebase_core 4.11.0 / firebase_auth 6.5.4 / cloud_firestore 6.6.0 — outdated에서 세 패키지 모두 `Upgradable == Resolvable == Latest`로 동일 → 상호 버전 제약 충돌 없이 **함께 해석 가능**. 세 패키지 major 라인(core 4.x / auth 6.x / firestore 6.x) 유지, 이번 밀림은 전부 패치/마이너.
- **4. 보안/중단 패키지**: outdated 출력에 discontinued·retracted·취약점 마커 **없음**. 알려진 취약점 표기 없음 → Phase A 승격 근거 없음.

## 발견 항목
| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| DEP-001 | pubspec.yaml:go_router | 16.3.0→17.3.0 메이저 밀림. 유일 BREAKING(ShellRoute observer)은 본 앱 ShellRoute·URL전략·redirect 시그니처 무관 → 영향 반경 확인상 0. | L | 높 | 시험 후 17.3.0 승격 시 flutter test(499 그린)·analyze(신규0)·web build로 회귀 확인. hash 딥링크 실브라우저 dogfood. | B | N |
| DEP-002 | pubspec.yaml:cloud_firestore | 6.5.0→6.6.0 마이너. Firebase 트리오와 함께 해석 가능(Resolvable==Latest). | L | 높 | firebase_core/auth와 묶어 일괄 pub upgrade(시험 후). | B | N |
| DEP-003 | pubspec.yaml:firebase_auth | 6.5.2→6.5.4 패치. 트리오 동반. | L | 높 | DEP-002·004와 일괄 처리. | B | N |
| DEP-004 | pubspec.yaml:firebase_core | 4.10.0→4.11.0 마이너. 트리오 동반. | L | 높 | DEP-002·003과 일괄 처리. | B | N |
| DEP-005 | pubspec.lock:matcher,meta,test_api,vector_math | SDK 핀 고정 transitive 4개가 최신보다 밀림(matcher 0.12.19→.20, meta 1.18.0→.3, test_api 0.7.11→.13, vector_math 2.2.0→2.4.0). 개별 업그레이드 불가 — Flutter SDK 갱신 시에만 이동. | L | 높 | 조치 불요(정상). 향후 Flutter 마이너 업그레이드 시 자동 반영. | B | N |
