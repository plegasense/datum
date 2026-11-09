#!/usr/bin/env bash
# Abre un archivo en la app dentro del emulador Android y guarda una captura.
# Uso: tools/shot_android.sh <archivo> <salida.png> [segundos_de_espera]
# Requiere el emulador arrancado (emulator -avd Medium_Phone_API_36.1 -gpu host).
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$DOVEXA_ROOT/app"
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
APP=app.datum.datum
NAME="$(basename "$1")"
DIR="/data/user/0/$APP/files"
"$ADB" push "$1" "/data/local/tmp/$NAME" >/dev/null
flutter build apk --debug --target-platform android-arm64 --dart-define=DOVEXA_OPEN="$DIR/$NAME" ${DOVEXA_DEFINES:-} >/dev/null
"$ADB" install -r build/app/outputs/flutter-apk/app-debug.apk >/dev/null
"$ADB" shell "run-as $APP sh -c 'mkdir -p files; cp \"/data/local/tmp/$NAME\" \"files/$NAME\"'"
"$ADB" shell am force-stop $APP
"$ADB" shell am start -n $APP/.MainActivity >/dev/null
sleep "${3:-20}"
"$ADB" exec-out screencap -p > "$2"
echo "Wrote screenshot to: $2"
