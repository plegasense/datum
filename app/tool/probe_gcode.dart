import 'dart:io';

import 'package:datum/io/bgcode_loader.dart';
import 'package:datum/io/gcode_loader.dart';
import 'package:datum/model/print_summary.dart';

Future<void> main(List<String> args) async {
  for (final f in args) {
    final sw = Stopwatch()..start();
    final d = f.endsWith('.bgcode') ? await loadBgcode(f) : await loadGcode(f);
    final t = d.build();
    final s = t.summary;
    final comp = t.stats.layerSeconds.fold(0.0, (a, b) => a + b);
    print('== ${f.split('/').last}  ${sw.elapsedMilliseconds} ms');
    print(' slicer=${s.slicer} printer=${s.printer}');
    print(
      ' tiempo=${s.seconds == null ? '-' : formatDuration(s.seconds!)} (laminador=${s.secondsFromSlicer}) teórico=${formatDuration(comp)} escala=${s.timeScale.toStringAsFixed(2)}',
    );
    for (final fl in s.filaments) {
      print(
        '  filamento ${fl.index}: ${fl.mm.toStringAsFixed(0)} mm ${fl.grams.toStringAsFixed(1)} g ${fl.type} #${fl.color?.toRadixString(16)} noz=${fl.nozzleTemp} cama=${fl.bedTemp}',
      );
    }
    print(
      ' medido por E: ${t.stats.toolMm.where((e) => e > 0).map((e) => e.toStringAsFixed(0)).toList()} mm, retracciones=${t.stats.retractions}',
    );
    print(
      ' capa=${s.layerHeight} 1ª=${s.firstLayerHeight} boquilla=${s.nozzle} relleno=${s.infill} paredes=${s.walls} soportes=${s.supports} coste=${s.cost}',
    );
    print(
      ' temps M104/M140: ${t.stats.nozzleTemps} / ${t.stats.bedTemps} ventilador=${s.fanPercent}%',
    );
    final ft = t.stats.featureSeconds;
    print(
      ' reparto: ${[for (var i = 0; i < ft.length; i++)
        if (ft[i] > 0) '${i}:${(ft[i] * 100 / comp).toStringAsFixed(0)}%']} viaje=${(t.stats.travelSeconds * 100 / comp).toStringAsFixed(0)}%',
    );
    print(' extras=${s.extras}');
  }
  exit(0);
}
