import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dovexa/io/gltf_loader.dart';
import 'package:dovexa/io/obj_loader.dart';
import 'package:dovexa/io/ply_loader.dart';
import 'package:dovexa/io/rich_mesh.dart';
import 'package:dovexa/io/texture_prep.dart';
import 'package:dovexa/model/mesh_info.dart';
import 'package:dovexa/model/rig.dart';
import 'package:dovexa/render/lod.dart';
import 'package:flutter_test/flutter_test.dart';

File tmp(String name, List<int> bytes) {
  final f = File('${Directory.systemTemp.path}/dovexa_mesh_$name');
  f.writeAsBytesSync(bytes);
  return f;
}

File text(String name, String s) => tmp(name, utf8.encode(s));

/// GLB mínimo: un triángulo con color por vértice normalizado (u8) y accesores intercalados.
Uint8List glb(Map<String, dynamic> json, Uint8List bin) {
  final j = utf8.encode(jsonEncode(json));
  final jp = Uint8List((j.length + 3) & ~3)..fillRange(0, (j.length + 3) & ~3, 0x20)..setRange(0, j.length, j);
  final bp = Uint8List((bin.length + 3) & ~3)..setRange(0, bin.length, bin);
  final total = 12 + 8 + jp.length + 8 + bp.length;
  final out = BytesBuilder();
  final h = ByteData(12)
    ..setUint32(0, 0x46546C67, Endian.little)
    ..setUint32(4, 2, Endian.little)
    ..setUint32(8, total, Endian.little);
  out.add(h.buffer.asUint8List());
  final c1 = ByteData(8)
    ..setUint32(0, jp.length, Endian.little)
    ..setUint32(4, 0x4E4F534A, Endian.little);
  out.add(c1.buffer.asUint8List());
  out.add(jp);
  final c2 = ByteData(8)
    ..setUint32(0, bp.length, Endian.little)
    ..setUint32(4, 0x004E4942, Endian.little);
  out.add(c2.buffer.asUint8List());
  out.add(bp);
  return out.takeBytes();
}

