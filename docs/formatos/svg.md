# SVG — dossier de especialización

Estado: fase 8 / 8 · puerta superada (8,63) · Última actualización: 25-oct-2026

## 1. Usuarios
| Perfil | Situación | Tarea principal | Qué decide al verlo | Fuente |
|---|---|---|---|---|
| Corte láser / CNC / vinilo | Recibe un SVG de un generador de cajas, de Inkscape o de un cliente | Saber si mide lo que dice y si se puede cortar | Si las unidades cuadran y si hay contornos abiertos | Foros de LightBurn (escala 96/72 ppp), documentación de Inkscape |
| Plóter de pluma (AxiDraw, vpype) | SVG por capas de color | Ver capas y que nada falte | Qué pluma dibuja qué | Documentación de vpype |
| Diseño gráfico | SVG de Illustrator o Figma | Ver que abre y qué no se dibuja | Si hay texto sin convertir, imágenes o recortes | Reseñas de visores SVG |

## 2. Especificación
SVG 1.1/2 (W3C). Mapa: `width/height/viewBox/preserveAspectRatio` (unidades: px, mm, cm, in, pt, pc, Q, %, em), formas y `path` (M L H V C S Q T A Z, banderas de arco pegadas), `g`, `use`/`symbol`/`defs`, estilo por atributo, `style` y hojas CSS (`<style>`), capas de Inkscape (`inkscape:groupmode`), `text`, `image`, `clip-path`, degradados. Rarezas: Illustrator declara entidades en el DOCTYPE; sin `width` con unidades el tamaño real es una suposición (96 ppp en navegadores e Inkscape, 72 ppp en Illustrator antiguo).

## 3. Estado del arte
| Función | Visores SVG genéricos | Inkscape | Dovexa |
|---|---|---|---|
| Dibujar | Sí | Sí | Sí (líneas) |
| Decir si el tamaño es real o supuesto | No | Parcial | Sí, con cambio 96/72 ppp |
| Capas por Inkscape o por color | No | Sí | Sí |
| Contornos, agujeros, abiertos, longitud de corte | No | No | Sí |
| Avisar de texto sin convertir, imágenes, recortes | No | No | Sí |
| Móvil, sin conexión, sin anuncios | Con anuncios | No | Sí |
Carencias reales: la escala 96/72 ppp es el error más repetido al cortar; los visores no avisan del texto sin convertir.

## 4. Hueco y ventaja
1. Tamaño real: mm cuando el archivo lo declara y «px a 96 ppp» con selector 96/72 cuando no (cambia las medidas al instante).
2. Datos de corte (piezas, agujeros, abiertos, longitud, rendimiento) a partir del SVG, que ningún visor genérico da.
3. «Qué no se puede dar por bueno»: texto, imágenes, recortes, degradados, discontinuos y trazados erróneos, dichos en la hoja.
4. Geometría contrastada: 180 de 183 cajas coinciden con las de un navegador; las 3 restantes son límites conocidos del navegador (ver §7).

## 5. Diseño específico
- Datos arriba: tamaño, piezas/agujeros, avisos, generador (Inkscape 1.2…), notas.
- Barra: capas, ajustar, girar, datos de corte, hoja «Sobre el archivo», revisión, relleno, medir.
- Capas: las de Inkscape; sin ellas, una por color de trazo («#FF0000») y «sin contorno» para rellenos.
- Textos: «Sin tamaño físico», «sin convertir a trazados», «Trazado ▸ Objeto a trazado».

## 6. Implementación
`io/svg_loader.dart` (lector nuevo: escáner de rutas propio, CSS, `use`, anidados, `preserveAspectRatio`, entidades del DOCTYPE, límite de elementos), `model/vector_info.dart`, `ui/vector_tools.dart`, `LengthUnit.px96/pt72`, código de unidad 100 en `DrawingController`.

## 7. Validación
| Origen | Archivos | Resultado |
|---|---|---|
| boxes.py (láser) | 181 | 181 abren, ≤30 ms |
| vpype (tests) | 56 | 54 abren; 2 vacíos con mensaje |
| resvg (suite de pruebas) | 320 | 320 abren |
| Comparación con un navegador (getBBox) | 183 con geometría | 180 coinciden; 3 distintas: arcos (el navegador da cajas no ajustadas, comprobado con un cálculo independiente) y `use` encadenado (el navegador duplica el desplazamiento) |
| Fuzz | 5 semillas × 4 095 casos | 0 fallos inesperados (se corrigió un desbordamiento de pila) |
| Dispositivos | iPhone (simulador) y tableta Android | carga 174 ms; hoja de datos y notas visibles |
Pruebas: `test/vector_formats_test.dart`.

## 8. Puerta de calidad
| Fila | Nota | Evidencia |
|---|---|---|
| Fidelidad | 8,5 | 180/183 contra navegador; texto como rótulo, sin recortes ni degradados reales |
| Información propia | 9 | tamaño declarado o supuesto, generador, capas, avisos |
| Herramientas específicas | 8,5 | corte, 96/72 ppp, hoja de archivo |
| Rendimiento | 9 | ≤35 ms de lectura; 174 ms en tableta |
| Robustez | 8,5 | fuzz limpio |
| Claridad | 8,5 | capturas iPhone y tableta |
| Frente al mejor | 8,5 | ningún visor móvil da datos de corte ni avisos |
| Detalle y acabado | 8,5 | textos propios; hoja comprobada en teléfono |
Media: 8,63 · Aprobado: sí · Fecha: 25-oct-2026
Deuda: recortes, máscaras y degradados no se aplican; `text` no se convierte en trazos; sin referencias a archivos externos.

### Ronda hacia el 9 (25-oct-2026)
- **Degradados:** se pinta con el color de su primera parada (siguiendo `href` entre degradados), en lugar de un gris fijo.
- **Recortes rectangulares (`clipPath` con un `rect`):** los trazos se recortan de verdad (Cyrus–Beck), también con giros; los recortes con otras formas siguen avisándose.
- 3 pruebas nuevas; sin cambios en las 181+54+320 muestras ni en la comparación con el navegador (180/183). Fila que cambia: Fidelidad 8,7. Media: **8,65**.
