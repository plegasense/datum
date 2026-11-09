import 'dart:io';
import 'dart:typed_data';

import 'package:dovexa/io/las_loader.dart';
import 'package:dovexa/io/mesh_data_extra.dart';
import 'package:dovexa/model/pointcloud.dart';
import 'package:dovexa/model/lines.dart';
import 'package:dovexa/model/mesh.dart';
import 'package:flutter_test/flutter_test.dart';

/// LAS mínimo: cabecera de 227 bytes, VLR opcionales y [n] puntos del formato dado.
File las(String name, int n, {int fmt = 0, List<List<int>> vlrs = const [], int Function(int)? x, double scale = 0.01, double ox = 0}) {
  final rl = const [20, 28, 26, 34, 57, 63, 30, 36, 38, 59, 67][fmt];
  final vlrBytes = <int>[for (final v in vlrs) ...v];
  final po = 227 + vlrBytes.length;
  final b = BytesBuilder();
  final h = ByteData(227);
  for (var i = 0; i < 4; i++) {
    h.setUint8(i, 'LASF'.codeUnitAt(i));
  }
  h.setUint8(24, 1);
  h.setUint8(25, fmt >= 6 ? 4 : 2);
  h.setUint16(94, 227, Endian.little);
  h.setUint32(96, po, Endian.little);
  h.setUint32(100, vlrs.length, Endian.little);
  h.setUint8(104, fmt);
  h.setUint16(105, rl, Endian.little);
  h.setUint32(107, n, Endian.little);
  for (var k = 0; k < 3; k++) {
    h.setFloat64(131 + 8 * k, scale, Endian.little);
    h.setFloat64(155 + 8 * k, k == 0 ? ox : 0, Endian.little);
  }
  b.add(h.buffer.asUint8List());
  b.add(vlrBytes);
  final d = ByteData(n * rl);
  for (var i = 0; i < n; i++) {
    final o = i * rl;
    d.setInt32(o, x?.call(i) ?? i * 100, Endian.little);
    d.setInt32(o + 4, i * 50, Endian.little);
    d.setInt32(o + 8, i * 10, Endian.little);
    d.setUint16(o + 12, 100 + i, Endian.little);
    if (fmt <= 5) {
      d.setUint8(o + 14, 1 | (2 << 3));
      d.setUint8(o + 15, i.isEven ? 2 : 1);
    } else {
      d.setUint8(o + 14, 1 | (2 << 4));
      d.setUint8(o + 16, i.isEven ? 2 : 6);
    }
    if (fmt == 2) {
      d.setUint16(o + 20, 255, Endian.little);
    }
    if (fmt == 3) {
      d.setUint16(o + 28, 255, Endian.little);
    }
  }
  b.add(d.buffer.asUint8List());
  final f = File('${Directory.systemTemp.path}/dovexa_cloud_$name');
  f.writeAsBytesSync(b.toBytes());
  return f;
}

List<int> vlr(String user, int id, List<int> data) {
  final h = ByteData(54);
  for (var i = 0; i < user.length; i++) {
    h.setUint8(2 + i, user.codeUnitAt(i));
  }
  h.setUint16(18, id, Endian.little);
  h.setUint16(20, data.length, Endian.little);
  return [...h.buffer.asUint8List(), ...data];
}

List<int> geoKeys(Map<int, int> keys) {
  final d = ByteData(8 + 8 * keys.length);
  d.setUint16(0, 1, Endian.little);
  d.setUint16(6, keys.length, Endian.little);
  var k = 0;
  for (final e in keys.entries) {
    d.setUint16(8 + 8 * k, e.key, Endian.little);
    d.setUint16(8 + 8 * k + 6, e.value, Endian.little);
    k++;
  }
  return d.buffer.asUint8List();
}

