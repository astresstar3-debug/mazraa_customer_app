#!/usr/bin/env bash
set -u

flutter devices

screenshot_exit=0
flutter drive --no-dds \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/home_reference_screenshot_test.dart \
  -d emulator-5554 || screenshot_exit=$?

echo "Installing the standalone APK built from lib/main.dart..."
adb install -r build/installable/mazraa-app-debug.apk
adb shell am force-stop com.example.mazraa_customer_app
adb logcat -c
adb shell monkey -p com.example.mazraa_customer_app -c android.intent.category.LAUNCHER 1
sleep 8

app_pid="$(adb shell pidof com.example.mazraa_customer_app | tr -d '\r' || true)"
if [[ -z "$app_pid" ]]; then
  echo "Standalone app exited during startup. Recent crash log:"
  adb logcat -d -t 600 | grep -E "AndroidRuntime|FATAL EXCEPTION|com.example.mazraa_customer_app|flutter" || true
  exit 1
fi

echo "Standalone app is still running after startup smoke test. PID=$app_pid"
exit "$screenshot_exit"
