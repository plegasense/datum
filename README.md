# Dovexa

Visor CAD/CAM para Android (el código de iOS y macOS se mantiene para uso propio). Gratuito, sin anuncios, sin cuenta, offline.
Abre STEP, IGES, DXF, STL, 3MF, OBJ, glTF, PLY, G-code (FDM y CNC), SVG, HPGL, VRML/X3D y nubes de puntos; ensamblajes con árbol de piezas, medición, secciones y varios modos de vista.

- Licencia: GPL-3.0 (`LICENSE`, avisos de terceros en `NOTICE.md`). Autor: Plegasense.
- Google Play: paquete `app.datum.datum` (no se puede cambiar; «Datum» fue el nombre anterior).
- Interfaz en 21 idiomas.

## Estado (9-nov-2026)
Proyecto cerrado en la versión **1.0.10 (build 13)**, etiqueta `v1.0.10`, publicada en Google Play (prueba cerrada «Alpha», 178 países) el 9-nov-2026.
Acceso a producción solicitado a Google el 9-nov-2026 (22:17); la respuesta llega por correo, normalmente en 7 días o menos. Las respuestas enviadas están en `docs/13-publicacion.md`.
El historial de versiones y los pasos para publicar otra están en `docs/13-publicacion.md`.

## Carpetas
| Carpeta | Contenido |
|---|---|
| `app/` | App Flutter: `lib/` (código), `lib/l10n/` (idiomas), `assets/licenses/` (licencias que muestra la app), `test/` (pruebas), `tool/` (bancos de prueba y sondas por formato), `hook/` (compila Draco y LASzip). |
| `core/` | Núcleo C++ que envuelve Open CASCADE (lectura de STEP/IGES/BREP). |
| `third_party/` | Draco y LASzip (código incluido). Open CASCADE compilado queda en `third_party/_install/` (fuera de git). |
| `tools/` | Scripts: entorno (`env.sh`), compilar el AAB, compilar Open CASCADE, capturas, comprobación de idiomas. |
| `store/` | Ficha de Google Play: textos, capturas, gráficos y política de privacidad. Ver `store/ficha_play.md`. |
| `branding/` | Logo, icono y tipografías. `build_logo.py` regenera todo. |
| `docs/` | Diseño, decisiones, especialización por formato, idiomas y publicación (índice abajo). |
| `testdata/` | Archivos de prueba pequeños y con licencia. Ver `testdata/README.md`. |
| `releases/` | AAB compilados (fuera de git). |
| `claves/`, `sdk/` | Clave de subida de Play y Flutter del proyecto (fuera de git). |

## Lo que no está en git (y hay que conservar)
Todo está dentro de esta carpeta; copiarla entera es la copia de seguridad del proyecto.
- **Clave de subida de Play**: `claves/` (`dovexa-upload-key.jks`, `key.properties` y una copia cifrada). Sin ella no se pueden subir versiones. Guardar otra copia fuera de este ordenador. Ver `app/android/RELEASE_SIGNING.md`.
- **Flutter del proyecto**: `sdk/flutter` (3.47.8, versión fijada; el Flutter global no sirve).
- **Open CASCADE para Android**: `third_party/_install/occt-android-arm64-v8a` (se recompila con `tools/build_occt_android.sh`, tarda).
- `testdata/_externos/` y `testdata/_big/`: muestras para capturas y pruebas de rendimiento.

Lo único que se crea fuera de la carpeta son cachés de compilación (`/Users/Shared/dovexa-build`, `/Users/Shared/dovexa-gradle`, `~/Library/Caches/Dovexa`): están fuera a propósito, para que el binario no lleve el nombre de usuario del equipo, y se pueden borrar siempre.

## Tareas habituales
```bash
source tools/env.sh                      # entorno (Flutter del proyecto, Java, Android SDK)
python3 tools/l10n_check.py              # idiomas: debe decir «0 problemas»
cd app && flutter test                   # pruebas
./tools/build_release_android.command    # AAB firmado en releases/android/
```

## Documentación (`docs/`)
- `01` visión y alcance · `02` formatos · `03` arquitectura · `06` decisiones.
- `04` roadmap, `05` workflow, `07` backlog y `08` informe M0–M1: plan original, se conservan como historia y no están al día.
- `09`, `10` y `formatos/`: evaluación y especialización de cada formato (`formatos/ESTADO.md` es el resumen).
- `11` localización (cómo se traduce) · `12` elección de idiomas · `14` revisión manual de idiomas.
- `13` publicación en Google Play.

## Código fuente de terceros
- **Open CASCADE Technology 8.0.1** (LGPL-2.1 con la excepción de OCCT), sin modificar. Código fuente: https://github.com/Open-Cascade-SAS/OCCT/tree/V8_0_1. Se compila con `tools/build_occt_android.sh` (y `_ios`, `_macos`); Dovexa lo enlaza de forma estática y su código completo está en este repositorio, por lo que se puede volver a enlazar con otra versión de la librería.
- **Draco** y **LASzip** (Apache-2.0): código incluido en `third_party/`.
- Cada versión publicada en Google Play corresponde a una etiqueta de este repositorio (p. ej. `v1.0.10`).
