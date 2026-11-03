"""Une los textos finales de ficha por idioma: store_final_<código>.json (title, short, long con la línea de unidades)."""
import json
import ficha_es, ficha_en
units = json.load(open("store_units_lines.json"))
units["es"] = "Unidades métricas e imperiales: medidas en mm o en pulgadas."
units["en"] = "Metric and imperial units: see sizes in mm or inches."
src = {"es": (ficha_es.TITULO, ficha_es.CORTA, ficha_es.LARGA), "en": (ficha_en.TITLE, ficha_en.SHORT, ficha_en.LONG)}
for code in "de zh pt fr ja ru ko it tr pl".split():
    d = json.load(open(f"store_{code}.json"))
    src[code] = (d["title"], d["short"], d["long"])
new = "cs nl tw id vi th hi uk sv".split()
for code in new:
    d = json.load(open(f"store_{code}.json"))
    src[code] = (d["title"], d["short"], d["long"])
for code, (t, s, l) in src.items():
    if code in new:
        assert len(t) <= 30 and len(s) <= 80 and len(l) <= 4000, (code, len(t), len(s), len(l))
        json.dump({"title": t, "short": s, "long": l}, open(f"store_final_{code}.json", "w"), ensure_ascii=False, indent=1)
        print(code, len(t), len(s), len(l))
        continue
    head, sep, rest = l.partition("\n\n")
    l2 = head + "\n\n" + units[code] + "\n\n" + rest if sep else l + "\n\n" + units[code]
    assert len(t) <= 30 and len(s) <= 80 and len(l2) <= 4000, (code, len(t), len(s), len(l2))
    json.dump({"title": t, "short": s, "long": l2}, open(f"store_final_{code}.json", "w"), ensure_ascii=False, indent=1)
    print(code, len(t), len(s), len(l2))
