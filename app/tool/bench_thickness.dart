import 'dart:io';

import 'package:dovexa/io/stl_loader.dart';
import 'package:dovexa/model/thickness.dart';

Future<void> main(List<String> args) async {
  for (final f in args) {
    final m = await loadStl(f);
    final sw = Stopwatch()..start();
    final r = computeThickness(m.vertices);
    final vals = r.perTriangle.where((e) => e.isFinite).toList()..sort();
    String q(double p) => vals.isEmpty ? '-' : vals[((vals.length - 1) * p).round()].toStringAsFixed(3);
    stdout.writeln('${f.split('/').last}: ${m.vertices.length ~/ 18} tri · ${sw.elapsedMilliseconds} ms · mín ${r.minThickness.toStringAsFixed(4)} · p1 ${q(0.01)} · p5 ${q(0.05)} · mediana ${q(0.5)} · con pared ${vals.length}');
  }
}
