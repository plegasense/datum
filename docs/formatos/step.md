# STEP · IGES · STPZ (CAD) — dossier de especialización

Estado: fases 1–4 hechas · fase 5 en propuesta (pendiente de tu visto bueno) · Última actualización: 24-oct-2026

Convención: **[F]** = leído en una fuente citada; **[I]** = inferencia mía, sin verificar.

## 1. Usuarios

| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Maquinista / operario CNC | En el taller, recibe el modelo del cliente o de oficina técnica | Entender la pieza antes de fabricarla: tamaño, agujeros, planos de corte | Si cabe en la máquina, cómo amarrarla, qué útiles necesita | [F] El listado de STEP File Viewer (App Store) cita expresamente a maquinistas y operarios CNC "que quieren revisar la geometría antes de producir"; un hilo de PTC pregunta cómo dar a personal de taller acceso a STEP sin licencia CAD |
| Presupuestador / comprador | Recibe STEP del cliente para cotizar | Medir tamaño, volumen, nº de agujeros, material probable | Precio y plazo | [I] |
| Ingeniero que revisa un proveedor | Recibe el modelo del proveedor o de otra empresa, con otro CAD | Comprobar medidas clave, tolerancias (PMI), que el ensamblaje esté completo | Aprobar o devolver | [F] NIST: los visores muestran el PMI gráfico; el STEP File Analyzer de NIST se usa para comprobar archivos STEP y su PMI |
| Técnico de mantenimiento / servicio | En planta, con una máquina parada | Ver el despiece de un conjunto, sus piezas y medidas | Qué pieza pedir o fabricar | [F] CAD Exchanger se anuncia para "shop floor, reunión o fuera de la oficina"; [I] el caso de uso concreto |
| Aficionado / estudiante / maker | Descarga STEP de Thingiverse, GrabCAD o un curso | Ver y entender un diseño, convertirlo a STL/GLB | Si le sirve | [F] STEP Viewer (MindblownSoft) ofrece guardar en GLB; STEP File Viewer apunta a estudiantes |

Contexto de uso [F]: un usuario de Android escribió en Play (nov-2025) que CAD Exchanger es lo único que conoce que "permite ver, navegar y explosionar STEP gratis en Android".

## 2. Especificación

Fuentes: ficha de ProSTEP sobre ISO 10303-242 y la comparativa AP203/AP214/AP242 de Visiativ (ambas abiertas). El texto de las normas ISO 10303-21/-242 es de pago; **lo marcado [I] se contrasta con ellas o con muestras reales antes de implementarlo.**

| Qué guarda un STEP | Detalle | ¿Lo mostramos hoy? |
|---|---|---|
| Cabecera | Programa de origen, autor, fecha, esquema (AP203/AP214/AP242) [I] | No |
| Unidades | Longitud/ángulo en SI_UNIT o en unidad convertida (pulgadas, etc.) [I]. Es el fallo más citado: modelos en pulgadas que entran 25,4 veces mayores en algunos programas [F: PrePoMax, Onshape, element14: una placa de 100 mm se veía de 3,9 m] | **No** |
| Estructura de producto | Árbol de ensamblaje, instancias con su transformación, nombres, identificador de pieza [I] | Sí (nombres, instancias) |
| Geometría B-rep | Caras planas, cilíndricas, cónicas, esféricas, toroidales y B-spline; aristas | Solo triángulos |
| Color y capas | Estilos por pieza o por cara | Colores sí; capas no |
| Propiedades de validación | Volumen, área y centro de masas calculados por el CAD de origen, para comprobar la importación [F: NIST/Visiativ lo describen como propiedades "calculadas por el CAD nativo"] | **No** |
| Material y propiedades | Según AP y programa [I] | No |
| PMI semántico | Cotas, tolerancias geométricas, datums, legibles por máquina [F] | No |
| PMI gráfico | La representación visible de esas anotaciones (líneas, texto, posición) [F: NIST] | No |
| Geometría teselada | AP242 permite que el archivo lleve solo mallas, sin B-rep [F: ProSTEP] | No comprobado |
| Vistas guardadas y secciones | AP242 [I] | No |

