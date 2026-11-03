#!/usr/bin/env python3
"""Genera DXF de prueba con medidas conocidas en testdata/dxf/ (para validar el análisis de corte)."""
import math, os, sys

def dxf(entities, insunits=None, layers=("CORTE",)):
    o = []
    o += ["0", "SECTION", "2", "HEADER"]
    o += ["9", "$ACADVER", "1", "AC1015"]
    if insunits is not None:
        o += ["9", "$INSUNITS", "70", str(insunits)]
    o += ["0", "ENDSEC", "0", "SECTION", "2", "TABLES", "0", "TABLE", "2", "LAYER"]
    for i, name in enumerate(layers):
        o += ["0", "LAYER", "2", name, "70", "0", "62", str(i + 1), "6", "CONTINUOUS"]
    o += ["0", "ENDTAB", "0", "ENDSEC", "0", "SECTION", "2", "ENTITIES"]
    o += entities
    o += ["0", "ENDSEC", "0", "EOF"]
    return "\n".join(o) + "\n"

def line(layer, x0, y0, x1, y1):
    return ["0", "LINE", "8", layer, "10", f"{x0}", "20", f"{y0}", "30", "0", "11", f"{x1}", "21", f"{y1}", "31", "0"]

def circle(layer, cx, cy, r):
    return ["0", "CIRCLE", "8", layer, "10", f"{cx}", "20", f"{cy}", "30", "0", "40", f"{r}"]

def arc(layer, cx, cy, r, a0, a1):
    return ["0", "ARC", "8", layer, "10", f"{cx}", "20", f"{cy}", "30", "0", "40", f"{r}", "50", f"{a0}", "51", f"{a1}"]

def lwpoly(layer, pts, closed=True):
    e = ["0", "LWPOLYLINE", "8", layer, "90", str(len(pts)), "70", "1" if closed else "0"]
    for x, y in pts:
        e += ["10", f"{x}", "20", f"{y}"]
    return e

def rect_lines(layer, x, y, w, h, gap=0.0):
    return (line(layer, x, y, x + w, y) + line(layer, x + w, y, x + w, y + h) +
            line(layer, x + w, y + h, x, y + h) + line(layer, x, y + h, x, y + gap))

out = sys.argv[1] if len(sys.argv) > 1 else "testdata/dxf"
os.makedirs(out, exist_ok=True)

# 1) Corte conocido: placa 100x50 con dos agujeros Ø8 (cuatro LINE sueltas), pieza 20x10 en polilínea cerrada,
#    y capas auxiliares que no se cortan.
e = rect_lines("CORTE", 0, 0, 100, 50)
e += circle("CORTE", 20, 25, 4) + circle("CORTE", 80, 25, 4)
e += lwpoly("CORTE", [(200, 0), (220, 0), (220, 10), (200, 10)])
e += line("COTAS", 0, -10, 100, -10) + line("PLEGADO", 50, 0, 50, 50)
open(f"{out}/corte_conocido.dxf", "w").write(dxf(e, insunits=4, layers=("CORTE", "COTAS", "PLEGADO")))

# 2) Contorno abierto: rectángulo 40x30 al que le falta 0,5 mm.
e = rect_lines("CORTE", 0, 0, 40, 30, gap=0.5)
open(f"{out}/contorno_abierto.dxf", "w").write(dxf(e, insunits=4))

# 3) Línea repetida: rectángulo 40x30 con un lado dibujado dos veces.
e = rect_lines("CORTE", 0, 0, 40, 30) + line("CORTE", 0, 0, 40, 0)
open(f"{out}/linea_repetida.dxf", "w").write(dxf(e, insunits=4))

# 4) Ranura con arcos: dos semicírculos de radio 5 unidos por dos rectas de 20 (ranura 30x10),
#    en pulgadas declaradas.
e = (line("CORTE", 5, 0, 25, 0) + arc("CORTE", 25, 5, 5, 270, 90) + line("CORTE", 25, 10, 5, 10) +
     arc("CORTE", 5, 5, 5, 90, 270))
open(f"{out}/ranura_pulgadas.dxf", "w").write(dxf(e, insunits=1))

# 5) Sin unidad declarada.
open(f"{out}/sin_unidad.dxf", "w").write(dxf(rect_lines("CORTE", 0, 0, 40, 30), insunits=None))
print("DXF generados en", out)
