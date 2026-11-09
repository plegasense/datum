#!/usr/bin/env bash
# Entorno de desarrollo de Dovexa. Uso:  source tools/env.sh
# Flutter propio del proyecto (separado del Flutter global, que no se toca).
_src="${BASH_SOURCE[0]:-${(%):-%x}}"
export DOVEXA_ROOT="$(cd "$(dirname "$_src")/.." && pwd)"
export FLUTTER_HOME="$HOME/development/flutter-dovexa"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$FLUTTER_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Compilaciones fuera de carpetas sincronizadas en la nube: éstas añaden atributos a los archivos y
# codesign de iOS falla con "resource fork, Finder information, or similar detritus".
export DOVEXA_BUILD_CACHE="$HOME/Library/Caches/Dovexa"
mkdir -p "$DOVEXA_BUILD_CACHE/app-build"
if [ -d "$DOVEXA_ROOT/app" ] && [ ! -L "$DOVEXA_ROOT/app/build" ]; then
  rm -rf "$DOVEXA_ROOT/app/build"
  ln -s "$DOVEXA_BUILD_CACHE/app-build" "$DOVEXA_ROOT/app/build"
fi
