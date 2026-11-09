#!/usr/bin/env bash
# Abre un archivo en la app dentro del simulador de iPhone y guarda una captura.
# Uso: tools/shot_ios.sh <archivo> <salida.png> [segundos_de_espera]
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$DOVEXA_ROOT/app"
SIM="${DOVEXA_SIM:-C7E501F0-452E-41FA-84C0-54393A9D5A2A}"   # iPhone 18 Pro
flutter build ios --simulator --debug --dart-define=DOVEXA_OPEN="$1" ${DOVEXA_DEFINES:-} >/dev/null
xcrun simctl boot "$SIM" 2>/dev/null || true
xcrun simctl terminate "$SIM" app.datum.datum 2>/dev/null || true
xcrun simctl install "$SIM" build/ios/iphonesimulator/Runner.app
xcrun simctl launch "$SIM" app.datum.datum >/dev/null
sleep "${3:-8}"
xcrun simctl io "$SIM" screenshot "$2" 2>&1 | tail -1
