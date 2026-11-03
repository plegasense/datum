import 'dart:io';

import 'package:datum/io/gcode_loader.dart';
import 'package:datum/model/toolpath.dart';

Future<void> main(List<String> a) async {
  for (final f in a) {
    final t = (await loadGcode(f)).build();
    final w = t.extrusionWidths();
    stdout.writeln('${f.split('/').last}: boquilla ${t.summary.nozzle} capa ${t.summary.layerHeight} · ' +
        [for (var k = 1; k < w.length; k++) if (w[k] != null) '${kFeatureNames[k]} ${w[k]!.toStringAsFixed(3)}'].join(' · '));
  }
}
