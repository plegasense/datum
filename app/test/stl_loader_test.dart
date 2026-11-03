import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:datum/io/stl_loader.dart';
import 'package:flutter_test/flutter_test.dart';

String ascii(String solid, {bool upper = false, String lead = ''}) {
  final b = StringBuffer('$lead$solid cubo\n');
  void facet(List<List<double>> p) {
    b.write('facet normal 0 0 1\nouter loop\n');
    for (final v in p) {
      b.write('vertex ${v[0]} ${v[1]} ${v[2]}\n');
    }
    b.write('endloop\nendfacet\n');
  }

  facet([
    [0, 0, 0],
    [1, 0, 0],
    [0, 1, 0],
  ]);
  b.write('endsolid cubo\n');
  var s = b.toString();
  if (upper) s = s.toUpperCase();
  return s;
}

Future<File> tmp(String name, List<int> bytes) async {
  final f = File('${Directory.systemTemp.path}/datum_stl_$name');
  f.writeAsBytesSync(bytes);
  return f;
}

Uint8List binaryOne({String header = 'solid exportado', bool nan = false}) {
  final b = BytesBuilder();
  final h = Uint8List(80)..setAll(0, utf8.encode(header));
  b.add(h);
  b.add(Uint8List(4)..buffer.asByteData().setUint32(0, 2, Endian.little));
  for (var t = 0; t < 2; t++) {
    final d = ByteData(50);
    final f = [
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      nan && t == 1 ? double.nan : 0.0,
    ];
    for (var i = 0; i < 12; i++) {
      d.setFloat32(i * 4, f[i].toDouble(), Endian.little);
    }
    b.add(d.buffer.asUint8List());
  }
  return b.toBytes();
}

void main() {
  test('ASCII en mayúsculas y con espacio delante', () async {
    final f = await tmp(
      'up.stl',
      utf8.encode(ascii('solid', upper: true, lead: '  ')),
    );
    final m = await loadStl(f.path);
    expect(m.triangleCount, 1);
    expect(stlMetaOf[m]!.binary, isFalse);
  });

  test(
    'binario cuya cabecera empieza por «solid» no se confunde con ASCII',
    () async {
      final f = await tmp('bin.stl', binaryOne());
      final m = await loadStl(f.path);
      expect(m.triangleCount, 2);
      expect(stlMetaOf[m]!.binary, isTrue);
    },
  );

  test('coordenadas no finitas se descartan', () async {
    final f = await tmp('nan.stl', binaryOne(nan: true));
    final m = await loadStl(f.path);
    expect(m.triangleCount, 1);
    expect(stlMetaOf[m]!.skipped, 1);
  });

  test('archivo vacío da un mensaje claro', () async {
    final f = await tmp('empty.stl', Uint8List(0));
    expect(
      () => loadStl(f.path),
      throwsA(predicate((e) => e.toString().contains('STL'))),
    );
  });
}
