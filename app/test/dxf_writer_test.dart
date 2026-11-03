import 'dart:convert';
import 'dart:typed_data';

import 'package:datum/io/dxf_loader.dart';
import 'package:datum/io/dxf_writer.dart';
import 'package:datum/model/document.dart';
import 'package:flutter_test/flutter_test.dart';

DrawingDocument open(String dxf) {
  final (l, t) = parseDxfBytes(Uint8List.fromList(utf8.encode(dxf)), 't.dxf').build();
  return DrawingDocument('t', l, t);
}

void main() {
  test('DXF: exportar y volver a abrir conserva capas, longitud y textos', () {
    const src = '0\nSECTION\n2\nENTITIES\n'
        '0\nLINE\n8\nCORTE\n10\n0\n20\n0\n11\n100\n21\n0\n'
        '0\nCIRCLE\n8\nCORTE\n10\n50\n20\n50\n40\n10\n'
        '0\nARC\n8\nGRABADO\n10\n0\n20\n0\n40\n20\n50\n0\n51\n90\n'
        '0\nTEXT\n8\nGRABADO\n10\n5\n20\n5\n40\n3\n1\nHola\n'
        '0\nENDSEC\n0\nEOF\n';
    final a = open(src);
    final back = open(utf8.decode(writeDxf(a)));
    expect(back.texts.single.text, 'Hola');
    expect(back.lines.groups.map((g) => g.name).toSet(), {'CORTE', 'GRABADO'});
    expect(back.lines.segmentCount, closeTo(a.lines.segmentCount, a.lines.segmentCount * 0.1));
    final only = open(utf8.decode(writeDxf(a, layers: {'CORTE'})));
    expect(only.lines.groups.map((g) => g.name).toSet(), {'CORTE'});
  });
}
