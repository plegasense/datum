# HPGL — dossier de especialización

Estado: fase 8 / 8 · puerta superada (8,63) · Última actualización: 25-oct-2026

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Plóter de corte y rotulación | Archivos `.plt` de CAD o de programas de rotulación | Ver qué hará el plóter | Si falta algo, tamaño real y plumas | Foros de plóteres (hpgl2gcode, PlotterTools) |
| Ingeniería antigua | Planos de instrumentos de los 80–90 (HP, Tektronix) | Abrir archivos antiguos | Que se vean y que se lean las etiquetas | Colección VK2BEA |
| Máquinas CNC/láser | HPGL exportado a la máquina | Comprobar el recorrido | Cuánto viaja en vacío | hpgl2gcode |
No existe un visor móvil de HPGL (sólo PloViewMini y PlotVision en PC).

## 2. Especificación
HP-GL y HP-GL/2: instrucciones de dos letras (`IN SP PU PD PA PR PE CI AA AR AT RT EA ER RA RR EW WG PM EP FP SC IP SI SR DI DT LB PW PC`), unidad 0,025 mm, `PE` codificado (base 64/32, fracciones), `LB` hasta ETX, envoltorio PCL/PJL (`<Esc>%0B`). Rarezas: sentencias sin `;`, rótulos sin ETX, `SC` sin `IP`.

## 3. Estado del arte
| Función | PloViewMini / PlotVision (PC) | Datum |
|---|---|---|
| Móvil | No | Sí |
| Plumas con su longitud y trazos | Parcial | Sí |
| Viajes en vacío medidos y dibujables | No | Sí (capa «Viajes», oculta) |
| Rótulos | Parcial | Sí, como texto |
| Avisos (SC sin IP, instrucciones sin interpretar) | No | Sí |

## 4. Hueco y ventaja
1. Único visor móvil de HPGL, sin conexión.
2. Recorrido del plóter: pluma abajo, pluma arriba (%), levantadas y longitud por pluma, con aviso si >30 % es en vacío.
3. Rótulos mostrados y avisos de lo que no se interpreta.

## 5. Diseño específico
Cabecera: tamaño, «dibujo X mm», plumas, notas (sin «piezas/avisos de corte», que no tienen sentido en un plóter). Hoja «Sobre el archivo»: recorrido, plumas, rótulos, avisos.

## 6. Implementación
`io/hpgl_parser.dart` (nuevo): tokenizador, `PE`, modo polígono, arcos de tres puntos, rótulos, `SC/IP`, plumas (`PW/PC`), viajes; `ui/vector_tools.dart`.

## 7. Validación
| Origen | Archivos | Resultado |
|---|---|---|
| VK2BEA, spustlik, hpgl2gcode, ImageMagick, plottertools | 28 | 27 abren; 1 (sólo un punto) con mensaje |
| Referencia independiente (Python) en archivos con PU/PD/PA/PR | 16 | 16/16 coinciden en caja y longitudes (pluma arriba y abajo) |
| Fuzz | 5 semillas | 0 fallos inesperados |
| Dispositivos | iPhone y tableta | carga 173 ms |
Pruebas: `test/vector_formats_test.dart`.

## 8. Puerta de calidad
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,0 | longitudes 16/16; `PE`, arcos y `SC` sólo con pruebas propias, sin archivo real |
| Información propia | 9 | recorrido, plumas, avisos |
| Herramientas específicas | 8,5 | hoja de archivo, capa de viajes |
| Rendimiento | 9 | ≤30 ms |
| Robustez | 8,5 | fuzz limpio |
| Claridad | 8,5 | capturas |
| Frente al mejor | 9 | no hay otro móvil |
| Detalle y acabado | 8,5 | |
Media: 8,63 · Aprobado: sí · Fecha: 25-oct-2026
Deuda: conseguir un archivo real con `PE`; rótulos con tipo de letra del plóter (se muestran con la tipografía de la app); `RO`, `IW`, tipos de línea.

### Ronda hacia el 9 (25-oct-2026): archivos reales de hp2xx
- Se descargaron los 43 archivos de prueba del proyecto hp2xx (GPL, no se redistribuyen): HPGL y HPGL/2 con arcos, polígonos, rectángulos, cuñas, rótulos, plumas, grosores, colores y varias páginas. **Abren los 43** (antes, 42 de 43).
- Lo que los archivos reales destaparon y se corrigió: rótulos de varias líneas terminados en ETX (se cortaban en el primer salto de línea), `RO` (giro del sistema de coordenadas), curvas Bézier `BZ`/`BR` de HPGL/2 y varias instrucciones ignorables (`CP`, `LO`, `SL`, `XT`, `PS`, `IW`, `CA`…).
- Sigue sin aparecer un archivo real con `PE` (ninguno de los 70 que tengo lo usa). Fila que cambia: Fidelidad 8,6. Media: **8,70**.