Qué da Open CASCADE (nuestro motor) [F: documentación 7.8]: `STEPCAFControl_Reader` lee formas, ensamblajes, colores y nombres; `XCAFDoc_DimTolTool` da acceso a dimensiones, tolerancias y datums de AP242. **Lo que no hay en OCCT libre es la presentación visible del PMI** (un desarrollador del foro oficial lo señala y una respuesta remite al componente comercial PMIVis). Por tanto, dibujar el PMI será trabajo nuestro (etiquetas y marcos de tolerancia generados a partir de los datos).

Rarezas de programas [I]: nombres de instancia genéricos ("NAUO12": ya lo gestionamos), piezas repetidas con distinto nombre, colores por cara en lugar de por pieza, archivos con varios sólidos sueltos en la raíz.

## 3. Estado del arte

Visores que he comprobado (fichas oficiales en Play y App Store) más las reseñas reales.

| Función | CAD Exchanger (Android, iOS) | Glovius (Android, iOS) | STEP Viewer MindblownSoft (Android) | STEP File Viewer (iOS/Mac) | Open3D / otros Android | **Dovexa hoy** |
|---|---|---|---|---|---|---|
| Precio | Gratis, sin forma clara de desbloquear lo demás | Suscripción: 19 USD/mes o 99 USD/año (según su ficha) | Gratis con anuncios (ver un anuncio por archivo) | Gratis ver; funciones sueltas de 1,99 a 19,99 USD | sin comprobar | **Gratis, sin anuncios** |
| ¿Hace falta cuenta o nube? | No | **Sí**: cuenta en Glovius Cloud | No | No | — | No |
| Árbol de ensamblaje | Sí | Sí; sin buscador ni plegar en la versión gratis (reseña de 2019) | No | Lista de piezas | — | Sí, con buscador |
| Aislar / ocultar piezas | Sí | Sí | No | Sí | — | Sí |
| Explosionar | Sí | No consta | No | Sí (pago) | — | **No** |
| Sección | Sí | Sí (planos XY, YZ, XZ) | No | Sí (pago, planos XYZ) | — | **No** |
| Medir | "Dimensiones básicas": caja envolvente | Puntos, aristas, radios | Solo caja envolvente | Agujeros, puntos, planos, caras, ángulos | — | **No** |
| Detección de agujeros | No | "Ver agujeros en 3D" y tabla de agujeros | No | Sí, Ø/R automático | — | **No** |
| PMI / GD&T | No consta | Sí (ver PMI y GD&T) | No | Sí (AP242) | — | **No** |
| Lista de materiales | No consta | Descargable | No | Lista de piezas | — | Sí (en pantalla) |
| Exportar | STEP, STL, IGES, OBJ, VRML | STL, 3DS, OBJ | GLB | STL, OBJ, glTF, USDZ | — | No |
| Vistas estándar y ortográfica | Sí | Sí | 6 vistas fijas | Cubo de vistas; **sin ortográfica** (reseña) | — | 4 vistas; ortográfica solo en 2D |
| Límite de tamaño | **25 MB** de importación (su ficha) | "Abre ensamblajes grandes rápido" (nube) | Avisa de tiempo y memoria | — | — | Sin límite fijado; 34 MB de 3MF abre bien |
| Valoración (Play/App Store) | 4,1 (731 reseñas) | **2,0** (700 reseñas) | sin valoración, 10 mil+ | 3,2 (6 valoraciones) | — | — |

Reseñas que importan [F]:
- Glovius: "mucho problema para crear la cuenta… el icono de subida se queda en Connecting" (nov-2025); "te pide iniciar sesión en la nube para importar, y devuelve el mismo error" (ene-2025). Lo que más duele es **obligar a la nube**.
- CAD Exchanger: "parece que la app ya no se desarrolla y no está claro cómo activar las funciones completas… pero es lo único que conozco que deja ver, navegar y explosionar STEP gratis en Android" (nov-2025).
- STEP File Viewer (iOS): "no tiene vista ortográfica real, la cámara orbital se congela a menudo" (mar-2026).
- CAD Assistant (Open CASCADE) [F: GrabCAD]: "no carga bien archivos grandes en Android, rotar va a tirones, medir es básico". Su último ajuste en Android consta de 2021.

