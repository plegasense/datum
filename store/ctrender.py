"""Texto con formación compleja (devanagari, tailandés) vía CoreText (binario ct/cttext, compilado de ct/cttext.swift).
Tipografías Noto (OFL) y Roboto para las letras latinas. install() hace que ImageDraw acepte estas fuentes."""
import os, subprocess, functools
from PIL import Image, ImageDraw, ImageColor

BIN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ct", "cttext")


@functools.lru_cache(maxsize=None)
def _metrics(text, p, f, size):
    out = subprocess.run([BIN, "-", text, p, f, str(size), "0", "0", "0"], capture_output=True, text=True, check=True).stdout.split()
    return tuple(float(x) for x in out)


@functools.lru_cache(maxsize=None)
def _png(text, p, f, size, rgb):
    import tempfile
    path = tempfile.mktemp(suffix=".png")
    subprocess.run([BIN, path, text, p, f, str(size), *map(str, rgb)], capture_output=True, check=True)
    im = Image.open(path).convert("RGBA"); im.load(); os.unlink(path)
    return im


class CTFont:
    def __init__(self, primary, fallback, size):
        self.p, self.f, self.size = os.path.abspath(primary), os.path.abspath(fallback), size

    def length(self, text):
        return _metrics(text, self.p, self.f, self.size)[0]


_orig_draw = ImageDraw.Draw
_orig_text = ImageDraw.ImageDraw.text
_orig_len = ImageDraw.ImageDraw.textlength


def _draw(im, mode=None):
    d = _orig_draw(im, mode)
    d._pil_image = im
    return d


def _text(self, xy, text, fill=None, font=None, anchor=None, **kw):
    if not isinstance(font, CTFont):
        return _orig_text(self, xy, text, fill=fill, font=font, anchor=anchor, **kw)
    w, asc, desc = _metrics(text, font.p, font.f, font.size)
    rgb = tuple((fill if isinstance(fill, tuple) else ImageColor.getrgb(fill or "white"))[:3])
    im = _png(text, font.p, font.f, font.size, rgb)
    a = anchor or "la"
    x, y = xy
    x0 = x - (0 if a[0] == "l" else w / 2 if a[0] == "m" else w)
    top = {"a": 0, "t": 0, "m": (asc + desc) / 2, "s": asc, "d": asc + desc}.get(a[1], 0)
    target = self._pil_image
    pos = (int(round(x0 - 6)), int(round(y - top - 6)))
    if target.mode == "RGBA":
        target.alpha_composite(im, pos)
    else:
        target.paste(im, pos, im)


def _len(self, text, font=None, **kw):
    return font.length(text) if isinstance(font, CTFont) else _orig_len(self, text, font=font, **kw)


def install():
    ImageDraw.Draw = _draw
    ImageDraw.ImageDraw.text = _text
    ImageDraw.ImageDraw.textlength = _len
