// flutter_app/lib/util/legal_links.dart
//
// 개인정보처리방침·계정 삭제 안내의 공개 위치와 표기(A8).
//
// 두 페이지는 `web/privacy.html`·`web/delete-account.html` 의 **정적 HTML**이다.
// Flutter 앱(해시 라우팅·CanvasKit)은 JS 가 꺼진 검토자·크롤러에게 빈 화면이라 정책
// 페이지를 앱 안에 두면 Play 의 「로드 오류 없음」을 보장할 수 없다. `flutter build web`
// 이 `web/` 을 그대로 `build/web/` 에 복사하므로 GitHub Pages 가 같은 경로로 서빙한다.
//
// ⚠️ 이 값들은 Play Console 에 적는 URL·표기와 같아야 한다. 가드:
// `test/legal_pages_test.dart`(index.html canonical · 파일 실재 · 두 페이지 본문).

/// 사이트 루트 — `web/index.html` 의 canonical 과 같다.
const String kSiteBase = 'https://velkaressiablutkrone.github.io/aws-docs/';

/// 개인정보처리방침. Play Console 「앱 콘텐츠 → 개인정보처리방침」에 넣는 URL.
const String kPrivacyPolicyUrl = '${kSiteBase}privacy.html';

/// 계정 삭제 안내. Play Console Data safety 「데이터 삭제 → 웹 링크」에 넣는 URL.
/// ⚠️ Play 는 이 페이지가 **앱을 다시 설치하게 하지 않고** 삭제를 요청하게 하라고
/// 요구한다 — 웹 앱 경로(같은 코드의 계정 삭제)와 이메일 경로를 함께 적는다.
const String kAccountDeletionUrl = '${kSiteBase}delete-account.html';

/// 개인정보 문의·삭제 요청 연락처(공개). 사용자 지정 2026-11-20 —
/// 개인 주소가 아니라 대표 주소를 쓴다(Play 가 예로 드는 「전용 이메일 별칭」).
const String kPrivacyContactEmail = 'info@leva.ai.kr';

/// 운영자(개발자) 표기 — Play 스토어의 개발자 이름과 같아야 한다.
const String kOperatorName = 'leva';

/// 스토어에 보이는 앱 이름 — Android `android:label` 과 같다.
/// ⚠️ 「AWS Docs」는 아마존 공식 문서의 이름이라 Play 사칭 정책에 걸릴 위험이 있다
/// (이름 확정은 로드맵 A0 의 사람 몫). 두 페이지가 「비공식」 고지를 함께 싣는다.
const String kAppDisplayName = 'AWS Docs Roadmap';
