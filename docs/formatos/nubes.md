# Nubes de puntos (XYZ · PTS · PCD · LAS · LAZ · E57) — dossier de especialización

Estado: fase 8 / 8 · puerta superada (8,56) · Última actualización: 25-oct-2026

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Topografía y vuelo con dron/LiDAR | Recibe LAS/LAZ del vuelo o del servicio cartográfico | Comprobar que el vuelo está completo y clasificado | Si el terreno, los edificios y la vegetación están donde deben | Fichas de LasViewer Pro y Pointscape |
| Escaneo terrestre (obra, arquitectura) | E57 de Faro, Leica, Trimble | Ver el escaneo y medir en el sitio | Si hay huecos y si las medidas cuadran | Ficha de 3D Point Cloud Viewer |
| Investigación y robótica | PCD de PCL, XYZ/PTS de pruebas | Mirar el resultado con su intensidad o altura | Si el algoritmo ha funcionado | Documentación de PCL |

## 2. Especificación
- **LAS** (ASPRS 1.0–1.4): cabecera con escala y desplazamiento (coordenadas enteras), VLR con el sistema de coordenadas (GeoKeys o WKT), 11 formatos de punto (intensidad, retornos, clase, tiempo GPS, color, infrarrojo, onda). **LAZ** es el mismo con compresión (LASzip).
- **E57** (ASTM E2807): XML + secciones binarias con páginas de 1 024 bytes y CRC; campos empaquetados por bits; varios escaneos con su pose; coordenadas cartesianas o esféricas.
- **PCD, XYZ, PTS**: texto o binario sencillo.
- Casos raros: coordenadas de mapa enormes (pierden precisión en `float`), color de 8 bits en un campo de 16, cabecera que dice más puntos de los que hay, sistema geográfico (grados), unidades en pies de EE. UU.

## 3. Estado del arte
| Función | Pointscape | LasViewer Pro | 3D Point Cloud Viewer | Dovexa |
|---|---|---|---|---|
| Formatos | E57, LAS, LAZ, COPC | LAS, LAZ, PLY | E57, PTS, PLY, XYZ, LAS | LAS, LAZ, E57, PCD, XYZ, PTS, PLY |
| Colorear por RGB / altura / intensidad / clase | Sí | Sí | Sólo altura | Sí, más retornos |
| Medir, secciones | Medir | Medir, secciones, volúmenes | No | Medir, recorte por altura |
| Sombreado de borde (EDL) | Sí | — | No | No |
| Coste | Sin verificar | Suscripción (prueba de 7 días) | Sin verificar | Gratis, sin conexión, sin anuncios |
| Datos del archivo (sistema, unidades, densidad) | Sin verificar | Sin verificar | No | Sí |
Carencias reales: sólo hay fichas de tienda, no reseñas independientes; el modelo de pago de las mejores es por suscripción.

## 4. Hueco y ventaja
1. Formatos de campo reales (LAS 1.0–1.4, LAZ y E57) en una app gratuita y sin conexión.
2. «Sobre el archivo»: sistema de coordenadas con su EPSG y unidad, densidad en puntos/m², precisión, retornos, clases y los avisos (sin unidades, grados, cabecera desactualizada, archivo cortado, muestreo).
3. Clases ASPRS con nombre, color y filtro por clase; recorte por altura; medir con distancia, horizontal, desnivel y pendiente en la unidad del archivo.
4. Velocidad: un LAS de 680 MB (20 millones de puntos) abre en 2,2 s en la tableta y se mueve a 31 ms por fotograma.

## 5. Diseño específico
- Datos arriba: puntos (y «de N» si se ha muestreado), extensión en la unidad del archivo, formato, sistema de coordenadas, notas.
- Barra: centrar, vistas (isométrica, planta, frontal), «Vista» (color, tamaño, clases, recorte), medir, «Sobre el archivo».
- Vocabulario: «Sin clasificar», «Suelo», «Vegetación baja/media/alta», «Edificio», «Retorno único / primero / último».

## 6. Implementación
`io/las_loader.dart` (cabecera, VLR/EVLR, GeoKeys y WKT, formatos 0–10, muestreo por tandas, estadísticas), `io/laz_glue.dart` + `core/src/datum_laz.cpp` + LASzip en `third_party/laszip` (Apache-2.0), `io/e57_loader.dart` (páginas con CRC, XML, paquetes, bits, pose), `io/mesh_data_extra.dart` (origen para coordenadas de mapa), `model/pointcloud.dart` (modos de color, filtros, muestra de 250 mil puntos para mover la vista), `model/cloud_info.dart`, `ui/cloud_tools.dart`.

