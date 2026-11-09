import 'dart:typed_data';

import 'package:dovexa/model/mesh.dart';
import 'package:dovexa/ui/stl_tools.dart';
import 'package:flutter_test/flutter_test.dart';

Float32List tri(List<List<double>> p) {
  final out = <double>[];
  for (final v in p) {
    out.addAll([...v, 0, 0, 1]);
  }
  return Float32List.fromList(out);
}

void main() {
  test('voladizos: techo = voladizo, suelo = apoyo, pared = normal', () async {
    // suelo (normal -z) en z=0, techo (normal -z) en z=10, pared vertical
    final v = Float32List.fromList([
      ...tri([
        [0, 0, 0],
        [0, 1, 0],
        [1, 0, 0],
      ]), // normal -z, en la cama
      ...tri([
        [0, 0, 10],
        [0, 1, 10],
        [1, 0, 10],
      ]), // normal -z, en el aire
      ...tri([
        [0, 0, 0],
        [1, 0, 0],
        [0, 0, 1],
      ]), // vertical
    ]);
    final mesh = Mesh(vertices: v, bounds: Bounds([0, 0, 0], [1, 1, 10]));
    final c = StlController(mesh, null, 't');
    c.toggleOverhang();
    for (var i = 0; i < 100 && c.overhangScene == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(c.overhangScene, isNotNull);
    final names = c.overhangScene!.parts.map((p) => p.name).toSet();
    expect(names, {'ok', 'voladizo', 'base'});
  });

  test(
    'mejor orientación: una T de pie se apoya mejor tumbada o igual, nunca peor que la menor',
    () async {
      // Pieza con un techo grande a z=10 (voladizo en −Z) y una base pequeña en z=0.
      final v = Float32List.fromList([
        ...tri([
          [0, 0, 0],
          [0, 1, 0],
          [1, 0, 0],
        ]), // base pequeña (cara −Z)
        ...tri([
          [-5, -5, 10],
          [-5, 5, 10],
          [5, -5, 10],
        ]), // techo grande mirando abajo
        ...tri([
          [-5, -5, 10],
          [5, -5, 10],
          [-5, -5, 11],
        ]), // pared
      ]);
      final mesh = Mesh(vertices: v, bounds: Bounds([-5, -5, 0], [5, 5, 11]));
      final c = StlController(mesh, null, 't');
      c.run();
      for (var i = 0; i < 100 && c.orientations.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(c.orientations.length, 6);
      final z = c.orientations.firstWhere((o) => o.axis == 2 && o.sign == -1);
      final best = ([
        ...c.orientations,
      ]..sort((a, b) => a.overhangMm2.compareTo(b.overhangMm2))).first;
      expect(best.overhangMm2, lessThanOrEqualTo(z.overhangMm2));
      expect(z.overhangMm2, closeTo(50, 1e-3)); // el techo: 10×10/2
      expect(z.baseMm2, closeTo(0.5, 1e-3));
    },
  );
}
