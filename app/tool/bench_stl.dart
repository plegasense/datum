// Mide la velocidad del lector de STL. Uso: dart run tool/bench_stl.dart archivo.stl
import 'dart:io';

import 'package:datum/io/stl_loader.dart';

Future<void> main(List<String> args) async {
  for (final path in args) {
    final size = File(path).lengthSync();
    final sw = Stopwatch()..start();
    final mesh = await loadStl(path);
    sw.stop();
    final mb = size / 1048576;
    print(
      '${path.split('/').last}: ${mb.toStringAsFixed(1)} MB, ${mesh.triangleCount} triángulos, '
      '${sw.elapsedMilliseconds} ms (${(mb / (sw.elapsedMilliseconds / 1000)).toStringAsFixed(0)} MB/s)',
    );
  }
}
