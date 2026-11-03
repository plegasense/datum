// Abre todos los archivos soportados de una carpeta con el cargador universal y resume el resultado.
// Uso: dart run tool/bench_docs.dart <carpeta> [tamañoMaxMB]
import 'dart:io';

import 'package:datum/io/loader.dart';
import 'package:datum/model/document.dart';

Future<void> main(List<String> args) async {
  final dir = Directory(args[0]);
  final maxMb = args.length > 1 ? double.parse(args[1]) : 200.0;
  var ok = 0, fail = 0;
  final files = dir.listSync(recursive: true).whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final f in files) {
    final name = f.path.split('/').last;
    final lower = name.toLowerCase();
    final ext = name.contains('.') ? lower.split('.').last : '';
    if (name.startsWith('.') ||
        !(kSupportedExtensions.contains(ext) || lower.endsWith('.gz')))
      continue;
    final mb = f.lengthSync() / 1048576;
    if (mb > maxMb) continue;
    final sw = Stopwatch()..start();
    try {
      final d = await loadDocument(f.path);
      final what = switch (d) {
        ModelDocument m =>
          '3D  ${m.scene.parts.length} piezas ${m.scene.instances(onlyVisible: false).length} inst ${m.scene.triangleCount} tri',
        DrawingDocument m =>
          '2D  ${m.lines.segmentCount} seg ${m.lines.groups.length} capas',
        ToolpathDocument m =>
          'CAM ${m.toolpath.paths.segmentCount} mov ${m.toolpath.layerCount} capas',
        PointCloudDocument m =>
          'PTS ${m.cloud.count} puntos color=${m.cloud.hasColor}',
      };
      stdout.writeln(
        'OK    ${sw.elapsedMilliseconds.toString().padLeft(6)} ms  ${mb.toStringAsFixed(2).padLeft(7)} MB  $what  $name',
      );
      ok++;
    } catch (e) {
      stdout.writeln('FALLO $name -> ${'$e'.split('\n').first}');
      fail++;
    }
  }
  stdout.writeln('--- $ok correctos, $fail fallos');
  exit(0);
}
