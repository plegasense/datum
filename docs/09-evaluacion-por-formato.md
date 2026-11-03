# Evaluación como usuario, formato a formato

Fecha: 24-oct-2026. Cada formato se abrió con un archivo real (de `Piezas CAD` o de fuentes externas) en el iPhone simulado y se juzgó pensando en quien lo usa de verdad. Las capturas están en `docs/eval/`.

## Principio nuevo

Cada formato debe parecer una app hecha solo para él. Eso significa que cambian cuatro cosas, no solo el dibujo:

1. **Qué datos salen arriba** (las "chips"): los que importan a ese usuario, no un recuento genérico.
2. **Qué herramientas hay** (la barra lateral): distintas por formato.
3. **Qué panel se abre**: árbol y lista de materiales en CAD; capas y corte en 2D; leyenda y estadísticas en impresión.
4. **Qué se calcula**: volumen y estanqueidad en STL, longitud de corte en DXF, filamento en G-code.

Hoy casi todo se parece: una vista, una barra con "centrar, vistas, rejilla" y poca información. Está correcto para abrir un archivo, pero no es especializado.

## Fallos que afectan a todos los formatos

| Problema | Dónde se ve | Juicio |
|---|---|---|
| **Sin unidades.** "3845 × 2292 × 2339" no dice si son mm, m o pulgadas. | STEP, DXF, STL | Grave. Un técnico no puede fiarse de una cota sin unidad. STEP y DXF la traen en el archivo; solo hay que leerla y mostrarla. |
| **Las piezas oscuras casi no se ven.** | `PaloMar.stp` (gris casi negro sobre fondo casi negro) | Grave. Hay que aclarar los colores muy oscuros, como ya se hace en DXF. |
| **No hay aristas.** Todo es superficie sombreada. | Todo el 3D | Es lo que más hace parecer "visor de mallas" y no "visor CAD". Un CAD dibuja las aristas vivas y las siluetas. |
| **El encuadre se pierde bajo la barra lateral.** | DXF 2500×1250: el borde derecho queda tapado | El "ajustar" debe reservar el hueco de los controles. |
| **Datos de relleno.** "Triángulos", "instancias", "movimientos", "rápidos". | Cabecera | Sobran en la mayoría. Un ingeniero CAD no piensa en triángulos; un impresor no piensa en "movimientos". |
| **Medir solo existe en 2D.** | 3D | Medir es lo primero que hace quien abre una pieza. |

## Por formato

### STEP / IGES (CAD, piezas y conjuntos) — 5/10

**Quién:** ingeniero o fabricante que recibe un modelo para revisarlo, presupuestarlo o fabricarlo.

**Lo que ve ahora:** vista 3D sombreada; para conjuntos, árbol con búsqueda y lista de piezas; 4 vistas estándar; rejilla. Las piezas sueltas ya no enseñan árbol.

**Lo que echaría en falta:**
- **Aristas y siluetas.** Imprescindible.
- **Medir en 3D:** distancia entre puntos, **diámetro de un agujero** (tocar la cara cilíndrica), distancia entre caras, ángulo. Con el B-rep esto se puede hacer exacto, no sobre triángulos.
- **Propiedades:** volumen, área, masa con una densidad elegible, centro de masas, nº de sólidos y caras.
- **Al tocar una pieza:** nombre, tamaño, volumen, material y color; para una cara, su tipo (plana, cilíndrica Ø…).
- **Sección** con un plano móvil, **transparencia** y **explosionar** un conjunto.
- **Lista de materiales** con cantidades y exportación a CSV. Existe la lista, no la exportación.
- **Metadatos del archivo:** programa que lo creó, protocolo (AP203/214/242), unidades.
- **Conjuntos grandes:** una pieza lejana encoge todo (el caso de la paletizadora); hace falta encuadrar la selección y ocultar/aislar fácil.

**Sobra:** el recuento de triángulos.

### STL (mallas de impresión) — 4/10

**Quién:** quien imprime en 3D y quiere saber "¿se va a imprimir bien y cabe?".

**Ahora:** se ve la pieza y sus medidas. Nada más.

**Echaría en falta:**
- **Comprobación de malla:** ¿es estanca (watertight)? ¿normales invertidas, aristas abiertas, varias cáscaras? Es lo que más preocupa con un STL descargado.
- **Volumen y peso estimado** con un material (PLA, PETG…).
- **¿Cabe en mi impresora?** Elegir plataforma (220×220, 256×256, 350…) y ver si entra.
- **Voladizos:** colorear las zonas con ángulo superior al límite.
- **Orientar/apoyar** la pieza sobre su cara plana más grande.
- **Alambre** (aquí sí tiene sentido ver los triángulos) y **sección**.

### 3MF (proyecto de impresión) — 3/10

**Quién:** quien recibe un proyecto de Bambu/Prusa/Orca ya preparado.

**Ahora:** se trata como una malla cualquiera, en gris. Lo más valioso del formato se descarta.

**Echaría en falta:**
- **Colores y materiales** por objeto (el muñeco multicolor es gris).
- **Placas** (varias camas), objetos con su nombre, y qué filamento lleva cada uno.
- **Metadatos:** programa y versión, impresora, miniatura incrustada.
- Si lleva G-code incrustado, entrar a la vista de impresión (ya se hace en parte).

### OBJ, PLY, glTF/GLB, VRML (mallas artísticas y de escaneo) — 3/10

**Quién:** diseñador, escaneador 3D, gente de visualización.

