#!/usr/bin/env bash
# Compila OCCT (estático) para iOS. Uso: tools/build_occt_ios.sh [simulator|device]
set -euo pipefail
KIND="${1:-simulator}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/third_party/occt"
BUILD="$ROOT/third_party/_build/occt-ios-$KIND"
OUT="$ROOT/third_party/_install/occt-ios-$KIND"
SDK=$([ "$KIND" = "device" ] && echo iphoneos || echo iphonesimulator)
mkdir -p "$BUILD"
cmake -G Ninja -S "$SRC" -B "$BUILD" \
  -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT="$SDK" -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=17.0 \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_LIBRARY_TYPE=Static \
  -DBUILD_MODULE_Visualization=OFF -DBUILD_MODULE_Draw=OFF \
  -DUSE_FREETYPE=OFF -DUSE_TK=OFF -DUSE_RAPIDJSON=OFF -DUSE_TBB=OFF \
  -DUSE_OPENGL=OFF -DUSE_GLES2=OFF -DBUILD_DOC_Overview=OFF \
  -DINSTALL_DIR="$OUT"
cmake --build "$BUILD" --target install
