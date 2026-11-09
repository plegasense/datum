# Dovexa — app Flutter

Ver el `README.md` de la raíz. Antes de nada: `source ../tools/env.sh` (usa el Flutter del proyecto).

- `lib/io/`: lectores de cada formato · `lib/model/`: datos · `lib/ui/`: pantallas · `lib/l10n/`: idiomas (`docs/11-localizacion.md`).
- `shaders/`, `fx/`: shaders del visor (Flutter GPU).
- `hook/`: compila Draco y LASzip al construir.
- `test/`: `flutter test`.
- `tool/`: se ejecutan con `dart run tool/<nombre>.dart <archivos>`:
  - `bench_*`: tiempos de carga · `verify_*`: comprobaciones de resultado y robustez · `probe_*`: vuelcan lo que se lee de un archivo.
