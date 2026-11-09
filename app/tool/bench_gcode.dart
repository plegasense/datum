import 'dart:io';

import 'package:dovexa/io/gcode_loader.dart';

Future<void> main(List<String> args) async {
  for (final f in args) {
    final sw = Stopwatch()..start();
    try {
      final d = await loadGcode(f);
      final t = d.build();
      print(
        'OK ${sw.elapsedMilliseconds} ms  ${t.paths.segmentCount} mov. de trabajo  ${t.travels.segmentCount} rápidos  '
        '${t.layerCount} capas  fdm=${t.isFdm}  ${t.bounds.size.map((e) => e.toStringAsFixed(1)).join('x')}  '
        'info=${t.info.length}  ${f.split('/').last}',
      );
      for (final s in t.info.take(4)) {
        print('   $s');
      }
    } catch (e) {
      print('FALLO ${f.split('/').last}: $e');
    }
  }
  exit(0);
}
