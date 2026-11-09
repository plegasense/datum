#!/usr/bin/env bash
# Capturas de las 7 escenas de la ficha de Play en varios idiomas (idioma por app, Android 13+).
# Uso: tools/shots_langs.sh <serie_adb> "de-DE:de zh-CN:zh pt-BR:pt …"   → store/shots/<código>/<escena>.png
set -uo pipefail
source "$(dirname "$0")/env.sh"
cd "$DOVEXA_ROOT/app"
ADB="$ANDROID_HOME/platform-tools/adb"; S="$1"; LANGS="$2"; APP=app.datum.datum
T=../testdata/_externos; OUT=../store/shots
# escena | archivo | CAD | defines | espera | toque x,y (opcional)
SCENES=(
 "step|$T/otros_cad/as1-oc-214.stp|e:0.6||22|"
 "fdm|$T/fdm_otros/prusaslicer_3dbenchy.gcode||--dart-define=DOVEXA_SLIDER=0.55|20|"
 "cnc|$T/cnc/mmount.ngc|||16|"
 "stl|$T/stl/3dbenchy_3DBenchy.stl|||12|974,1433"
 "gltf|$T/malla/gltf/CesiumMilkTruck.glb|||16|"
 "cloud|$T/nubes/las/autzen_trim.las|mode:1||40|"
 "dxf|../testdata/placa_ejemplo.dxf|||12|974,1200"
)
for sc in "${SCENES[@]}"; do
  IFS='|' read -r name file cad defs wait tap <<<"$sc"
  [ -n "${ONLY:-}" ] && [ "$name" != "$ONLY" ] && continue
  base="$(basename "$file")"
  "$ADB" -s "$S" push "$file" "/data/local/tmp/$base" >/dev/null
  flutter build apk --profile --target-platform android-arm64 --dart-define=DOVEXA_OPEN="/data/user/0/$APP/files/$base" --dart-define=DOVEXA_CAD="$cad" $defs >/dev/null 2>&1
  "$ADB" -s "$S" install -r build/app/outputs/flutter-apk/app-profile.apk >/dev/null
  "$ADB" -s "$S" shell "run-as $APP sh -c 'mkdir -p files; cp /data/local/tmp/$base files/$base'"
  for pair in $LANGS; do
    tag="${pair%%:*}"; code="${pair##*:}"
    mkdir -p "$OUT/$code"
    "$ADB" -s "$S" shell cmd locale set-app-locales $APP --locales "$tag" >/dev/null 2>&1
    "$ADB" -s "$S" shell am force-stop $APP
    "$ADB" -s "$S" shell am start -n $APP/.MainActivity >/dev/null
    sleep "$wait"
    if [ -n "$tap" ]; then "$ADB" -s "$S" shell input tap "${tap%%,*}" "${tap##*,}"; sleep 3; fi
    "$ADB" -s "$S" exec-out screencap -p > "$OUT/$code/$name.png"
    echo "$code/$name"
  done
done
