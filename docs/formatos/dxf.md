# DXF — dossier de especialización

Estado: fases 1–5 hechas; implementación en curso · Última actualización: 24-oct-2026

Convención: **[F]** = leído en una fuente citada; **[I]** = inferencia mía, sin verificar.

## 1. Usuarios

| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Operario de corte (láser, plasma, chorro de agua) | Recibe el DXF del cliente en taller o por correo | Comprobar que el archivo está listo para cortar: contornos cerrados, escala, sin duplicados | Si se corta tal cual o se devuelve al cliente | [F] Guías de preparación para corte láser: cada pieza debe ser un lazo cerrado, sin líneas duplicadas ni de longitud cero, con unidades y escala correctas y capas con nombre |
| Presupuestador | Cotiza trabajos de corte | Obtener longitud de corte, nº de perforaciones, caja envolvente y rendimiento de chapa | Precio y plazo | [F] Las herramientas de presupuesto leen del DXF "longitud de corte, perforaciones, caja envolvente y desperdicio"; en un foro, el cálculo manual es "longitud de perfiles y nº de perforaciones en una hoja de cálculo"; un taller universitario mide la longitud total seleccionando todas las líneas |
| Técnico de chapa / punzonadora | Revisa desarrollos de plegado | Ver contornos, agujeros y líneas de plegado (capas) | Si la pieza es fabricable | [F] El DXF de los desarrollos distingue plegados por capa/color; ya lo vimos en `BENDLINES` |
| Ingeniero o arquitecto en obra | Revisa planos en el móvil | Medir y consultar capas | Aprobar o pedir cambios | [F] CAD Reader (5 M+ descargas) y DXF Viewer apuntan a "ingenieros, arquitectos, contratistas" y a medir distancias, ángulos y áreas |
| Aficionado (CNC de sobremesa, láser de diodo, corte de vinilo) | Descarga DXF de internet | Ver si cabe en su máquina y si está bien | Cortarlo o no | [F] Foros de LightBurn: DXF hechos de líneas sueltas fallan al moverlos hasta que se unen en polilíneas |

## 2. Especificación

Fuentes: Wikipedia (AutoCAD DXF), documentación de ezdxf (unidades) y el hilo de Autodesk sobre `$INSUNITS`. **La referencia oficial de Autodesk no estaba accesible en la búsqueda;** lo marcado [I] se contrasta con muestras reales.

| Qué guarda un DXF | Detalle | ¿Lo mostramos hoy? |
|---|---|---|
| Unidades | `$INSUNITS` (0 sin unidad, 1 pulgadas, 4 mm, 5 cm, 6 m…) y `$MEASUREMENT` (0 inglés, 1 métrico). **Muchos archivos no lo traen o lo traen mal**: Onshape escribía 1 (pulgadas) aunque estuviera en mm [F]; `$MEASUREMENT` solo afecta a tipos de línea y rellenos, no a las unidades [F] | **No** |
| Geometría | LINE, CIRCLE, ARC, ELLIPSE, LWPOLYLINE y POLYLINE (con arcos por abultamiento), SPLINE, SOLID/TRACE/3DFACE, INSERT (bloques con rotación, escala y matrices) | Sí |
| Capas y color | Nombre, color ACI o verdadero, visibilidad | Sí (panel de capas) |
| Texto | TEXT, MTEXT | Sí |
| Acotaciones | DIMENSION (bloque anónimo con la geometría de la cota) y sus medidas | No dibujadas |
| Rellenos | HATCH (patrones y rellenos con sus límites) | No |
| Caja envolvente | `$EXTMIN`/`$EXTMAX` (a veces desfasadas) | Calculada de la geometría |
| Espacio papel / vistas | LAYOUT, VIEWPORT | No |

Rarezas [F]: DXF hechos de líneas sueltas en lugar de polilíneas; exportadores (Illustrator) que deforman curvas; textos y acotaciones mezclados con la capa de corte; bloques sin explotar.

## 3. Estado del arte

Visores de Android que he comprobado en Google Play (fichas y reseñas reales).

