import 'dart:typed_data';

import 'package:datum/model/mesh_check.dart';
import 'package:flutter_test/flutter_test.dart';

typedef P = (double, double, double);

/// Malla de 6 floats por vértice a partir de triángulos.
Float32List mesh(List<List<P>> tris) {
  final out = <double>[];
  for (final t in tris) {
    for (final p in t) {
      out.addAll([p.$1, p.$2, p.$3, 0, 0, 1]);
    }
  }
  return Float32List.fromList(out);
}

/// Cubo de lado [s] con triángulos hacia fuera.
List<List<P>> cube(double s, {double ox = 0, double oy = 0, double oz = 0}) {
  P p(double x, double y, double z) => (ox + x * s, oy + y * s, oz + z * s);
  final v = [
    p(0, 0, 0),
    p(1, 0, 0),
    p(1, 1, 0),
    p(0, 1, 0),
    p(0, 0, 1),
    p(1, 0, 1),
    p(1, 1, 1),
    p(0, 1, 1),
  ];
  List<List<P>> q(int a, int b, int c, int d) => [
    [v[a], v[b], v[c]],
    [v[a], v[c], v[d]],
  ];
  return [
    ...q(0, 3, 2, 1), // abajo (normal -z)
    ...q(4, 5, 6, 7), // arriba
    ...q(0, 1, 5, 4), // frente (-y)
    ...q(2, 3, 7, 6), // atrás (+y)
    ...q(1, 2, 6, 5), // derecha
    ...q(3, 0, 4, 7), // izquierda
  ];
}

List<P> flip(List<P> t) => [t[0], t[2], t[1]];

void main() {
  test('cubo cerrado: estanco, 1000 mm³, 600 mm²', () {
    final r = analyzeMesh(mesh(cube(10)));
    expect(r.triangles, 12);
    expect(r.vertices, 8);
    expect(r.watertight, isTrue);
    expect(r.volume, closeTo(1000, 1e-6));
    expect(r.area, closeTo(600, 1e-6));
    expect(r.shells.length, 1);
    expect(r.shells.first.closed, isTrue);
    expect(r.centroid[0], closeTo(5, 1e-6));
    expect(r.problemCount, 0);
  });

  test('sin un triángulo: dos aristas… un agujero de 3 aristas', () {
    final t = cube(10)..removeAt(0);
    final r = analyzeMesh(mesh(t));
    expect(r.watertight, isFalse);
    expect(r.boundaryEdges, 3);
    expect(r.holes.length, 1);
    expect(r.holes.first.edges, 3);
    expect(r.shells.first.closed, isFalse);
  });

  test('normales invertidas en todo el cubo: volumen negativo', () {
    final t = [for (final x in cube(10)) flip(x)];
    final r = analyzeMesh(mesh(t));
    expect(r.boundaryEdges, 0);
    expect(r.volume, closeTo(-1000, 1e-6));
    expect(r.invertedNormals, isTrue);
  });

  test('un triángulo invertido: orientación inconsistente', () {
    final t = cube(10);
    t[3] = flip(t[3]);
    final r = analyzeMesh(mesh(t));
    expect(r.inconsistentEdges, greaterThan(0));
    expect(r.watertight, isFalse);
  });

  test('dos cubos separados: dos cascos y volumen sumado', () {
    final r = analyzeMesh(mesh([...cube(10), ...cube(5, ox: 20)]));
    expect(r.shells.length, 2);
    expect(r.volume, closeTo(1000 + 125, 1e-6));
    expect(r.watertight, isTrue);
  });

  test('triángulo duplicado y degenerado', () {
    final t = cube(10);
    final r = analyzeMesh(
      mesh([
        ...t,
        t[2],
        [(0, 0, 0), (0, 0, 0), (1, 1, 1)],
      ]),
    );
    expect(r.duplicates, 1);
    expect(r.degenerate, 1);
  });

  test('tres triángulos en una arista: no-manifold', () {
    final r = analyzeMesh(
      mesh([
        [(0, 0, 0), (1, 0, 0), (0, 1, 0)],
        [(0, 0, 0), (1, 0, 0), (0, 0, 1)],
        [(0, 0, 0), (1, 0, 0), (0, -1, 0)],
      ]),
    );
    expect(r.nonManifoldEdges, 1);
  });

  test('vértices que coinciden salvo ruido de coma flotante se sueldan', () {
    final t = cube(10);
    // desplaza 1e-5 mm un vértice en un triángulo
    t[5] = [(t[5][0].$1 + 1e-5, t[5][0].$2, t[5][0].$3), t[5][1], t[5][2]];
    final r = analyzeMesh(mesh(t));
    expect(r.boundaryEdges, 0);
  });
}
