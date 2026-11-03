#!/usr/bin/env bash
# Mide el rendimiento en un dispositivo Android físico (compilación de perfil).
# Uso: tools/perf_device.sh <serie_adb> <archivo> <valor_DATUM_CAD> [segundos]
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$DATUM_ROOT/app"
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
S="$1"; APP=app.datum.datum; NAME="$(basename "$2")"; DIR="/data/user/0/$APP/files"
if [ -z "${NOPUSH:-}" ]; then "$ADB" -s "$S" push "$2" "/data/local/tmp/$NAME" >/dev/null; fi
flutter build apk --profile --target-platform android-arm64 --dart-define=DATUM_OPEN="$DIR/$NAME" --dart-define=DATUM_CAD="$3" ${DATUM_DEFINES:-} >/dev/null 2>&1
"$ADB" -s "$S" install -r build/app/outputs/flutter-apk/app-profile.apk >/dev/null
if [ -z "${NOPUSH:-}" ]; then "$ADB" -s "$S" shell "run-as $APP sh -c 'mkdir -p files; cp /data/local/tmp/$NAME files/$NAME'"; fi
"$ADB" -s "$S" shell input keyevent KEYCODE_WAKEUP || true
"$ADB" -s "$S" shell am force-stop $APP
"$ADB" -s "$S" logcat -c
"$ADB" -s "$S" shell am start -n $APP/.MainActivity >/dev/null
sleep "${4:-40}"
"$ADB" -s "$S" logcat -d | grep -E "flutter.*(PERF|LOAD|LOD|STOCKPLAY|TWIST|REVIEW)|FATAL|AndroidRuntime" | tail -5
"$ADB" -s "$S" exec-out screencap -p > "${5:-/tmp/dev_shot.png}"
