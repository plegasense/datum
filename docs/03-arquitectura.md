# 03 · Arquitectura (iOS + Android)

## Resumen
**Un solo núcleo en C++ y un solo renderizador para las dos plataformas**, con una interfaz compartida. Así Dovexa se comporta igual en iPhone y en Android, y el trabajo difícil (leer formatos, entender ensamblajes, dibujar) se hace una vez.

> Esta arquitectura **cambió** al decidir que Dovexa sea para iOS y Android. Antes era Kotlin + OpenGL ES solo para Android. OpenGL ES está en desuso en iOS, y duplicar el núcleo en dos lenguajes sería carísimo.

```
┌──────────────────────────────────────────────────┐
│ UI compartida (Flutter / Dart)                   │
│  inicio · recientes · árbol · búsqueda · lista   │
│  de materiales · ajustes · paneles               │
│  ── hueco nativo para el visor 3D ──             │
└──────────────┬───────────────────────────────────┘
               │ Dart FFI sobre una API en C (datum.h)
┌──────────────▼───────────────────────────────────┐
│ core/  (C++17, compartido)                       │
│  io/    importadores (STL, OBJ, 3MF, STEP…)      │
│  model/ escena: nodos, piezas, instancias        │
│  tess/  teselado y niveles de detalle            │
│  render/ renderizador sobre bgfx o Filament      │
│  tools/ selección, medición, secciones           │
│  cache/ caché binaria de mallas                  │
└──────────────┬───────────────────────────────────┘
               │
   Metal (iOS)        Vulkan / OpenGL ES (Android)
   third_party/  OCCT · lib3mf · bgfx …
```

## Decisiones técnicas
- **Plataformas:** Android minSdk 26, targetSdk 36 (Google lo exige a apps nuevas desde el 31/08/2026). iOS 17 o superior (a confirmar).
- **Núcleo:** C++17, una API en C estable (`datum.h`) que Dart consume por FFI en ambas plataformas, sin código puente distinto en cada sistema. El código específico de plataforma se reduce a crear la superficie de dibujo y recibir archivos.
- **Gráficos:** capa multiplataforma. Candidatas: **bgfx** (BSD; control de bajo nivel y shaders propios) o **Filament** (Apache-2.0; más estructurado). Se decide con una prueba en M0 (D-03). Ya no vale solo OpenGL ES.
- **Interfaz:** Flutter (ya instalado en este Mac). Riesgo principal: **incrustar un visor 3D nativo a 60 fps con gestos fluidos dentro de Flutter**. Se valida en M0 (D-10). Plan B: dos carcasas nativas finas (SwiftUI y Compose) sobre la misma API en C.
- **Sin permiso de Internet en Android** y sin uso de red en iOS. Sin analítica. Privacidad comprobable.
- **Distribución:** AAB para Google Play; archivo firmado de Xcode para App Store y TestFlight.

## ¿Por qué Flutter ahora, si antes dije que no?
Con solo Android, Kotlin era la mejor opción. Con iOS y Android, tener una única interfaz compensa. Pero el visor 3D en sí **no es Flutter**: es C++ dibujando en una superficie nativa. Flutter pinta el resto.

| Opción | A favor | En contra |
|---|---|---|
| **Flutter + núcleo C++** (propuesta) | Una sola UI; ya instalado; FFI directo al C | Incrustar la vista 3D requiere trabajo; dos lenguajes (Dart, C++) |
| Kotlin Multiplatform / Compose Multiplatform + núcleo C++ | Un solo lenguaje de UI (Kotlin) | iOS sigue madurando; puente distinto por plataforma |
| Dos UIs nativas (SwiftUI y Compose) | Máxima calidad nativa en cada sistema | El doble de trabajo en paneles, árbol, ajustes y pruebas |

## Licencias que condicionan la arquitectura
- **OCCT:** LGPL-2.1 con excepción. No encontré cambio de licencia en su versión 8.0. En iOS hay que enlazarlo como **framework dinámico** y publicar las modificaciones que le hagamos; así se suele cumplir la LGPL en la App Store. Habrá que revisar el texto de licencia con calma.
- **GPL en nuestro código:** choca con la App Store. Por eso **no usamos libdxfrw ni LibreDWG** (GPL). El lector DXF es propio y DWG queda fuera por ahora. Ver D-01 y D-02.

## Modelo de datos (escena)
Pensado para ensamblajes grandes:
- **Pieza (Part):** geometría única, teselada una sola vez.
- **Instancia (Instance):** referencia a una pieza con matriz de transformación. 1000 tornillos iguales = 1 malla, 1000 instancias.
- **Nodo (Node):** árbol de ensamblaje con nombre, visibilidad, color, capa y propiedades.
- **Material y color:** los del archivo si existen.

Es lo que permite árbol, búsqueda por nombre, recuentos, aislar y ocultar.

## Canal de importación
1. Detectar formato por cabecera.
2. Leer estructura (OCCT XCAF para STEP/IGES).
3. Teselar piezas en hilos de fondo, **mostrándolas según están listas**.
4. Caché binaria por huella de archivo: la segunda apertura es casi instantánea.
5. Presupuesto de memoria y niveles de detalle. **iOS mata las apps que gastan demasiada memoria, así que el presupuesto es más estricto que en Android.**

## Renderizado
- Dibujo instanciado, aristas de CAD reales (las del B-rep; para mallas, por ángulo), antialiasing, transparencia, planos de corte con tapa (stencil), selección por identificadores y medición sobre geometría.
- Los mismos shaders para las dos plataformas gracias a la capa gráfica.

## Interfaz
- Una pantalla principal: el visor, barra mínima y paneles que salen del borde.
- Cubo de vistas, gestos naturales, centrar en selección.
- Claro y oscuro, español e inglés desde el primer día, accesibilidad.
- Integración con archivos: en Android, intenciones y selector del sistema; en iOS, tipos de documento (UTType) para `.stl .step .dxf…`, Archivos y menú de compartir.

## Presupuestos de rendimiento (a validar)
| Métrica | Objetivo |
|---|---|
| Arranque en frío | < 1,5 s |
| STEP de 10 MB, primera apertura | < 5 s en gama media |
| Segunda apertura (con caché) | < 1 s |
| Fluidez al girar | 60 fps hasta ~2 M de triángulos en gama media |
| Memoria | < 1 GB en Android; menos en iPhone antiguos (se mide) |

## Calidad y pruebas
- **Núcleo en escritorio:** GoogleTest y `datum-cli` (abre un archivo y vuelca estadísticas y mallas de referencia). Itera mucho más rápido que en emulador.
- **Móvil:** pruebas de UI y capturas en los simuladores de iOS y en el emulador Android; rendimiento en móviles físicos de ambos sistemas.
- **Corpus de archivos** versionado (ver `02-formatos.md`).
- Los archivos corruptos o enormes **nunca** deben cerrar la app; se prueban con fuzzing básico.
