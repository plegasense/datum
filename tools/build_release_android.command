#!/bin/zsh -l
# Compila el App Bundle firmado de Dovexa para Google Play (solo arm64, que es
# la única arquitectura para la que hay Open CASCADE compilado).
# Uso: doble clic en Finder, o ./tools/build_release_android.command
# Resultado: releases/android/Dovexa-<versión>-<build>.aab
# La firma se lee de ~/Library/Application Support/Dovexa/signing/key.properties.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/app" || exit 1
F="$HOME/development/flutter-datum/bin/flutter"; [ -x "$F" ] || F=flutter
VER=$(grep '^version:' pubspec.yaml | sed 's/version: *//; s/+/-/')
LOG="$ROOT/releases/android/build-$VER.log"
mkdir -p "$ROOT/releases/android"
echo "Compilando Dovexa $VER... no cierres esta ventana."
{ "$F" --version; "$F" build appbundle --release --target-platform android-arm64; } > "$LOG" 2>&1
RC=$?
if [ $RC -eq 0 ]; then
  cp build/app/outputs/bundle/release/app-release.aab "$ROOT/releases/android/Dovexa-$VER.aab"
  rm -f "$LOG"
  echo "Listo: releases/android/Dovexa-$VER.aab"
else
  echo "Error (código $RC). Detalles en $LOG"
fi
