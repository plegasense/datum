# OBJ — dossier de especialización

Estado: fase 8 / 8 · puerta superada (8,60) · Última actualización: 25-oct-2026

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Quien imprime en color en 3D | Su programa exporta OBJ con color por vértice | Ver los colores antes de laminar | Si el color llegó bien | Archivo real del usuario: `IMPRIMIR MULTICOLOR.obj` (90 MB, 1,87 M de triángulos) |
| Fotogrametría y escaneo | Recibe un OBJ con `.mtl` y texturas | Ver el modelo texturizado | Si faltan archivos o está bien | Hilos de [archivos que faltan](https://www.sweethome3d.com/support/forum/printthread_thread,8935_printall,yes) y de [texturas al revés](https://polycount.com/discussion/comment/1235323) |
| Artista que descarga modelos | ZIP de Sketchfab o similar | Abrir el ZIP con modelo y texturas | Si sirve | [Ficha de OBJ & MTL Simple Viewer](https://apps.apple.com/am/app/obj-mtl-simple-viewer/id6469348754) (carga desde ZIP) |

## 2. Especificación
- Formato de Wavefront (texto): `v` (con color `r g b` no oficial pero habitual), `vt`, `vn`, `f` (con índices negativos y polígonos), `o`/`g`, `usemtl`, `mtllib`. El `.mtl` aporta `Kd`, `Ke`, `d`/`Tr`, `illum`, `map_Kd`, `map_d`, `bump`.
- Rarezas: sin eje vertical declarado (Y es lo habitual); `Tr 1` lo escriben algunos programas como «opaco»; rutas con `\` o con mayúsculas distintas; polígonos cóncavos; texturas con el eje V invertido.

## 3. Estado del arte
| Función | OBJ & MTL Simple Viewer (iOS) | MeshLab (iOS/PC) | Dovexa hoy |
|---|---|---|---|
| Materiales y texturas | Sí, con ZIP | Sí | Sí, con ZIP |
| Color por vértice | Sin verificar | Sí | Sí |
| Qué falta junto al modelo | Sin verificar | Sin verificar | Lista y botón «Añadir los archivos que faltan» |
| Revisión de la malla | No | Sí (filtros) | Agujeros, no-manifold, cascos, estanca |
| Sección, medida, eje | No aparece | Sí | Sí |
Carencias reales: el único visor específico de OBJ de iOS que encontré tiene valoraciones bajas y pocas ([2,7 de 3 reseñas](https://apps.apple.com/am/app/obj-mtl-simple-viewer/id6469348754) en un agregador; sin verificar).

## 4. Hueco y ventaja
Superaremos al mejor en:
1. **Archivos que faltan**: avisa de la textura o el `.mtl` ausente, lo pide y lo guarda junto al modelo para la próxima vez (el problema más repetido en foros).
2. **OBJ de impresión en color**: color por vértice leído y mostrado (90 MB en 5,5 s en la tableta; 41,8 ms al girar).
3. **Revisión de la malla**: la del conejo de Stanford da cinco agujeros, el dato conocido.
4. **ZIP directo**: modelo, `.mtl` y texturas de un solo archivo.

## 5. Diseño específico
Cabecera: formato · triángulos · medidas · texturas/color por vértice · «Faltan N archivos». Barra: Archivo · Piezas y eje · Texturas · Medir · Sección · Eje. Hoja con materiales (modo, textura), texturas, archivos que faltan, avisos y revisión de la malla.

## 6. Implementación
`io/obj_loader.dart` (lector por bytes, normales/UV/color, MTL, texturas, búsqueda de hermanos sin distinguir mayúsculas y con `\`), `io/rich_mesh.dart` (soldadura de esquinas con tabla propia, normales suaves ponderadas por ángulo con aristas vivas, triangulación de polígonos cóncavos por orejas), `io/loader.dart` (ZIP y carpeta de archivos añadidos), `ui/mesh_tools.dart`.

## 7. Validación
| Origen | Archivos | Resultado |
|---|---|---|
| trimesh (casos límite: vacío, índices negativos, no convexo, color NaN…) y alecjacobson | 40 | 39 abren (3 como nube de puntos, sin caras); 2 vacíos con mensaje |
| Del usuario (impresión en color) | 1 | 2,0 s en el Mac, 5,5 s en la tableta |
| Dañados | incluidos en los 1197 casos | 0 inesperados |
Pruebas: `test/mesh_formats_test.dart` (barras, negativos, polígonos, MTL, texturas ausentes, solo vértices).

## 8. Puerta de calidad
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,6 | Color, UV, MTL, alfa, normales; sin relieve ni brillo especular |
| Información propia | 8,6 | Hoja con materiales, texturas, faltantes y revisión |
| Herramientas específicas | 8,7 | Asistente de faltantes, ZIP, revisión, sección, medida |
| Rendimiento | 8,6 | 90 MB en 5,5 s; giro 41,8 ms |
| Robustez | 8,7 | Fuzz limpio |
| Claridad | 8,5 | |
| Frente al mejor | 8,7 | Contra fichas de tienda |
| Detalle y acabado | 8,4 | |
Media: **8,60** · Aprobado: **sí** · Fecha: 25-oct-2026

Deuda: mapas de relieve y brillo, `.mtl` con varias capas, líneas (`l`) y curvas, selección de archivo entero de la carpeta en iOS (hoy se añaden a mano).

### Ronda hacia el 9 (25-oct-2026)
- **Relieve (`map_bump`, `bump`):** el mapa de alturas se convierte en mapa de normales al decodificar (Sobel) y se aplica con el sombreado por píxel.
- **Líneas (`l`):** las polilíneas se dibujan como tubos finos; un OBJ solo de líneas (el «wireframe» real de la colección de trimesh) ya no queda vacío.
- 4 pruebas nuevas. Filas que cambian: Fidelidad 8,8 · Herramientas 8,7. Media: **8,63**.
