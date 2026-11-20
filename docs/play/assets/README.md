# Play 스토어 그래픽 자산 (A8-2, 2026-11-20)

| 파일 | 규격 | 만드는 법 |
|---|---|---|
| `icon-512.png` | 512×512 · 32-bit PNG(알파) · **모서리를 깎지 않은 정사각형** | `py tool/make_app_icon.py --store` |
| `feature-graphic.png` | 1024×500 · 24-bit PNG(알파 없음) | 같은 명령. 문구는 생성기의 `FEATURE_LINE` |
| `screenshots/*.png` | 1080×2400 · 24-bit PNG · 6장 | 아래 절차 |

요건 정본과 가드는 `flutter_app/test/store_assets_test.dart` 머리말에 있다. 자산을 바꾸면 그 테스트를 돌린다.

⚠️ 아이콘을 웹 `Icon-512.png` 로 대신하면 안 된다 — 모서리를 미리 둥글게 그렸고, Play 는 그 위에 30% 마스크와 그림자를 또 씌운다.
⚠️ 앱 이름(A0)이 정해져도 기능 그래픽에는 이름이 없다. 이름을 넣으려면 `FEATURE_LINE` 을 바꿔 다시 생성한다.

## 스크린샷 절차

1. 에뮬레이터 `Medium_Phone`(1080×2400) 을 `-gpu swiftshader_indirect -memory 4096` 으로 띄우고 `adb shell service check package` 가 found 일 때 진행한다.
2. `flutter build apk --release` 로 만든 APK 를 설치한다.
3. 상태 표시줄 데모 모드 — Play 는 "Do not show service providers or notifications. The battery, WiFi, and cell service logos should be full" 을 요구한다.
   ```
   adb shell settings put global sysui_demo_allowed 1
   adb shell am broadcast -a com.android.systemui.demo -e command enter
   adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0900
   adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 100 -e plugged false
   adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 4 -e fully true
   adb shell am broadcast -a com.android.systemui.demo -e command network -e mobile hide
   adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
   ```
4. **`adb shell pm clear kr.ai.leva.awsdocs` 로 앱 데이터를 비운 뒤** 라이트 테마·기본 글자 크기로 아래 화면을 `adb exec-out screencap -p` 로 찍는다. ⚠️ 비우지 않으면 앞선 촬영의 모의고사 제출(정답률 2%)이 자격증 상세의 「최고 정답률」·Task별 「오답」으로 남는다(2026-11-20 재촬영에서 실제로 남았다). 모의고사 문항은 매번 섞여 나오므로 05·06 의 문항은 찍을 때마다 다르다.
5. ⚠️⚠️ **`screencap` 은 RGBA(알파 있음) PNG 를 낸다** — Play 는 알파 없는 24-bit PNG 를 요구하므로 **RGB 로 바꿔 저장**한다(알파가 전부 255 인지 확인한 뒤 바꾸면 픽셀은 그대로다). 가드가 이것을 처음 잡았다.
6. Git Bash 에서 `adb shell uiautomator dump /sdcard/...` 를 부르면 MSYS 가 경로를 바꾼다 — Python `subprocess` 로 부른다.

| 파일 | 화면 |
|---|---|
| `01-home.png` | 홈 맨 위 |
| `02-certs.png` | 홈 자격증 목록(Foundational 제목이 헤더 아래 보이게) |
| `03-cert-tasks.png` | SAA-C03 상세 「학습 콘텐츠 · 검증 문항」 |
| `04-study-doc.png` | `saa-t1-3` 학습문서 머리(검증됨·검수일·출처 수) |
| `05-exam.png` | SAA-C03 통합 모의고사 1번(정답 보기 선택) |
| `06-review.png` | 제출 후 해설·학습문서 링크(점수 줄은 화면 밖) |

찍는 동안 관찰한 앱 쪽 문제(이번 범위 밖): 폰 폭에서 홈 히어로 제목 「이해하고 통과하기」의 「기」가 한 줄에 홀로 떨어진다. 통합 모의고사 상단에 큰 빈 띠가 있다.
