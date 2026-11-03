# 02 · Formatos: qué se puede abrir y cómo

Honestidad por delante: **no todos los formatos son posibles gratis.** Los clasificamos por viabilidad real.

## Nivel 1 · Seguro (v0.1)
| Formato | Cómo | Notas |
|---|---|---|
| STL (ASCII y binario) | Lector propio en C++ | Sin dependencias; tiene que ser muy rápido (mallas de millones de triángulos) |
| OBJ (+ MTL) | Lector propio o Assimp | Colores y materiales básicos |
| 3MF | lib3mf (BSD) o lector propio (zip + XML) | Colores, múltiples objetos, unidades |
| STEP `.stp .step` (AP203/214/242) | Open CASCADE (OCCT), módulo XCAF | **Clave:** XCAF da estructura del ensamblaje, nombres, colores, capas e instancias |
| IGES `.igs .iges` | OCCT | Superficies; menos estructura que STEP |
| BREP `.brep` | OCCT | Formato nativo de OCCT |

**Riesgo:** OCCT compila para Android (NDK, arm64) según su guía oficial; para iOS es habitual compilarlo como framework, pero no lo he verificado aquí. Hay que comprobar tamaño de la app, tiempo de teselado en el móvil y memoria, en las dos plataformas. Se resuelve en el hito M0.

## Nivel 2 · Alcanzable (v1.0)
| Formato | Cómo | Notas |
|---|---|---|
| DXF (2D y caras 3D) | **Lector propio** (D-02: no usamos librerías GPL por la App Store) | Líneas, arcos, círculos, polilíneas, texto, bloques, capas |
| G-code | Lector propio | Es el "CAM" de Datum: ver trayectorias, capas, tiempos estimados |
| glTF/GLB, PLY, OFF | Librerías pequeñas permisivas | Fáciles |
| FreeCAD `.FCStd` | ZIP con BREP, lo lee OCCT | Sin parámetros, solo geometría |
| Rhino `.3dm` | openNURBS (licencia permisiva) | A confirmar |

## Nivel 3 · Con licencia delicada
| Formato | Problema |
|---|---|
| DWG | LibreDWG (GPLv3+) lo lee casi todo, pero **la GPL choca con la App Store**, así que queda descartado mientras Datum salga en iOS. libdxfrw (GPLv2+) tiene el mismo problema. La alternativa es el SDK comercial de Open Design Alliance |
| IFC | IfcOpenShell (LGPL) existe; pesado para móvil. Después |
| JT, Parasolid `.x_t`, ACIS `.sat` | Formatos de terceros con kits comerciales |

## Nivel 4 · Formatos nativos propietarios (el punto difícil)
**SolidWorks `.sldprt .sldasm`, Inventor `.ipt .iam`, NX/Creo `.prt`, CATIA `.catpart`, Solid Edge, etc.**

- **No existe una librería libre y completa** que los lea. El SDK de Open Design Alliance (MCAD) los lee, pero es comercial: su web ofrece prueba de 60 días, solo para SolidWorks e Inventor, y no pude confirmar precios.
- Aunque pudiéramos, cada formato cambia con cada versión del programa.

**Qué haremos en su lugar (por orden de coste):**
1. **Detectar el formato y explicarlo.** La app reconoce `.sldprt`, `.ipt`, etc. y dice: "Este formato es propietario. Expórtalo como STEP desde X", con la ruta exacta en SolidWorks, Inventor, Fusion, NX y Creo.
2. **Mostrar la miniatura incrustada** cuando el archivo la traiga (por investigar: algunos formatos guardan una vista previa).
3. **Después de v1.0, evaluar** el SDK de Open Design Alliance o una conversión externa. Cuesta dinero y/o enviaría archivos fuera del móvil, lo que choca con el principio de privacidad.

> Esto significa que, en las primeras versiones, **Datum no abrirá directamente `.ipt` ni `.sldprt`.** Conviene decidirlo con los ojos abiertos (ver `06-decisiones.md`, D-04).

