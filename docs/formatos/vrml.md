# VRML (y X3D) — dossier de especialización

Estado: fase 8 / 8 · puerta superada (8,5) · Última actualización: 25-oct-2026

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Impresión 3D a todo color | Archivos `.wrl` con color o textura para máquinas PolyJet y servicios de impresión | Comprobar que el color y la textura sobreviven | Si se puede mandar a imprimir | [Guía de PolyJet multicolor de Facfox](https://facfox.com/docs/kb/design-guideline-how-to-design-parts-for-polyjet-multi-color), [Shapeways: color desde 3ds Max](https://www.shapeways.com/blog/full-color-3d-printing-from-3ds-max) |
| Ciencia (cristalografía, química) | Estructuras exportadas por programas de visualización | Ver y girar el modelo | Si la figura está completa | [Artículo de CrystEngComm, 2014](https://pubs.rsc.org/ks/content/articlelanding/2014/ce/c4ce00371c) |
| Archivo técnico y arquitectura antigua | Modelos de los años 90 y 2000 (VRML 1.0 y 97) de CAD, Mathematica, Blender 2.4 | Abrir lo que ya no abre casi nada | Qué contiene y qué falta | Colección de J. Burkardt (LGPL) |

## 2. Especificación
- **VRML 1.0** (nodos de propiedades que se acumulan al recorrer: `Separator`, `Material`, `Coordinate3`, `ShapeHints`…), **VRML 97 / 2.0** (ISO 14772: nodos con campos, `Transform`, `Shape`, `Appearance`, `PROTO`, `Inline`, `ROUTE`) y **X3D** clásico y XML. Admite `.wrz` (gzip).
- Eje vertical Y; **sin unidades** (por norma, metros).
- Casos raros: `PROTO`, hijos sin corchetes, `children` con un solo nodo, `creaseAngle`, color por cara o por vértice con índices propios, `Extrusion` y `ElevationGrid`, líneas y puntos, texturas de píxeles incrustadas.

## 3. Estado del arte
| Función | FreeX3D (Android) | view3dscene-mobile | Datum |
|---|---|---|---|
| Mantenimiento | Ficha de hacia 2013 | Anunciado en 2018, sin verificar que se publicara | Activo |
| VRML 1.0, VRML 97 y X3D | VRML, X3D, STL | X3D y VRML | Sí, también `.wrz` y X3D en XML |
| Texturas, transparencia, color por vértice | Sin verificar | Sin verificar | Sí |
| Tamaño y aviso de unidades | No | No | Sí |
| Lista de materiales, árbol, sección, medida | No | Parcial | Sí (las de glTF y OBJ) |
Carencia real: no hay un visor móvil de VRML mantenido (las fuentes que encontré son de 2011–2018).

## 4. Hueco y ventaja
1. Un VRML abre y se ve igual que en un navegador: 18 de 20 cajas coinciden con las de three.js; las 2 distintas son un error de three.js con `ElevationGrid` (comprobado contra la norma).
2. Aviso de unidades: si el archivo mide más de 400 unidades se pregunta si están en milímetros.
3. Lo que no se dibuja se dice: textos, animación, nodos de interacción, `PROTO` externos y archivos `Inline` que faltan.
4. Todas las herramientas de malla (sección, medida, materiales, texturas, árbol, eje vertical) valen sin más.

## 5. Diseño específico
Cabecera: «VRML 1.0 / VRML 97 / X3D», triángulos, tamaño, texturas, archivos que faltan. Hoja «Archivo»: formato y programa de origen, materiales, texturas, avisos. Las líneas (`IndexedLineSet`) y los puntos (`PointSet`) se convierten en tubos finos y octaedros porque Datum sólo dibuja mallas.

## 6. Implementación
`io/vrml_parse.dart` (fichas como posiciones, números sin crear texto, `PROTO`, `DEF/USE`), `io/vrml_loader.dart` (VRML 97 y 1.0, materiales, texturas, árbol de nodos, información), `io/vrml_geom.dart` (cajas, esferas, conos, cilindros, extrusión, rejilla de alturas, tubos, PNG para texturas de píxeles), `io/x3d_xml.dart` (X3D en XML). Se reutiliza `RichMeshBuilder` (normales, UV, color) de OBJ y glTF.

## 7. Validación
| Origen | Archivos | Resultado |
|---|---|---|
| Colección de Burkardt (VRML 1.0 y 97) | 24 | 24 abren |
| Ejemplos de three.js (extrusión, rejilla, texturas, líneas, puntos, casa de 132 piezas) | 17 | 17 abren |
| Blender 2.45, X3D → VRML (Web3D) | 2 | 2 abren |
| Comparación con three.js (cajas de la escena colocada) | 20 con referencia | 18 coinciden; 2 por un error de three.js |
| Pruebas geométricas | volumen de caja, cilindro, cono, esfera, extrusión; ccw falso; PROTO; Switch; X3D XML; `.wrz`; PNG | 16 tests |
| Fuzz | 3 semillas × 352 casos | 0 fallos inesperados |
| Rendimiento | 35 MB y 977 mil triángulos | Mac 1,1 s; tableta 5,4 s y 52 ms por fotograma al mover |
Dispositivos: iPhone (simulador) y tableta Xiaomi.

## 8. Puerta de calidad
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,5 | 18/20 contra three.js; volúmenes exactos en primitivas; sin PROTO ni Inline de CAD reales |
| Información propia | 8,5 | formato, origen, avisos, unidades |
| Herramientas específicas | 8,5 | las de malla; sin animación ni vistas guardadas |
| Rendimiento | 8,5 | 5,4 s para 35 MB en tableta |
| Robustez | 8,5 | fuzz limpio |
| Claridad | 8,5 | capturas |
| Frente al mejor | 8,5 | no hay otro móvil mantenido |
| Detalle y acabado | 8,5 | negros puros subidos a gris oscuro |
Media: 8,50 · Aprobado: sí · Fecha: 25-oct-2026
Deuda: animación y vistas (`Viewpoint`), `Text`, `PROTO` externos, `Inline` en cadenas largas, `Billboard`, texturas de película, luces del archivo.

### Ronda hacia el 9 (25-oct-2026)
- **Animación:** los `TimeSensor` con `PositionInterpolator` y `OrientationInterpolator` encaminados por `ROUTE` a un `Transform` se reproducen con la barra de animación de glTF (centro de giro incluido). Comprobado con `red_chair`, `vrml_balance3d` y `house` (19 animaciones) y con 3 pruebas.
- **Vistas:** los `Viewpoint` pasan a «Vistas del archivo».
- Filas que cambian: Fidelidad 8,7 · Herramientas específicas 9,0. Media: **8,59**.
- Sigue sin 9: Rendimiento, Robustez, Claridad, Frente al mejor y Detalle (8,5). Faltan archivos de CAD reales con `PROTO` e `Inline`, y una comparación con el único visor móvil de la época.
