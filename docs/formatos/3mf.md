# 3MF — dossier de especialización

Estado: fase 8 / 8 · puerta superada (8,65) · Última actualización: 24-oct-2026

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Aficionado con impresora Bambu / Prusa / Creality | Descarga proyectos `.3mf` de MakerWorld o los guarda de su laminador; está lejos del PC | Abrir el proyecto en el móvil: ¿qué placas trae, con qué colores, cuánto tarda y cuánto material gasta? | Si merece la pena imprimirlo hoy, qué filamentos cargar | Paso por los 75 proyectos reales del usuario (Bambu Studio 2.4–2.8); sin verificar fuera de ese uso |
| Quien comparte o recibe proyectos | Recibe un `.3mf` por mensaje | Comprobar que no está vacío, que cabe en su cama y qué ajustes trae | Si lo abre en el laminador o lo descarta | Hilo de [problemas con color entre visores](https://forum.bambulab.com/t/hueforge-problems/212308): el color de Bambu «no cumple el estándar» y otros visores lo pierden |
| Diseñador (Fusion, SolidWorks, Blender…) | Exporta 3MF estándar con color o materiales | Revisar que la exportación conserva color, unidades y piezas | Si la exportación es correcta | Extensión de materiales del [estándar 3MF](https://3mf.io/spec/) |
| Taller / ingeniería con retículas | Estructuras ligeras (Beam Lattice) | Ver que las vigas están | Si el archivo es válido | Muestras oficiales del consorcio 3MF |

## 2. Especificación
- Documento oficial: [3MF Core 1.3.0](https://3mf.io/spec/) (ISO/IEC 25422) con las extensiones de materiales 1.2.1, producción 1.1.2, retícula de vigas 1.2.0 y cortes 1.0.2.
- Qué contiene un 3MF (ZIP + XML): `3D/3dmodel.model` (objetos, componentes, `<build>` con transformaciones de fila 3×4, unidad: micra/mm/cm/m/pulgada/pie), metadatos (título, diseñador, licencia, fechas), materiales (`basematerials`, `colorgroup`, `texture2dgroup`, multipropiedad) por objeto o por triángulo (`pid`/`p1..p3`), producción (`p:path` a otros `.model`), retícula y cortes.
- Bambu Studio / OrcaSlicer añaden: `Metadata/model_settings.config` (piezas, volúmenes con rol, placas, miniaturas), `project_settings.config` (JSON con cientos de ajustes, filamentos, cama), `slice_info.config` (resultado del laminado), `plate_N.gcode`, y **pintura por triángulo** en `paint_color` (formato del `TriangleSelector`: texto hexadecimal leído de derecha a izquierda, árbol de subdivisión).
- PrusaSlicer: `Slic3r_PE_model.config` (una malla por pieza con volúmenes por rango de triángulos y tipo `ModelPart`/`NegativeVolume`/`ParameterModifier`/…), `Slic3r_PE.config` (ajustes), `mmu_segmentation` (misma codificación), cambios de color por altura.
- Rarezas encontradas en archivos reales: ids de objeto que no coinciden entre `<build>` y componentes (Bambu usa objeto→componente→malla en otro archivo), volúmenes negativos (69 volúmenes negativos en 7 proyectos), placas dispuestas en cuadrícula con 20 % de separación (`ceil(√n)` columnas), proyectos de 216 MB de XML en 48 MB de ZIP, `<build>` ausente o con `p:path` (muestras del consorcio), UTF-16 (caso inválido).

## 3. Estado del arte
| Función | LayerPeek (Android) | Viewer3D (iOS) | Visores genéricos (Meshy web, Meshman) | Dovexa hoy |
|---|---|---|---|---|
| Placas y filamentos de Bambu/Orca | Sí: placas, color de filamento, tiempo y gramos de archivos laminados ([ficha](https://www.similarweb.com/app/google/com.cosmovex.layerpeek/)) | Lo anuncia; la propia ficha lo matiza («en optimización») ([ficha](https://appshunter.io/ios/app/viewer3d/id6757183916)) | No dicen que lo lean ([Meshy](https://www.meshy.ai/3d-tools/online-viewer/3mf)) | Sí |
| Pintura multicolor por triángulo | No documentada | No verificada | Color de texturas embebidas, no de Bambu | Sí, decodificada |
| Volúmenes negativos / modificadores | No documentado | No | No | Sí, con rol y ocultos por defecto |
| Cabe en la cama | Sí | No | No | Sí, por placa y con el aviso de cuánto se sale |
| Medir | Sí, dos puntos | No documentado | No | Sí, dos puntos |
| Salud de la malla / voladizos | Sí | No | No | Solo en STL (aquí no) |
| PrusaSlicer, Cura, estándar con color | Solo habla de Bambu/Orca | — | Color estándar | Sí |
| Retícula de vigas | No | No | No | Sí (prismas) |
| Anuncios / conexión | Anuncios, Pro de pago; IA en la nube opcional | De pago | Web | Sin anuncios, sin conexión |
Carencias reales de la competencia: LayerPeek simplifica los modelos grandes para mostrarlos; el único aviso público sobre color es que el de Bambu «no cumple el estándar» y otros visores lo ven gris. Sin probar las apps en mano: lo anterior sale de sus fichas.

## 4. Hueco y ventaja
Superaremos al mejor (LayerPeek, por su ficha) en:
1. **Color real del proyecto**: pintura por triángulo decodificada y comparada con la miniatura que guarda Bambu. 35 de los 73 proyectos con pintura contados del usuario la usan; el de 1,9 M de triángulos y 4 filamentos se ve con sus 4 colores y abre en 4,7 s en la tableta, girando a 29,7 ms por fotograma.
2. **Qué es cada volumen**: piezas, volúmenes negativos, modificadores y bloqueadores con su nombre y rol, ajustes propios de cada pieza (relleno, paredes, soportes) y filamento por volumen.
3. **Placas con su sitio**: posición real en la cuadrícula del laminador, miniatura de cada placa del propio archivo, aviso si algo se sale de la cama, y salto al recorrido G-code de esa placa (reutiliza el visor de G-code ya aprobado).
4. **Cualquier programa**: PrusaSlicer (volúmenes por rango, cambios de color), Cura, exportaciones estándar con color (por objeto, por triángulo, por vértice), retícula de vigas y producción; 163 archivos de 5 orígenes sin un solo fallo inesperado.

## 5. Diseño específico
- Datos arriba (chips): «Placa 2 de 2» · piezas · medida de la placa · «Cabe en la cama»/«Se sale de la cama N mm» · tiempo y gramos del laminado (o «hasta N g» de material macizo) · filamentos.
- Barra: Piezas · Filamentos y laminado · Proyecto y ajustes · Medir · Cama (además del árbol y las vistas estándar).
- Tira de placas abajo: «Todas» + miniatura, nombre y tiempo (o nº de piezas) de cada placa, con triángulo de aviso si se sale.
- Hojas: **Filamentos** (laminado real: tiempo, material, capas con más de un color, soportes; por filamento tipo, perfil, temperatura, gramos y metros reales o macizo estimado; ojo para aislar un color; botón «Ver el recorrido (G-code)»); **Piezas** (nombre, medida, triángulos, colores, ajustes propios, volúmenes con rol, ver solo esta / ocultar, mostrar auxiliares); **Proyecto** (portada del archivo, diseñador, licencia, fechas, impresora, boquilla, cama, perfil, ajustes, cambios de color por altura, extensiones, avisos).
- Textos con el vocabulario del oficio: «Placa», «Filamento», «Volumen negativo», «Modificador», «Capas con más de un color», «Se sale de la cama».
- Lo que se estima se dice: el peso sin laminar es «hasta N g» = volumen × densidad del filamento (cota máxima del material macizo); lo laminado es el del archivo.
- Capturas: `docs/formatos/3mf/`.

## 6. Implementación
- `io/zip_lite.dart`: lector de ZIP (almacenado y deflate, ZIP64) que descomprime con zlib nativo **en trozos**; un modelo de 216 MB no se carga entero.
- `io/threemf_model.dart`: lector de XML por bytes, sin cadenas en las etiquetas calientes (vértices y triángulos); estado de pintura, propiedades de color `pid/p1..p3`, vigas y metadatos. `PaintDecoder` reconstruye las subdivisiones del `TriangleSelector` (1, 2 o 3 lados partidos, hijos en orden inverso) leyendo el código de PrusaSlicer/Bambu para entender el formato; implementación propia.
- `io/threemf_loader.dart`: unidades, producción, componentes anidados, volúmenes de Bambu (componentes) y de PrusaSlicer (rangos), partición de cada volumen por filamento o por color (cuantizado a 4/3 bits si hay más de 48 colores), volumen por filamento, cajas, placas (cuadrícula `ceil(√n)` × 1,2·cama), proyecto (JSON de Bambu, `Slic3r_PE.config`, `slice_info`), vigas como prismas hexagonales.
- `ui/threemf_tools.dart`: controlador (placa, ocultos, aislado, auxiliares, cama, medida, versión simplificada para girar proyectos de más de 400 mil triángulos), chips, tira de placas y hojas. `viewer_page.dart`: integración y ganchos de prueba `DOVEXA_CAD=plate:N;filaments;parts;project;aux;hide:N;iso:N;m:x,y,..;tap:x,y;toolpath:N;v:yaw,pitch;perf`.
- Medido: ver sección 7.

## 7. Validación
| Origen | Archivos | Resultado |
|---|---|---|
| Bambu Studio 2.4–2.8 (proyectos del usuario) | 75 (54 + 21 en el corpus local) | 75/75 abren; 54 proyectos en 3,8 s en el Mac; 2,27 M de triángulos en 1 s |
| Consorcio 3MF: ejemplos (núcleo, materiales, texturas, producción, cortes, retícula) | 33 | 33/33 abren |
| Consorcio 3MF: pruebas de validación | 47 | los 4 `MUSTFAIL` sin geometría fallan con mensaje limpio; el resto abre |
| PrusaSlicer 2.8/2.9 (clon de pruebas, SLA, torre de purga, costura) | 6 | 6/6; volúmenes por rango, cambios de color |
| OrcaSlicer (calibraciones, insignia, laminado) | 5 | 5/5 |
| Cura (plataformas de impresoras) | 4 | 4/4 |
| Fuzz: ZIP cortado, XML truncado, bytes cambiados o borrados | 1224 casos sobre 75 archivos | 328 abren, 896 error limpio, **0 inesperados** (`tool/verify_robust_3mf.dart`) |
Pruebas unitarias: `test/threemf_test.dart` (10 casos: pintura, unidades, colores, Bambu con volumen negativo, laminado, ZIP roto); total del proyecto 42 pasan.

Rendimiento (tableta Android, Mali-G57): proyecto de 1,9 M de triángulos y 4 filamentos (25 MB): carga 4,7 s, giro 29,7 ms por fotograma con la versión simplificada (83–94 ms sin ella); proyecto de 85 mil triángulos: 0,4 s.

Tareas del usuario completadas (capturas):
- Toque real en la tableta: tira de placas.

## 8. Puerta de calidad
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 9,0 | Colores por filamento y pintura por triángulo coherentes con las miniaturas de Bambu; unidades, producción, componentes, color por objeto/triángulo/vértice y retícula. No aplica texturas de imagen ni dibuja cortes (avisa) |
| Información propia | 8,8 | Placas, filamentos, volúmenes con rol, ajustes por pieza, laminado real, cambios de color, proyecto, avisos |
| Herramientas específicas | 8,5 | Piezas, filamentos, proyecto, cama, medida, aislar y ocultar, salto al recorrido. Faltan sección y orientación |
| Rendimiento | 8,8 | 75 proyectos reales; 1,9 M de triángulos pintados: 4,7 s y 29,7 ms en la tableta |
| Robustez | 8,7 | 1224 casos dañados sin fallos inesperados; 163 archivos de 5 orígenes |
| Claridad | 8,4 | Chips, tira de placas y hojas en español del oficio; la barra lateral es larga en el móvil |
| Frente al mejor | 8,6 | ≥ 4 ventajas con evidencia; la comparación con LayerPeek y Viewer3D se hizo con sus fichas, sin probar las apps |
| Detalle y acabado | 8,4 | Medida de pantalla, miniaturas del archivo, mensajes de cada caso |
Media: **8,65** · Aprobado: **sí** · Fecha: 24-oct-2026

Deuda conocida: pintura de PrusaSlicer (`mmu_segmentation`) probada solo con archivos sin pintura real (misma codificación que Bambu, sin muestra pintada); texturas de imagen y cortes sin dibujar; peso sin laminar es cota máxima; sin sección ni análisis de orientación/voladizos como en STL; XML truncado no muestra la malla parcial.

### Ronda hacia el 9 (25-oct-2026)
- **Sección** con plano X/Y/Z, deslizador y tapa del corte (la misma que en las demás mallas), comprobada en iPhone con un proyecto de Cura.
- Fila que cambia: Herramientas específicas 9,0. Media: **8,71**. Pendiente: texturas de imagen, cortes y orientación; pintura de PrusaSlicer con una muestra real.