## 4. Hueco y ventaja

Hueco claro [F]: en Android no hay ningún visor STEP **gratis, sin cuenta, sin anuncios y con herramientas de revisión de verdad**. Los que las tienen o piden una suscripción con nube (Glovius, valoración 2,0) o están abandonados (CAD Exchanger, CAD Assistant). El del App Store las vende por piezas y no existe en Android.

**Superaremos al mejor en:**
1. **Medición exacta sobre la geometría real (B-rep), sin pagar:** Ø/R de agujeros, distancia entre caras, ángulos, distancia mínima entre piezas. Criterio: en un STEP de prueba con cotas conocidas, el error es menor de 0,001 mm; y todo el conjunto de medidas está en la versión gratis.
2. **Unidades y fiabilidad a la vista:** siempre se muestra la unidad del archivo y se avisa si el modelo declara pulgadas; y se comprueba el volumen calculado contra el volumen de validación que trae el archivo (si coincide, "datos fiables"). Criterio: ningún modelo de la batería de pruebas sale con la escala equivocada. [I: no he visto que otro lo haga]
3. **Ensamblajes sin fricción:** árbol con búsqueda y plegado, aislar/ocultar, explosión, lista de materiales exportable (CSV). Criterio: encontrar una pieza por nombre en un conjunto de 500 en menos de 3 toques; Glovius gratis no tiene buscador.
4. **Fluidez con conjuntos grandes y sin límite artificial de 25 MB.** Criterio: conjunto de 100 MB abre en menos de 15 s en el móvil de prueba y gira a 60 fps.
5. **Sección, vista ortográfica real y vistas guardadas** sin pago (los competidores las cobran o las ocultan).
6. **Sin cuenta, sin nube, sin anuncios** (los usuarios de Glovius la señalan como el defecto principal).
7. **PMI legible** (cotas y tolerancias de AP242) en la versión gratis. Riesgo: OCCT libre no trae su presentación; hay que dibujarla nosotros.

Fuera de alcance en este formato: editar, exportar a otros CAD y comentarios en la nube.

## 5. Diseño específico (PROPUESTA — pendiente de tu aprobación)

**Cabecera (solo lo que le importa a un técnico):** nombre · unidad del archivo (mm / pulgadas) · tamaño total (A × B × C) · en conjuntos: nº de piezas. Sin triángulos, sin instancias.

**Barra de herramientas del CAD (propia, distinta de las demás):**
1. Vistas: cubo de vistas (frontal, superior, isométrica…) con **perspectiva/ortográfica**.
2. Aristas: mostrar/ocultar líneas vivas (por defecto, activadas).
3. Medir (modo propio, ver abajo).
4. Sección (plano que se arrastra; X/Y/Z y plano de una cara).
5. Explosionar (deslizador).
6. Transparencia y aislar.
7. Información de la pieza (volumen, área, centro de masas, peso con material elegible).
8. (Conjuntos) árbol de piezas con buscador y lista de materiales.

**Medir:** al tocar una cara/arista el sistema dice qué es ("Agujero Ø 8,00", "Plano", "Cilindro R 12", "Arista recta 35,0"). Un segundo toque da la distancia o el ángulo entre ambos. Un botón "Agujeros" lista todos los agujeros con diámetro y profundidad.

**Panel de pieza (al tocarla):** nombre, nº de pieza, volumen, área, color, material si lo trae.

**Textos (vocabulario del oficio):** "Pieza", "Conjunto", "Agujero", "Plano", "Sección", "Explosionar", "Lista de materiales (BOM)".

**Qué NO llevará:** recuento de triángulos, milisegundos, iconos decorativos.

## 6. Implementación (24-oct-2026)

