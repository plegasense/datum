import 'dart:io';

import 'package:dovexa/io/mesh_data.dart';
import 'package:dovexa/io/ply_loader.dart';
import 'package:dovexa/model/mesh_info.dart';
import 'package:flutter_test/flutter_test.dart';

File ply(String name, String s) => File('${Directory.systemTemp.path}/dovexa_ply_$name')..writeAsStringSync(s);

void main() {
  test('PLY: escalar por cara pinta las caras con la rampa', () {
    final f = ply(
      'fq.ply',
      'ply\nformat ascii 1.0\nelement vertex 4\nproperty float x\nproperty float y\nproperty float z\n'
      'element face 2\nproperty list uchar int vertex_indices\nproperty float quality\nend_header\n'
      '0 0 0\n1 0 0\n1 1 0\n0 1 0\n3 0 1 2 0.1\n3 0 2 3 0.9\n',
    );
    final r = parsePly(f.path) as SceneData;
    final info = r.extra as MeshFileInfo;
    expect(info.scalarName, contains('quality'));
    expect(info.hasColors, isTrue);
    expect(info.scalarMin, closeTo(0.1, 1e-6));
    expect(info.scalarMax, closeTo(0.9, 1e-6));
  });

  test('PLY: elemento edge se dibuja como tubos y se avisa', () {
    final f = ply(
      'edge.ply',
      'ply\nformat ascii 1.0\nelement vertex 3\nproperty float x\nproperty float y\nproperty float z\n'
      'element edge 2\nproperty int vertex1\nproperty int vertex2\nend_header\n0 0 0\n1 0 0\n1 1 0\n0 1\n1 2\n',
    );
    final r = parsePly(f.path) as SceneData;
    expect(r.meshes.length, 1);
    expect(r.meshes.first.name, 'Aristas');
    expect((r.extra as MeshFileInfo).warnings.any((w) => w.contains('aristas')), isTrue);
  });

  test('PLY: caras y aristas a la vez', () {
    final f = ply(
      'both.ply',
      'ply\nformat ascii 1.0\nelement vertex 4\nproperty float x\nproperty float y\nproperty float z\n'
      'element face 1\nproperty list uchar int vertex_indices\nelement edge 1\nproperty int vertex1\nproperty int vertex2\nend_header\n'
      '0 0 0\n1 0 0\n1 1 0\n0 1 0\n3 0 1 2\n0 3\n',
    );
    final r = parsePly(f.path) as SceneData;
    expect(r.meshes.map((m) => m.name), contains('Aristas'));
    expect(r.meshes.length, 2);
  });
}
