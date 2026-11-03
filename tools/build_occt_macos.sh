#!/usr/bin/env bash
# Compila OCCT (estático, solo lo necesario para importar formatos) para macOS arm64.
# Resultado: third_party/_install/occt-macos
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/third_party/occt"
BUILD="$ROOT/third_party/_build/occt-macos"
OUT="$ROOT/third_party/_install/occt-macos"

if [ ! -d "$SRC" ]; then
  git clone --depth 1 --branch V8_0_1 https://github.com/Open-Cascade-SAS/OCCT.git "$SRC"
fi
mkdir -p "$BUILD"
cmake -G Ninja -S "$SRC" -B "$BUILD" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_LIBRARY_TYPE=Static \
  -DBUILD_MODULE_Visualization=OFF -DBUILD_MODULE_Draw=OFF \
  -DUSE_FREETYPE=OFF -DUSE_TK=OFF -DUSE_RAPIDJSON=OFF -DUSE_TBB=OFF \
  -DUSE_OPENGL=OFF -DUSE_GLES2=OFF -DBUILD_DOC_Overview=OFF \
  -DINSTALL_DIR="$OUT" -DCMAKE_OSX_ARCHITECTURES=arm64
cmake --build "$BUILD" --target install
