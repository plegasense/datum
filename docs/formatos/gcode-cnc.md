# G-code CNC (fresado, plasma, láser) — dossier de especialización

Estado: fases 1–7 hechas; puerta provisional · Última actualización: 24-oct-2026

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Maquinista / aficionado de CNC | Tiene el programa del CAM antes de cargarlo | «Backplot»: comprobar recorrido, límites y herramientas antes de arrancar | Cargar o no el programa | [F] CAMotics, NC Viewer y CIMCO se describen como verificadores de trayectoria; webgcode muestra límites y tiempo; CIMCO detecta fallos como retiradas ausentes |
| Programador CAM | Revisa el posprocesado | Ver cambios de herramienta, ciclos fijos, avances | Corregir el posprocesador | [I] |

## 2. Especificación
Dialectos: Fanuc/Haas/Grbl (códigos planos, G54, G43, ciclos G81–G89, movimiento modal sin G) y LinuxCNC RS-274/NGC (parámetros `#`, expresiones `[ ]`, subrutinas y condicionales con `O`). Comprobado en archivos reales de LinuxCNC: sin intérprete, 3D_Chips, daisy y mmount fallaban o salían incompletos.

## 3. Estado del arte
CAMotics (simulación de material, ajustes de máquina), NC Viewer (reproduce la trayectoria, bloque a bloque), webgcode (línea seleccionada → movimiento, límites, tiempo), CIMCO ($299, referencia del sector). [F] Las fuentes no confirman lista de herramientas ni alarmas de recorrido.

## 4. Ventaja
1. Offline en el móvil, sin cuenta (CAMotics/CIMCO son de escritorio).
2. Ficha de aviso: bajada en G0 por debajo de Z0 (con línea), husillo sin encender, unidades sin declarar, lógica no soportada.
3. Línea de código en curso junto a la trayectoria y reproducción.

## 5–6. Diseño e implementación
`gcode_loader.dart` interpreta: parámetros y expresiones (`ngc_calc.dart`); O-words de LinuxCNC (sub/call, if/else, while, do-while, repeat, break/continue); macros Fanuc (IF…GOTO, WHILE…DO/END, M98 P L / M99, subprogramas locales M97 de Haas); ciclos G73/G74/G76/G81–G89 con G98/G99; movimiento modal sin G; G53/G28/G30 sin dibujar; G91.1 y similares sin confundir con G91; G54 antes del movimiento; CRLF. Cortes de seguridad: 4 M pasos con lógica.
UI: `CncCard` (línea en curso, simulación, color Avance/Profundidad/Herramienta, **tocar el recorrido lleva a su línea**), ejes del origen y caja de límites del corte, `CncInfoPanel` (avisos, resumen, límites, herramientas con tiempo y recorrido, avance, husillo, refrigerante).
Avisos: bajada en G0 por debajo de Z0 (con línea), husillo sin M3/M4, unidades sin declarar (y sospecha de pulgadas), compensación G41/G42, varios sistemas de coordenadas, lógica no soportada.

## 7. Validación
22 archivos de terceros (carpetas `cnc/` y `cnc_otros/`): LinuxCNC (mmount, 3D_Chips, daisy, comp-g1…), Fanuc/Haas de ejemplo (G54, G41, G43, G81/G83, M98, M97, G154), Mach3/OneCNC, Vectric `.tap`, V-Carve, CamBam, PyCAM, Easel, cncjs (G42, láser).
Antes: 3 de 7 archivos de LinuxCNC fallaban o salían incompletos. Ahora: 21 de 22 se leen; `m6demo` no contiene movimientos (mensaje claro). Casos con valor comprobado: mmount 5.719 mov. (antes 638), 3D_Chips 4.681 (antes error), daisy 51 (antes error), Haas VF-2 34 (antes error por G154), Fanuc con WHILE/M98 (test).
Robustez: fuzz de 258 archivos, 0 fallos inesperados; bucle infinito cortado en 0,9 s; recursión y expresiones inválidas sin colgarse.
Tests: `app/test/gcode_test.dart`.
Capturas: `gcode-cnc/*.png`.
No cubierto: código real de Fusion 360/Mastercam/Haas posprocesado (no se encontró público); compensación de radio y longitud; desplazamientos de G54–G59; simulación de material.

