package kr.ai.leva.awsdocs

import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import java.io.File

/**
 * 저장된 앱 테마에 맞춰 **다음 콜드 스타트의 시스템 스플래시 테마**를 지정한다 (A6-4 잔여).
 *
 * 왜 필요한가: 시스템 스플래시 배경은 `values-night/` 리소스 한정자로 **시스템** 다크
 * 모드를 따르는데, 앱은 `ThemePrefStore` 의 **저장값**을 따르고 키가 없으면 라이트다
 * (DESIGN.md: 라이트가 기본). 그래서 「시스템 다크 + 앱 라이트」에서 어두운 스플래시 뒤
 * 밝은 앱이 뜬다 — 2026-11-20 프레임 단위 실측으로 **1,867ms** 동안 `#14181F` 였다.
 *
 * ⚠️⚠️ **이번 실행의 스플래시는 코드로 바꿀 수 없다.** 프로세스가 시작되기 전에
 * WindowManager 가 그린다. 공식 javadoc 이 "overrides and **persists** the theme used for
 * the SplashScreen" 라고 적는 대로 이 호출은 **다음** 콜드 스타트에 적용된다. 그래서
 * 설치 직후 첫 실행 한 번은 여전히 시스템 테마를 따른다(그때는 저장값도 없다).
 *
 * ⚠️ `onPause` 에서도 부르는 이유: 사용자가 앱 안에서 테마를 토글한 **직후**가 어긋남이
 * 가장 눈에 띄는 순간이다. `onCreate` 만 보면 토글 후 첫 재시작이 옛 테마로 뜬다.
 *
 * ⚠️ API 31 미만에는 이 API 가 없다 — 시스템 스플래시 자체가 없고 starting window 는
 * 매니페스트의 `LaunchTheme` 으로 고정되므로 그 버전에서는 잔여가 남는다.
 *
 * ⚠️ `NormalTheme`(`?android:colorBackground`)은 **건드리지 않았다** — 같은 실측에서 30fps
 * 전 프레임을 훑어도 보이지 않는다(시스템 스플래시가 Flutter 첫 프레임까지 유지된다).
 * 보이지 않는 구간을 위해 코드를 넣는 것은 추측으로 고치는 것이다.
 */
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        applySavedSplashTheme()
    }

    override fun onPause() {
        super.onPause()
        applySavedSplashTheme()
    }

    private fun applySavedSplashTheme() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        val themeId =
            if (readSavedDark()) R.style.SplashThemeDark else R.style.SplashThemeLight
        try {
            splashScreen.setSplashScreenTheme(themeId)
        } catch (e: Throwable) {
            // 스플래시 색이 어긋나는 것은 앱을 못 쓰게 만들지 않는다 — 다만 조용히 삼키면
            // 아무도 모르므로 흔적은 남긴다.
            Log.w(TAG, "스플래시 테마를 지정하지 못했다", e)
        }
    }

    /**
     * `ThemePrefStore`(lib/data/theme_pref_store.dart)가 `FileKvBackend`
     * (lib/data/persistent_backend_io.dart)로 쓴 값을 읽는다. 키가 없거나 읽히지 않으면
     * **라이트** — Dart 쪽 폴백(`read(_key) == _dark`)과 같아야 한다.
     *
     * 경로 계약(2026-11-20 소스 실측):
     *  - `getApplicationSupportDirectory()` = `PathUtils.getFilesDir(context)`
     *    = `context.getFilesDir()` = `<dataDir>/files`
     *    (path_provider_android 2.2.23 `PathProviderPlugin.getApplicationSupportPath`)
     *  - 그 아래 `kv/` 디렉터리이고 **키 하나가 파일 하나**다
     *  - 파일명은 `base64Url(utf8(key))` — 패딩(`=`) 포함
     *  - 내용은 `dark`|`light` 평문(JSON 아님 — 웹 index.html 의 스플래시 JS 도 같은 계약)
     *
     * ⚠️⚠️ **`<dataDir>/app_flutter`(`getDir` + `MODE_PRIVATE` 로 얻는 그 디렉터리)가
     * 아니다.** 그것은 바로 옆 메서드인 `getApplicationDocumentsPath` 의 경로다(그 이름을
     * 여기에 그대로 적으면 `test/splash_theme_sync_test.dart` 의 금지 단정에 **이 주석이**
     * 걸린다 — 실제로 걸렸다). 두 메서드가 6줄
     * 간격으로 붙어 있어 2026-11-20 에 혼동했고, 그 결과 네이티브가 **빈 디렉터리**를 보고
     * 저장값이 다크인데도 **항상 라이트로 폴백**했다(에뮬레이터 실측으로 드러났다).
     */
    private fun readSavedDark(): Boolean = try {
        File(filesDir, "kv/$THEME_FILE_NAME").readText().trim() == THEME_DARK_VALUE
    } catch (e: Throwable) {
        false // 파일 없음·권한·파손 → 라이트
    }

    private companion object {
        const val TAG = "AwsDocsSplash"

        /**
         * `base64Url(utf8("awsdocs.theme.v1"))`.
         *
         * ⚠️⚠️ **런타임에 계산하지 않고 상수로 둔다.** Dart 테스트는 Kotlin 을 실행할 수
         * 없으므로, Kotlin 이 자기 방식으로 인코딩하면 그 결과가 Dart 와 같은지 아무도
         * 검증하지 못한다. 상수로 두면 `test/splash_theme_sync_test.dart` 가
         * `ThemePrefStore._key` 에서 유도해 맞댈 수 있고, 키가 바뀌면 거기서 먼저 깨진다
         * (그러지 않으면 네이티브가 조용히 「키 없음 = 라이트」로 떨어진다).
         */
        const val THEME_FILE_NAME = "YXdzZG9jcy50aGVtZS52MQ=="

        /** `ThemePrefStore._dark` 와 같아야 한다. */
        const val THEME_DARK_VALUE = "dark"
    }
}
