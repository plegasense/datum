# Ficha de Play: Dovexa

Identificador: `app.datum.datum` · AAB: `releases/android/Dovexa-<versión>-<build>.aab` (solo arm64-v8a; ver `docs/13-publicacion.md`) · Firma: clave de subida en `~/Library/Application Support/Dovexa/signing/` (ver `app/android/RELEASE_SIGNING.md`).
Huellas de la clave de subida — SHA-1 `6E:0C:12:BD:10:9F:E0:6A:42:3B:64:3E:FE:02:1B:F5:6E:6B:F6:A9` · SHA-256 `3F:67:C5:62:42:30:F5:F9:29:18:BD:65:A2:1B:BE:5F:4A:D9:F8:37:48:FC:D9:9F:03:A9:2E:DB:76:F6:DE:A4`.

## Textos
Los textos publicados (título, descripción breve y larga) de los 21 idiomas están en `ficha/<idioma>.json`: esa es la fuente real y se corrige a mano. `ficha_es.py` y `ficha_en.py` son el original en español e inglés y validan longitudes; `ficha/es.txt` y `ficha/en.txt` son su copia en texto plano (sin la línea de unidades). `textos/<idioma>.json` lleva además los rótulos de las capturas, del gráfico de cabecera y de la pantalla «gratis». Idioma principal de la ficha: español (España).

- **Título** (28/30): Dovexa: visor CAD, STEP y 3D. No lleva «gratis» (Play no admite palabras promocionales en el título); lo dice la descripción breve y el gráfico.
- **Categoría**: Productividad (alternativa: Herramientas) · **Etiquetas**: CAD, visor 3D, impresión 3D, CNC.
- **Contacto público**: plegasense@gmail.com · **Política**: ver abajo.

## Gráficos (carpeta `play/`)
- Icono 512×512: `play/graficos/icono-512.png` (el cuadrado completo, sin esquinas transparentes).
- Gráfico de cabecera 1024×500: `play/<idioma>/feature-graphic-1024x500.png` (se genera con `feature.py`).
- Teléfono 1080×1920 (8, en orden): `play/<idioma>/phone/01…08`. Capturas reales de la app con archivos públicos de muestra (`shots/<idioma>/`, hechas con `tools/shots_langs.sh`), más titular. Se regeneran con `python3 build_assets.py <idioma>` (el español se compuso a mano con `compose.py`).
- Tableta: `play/es/tablet/` (a partir de `shots/tab_*.png`).
- Créditos de los modelos de las capturas: Cesium Milk Truck (Cesium, CC BY 4.0), 3DBenchy (CreativeTools, CC0 1.0, 3DBenchy.com), PrusaSlicer/g-code de muestra, mmount.ngc (LinuxCNC), Autzen (Hobu/USGS), as1-oc-214 (Open CASCADE).

## Respuestas de Play Console
- Acceso a la app: sin restricciones, no hace falta cuenta. Anuncios: no. Compras: no.
- Público objetivo: 13 años o más. No es app de noticias ni de salud ni financiera.
- Clasificación (IARC): sin violencia, sexo, drogas, juego ni contenido generado por usuarios → apta para todos.
- Seguridad de los datos: no recoge ni comparte datos; sin cifrado en tránsito aplicable (no hay tránsito); se puede borrar desinstalando.
- Permisos: ninguno (el manifiesto no declara INTERNET; verificado en el AAB).
- IA: la app no incluye contenido generado con IA.

## Política de privacidad
Texto en `politica_privacidad.md`. URL pública: https://github.com/plegasense/dovexa/blob/main/store/politica_privacidad.md.

## Canales
Historial de versiones y pistas en `docs/13-publicacion.md`.
