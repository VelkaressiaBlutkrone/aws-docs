import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 업로드 키는 저장소 밖에 둔다 — android/key.properties 는 .gitignore 대상이다.
// 형식: storeFile=<키스토어 경로>  storePassword=…  keyAlias=…  keyPassword=…
// ⚠️ 이 키를 분실하면 앱 업데이트가 불가능하다(Play App Signing 의 업로드 키).
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "kr.ai.leva.awsdocs"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Play 에 영구 등록되는 식별자 — 삭제·재사용이 불가능하다(2026-11-18 확정).
        // 바뀌면 Firebase 안드로이드 앱 등록과 구글 로그인 SHA 지문까지 어긋난다.
        applicationId = "kr.ai.leva.awsdocs"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Flutter 3.47.2 템플릿 기본값을 실측해 리터럴로 고정했다
        // (FlutterExtension.kt: minSdkVersion 24 · targetSdkVersion 36).
        // 리터럴이어야 제출 시점의 대상 API 수준을 소스에서 감사할 수 있고,
        // android_release_config_test.dart 가 수치를 확인할 수 있다.
        minSdk = 24
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // ⚠️ 의도된 폴백 — 키가 없는 환경(CI·새 클론)에서도 릴리스 빌드 구성을
                // 검증할 수 있게 한다. 디버그 키로 서명된 AAB 는 Play 에 업로드할 수 없으니,
                // 업로드할 빌드는 key.properties 가 있는 곳에서 만든다.
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
