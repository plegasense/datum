"""Gráfico de funciones 1024x500. Uso: python3 feature.py <código> …"""
import json, os, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import compose

W, H = 1024, 500


def build(code):
    st = json.load(open("store_strings_en.json" if code == "en" else f"store_{code}.json"))
    ft = st["feature"]
    compose.use_language(code)
    f = compose.font
    Fl = lambda s: ImageFont.truetype(compose.FONT, s)  # Roboto para el nombre
    im = Image.new("RGB", (W, H))
    px = im.load()
    for y in range(H):
        for x in range(W):
            t = min(1, max(0, (x / W) * 0.55 + (y / H) * 0.45)) ** 1.4
            a, b = (13, 27, 30), (20, 92, 104)
            px[x, y] = tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))
    im = im.convert("RGBA")
    d = ImageDraw.Draw(im)
    icon = Image.open("../app/assets/icon/icon_square.png").convert("RGB").resize((104, 104), Image.LANCZOS)
    m = Image.new("L", (104, 104), 0); ImageDraw.Draw(m).rounded_rectangle((0, 0, 103, 103), 26, fill=255)
    im.paste(icon, (52, 92), m)
    d.text((178, 144), "Datum", font=Fl(84), fill="white", anchor="lm")
    def fit(text, size, maxw):
        while size > 14 and d.textlength(text, font=f(size)) > maxw:
            size -= 1
        return f(size)
    d.text((54, 262), ft["tagline"], font=fit(ft["tagline"], 44, 440), fill=(220, 236, 238))
    d.text((54, 322), ft["line"], font=fit(ft["line"], 26, 440), fill=(94, 234, 212))
    d.text((54, 366), ft["formats"], font=fit(ft["formats"], 21, 440), fill=(150, 184, 190))

    def card(src, box, size, pos, rot):
        s = Image.open(src).convert("RGB").crop(box)
        s.thumbnail(size, Image.LANCZOS)
        c = Image.new("RGBA", (s.width + 12, s.height + 12), (0, 0, 0, 0))
        ImageDraw.Draw(c).rounded_rectangle((0, 0, c.width - 1, c.height - 1), 26, fill=(8, 14, 16, 255), outline=(60, 90, 96, 255), width=2)
        mm = Image.new("L", s.size, 0); ImageDraw.Draw(mm).rounded_rectangle((0, 0, s.width - 1, s.height - 1), 20, fill=255)
        c.paste(s, (6, 6), mm)
        c = c.rotate(rot, expand=True, resample=Image.BICUBIC)
        sh = Image.new("RGBA", im.size, (0, 0, 0, 0))
        sh.paste((0, 0, 0, 150), (pos[0] + 6, pos[1] + 10), c.split()[3])
        im.alpha_composite(sh.filter(ImageFilter.GaussianBlur(10)))
        im.alpha_composite(c, pos)

    sd = f"shots/{code}"
    card(f"{sd}/cnc.png", (0, 780, 1000, 1600), (360, 260), (535, 28), -3)
    card(f"{sd}/gltf.png", (0, 820, 860, 1560), (300, 240), (705, 105), 3)
    card(f"{sd}/step.png", (0, 940, 860, 1500), (330, 215), (575, 268), 2)
    os.makedirs(f"play/{code}", exist_ok=True)
    im.convert("RGB").save(f"play/{code}/feature-graphic-1024x500.png", optimize=True)
    print(code)


if __name__ == "__main__":
    for c in sys.argv[1:]:
        build(c)
