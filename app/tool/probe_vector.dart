import 'dart:io';

import 'package:datum/io/hpgl_parser.dart';
import 'package:datum/io/svg_loader.dart';

/// Resume cómo se lee cada SVG / HPGL: dart run tool/probe_vector.dart <archivo|carpeta>...
void main(List<String> args) {
  final files = <String>[];
  for (final a in args) {
    if (FileSystemEntity.isDirectorySync(a)) {
      files.addAll(Directory(a).listSync(recursive: true).whereType<File>().map((f) => f.path).where((p) => RegExp(r'\.(svg|hpgl|plt|hgl|hpg|hp)$', caseSensitive: false).hasMatch(p)));
    } else {
      files.add(a);
    }
  }
  files.sort();
  var ok = 0, bad = 0;
  for (final f in files) {
    final sw = Stopwatch()..start();
    try {
      final d = f.toLowerCase().endsWith('.svg') ? parseSvg(f) : parseHpgl(f);
      final (lines, texts) = d.build();
      stdout.writeln('${f.split('/').last}  ${sw.elapsedMilliseconds} ms  seg=${lines.segmentCount} capas=${d.layers.length} textos=${texts.length} '
          'caja=${d.min.take(2).map((e) => e.toStringAsFixed(1))}..${d.max.take(2).map((e) => e.toStringAsFixed(1))} u=${d.insUnits} '
          '${d.info?.generator ?? ''} avisos=${d.info?.warnings.length}');
      if (Platform.environment.containsKey('VERBOSE')) {
        final v = d.info;
        if (v != null) {
          stdout.writeln('    ${v.format} dibujo=${v.drawMm.toStringAsFixed(0)} mm viaje=${v.travelMm.toStringAsFixed(0)} mm plumas=${v.pens.length} ${v.counts}');
          for (final w in v.warnings) {
            stdout.writeln('    ! $w');
          }
        }
      }
      ok++;
    } catch (e) {
      stdout.writeln('${f.split('/').last}  ERROR ${e.toString().split('\n').first}');
      bad++;
    }
  }
  stdout.writeln('ok=$ok error=$bad');
}
