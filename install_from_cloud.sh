#!/bin/bash
set -e

echo "=== Fetching latest cloud compiled ARM64 APK from GitHub Actions ==="
gh run download $(gh run list --limit 1 --json databaseId -q '.[0].databaseId') -n HID_Tool_arm64_Release -D ./build_output

APK_PATH="./build_output/HID_Tool_arm64.apk"
if [ ! -f "$APK_PATH" ]; then
  APK_PATH=$(find ./build_output -name "*.apk" | head -n 1)
fi

echo "=== Found compiled binary: $APK_PATH ==="
echo "=== Installing onto connected phone via ADB ==="
adb install -r -d "$APK_PATH"

echo "=== Launching HID Tool on device ==="
adb shell am start -n com.antigravity.hidtool/.MainActivity

echo "=== Deployment successful! ==="
