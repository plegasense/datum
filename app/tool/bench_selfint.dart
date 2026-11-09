import 'dart:io';

import 'package:dovexa/io/stl_loader.dart';
import 'package:dovexa/model/thickness.dart';

Future<void> main(List<String> args) async {
  for (final f in args) {
    final m = await loadStl(f);
    final sw = Stopwatch()..start();
    final r = findSelfIntersections(m.vertices);
    stdout.writeln('${f.split('/').last}: ${m.vertices.length ~/ 18} tri · ${sw.elapsedMilliseconds} ms · pares ${r.pairs}${r.truncated ? '+' : ''}');
  }
}