## 8. Puerta (segunda evaluación)
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8 | 21/22 archivos; sin compensaciones ni offsets (avisados) |
| Información propia | 8,5 | avisos, límites, herramientas con tiempo, línea de código |
| Herramientas específicas | 8,5 | tocar↔código, simulación, ejes y caja, 3 modos de color |
| Rendimiento | 8 | 10.646 mov. en 14 ms; sin dispositivo físico |
| Robustez | 8,5 | 258 corrupciones, bucles cortados |
| Claridad | 8 | |
| Frente al mejor | 8 | gana: móvil sin conexión; tocar recorrido→línea; avisos automáticos; 5 dialectos en una app. Pierde: sin simulación de material (CAMotics) |
| Detalle y acabado | 8 | |
Media: **8,19** · Aprobado: **no**. Para aprobar: compensación de radio con diámetro de herramienta y desplazamientos G54, o simulación de material; validar con posprocesado real.

## Segunda ronda hacia la puerta (24-oct-2026)
Cambios: **simulación de material** 2,5D (mapa de alturas que se talla con la fresa; plana o esférica; diámetro desde el comentario de la herramienta —«D12», «Ø6», «1/4"»— o editable en la ficha), **compensación de radio G41/G42 aplicada** al tallar, **sistema M98/M99 de Fanuc, M97 de Haas, IF/GOTO/WHILE-DO**, G54–G59 sin tragarse el movimiento, **tiempo y recorrido por herramienta**, ejes del origen y caja de límites, aviso de varios sistemas de coordenadas y de unidades sospechosas, y el avance se puede fijar **tocando el recorrido**.
Validación: 22 archivos de terceros (LinuxCNC, Fanuc/Haas, Mach3, Vectric, CamBam…); 4 pruebas de la simulación con valores conocidos (cajera de 20×20 Ø4 y 3 mm, G41 a la izquierda, fresa esférica, diámetro desde comentario) y 8 del intérprete. Tableta física: carga 150–250 ms; reproducción del material a 24 ms por paso (mmount, 5 719 movimientos) y 34 ms (3D_Chips, 4 681); toque sobre el recorrido lleva a «Línea 17 · G1 X155.».
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,5 | G41/G42 aplicada en la simulación; sin desplazamientos de G54 (avisado) |
| Información propia | 8,5 | avisos, límites, herramientas con tiempo y Ø |
| Herramientas específicas | 9 | material, tocar↔código, reproducción, Ø editable, ejes y caja |
| Rendimiento | 8,5 | 24–34 ms por paso de simulación en la tableta |
| Robustez | 8,5 | 22 reales + fuzz de 258 archivos |
| Claridad | 8,5 | avisos con línea, estimaciones etiquetadas «supuesto» |
| Frente al mejor | 9 | ofrece en el móvil sin conexión lo central de CAMotics (material tallado) más avisos automáticos |
| Detalle y acabado | 8,5 | probado en iPhone, emulador y tableta |
Media: **8,69** · Aprobado: **sí** (24-oct-2026). Deuda: salida real de posprocesadores de Fusion/Mastercam, desplazamientos G54 conocidos, material con portaherramientas.

## Ronda hacia el 9 (3.ª tanda)
- **Desplazamientos de trabajo:** `G10 L2/L20 Pn` fijan el desplazamiento de G54–G59 y `G92` ya no hace saltar la herramienta (se acumula como desplazamiento). Varias fijaciones quedan en su sitio real. Test `gcode_test.dart`. No verificado con un programa real de varias fijaciones.
