# G-code FDM (incluye .bgcode y .gcode.3mf) — dossier de especialización

Estado: fases 1–7 hechas; puerta provisional · Última actualización: 24-oct-2026

[F] = leído en fuente citada; [I] = inferencia mía.

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Operario de granja / makerspace | Recibe el G-code ya laminado (USB, red) | Comprobar que es el trabajo correcto: tiempo, material, tamaño, filamentos | Lanzar la impresión o no | [F] Firmware y servidores de impresión (Duet, OctoPrint) leen del archivo tiempo, filamento y altura de capa para mostrarlos al operario |
| Maker con laminador en el PC | Quiere revisar fuera del PC | Ver capas, soportes, primera capa, cambios de color | Corregir el laminado | [F] El visor de PrusaSlicer ofrece leyenda por tipo con tiempo y deslizador de capas; SimplyPrint, modos de color por tipo, extrusor, velocidad y ventilador |
| Usuario multicolor (Bambu/Prusa MMU) | Placa con 4 filamentos y torre de purga | Ver cuánto filamento gasta cada color y cuánto se pierde en la torre | Reordenar o cambiar colores | [I] consecuencia del cabecero de Bambu, que lista longitud y peso por filamento |

## 2. Especificación
- No existe estándar: es un dialecto de RS-274 con comentarios propios de cada laminador [F].
- Datos que el laminador declara (distinto sitio según programa) [F]: PrusaSlicer, estadísticas al final (`; filament used [mm]`, `; estimated printing time (normal mode)`); Cura, al principio (`;TIME`, `;Filament used`, `;Layer height`); Simplify3D, bloque «Build Summary» al final; Bambu Studio, `HEADER_BLOCK` con tiempo, longitud/peso por filamento y nº de capas. Hay que leer ambos extremos.
- Comprobado en archivos reales: Bambu escribe «model printing time: …; total estimated time: …» en una sola línea (dos claves).
- `.bgcode` (Prusa): bloques con metadatos INI, miniatura y G-code comprimido (heatshrink/MeatPack) [F, ya implementado].
- Tipos de movimiento por comentario: `;TYPE:` (Prusa/Cura/Orca), `; FEATURE:` (Bambu).

## 3. Estado del arte
| Función | Visor PrusaSlicer | OrcaSlicer/Bambu Studio | SimplyPrint (web) | **Dovexa ahora** |
|---|---|---|---|---|
| Funciona sin PC, sin cuenta | no | no | no (nube) | **sí** |
| Leyenda por tipo con % de tiempo | sí | sí | por tipo | sí (solo cuando el tiempo teórico se parece al del laminador) |
| Rango de capas | sí | sí | selector de capa | sí (rango + «solo esta capa») |
| Reproducción | sí | sí | — | sí |
| Tiempo transcurrido hasta la capa | sí | sí | — | sí (proporcional al total declarado) |
| Peso/longitud por filamento | sí | sí | sí | sí |
| Temperaturas, boquilla, relleno, soportes | parcial | en laminador | detectados | sí |
| Anchura/flujo real de extrusión | sí | sí | — | **no** |
| Gráfico de tiempo por capa | sí | sí | — | no |

## 4. Hueco y ventaja
Superaremos al mejor en (medible):
1. Abrir un `.gcode`, `.bgcode` o `.gcode.3mf` en el móvil, sin conexión ni cuenta: ninguno de los anteriores lo hace (PrusaSlicer/Orca exigen escritorio; SimplyPrint, nube).
2. Una sola ficha con tiempo, gramos por filamento, temperaturas, altura de capa, relleno, soportes y tamaño, leída de Prusa, Bambu y Cura y completada con lo medido si falta.
3. Carga de una placa de 1,5 M de movimientos y 33 MB en 0,5 s (escritorio) y rango/reproducción fluidos.

## 5. Diseño específico
- Arriba: capas, tiempo total, gramos totales (sin «movimientos/rápidos»).
- Tarjeta inferior: capa actual, Z, tiempo transcurrido; rango de capas con reproducción; leyenda del color en uso (tocar un tipo lo oculta); modos Tipo / Filamento (si hay varios) / Velocidad / Altura / Liso.
- Panel lateral «Ficha de impresión»: resumen, materiales (color, tipo, gramos, temperaturas), laminado, qué mostrar con %, datos crudos del archivo plegados.

## 6. Implementación
`parseGcode` recoge metadatos de cualquier comentario `clave = valor`/`clave: valor`, tiempo teórico por capa y por tipo, filamento por herramienta, retracciones, temperaturas y ventilador (M104/M109/M140/M190/M106). `PrintSummary` combina lo declarado y lo medido. UI en `app/lib/ui/gcode_ui.dart`; modelo en `app/lib/model/print_summary.dart`.
Decisión: el tiempo declarado manda; el teórico (sin aceleraciones) solo reparte. Si difiere más de 25–40 % (Bambu: ×3,3) se ocultan los porcentajes por tipo.

