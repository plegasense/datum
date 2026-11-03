# Localización es/en

Dovexa se escribe en español y se traduce al inglés en tiempo de ejecución.

## Mecanismo
- `app/lib/l10n/l10n.dart`: `tr('texto en español {marcador}', {'marcador': valor})`. Con idioma `es` devuelve el texto
  de partida (con los marcadores rellenos); con `en` busca la traducción en `kEn` (unión de `en_*.dart`).
- El idioma sale del dispositivo (`L.initFromPlatform`): es/gl/ca/eu → español; el resto → inglés. Por defecto `es`.
- Números: `.ldec` (coma decimal en español, punto en inglés), `kThousands` (separador de miles), `fmtNum`.
- `python3 tools/l10n_check.py` comprueba claves sin traducir, marcadores distintos y literales con aspecto de español.

## Reglas
1. Todo texto que ve el usuario pasa por `tr`: etiquetas, tooltips, títulos de hojas, avisos, errores, mensajes de
   los lectores de archivos, textos de los resúmenes. El texto español se queda **idéntico** (la versión española no cambia).
2. Interpolación: nunca `tr('${n} piezas')`; sí `tr('{n} piezas', {'n': n})`. Un marcador por valor, mismo nombre en inglés.
3. Plurales: claves distintas (`tr('1 pieza')` / `tr('{n} piezas', …)`); en inglés «1 part» / «{n} parts».
4. `const`: donde entre `tr(...)` hay que quitar `const` del widget que lo contiene.
5. Mapas/listas constantes de textos: déjalas y traduce al usarlas (`tr(kNombres[k])`); el texto debe estar como clave en el mapa inglés.
6. No se traduce: comentarios, nombres de formatos y unidades (STEP, DXF, mm, G-code…), identificadores, claves
   de preferencias, mensajes de depuración (`print`), ganchos de prueba (`DATUM_*`), nombres propios.
7. Cada área escribe sus traducciones en su `lib/l10n/en_<area>.dart`; una entrada por clave, sin claves repetidas dentro del archivo.

## Glosario (usar siempre igual)
pieza→part · ensamblaje→assembly · árbol de piezas→part tree · lista de piezas→parts list · capa→layer (CAD/G-code) ·
malla→mesh · cara→face/triangle (según el contexto) · arista→edge · agujero→hole · voladizo→overhang · espesor de pared→wall thickness ·
normales invertidas→inverted normals · aristas no variedad→non-manifold edges · sección→section · explosionar→explode ·
medir→measure · cotas y tolerancias→dimensions and tolerances (PMI) · trayectoria→toolpath · avance→feed rate ·
rápido (G0)→rapid move · retracción→retraction · extrusión→extrusion · laminador→slicer · cama→bed · relleno→infill ·
herramienta→tool · material restante→remaining stock · pieza en bruto→stock · fresado→milling · nube de puntos→point cloud ·
clasificación→classification · retorno→return · intensidad→intensity · textura→texture · variante→variant · cámara/vista del archivo→file view ·
aviso→warning · "Datos de corte"→Cutting data · "Rendimiento de chapa"→Sheet yield · "Contornos abiertos"→Open contours ·
"Ficha de impresión"→Print summary.

## Comprobación visual
En inglés: emulador Android con el idioma del sistema en inglés (`tools/shot_play.sh`), y en español en la tableta.
