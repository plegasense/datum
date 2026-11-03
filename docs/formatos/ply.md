# PLY — dossier de especialización

Estado: fase 8 / 8 · puerta superada (8,50) · Última actualización: 25-oct-2026

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Escaneo y fotogrametría | Mallas con color por vértice de escáner o COLMAP | Ver el resultado con su color | Si el escaneo vale | [Ficha de MeshLab para iOS](https://apps.apple.com/app/id451944013), [Emb3D](https://www.cgchannel.com/2016/11/view-3d-models-on-your-mobile-with-free-app-emb3d/) |
| Investigación y metrología | Campos escalares (calidad, intensidad) | Ver el campo como color y revisar la malla | Si hay huecos o ruido | Propiedades habituales de MeshLab/CloudCompare |
| Impresión y modelado | PLY de Blender con UV y color | Comprobar que exporta bien | Si abre en el laminador | Archivos de Blender del corpus |

## 2. Especificación
PLY (Stanford): cabecera de texto (`format ascii|binary_little_endian|binary_big_endian`, elementos y propiedades), cuerpo ASCII o binario. Elemento `vertex` con `x y z`, `nx ny nz`, `red green blue alpha`, `s t`, campos escalares; `face` con `vertex_indices` (listas), `texcoord` por esquina, color por cara. Comentario `TextureFile`. Rarezas: tipos mezclados, listas con tipos distintos, `vertex_index`, nubes sin caras.

## 3. Estado del arte
| Función | MeshLab iOS | Emb3D | Datum hoy |
|---|---|---|---|
| Color por vértice | Sí | Sí | Sí, también por cara |
| UV + textura (`TextureFile`) | Sí | Sin verificar | Sí |
| Campo escalar como color | Sí (filtros) | No | Sí, con su rango |
| Revisión de malla, sección, medida | Sí (filtros) | No | Sí |
| Estado de la app | ficha de 45 reseñas, 3,7/5, pensada para iPad | 2016 | Activa |
Carencias reales: ambas son antiguas; MeshLab móvil es un visor de PC reducido.

## 4. Hueco y ventaja
1. Color, UV y textura leídos de verdad (corpus con 5 programas distintos).
2. Campo escalar pintado con una rampa y su rango en la hoja.
3. Revisión de la malla y sección en el visor.
4. Velocidad: 1,87 M de triángulos en 1,3 s en el Mac.

## 5. Diseño específico
Los de OBJ y glTF más: «Campo escalar «quality» 0–1 (pintado como color)» en la hoja del archivo.

## 6. Implementación
`io/ply_loader.dart`: cabecera, tipos binarios y ASCII (lector propio), propiedades de vértice y cara, polígonos, color por vértice y por cara, UV por vértice y por esquina, textura citada, campo escalar, nube de puntos sin caras; `io/rich_mesh.dart` (compartido).

## 7. Validación
| Origen | Archivos | Resultado |
|---|---|---|
| trimesh (Blender, MeshLab/VCG, vacíos, listas raras) y de alecjacobson | 31 | 26 abren (algunos como nube de puntos); 5 vacíos o ilegibles con mensaje |
| Escaneo del usuario (`socia.ply`, 1,87 M de triángulos) | 1 | 1,3 s |
| Dañados | incluidos en los 1197 | 0 inesperados |
Un archivo (`fuze_ascii.ply`) trae filas que no cumplen su propia cabecera: se rechaza o lee mal; documentado.

## 8. Puerta de calidad
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,5 | Color, UV, normales, polígonos; sin valores por cara que no sean color |
| Información propia | 8,5 | Campo escalar, normales del archivo o calculadas |
| Herramientas específicas | 8,5 | Revisión, sección, medida, eje, texturas sí/no |
| Rendimiento | 8,6 | 1,9 M de triángulos en 1,3 s |
| Robustez | 8,7 | Fuzz limpio, límites de lectura |
| Claridad | 8,5 | |
| Frente al mejor | 8,4 | Contra fichas de tienda |
| Detalle y acabado | 8,3 | |
Media: **8,50** · Aprobado: **sí** (justo) · Fecha: 25-oct-2026

Deuda: elemento `edge`, escalares por cara, varias capas de campos, `ply` con puntos muy densos (la nube se trata en su dossier).

### Ronda hacia el 9 (25-oct-2026)
- **Bandas de triángulos (`tristrips`):** `aj_igea.ply` (un escaneo real que antes daba «PLY dañado») ahora abre con 268 686 triángulos y volumen positivo (caras hacia fuera).
- **Elemento `edge`:** las aristas se dibujan como tubos finos y se avisa.
- **Escalar por cara** (calidad, etc.): se pinta con la rampa y su rango en la hoja.
- 3 pruebas nuevas; fuzz de 490 casos sin fallos inesperados. Filas que cambian: Fidelidad 8,8 · Información propia 8,6. Media: **8,55**.