## 7. Validación (segunda ronda, con archivos de terceros)
| Archivo | Origen | Resultado |
|---|---|---|
| plate_1.gcode (33 MB, 1,54 M mov.) | BambuStudio 2.7.1, A1 mini, 4 filamentos | 880 capas (= cabecera), 18h 27m, 145/38/56/9 g ✔; carga 0,5 s (Mac) |
| mini_cube_ps2.8.1 `.gcode` y `.bgcode`, mini_cube_b | PrusaSlicer 2.8.1 / libbgcode | idénticos entre sí; 31 capas (= max_layer_z/0,2); miniatura QOI mostrada |
| orca_3dbenchy, orca_autodesk_test | OrcaSlicer 2.5.0-dev (H2D) | 240 y 460 capas = Z/0,2; 46m 49s y 11,2 g = cabecera |
| prusaslicer_3dbenchy, vase, test_rc | PrusaSlicer 2.9.2 / 2.7.4 / 2.2.0-rc4 | 240, 334 y 50 capas ✔ (la rc4 no tiene marcadores: capas por altura) |
| bambustudio_cube | BambuStudio 2.5 | 50 capas ✔ |
| simplify3d_mont_box (7 MB) | Simplify3D 4.1.1, 2 extrusores | 171 capas (= 51,3/0,3); «Build Summary»: 7h 17m, 252 g repartidos 14/238 g según lo medido; tipos de movimiento («; feature …») |
| cura_steamengine_griffin_um3_dual | Cura 2.3.1 Ultimaker 3 | 36 capas, 18m 04s y 2 filamentos del encabezado; el tiempo teórico no concuerda (10×): se oculta el % por tipo |
| slic3r129_heartkeychain, kisslicer_100_1 | Slic3r 1.2.9, KISSlicer | capas por altura (158 y 41) |
| cura_ender3_CE3_Laser_* (4) | Cura, láser Marlin | una sola capa (grabado), sin errores |
Robustez: 258 archivos truncados/corrompidos, 0 fallos inesperados; `.bgcode` dañado → mensaje claro.
Rendimiento (emulador Android, perfil, 1,54 M movimientos): 21,6 ms por fotograma al girar (antes 39 ms); dispositivo físico sin medir.
Tests automáticos: `app/test/gcode_test.dart` (8).
Capturas: `gcode-fdm/*.png` (iPhone y Android).

## 8. Puerta de calidad (segunda evaluación)
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,5 | capas y totales coinciden con la cabecera en 6 laminadores; falla el tiempo teórico en el ejemplo de Cura |
| Información propia | 9 | ficha, miniatura, tiempo por capa, paradas M600, flujo, filamentos |
| Herramientas específicas | 8,5 | rango + reproducción, leyenda filtrable, color por tipo/filamento/velocidad/flujo/altura, gráfico tocable |
| Rendimiento | 8 | 21,6 ms en emulador; falta dispositivo físico |
| Robustez | 8,5 | 258 corrupciones sin fallos |
| Claridad | 8,5 | capturas |
| Frente al mejor | 8 | gana: sin PC ni cuenta; ficha de 7 laminadores; paradas y gráfico por capa. Pierde: sin anchura real de extrusión ni marcadores de purga |
| Detalle y acabado | 8,5 | miniatura incrustada, leyenda con %, textos del oficio |
Media: **8,44** · Aprobado: **no** (faltan 0,06). Para aprobar: medir en dispositivo físico (Rendimiento ≥ 8,5) o dibujar extrusión con anchura real.

## Prueba en tableta física (24-oct-2026)
Xiaomi 25040RP0AE (Helio G99, Mali-G57, 2560×1600), compilación de perfil. Placa Bambu de 1,54 M de movimientos, girando:
| Versión | Por fotograma |
|---|---|
| Inicial | **180 ms** (5 fps; el emulador daba 39 ms y ocultaba el problema) |
| Sin desenfoque de las tarjetas (`BackdropFilter`: ~35 ms) | 119 ms |
| + render a 0,6 de resolución al girar | 114 ms |
| + versión aligerada de 200 mil segmentos al girar o reproducir (cupo por tipo de movimiento) | **21,8 ms** (46 fps) |
Un modelo diminuto pasó de 84 ms a 21 ms solo con quitar el desenfoque y bajar la resolución al girar. La vista en reposo conserva toda la calidad.
Puntuación revisada con el dato real (Rendimiento 8 → 8,5): Fidelidad 8,5 · Información 9 · Herramientas 8,5 · Rendimiento 8,5 · Robustez 8,5 · Claridad 8,5 · Frente al mejor 8 · Detalle 8,5 → media **8,5**, ninguna fila < 8, tres ventajas concretas sobre el mejor visor (sin PC ni cuenta; ficha de 7 laminadores; paradas M600 y gráfico por capa tocable). **Puerta superada** (24-oct-2026). Queda como deuda: anchura real de extrusión.

### Ronda hacia el 9 (25-oct-2026)
- **Anchura real de extrusión estimada** por tipo de movimiento (caudal ÷ velocidad ÷ altura de capa, con el perfil redondeado de los laminadores). Contraste con lo que declara el propio archivo: PrusaSlicer (benchy) pared exterior 0,450 frente a 0,45 declarado y relleno 0,454 frente a 0,45; PrusaSlicer (jarrón) 0,419 frente a 0,42; Orca (benchy) 0,413 / 0,442 / 0,418 frente a 0,42 / 0,45 / 0,42.
- Aparece en la ficha de impresión, con la diferencia respecto a la boquilla. Media: **8,53**.