| Función | CAD Reader (Glodon) | DXF Viewer: CAD & Measure (nagyy) | DWG FastView | **Datum hoy** |
|---|---|---|---|---|
| Descargas / valoración | 5 M+ · 4,2–4,3 (14 mil reseñas) | 10 mil+ | muy alta | — |
| Precio | Gratis con **anuncios** (reseña: "no se pueden cerrar") y compras | Gratis con anuncios; medidas ilimitadas y exportación en versión Pro (suscripción) | con anuncios | **Gratis, sin anuncios** |
| Medir distancia, ángulo, área | Sí, con "ratón virtual" y ajuste | Sí (distancia, ángulo, área, coordenadas, caja) | Sí | Distancia entre puntos y figuras (círculos, arcos, contornos con perímetro y área) |
| Capas | Sí | Sí, jerárquico | Sí | Sí |
| **Longitud de corte, nº de contornos, perforaciones** | **No** | **No** | **No** | **No (a hacer)** |
| **Detección de contornos abiertos, duplicados** | No | No | No | **No (a hacer)** |
| Unidades del archivo | escala personalizada | escala | — | No |
| Exportar | PDF↔CAD | PNG, SVG, CSV | PDF | No |
| Anotar / marcar | Sí (texto, nube de revisión, fotos) | Dibujo a mano alzada | Sí | No |
| Orientado a | Obra / AEC | Obra / AEC | AEC | Taller y chapa |

Reseñas que importan [F]: anuncios que no se cierran (CAD Reader, oct-2026); petición de poder **girar el plano** (CAD Reader, 193 votos: "los planos salen torcidos y hace difícil hallar una línea recta"); la versión gratuita "es más que suficiente" para obra.

## 4. Hueco y ventaja

Hueco claro [F]: **ningún visor de Android de los líderes calcula lo que paga el taller** (longitud de corte, perforaciones, contornos) **ni avisa de los defectos que hacen fallar un corte** (contornos abiertos, líneas duplicadas, unidad dudosa). Todos están pensados para obra y arquitectura.

**Superaremos al mejor en:**
1. **Datos de corte exactos y gratis:** nº de contornos exteriores y agujeros, longitud total de corte, nº de perforaciones, caja envolvente y rendimiento de chapa, **por capa**. Criterio: coinciden con piezas de medidas conocidas con error < 0,01 mm.
2. **Revisión de archivo antes de cortar:** contornos abiertos, líneas duplicadas, segmentos diminutos y texto/cotas en capas de corte, con su ubicación resaltada y un veredicto claro ("listo para cortar" / "revisar"). Ninguno de los visores comprobados lo hace.
3. **Unidades a la vista:** unidad declarada por el archivo y aviso cuando falta o es dudosa, con la posibilidad de corregirla (mm / pulgadas) y ver cómo cambia el tamaño. Es el fallo más citado de los DXF [F].
4. **Sin anuncios y sin suscripción** (reseñas negativas de los líderes).
5. **Unir líneas sueltas en contornos** al analizar, como hacen los programas de corte (hoy, un rectángulo hecho de 4 LINE cuenta como 4 piezas abiertas en otros visores).
6. **Girar el plano** con dos dedos (petición con 193 votos).
7. Relleno de contornos para distinguir pieza y agujero.

Fuera de alcance en este formato: edición, DWG nativo, exportar a PDF.

## 5. Diseño específico (propuesta)

**Cabecera:** nombre · tamaño con unidad (mm / pulgadas, y "unidad sin indicar" si falta) · "N piezas · M agujeros" · veredicto ("Listo para cortar" en menta, "Revisar" en naranja).

**Barra:** Centrar · Capas · **Datos de corte** · **Revisión** · Medir · Relleno · Girar plano.

**Datos de corte (hoja):** por capa y total — contornos exteriores, agujeros, abiertos, longitud, perforaciones; caja envolvente, área neta de pieza y rendimiento; nº de piezas distintas. Botón para copiar en CSV.

**Revisión (hoja):** lista de problemas con ubicación y botón "ver" (se resalta en el plano): contornos abiertos (con la separación del hueco), líneas duplicadas, segmentos menores de una tolerancia, textos y cotas en capas con geometría, unidad dudosa.

**Textos:** vocabulario del oficio ("contorno", "agujero", "perforación", "longitud de corte", "rendimiento de chapa").

## 6. Implementación (24-oct-2026)

