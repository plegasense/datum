#!/bin/zsh -l
# Compila el App Bundle firmado de Dovexa para Google Play (solo arm64, que es
# la única arquitectura para la que hay Open CASCADE compilado).
# Uso: doble clic en Finder, o ./tools/build_release_android.command
# Resultado: releases/android/Dovexa-<versión>-<build>.aab
# La firma se lee de ~/Library/Application Support/Dovexa/signing/key.properties.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Se compila desde una copia en una ruta sin tu nombre de usuario: las rutas de compilación acaban dentro del binario.
B=/Users/Shared/datum-build
mkdir -p "$B/third_party/_install" "$ROOT/releases/android"
rsync -a --delete --exclude build --exclude .dart_tool --exclude ios --exclude macos "$ROOT/app" "$ROOT/core" "$ROOT/tools" "$B/" || exit 1
rsync -a --delete "$ROOT/third_party/draco" "$ROOT/third_party/laszip" "$B/third_party/" || exit 1
rsync -a "$ROOT/third_party/_install/occt-android-arm64-v8a" "$B/third_party/_install/" || exit 1
# Las bibliotecas de Open CASCADE ya compiladas llevan la ruta vieja: se sustituye por una neutra de igual longitud.
python3 "$ROOT/tools/scrub_paths.py" "$B/third_party/_install/occt-android-arm64-v8a/lib" "$ROOT" || exit 1
cd "$B/app" || exit 1
F="$HOME/development/flutter-datum/bin/flutter"; [ -x "$F" ] || F=flutter
VER=$(grep '^version:' pubspec.yaml | sed 's/version: *//; s/+/-/')
LOG="$ROOT/releases/android/build-$VER.log"
mkdir -p "$ROOT/releases/android"
echo "Compilando Dovexa $VER... no cierres esta ventana."
{ "$F" --version; "$F" build appbundle --release --target-platform android-arm64; } > "$LOG" 2>&1
RC=$?
if [ $RC -eq 0 ]; then
  cp "$B/app/build/app/outputs/bundle/release/app-release.aab" "$ROOT/releases/android/Dovexa-$VER.aab"
  rm -f "$LOG"
  echo "Listo: releases/android/Dovexa-$VER.aab"
else
  echo "Error (código $RC). Detalles en $LOG"
fi
