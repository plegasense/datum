import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dovexa/io/mesh_data.dart';
import 'package:dovexa/io/vrml_loader.dart';
import 'package:dovexa/io/vrml_parse.dart';
import 'package:dovexa/model/mesh_info.dart';
import 'package:dovexa/model/rig.dart';
import 'package:flutter_test/flutter_test.dart';

File wrl(String name, String body, {String header = '#VRML V2.0 utf8'}) {
  final f = File('${Directory.systemTemp.path}/dovexa_vrml_$name');
  f.writeAsStringSync('$header\n$body');
  return f;
}

/// Volumen con signo (teorema de la divergencia): positivo si las caras miran hacia fuera.
double volume(SceneData d) {
  var v = 0.0;
  for (final m in d.meshes) {
    final mesh = m.toMesh();
    final vs = mesh.vertices, ix = mesh.indices!;
    for (var i = 0; i + 2 < ix.length; i += 3) {
      final a = ix[i] * 6, b = ix[i + 1] * 6, c = ix[i + 2] * 6;
      v += (vs[a] * (vs[b + 1] * vs[c + 2] - vs[b + 2] * vs[c + 1]) -
              vs[a + 1] * (vs[b] * vs[c + 2] - vs[b + 2] * vs[c]) +
              vs[a + 2] * (vs[b] * vs[c + 1] - vs[b + 1] * vs[c])) /
          6;
    }
  }
  return v;
}

SceneData read(String name, String body, {String header = '#VRML V2.0 utf8'}) => parseVrml(wrl(name, body, header: header).path);

