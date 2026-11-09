# 07 · Backlog

> **Documento histórico.** Es el plan original; el proyecto se cerró en la versión 1.0.10 (9-nov-2026) y las casillas no se actualizaron hasta el final. El estado real está en `README.md`, `docs/formatos/ESTADO.md` y `docs/13-publicacion.md`.

Prioridad: **P0** imprescindible para el hito, **P1** importante, **P2** deseable. Tamaño: S (horas), M (1–2 días), L (3–5 días), XL (más de una semana).
Estado: `[ ]` pendiente · `[~]` en curso · `[x]` hecho.

> **iOS no se publica en la App Store (D-11).** Los elementos de ficha, TestFlight, cuenta de Apple y privacidad de Apple (E5-06 a E5-09, E6-02) se leen solo para Android. iOS se mantiene funcionando en el código para uso propio.

## E0 · Infraestructura (M0)
- [ ] **E0-01** Crear proyecto Flutter para iOS y Android (minSdk 26, targetSdk 36, iOS 17+) y compilar en emulador y simulador. P0 · M
- [ ] **E0-02** Instalar `ninja` y CMake de escritorio, configurar `JAVA_HOME`; script `tools/setup.sh` que verifica el entorno. P0 · S
- [ ] **E0-03** Estructura del núcleo C++ (`core/`) con CMake para Android, iOS y macOS, y API en C (`dovexa.h`). P0 · L
- [ ] **E0-04** Compilar OCCT para Android (`arm64-v8a`, `x86_64`), iOS (dispositivo y simulador, como framework dinámico) y macOS, con script reproducible en `tools/`. P0 · XL
- [ ] **E0-05** Enlace Dart FFI ↔ API en C, funcionando en las dos plataformas. P0 · M
- [ ] **E0-06** Visor 3D nativo incrustado en Flutter (Metal en iOS, Vulkan/GLES en Android) con gestos de cámara. P0 · XL
- [ ] **E0-07** Prueba: STEP → teselado → malla en pantalla con cámara orbital, en simulador iOS y emulador Android. P0 · L
- [ ] **E0-08** Medir tamaño de la app, tiempo y memoria en cada plataforma; informe en `docs/`. P0 · S
- [ ] **E0-09** Comparar bgfx y Filament con aristas, selección y secciones; cerrar D-03. P0 · M
- [ ] **E0-10** `dovexa-cli` en escritorio: abre un archivo y vuelca estadísticas. P1 · M
- [ ] **E0-11** Integración continua con GitHub Actions (Linux y macOS) y caché de OCCT. P1 · L
- [ ] **E0-12** Lint y formato: `flutter analyze`, `dart format`, `clang-format`. P2 · S
- [ ] **E0-13** Integrar el icono y la marca (adaptable en Android, conjunto de iconos en iOS, tema). P1 · S
- [ ] **E0-14** Cerrar D-01 (licencia) y añadir `LICENSE` y avisos de terceros (OCCT, etc.). P0 · S

## E1 · Visor de mallas (M1)
- [x] **E1-01** Detector de formato por cabecera (`FormatDetector`). P0 · M
- [x] **E1-02** Lector STL binario y ASCII rápido (millones de triángulos). P0 · M
- [x] **E1-03** Lector OBJ con MTL. P0 · M
- [x] **E1-04** Lector 3MF (zip + XML, colores, unidades, varios objetos). P0 · L
- [x] **E1-05** Renderizador sobre la capa gráfica elegida: buffers, shaders, antialiasing (Metal y Vulkan/GLES). P0 · XL
- [x] **E1-06** Cámara orbital con inercia, desplazamiento y zoom al punto. P0 · L
- [x] **E1-07** Vistas estándar y centrar en el modelo. P0 · M
- [x] **E1-08** Sombreado con iluminación agradable y color por defecto. P0 · M
- [ ] **E1-09** Aristas por ángulo de pliegue. P1 · M
- [x] **E1-10** Carga en hilo de fondo con progreso y cancelación. P0 · M
- [ ] **E1-11** Abrir desde otras apps: en Android intenciones y `content://`; en iOS tipos de documento, Archivos y menú de compartir. P0 · L
- [ ] **E1-12** Pantalla de recientes y selector de archivos. P1 · M
- [x] **E1-13** Manejo de archivos corruptos y muy grandes sin cerrar la app. P0 · M