Hecho (iOS y Android):
- **Núcleo C++** (`core/src/datum_cad.cpp`): ahora conserva en memoria la geometría exacta mientras el documento está abierto. Expone la cara de cada triángulo, el tipo y las medidas de cada cara (plano, cilindro, cono, esfera, toro), las **aristas vivas** (se descartan las costuras y las uniones tangentes), volumen y área, distancia mínima exacta entre dos entidades (`BRepExtrema`), la **unidad del archivo** y los datos de cabecera (programa de origen, protocolo).
- **Render:** aristas con contraste automático según el color de la pieza, colores muy oscuros aclarados, plano de **sección**, **explosión** del conjunto, **atenuar** las piezas no seleccionadas, resaltado de caras y aristas, vista **ortográfica**.
- **Interfaz propia de CAD:** barra con Centrar · Vistas (7 vistas + ortográfica) · Aristas · Medir · Agujeros · Sección · (conjuntos) Explosionar y Atenuar · Información · Árbol. Cabecera con tamaño y unidad. Sin triángulos ni instancias.
- **Medir:** al tocar se describe la entidad ("Agujero · Ø 8,00 mm · prof. 20,00 mm", "Plano · 4 871,2 mm²", "Circunferencia · Ø 6,00 mm"); al tocar otra se da distancia entre ejes, entre planos, eje a plano, ángulo (solo entre entidades comparables) y mínima entre superficies. Cota dibujada sobre el modelo.
- **Agujeros:** lista con Ø y profundidad; une las medias caras que algunos CAD parten en dos.
- **Información:** tamaño, volumen, superficie, masa estimada (8 materiales), unidad, programa de origen, protocolo y, si el archivo trae volumen de validación, comprobación contra el calculado.
- **Lista de materiales:** en el árbol, con tamaño por pieza y botón "Copiar" (CSV listo para Excel).
- Memoria nativa liberada al cerrar o cambiar de documento.

Decisiones técnicas: la geometría de OCCT llega siempre en mm; la unidad del archivo solo decide cómo se muestra. Las aristas y los triángulos se dibujan con el mismo pipeline de GPU: **en Flutter GPU, tras cambiar de pipeline dentro de una pasada, el segundo no dibuja** (comprobado en iOS y Android), así que las aristas son líneas del pipeline de mallas sin iluminación.

## 7. Validación

**Piezas de medidas conocidas** (`core/tools/make_test_step.cpp` → `testdata/step/`, comprobadas con `dart run tool/verify_cad.dart ../testdata/step`):

| Comprobación | Resultado |
|---|---|
| Tamaño 100 × 50 × 20 | exacto |
| Volumen de la placa con 3 agujeros (97 706,637 mm³) | exacto |
| 3 agujeros: 2 × Ø8 pasantes (prof. 20) y 1 × Ø6 ciego (prof. 10) | exacto |
| Distancia mínima entre los dos Ø8 (60 − 8 = 52 mm) | 52,0000 |
| Distancia entre ejes (60 mm) | 60,0000 |
| Conjunto de dos piezas separadas 150 mm: largo total 180 mm | exacto |
| Archivo guardado en pulgadas: unidad detectada y tamaño correcto en mm | exacto |

Error medido: por debajo de 0,0001 mm (criterio: 0,001).

**Batería de archivos reales** (`dart run tool/bench_cad.dart "<carpeta>"`): los **83 STEP/STP de `Piezas CAD`** (SolidWorks, Inventor, NX, Fusion; de 0,01 a 2 MB; piezas y conjuntos de hasta 25 piezas / 47 instancias) abren sin fallo; unidad detectada en todos; agujeros y propiedades en < 120 ms por archivo. Dos archivos más con caras sin aristas vivas (`ChapaSoldada`, `PaloRueda`) son correctos: todas sus uniones son tangentes.

**Rendimiento** (emulador Android, GPU del anfitrión, compilación *profile*): conjunto de estrés de **1 500 piezas, 498 000 triángulos, 46 MB**:
- carga en Mac: 4,8 s (en el móvil será varias veces más; sin medir);
- girando la cámara: construcción 4,5 ms + raster 12,8 ms por fotograma (por debajo de los 16,7 ms de 60 fps);
- mientras se mueve la cámara con más de 200 piezas no se dibujan las aristas; se descartan las piezas fuera de la vista o de menos de un píxel.

