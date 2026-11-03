# Archivos de prueba

- `step/`: ejemplos de Open CASCADE (pequeños, con su licencia).
- **Corpus local, no se sube a git:** la carpeta `~/Documents/Piezas CAD` (1,4 GB) contiene archivos reales del autor
  (SolidWorks, Inventor, NX, Fusion, AutoCAD). Se usa solo desde disco, nunca se copia al repositorio.

Pruebas de carga masiva (desde `app/`):

```bash
source ../tools/env.sh
dart run tool/bench_load.dart "$HOME/Documents/Piezas CAD" step,stp 200   # STEP
dart run tool/bench_load.dart "$HOME/Documents/Piezas CAD" 3mf 100        # 3MF
dart run tool/bench_load.dart "$HOME/Documents/Piezas CAD" stl,obj 120    # STL y OBJ
```

Capturas automáticas en el simulador de iPhone: `tools/shot_ios.sh <archivo> <salida.png>`.