## 7. Validación
| Origen | Archivos | Resultado |
|---|---|---|
| PDAL (LAS 1.0–1.4, GeoKeys, WKT, color, bytes extra) | 28 LAS | 27 abren; 1 sin puntos con mensaje. Caja, intensidad y clases de 26 archivos idénticas a un cálculo independiente en Python |
| PDAL y LASzip (LAZ 1.2 y 1.4) | 4 LAZ | 4 abren; los dos con LAS gemelo dan estadísticas idénticas |
| libE57Format (referencia y pruebas propias) | 7 E57 | 4 abren (conejo en `double` e `int32`, cubo con color en `float` y `double`); 3 con error claro (sin prototipo, sin puntos, cortado). La caja del conejo coincide con la del XML |
| Sintético de 20 M puntos (680 MB) | 1 LAS | densidad medida 79,8 frente a 80 real; tableta: lectura 2,2 s, 31 ms por fotograma al mover, 440 ms por fotograma con los 4 M de puntos en reposo |
| Fuzz | 6 semillas × 315 casos | 0 fallos inesperados (se corrigieron 3 tipos de error en PCD, PTS y LAS) |
Pruebas: `test/cloud_formats_test.dart` (9). Dispositivos: iPhone (simulador) y tableta Xiaomi.

## 8. Puerta de calidad
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,5 | LAS 26/26 contra Python; LAZ = LAS; E57 contra el XML; sin archivos de escáneres reales en E57 |
| Información propia | 9 | sistema, unidad, densidad, precisión, clases, avisos |
| Herramientas específicas | 8,5 | 6 modos de color, clases, recorte, medir, tamaño |
| Rendimiento | 8,5 | 2,2 s y 31 ms en tableta; 440 ms en reposo con 4 M |
| Robustez | 8,5 | fuzz limpio, LASzip nativo sin caídas |
| Claridad | 8,5 | capturas iPhone y tableta |
| Frente al mejor | 8,5 | gratis y sin conexión; sin sombreado de borde ni COPC |
| Detalle y acabado | 8,0 | falta pulir la medición en pantallas pequeñas |
Media: 8,56 · Aprobado: sí · Fecha: 25-oct-2026
Deuda: sombreado de borde (EDL), secciones/perfiles, COPC y teselas, E57 de escáneres reales (Faro, Leica) y con imágenes, onda completa de LAS, clases personalizadas.

### Ronda hacia el 9 (25-oct-2026)
- **Sombreado de borde (EDL):** dos pasadas (color y profundidad empaquetada en dos canales) y un programa de fragmentos que oscurece los puntos con vecinos más cercanos. Se aplica en reposo, no al mover. Con más de 1,6 M de puntos usa una muestra de 1,5 M. Interruptor y fuerza en la hoja «Vista».
- Medido en la tableta (4 M de puntos): al mover 39 ms; en reposo con sombreado 273 ms. Comprobado en iPhone (Metal) y tableta (Vulkan).
- Filas que cambian: Herramientas específicas 9,0 · Frente al mejor 8,7. Media: **8,59**. Pendiente: secciones/perfiles, COPC, E57 de escáneres reales, pulir la medición en pantalla pequeña.

### Segunda ronda hacia el 9 (25-oct-2026)
- **E57 real:** `Union_Station.e57` (Trimble, 121 MB, 6,36 M de puntos con color e intensidad; reexportado con libE57Format 2.0.1): abre en 0,65 s mostrando una de cada dos.
- **Corte y perfil por eje:** además de la altura, ahora por X o Y: se ve una rodaja de la nube.
- Filas que cambian: Fidelidad 8,8. Media: **8,63**.

## Ronda hacia el 9 (3.ª tanda)
- **COPC:** se detecta (VLR `copc`) y se rotula como COPC. Se lee como LAZ normal (todo el archivo, sin pedir por zonas). Muestra real `autzen-classified.copc.laz` (81 MB, 10,65 M puntos): abre en 3,4 s en el Mac mostrando 3,55 M.
