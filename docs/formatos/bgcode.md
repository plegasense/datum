# bgcode (Prusa) — dossier

Estado: cubierto con G-code FDM (mismo visor y ficha) · 24-oct-2026

- Los metadatos del bloque (`filament used [g]`, `estimated printing time`, `temperature`, `layer_height`…) alimentan la misma ficha (`PrintSummary`), con prioridad sobre lo medido.
- Validado: `mini_cube_ps2.8.1.bgcode` ≡ `.gcode` (mismos totales y 1.107 movimientos); `mini_cube_b.bgcode` frente a `mini_cube_b_ref.gcode` de libbgcode.
- Pendiente: bgcode con MeatPack real de MK4/XL de usuario, y miniatura del archivo (bloque 5) en la ficha.
- Puerta: se evalúa junto a G-code FDM (provisional 8,06; no aprobado).

Actualización: la miniatura del bloque 5 (PNG/JPG/QOI) se muestra en la ficha; archivos dañados dan «.bgcode dañado» en lugar de un error técnico. Puntuación: la de G-code FDM (8,5, aprobado).
