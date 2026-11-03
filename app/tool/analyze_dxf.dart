// Analiza en lote DXF reales: tiempos y resultados del análisis de corte.
//   dart run tool/analyze_dxf.dart "<carpeta>"
import 'dart:io';

import 'package:datum/io/loader.dart';
import 'package:datum/model/document.dart';
import 'package:datum/model/drawing_stats.dart';
import 'package:datum/model/shapes.dart';

Future<void> main(List<String> args) async {
  final files = [
    for (final f in Directory(args.first).listSync(recursive: true))
      if (f is File && f.path.toLowerCase().endsWith('.dxf')) f,
  ]..sort((a, b) => a.lengthSync().compareTo(b.lengthSync()));
  var ok = 0, bad = 0;
  for (final f in files) {
    final name = f.path.split('/').last;
    final sw = Stopwatch()..start();
    try {
      final d = await loadDocument(f.path) as DrawingDocument;
      final tLoad = sw.elapsedMilliseconds;
      sw.reset();
      final shapes = buildShapes(d.lines);
      final a = analyzeDrawing(shapes, d.lines);
      final inc = {
        for (final g in d.lines.groups)
          if (isCutLayer(g.name)) g.name,
      };
      final t = a.totals(inc, d.lines.groups);
      stdout.writeln(
        'OK ${(f.lengthSync() / 1000).toStringAsFixed(0).padLeft(6)} KB  carga ${tLoad.toString().padLeft(5)} ms  análisis ${sw.elapsedMilliseconds.toString().padLeft(5)} ms  '
        'seg ${d.lines.segmentCount.toString().padLeft(7)}  capas ${d.lines.groups.length.toString().padLeft(3)}  unidad ${d.insUnits}  '
        'piezas ${t.$1}  agujeros ${t.$2}  abiertos ${t.$3}  corte ${t.$4.toStringAsFixed(1)}  avisos ${a.problems.length}  $name',
      );
      ok++;
    } catch (e) {
      stdout.writeln('FALLO $name -> ${e.toString().split('\n').first}');
      bad++;
    }
  }
  stdout.writeln('--- $ok correctos, $bad fallos');
}