## E2 · STEP, IGES y ensamblajes (M2)
- [x] **E2-01** Importador STEP con XCAF: estructura, nombres, colores, capas. P0 · XL
- [x] **E2-02** Importador IGES y BREP. P1 · M
- [x] **E2-03** Modelo de escena con piezas e instancias. P0 · L
- [ ] **E2-04** Teselado con calidad configurable y niveles de detalle. P0 · L
- [ ] **E2-05** Carga progresiva: las piezas aparecen según se calculan. P0 · L
- [ ] **E2-06** Caché binaria por huella de archivo. P1 · L
- [ ] **E2-07** Aristas reales del B-rep. P1 · L
- [x] **E2-08** Árbol de ensamblaje (panel lateral) con expandir y contraer. P0 · L
- [x] **E2-09** Búsqueda por nombre con resaltado y filtro. P0 · M
- [x] **E2-10** Recuentos y lista de materiales (agrupa piezas iguales). P0 · L
- [x] **E2-11** Aislar, ocultar, mostrar todo; seleccionar tocando en el modelo. P0 · L
- [ ] **E2-12** Propiedades de pieza (nombre, tamaño, volumen, material si hay). P1 · M
- [ ] **E2-13** Presupuesto de memoria y aviso en modelos enormes. P1 · M
- [x] **E2-14** Formato propietario: detección y guía para exportar a STEP. P0 · M
- [ ] **E2-15** Corpus de pruebas y script de descarga (`testdata/`, `tools/`). P0 · M

## E3 · Modos de vista y herramientas (M3)
- [x] **E3-01** Modos: sombreado, con aristas, alambre. P0 · M
- [ ] **E3-02** Transparencia / rayos X por pieza o global. P1 · L
- [ ] **E3-03** Planos de corte X/Y/Z con tapa (stencil). P0 · XL
- [x] **E3-04** Medir: punto a punto, arista, cara, ángulo, radio. P0 · XL
- [ ] **E3-05** Caja envolvente y dimensiones totales. P0 · S
- [ ] **E3-06** Cubo de vistas (ViewCube) y vistas ortogonales/perspectiva. P1 · L
- [ ] **E3-07** Vista explosionada. P1 · L
- [ ] **E3-08** Vistas guardadas. P2 · M
- [ ] **E3-09** Colores personalizados y fondo. P2 · S
- [ ] **E3-10** Capturas de pantalla y compartir. P1 · M

## E4 · 2D y CAM (M4)
- [x] **E4-01** Lector DXF (líneas, arcos, círculos, polilíneas, splines, texto, bloques, capas). P0 · XL
- [x] **E4-02** Visor 2D con zoom, capas y medición. P0 · L
- [x] **E4-03** Lector de G-code (G0/G1/G2/G3, planos, cambios de herramienta). P0 · L
- [x] **E4-04** Visor de trayectorias con capas, rápidos distintos y estimación de tiempo. P1 · L
- [ ] **E4-05** DXF con caras 3D. P2 · M

## E5 · Producto y tienda (M5)
- [ ] **E5-01** Pantalla de inicio y primer uso (sin cuentas ni permisos innecesarios). P0 · M
- [ ] **E5-02** Ajustes: tema, unidades, calidad, idioma. P0 · M
- [ ] **E5-03** Español e inglés completos en recursos. P0 · M
- [ ] **E5-04** Accesibilidad y modo oscuro revisado. P1 · M
- [ ] **E5-05** Rendimiento y estabilidad: perfilado, fugas, ANR. P0 · L
- [ ] **E5-06** Política de privacidad (página pública), formulario de datos de Play, etiqueta y manifiesto de privacidad de Apple. P0 · M
- [ ] **E5-07** Ficha de Play y ficha de App Store: textos, capturas por tamaño de pantalla, imagen destacada. P0 · L
- [ ] **E5-08** Firma de la app para Android y certificados de iOS; copia segura de las claves. P0 · M
- [ ] **E5-09** Cuentas de Play Console (D-05) y de Apple Developer (D-11) configuradas. P0 · S
- [ ] **E5-10** Modelos de ejemplo incluidos en la app, para que no esté vacía en la revisión de Apple ni en el primer uso. P0 · S
- [ ] **E5-11** Pantalla de "Acerca de" con avisos de licencias de terceros (OCCT y demás). P0 · S

## E6 · Prueba cerrada y publicación (M6)
- [ ] **E6-01** Reclutar 12+ testers (comunidades de makers, talleres, estudiantes), también para TestFlight. P0 · L
- [ ] **E6-02** Android: prueba interna y luego cerrada durante 14 días. iOS: TestFlight y revisión de la App Store. P0 · L
- [ ] **E6-03** Canal de feedback y triage semanal. P0 · M
- [ ] **E6-04** Solicitud de acceso a producción. P0 · S
- [ ] **E6-05** Lanzamiento por fases y seguimiento de vitales. P0 · M

## E7 · Después
- [ ] **E7-01** DWG (solo vía SDK comercial; ver D-02). P2 · XL
- [~] **E7-02** FCStd, 3DM (pendientes); glTF y PLY hechos. P2 · L
- [ ] **E7-03** IFC. P2 · XL
- [ ] **E7-04** PMI: mostrar tolerancias y cotas del archivo. P2 · XL
- [ ] **E7-05** Comparar dos versiones de una pieza. P2 · XL
- [ ] **E7-06** Evaluar formatos nativos propietarios (D-04). P2 · L
- [ ] **E7-07** Anotaciones y exportar informe. P2 · L
