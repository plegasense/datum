"""Compone las capturas de la ficha de Play (1080x1920) a partir de capturas reales de la app."""
import sys, json
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FONT = "../branding/fonts/Roboto-Medium.ttf"
INK, MINT, ORANGE = (13, 27, 30), (94, 234, 212), (251, 146, 60)
W, H = 1080, 1920

FONT_SPEC = (FONT, 0)
CJK = "../branding/fonts/noto/NotoSansCJK-Regular.ttc"
CJK_INDEX = {"ja": 0, "ko": 1, "zh": 2, "tw": 3}


CT_FONTS = {"hi": "../branding/fonts/noto/NotoSansDevanagari-VF.ttf", "th": "../branding/fonts/noto/NotoSansThai-Regular.ttf"}
_CT = None


def use_language(code):
    """Elige la tipografía: Roboto para latino/cirílico, Noto Sans CJK para ja/ko/zh/tw y CoreText para hi/th."""
    global FONT_SPEC, _CT
    _CT = CT_FONTS.get(code)
    if _CT:
        import ctrender
        ctrender.install()
    FONT_SPEC = (CJK, CJK_INDEX[code]) if code in CJK_INDEX else (FONT, 0)


def font(sz):
    if _CT:
        import ctrender
        return ctrender.CTFont(_CT, FONT, sz)
    return ImageFont.truetype(FONT_SPEC[0], sz, index=FONT_SPEC[1])

def bg():
    im = Image.new("RGB", (W, H), INK)
    px = im.load()
    top, bot = (13, 27, 30), (18, 78, 88)
    for y in range(H):
        t = (y / H) ** 1.6
        c = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3))
        for x in range(W): px[x, y] = c
    return im

def wrap(d, text, f, maxw):
    sep = " " if " " in text else ""
    words, lines, cur = (text.split() if sep else list(text)), [], ""
    for w in words:
        t = (cur + sep + w).strip() if sep else cur + w
        if d.textlength(t, font=f) <= maxw or not cur: cur = t
        else: lines.append(cur); cur = w
    lines.append(cur)
    return lines

def phone(shot, scale=0.78, crop=None):
    s = Image.open(shot).convert("RGB")
    if crop: s = s.crop(crop)
    sw, sh = int(s.width * scale), int(s.height * scale)
    s = s.resize((sw, sh), Image.LANCZOS)
    pad, rad = 14, 56
    fw, fh = sw + pad * 2, sh + pad * 2
    frame = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    d = ImageDraw.Draw(frame)
    d.rounded_rectangle((0, 0, fw - 1, fh - 1), rad + pad, fill=(6, 11, 12, 255), outline=(52, 74, 79, 255), width=3)
    m = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, sw - 1, sh - 1), rad, fill=255)
    frame.paste(s, (pad, pad), m)
    return frame

def slide(out, shot, tag, title, sub, scale=0.74, crop=(0, 96, 1080, 2030), top=None):
    im = bg().convert("RGBA")
    d = ImageDraw.Draw(im)
    x0 = 72
    f_tag, f_t, f_s = font(34), font(78), font(40)
    tw = d.textlength(tag, font=f_tag)
    ov = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(ov).rounded_rectangle((x0, 96, x0 + tw + 48, 96 + 66), 33, fill=(94, 234, 212, 40), outline=MINT, width=2)
    im.alpha_composite(ov)
    d = ImageDraw.Draw(im)
    d.text((x0 + 24, 96 + 33), tag, font=f_tag, fill=MINT, anchor="lm")
    y = 200
    for ln in wrap(d, title, f_t, W - 2 * x0):
        d.text((x0, y), ln, font=f_t, fill=(255, 255, 255)); y += 90
    y += 10
    for ln in wrap(d, sub, f_s, W - 2 * x0):
        d.text((x0, y), ln, font=f_s, fill=(168, 196, 202)); y += 54
    ph = phone(shot, scale, crop)
    px, py = (W - ph.width) // 2, (top if top else y + 50)
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).rounded_rectangle((px - 10, py - 10, px + ph.width + 10, py + ph.height), 100, fill=(94, 234, 212, 55))
    im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(40)))
    im.alpha_composite(ph, (px, py))
    im.convert("RGB").save(out, optimize=True)
    print(out)

if __name__ == "__main__":
    spec = json.load(open(sys.argv[1]))
    for s in spec:
        slide(s["out"], s["shot"], s["tag"], s["title"], s["sub"], s.get("scale", 0.74), tuple(s["crop"]) if s.get("crop") else (0, 96, 1080, 2030), s.get("top"))