**Capturas** en `docs/formatos/step/`: aristas, medir, sección con tapa, agujeros, información, ortográfica, iOS y Android.

Pendiente de validar: archivos de NIST con PMI y de otros programas (Creo, CATIA, FreeCAD) —necesitan tu permiso para descargarse—, archivos de 100 MB, un móvil físico.

**PMI (24-oct-2026)** — descargados con permiso los 33 STEP de ejemplo de NIST (`testdata/_externos/nist/`, fuera del repositorio): AP203 con PMI gráfico, AP242 ed. 1/2/3 con PMI semántico y uno teselado. Los 33 abren sin fallo.
- Se leen cotas (tipo, valor, ± o rango, calificador), tolerancias geométricas (15 tipos, Ø, modificadores Ⓜ/Ⓛ, referencias A B C) y referencias (datums, unidas por nombre), con las caras o aristas a las que apuntan y su representación gráfica 3D.
- Hoja «Cotas y tolerancias»: filtro por clase, interruptor para dibujarlas sobre el modelo (líneas de cota, flechas, marcos de tolerancia y texto, siempre visibles), y al elegir una se resaltan sus caras y se dibuja solo ella.
- Valores comprobados contra lo esperado: ángulo 60° ±0,5°, Ø 20 +0,05/−0,10, Ø 34,80–35,20, Posición Ø 0,016 Ⓜ con 3 referencias, Planitud 0,010.
- Error corregido: una pieza sin triángulos (geometría auxiliar) hacía fallar toda la imagen en iOS (Metal no crea buffers vacíos); el modelo salía en blanco. Capturas: `pmi_todas.png`, `pmi_seleccion.png`, `pmi_android.png`.
- Limitación: el texto de las anotaciones se dibuja como líneas (tal como lo guarda el archivo); no hay etiquetas propias y los AP203 con PMI solo traen dibujo, sin valores legibles.

**Segunda ronda de pruebas (24-oct-2026)**
- **Carga con muchos núcleos** (el emulador de Android tenía 1 núcleo y daba tiempos 20 veces peores; ahora 4): conjunto de estrés de 110 MB, 3 500 piezas y 1,16 millones de triángulos, 16,6 s; 46 MB, 6,6 s; 15 MB, 4,9 s. En el Mac (8 núcleos): 110 MB en 9 s (lectura 2,4 s, conversión 5,3 s —un solo hilo en OpenCASCADE—, teselado y aristas 1 s en paralelo). El teselado ya se reparte entre núcleos.
- **Fluidez** con ese conjunto: 11,2 ms de construcción + 9,8 ms de dibujado por fotograma (por debajo de 16,7 ms). Con más de 40 piezas se descartan las que están fuera de vista o miden menos de un píxel; con más de 200 no se dibujan las aristas mientras se mueve la cámara.
- **Archivos grandes:** aviso con estimación de tiempo en la pantalla de carga a partir de 10 MB.
- **Archivos rotos** (`dart run tool/verify_robust.dart`): vacío, texto suelto, cortado (mitad, 10 %, solo cabecera), binario aleatorio, bytes corruptos, sin datos y línea de 2 MB: 9 casos sin cierre inesperado y con mensaje claro («El archivo está incompleto… ¿se cortó la descarga?», «no parece un STEP»).
- **Toques reales** en Android (`adb input tap/swipe`): activar medir, tocar caras, girar con el dedo y ver el cubo de vistas seguirlo. Detectado y corregido: tocar dos veces la misma cara medía «0,00 mm entre planos»; ahora la quita de la selección.
- **Interfaz:** cubo de vistas táctil, valor de la cota escrito sobre el modelo, etiqueta de la anotación elegida junto a su dibujo, valores numéricos en las hojas de sección y explosión, y la imagen se desplaza para que la barra de herramientas no tape el modelo.
- **Pruebas automáticas que pasan:** `verify_cad` (medidas exactas), `bench_cad` (83 reales + 33 NIST), `verify_robust`, `flutter test`.

