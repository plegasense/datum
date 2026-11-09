import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:dovexa/io/cad_loader.dart';
import 'package:dovexa/src/dovexa_ffi.dart';
import 'package:ffi/ffi.dart';

/// Tiempos de lectura de Open CASCADE por fase (misma librería nativa que la app).
Future<void> main(List<String> args) async {
  for (final f in args) {
    final sw = Stopwatch()..start();
    final t = await Isolate.run(() {
      parseCad(f, cacheDir: '/tmp/dovexa_cad_test');
      final p = malloc<Double>(5);
      dovexaCadTiming(p);
      final r = [for (var i = 0; i < 5; i++) p[i]];
      malloc.free(p);
      return r;
    });
    print(
      '${f.split('/').last}: total ${sw.elapsedMilliseconds} ms · lectura ${t[0].round()} · conversión ${t[1].round()} · árbol ${t[2].round()} · teselado ${t[3].round()} · PMI ${t[4].round()}',
    );
  }
  exit(0);
}
