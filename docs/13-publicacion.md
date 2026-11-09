# Publicar una versión en Google Play

## Estado actual
| Versión | Build | Canal | Fecha | Notas |
|---|---|---|---|---|
| 1.0.0 | 3 | Prueba cerrada – Alpha | 31-oct-2026 | Primera versión |
| 1.0.1 | 4 | Prueba cerrada – Alpha | 4-nov-2026 (publicada) | Ajustes (Unidades, Idioma, Acerca de), licencias de código abierto, enlace al código |
| 1.0.2 | 5 | Prueba cerrada – Alpha | 4-nov-2026 (enviada a revisión) | Barra del visor simplificada; Abrir, Unidades e Idioma siguen accesibles desde Inicio y Ajustes |
| 1.0.3 | 6 | Prueba cerrada – Alpha | — | Aviso BSD de LASzip en licencias (el AAB lleva ABIs sobrantes y rutas del equipo: no usar) |
| 1.0.4 (no usar: lleva el usuario del equipo en resources.pb) | 7 | — | (sin subir) | Solo arm64, sin rutas del equipo en el binario, sin copia de seguridad en la nube, política de privacidad actualizada |
| 1.0.5 | 8 | — | 9-nov-2026 | Caché de Gradle en ruta neutra: el AAB ya no lleva el usuario del equipo |
| 1.0.6 | 9 | — | 9-nov-2026 | La app pasa a llamarse Dovexa (el paquete sigue siendo `app.datum.datum`) |
| 1.0.7 | 10 | — | 9-nov-2026 | El limpiador de rutas cubre también la carpeta antigua |
| 1.0.8 | 11 | — | 9-nov-2026 | Correcciones de traducción en 8 idiomas |
| 1.0.9 | 12 | — | 9-nov-2026 | Política de privacidad bilingüe en el repositorio como URL pública |
| **1.0.10** | **13** | Lanzamiento completo | 9-nov-2026 (enviada a revisión) | Pantalla de licencias traducida. Versión de cierre del proyecto |

Las versiones 1.0.5 a 1.0.9 fueron pasos intermedios del mismo día; en `releases/android/` solo se conserva el AAB de la 1.0.10.

Código fuente público: https://github.com/plegasense/dovexa (cada versión tiene su etiqueta `vX.Y.Z`).

## Pasos
1. **Versión**: subir `version:` en `app/pubspec.yaml` (`X.Y.Z+build`; el build siempre mayor que el anterior).
2. **Compilar** (copia en `/Users/Shared/dovexa-build`, sin tu nombre de usuario en el binario): doble clic en `tools/build_release_android.command`. Deja `releases/android/Dovexa-X.Y.Z-build.aab` (solo arm64; firmado con la clave de subida de `claves/`).
3. **Código (obligatorio por la GPL-3.0)**: `git commit`, `git tag vX.Y.Z` y `git push origin main vX.Y.Z` **antes** de publicar el AAB.
4. **Play Console** → Dovexa → la pista que toque → Crear nueva versión → Subir el AAB → notas en `es-ES` y `en-US` → Guardar → Resumen de publicación → Enviar a revisión.

## Licencias (revisar si cambian las dependencias)
- Dovexa: GPL-3.0 (`LICENSE`).
- Open CASCADE 8.0.1: LGPL-2.1 + excepción OCCT, enlazado estático, sin modificar (fuente: tag `V8_0_1` del repositorio oficial).
- Draco y LASzip: Apache-2.0 (código en `third_party/`).
- Los textos se muestran en la app (Ajustes → Acerca de → Licencias de código abierto) desde `app/assets/licenses/`; se registran en `app/lib/ui/licenses.dart`.
- Si se añade una librería nativa nueva: copiar su licencia a `app/assets/licenses/` y registrarla en `licenses.dart` y en `NOTICE.md`.
