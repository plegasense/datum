#!/usr/bin/env python3
"""Sustituye en los .a la ruta absoluta del proyecto por una neutra de la misma longitud (uso: scrub_paths.py DIR RUTA)."""
import glob, sys
d, root = sys.argv[1], sys.argv[2].encode()
new = b"/" * (len(root) - 7) + b"/dovexa"
for f in glob.glob(d + "/*.a"):
    b = open(f, "rb").read()
    if root in b:
        open(f, "wb").write(b.replace(root, new))