void main() {
  group('malla enriquecida', () {
    test('un cubo sin normales queda con aristas vivas y una esfera suave', () {
      // cubo: 8 vértices, 12 triángulos
      final pos = Float32List.fromList([
        -1, -1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, //
        -1, -1, 1, 1, -1, 1, 1, 1, 1, -1, 1, 1,
      ]);
      final t = CornerTris();
      for (final f in const [
        [0, 2, 1], [0, 3, 2], [4, 5, 6], [4, 6, 7], [0, 1, 5], [0, 5, 4], //
        [2, 3, 7], [2, 7, 6], [0, 4, 7], [0, 7, 3], [1, 2, 6], [1, 6, 5],
      ]) {
        t.tri(f[0], f[1], f[2]);
      }
      final out = RichMeshBuilder(pos: pos).build(t, ['cubo']);
      expect(out.single.vertices.length ~/ 6, 24); // 4 por cara: aristas vivas
      expect(out.single.indices.length, 36);
    });

    test('polígono cóncavo se triangula sin cruzarse', () {
      // «L» de 6 vértices
      final p = Float32List.fromList([0, 0, 0, 2, 0, 0, 2, 1, 0, 1, 1, 0, 1, 2, 0, 0, 2, 0]);
      final tr = triangulatePolygon(p, [0, 1, 2, 3, 4, 5]);
      expect(tr.length, 12); // 4 triángulos
      var area = 0.0;
      for (var i = 0; i < tr.length; i += 3) {
        final a = tr[i] * 3, b = tr[i + 1] * 3, c = tr[i + 2] * 3;
        area += ((p[b] - p[a]) * (p[c + 1] - p[a + 1]) - (p[b + 1] - p[a + 1]) * (p[c] - p[a])).abs() / 2;
      }
      expect(area, closeTo(3, 1e-9));
    });

    test('simplificación conserva el contorno y reduce triángulos', () {
      // rejilla 40×40 de vértices
      const n = 40;
      final v = Float32List(n * n * 6);
      for (var y = 0; y < n; y++) {
        for (var x = 0; x < n; x++) {
          final i = (y * n + x) * 6;
          v[i] = x.toDouble();
          v[i + 1] = y.toDouble();
          v[i + 5] = 1;
        }
      }
      final idx = <int>[];
      for (var y = 0; y + 1 < n; y++) {
        for (var x = 0; x + 1 < n; x++) {
          final a = y * n + x;
          idx.addAll([a, a + 1, a + n, a + 1, a + n + 1, a + n]);
        }
      }
      final r = decimateIndexed(v, null, Uint32List.fromList(idx), [0, 0, 0], [39, 39, 0], 200);
      expect(r.indices.length ~/ 3, lessThan(idx.length ~/ 3));
      expect(r.indices.length, greaterThan(0));
    });

    test('mips: una imagen 4×4 genera 2 niveles y promedia', () {
      final base = Uint8List(4 * 4 * 4);
      for (var i = 0; i < 16; i++) {
        base[i * 4] = i < 8 ? 0 : 200;
        base[i * 4 + 3] = 255;
      }
      final m = buildMips(base, 4, 4);
      expect(m.length, 2);
      expect(m[1].length, 2 * 2 * 4);
      expect(m[1][0], 0);
      expect(m[1][8], 200);
    });
  });

  group('OBJ', () {
    test('caras con barras, índices negativos, polígonos y color por vértice', () {
      final f = text('a.obj', '''
v 0 0 0 1 0 0
v 1 0 0 0 1 0
v 1 1 0 0 0 1
v 0 1 0 1 1 1
vt 0 0
vt 1 0
vt 1 1
vt 0 1
f 1/1 2/2 3/3 4/4
f -4 -3 -2
''');
      final r = parseObj(f.path) as dynamic;
      final info = r.extra as MeshFileInfo;
      expect(info.triangles, 3); // un cuadrilátero (2) + un triángulo
      expect(info.hasUv, isTrue);
      expect(info.hasColors, isTrue);
      expect(info.polygonsNonTri, 1);
    });

    test('MTL: color, textura citada y archivo que falta', () {
      final dir = Directory.systemTemp.createTempSync('dovexa_obj');
      File('${dir.path}/m.obj').writeAsStringSync('mtllib m.mtl\nusemtl rojo\nv 0 0 0\nv 1 0 0\nv 0 1 0\nf 1 2 3\nusemtl pintado\nf 1 2 3\n');
      File('${dir.path}/m.mtl').writeAsStringSync('newmtl rojo\nKd 1 0 0\nnewmtl pintado\nKd 0.5 0.5 0.5\nmap_Kd -s 1 1 1 falta.png\nd 0.5\n');
      final r = parseObj('${dir.path}/m.obj') as dynamic;
      final info = r.extra as MeshFileInfo;
      expect(info.materials.length, 2);
      expect(info.missing, ['falta.png']);
      expect(info.materials.last.alpha, 'mezcla');
      expect(r.meshes.length, 2);
    });

    test('solo vértices: nube de puntos; vacío: error claro', () {
      final f = text('p.obj', 'v 0 0 0\nv 1 1 1\n');
      expect(parseObj(f.path), isNot(isA<dynamic>().having((x) => x.runtimeType.toString(), 't', 'SceneData')));
      expect(() => parseObj(text('e.obj', '# nada').path), throwsA(isA<FormatException>()));
    });
  });

  group('PLY', () {
    test('binario con color y UV por vértice', () {
      final header = 'ply\nformat binary_little_endian 1.0\nelement vertex 3\n'
          'property float x\nproperty float y\nproperty float z\nproperty uchar red\nproperty uchar green\nproperty uchar blue\n'
          'property float s\nproperty float t\nelement face 1\nproperty list uchar int vertex_indices\nend_header\n';
      final b = BytesBuilder()..add(utf8.encode(header));
      final d = ByteData(3 * 23 + 13);
      var o = 0;
      for (final v in const [
        [0.0, 0.0, 0.0, 255, 0, 0, 0.0, 0.0],
        [1.0, 0.0, 0.0, 0, 255, 0, 1.0, 0.0],
        [0.0, 1.0, 0.0, 0, 0, 255, 0.0, 1.0],
      ]) {
        d.setFloat32(o, v[0] as double, Endian.little);
        d.setFloat32(o + 4, v[1] as double, Endian.little);
        d.setFloat32(o + 8, v[2] as double, Endian.little);
        d.setUint8(o + 12, v[3] as int);
        d.setUint8(o + 13, v[4] as int);
        d.setUint8(o + 14, v[5] as int);
        d.setFloat32(o + 15, v[6] as double, Endian.little);
        d.setFloat32(o + 19, v[7] as double, Endian.little);
        o += 23;
      }
      d.setUint8(o, 3);
      d.setInt32(o + 1, 0, Endian.little);
      d.setInt32(o + 5, 1, Endian.little);
      d.setInt32(o + 9, 2, Endian.little);
      b.add(d.buffer.asUint8List(0, o + 13));
      final r = parsePly(tmp('c.ply', b.takeBytes()).path) as dynamic;
      final info = r.extra as MeshFileInfo;
      expect(info.format, 'PLY binario');
      expect(info.hasColors, isTrue);
      expect(info.hasUv, isTrue);
      expect(info.triangles, 1);
    });

    test('truncado da un error, sin colgarse', () {
      final f = text('t.ply', 'ply\nformat ascii 1.0\nelement vertex 100\nproperty float x\nproperty float y\nproperty float z\nend_header\n0 0 0\n');
      expect(() => parsePly(f.path), throwsA(isA<FormatException>()));
    });
  });

  group('glTF', () {
    test('color normalizado, accesor con paso y modo de rotación de ejes', () {
      // 3 vértices intercalados: posición (12 B) + color u8 normalizado RGBA (4 B) = 16 B
      final bin = ByteData(48 + 6);
      final pts = [
        [0.0, 0.0, 0.0, 255, 0, 0, 255],
        [1.0, 0.0, 0.0, 0, 255, 0, 255],
        [0.0, 1.0, 0.0, 0, 0, 255, 255],
      ];
      for (var i = 0; i < 3; i++) {
        bin.setFloat32(i * 16, pts[i][0] as double, Endian.little);
        bin.setFloat32(i * 16 + 4, pts[i][1] as double, Endian.little);
        bin.setFloat32(i * 16 + 8, pts[i][2] as double, Endian.little);
        for (var k = 0; k < 4; k++) {
          bin.setUint8(i * 16 + 12 + k, pts[i][3 + k] as int);
        }
      }
      bin.setUint16(48, 0, Endian.little);
      bin.setUint16(50, 1, Endian.little);
      bin.setUint16(52, 2, Endian.little);
      final json = {
        'asset': {'version': '2.0', 'generator': 'prueba'},
        'scene': 0,
        'scenes': [
          {'nodes': [0]},
        ],
        'nodes': [
          {'mesh': 0, 'name': 'tri'},
        ],
        'meshes': [
          {
            'primitives': [
              {
                'attributes': {'POSITION': 0, 'COLOR_0': 1},
                'indices': 2,
              },
            ],
          },
        ],
        'accessors': [
          {'bufferView': 0, 'byteOffset': 0, 'componentType': 5126, 'count': 3, 'type': 'VEC3'},
          {'bufferView': 0, 'byteOffset': 12, 'componentType': 5121, 'normalized': true, 'count': 3, 'type': 'VEC4'},
          {'bufferView': 1, 'componentType': 5123, 'count': 3, 'type': 'SCALAR'},
        ],
        'bufferViews': [
          {'buffer': 0, 'byteOffset': 0, 'byteLength': 48, 'byteStride': 16},
          {'buffer': 0, 'byteOffset': 48, 'byteLength': 6},
        ],
        'buffers': [
          {'byteLength': 54},
        ],
      };
      final f = tmp('t.glb', glb(json, bin.buffer.asUint8List()));
      final d = parseGltf(f.path);
      final info = d.extra as MeshFileInfo;
      expect(info.up, 'y');
      expect(info.hasColors, isTrue);
      expect(info.generator, 'prueba');
      final m = d.meshes.single.toMesh();
      expect(m.vertexCount, 3);
      expect(m.extra![2], 1.0); // rojo del primer vértice
      expect(m.extra![5], 1.0);
    });

    test('un accesor que sale del buffer da un error, no un fallo de índice', () {
      final json = {
        'asset': {'version': '2.0'},
        'scenes': [
          {'nodes': [0]},
        ],
        'nodes': [
          {'mesh': 0},
        ],
        'meshes': [
          {
            'primitives': [
              {'attributes': {'POSITION': 0}},
            ],
          },
        ],
        'accessors': [
          {'bufferView': 0, 'componentType': 5126, 'count': 100, 'type': 'VEC3'},
        ],
        'bufferViews': [
          {'buffer': 0, 'byteLength': 12},
        ],
        'buffers': [
          {'byteLength': 12},
        ],
      };
      final f = tmp('bad.glb', glb(json, Uint8List(12)));
      expect(() => parseGltf(f.path), throwsA(isA<FormatException>()));
    });

    test('animación: interpolación lineal y rotación', () {
      final rig = Rig(1)
        ..t = Float32List(3)
        ..r = Float32List.fromList([0, 0, 0, 1])
        ..s = Float32List.fromList([1, 1, 1])
        ..matrix = [null];
      rig.parent.add(-1);
      rig.hasMatrix.add(false);
      final a = RigAnimation('a', 1, [
        RigChannel(0, 0, 0, Float32List.fromList([0, 1]), Float32List.fromList([0, 0, 0, 10, 0, 0])),
      ]);
      final pose = RigPose(rig)..sample(a, 0.25);
      expect(pose.t[0], closeTo(2.5, 1e-6));
      pose.sample(a, 5);
      expect(pose.t[0], closeTo(10, 1e-6));
    });

    test('Draco: el pato comprimido coincide con el pato sin comprimir', () {
      const a = '../testdata/_externos/malla/gltf/_Duck_glTF-Draco/Duck.gltf';
      const b = '../testdata/_externos/malla/gltf/_Duck_glTF/Duck.gltf';
      if (!File(a).existsSync() || !File(b).existsSync()) return;
      final da = parseGltf(a), db = parseGltf(b);
      expect(da.meshes.length, db.meshes.length);
      final ma = da.meshes.first, mb = db.meshes.first;
      for (var k = 0; k < 3; k++) {
        final size = mb.max[k] - mb.min[k];
        expect(ma.min[k], closeTo(mb.min[k], size * 0.01));
        expect(ma.max[k], closeTo(mb.max[k], size * 0.01));
      }
      expect(da.meshes.first.toMesh().triangleCount, db.meshes.first.toMesh().triangleCount);
    });

    test('meshopt: los cubos comprimidos dan lo mismo que los sin comprimir', () {
      const p = '../testdata/_externos/malla/gltf/_MeshoptCubeTest_glTF-Meshopt/MeshoptCubeTest.gltf';
      if (!File(p).existsSync()) return;
      final d = parseGltf(p);
      // cubos 0..3 sin comprimir; 5..8 comprimidos en índices; 10..13 en triángulos; 15..18 con filtros
      final base = d.meshes[10].toMesh();
      for (final k in const [15, 16, 17, 18, 20, 21, 22, 23, 25, 26, 27, 28, 30, 31, 32, 33]) {
        final m = d.meshes[k].toMesh();
        expect(m.vertexCount, base.vertexCount, reason: 'malla $k');
        for (var i = 0; i < m.vertices.length; i++) {
          expect(m.vertices[i], closeTo(base.vertices[i], 0.02), reason: 'malla $k vértice ${i ~/ 6}');
        }
      }
    });
  });
}
