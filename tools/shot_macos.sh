#!/usr/bin/env bash
# Abre un archivo en la app de macOS, guarda una captura y cierra. Uso: tools/shot_macos.sh <archivo> <salida.png>
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$DOVEXA_ROOT/app"
flutter build macos --debug --dart-define=DOVEXA_OPEN="$1" --dart-define=DOVEXA_SHOT="$2" >/dev/null
rm -f "$2"
build/macos/Build/Products/Debug/dovexa.app/Contents/MacOS/dovexa >/dev/null 2>&1 &
for i in $(seq 1 60); do [ -f "$2" ] && break; sleep 1; done
[ -f "$2" ] && echo "captura: $2" || { echo "no se generó captura"; pkill -x dovexa || true; exit 1; }
