# STL — dossier de especialización

Estado: fases 1–8 hechas · Última actualización: 24-oct-2026

[F] = leído en fuente citada; [I] = inferencia mía.

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Quien imprime en 3D | Descarga un STL o lo recibe de un cliente | Saber si se puede laminar tal cual, cuánto pesa y si cabe | Imprimirlo, repararlo o devolverlo | [F] Las guías de reparación coinciden en los defectos que hacen fallar un laminado: aristas no-manifold, normales invertidas, agujeros, cascos sueltos o solapados |
| Granja o servicio de impresión | Recibe muchos archivos | Filtrar los defectuosos antes de gastar material | Aceptar o rechazar el trabajo | [I] |
| Diseñador | Exporta desde CAD/Blender | Comprobar la exportación y la escala | Re-exportar | [F] Blender tiene el complemento 3D-Print Toolbox para comprobar la variedad |

## 2. Especificación
- STL binario: 80 bytes de cabecera + nº de triángulos + 50 bytes por triángulo (normal, 3 vértices, 2 bytes de atributo). ASCII: bloques `solid … facet … vertex … endsolid`, con posible varios sólidos, mayúsculas, CRLF o CR, espacios delante.
- **No lleva unidades ni conectividad**: cada triángulo repite sus vértices; hay que soldarlos para saber si la malla es cerrada.
- Color: extensión de Magics (cabecera con `COLOR=` y 15 bits RGB por triángulo en el atributo); no es estándar.
- Casos comprobados con archivos reales: ASCII con espacio antes de «solid», mayúsculas (`SOLID`, `FACET`), binario cuya cabecera empieza por «solid», binario truncado, coordenadas no finitas, archivo vacío.

## 3. Estado del arte
| Función | Fast STL Viewer (Android) | STL Simple Viewer / STL Viewer 3D (iOS) | Slicers (Prusa/Orca/Bambu) | **Dovexa** |
|---|---|---|---|---|
| Triángulos, caja envolvente | sí | sí | sí | sí |
| Superficie, volumen | — | sí | sí | sí |
| Peso por material | — | alguno | sí | sí (7 materiales, relleno) |
| ¿Es estanca? aristas abiertas, no-manifold, orientación | **no** | **no** | reparan en silencio (Windows) | **sí, con localización** |
| ¿Cabe en mi impresora? | no | no | sí | sí (7 camas) |
| Voladizos coloreados | no | no | sí | sí, con ángulo y área |
| Mejor orientación | no | no | algunos | sí (6 caras) |
| Sección, medir entre puntos | no / sí | — | no | sí |
[F] Las fichas de las tres apps móviles no mencionan comprobaciones de malla, cama ni voladizos.

## 4. Ventaja (medida)
1. Diagnóstico de malla en el móvil, sin conexión: 91 archivos reales revisados; un casco de 950 mil triángulos se revisa en 2,5 s en la tableta.
2. Cada defecto se localiza en el modelo (agujeros uno a uno, aristas no-manifold, orientación mezclada).
3. Lo que decide el operario sin abrir el laminador: peso y filamento, ¿cabe?, ¿qué orientación necesita menos soportes?

## 5. Diseño
Cabecera: estado de la malla («Estanca» / «N problemas»), medidas, volumen y masa; avisos de unidad dudosa. Barra: revisión, impresión, voladizos, sección, medir, color del archivo, alambre. Hojas: *Revisión de la malla*, *Impresión* (unidad, material, relleno, cama, orientación, voladizos), *Sección*.

## 6. Implementación
`mesh_check.dart` (soldadura con rejilla y vecinas, aristas por conteo y sentido, cascos con volumen con signo, agujeros por contornos); `stl_loader.dart` (formatos, cabecera, no finitos, color Magics); `stl_tools.dart` (controlador y hojas, voladizos y orientaciones en otro hilo, versión simplificada para mallas de más de 400 mil triángulos). Pruebas: `mesh_check_test`, `stl_loader_test`, `stl_overhang_test` (valores conocidos: cubo 1000 mm³/600 mm², agujero de 3 aristas, orientación…).

## 7. Validación
- 96 STL reales (trimesh, admesh, assimp, numpy-stl, three.js, PrusaSlicer, OpenSCAD, Cura, NASA, Benchy…): 91 se abren, 4 están vacíos o ilegibles (mensaje claro), 1 ZIP no probado.
- Hallazgos que corregimos con ellos: ASCII con espacio delante y en mayúsculas se leían como binario; binario truncado con «solid» en la cabecera; vértices con ruido de 1e-5 no se soldaban (rejilla con vecinas).
- Referencias: Benchy 15 550,5 mm³ y 19,3 g PLA, 9 agujeros y 563 triángulos degenerados; cubo de 20 mm = 8 000 mm³; defectos de admesh detectados (agujero, normales, no-manifold).
- Robustez: 516 casos truncados o corrompidos, 0 fallos inesperados (más lento 42 ms).
- Tableta Xiaomi (Helio G99): Benchy (225 mil tri) carga 0,2 s, revisión 1,1 s, 22 ms por fotograma; Vesta (800 mil) 0,49 s / 3,4 s / 31 ms; Linne (950 mil, 47 MB) 0,5 s / 3,4 s / 29 ms (versión simplificada al girar). Toques reales: medir de la chimenea al casco = 37,19 mm (ΔX 23,72 · ΔY 12,59 · ΔZ 25,72).

## 8. Puerta de calidad
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,5 | variantes de formato reales, color Magics, unidades sugeridas |
| Información propia | 9 | diagnóstico, masa/filamento, cama, orientación, voladizos |
| Herramientas específicas | 8,5 | revisión localizada, voladizos, cama, sección con tapa, medir, color |
| Rendimiento | 8,5 | 29–31 ms con 0,8–0,95 M de triángulos en la tableta |
| Robustez | 8,5 | 516 corrupciones + 96 reales |
| Claridad | 8,5 | veredicto en una frase y cada defecto explicado |
| Frente al mejor | 9 | ningún visor móvil comprobado revisa la malla ni la cama |
| Detalle y acabado | 8,5 | probado con toques reales en una tableta |
Media: **8,69** · Aprobado: **sí** (24-oct-2026). Deuda: espesor mínimo de pared, autointersecciones, reparación y exportación del STL arreglado.

### Ronda hacia el 9 (25-oct-2026)
- **Espesor de pared:** desde cada cara se lanza un rayo hacia dentro y se mide hasta la pared de enfrente (BVH propio). Hoja «Impresión»: umbral ajustable, pared más fina, porcentaje de superficie por debajo (rojo) y justa (amarillo), y el modelo coloreado.
- Comprobado: cubo macizo = lado; cubo hueco = 2,000 mm; pared descentrada = 0,500 mm (4 pruebas); Benchy (225 mil triángulos) 1,4 s en el Mac; tableta con 545 mil triángulos 4,4 s.
- Fila que cambia: Herramientas específicas 9,0. Media: **8,75**. Pendiente: autointersecciones, reparación y exportación.

## Ronda hacia el 9 (3.ª tanda)
- **Autointersecciones:** botón «Buscar» en la hoja de análisis (`findSelfIntersections`, BVH + prueba arista-triángulo, ignora triángulos que comparten vértice). 0,8–2,8 s en mallas de 400–550 mil caras (NASA DART: más de 5 000 pares, Curiosity: 0). Sin reparación ni exportación todavía.
