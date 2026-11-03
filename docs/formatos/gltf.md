# glTF / GLB — dossier de especialización

Estado: fase 8 / 8 · puerta superada (8,59) · Última actualización: 25-oct-2026

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Artista 3D / desarrollador de apps | Exporta desde Blender, Sketchfab o un motor; está lejos del PC | Comprobar que el modelo exporta bien: texturas, materiales, animación, jerarquía | Si lo entrega, lo corrige o lo vuelve a exportar | Hojas de los visores de [Khronos](https://apps.apple.com/app/id6470311948) y [GLB File Viewer](https://apps.apple.com/us/app/-/id6756513463); tienda de apps (sin cifras de uso verificadas) |
| Quien recibe un modelo para AR o web | Recibe un `.glb` por mensaje | Ver si carga, cuánto pesa y qué trae (licencia, texturas, extensiones) | Si lo puede publicar | Especificación glTF 2.0 (campos `asset`, `extensionsUsed`) |
| Equipo con avatares animados (caso del usuario: avatar de Signa) | Esqueleto, piel, formas de morfo | Ver la pose y reproducir los clips | Si el rig está bien | Archivo real del usuario (`signa_avatar.glb`, 54 nodos, 1 esqueleto) |

## 2. Especificación
- Documento oficial: glTF 2.0 de Khronos (JSON + binario; `.glb` = contenedor). Extensiones vistas en archivos reales: `KHR_materials_*` (emisión, unlit, transmisión, especular-brillo heredado), `KHR_texture_transform`, `KHR_mesh_quantization`, `EXT_mesh_gpu_instancing`, `EXT/KHR_meshopt_compression`, `KHR_draco_mesh_compression`, `KHR_texture_basisu`, `EXT_texture_webp` ([compatibilidad habitual](https://threejs.org/docs/pages/GLTFLoader.html)).
- Qué trae el archivo: escena y nodos (TRS o matriz), mallas con primitivas (posición, normal, UV, color, articulaciones, pesos, formas de morfo), materiales (color base, metal/rugosidad, normales, oclusión, emisión, alfa, doble cara), texturas e imágenes (PNG, JPEG, WebP; KTX2 con extensión), pieles, animaciones, cámaras y luces.
- Rarezas: Y hacia arriba; mallas con piel ignoran la transformación de sus ancestros; accesores con paso, normalizados o dispersos; cuadrados de UV con origen arriba a la izquierda; `scale` negativo; GLB con `fallback` sin comprimir.

## 3. Estado del arte
| Función | Khronos glTF Viewer (iOS) | GLB File Viewer (iOS) | Datum hoy |
|---|---|---|---|
| PBR (texturas de metal, normales, emisión) | Sí, según su ficha | Sin verificar | Sí, versión simplificada: sin reflejos reales del entorno |
| Animaciones | Sí (muestras con animación) | Sin verificar | Reproducción con piel y morfo, selector, velocidad, bucle |
| Informe del archivo (extensiones, memoria de texturas, licencia, avisos) | No aparece en la ficha | No | Sí |
| Ocultar piezas, medir, sección, cambiar el eje | No aparece | No | Sí |
| Compresión Draco / meshopt / cuantización / instancias | Sin verificar | Sin verificar | Sí; KTX2 no |
| Otros formatos (STL, OBJ, PLY, 3MF, STEP…) | Solo glTF/GLB | glTF/GLB | Sí, en el mismo visor |
Carencias reales de la competencia: las fichas no prometen informe del archivo ni herramientas de revisión; no se ha podido comprobar el comportamiento real (apps sin instalar).

## 4. Hueco y ventaja
Superaremos al mejor visor de glTF en:
1. **Qué trae el archivo**: hoja con generador, autor y licencia (si el archivo los declara), triángulos, normales del archivo o calculadas, materiales con su modo de transparencia, texturas con medidas y memoria de GPU, extensiones usadas y obligatorias, animaciones con duración, avisos de lo que no se aplica.
2. **Formato leído de verdad**: Draco (decodificador oficial de Google compilado en el núcleo), meshopt (`TRIANGLES`, `ATTRIBUTES` con filtros octaédrico, cuaternión, exponencial y color), cuantización, accesores dispersos, instancias por GPU y `KHR_texture_transform`. Pruebas: los 16 cubos meshopt de la prueba oficial dan los mismos vértices que los sin comprimir; el pato Draco coincide con el pato sin comprimir.
3. **Herramientas de revisión en el propio visor**: lista de piezas con ocultar, medida entre dos puntos, sección, revisión de malla (agujeros, aristas no-manifold) y cambio del eje vertical.
4. **Robustez**: 1197 archivos dañados (cortados, bytes cambiados o borrados) sin un solo fallo inesperado.

## 5. Diseño específico
- Cabecera (chips): formato · triángulos · medidas · texturas · animaciones · «Faltan N archivos».
- Barra: Archivo · Piezas y eje · Texturas sí/no · Medir · Sección · Eje vertical (+ árbol).
- Barra de animación abajo: reproducir/pausar, línea de tiempo, selector, bucle, 0,5×/1×/2×.
- Textos del oficio: «Normales calculadas (el archivo no las trae)», «Memoria de texturas», «Extensiones obligatorias».

## 6. Implementación
- `io/gltf_loader.dart`: lector con accesores tipados, dispersos y con paso, normalizado, `KHR_texture_transform`, materiales PBR, color por vértice, esqueleto, formas de morfo, instancias, meshopt (`io/meshopt.dart`, decodificador propio del formato público), Draco (`core/src/datum_draco.cpp` + `io/draco_glue.dart`; fuentes de Draco 1.5.7, Apache-2.0, en `third_party/draco/`), rig (`model/rig.dart`).
- Renderizador: pipeline propio (`shaders/rich.*`) con UV, color por vértice, 5 texturas (color, metal/rugosidad, normales, oclusión, emisión), mapas de mip, mezcla y recorte; sombreado físico simplificado con luz clave, relleno y entorno de hemisferio; mallas indexadas.
- `ui/rig_player.dart`: animación de nodos, piel por CPU y morfo con actualización del buffer de GPU.
- `render/lod.dart`: versión simplificada para girar modelos de más de 400 mil triángulos.

## 7. Validación
| Origen | Archivos | Resultado |
|---|---|---|
| Muestras de Khronos (modelos, extensiones, pruebas de materiales y animación) | 124 (110 GLB + 14 variantes: separado, incrustado, cuantizado, meshopt, Draco) | 124/124 abren (Draco incluido) |
| Blender (varios) y del usuario (avatar de Signa) | 6 | 6/6 |
| Dañados (`tool/verify_robust_mesh.dart`) | 1197 casos sobre archivos de menos de 2 MB de las tres familias | 347 abren, 850 error limpio, 0 inesperados |
Draco dañado (432 variantes con bytes cambiados o cortados en los tres modelos Draco): sin cuelgues ni cierres de la app. Pruebas unitarias: `test/mesh_formats_test.dart` (14 casos, con las comparaciones de meshopt y Draco).
Rendimiento (tableta Mali-G57): Corset en Draco 13,2 ms al girar (carga 1,5 s); DamagedHelmet (5 texturas) 17,4 ms por fotograma al girar; CesiumMan animado 10,3 ms; 125 esferas (1 M de triángulos) 56,6 ms con versión simplificada.
Capturas en `docs/formatos/gltf_*.png`.

## 8. Puerta de calidad
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,6 | PBR simplificado (casco, esferas de metal), color por vértice, alfa, animación con piel, Draco y meshopt; sin KTX2, sin reflejos reales de entorno ni capas de vidrio/barniz |
| Información propia | 8,8 | Hoja del archivo completa |
| Herramientas específicas | 8,6 | Animación, piezas, medida, sección, revisión de malla, eje |
| Rendimiento | 8,6 | Tableta: 10–17 ms con modelos típicos |
| Robustez | 8,7 | Fuzz limpio, también con bloques Draco y meshopt dañados |
| Claridad | 8,5 | Chips y hojas en el idioma del oficio |
| Frente al mejor | 8,5 | Comparación con las fichas de las apps, sin probarlas |
| Detalle y acabado | 8,4 | Avisos por caso, memoria de texturas |
Media: **8,59** · Aprobado: **sí** · Fecha: 25-oct-2026

Deuda conocida: KTX2/Basis, cámaras y variantes de material del archivo, texturas con segunda capa de UV, reflejos con mapa de entorno real, rotación de cámara guardada.

### Ronda hacia el 9 (25-oct-2026)
- **Cámaras del archivo** como «Vistas del archivo» (comprobado con `VirtualCity.glb`, 14 cámaras).
- Fila que cambia: Herramientas específicas 8,8. Media: **8,61**. Sigue pendiente KTX2/Basis, variantes de material y reflejos con mapa de entorno.

### Variantes de material (25-oct-2026)
- `KHR_materials_variants`: «Variantes de material» en la barra; al elegir una cambian los materiales de las piezas (probado con `MaterialsVariantsShoe.glb`: del azul al rosa, con su textura). Fidelidad 8,8. Media: **8,66**.

## Ronda hacia el 9 (3.ª tanda)
- **KTX2/Basis:** no hecho (exige integrar el transcodificador Basis Universal para ASTC/ETC/BC según dispositivo).
