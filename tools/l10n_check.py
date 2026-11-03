#!/usr/bin/env python3
"""Revisa la traducción es/en de la app.

  python3 tools/l10n_check.py            # informe completo
  python3 tools/l10n_check.py --files app/lib/ui/stl_tools.dart ...   # sólo esos archivos

Comprueba: (1) cada `tr('…')` tiene entrada en los `lib/l10n/en_*.dart`; (2) los marcadores {x} coinciden;
(3) quedan sin traducir literales con aspecto de español (lista para revisar a mano; las excepciones
van en tools/l10n_allow.txt, una por línea: «ruta_relativa|texto exacto»).
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'app', 'lib')
ACCENT = re.compile(r'[áéíóúñÁÉÍÓÚÑ¿¡]')
WORDS = re.compile(r'\b(de|la|el|los|las|con|sin|para|por|se|que|una?|del|al|en|es|no|hay|más|tus?|su|sus|este|esta|archivo|pieza|capa|modelo)\b', re.I)
ESC = {'n': '\n', 't': '\t', 'r': '\r', "'": "'", '"': '"', '\\': '\\', '$': '$'}


def parse_string(src, i):
    """src[i] es el inicio de un literal Dart. Devuelve (fin, contenido, interpolado)."""
    raw = False
    if src[i] == 'r' and i + 1 < len(src) and src[i + 1] in '\'"':
        raw = True
        i += 1
    q = src[i]
    triple = src[i:i + 3] == q * 3
    ql = 3 if triple else 1
    j = i + ql
    out = []
    interp = False
    while j < len(src):
        c = src[j]
        if src[j:j + ql] == q * ql:
            return j + ql, ''.join(out), interp
        if not raw and c == '\\':
            n = src[j + 1]
            out.append(ESC.get(n, '\\' + n))
            j += 2
            continue
        if not raw and c == '$':
            interp = True
            if src[j + 1] == '{':
                depth = 1
                k = j + 2
                while k < len(src) and depth:
                    if src[k] in '\'"':
                        k, _, _ = parse_string(src, k)
                        continue
                    if src[k] == '{':
                        depth += 1
                    elif src[k] == '}':
                        depth -= 1
                    k += 1
                out.append('${…}')
                j = k
                continue
            m = re.match(r'\$[A-Za-z_]\w*', src[j:])
            out.append(m.group(0) if m else '$')
            j += len(m.group(0)) if m else 1
            continue
        if c == '\n' and not triple:
            return j, ''.join(out), interp
        out.append(c)
        j += 1
    return j, ''.join(out), interp


def tokens(src):
    """Genera (pos, kind, valor): 'str' (contenido, interpolado) y 'id'/'punct' mínimos."""
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == '/' and src[i:i + 2] == '//':
            while i < n and src[i] != '\n':
                i += 1
            continue
        if c == '/' and src[i:i + 2] == '/*':
            i = src.find('*/', i + 2)
            i = n if i < 0 else i + 2
            continue
        if c in '\'"' or (c == 'r' and i + 1 < n and src[i + 1] in '\'"' and (i == 0 or not (src[i - 1].isalnum() or src[i - 1] == '_'))):
            e, val, interp = parse_string(src, i)
            yield i, 'str', (val, interp)
            i = e
            continue
        if c.isalpha() or c == '_':
            m = re.match(r'[A-Za-z_]\w*', src[i:])
            yield i, 'id', m.group(0)
            i += len(m.group(0))
            continue
        if c.isspace():
            i += 1
            continue
        yield i, 'p', c
        i += 1


def line_of(src, pos):
    return src.count('\n', 0, pos) + 1


def scan_file(path):
    src = open(path, encoding='utf-8').read()
    toks = list(tokens(src))
    calls, strings = [], []
    consumed = set()
    k = 0
    while k < len(toks):
        pos, kind, v = toks[k]
        if kind == 'id' and v in ('tr', 'tru') and k + 2 < len(toks) and toks[k + 1][2] == '(' and toks[k + 2][1] == 'str':
            # literales adyacentes = un solo texto
            j = k + 2
            text, interp = '', False
            while j < len(toks) and toks[j][1] == 'str':
                text += toks[j][2][0]
                interp = interp or toks[j][2][1]
                consumed.add(j)
                j += 1
            calls.append((line_of(src, pos), text, interp))
            k = j
            continue
        if kind == 'str':
            strings.append((line_of(src, pos), v[0], k))
        k += 1
    return calls, [(ln, s) for ln, s, idx in strings if idx not in consumed], src


def load_en(prefix='en'):
    en = {}
    d = os.path.join(LIB, 'l10n')
    for f in sorted(os.listdir(d)):
        if not ((f == prefix + '.dart') if prefix.startswith('lang_') else (f.startswith(prefix) and f.endswith('.dart'))):
            continue
        toks = list(tokens(open(os.path.join(d, f), encoding='utf-8').read()))
        k = 0
        while k < len(toks):
            if toks[k][1] == 'str':
                key, j = '', k
                while j < len(toks) and toks[j][1] == 'str':
                    key += toks[j][2][0]
                    j += 1
                if j < len(toks) and toks[j][2] == ':' and j + 1 < len(toks) and toks[j + 1][1] == 'str':
                    val, m = '', j + 1
                    while m < len(toks) and toks[m][1] == 'str':
                        val += toks[m][2][0]
                        m += 1
                    en[key] = val
                    k = m
                    continue
                k = j
                continue
            k += 1
    return en


def looks_spanish(s):
    if len(s) < 4 or s.startswith(('package:', 'dart:', 'http', '/', '.')):
        return False
    if ACCENT.search(s):
        return True
    return len(WORDS.findall(s)) >= 2 and ' ' in s


def check_lang(code):
    en = load_en()
    tr_ = load_en('lang_' + code)
    bad = 0
    for k in en:
        if k not in tr_ or not tr_[k].strip():
            print(f'{code}: falta {k!r}')
            bad += 1
        else:
            a, b = set(re.findall(r'\{(\w+)\}', k)), set(re.findall(r'\{(\w+)\}', tr_[k]))
            if a != b:
                print(f'{code}: marcadores distintos {sorted(a)} vs {sorted(b)} en {k!r} -> {tr_[k]!r}')
                bad += 1
    extra = [k for k in tr_ if k not in en]
    print(f'{code}: {len(tr_)} claves, {bad} problemas, {len(extra)} claves de más')
    return 1 if bad else 0


def main():
    files = []
    args = sys.argv[1:]
    if args and args[0] == '--lang':
        return check_lang(args[1])
    if args and args[0] == '--files':
        files = [os.path.abspath(a) for a in args[1:]]
    else:
        for dp, _, fs in os.walk(LIB):
            for f in fs:
                if f.endswith('.dart') and 'l10n' not in dp:
                    files.append(os.path.join(dp, f))
    allow = set()
    ap = os.path.join(ROOT, 'tools', 'l10n_allow.txt')
    if os.path.exists(ap):
        allow = {l.rstrip('\n') for l in open(ap, encoding='utf-8') if l.strip() and not l.startswith('#')}
    en = load_en()
    bad = 0
    used = set()
    for f in sorted(files):
        rel = os.path.relpath(f, LIB)
        calls, strings, _ = scan_file(f)
        for ln, key, interp in calls:
            used.add(key)
            if interp:
                print(f'{rel}:{ln}: tr() con interpolación ${{}} en la clave: {key!r} (usa marcadores {{x}} y el mapa de argumentos)')
                bad += 1
            elif key not in en and key and ACCENT.search(key + 'x') is not None or (key and key not in en):
                print(f'{rel}:{ln}: sin traducción al inglés: {key!r}')
                bad += 1
            elif key in en:
                a, b = set(re.findall(r'\{(\w+)\}', key)), set(re.findall(r'\{(\w+)\}', en[key]))
                if a != b:
                    print(f'{rel}:{ln}: marcadores distintos {sorted(a)} vs {sorted(b)} en {key!r}')
                    bad += 1
        for ln, s in strings:
            if looks_spanish(s) and f'{rel}|{s}' not in allow:
                print(f'{rel}:{ln}: SIN TRADUCIR? {s[:90]!r}')
                bad += 1
    if not args:
        unused = [k for k in en if k not in used]
        if unused:
            print(f'(aviso) {len(unused)} entradas del mapa inglés sin uso')
    print(f'{bad} problemas')
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
