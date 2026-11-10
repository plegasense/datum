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
| 1.0.10 | 13 | Prueba cerrada – Alpha | 9-nov-2026 (publicada) | Pantalla de licencias traducida. |
| **1.0.11** | **14** | Alpha y Producción (178 países) | Enviada a revisión de Google (10 nov 2026) | Auditoría de uso: «Atrás» cierra el panel de piezas en vez de la app; mensajes de error sin prefijo técnico; STL con coordenadas absurdas se descartan; barra de herramientas y pantalla de inicio con desplazamiento en horizontal; «Abrir con» y «Compartir» desde el gestor de archivos; protocolo STEP legible en la ficha; masas y medidas diminutas ya no salen como 0,00 |

Las versiones 1.0.5 a 1.0.9 fueron pasos intermedios del mismo día; en `releases/android/` solo se conserva el AAB de la 1.0.10.

## Acceso a producción
Aprobado el 10-nov-2026. La 1.0.11 se envió a revisión como primera versión de producción, en los 178 países disponibles.

Solicitado el 9-nov-2026 a las 22:17 (Panel de control → Producción → Solicitar acceso a producción). Google responde por correo al propietario de la cuenta, normalmente en 7 días o menos. Cuando lo conceda, hay que crear la versión en el canal Producción (se puede promocionar la 1.0.10 desde la prueba cerrada).

Respuestas enviadas:
1. Reclutamiento: We used a paid testing provider (Testers Community), which supplied the testers who opted in to the closed test.
2. Facilidad para reclutar: Fácil.
3. Participación: Testers installed Dovexa on their own phones and tablets and kept it during the 14-day test, receiving the updates we published (1.0.0 to 1.0.10). They opened CAD and 3D files and used the viewer tools. No tester reported crashes or blocking problems.
4. Comentarios: Testers did not report bugs or request features. We watched for feedback through Google Play's private tester feedback and through the testing provider, and we checked every build ourselves on a physical tablet.
5. Audiencia: Dovexa is for engineers, designers, machinists, 3D-printing users and students who need to view and check CAD, 3D and manufacturing files (STEP, IGES, DXF, STL, 3MF, G-code and others) on an Android phone or tablet.
6. Valor: Dovexa opens engineering and manufacturing files on the device: assemblies with a part tree, measurement, section views and several display modes. It is free and open source, works offline, has no ads and no account, and is available in 21 languages.
7. Descargas el primer año: entre 10.000 y 100.000.
8. Cambios durante la prueba: During the test we simplified the viewer toolbar, added a Settings screen (units, language, About, open-source licenses), corrected translations in 8 languages, translated the licenses screen, updated the privacy policy and renamed the app from Datum to Dovexa.
9. Por qué está lista: The closed test ran 14 days with 12+ testers and no reported crashes or blocking issues. The latest build (1.0.10) was checked on a physical tablet: loading a STEP file, rotating, part information and section views all work. Translations, licenses and privacy policy were reviewed.

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