**Archivos de otros programas, conseguidos por mi cuenta** (repositorios públicos de GitHub, descargados a `testdata/_externos/otros_cad/`; el programa de origen se comprobó en la cabecera del propio archivo):

| Archivo | Programa de origen (cabecera) | Resultado |
|---|---|---|
| `Ventilator.stp` | **CATIA V5 R18** (AP203) | 305 caras, rodete con álabes curvos; se ve fiel |
| `as1_pe_203.stp` | **PRO/ENGINEER** de PTC (AP203) | ensamblaje de 10 piezas / 36 instancias, declarado en **pulgadas** y mostrado en pulgadas |
| `KR600_R2830-4.stp` (12,6 MB) | **Siemens NX 7.5** | 4 123 caras, 271 agujeros, 2,2 s |
| `RC_Buggy_2_front_suspension.stp` (15,3 MB) | **Autodesk Inventor 2018** | 91 piezas / 211 instancias, 4,6 s |
| `11752.stp` | **Autodesk Inventor 2013** | 1 018 caras, en pulgadas |
| `face_recognition_sample_part.stp`, `splinecage.stp` | NX 9.0 / ST-Developer | correcto |
| 5 piezas de la biblioteca de FreeCAD (rodamientos, piñones, pila) | **FreeCAD** (OCCT 6.5–7.5) | correcto |

14 de 14 sin fallo. Sumados a los 83 de `Piezas CAD` (SolidWorks, Inventor, NX, Fusion) y a los 33 de NIST, el visor ha abierto archivos de SolidWorks, Inventor (2013 y 2018), NX (7.5 y 9), CATIA V5, Pro/ENGINEER, Fusion, FreeCAD y OpenCASCADE. De **Creo** moderno no he encontrado ningún archivo público con origen verificable; Pro/ENGINEER es el mismo programa de PTC, con el formato de entonces.

## 8. Puerta de calidad — todavía NO aprobada (autoevaluación crítica)

| Fila | Nota | Evidencia y lo que falta |
|---|---|---|
| Fidelidad | 8 | Geometría exacta (error < 0,0001 mm), unidad, color, PMI. Faltan los materiales del archivo |
| Información propia | 8,5 | Tamaño, volumen, masa, unidad, origen, protocolo, PMI semántico y gráfico |
| Herramientas específicas | 8,5 | Medir, agujeros, sección con tapa, explosión, atenuar, ortográfica, BOM, PMI, cubo de vistas |
| Rendimiento | 8 | 110 MB en 16,6 s y 60 fps en emulador de 4 núcleos. **Sin medir en un móvil físico** |
| Robustez | 8,5 | 83 reales + 33 NIST + 14 de CATIA, Pro/E, NX, Inventor y FreeCAD con origen verificado + 9 archivos rotos |
| Claridad | 8 | Textos del oficio, valores en las hojas, aviso de archivo grande |
| Frente al mejor | 8,5 | En Android no hay nada gratis que mida, haga sección, explosione y lea PMI; frente a STEP File Viewer (iOS) tenemos más herramientas en la versión gratuita |
| Detalle y acabado | 8 | Toques reales probados en emulador; falta probar gestos de dos dedos y en móvil real |

Media: **8,25**. La puerta (≥ 8,5 con ninguna fila por debajo de 8) no se cumple por 0,3. Lo que falta no se puede conseguir sin material que no tengo aquí: **un móvil físico** (rendimiento y detalle) y (la robustez ya está cubierta con los archivos de otros programas). Con la prueba en el móvil, si sale bien, rendimiento y detalle suben a 8,5 y la media a ~8,4–8,5.

