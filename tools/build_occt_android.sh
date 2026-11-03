#!/usr/bin/env bash
# Compila OCCT (estático) para Android. Uso: tools/build_occt_android.sh [arm64-v8a|x86_64]
set -euo pipefail
ABI="${1:-arm64-v8a}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NDK="${ANDROID_NDK_HOME:-$HOME/Library/Android/sdk/ndk/28.2.13676358}"
SRC="$ROOT/third_party/occt"
BUILD="$ROOT/third_party/_build/occt-android-$ABI"
OUT="$ROOT/third_party/_install/occt-android-$ABI"
mkdir -p "$BUILD"
cmake -G Ninja -S "$SRC" -B "$BUILD" \
  -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI="$ABI" -DANDROID_PLATFORM=android-26 -DANDROID_STL=c++_shared \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_LIBRARY_TYPE=Static \
  -DBUILD_MODULE_Visualization=OFF -DBUILD_MODULE_Draw=OFF \
  -DUSE_FREETYPE=OFF -DUSE_TK=OFF -DUSE_RAPIDJSON=OFF -DUSE_TBB=OFF \
  -DUSE_OPENGL=OFF -DUSE_GLES2=OFF -DBUILD_DOC_Overview=OFF \
  -DINSTALL_DIR="$OUT"
cmake --build "$BUILD" --target install