void main() {
  test('lector de números rápido coincide con double.parse', () {
    final samples = ['0', '1', '-1', '+2.5', '.5', '-.5', '3.', '1e3', '1E-3', '-2.5e+2', '0.000123', '123456789.123456789', '1e22', '1e-22', '9007199254740993', '0.1', '12345678901234567890', '1e308', '-0.0'];
    final src = samples.join(' ');
    final t = VTokens(src);
    for (var i = 0; i < samples.length; i++) {
      final a = t.num(i), b = double.tryParse(samples[i]);
      expect(a, isNotNull, reason: samples[i]);
      expect(a!, closeTo(b!, b.abs() * 1e-12 + 1e-300), reason: samples[i]);
    }
    expect(VTokens('abc DEF {').num(0), isNull);
  });

  group('primitivas', () {
    test('Box, Cylinder, Cone y Sphere tienen el volumen que toca y caras hacia fuera', () {
      expect(volume(read('box', 'Shape { geometry Box { size 2 3 4 } }')), closeTo(24, 1e-3));
      expect(volume(read('cyl', 'Shape { geometry Cylinder { radius 1 height 2 } }')), closeTo(6.28, 0.15));
      expect(volume(read('cone', 'Shape { geometry Cone { bottomRadius 1 height 2 } }')), closeTo(2.09, 0.1));
      expect(volume(read('sph', 'Shape { geometry Sphere { radius 1 } }')), closeTo(4.19, 0.2));
    });

    test('Extrusion: sección cuadrada recta con tapas', () {
      final d = read('ext', 'Shape { geometry Extrusion { crossSection [1 1, 1 -1, -1 -1, -1 1, 1 1] spine [0 0 0, 0 1 0] } }');
      expect(volume(d), closeTo(4, 1e-3));
    });

    test('Extrusion con espina curva y escala', () {
      final d = read(
        'ext2',
        'Shape { geometry Extrusion { crossSection [1 1, 1 -1, -1 -1, -1 1, 1 1] spine [0 0 0, 0 2 0, 1 4 0] scale [1 1, 1 1, 0.5 0.5] } }',
      );
      expect(volume(d), greaterThan(0));
    });

    test('ElevationGrid: dimensiones por la norma (puntos, no celdas)', () {
      final d = read('eg', 'Shape { geometry ElevationGrid { xDimension 5 zDimension 6 xSpacing 0.5 zSpacing 0.25 height [${List.filled(30, 0).join(' ')}] } }');
      final m = d.meshes.first;
      expect(m.max[0], closeTo(2.0, 1e-5));
      expect(m.max[2], closeTo(1.25, 1e-5));
    });
  });

  group('IndexedFaceSet', () {
    const cube =
        'Shape { geometry IndexedFaceSet { coord Coordinate { point [0 0 0, 1 0 0, 1 1 0, 0 1 0, 0 0 1, 1 0 1, 1 1 1, 0 1 1] } '
        'coordIndex [0 3 2 1 -1, 4 5 6 7 -1, 0 1 5 4 -1, 3 7 6 2 -1, 0 4 7 3 -1, 1 2 6 5 -1] %s } }';

    test('cubo por caras con ccw por defecto', () {
      expect(volume(read('cube', cube.replaceAll('%s', ''))), closeTo(1, 1e-4));
      expect(volume(read('cube2', cube.replaceAll('%s', 'ccw FALSE'))), closeTo(-1, 1e-4));
    });

    test('índices fuera de rango se omiten y se avisan', () {
      final d = read('bad', 'Shape { geometry IndexedFaceSet { coord Coordinate { point [0 0 0, 1 0 0, 0 1 0] } coordIndex [0 1 2 -1, 0 1 9 -1] } }');
      expect(d.meshes.length, 1);
      expect((d.extra as MeshFileInfo).warnings.any((w) => w.contains('índices')), isTrue);
    });

    test('color por vértice y por cara', () {
      final pv = read(
        'col',
        'Shape { geometry IndexedFaceSet { coord Coordinate { point [0 0 0, 1 0 0, 0 1 0] } coordIndex [0 1 2 -1] color Color { color [1 0 0, 0 1 0, 0 0 1] } } }',
      );
      expect((pv.extra as MeshFileInfo).hasColors, isTrue);
      final pf = read(
        'colf',
        'Shape { geometry IndexedFaceSet { coord Coordinate { point [0 0 0, 1 0 0, 0 1 0] } coordIndex [0 1 2 -1] colorPerVertex FALSE color Color { color [1 0 0] } } }',
      );
      expect((pf.extra as MeshFileInfo).hasColors, isTrue);
    });
  });

  group('estructura', () {
    test('DEF/USE reutiliza la malla y Transform la coloca', () {
      final d = read(
        'use',
        'DEF A Transform { translation 5 0 0 children Shape { geometry Box { size 1 1 1 } } } Transform { translation -5 0 0 children USE A }',
      );
      expect(d.nodes.where((n) => n.part >= 0).length, 2);
      expect(d.meshes.length, 1); // la geometría se comparte
    });

    test('PROTO con campo por defecto', () {
      final d = read(
        'proto',
        'PROTO Cubo [ field SFVec3f lado 2 2 2 ] { Shape { geometry Box { size IS lado } } }\nCubo { lado 3 3 3 }',
      );
      expect(d.meshes.first.max[0], closeTo(1.5, 1e-5));
    });

    test('Switch sólo dibuja la opción elegida', () {
      final d = read('sw', 'Switch { whichChoice 1 choice [ Shape { geometry Box {} } Shape { geometry Sphere {} } ] }');
      expect(d.meshes.length, 1);
    });

    test('VRML 1.0: Separator, Transform y Material', () {
      final d = read(
        'v1',
        'Separator { Material { diffuseColor 1 0 0 } Transform { translation 2 0 0 } Cube { width 1 height 1 depth 1 } }',
        header: '#VRML V1.0 ascii',
      );
      expect((d.extra as MeshFileInfo).format, 'VRML 1.0');
      expect(d.materials.length, 1);
      expect(d.nodes.last.matrix[12], closeTo(2, 1e-9));
    });

    test('X3D en XML', () {
      final f = File('${Directory.systemTemp.path}/dovexa_vrml_x.x3d')
        ..writeAsStringSync('<?xml version="1.0"?><X3D version="3.3"><Scene><Transform translation="1 2 3"><Shape><Appearance><Material diffuseColor="1 0 0" transparency="0.5"/></Appearance><Box size="2 2 2"/></Shape></Transform></Scene></X3D>');
      final d = parseVrml(f.path);
      expect((d.extra as MeshFileInfo).format, 'X3D (XML)');
      expect(d.materials.first.baseColor >> 24, closeTo(128, 1));
      expect(d.nodes.last.matrix[13], 0);
    });

    test('.wrz comprimido', () {
      final f = File('${Directory.systemTemp.path}/dovexa_vrml_z.wrz')
        ..writeAsBytesSync(gzip.encode(utf8.encode('#VRML V2.0 utf8\nShape { geometry Box {} }')));
      expect(parseVrml(f.path).meshes.length, 1);
    });

    test('errores limpios', () {
      expect(() => read('vacio', ''), throwsFormatException);
      expect(() => read('mal', 'Shape { geometry Box { size [ 1 2 }'), throwsFormatException);
    });
  });

  group('animación', () {
    const base = 'DEF T Transform { center 0 0 0 children Shape { geometry Box {} } }\n'
        'DEF TS TimeSensor { cycleInterval 4 loop TRUE }\n';

    test('PositionInterpolator encaminado a un Transform', () {
      final d = read(
        'anim1',
        '${base}DEF P PositionInterpolator { key [0 1] keyValue [0 0 0, 10 0 0] }\n'
        'ROUTE TS.fraction_changed TO P.set_fraction\nROUTE P.value_changed TO T.set_translation',
      );
      final rig = (d.extra as MeshFileInfo).rig as Rig;
      expect(rig.animations.length, 1);
      expect(rig.animations.first.duration, 4);
      final node = d.nodes.indexWhere((n) => n.name == 'T');
      final pose = RigPose(rig)..sample(rig.animations.first, 2);
      expect(pose.t[node * 3], closeTo(5, 1e-4));
    });

    test('OrientationInterpolator con centro de giro', () {
      final d = read(
        'anim2',
        'DEF T Transform { center 1 0 0 children Shape { geometry Box {} } }\n'
        'DEF TS TimeSensor { cycleInterval 2 }\n'
        'DEF O OrientationInterpolator { key [0 1] keyValue [0 0 1 0, 0 0 1 3.14159265] }\n'
        'ROUTE TS.fraction_changed TO O.set_fraction\nROUTE O.value_changed TO T.set_rotation',
      );
      final rig = (d.extra as MeshFileInfo).rig as Rig;
      final node = d.nodes.indexWhere((n) => n.name == 'T');
      final pose = RigPose(rig)..sample(rig.animations.first, 2);
      final m = Float64List(16);
      pose.local(node, m);
      // media vuelta alrededor de (1,0,0): el origen pasa a (2,0,0)
      expect(m[12], closeTo(2, 1e-3));
    });

    test('sin rutas no hay animación y se avisa', () {
      final d = read('anim3', '${base}DEF P PositionInterpolator { key [0 1] keyValue [0 0 0, 1 0 0] }');
      expect((d.extra as MeshFileInfo).rig, isNull);
    });
  });

  test('textura de píxeles se codifica como PNG válido', () {
    final d = read(
      'pix',
      'Shape { appearance Appearance { texture PixelTexture { image 2 2 3 0xFF0000 0x00FF00 0x0000FF 0xFFFFFF } } geometry Box {} }',
    );
    expect(d.textures.length, 1);
    final png = d.textures.first.encoded;
    expect(png.sublist(0, 8), Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]));
  });
}
