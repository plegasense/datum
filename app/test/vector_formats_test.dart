import 'dart:convert';
import 'dart:io';

import 'package:dovexa/io/hpgl_parser.dart';
import 'package:dovexa/io/svg_loader.dart';
import 'package:flutter_test/flutter_test.dart';

File tmp(String name, String s) {
  final f = File('${Directory.systemTemp.path}/dovexa_vec_$name');
  f.writeAsBytesSync(utf8.encode(s));
  return f;
}

void main() {
  svgExtras();
  group('SVG', () {
    test('tamaño declarado en mm: la geometría sale en mm', () {
      final d = parseSvg(tmp('a.svg', '<svg xmlns="http://www.w3.org/2000/svg" width="100mm" height="50mm" viewBox="0 0 10 5"><rect x="0" y="0" width="10" height="5" fill="none" stroke="#f00"/></svg>').path);
      expect(d.insUnits, 4);
      expect(d.max[0] - d.min[0], closeTo(100, 0.01));
      expect(d.info!.declaredWidthMm, closeTo(100, 0.01));
    });

    test('sin tamaño físico: px a 96 ppp y avisa', () {
      final d = parseSvg(tmp('b.svg', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 100"><path d="M0 0H200V100H0Z" stroke="black" fill="none"/></svg>').path);
      expect(d.insUnits, kInsUnitsPx96);
      expect(d.max[0] - d.min[0], closeTo(200, 0.01));
    });

    test('CSS por clase, use, ocultos y defs', () {
      final d = parseSvg(tmp('c.svg', '''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100mm" height="100mm" viewBox="0 0 100 100">
<style>.cut{fill:none;stroke:#ff0000}</style>
<defs><rect id="r" width="10" height="10" class="cut"/></defs>
<use xlink:href="#r" x="20" y="20"/>
<rect class="cut" x="50" y="50" width="10" height="10" style="display:none"/>
</svg>''').path);
      expect(d.layers.map((l) => l.$1), ['#FF0000']);
      expect(d.layers.first.$3, 8); // un solo cuadrado (4 segmentos × 2 vértices)
      expect(d.min[0], closeTo(20, 0.01));
    });

    test('banderas de arco pegadas y trazados erróneos', () {
      final d = parseSvg(tmp('d.svg', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><path d="M10 50a40 40 0 0150 0" stroke="red" fill="none"/><path d="M0 0 L10 10 L x" stroke="red" fill="none"/></svg>').path);
      expect(d.max[0], closeTo(60, 0.5));
      expect(d.info!.counts['trazados con datos erróneos'], 1);
    });

    test('texto sin convertir se avisa', () {
      final d = parseSvg(tmp('e.svg', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><path d="M0 0L10 10" stroke="red"/><text x="5" y="50">Hola</text></svg>').path);
      expect(d.texts.single.text, 'Hola');
      expect(d.info!.warnings.any((w) => w.contains('texto')), isTrue);
    });

    test('XML roto da error limpio', () {
      expect(() => parseSvg(tmp('f.svg', '<svg><path').path), throwsFormatException);
      expect(() => parseSvg(tmp('g.svg', '<html/>').path), throwsFormatException);
    });
  });

  group('HPGL', () {
    test('PA/PR, plumas y recorrido en vacío', () {
      final d = parseHpgl(tmp('a.hpgl', 'IN;SP1;PU0,0;PD400,0,400,400;PU800,800;SP2;PD;PR-400,0;').path);
      final v = d.info!;
      expect(v.drawMm, closeTo(10 + 10 + 10, 0.01));
      expect(v.travelMm, closeTo(math(400, 400) * 0.025 + 0, 0.5 + 0.1));
      expect(v.pens.length, 2);
      expect(d.layers.map((l) => l.$1), containsAll(['Pluma 1', 'Pluma 2']));
    });

    test('PE codificado (base 64)', () {
      // :1 (pluma 1) y un trazo relativo de (+8, +8): 16 → «p»? base64: valor 16 = 0b10000 → carácter 63+16.
      final d = parseHpgl(tmp('b.hpgl', 'IN;PA0,0;PE:${String.fromCharCode(63 + 2)}=${String.fromCharCode(63 + 16)}${String.fromCharCode(63 + 16)};').path);
      expect(d.info!.encodedPolylines, isTrue);
    });

    test('rótulos y envoltorio PCL', () {
      final d = parseHpgl(tmp('c.hpgl', '\x1b%-12345X@PJL ENTER LANGUAGE=HPGL2\n\x1b%0BIN;SP1;PU0,0;PD400,0;PU100,100;LBHola\x03\x1b%0A').path);
      expect(d.texts.single.text, 'Hola');
      expect(d.info!.drawMm, closeTo(10, 0.01));
    });

    test('arco y círculo', () {
      final d = parseHpgl(tmp('d.hpgl', 'IN;SP1;PA1000,1000;CI400;').path);
      expect(d.info!.drawMm, closeTo(2 * 3.14159 * 400 * 0.025, 0.2));
    });

    test('vacío da error limpio', () {
      expect(() => parseHpgl(tmp('e.hpgl', 'IN;SP1;').path), throwsFormatException);
    });
  });
}

double math(double a, double b) => (a * a + b * b) <= 0 ? 0 : (a * a + b * b).toDouble() == 0 ? 0 : _sqrt(a * a + b * b);
double _sqrt(double v) {
  var x = v;
  for (var i = 0; i < 40; i++) {
    x = (x + v / x) / 2;
  }
  return x;
}

void svgExtras() {
  group('SVG: degradados y recortes', () {
    test('el degradado usa el color de su primera parada', () {
      final d = parseSvg(tmp('grad.svg', '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
<defs><linearGradient id="g"><stop offset="0" stop-color="#00ff00"/><stop offset="1" stop-color="#0000ff"/></linearGradient></defs>
<rect width="50" height="50" fill="url(#g)"/></svg>''').path);
      expect(d.layers.first.$1, '#00FF00 sin contorno');
    });

    test('recorte rectangular: los trazos salen recortados', () {
      final d = parseSvg(tmp('clip.svg', '''<svg xmlns="http://www.w3.org/2000/svg" width="100mm" height="100mm" viewBox="0 0 100 100">
<defs><clipPath id="c"><rect x="0" y="0" width="50" height="100"/></clipPath></defs>
<g clip-path="url(#c)"><path d="M0 50 L100 50" stroke="red" fill="none"/></g></svg>''').path);
      expect(d.max[0] - d.min[0], closeTo(50, 0.01));
      expect(d.info!.counts['recortes aplicados'], 1);
    });

    test('recorte que deja todo fuera', () {
      final d = parseSvg(tmp('clip2.svg', '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
<defs><clipPath id="c"><rect x="0" y="0" width="10" height="10"/></clipPath></defs>
<path d="M0 50 L100 50" stroke="red" fill="none" clip-path="url(#c)"/><path d="M0 0 L5 5" stroke="blue"/></svg>''').path);
      expect(d.layers.single.$1, '#0000FF');
    });
  });
}
