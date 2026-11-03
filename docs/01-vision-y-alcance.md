# 01 · Visión y alcance

## Qué es Datum
El visor CAD/CAM para **iOS y Android** que debería existir: abre casi cualquier archivo de ingeniería y fabricación, lo muestra rápido y bien, y te deja entender un ensamblaje, no solo mirarlo.

**Gratis, sin anuncios, sin cuenta, sin conexión.** Nada sale del móvil.

## Por qué hay hueco (evidencia, octubre 2026)
Datos de Google Play (rangos de descargas y notas; foto de un día, tienda de España y EE. UU.):

| Dato | Lectura |
|---|---|
| Fast STL Viewer: 1M+ descargas, nota 2,5 | Es la referencia y los usuarios se quejan sobre todo de los anuncios; varios dicen que no hay alternativa |
| Autodesk Fusion (Android): 1M+, nota 1,5 | Visor limitado, inicio de sesión roto; piden línea de tiempo, medir y ver el tamaño del material |
| Onshape (Android): 1M+, nota 2,9 | Editar en móvil es incómodo |
| Visores STEP en Android: 10K a 100K, notas de 2,0 a 3,6 | Mercado sin referente de calidad |
| Chapa, calculadoras, costes de impresión: ≤100K | Nichos pequeños: no merecen ser el producto principal |
| iOS: ya hay visores STEP con medición y secciones, pero con versión gratuita limitada (por ejemplo, 2 mediciones) | Un visor completo y gratuito también destaca en iPhone. Estudio de iOS menos profundo que el de Android |

Fuentes y método: ver la conversación original y `docs/06-decisiones.md`. Son rangos, no cifras exactas.

## Principios
1. **Abrir lo que te llegue.** Desde el gestor de archivos, Drive, WhatsApp o el correo, con un toque.
2. **Fluido o no vale.** 60 fps al girar, cualquier modelo razonable.
3. **Entender ensamblajes.** Árbol de piezas, búsqueda por nombre, recuentos, aislar y ocultar, colores del archivo.
4. **Privado por diseño.** Sin permiso de Internet, sin analítica, sin cuenta.
5. **Honesto.** Si un formato no se puede abrir bien, la app lo dice y explica qué hacer, en vez de fallar en silencio.
6. **Moderno y directo.** Interfaz mínima, gestos naturales, modo claro y oscuro, español e inglés desde el principio.

## Usuarios
Makers y aficionados a la impresión 3D, estudiantes de ingeniería, técnicos y operarios de taller, ingenieros que revisan algo fuera de la oficina, compradores y comerciales que reciben archivos.

## Qué incluye cada versión

**v0.1 · Prueba cerrada (MVP)**
- Abrir STL, OBJ, 3MF, STEP (piezas y ensamblajes) e IGES.
- Navegación excelente: orbitar, desplazar, zoom, vistas estándar, centrar en selección.
- Modos de vista: sombreado, sombreado con aristas, alambre, transparencia.
- Árbol de ensamblaje con búsqueda por nombre, recuentos (lista de materiales), aislar y ocultar.
- Medir puntos, distancias y tamaño total; dimensiones de la caja envolvente.
- Asociación de archivos y abrir desde otras apps; recientes.
- Claro y oscuro, español e inglés.

**v1.0 · Producción**
- Secciones (planos de corte) con tapa.
- Vista explosionada y vistas guardadas.
- DXF en 2D con medición; visor de G-code (CAM).
- Capturas y compartir.
- Más formatos de malla y neutros (glTF, PLY, 3DM, FCStd…).

**Después**
- DWG, IFC, PMI (tolerancias y cotas del archivo), comparar versiones, anotaciones.
- Formatos nativos propietarios: ver `02-formatos.md`, es el punto más difícil.

## Fuera de alcance
Editar o modelar, cuentas y nube propias, publicidad, suscripciones, versión de escritorio o web (por ahora). Las dos plataformas objetivo son **iOS y Android**.

## Cómo sabremos si funciona
Objetivo orientativo, a ajustar con datos reales:
- Nota ≥ 4,5 en Play Store y en App Store.
- Instalaciones y usuarios activos semanales (Play Console y App Store Connect los dan sin añadir ningún SDK).
- Tasa de fallos baja (vitales de Play Console, informes de App Store Connect).
- Abrir un STEP de 10 MB en < 5 s en un móvil de gama media.
