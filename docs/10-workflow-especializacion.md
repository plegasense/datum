# Workflow de especialización por formato

Decisión (24-oct-2026): **todos los formatos son de nivel A.** Ninguno se da por terminado hasta que Datum sea, para ese formato, tan bueno como el mejor visor que existe o mejor, juzgado como lo juzgaría quien lo usa a diario. No hay límite de tiempo; sí hay una puerta de calidad.

Se ejecuta formato a formato, con la skill `/especializar-formato <formato>` (`.claude/skills/especializar-formato`). El estado de todos está en `docs/formatos/ESTADO.md`. Cada formato tiene su dossier en `docs/formatos/<formato>.md`, creado desde `docs/formatos/_plantilla.md`.

## Las 8 fases (no se salta ninguna)

| Fase | Qué se hace | Qué queda escrito en el dossier |
|---|---|---|
| **1. Usuarios** | Quién abre este formato, en qué situación, con qué prisa, en qué dispositivo y qué decide al verlo. Buscar en foros, reseñas de apps y documentación de oficio (no en suposiciones). | 3–5 perfiles y sus tareas reales, con citas o fuentes. |
| **2. La especificación** | Qué guarda el formato de verdad (versiones, extensiones, casos raros, qué suelen escribir mal los programas). Leer la especificación oficial. | Mapa de datos del archivo: qué hay y cuánto de eso mostramos. |
| **3. Estado del arte** | Instalar o probar los 3–5 mejores visores de ese formato (móvil y escritorio, gratis y de pago). Capturas y lista de qué hacen. Leer sus reseñas negativas: ahí están las carencias. | Tabla comparativa: función por función, quién la tiene. |
| **4. Hueco y ventaja** | Qué falta a todos, qué hacen mal, qué haría un especialista y nadie hace. Elegir al menos 3 cosas concretas en las que Datum será claramente mejor. | Lista "superamos al mejor en…" con criterios medibles. |
| **5. Diseño específico** | Cómo se ve y se maneja: qué datos van arriba, qué herramientas hay, qué panel se abre, qué se calcula. **Distinto al resto de formatos.** Comprobar contra el lenguaje del usuario (nada de jerga ajena). | Boceto o captura objetivo, lista de herramientas, textos exactos. |
| **6. Implementación** | Construirlo. Rendimiento medido en el móvil, no solo en el simulador. | Cambios y decisiones técnicas. |
| **7. Validación** | Archivos reales de al menos 5 fuentes distintas (programas, versiones, tamaños), incluidos los rotos o raros. Escenarios de usuario: cada tarea de la fase 1 se hace de principio a fin con capturas. | Registro de archivos y de tareas hechas. |
| **8. Puerta de calidad** | Puntuar con la rúbrica. Si no pasa, se vuelve a la fase que corresponda. | Notas, evidencia y fecha. |

## Rúbrica (0–10, todas las filas)

1. **Fidelidad:** lo que se ve es lo que hay en el archivo (geometría, color, escala, unidades).
2. **Información propia del formato:** muestra lo que ese usuario necesita saber, y solo eso.
3. **Herramientas específicas:** tiene lo que haría un especialista de ese formato.
4. **Rendimiento:** abre y se mueve con fluidez en un móvil medio, con archivos grandes.
5. **Robustez:** no falla con archivos de otros programas, versiones o tamaños; si no puede, lo explica bien.
6. **Claridad:** se entiende sin explicación, con el vocabulario del oficio.
7. **Frente al mejor:** supera al mejor competidor encontrado en la fase 3.
8. **Detalle y acabado:** estados vacíos, errores, textos, estética coherente.

**Se pasa si:** ninguna fila baja de 8, la media es ≥ 8.5, se superan al mejor competidor en al menos 3 cosas concretas y hay evidencia (capturas + archivos reales) en el dossier. La evaluación la hago yo con criterio de usuario, en voz crítica, y la enseño; la puerta no se aprueba sola si hay una nota flojada.

## Reglas

- **Investigar antes de construir.** No se escribe código de un formato sin las fases 1–4 hechas.
- **Los datos se citan.** Cada afirmación del dossier lleva fuente o "sin verificar".
- **No se copia código ni activos de otros programas;** se aprende de lo que hacen (funciones, flujos), respetando licencias.
- **Lo que se muestra debe ser verdad.** Si una cifra se estima (peso, tiempo), se dice cómo.
- **Nada de adornos de IA:** ni milisegundos, ni jerga, ni datos que el usuario no usa.
- **Cada formato, su propia cara.** Las herramientas no se comparten por comodidad; se comparten solo si el oficio las comparte (p. ej. medir).
- **Un cambio visual se comprueba en pantalla** (simulador, captura) y se guarda en `docs/formatos/<formato>/`.

## Orden de trabajo

Por impacto y dependencias técnicas. Cada uno cierra su puerta antes de pasar al siguiente, salvo trabajo común (unidades, aristas, medición) que se hace una vez y sirve a varios.

1. STEP / IGES / STPZ (CAD) — base: aristas, medición exacta, propiedades.
2. DXF — unidades, datos de corte, relleno, cotas.
3. G-code FDM + .bgcode — leyenda, ficha, animación.
4. G-code CNC — modo propio.
5. STL — comprobación de malla, ¿cabe?
6. 3MF — colores, placas, metadatos.
7. glTF/GLB, OBJ, PLY — texturas y materiales.
8. SVG, HPGL.
9. Nubes de puntos (XYZ/PTS/PCD, y LAS/LAZ/E57 si resulta ser lo que se usa).
10. VRML.

Los formatos propietarios (.sldprt, .ipt, .prt, .dwg) siguen en "detectar y explicar" (D-04c); su dossier es lo mejor que se puede hacer legal y técnicamente, incluida la guía de cómo exportarlos.
