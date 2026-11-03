import 'dart:io';
import 'dart:math' as math;

import 'package:datum/io/dxf_loader.dart';
import 'package:datum/io/dxf_writer.dart';
import 'package:datum/model/document.dart';

double len(DrawingDocument d) {
  final v = d.lines.vertices;
  var s = 0.0;
  for (var i = 0; i + 1 < d.lines.vertexCount; i += 2) {
    final a = i * 6, b = (i + 1) * 6;
    s += math.sqrt(math.pow(v[a] - v[b], 2) + math.pow(v[a + 1] - v[b + 1], 2));
  }
  return s;
}

DrawingDocument docOf(DxfData d) {
  final (l, t) = d.build();
  return DrawingDocument(d.name, l, t, d.insUnits);
}

void main(List<String> args) {
  var ok = 0, bad = 0;
  for (final f in args) {
    try {
      final a = docOf(parseDxf(f));
      final out = writeDxf(a);
      final b = docOf(parseDxfBytes(out, 'x.dxf'));
      final la = len(a), lb = len(b);
      final good = (la - lb).abs() <= la * 0.002 + 1e-6 && a.texts.length == b.texts.length && a.lines.groups.length >= b.lines.groups.length;
      if (good) {
        ok++;
      } else {
        bad++;
        stdout.writeln('${f.split('/').last}: long ${la.toStringAsFixed(2)} → ${lb.toStringAsFixed(2)} · textos ${a.texts.length}→${b.texts.length} · capas ${a.lines.groups.length}→${b.lines.groups.length}');
      }
    } catch (e) {
      bad++;
      stdout.writeln('${f.split('/').last}: ERROR $e');
    }
  }
  stdout.writeln('iguales=$ok distintos=$bad');
}
