// Archivos rotos o raros: no debe haber cierres inesperados, solo un mensaje claro.
//   dart run tool/verify_robust.dart ../testdata/step/placa_agujeros.step
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dovexa/io/loader.dart';

Future<void> main(List<String> a) async {
  final src = File(a.first).readAsBytesSync();
  final dir = Directory.systemTemp.createTempSync('dovexa_robust');
  final cases = <String, Uint8List>{
    'vacío': Uint8List(0),
    'texto suelto': Uint8List.fromList('esto no es un STEP\n'.codeUnits),
    'mitad del archivo': Uint8List.sublistView(src, 0, src.length ~/ 2),
    'solo cabecera': Uint8List.sublistView(src, 0, 600),
    'diez por ciento': Uint8List.sublistView(src, 0, src.length ~/ 10),
    'binario aleatorio': Uint8List.fromList(
      List.generate(20000, (i) => math.Random(i).nextInt(256)),
    ),
    'bytes corruptos': () {
      final b = Uint8List.fromList(src);
      final r = math.Random(7);
      for (var i = 0; i < 400; i++) {
        b[r.nextInt(b.length)] = r.nextInt(256);
      }
      return b;
    }(),
    'sin datos (solo DATA vacío)': Uint8List.fromList(
      'ISO-10303-21;\nHEADER;\nENDSEC;\nDATA;\nENDSEC;\nEND-ISO-10303-21;\n'
          .codeUnits,
    ),
    'línea gigante': Uint8List.fromList(
      ('ISO-10303-21;\nHEADER;\nENDSEC;\nDATA;\n#1=${'X' * 2000000};\nENDSEC;\nEND-ISO-10303-21;\n')
          .codeUnits,
    ),
  };
  var ok = 0, bad = 0;
  for (final e in cases.entries) {
    final f = File('${dir.path}/caso.step')..writeAsBytesSync(e.value);
    final sw = Stopwatch()..start();
    try {
      final s = await loadScene(f.path);
      stdout.writeln(
        'OK     ${e.key}: abrió (${s.parts.length} piezas) en ${sw.elapsedMilliseconds} ms',
      );
      s.dispose();
      ok++;
    } catch (err) {
      final msg = err.toString().replaceAll('Exception: ', '');
      stdout.writeln('ERROR  ${e.key}: "$msg" en ${sw.elapsedMilliseconds} ms');
      // Un error con mensaje es correcto; lo que no puede pasar es un cierre inesperado.
      ok++;
    }
  }
  dir.deleteSync(recursive: true);
  stdout.writeln('--- ${cases.length} casos sin cierre inesperado ($ok)');
  exit(bad == 0 ? 0 : 1);
}