## Cómo se detecta el formato
Por extensión y, sobre todo, por cabecera del archivo (los archivos llegan renombrados o sin extensión). Un único punto de entrada: `FormatDetector`.

## Corpus de pruebas
Una carpeta `testdata/` con archivos pequeños de cada formato y un script que descarga modelos grandes de fuentes con licencia clara (modelos de prueba del NIST, ejemplos de OCCT). No se suben archivos de terceros sin licencia al repositorio.


---

# Catálogo ampliado (investigación del 24/10/2026)

Búsqueda más amplia de formatos del mundillo, con lo que se puede hacer sin pagar. Marcado **(verificado)** lo que comprobé en una fuente y **(sin verificar)** lo que viene de mi conocimiento general.

## Hecho
STEP, IGES, BREP, STL, OBJ, 3MF, DXF, G-code (`.gcode`, `.nc`, `.ngc`, `.tap`…) y proyectos laminados de Bambu/Orca (`.gcode.3mf`).

**Añadidos el 24/10/2026:** PLY (ASCII y binario, mallas y nubes), glTF/GLB, VRML 2.0, STEP comprimido (`.stpz`, `.stp.gz`), SVG, HPGL/PLT, nubes de puntos XYZ/PTS/PCD y G-code binario de Prusa (`.bgcode`).

### Cómo se han comprobado (honestidad)
| Formato | Prueba |
|---|---|
| STEP, STL, OBJ, 3MF, DXF, G-code, `.gcode.3mf` | 137 archivos reales de la carpeta del autor |
| PLY (1,87 M de triángulos) | Convertido por mí desde un STL real; 0,4 s |
| Nube de 600 mil puntos | Generada a partir de un STL real |
| PLY pequeño, glTF/GLB, VRML, SVG, HPGL, PCD, PTS, `.stpz` | **Solo archivos sintéticos que generé yo** (`tools/make_format_samples.py`). Falta probar con archivos reales de otros programas |
| `.bgcode` | **Solo archivos sintéticos hechos por mí** siguiendo la especificación de Prusa (`tools/make_bgcode_sample.py`); nunca con uno real de PrusaSlicer. El decodificador de MeatPack y heatshrink sigue la especificación y el código fuente de libbgcode, pero un fallo sutil solo aparecería con un archivo real |

### Limitaciones conocidas
- glTF con compresión Draco o meshopt: no soportado (da un aviso claro). Sin texturas.
- VRML: solo 2.0 con `IndexedFaceSet`; sin VRML 1.0 ni X3D.
- SVG: contornos de trazados y formas, sin texto, sin `use`, sin degradados.
- HPGL: sin texto de plóter ni HPGL/2 binario.
- PCD: sin `binary_compressed`.
- Las nubes de puntos se limitan a 6 millones de puntos.

## Victorias rápidas (sin licencias problemáticas)
| Formato | Para qué | Cómo |
|---|---|---|
| PLY, OFF | Mallas y nubes de puntos de escáner | Lector propio, unas horas |
| glTF / GLB | Intercambio 3D moderno (web, AR) | Lector propio (JSON + binario) |
| `.stpz` | STEP comprimido | gzip + el lector de STEP que ya tenemos |
| VRML / X3D | 3D antiguo, aún frecuente | OCCT incluye lector VRML (TKDEVRML) (verificado en su lista de módulos) |
| AMF | Impresión 3D (XML + zip) | Lector propio |
| 3DS, DAE (Collada), FBX | Modelado y animación | Assimp (licencia BSD, sin verificar) o `ufbx` para FBX |
| SVG | Dibujo vectorial 2D, láser y corte | Lector propio de trazados |
| HPGL / PLT | Plóter y corte | Lector propio, formato simple |
| Gerber / Excellon | Placas de circuito (PCB) | Lector propio, formato simple |
| XYZ, PTS, PCD | Nubes de puntos | Lectores propios (texto) |
| FCStd (FreeCAD) | CAD paramétrico (solo geometría) | ZIP con BREP, lo lee OCCT |
| `.bgcode` (Prusa) | G-code binario de Prusa | Formato público; lector propio (zlib + heatshrink) (sin verificar) |
| `.ufp` (Ultimaker) | G-code empaquetado | ZIP con G-code |
| Resina: `.sl1`, `.ctb`, `.cbddlp`, `.photon` | Archivos laminados de impresoras de resina | Documentados por la comunidad; mostrar capas (sin verificar; mi búsqueda no encontró fuentes) |