- **Unidades:** se lee `$INSUNITS`; si falta, el archivo se marca «unidad sin indicar» y el usuario elige en qué están los números (mm, cm, m, pulgadas). Todas las medidas (cabecera, medir, datos de corte) llevan unidad.
- **Análisis de corte** (`lib/model/drawing_stats.dart`): une tramos sueltos en contornos por sus extremos (tolerancia relativa al tamaño), separa los lazos cerrados de las repeticiones, clasifica pieza o agujero por profundidad de contención (índice espacial: 160 000 segmentos en 0,2 s), calcula longitudes exactas (arcos y círculos analíticos), área neta, rendimiento y piezas distintas, por capa. Solo cuentan las capas de corte (se excluyen cotas, textos, plegados, rellenos, chapa/stock…; el usuario puede marcar o desmarcar cada una).
- **Revisión:** contornos abiertos (con el hueco que falta cerrar), líneas repetidas, segmentos diminutos, unidad sin indicar y archivo incompleto; veredicto «Listo para cortar» o «N avisos»; botón «Ver» que resalta y encuadra el problema.
- **Interfaz propia de DXF:** barra con Capas · Ajustar · Girar el plano 90° · Datos de corte · Revisión · Relleno de contornos · Medir. Cabecera con tamaño con unidad, «N piezas · M agujeros» y veredicto.
- **Lectura del DXF:** nuevas entidades — contornos de **HATCH** (líneas, arcos, elipses, polilíneas, en una capa «(relleno)» propia para no contarlos dos veces) y **DIMENSION** (dibujo de la cota); mensajes claros para DXF binario, vacío, ajeno o incompleto.
- **Medir:** reconoce figuras (círculo, arco, línea, rectángulo, contorno cerrado) con la unidad del archivo.
- Corregido: un rectángulo se confundía con un círculo (cuatro esquinas caben en una circunferencia); ahora se exige avance angular pequeño entre puntos.

## 7. Validación

**Piezas de medidas conocidas** (`tools/make_dxf_samples.py` → `testdata/dxf/`; `dart run tool/verify_dxf.dart ../testdata/dxf`): 

| Caso | Esperado | Obtenido |
|---|---|---|
| Placa 100×50 con 2 agujeros Ø8 (4 LINE sueltas) + pieza 20×10 (polilínea) | 2 piezas, 2 agujeros, corte 410,265 mm, área neta 5 099,469 mm², 2 distintas, 0 avisos | exacto |
| Rectángulo con un hueco de 0,5 mm | 1 contorno abierto, aviso con «hueco de 0,5» | exacto |
| Rectángulo con un lado repetido | 1 pieza + 1 línea repetida | exacto |
| Ranura de 4 tramos (2 rectas + 2 arcos) en pulgadas | 1 pieza, corte 71,416, área 278,54, unidad 1 = pulgadas | 71,411 / 278,494 (error por teselado de arcos < 0,02 %) |
| Sin unidad | unidad 0 | exacto |

**Archivos reales:** 5 de `Piezas CAD` (logo del perro, 3 chapas de corte de 2 500 × 1 250: 42–83 piezas) y 19 DXF públicos (ezdxf: rellenos, cotas en bloques, columnas, arcos horarios, archivos raros; LibreCAD: símbolos, bloques, plantillas). 21 de 24 abren; los 3 que no (mínimo de 35 bytes, plantilla vacía y mínimo AC1021) no contienen geometría y lo dicen.
**Rendimiento** (emulador Android, 4 núcleos, compilación *profile*): chapa sintética de 20 000 piezas con agujero (160 000 segmentos, 3 MB): carga 2,1 s, análisis 0,2 s, 41 fps arrastrando el plano con una pasada de línea (el cuello de botella es el dibujado de líneas de la GPU del emulador). El relleno se limita a 2 500 contornos.
**Archivos rotos** (`tool/verify_robust_dxf.dart`): 9 casos sin cierre inesperado (vacío, texto, cortado a la mitad —abre y avisa de que está incompleto—, binario, corrupto, línea de 3 MB, coordenadas de 1e300).
**Capturas:** `docs/formatos/dxf/`.

## 8. Puerta de calidad — todavía NO aprobada (autoevaluación crítica)

