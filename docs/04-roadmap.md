# 04 · Roadmap

Los hitos van en orden. **Cada uno termina en algo que se puede ver y probar.** Los esfuerzos son estimaciones gruesas de trabajo efectivo, no fechas; se reajustan tras M0.

| Hito | Objetivo | Esfuerzo |
|---|---|---|
| M0 | Preparación y prueba de viabilidad (iOS y Android) | 2–3 semanas |
| M1 | Visor de mallas con navegación excelente | 2–3 semanas |
| M2 | STEP/IGES y ensamblajes | 3–4 semanas |
| M3 | Modos de vista y herramientas | 3–4 semanas |
| M4 | 2D y CAM: DXF y G-code | 2–3 semanas |
| M5 | Producto y preparación de la tienda | 2–3 semanas |
| M6 | Prueba cerrada y publicación | 3–4 semanas (la prueba exige 14 días) |
| M7 | Después del lanzamiento | continuo |

## M0 · Preparación y prueba de viabilidad
**Objetivo:** confirmar que las dos apuestas técnicas funcionan antes de construir encima.
- Proyecto Flutter que compila y arranca en el emulador Android (API 36.1) y en un simulador de iPhone (Xcode 27.1 ya instalado).
- OCCT compilado para Android (`arm64-v8a`, `x86_64`), iOS (dispositivo y simulador) y macOS.
- Prueba en **las dos plataformas**: abrir un STEP, teselarlo y dibujarlo con cámara orbital.
- Probar la incrustación del visor 3D nativo dentro de Flutter: 60 fps y gestos fluidos.
- Medir tamaño de la app, tiempo de teselado y memoria en cada plataforma.
- Comparar bgfx y Filament sobre un modelo con aristas y selección (cubre Metal y Vulkan).

**Puerta de decisión:** (1) si OCCT en el móvil es inviable (tamaño o tiempo), plan B: motor STEP más ligero o teselado previo. (2) Si Flutter no logra incrustar el visor con fluidez, plan B: dos carcasas nativas finas (SwiftUI y Compose) sobre el mismo núcleo. (3) Se elige capa gráfica.
**Listo cuando:** vídeo corto del STEP girando en iPhone y en Android, y un informe de medidas.

## M1 · Visor de mallas
STL, OBJ, 3MF. Cámara orbital con inercia, desplazamiento, zoom al punto, vistas estándar y centrar. Sombreado y aristas. Abrir desde el gestor de archivos. Carga en hilo de fondo con progreso.
**Listo cuando:** abre un STL de 1 M de triángulos y gira a 60 fps en un móvil de gama media.

## M2 · STEP/IGES y ensamblajes
Importación con XCAF, instancias, colores, nombres. Árbol de ensamblaje con búsqueda, recuentos, aislar y ocultar. Carga progresiva y caché.
**Listo cuando:** un ensamblaje real de varios cientos de piezas se abre, se explora y se busca por nombre con fluidez.

## M3 · Modos de vista y herramientas
Alambre, sombreado con aristas, rayos X. Planos de corte con tapa. Medición (punto, arista, cara, distancia, ángulo). Vista explosionada. Vistas guardadas. Cubo de vistas.

## M4 · 2D y CAM
Visor DXF con capas y medición. Visor de G-code (trayectorias, capas, desplazamientos rápidos, estimación de tiempo).

## M5 · Producto y tienda
Pantalla de inicio y recientes, ajustes, tema, idiomas, accesibilidad, mensajes claros de error y de formatos no soportados, rendimiento y estabilidad, icono y marca definitivos (ya hechos), política de privacidad, capturas y descripción de la ficha, cuenta de Play Console.

## M6 · Prueba cerrada y publicación
- **Android:** las cuentas personales nuevas de Play Console **necesitan una prueba cerrada con al menos 12 testers durante 14 días seguidos** antes de publicar en producción (ver `05-workflow.md` y D-05).
- **iOS:** pruebas con TestFlight y revisión de la App Store. Requiere cuenta del programa de desarrolladores de Apple (D-11).
- Reclutar testers desde ya, corregir lo que salga, publicar por fases en ambas tiendas.

## M7 · Después
DWG, IFC, 3DM, FCStd, PMI, comparación de versiones, anotaciones; evaluar los formatos propietarios (ver `02-formatos.md`).

## Riesgos principales
| Riesgo | Mitigación |
|---|---|
| Tamaño de la app por OCCT | AAB por ABI en Android, compilar solo los módulos necesarios; medirlo en M0 en las dos plataformas |
| Visor 3D dentro de Flutter | Probarlo en M0; plan B con carcasas nativas finas |
| Memoria en iPhone (el sistema cierra apps que gastan demasiado) | Presupuesto de memoria más estricto y modelos por partes |
| La GPL choca con la App Store | Sin librerías GPL; licencia permisiva (D-01) |
| Teselado lento en móvil | Hilos de fondo, carga progresiva, caché, niveles de detalle |
| Modelos enormes sin memoria | Presupuesto de memoria, carga por instancias, aviso al usuario |
| Formatos propietarios | Detectar y guiar, ver `02-formatos.md` |
| Los 12 testers de Play Console | Empezar a reclutar en M3 |
| Licencias (LGPL de OCCT en iOS) | Enlazar como framework dinámico y revisar la licencia, ver arquitectura |
| Dependencia de una sola persona | Documentar todo, automatizar con CI y `build_logo.py`-style scripts |