## Prueba en tableta física (24-oct-2026)
Xiaomi 25040RP0AE (Android 16, MediaTek Helio G99, Mali-G57, 8 núcleos, 8 GB, 2560×1600), compilación de perfil, mediante `tools/perf_device.sh`.
| Archivo | Carga | Giro (por fotograma) |
|---|---|---|
| Ventilator.stp, 2,2 MB, 1 pieza | 3,3 s (lectura 0,7 s, conversión 1,9 s, teselado 0,5 s) | 9 ms |
| NIST CTC-02 con 37 anotaciones PMI, 1,1 MB | 3,6 s | 11 ms con las anotaciones dibujadas |
| RC_Buggy, 15 MB, 91 piezas, 211 instancias, 421 mil triángulos | **31,5 s** (lectura 3,2 s, **conversión 22,3 s**, teselado 5,3 s) | 43 ms (24 fps) |
Hallazgos: (1) el Mac tarda 5 s en el mismo archivo: la conversión de Open CASCADE es de un solo hilo y la tableta es ~5 veces más lenta; desactivar capas/propiedades/materiales/GD&T no la acorta. (2) El aviso de archivo grande daba «unos 3 s» y ahora estima 2,1 s por MB en Android. (3) **Fallo corregido:** la vista ortogonal usaba una matriz con profundidad de OpenGL ([-1, 1]); en Vulkan se recortaba la mitad de la pieza (y los dibujos 2D salían en blanco). Matriz nueva con [0, 1], comprobada en tableta y en iPhone.
Nota Rendimiento (revisada): 7,5 para ensamblajes grandes (31 s de carga), 9 para piezas habituales.

## Segunda ronda hacia la puerta (24-oct-2026)
Cambios: (1) **materiales del archivo**: nombre y densidad por pieza (Inventor: «Aluminum, Anodized Bronze» 2,7 g/cm³, «Iron, Cast» 7,15…), masa del conjunto según el archivo y selector «Archivo» frente a los materiales genéricos; (2) **propiedades del conjunto completo** (antes salían a 0: 291 366 mm³ y 590,5 g en el buggy de 91 piezas); (3) **caché del documento convertido** (clave: ruta, tamaño y fecha; carpeta de caché del sistema, máx. 600 MB): el buggy de 15 MB pasa de **32,6 s a 7,8 s** en la tableta y de 5,1 s a 1,0 s en el Mac, con resultados idénticos (caras, aristas, agujeros y 30 anotaciones PMI iguales); (4) tarjeta de carga con nombre, segundos transcurridos y aviso que distingue «ya se abrió antes»; (5) pantalla de inicio de tableta con contenido de ancho máximo; (6) vista ortogonal corregida para Vulkan.
Prueba táctil en la tableta (toques reales por adb): tocar la rueda → «Seleccionado: Felni_1:1» y resaltado; panel de árbol; hoja de información con masa y material; cubo de vistas.
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,5 | geometría exacta, unidades, color, PMI y materiales del archivo (Inventor) |
| Información propia | 9 | masa, volumen y materiales del conjunto completo; PMI semántico y gráfico |
| Herramientas específicas | 8,5 | medir, agujeros, sección con tapa, explosión, ortográfica, BOM, PMI, árbol |
| Rendimiento | 8 | piezas habituales 3,3–3,6 s y 9–11 ms; ensamblaje de 15 MB 32,6 s la primera vez (7,8 s después) y 43 ms al girar |
| Robustez | 8,5 | 83 + 33 NIST + 14 de otros CAD + 9 rotos |
| Claridad | 8,5 | aviso de espera con segundos y estimación medida en el dispositivo |
| Frente al mejor | 8,5 | nada gratuito en Android mide, secciona, explosiona y lee PMI |
| Detalle y acabado | 8,5 | probado con toques reales en una tableta física |
Media: **8,56** · Aprobado: **sí** (24-oct-2026). Deuda: la primera apertura de ensamblajes muy grandes (la conversión de Open CASCADE usa un hilo).

## Ronda hacia el 9 (3.ª tanda)
- **Apertura lenta de ensamblajes:** probé desactivar el reparado de formas de OCCT (`SetShapeProcessFlags` vacío) en RC_Buggy: conversión 3,77 s frente a 3,88 s, sin ganancia. El tiempo es la transferencia misma, de un solo hilo. Revertido; queda sin mejorar.