| Fila | Nota | Evidencia y lo que falta |
|---|---|---|
| Fidelidad | 8 | Entidades habituales, HATCH, DIMENSION, unidades. Faltan splines dentro de rellenos, espacio papel y DXF binario |
| Información propia | 8,5 | Datos de corte, revisión, unidades — lo que ningún visor móvil comprobado ofrece |
| Herramientas específicas | 8 | Medir figuras, relleno, girar 90°, ver problemas. Falta lectura de coordenadas bajo el dedo, gesto de dos dedos para girar (sin comprobar) y exportar |
| Rendimiento | 8 | 160 000 segmentos: carga 2,1 s, análisis 0,2 s, 41 fps en emulador. Sin medir en móvil real |
| Robustez | 8 | 24 archivos reales/públicos y 5 generados con valores conocidos, 9 rotos. Faltan DXF exportados por más programas de corte (LightBurn, Fusion 360, SolidWorks) |
| Claridad | 8 | Vocabulario del oficio, avisos con su ubicación. Los avisos de duplicados no se pueden recorrer uno a uno |
| Frente al mejor | 9 | Ningún visor comprobado da longitud de corte, perforaciones ni revisión; sin anuncios |
| Detalle y acabado | 8 | Probado en iOS y Android; sin dedos reales ni tablet todavía |

Media: **8,2**. Igual que en STEP, la puerta no se cumple por la falta de una prueba en dispositivo físico y de más archivos de otros programas.

## Prueba en tableta física (24-oct-2026)
Xiaomi 25040RP0AE (Helio G99, Mali-G57, 2560×1600).
- **Fallo encontrado y corregido:** todos los DXF salían **en blanco** (el análisis sí funcionaba). Causa: matriz ortogonal con profundidad estilo OpenGL, recortada por Vulkan. Corregida; ahora dibuja en tableta y en iPhone.
- Chapa sintética de 20 000 piezas con agujero (5,9 MB): carga 2,8 s, 20 ms por fotograma al desplazar (8,7 ms de construcción + 11,4 ms de trama). 2 000 piezas: carga 0,25 s, 7 ms.
- Nota Rendimiento: 8,5 (medido en dispositivo real).

## Segunda ronda hacia la puerta (24-oct-2026)
Cambios: DXF **binario** (R12 y R13+; antes se rechazaba), bordes de **spline** dentro de rellenos, **espacio papel** cuando el modelo está vacío, archivos de **solo texto** y **fragmentos sin secciones**, mensajes más claros, **barra de avisos** («Aviso 2 de 5» con anterior/siguiente), **giro con dos dedos** (se endereza a 0/90/180/270° si queda a menos de 6°) y textos que giran con la vista. Corregido el dibujo en blanco en Vulkan.
Validación con **96 DXF reales de terceros** (`testdata/_externos/dxf_otros/`: SolidWorks, Inkscape, FreeCAD, QCAD, LibreCAD, AutoCAD R12–R2018, Langmuir/plasma, OpenBuilds, CAMnest/OpenNest, ezdxf, 5 binarios): 92 se abren y 4 no tienen dibujo (solo bloques o tablas; mensaje claro); análisis de corte de 244 mil segmentos en 82 ms. Fuzz: 9 casos sin cierres. Pruebas: `dxf_binary_test.dart` (binario = texto, R12 y R13+).
En la tableta: giro de dos dedos simulado con punteros reales (30° → 27°, zoom ×2,17), chapa de 20 000 piezas con carga 2,8 s y 20 ms por fotograma.
No se encontraron archivos públicos de LightBurn ni Fusion 360 con cabecera comprobable.
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,5 | binario, splines en rellenos, papel/modelo, solo texto, 92/96 reales |
| Información propia | 8,5 | datos de corte y revisión únicos entre los visores móviles |
| Herramientas específicas | 8,5 | medir, giro con dos dedos verificado, recorrer avisos, relleno, girar 90° |
| Rendimiento | 8,5 | 20 ms con 20 000 piezas en la tableta |
| Robustez | 8,5 | 96 reales de ≥ 15 programas + fuzz |
| Claridad | 8,5 | barra de avisos con «n de m» y textos del oficio |
| Frente al mejor | 9 | ningún visor comprobado da longitud de corte ni revisión |
| Detalle y acabado | 8,5 | probado en iPhone, emulador y tableta física |
Media: **8,56** · Aprobado: **sí** (24-oct-2026). Deuda: exportaciones reales de LightBurn y Fusion 360.

## Ronda hacia el 9 (3.ª tanda)
- **Exportar DXF:** «Guardar DXF de las capas marcadas» en Datos de corte (`io/dxf_writer.dart`, AC1015: LINE, CIRCLE, ARC, LWPOLYLINE, TEXT, capas con color). Ida y vuelta sobre 119 archivos: 110 iguales (diferencias <1 % por reteselado de arcos), 9 sin dibujo. Los arcos que el ajuste no reproduce se guardan como polilínea.
