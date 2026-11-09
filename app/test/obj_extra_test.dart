import 'dart:io';
import 'dart:typed_data';

import 'package:dovexa/io/mesh_data.dart';
import 'package:dovexa/io/obj_loader.dart';
import 'package:dovexa/io/texture_prep.dart';
import 'package:dovexa/model/mesh_info.dart';
import 'package:flutter_test/flutter_test.dart';

Directory tmp(String n) => Directory('${Directory.systemTemp.path}/dovexa_obj_$n')..createSync(recursive: true);

void main() {
  test('OBJ: líneas sin caras se dibujan como tubos', () {
    final d = tmp('lineas');
    final f = File('${d.path}/l.obj')..writeAsStringSync('v 0 0 0\nv 1 0 0\nv 1 1 0\nl 1 2 3\n');
    final r = parseObj(f.path) as SceneData;
    expect(r.meshes.single.name, 'Líneas');
    expect((r.extra as MeshFileInfo).warnings.any((w) => w.contains('línea')), isTrue);
  });

  test('OBJ: caras y líneas a la vez', () {
    final d = tmp('mixto');
    final f = File('${d.path}/m.obj')..writeAsStringSync('v 0 0 0\nv 1 0 0\nv 1 1 0\nv 0 1 0\nf 1 2 3\nl 1 4\n');
    final r = parseObj(f.path) as SceneData;
    expect(r.meshes.length, 2);
  });

  test('OBJ: el relieve (map_bump) se vuelve mapa de normales', () {
    final d = tmp('bump');
    // PNG 2x2 mínimo no hace falta: basta con que el archivo exista
    File('${d.path}/b.png').writeAsBytesSync(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]));
    File('${d.path}/m.mtl').writeAsStringSync('newmtl a\nKd 0.5 0.5 0.5\nmap_bump b.png\n');
    final f = File('${d.path}/o.obj')
      ..writeAsStringSync('mtllib m.mtl\nusemtl a\nv 0 0 0\nv 1 0 0\nv 1 1 0\nvt 0 0\nvt 1 0\nvt 1 1\nf 1/1 2/2 3/3\n');
    final r = parseObj(f.path) as SceneData;
    final m = r.materials.single;
    expect(m.pbr, isTrue);
    expect(m.normalTexture, isNotNull);
    expect(r.textures[m.normalTexture!].asHeight, isTrue);
  });

  test('altura → normales: una rampa inclina las normales', () {
    // 4x4, altura creciente hacia la derecha
    final rgba = Uint8List(4 * 4 * 4);
    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 4; x++) {
        final o = (y * 4 + x) * 4;
        rgba[o] = rgba[o + 1] = rgba[o + 2] = x * 80;
        rgba[o + 3] = 255;
      }
    }
    final n = heightToNormals(rgba, 4, 4, strength: 64);
    final o = (1 * 4 + 1) * 4;
    expect(n[o], lessThan(120)); // nx negativo (inclinada hacia la izquierda)
    expect((n[o + 1] - 128).abs(), lessThan(3)); // sin pendiente en y
    expect(n[o + 2], greaterThan(150));
  });
}