## Con más trabajo o con licencia a revisar
| Formato | Situación |
|---|---|
| Rhino `.3dm` | openNURBS: McNeel dice que se puede usar comercialmente sin restricciones de copyleft (verificado); revisar el texto exacto de la licencia |
| IFC (construcción) | IfcOpenShell es LGPL (verificado). Pesado para móvil |
| E57, LAS/LAZ (escáneres) | libE57Format y laspy: licencias sin verificar |
| SketchUp `.skp` | SDK de Trimble: no pude verificar sus condiciones |
| JT | El kit de Siemens es de pago (verificado) |
| Parasolid `.x_t`, ACIS `.sat` | Kits comerciales; no encontré lector libre |
| DWG | LibreDWG (GPLv3), choca con la App Store; ODA (de pago); RealDWG (Autodesk, de pago) |
| Dialectos de control (Heidenhain, Siemens Sinumerik) | Se pueden leer como G-code ampliado; requiere pruebas con archivos reales |
| APT / CL data | Formato neutro de CAM, simple; sin verificar uso real |
| PDF 3D (PRC), U3D | Formatos de nicho |

## Formatos nativos propietarios (SolidWorks, Inventor, NX, Creo, CATIA…)
Ver `06-decisiones.md`, D-04. Resumen de lo que averigüé:
- Existen SDK comerciales: Open Design Alliance (membresías de unos miles de dólares al año según su web, con precio de extensiones no público), CAD Exchanger, HOOPS Exchange y Datakit. **No pude confirmar precios de los tres últimos.**
- Un archivo `.ipt` de Inventor es un contenedor OLE2 con flujos propios (`RSeDb`, `RSeStorage`) y geometría del núcleo ShapeManager, derivado de ACIS (verificado en la documentación de un proyecto de FreeCAD). Existe un lector comunitario (InventorLoader, Python, para FreeCAD) que solo cubre Inventor 2010 o superior y no parece mantenido; Autodesk cambia el formato cada año.

## Validación con archivos reales (M7)

| Formato | Archivo real | Resultado |
|---|---|---|
| PLY (binario y ASCII) | Exportados con Blender 5.2.3 | OK, 2132 triángulos |
| GLB | `signa_avatar.glb` (real) y Blender | OK, colores de material correctos |
| glTF + .bin separado | Blender | OK, 2132 triángulos |
| SVG | 40 archivos reales (Twemoji, etc.) | OK |
| .bgcode | 2 archivos reales de libbgcode (PrusaSlicer 2.8.1) | OK: mismos movimientos que su .gcode de referencia (1107/32 capas y 19634/122 capas) |
| glTF/GLB Khronos | Box, BoxVertexColors, CesiumMilkTruck | OK |
| PCD | canny, chef, closing_binary (PCL) | OK; los tres son `binary_compressed` (LZF), implementado tras esta prueba; nº de puntos = cabecera |
| VRML | Wuson.wrl (Blender 2.45): OK, 3732 tri. HelloWorld.wrl (X3D): FALLA | Faltan primitivas (Sphere/Box/Cone/Cylinder); solo se leen IndexedFaceSet |
| HPGL, PTS/XYZ, .stpz | Solo muestras sintéticas | **Pendiente**: sin fuentes públicas fiables |
