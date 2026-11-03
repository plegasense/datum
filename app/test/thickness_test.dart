import 'dart:typed_data';

import 'package:datum/model/thickness.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cubo centrado de lado [s]; con [inward] las caras miran hacia dentro (cavidad).
List<double> cube(double s, {bool inward = false, double ox = 0}) {
  final h = s / 2;
  final p = [
    [-h, -h, -h], [h, -h, -h], [h, h, -h], [-h, h, -h],
    [-h, -h, h], [h, -h, h], [h, h, h], [-h, h, h],
  ];
  // caras con orientación antihoraria vista desde fuera
  const faces = [
    [0, 3, 2, 1], [4, 5, 6, 7], [0, 1, 5, 4], [3, 7, 6, 2], [0, 4, 7, 3], [1, 2, 6, 5],
  ];
  final out = <double>[];
  void tri(List<int> i) {
    final idx = inward ? [i[0], i[2], i[1]] : i;
    for (final k in idx) {
      out.addAll([p[k][0] + ox, p[k][1], p[k][2], 0, 0, 0]);
    }
  }

  for (final f in faces) {
    tri([f[0], f[1], f[2]]);
    tri([f[0], f[2], f[3]]);
  }
  return out;
}

void main() {
  selfIntersectionTests();
  test('cubo macizo: el espesor es el lado', () {
    final r = computeThickness(Float32List.fromList(cube(20)));
    expect(r.minThickness, closeTo(20, 1e-3));
    expect(r.sampled, isFalse);
  });

  test('cubo hueco: paredes de 2', () {
    final v = Float32List.fromList([...cube(20), ...cube(16, inward: true)]);
    final r = computeThickness(v);
    expect(r.minThickness, closeTo(2, 1e-3));
    // todas las caras (exteriores e interiores) miden 2
    final good = r.perTriangle.where((e) => e.isFinite).toList();
    expect(good.length, 24);
    expect(good.every((e) => (e - 2).abs() < 1e-3), isTrue);
  });

  test('pared fina localizada', () {
    // cavidad descentrada: una pared de 0,5 y la opuesta de 3,5
    final v = Float32List.fromList([...cube(20), ...cube(16, inward: true, ox: 1.5)]);
    final r = computeThickness(v);
    expect(r.minThickness, closeTo(0.5, 1e-3));
    expect(r.minAt[0].abs(), greaterThan(5)); // en la cara de x = ±10
  });

  test('muestreo de mallas grandes', () {
    final v = Float32List.fromList([...cube(20), ...cube(16, inward: true)]);
    final r = computeThickness(v, maxRays: 10);
    expect(r.sampled, isTrue);
    expect(r.measured, lessThanOrEqualTo(24));
  });
}

void selfIntersectionTests() {
  Float32List tri(List<double> p) {
    final v = Float32List(18);
    for (var i = 0; i < 3; i++) {
      for (var k = 0; k < 3; k++) {
        v[i * 6 + k] = p[i * 3 + k];
      }
    }
    return v;
  }

  Float32List cat2(Float32List a, Float32List b) => Float32List(a.length + b.length)..setAll(0, a)..setAll(a.length, b);

  test('dos triángulos que se atraviesan', () {
    final a = tri([0, 0, 0, 4, 0, 0, 0, 4, 0]);
    final b = tri([1, 1, -1, 1, 1, 1, 3, 1, 0.2]);
    expect(findSelfIntersections(cat2(a, b)).pairs, 1);
  });

  test('triángulos que sólo comparten un vértice o están separados no cuentan', () {
    final a = tri([0, 0, 0, 4, 0, 0, 0, 4, 0]);
    final b = tri([0, 0, 0, 0, 0, 3, 3, 0, 3]);
    final c = tri([0, 0, 5, 4, 0, 5, 0, 4, 5]);
    expect(findSelfIntersections(cat2(cat2(a, b), c)).pairs, 0);
  });
}
