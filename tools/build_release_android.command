#!/bin/zsh -l
# Compila el App Bundle firmado de Datum para Google Play (solo arm64, que es
# la única arquitectura para la que hay Open CASCADE compilado).
# Uso: doble clic en Finder, o ./tools/build_release_android.command
# Resultado: releases/android/Datum-<versión>-<build>.aab
# La firma se lee de ~/Library/Application Support/Datum/signing/key.properties.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/app" || exit 1
F="$HOME/development/flutter-datum/bin/flutter"; [ -x "$F" ] || F=flutter
VER=$(grep '^version:' pubspec.yaml | sed 's/version: *//; s/+/-/')
LOG="$ROOT/releases/android/build-$VER.log"
mkdir -p "$ROOT/releases/android"
echo "Compilando Datum $VER... no cierres esta ventana."
{ "$F" --version; "$F" build appbundle --release --target-platform android-arm64; } > "$LOG" 2>&1
RC=$?
if [ $RC -eq 0 ]; then
  cp build/app/outputs/bundle/release/app-release.aab "$ROOT/releases/android/Datum-$VER.aab"
  rm -f "$LOG"
  echo "Listo: releases/android/Datum-$VER.aab"
else
  echo "Error (código $RC). Detalles en $LOG"
fi
