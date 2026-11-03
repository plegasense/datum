# 05 · Forma de trabajar (workflow)

## Reparto
| Tú | Claude |
|---|---|
| Decides producto y prioridades | Escribe, prueba y documenta el código |
| Pruebas en un móvil real y das tu ojo de usuario CAD/CAM | Monta la infraestructura, CI y herramientas |
| Cuenta de Play Console, identidad, política de privacidad | Prepara la ficha, capturas, textos y paquetes |
| Reclutas testers y comunidad | Analiza el feedback y lo convierte en tareas |
| Aportas archivos reales de tu trabajo (STEP, ensamblajes, DXF) | Los usa como corpus de pruebas |

## Ciclo de cada tarea
1. **Definir.** Una tarea del backlog (`07-backlog.md`) con criterios de aceptación.
2. **Rama corta.** `feat/<id>-nombre` desde `main`.
3. **Implementar con pruebas.** Núcleo en C++ con GoogleTest; interfaz con pruebas de UI.
4. **Verificar en vivo.** Compilar, abrir en el emulador, capturar pantalla. Si toca 3D, probar con archivos reales del corpus.
5. **Revisión.** Una pasada de revisión de código antes de fusionar.
6. **Fusionar a `main`** si CI está en verde.
7. **Registrar.** Actualizar el backlog y, si cambia una decisión, `06-decisiones.md`.

## Git
- Rama principal: `main`, siempre compila y pasa pruebas.
- Ramas cortas de funcionalidad. Mensajes de commit en formato *conventional commits* (`feat:`, `fix:`, `perf:`, `docs:`, `test:`, `chore:`).
- Versionado semántico: `0.1.0` (prueba cerrada) → `1.0.0` (producción).
- Etiquetas por cada versión que se sube a Play Console.
- Nada de archivos grandes ni de terceros en el repositorio: se descargan con scripts en `tools/`.

## Integración continua (cuando haya código)
En GitHub Actions, en cada pull request:
- Compilar el núcleo para escritorio y ejecutar sus pruebas.
- Compilar la app de Android (`flutter build apk --debug`) y la de iOS (simulador), y pasar `flutter analyze`, `dart format` y `clang-format`.
- Guardar el APK de depuración como artefacto, para instalar y probar rápido.
- OCCT precompilado para cada plataforma y cacheado, para no recompilarlo cada vez (tarda mucho).

## Definition of Done
- Cumple los criterios de aceptación.
- Pruebas automáticas que cubren lo nuevo.
- Probado en emulador y, si afecta al rendimiento, en móvil real.
- Sin regresiones de rendimiento frente a los presupuestos de `03-arquitectura.md`.
- Textos en español e inglés.
- Documentación actualizada.

## Seguimiento
- Backlog en `docs/07-backlog.md` (épicas, tareas, prioridad, tamaño).
- Cuando haya repositorio en GitHub, se vuelca a **GitHub Issues + Projects** (tablero Por hacer / En curso / Revisión / Hecho), con un máximo de 2 tareas en curso.
- Revisión semanal corta: qué se hizo, qué se prueba, qué se decide.

## Trabajar con Claude
- Una conversación por épica o hito, para que cada una conserve su contexto.
- Una sola persona escribe a la vez en cada zona del código (evita pisarse). Si hay trabajo en paralelo, cada uno en su propia rama y copia de trabajo (*worktree*).
- Siempre se deja el estado en el repositorio (código, backlog, decisiones), no solo en la conversación.

## Entorno de desarrollo (estado)
Revisado en este Mac (Apple Silicon, arm64):
- **Android, listo:** Android Studio, SDK con plataformas 33 a 36.1, NDK 28.2, CMake 3.22.1, JDK 21 incluido en Android Studio, emulador `Medium_Phone` con API 36.1 y Google Play.
- **iOS, listo:** Xcode 27.1, simuladores de iOS 27 (iPhone 18 Pro, iPhone Air…), CocoaPods y una identidad de firma "Apple Development" (equipo personal), que permite instalar en un iPhone propio por cable.
- **Compartido, listo:** Flutter 3.41, Git 2.54.
- **Falta:** `JAVA_HOME` apuntando al JDK de Android Studio (para compilar desde terminal), `ninja` y CMake para escritorio (Homebrew), y **ningún móvil físico conectado** (ni iPhone ni Android).
- Espacio libre en disco: unos 53 GB; OCCT para tres plataformas y las compilaciones ocupan varios GB.
- **Limitación:** las compilaciones de iOS solo funcionan en un Mac. Está bien, porque desarrollas en Mac.

## Publicación en Google Play
1. Cuenta de desarrollador (pago único, verificación de identidad). Decidir tipo de cuenta (D-05).
2. Firma de la app y copia segura de la clave (sin ella no se pueden publicar actualizaciones).
3. Prueba interna → **prueba cerrada con 12+ testers durante 14 días** → solicitud de acceso a producción.
4. Ficha: descripción, capturas, icono 512, imagen destacada, política de privacidad, formulario de seguridad de datos (aquí: "no recopila datos").
5. Lanzamiento por fases (20 % → 100 %) y vigilancia de los vitales de Play Console.

## Publicación en App Store
1. Cuenta del programa de desarrolladores de Apple (suscripción anual, a verificar el precio actual; D-11).
2. Identificador de la app, certificados y perfiles; archivo firmado desde Xcode.
3. **TestFlight** para probar con testers (no exige un mínimo de testers como Google).
4. Ficha en App Store Connect: capturas por tamaño de pantalla, descripción, política de privacidad, etiqueta de privacidad ("no recopila datos") y manifiesto de privacidad.
5. Revisión de Apple (suele pedir que la app sea útil y estable desde el primer uso; un visor sin archivos de ejemplo puede parecer vacío, así que incluiremos modelos de ejemplo).
6. Lanzamiento por fases opcional.

## Pruebas en dos plataformas
- Cada tarea que toque el visor o los archivos se prueba en Android **y** en iPhone.
- Ante diferencias de comportamiento, se corrige en el núcleo compartido siempre que se pueda.
- CI: ejecutores macOS de GitHub Actions para iOS (son más lentos y más caros que Linux; gratis en repositorios públicos con límites).