**Ahora:** geometría y color de material/vértice. **No hay texturas** (ni en OBJ ni en glTF), que es lo que define estos formatos. No hay luces, materiales PBR ni animaciones.

**Juicio honesto:** sin texturas, un OBJ o GLB escaneado se ve peor que en cualquier visor gratuito. Hay que elegir: o se hace bien (texturas, materiales, lista de materiales, vértices de color) o se declaran "solo geometría". **VRML** es un formato muerto: yo lo bajaría de prioridad y dejaría de anunciarlo.

### DXF (planos 2D, corte) — 6/10

**Quién:** operario de láser, plasma, chorro de agua o punzonadora; o quien recibe un plano de AutoCAD.

**Ahora:** dibujo por capas con colores, panel de capas, medición que ahora reconoce líneas, círculos, arcos y contornos.

**Echaría en falta:**
- **Unidades** (el DXF las trae) y **escala real**.
- **Datos de corte, que es lo que paga el taller:** nº de contornos cerrados, de agujeros, **longitud total de corte**, nº de perforaciones, área neta. Por capa, y filtrable por color.
- **Lista de capas con su recuento y longitud**, no solo "visible/oculta".
- **Relleno** de los contornos cerrados (distingue pieza y hueco) y modo "solo contornos".
- **Cotas y rayados:** hoy no se dibujan las DIMENSION ni los HATCH; un plano acotado pierde información.
- **Coordenadas bajo el dedo** y rejilla con escala.
- Para un nesting (varias piezas en una chapa): **número de piezas distintas**, aprovechamiento de la chapa.

### SVG / HPGL (vector y plóter) — 3/10

Se dibujan **solo contornos**, sin relleno: un SVG con colores se ve como un esqueleto. Para el usuario de láser o diseño, falta relleno, unidades reales (mm según viewBox) y colores por trazo como "capas". HPGL: plumas con colores y tamaño real. Son formatos de nicho; no merecen más que un visor fiel.

### G-code de impresora FDM — 6/10

**Quién:** quien revisa una impresión antes de lanzarla.

**Ahora (lo mejor de la app):** deslizador de capas, colores por tipo / filamento / altura / velocidad, tiempo estimado, filtros por característica, trayectos en vacío.

**Echaría en falta:**
- **Leyenda de colores** (qué filamento es cada color, qué velocidad es cada tono). Hoy el color no se explica.
- **Filamento usado** (m y g), temperaturas, altura de capa, boquilla, programa que lo generó. Casi todo está en los comentarios del archivo.
- **Animación** del recorrido y un **deslizador doble** (ver capas de la n a la m).
- **Ver el volumen de lo extruido** en vez de líneas: hoy parece plano.
- **Pila de piezas:** poder ver una sola pieza de una placa con varias.

**Sobra:** "1.54 M movimientos" y "rápidos": son datos de CNC que no dicen nada al impresor.

### G-code CNC (fresado, torno, láser) — 3/10

Es **otro usuario**: el maquinista. Con la misma pantalla de impresión no le sirve.

**Necesita:** recorridos de corte frente a rápidos (colores distintos), **límites de la máquina (X/Y/Z mín-máx)**, herramientas usadas con diámetro y su tiempo, avances y velocidades, **tocar un tramo y ver su línea de código** (y al revés), unidades (G20/G21), orígenes de trabajo, profundidad por colores. Debe ser un modo propio con su propia barra.

### .bgcode (Prusa) — 5/10

Valida igual que el G-code, y el formato trae los **metadatos ya estructurados** (impresora, filamento usado, tiempo estimado): hay que enseñarlos en una ficha.

### Nubes de puntos — 4/10

**Quién:** topógrafo o escaneador.

**Ahora:** colorear por altura, 600 000 puntos fluidos.

**Echaría en falta:** tamaño de punto ajustable, modos de color (RGB, intensidad, clasificación), **medir**, caja de recorte, iluminación de borde para dar relieve. Y un dato clave: los formatos reales de campo son **LAS/LAZ y E57**, que no abrimos; XYZ, PTS y PCD son los de menor uso.

## Propuesta de prioridad

No se puede ser el mejor en 14 formatos. Propongo **tres niveles**:

| Nivel | Formatos | Meta |
|---|---|---|
| **A. Especialización total** (donde quiero ser el mejor) | STEP/IGES, G-code (FDM y CNC como dos modos), DXF | Aristas, medir exacto, propiedades, unidades, datos de corte, leyenda, ficha |
| **B. Buen visor con lo esencial del formato** | STL, 3MF, .bgcode | Comprobación de malla, volumen, ¿cabe?, colores y placas, ficha de metadatos |
| **C. Abrir y ver con fidelidad, sin más** | OBJ, PLY, glTF, SVG, HPGL, nubes, VRML | Texturas en OBJ/glTF; el resto, tal cual. VRML y HPGL sin anunciar |

## Orden de trabajo sugerido

1. **Arreglos transversales** (días): unidades, contraste de piezas oscuras, encuadre bajo la barra, quitar datos de relleno.
2. **CAD:** aristas, medición exacta (diámetro, distancia), propiedades físicas, información al tocar.
3. **DXF:** unidades, longitud de corte y contornos, relleno, cotas.
4. **G-code:** leyenda, ficha de impresión y de filamento; luego el modo CNC con código sincronizado.
5. **STL/3MF:** comprobación de malla, ¿cabe?, colores y placas.
6. Texturas en OBJ/glTF.