void main() {
  group('LAS', () {
    test('escala, desplazamiento y clases', () {
      final d = parseLas(las('a.las', 10, fmt: 1, ox: 500000).path);
      expect(d.info.totalPoints, 10);
      expect(d.info.classCounts, {2: 5, 1: 5});
      expect(d.info.minAbs![0], closeTo(500000, 1e-6));
      expect(d.info.maxAbs![0], closeTo(500009, 1e-6));
      // coordenadas de mapa: se guardan relativas al primer punto para no perder precisión
      expect(d.origin[0], closeTo(500000, 1e-6));
      expect(d.verts[6 * 9], closeTo(9, 1e-4));
    });

    test('color de 8 bits dentro de un campo de 16', () {
      final d = parseLas(las('c.las', 4, fmt: 2).path);
      expect(d.hasColor, isTrue);
      expect(d.verts[3], closeTo(1.0, 1e-6));
    });

    test('muestreo uniforme por encima del límite', () {
      final d = parseLas(las('s.las', 5000).path, maxPoints: 1000);
      expect(d.info.shownPoints, lessThanOrEqualTo(1100));
      expect(d.info.shownPoints, greaterThan(800));
      expect(d.info.totalPoints, 5000);
      expect(d.info.warnings.any((w) => w.contains('una de cada')), isTrue);
    });

    test('sistema geográfico y proyectado por GeoKeys', () {
      final g = parseLas(las('g.las', 3, vlrs: [vlr('LASF_Projection', 34735, geoKeys({1024: 2, 2048: 4326}))]).path);
      expect(g.info.geographic, isTrue);
      expect(g.info.unit, '°');
      final p = parseLas(las('p.las', 3, vlrs: [vlr('LASF_Projection', 34735, geoKeys({1024: 1, 3072: 25830}))]).path);
      expect(p.info.geographic, isFalse);
      expect(p.info.crs, contains('UTM zona 30'));
      expect(p.info.unit, 'm');
      final ft = parseLas(las('f.las', 3, vlrs: [vlr('LASF_Projection', 34735, geoKeys({1024: 1, 3072: 2263, 3076: 9003}))]).path);
      expect(ft.info.unit, 'ft EE. UU.');
    });

    test('cabecera mentirosa: cuenta de más y archivo cortado', () {
      final f = las('t.las', 10);
      final b = f.readAsBytesSync();
      f.writeAsBytesSync(b.sublist(0, b.length - 20 * 3)); // faltan 3 puntos
      final d = parseLas(f.path);
      expect(d.info.shownPoints, 7);
      expect(d.info.warnings.any((w) => w.contains('cortado')), isTrue);
    });

    test('errores limpios', () {
      final corto = File('${Directory.systemTemp.path}/dovexa_cloud_nada.las')..writeAsBytesSync([1, 2, 3]);
      expect(() => parseLas(corto.path), throwsFormatException);
      final f = File('${Directory.systemTemp.path}/dovexa_cloud_x.las')..writeAsBytesSync(List.filled(300, 0));
      expect(() => parseLas(f.path), throwsFormatException);
    });
  });

  group('PointCloud', () {
    PointCloud make() {
      const n = 6;
      final v = Float32List(n * 6);
      for (var i = 0; i < n; i++) {
        v[i * 6] = i.toDouble();
        v[i * 6 + 2] = i.toDouble();
      }
      final set = LineSet(vertices: v, bounds: Bounds([0, 0, 0], [5, 0, 5]));
      return PointCloud(
        name: 't',
        points: set,
        hasColor: false,
        attrs: CloudAttrs(cls: Uint8List.fromList([2, 2, 6, 6, 1, 1])),
      );
    }

    test('ocultar clase y recortar por altura', () {
      final c = make();
      expect(c.count, 6);
      c.toggleClass(6);
      expect(c.count, 4);
      c.setClip(1, 4);
      expect(c.count, 2); // z 1 (clase 2) y z 4 (clase 1)
      c.showAll();
      expect(c.count, 6);
    });

    test('color por clasificación usa la paleta ASPRS', () {
      final c = make()..recolor(CloudColorMode.classification);
      final v = c.points.vertices;
      expect(v[3], isNot(v[2 * 6 + 3])); // suelo ≠ edificio
    });
  });

  test('PointBuilder resta el origen en coordenadas de mapa', () {
    final pb = PointBuilder();
    pb.add(430000.5, 4500000.25, 12);
    pb.add(430010.5, 4500010.25, 13);
    final d = pb.build('x');
    expect(d.origin[0], 430000.5);
    expect(d.verts[6], closeTo(10, 1e-6));
  });
}