def free_slide(out, tagline="Visor CAD y 3D", items=None, foot=("Los archivos de taller que te llegan,", "abiertos en el móvil.")):
    items = items or [("Gratis de verdad", "Sin suscripciones ni compras dentro de la app"),
                      ("Sin anuncios", "Nada que cierre ni que te interrumpa"),
                      ("Sin cuenta", "Abre y trabaja, sin registrarte"),
                      ("Sin conexión", "No tiene permiso de Internet: tus archivos no salen del móvil")]
    im = bg().convert("RGBA")
    d = ImageDraw.Draw(im)
    icon = Image.open("../app/assets/icon/icon_square.png").convert("RGB").resize((220, 220), Image.LANCZOS)
    m = Image.new("L", (220, 220), 0); ImageDraw.Draw(m).rounded_rectangle((0, 0, 219, 219), 54, fill=255)
    im.paste(icon, (72, 120), m)
    d.text((332, 232), "Dovexa", font=ImageFont.truetype(FONT, 120), fill="white", anchor="ls")
    d.text((336, 296), tagline, font=font(46), fill=(168, 196, 202), anchor="ls")
    y = 470
    for t, sub in items:
        ov = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        ImageDraw.Draw(ov).rounded_rectangle((72, y, W - 72, y + 190), 40, fill=(255, 255, 255, 14), outline=(94, 234, 212, 70), width=2)
        im.alpha_composite(ov)
        d = ImageDraw.Draw(im)
        d.ellipse((108, y + 62, 174, y + 128), fill=MINT)
        d.line((124, y + 96, 138, y + 111, 160, y + 80), fill=INK, width=9, joint="curve")
        d.text((208, y + 70), t, font=font(54), fill="white", anchor="ls")
        f = font(33)
        for i2, ln in enumerate(wrap(d, sub, f, W - 72 - 208 - 40)[:2]):
            d.text((208, y + 118 + i2 * 40), ln, font=f, fill=(168, 196, 202), anchor="ls")
        y += 220
    for k, ln in enumerate(["STEP · IGES · DXF · SVG · HPGL", "STL · 3MF · OBJ · PLY · glTF · VRML", "G-code · bgcode · LAS · LAZ · E57 · PCD"]):
        d.text((W // 2, 1450 + 60 * k), ln, font=ImageFont.truetype(FONT, 38), fill=MINT, anchor="mm")
    d.text((W // 2, 1700), foot[0], font=font(46), fill="white", anchor="mm")
    d.text((W // 2, 1760), foot[1], font=font(46), fill="white", anchor="mm")
    im.convert("RGB").save(out, optimize=True); print(out)


def tablet_slide(out, shot, tag, title, sub):
    TW, TH = 2560, 1600
    im = Image.new("RGB", (TW, TH), INK)
    px = im.load()
    for y in range(TH):
        t = (y / TH) ** 1.5
        c = tuple(int((13, 27, 30)[i] + ((18, 78, 88)[i] - (13, 27, 30)[i]) * t) for i in range(3))
        for x in range(0, TW): px[x, y] = c
    im = im.convert("RGBA")
    d = ImageDraw.Draw(im)
    f_tag, f_t, f_s = font(40), font(92), font(46)
    tw = d.textlength(tag, font=f_tag)
    ov = Image.new("RGBA", (TW, TH), (0, 0, 0, 0))
    ImageDraw.Draw(ov).rounded_rectangle((120, 70, 120 + tw + 56, 70 + 74), 37, fill=(94, 234, 212, 40), outline=MINT, width=2)
    im.alpha_composite(ov)
    d = ImageDraw.Draw(im)
    d.text((148, 70 + 37), tag, font=f_tag, fill=MINT, anchor="lm")
    d.text((120, 176), title, font=f_t, fill="white")
    d.text((120, 290), sub, font=f_s, fill=(168, 196, 202))
    s = Image.open(shot).convert("RGB").crop((0, 72, 2560, 1560))
    cw = 2060; ch = int(s.height * cw / s.width)
    s = s.resize((cw, ch), Image.LANCZOS)
    pad = 14
    frame = Image.new("RGBA", (cw + 2 * pad, ch + 2 * pad), (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle((0, 0, frame.width - 1, frame.height - 1), 54, fill=(6, 11, 12, 255), outline=(52, 74, 79, 255), width=3)
    m = Image.new("L", s.size, 0); ImageDraw.Draw(m).rounded_rectangle((0, 0, s.width - 1, s.height - 1), 42, fill=255)
    frame.paste(s, (pad, pad), m)
    fx, fy = (TW - frame.width) // 2, 400
    glow = Image.new("RGBA", (TW, TH), (0, 0, 0, 0))
    ImageDraw.Draw(glow).rounded_rectangle((fx, fy, fx + frame.width, fy + frame.height), 60, fill=(94, 234, 212, 50))
    im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(50)))
    im.alpha_composite(frame, (fx, fy))
    im.convert("RGB").save(out, optimize=True); print(out)
