import 'dart:io';

import 'package:datum/io/threemf_loader.dart';
import 'package:datum/model/threemf.dart';

/// Resume cómo se lee cada 3MF: dart run tool/probe_3mf.dart <archivo|carpeta>...
void main(List<String> args) {
  final files = <String>[];
  for (final a in args) {
    if (FileSystemEntity.isDirectorySync(a)) {
      files.addAll(
        Directory(a)
            .listSync(recursive: true)
            .whereType<File>()
            .map((f) => f.path)
            .where((p) => p.toLowerCase().endsWith('.3mf')),
      );
    } else {
      files.add(a);
    }
  }
  files.sort();
  var ok = 0, bad = 0;
  for (final f in files) {
    final sw = Stopwatch()..start();
    try {
      final d = parse3mf(f);
      final p = d.extra as ThreeMfProject;
      var tris = 0;
      for (final o in p.objects) {
        tris += o.triangles;
      }
      final fil = p.filaments.map((x) => '#${x.color.toRadixString(16).substring(2)}').join(',');
      stdout.writeln(
        '${f.split('/').last}  ${sw.elapsedMilliseconds} ms  ${p.generator.isEmpty ? '?' : p.generator}  '
        'obj=${p.objects.length} placas=${p.plates.length} tri=$tris mallas=${d.meshes.length} nodos=${d.nodes.length} '
        'fil=[$fil] ${p.sliced ? 'LAMINADO ' : ''}${p.notes.isEmpty ? '' : p.notes}',
      );
      ok++;
    } catch (e) {
      stdout.writeln('${f.split('/').last}  ERROR $e');
      bad++;
    }
  }
  stdout.writeln('ok=$ok error=$bad');
}
