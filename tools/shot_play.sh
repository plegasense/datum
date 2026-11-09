#!/usr/bin/env bash
# Captura de una escena para la ficha de Play en un dispositivo/emulador Android.
# Uso: tools/shot_play.sh <serie_adb> <archivo> <salida.png> [segundos] [valor_DOVEXA_CAD]
# Variables: DOVEXA_DEFINES="--dart-define=..." para ganchos extra (DOVEXA_PANEL, DOVEXA_SELECT…).
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$DOVEXA_ROOT/app"
ADB="$ANDROID_HOME/platform-tools/adb"
S="$1"; APP=app.datum.datum; NAME="$(basename "$2")"; DIR="/data/user/0/$APP/files"
"$ADB" -s "$S" push "$2" "/data/local/tmp/$NAME" >/dev/null
flutter build apk --profile --target-platform android-arm64 --dart-define=DOVEXA_OPEN="$DIR/$NAME" --dart-define=DOVEXA_CAD="${5:-}" ${DOVEXA_DEFINES:-} >/dev/null 2>&1
"$ADB" -s "$S" install -r build/app/outputs/flutter-apk/app-profile.apk >/dev/null
"$ADB" -s "$S" shell "run-as $APP sh -c 'mkdir -p files; cp /data/local/tmp/$NAME files/$NAME'"
"$ADB" -s "$S" shell input keyevent KEYCODE_WAKEUP || true
"$ADB" -s "$S" shell am force-stop $APP
"$ADB" -s "$S" shell am start -n $APP/.MainActivity >/dev/null
sleep "${4:-15}"
"$ADB" -s "$S" exec-out screencap -p > "$3"
echo "$3"
