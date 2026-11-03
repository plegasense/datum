// Prueba de carga masiva: abre todos los archivos de una carpeta y resume el resultado.
// Uso: dart run tool/bench_load.dart <carpeta> [extensiones separadas por coma] [tamañoMaxMB]
import 'dart:io';

import 'package:datum/io/loader.dart';

Future<void> main(List<String> args) async {
  final dir = Directory(args[0]);
  final exts = (args.length > 1 ? args[1] : 'stl,obj,3mf').split(',');
  final maxMb = args.length > 2 ? double.parse(args[2]) : 200.0;
  var ok = 0, fail = 0;
  final failures = <String>[];
  for (final f in dir.listSync(recursive: true).whereType<File>()) {
    final name = f.path.split('/').last;
    if (name.startsWith('.')) continue;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    if (!exts.contains(ext)) continue;
    final mb = f.lengthSync() / 1048576;
    if (mb > maxMb) {
      print('OMITIDO ${mb.toStringAsFixed(0)} MB  $name');
      continue;
    }
    final sw = Stopwatch()..start();
    try {
      final s = await loadScene(f.path);
      final b = s.bounds().size;
      print(
        'OK  ${sw.elapsedMilliseconds.toString().padLeft(6)} ms  ${mb.toStringAsFixed(1).padLeft(6)} MB  '
        '${s.parts.length} piezas ${s.instances(onlyVisible: false).length} inst ${s.triangleCount} tri  '
        '${b[0].toStringAsFixed(1)}x${b[1].toStringAsFixed(1)}x${b[2].toStringAsFixed(1)}  $name',
      );
      ok++;
    } catch (e) {
      print('FALLO  $name -> ${'$e'.split('\n').first}');
      failures.add(name);
      fail++;
    }
  }
  print('--- $ok correctos, $fail fallos');
}
