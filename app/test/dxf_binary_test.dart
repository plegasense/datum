import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:datum/io/dxf_loader.dart';
import 'package:flutter_test/flutter_test.dart';

bool _inR(int c, int a, int z) => c >= a && c <= z;

/// Convierte un DXF de texto en uno binario (R13+, códigos de 2 bytes) para probar el lector.
Uint8List toBinary(String ascii, {bool wide = true}) {
  final lines = const LineSplitter().convert(ascii);
  final out = BytesBuilder();
  out.add(latin1.encode('AutoCAD Binary DXF\r\n'));
  out.addByte(0x1A);
  out.addByte(0);
  for (var i = 0; i + 1 < lines.length; i += 2) {
    final code = int.parse(lines[i].trim());
    final v = lines[i + 1];
    if (wide) {
      out.add(
        Uint8List(2)..buffer.asByteData().setUint16(0, code, Endian.little),
      );
    } else {
      out.addByte(code);
    }
    final b = ByteData(8);
    if (_inR(code, 10, 59) || _inR(code, 110, 149) || _inR(code, 210, 239)) {
      b.setFloat64(0, double.parse(v), Endian.little);
      out.add(b.buffer.asUint8List());
    } else if (_inR(code, 60, 79) ||
        _inR(code, 170, 179) ||
        _inR(code, 270, 289)) {
      b.setInt16(0, int.parse(v.trim()), Endian.little);
      out.add(b.buffer.asUint8List(0, 2));
    } else if (_inR(code, 90, 99)) {
      b.setInt32(0, int.parse(v.trim()), Endian.little);
      out.add(b.buffer.asUint8List(0, 4));
    } else {
      out.add(utf8.encode(v));
      out.addByte(0);
    }
  }
  return out.toBytes();
}

void main() {
  for (final f in [
    'testdata/dxf/corte_conocido.dxf',
    'testdata/dxf/ranura_pulgadas.dxf',
  ]) {
    for (final wide in [true, false]) {
      test('DXF binario (${wide ? 'R13+' : 'R12'}) = texto: $f', () {
        final ascii = File('../$f').readAsStringSync();
        final a = parseDxfBytes(
          Uint8List.fromList(utf8.encode(ascii)),
          'a.dxf',
        ).build();
        final b = parseDxfBytes(toBinary(ascii, wide: wide), 'b.dxf').build();
        expect(b.$1.segmentCount, a.$1.segmentCount);
        expect(b.$1.bounds.size, a.$1.bounds.size);
        expect(
          b.$1.groups.map((g) => g.name).toList(),
          a.$1.groups.map((g) => g.name).toList(),
        );
      });
    }
  }
}
