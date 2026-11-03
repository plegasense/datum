# Dovexa

Visor CAD/CAM para iOS y Android. Gratuito, sin anuncios, sin cuenta, offline.
Abre STEP, DXF, STL, 3MF, OBJ y más; ensamblajes con árbol de piezas, búsqueda, recuentos y varios modos de vista.

## Decisiones tomadas
- Licencia: GPL-3.0 (ver `LICENSE` y `NOTICE.md`).
- Nombre: Dovexa (plano de referencia en CAD/GD&T). Comprobado que no hay app de CAD con ese nombre en Play Store.
- Plataformas: iOS y Android. Núcleo C++ compartido, interfaz Flutter (a validar en M0).
- Logo: vista explosionada de un ensamblaje en isométrica: base sólida, bloque en alambre y pieza naranja seleccionada, unidos por guías discontinuas. Ver ensamblajes, modos de vista y selección de piezas.
- Colores: tinta #0D1B1E, blanco y grises azulados, naranja #FB923C (pieza seleccionada), menta #5EEAD4 (guías).
- Fuente del nombre: Roboto Medium (Apache-2.0), incluida en `branding/fonts/` con su licencia; en los SVG el nombre va como trazados. Sustituye a Avenir Next (fuente de Apple, no redistribuible).

## Carpetas
- `branding/`: logo, icono adaptable de Android, versiones clara y oscura, PNG para Play Store. `build_logo.py` regenera todo.
- `docs/`: plan del proyecto. Empieza por `docs/01-vision-y-alcance.md`; las decisiones abiertas están en `docs/06-decisiones.md` y las tareas en `docs/07-backlog.md`.
- `app/`: interfaz Flutter (pendiente).
- `core/`: núcleo C++ compartido (pendiente).
- `third_party/`, `testdata/`, `tools/`: dependencias, archivos de prueba y scripts.

## Código fuente de terceros
- **Open CASCADE Technology 8.0.1** (LGPL-2.1 con la excepción de OCCT), sin modificar. Código fuente: https://github.com/Open-Cascade-SAS/OCCT/tree/V8_0_1. Se compila con `tools/build_occt_android.sh` (y `_ios`, `_macos`); Dovexa lo enlaza de forma estática y su código completo está en este repositorio, por lo que se puede volver a enlazar con otra versión de la librería.
- **Draco** y **LASzip** (Apache-2.0): código incluido en `third_party/`.
- Cada versión publicada en Google Play corresponde a una etiqueta de este repositorio (p. ej. `v1.0.1`).
