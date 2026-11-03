# 08 · Informe de M0 y primer M1/M2 (24/10/2026)

## Decisiones que se han cerrado con datos
| Tema | Resultado |
|---|---|
| **Renderizado** | **Flutter GPU** (Impeller): shaders propios, MSAA 4x, profundidad, modo alambre. Sin bgfx ni Filament. Probado en iOS y macOS. Está en preview y se fija a Flutter 3.47.8 |
| **Interfaz** | Flutter, un solo código para iOS y Android. El visor 3D se dibuja dentro de Flutter, sin vistas nativas incrustadas |
| **Núcleo** | C++ con Open CASCADE 8.0.1, compilado por el *hook* de Flutter (native assets) para cada plataforma, API en C (`core/include/datum.h`) |
| **STL, OBJ, 3MF** | Lectores propios en Dart (isolates), sin dependencias nativas |

## Resultados con archivos reales (corpus local, 1,4 GB)
| Formato | Archivos | Resultado |
|---|---|---|
| STEP/STP | 83 | Todos abren. Ensamblajes de SolidWorks con piezas e instancias; 20–660 ms |
| 3MF | 21 | Todos abren, incluidos proyectos de Bambu Studio con 34 piezas |
| STL / OBJ | 26 | Todos abren. 89 MB y 1,87 M de triángulos en ~80 ms (binario) |
| iPhone (simulador) | | STL de 1,87 M de triángulos dibujado con profundidad y MSAA; STEP de ensamblaje con árbol, búsqueda, selección y lista de piezas |

## Lo que NO está verificado
- **Android:** la app compila (APK de depuración), pero el emulador de este Mac (2,5 GB de RAM) se queda en la pantalla de inicio. Falta probar en un emulador con más memoria o en un móvil físico. OCCT para Android sin compilar todavía.
- **iPhone físico:** sin probar; OCCT para dispositivo sin compilar.
- **Rendimiento real:** solo medido en simulador y en Dart de escritorio. El STL de 547 MB (11 M de triángulos) del corpus no se ha probado.
- **Formatos propietarios** (`.sldprt`, `.ipt`, `.prt`: 400+ archivos del corpus): detectados y explicados, no abiertos. Es la mayoría de tu biblioteca.

## Incidencias técnicas encontradas (y resueltas)
1. iCloud añade atributos a `~/Documents` y `codesign` de iOS falla: compilar fuera (enlace `app/build` → `~/Library/Caches/Dovexa`).
2. El Flutter global (3.41) no era compatible con Xcode 27: Flutter propio en `~/development/flutter-datum` (3.47.8).
3. `file_picker` 13 cambió su API.
4. El simulador de iOS compila también x86_64: pieza vacía (`datum_stub.cpp`) para esa arquitectura.
5. Una pantalla de captura en macOS no es posible desde este entorno; las capturas automáticas se hacen en el simulador de iPhone.


## Actualización: DXF y G-code (24/10/2026)
| Formato | Corpus | Resultado |
|---|---|---|
| DXF | 4 archivos (3 planos de corte láser de 2500×1250 en formato R12 con POLYLINE/INSERT, 1 logo en R2010 con LWPOLYLINE) | Todos abren. 20–150 ms. Capas, colores ACI, arcos y bulges, splines, bloques, texto |
| G-code | 1 archivo Bambu de 31 MB (1,54 M de movimientos de trabajo, 881 capas, 4 filamentos) + 1 ejemplo de fresado propio (arcos G2/G3 y rampa helicoidal) | Abren. ~300–450 ms. Barra de progreso por movimiento/capa, colores por tipo/herramienta/velocidad, tiempo estimado leído de la cabecera |
| DWG | 6 archivos | No se abren: se explica cómo guardarlos como DXF |

Herramientas nuevas: capas, medición con ajuste al vértice (distancia, ΔX, ΔY y ángulo), textos del dibujo, líneas engrosadas (varias pasadas desplazadas un píxel).

### Fallo importante encontrado y corregido
La matriz de proyección usaba profundidad en [-1, 1] (OpenGL). **Metal y Vulkan usan [0, 1]**, así que se recortaba la mitad delantera de la escena. Corregido en `camera.dart` y comprobado con una prueba numérica (`test/camera_test.dart`) y en pantalla. Afectaba también a los modelos 3D de capturas anteriores.

### Pendiente
- DXF: sombreados (HATCH), cotas (DIMENSION), texto MTEXT con formato, unidades ($INSUNITS).
- G-code: grosor real de la extrusión, animación de reproducción, estimación de tiempos propia, `.gcode.3mf` (G-code dentro del 3MF).
- iCloud crea copias "X 2" de archivos en `~/Documents` (43 en este proyecto, ya borradas); conviene mover el proyecto a una carpeta que no se sincronice.


## Actualización: formatos nuevos y fallo del encuadre (24/10/2026)
- **Nuevos:** PLY, glTF/GLB, VRML 2.0, `.stpz`, SVG, HPGL, XYZ/PTS/PCD (nubes de puntos) y `.bgcode`. Detalle de cómo se comprobó cada uno en `02-formatos.md`.
- **Nube de puntos** como tipo nuevo de documento: puntos con tamaño propio, color original, por altura o liso.
- **Fallo corregido (afectaba a la primera apertura de cada sesión):** la cámara usaba una relación de aspecto de 1:1 al encuadrar el primer archivo, porque la vista aún no se había dibujado; por eso el primer modelo salía recortado en un móvil vertical. Ahora usa el tamaño de la pantalla.
- **Fallo corregido:** las líneas se dibujaban sin las pasadas de grosor (el código no se había aplicado); ahora los dibujos y el G-code se ven más gruesos y los puntos tienen tamaño.
- Pruebas: `tool/bench_docs.dart` abre todo con el cargador universal. Resultado: 16 de 16 muestras nuevas y 137 de 137 archivos reales del corpus.

## Android (24-oct-2026)
- OCCT compilado para arm64-v8a (`tools/build_occt_android.sh`). El hook enlaza además `m` y `log`.
- Emulador `Medium_Phone_API_36.1` con 6 GB de RAM y GPU del anfitrión; arranca en ~40 s.
- Verificado: STEP (OCCT) y DXF abren y se dibujan con Flutter GPU, con Impeller en OpenGLES (por defecto en el emulador) y en Vulkan.
- Fallo encontrado y corregido: al arrancar, Android no da tamaño a la ventana, el encuadre salía NaN y no se dibujaba nada. Ahora se reencuadra al conocer el tamaño.
- Script de pruebas: `tools/shot_android.sh <archivo> <salida.png>`.
- Pendiente: probar en un móvil físico; compilar OCCT para x86_64 solo si hace falta.
