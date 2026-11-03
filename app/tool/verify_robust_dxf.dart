// DXF rotos o raros: no debe haber cierres inesperados, solo un mensaje claro o una apertura parcial.
//   dart run tool/verify_robust_dxf.dart ../testdata/dxf/corte_conocido.dxf
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:datum/io/loader.dart';
import 'package:datum/model/document.dart';

Future<void> main(List<String> a) async {
  final src = File(a.first).readAsBytesSync();
  final dir = Directory.systemTemp.createTempSync('datum_robust_dxf');
  final cases = <String, Uint8List>{
    'vacío': Uint8List(0),
    'texto suelto': Uint8List.fromList('esto no es un DXF\n'.codeUnits),
    'mitad del archivo': Uint8List.sublistView(src, 0, src.length ~/ 2),
    'diez por ciento': Uint8List.sublistView(src, 0, src.length ~/ 10),
    'DXF binario': Uint8List.fromList(
      'AutoCAD Binary DXF\r\n\x1a\x00${'x' * 200}'.codeUnits,
    ),
    'binario aleatorio': Uint8List.fromList(
      List.generate(20000, (i) => math.Random(i).nextInt(256)),
    ),
    'bytes corruptos': () {
      final b = Uint8List.fromList(src);
      final r = math.Random(3);
      for (var i = 0; i < 80; i++) {
        b[r.nextInt(b.length)] = r.nextInt(256);
      }
      return b;
    }(),
    'línea de 3 MB': Uint8List.fromList(
      ('0\nSECTION\n2\nENTITIES\n0\nTEXT\n1\n${'X' * 3000000}\n0\nENDSEC\n0\nEOF\n')
          .codeUnits,
    ),
    'coordenadas enormes': Uint8List.fromList(
      '0\nSECTION\n2\nENTITIES\n0\nLINE\n8\n0\n10\n1e300\n20\n-1e300\n11\n5\n21\n5\n0\nENDSEC\n0\nEOF\n'
          .codeUnits,
    ),
  };
  for (final e in cases.entries) {
    final f = File('${dir.path}/caso.dxf')..writeAsBytesSync(e.value);
    final sw = Stopwatch()..start();
    try {
      final d = await loadDocument(f.path) as DrawingDocument;
      stdout.writeln(
        'OK     ${e.key}: abrió (${d.lines.segmentCount} segmentos) en ${sw.elapsedMilliseconds} ms',
      );
    } catch (err) {
      stdout.writeln(
        'ERROR  ${e.key}: "${err.toString().replaceAll('Exception: ', '')}" en ${sw.elapsedMilliseconds} ms',
      );
    }
  }
  dir.deleteSync(recursive: true);
  stdout.writeln('--- ${cases.length} casos sin cierre inesperado');
}
