#!/usr/bin/env bash
# Entorno de desarrollo de Dovexa. Uso:  source tools/env.sh
# Flutter propio del proyecto (separado del Flutter global, que no se toca).
_src="${BASH_SOURCE[0]:-${(%):-%x}}"
export DATUM_ROOT="$(cd "$(dirname "$_src")/.." && pwd)"
export FLUTTER_HOME="$HOME/development/flutter-datum"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$FLUTTER_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Compilaciones fuera de Documents: iCloud añade atributos a los archivos y
# codesign de iOS falla con "resource fork, Finder information, or similar detritus".
export DATUM_BUILD_CACHE="$HOME/Library/Caches/Dovexa"
mkdir -p "$DATUM_BUILD_CACHE/app-build"
if [ -d "$DATUM_ROOT/app" ] && [ ! -L "$DATUM_ROOT/app/build" ]; then
  rm -rf "$DATUM_ROOT/app/build"
  ln -s "$DATUM_BUILD_CACHE/app-build" "$DATUM_ROOT/app/build"
fi
