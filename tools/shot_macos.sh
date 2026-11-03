#!/usr/bin/env bash
# Abre un archivo en la app de macOS, guarda una captura y cierra. Uso: tools/shot_macos.sh <archivo> <salida.png>
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$DATUM_ROOT/app"
flutter build macos --debug --dart-define=DATUM_OPEN="$1" --dart-define=DATUM_SHOT="$2" >/dev/null
rm -f "$2"
build/macos/Build/Products/Debug/datum.app/Contents/MacOS/datum >/dev/null 2>&1 &
for i in $(seq 1 60); do [ -f "$2" ] && break; sleep 1; done
[ -f "$2" ] && echo "captura: $2" || { echo "no se generó captura"; pkill -x datum || true; exit 1; }
