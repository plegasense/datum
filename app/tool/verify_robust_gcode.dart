import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:datum/io/bgcode_loader.dart';
import 'package:datum/io/gcode_loader.dart';

/// Trunca y corrompe archivos reales: debe terminar siempre (resultado o error claro), sin colgarse.
Future<void> main(List<String> args) async {
  final rnd = Random(7);
  var ok = 0, err = 0, bad = 0;
  var slowest = 0;
  for (final f in args) {
    final bytes = File(f).readAsBytesSync();
    if (bytes.length > 12 * 1024 * 1024) continue;
    for (var k = 0; k < 6; k++) {
      Uint8List b;
      if (k < 3) {
        b = Uint8List.sublistView(
          bytes,
          0,
          max(1, (bytes.length * (k + 1) / 4).floor()),
        );
      } else {
        b = Uint8List.fromList(bytes);
        for (var j = 0; j < 40; j++) {
          b[rnd.nextInt(b.length)] = rnd.nextInt(256);
        }
      }
      final sw = Stopwatch()..start();
      try {
        final d = f.endsWith('.bgcode') ? null : parseGcode(b, 'x.gcode');
        d?.build();
        ok++;
      } on Exception {
        err++;
      } catch (e) {
        bad++;
        print('FALLO INESPERADO ${f.split('/').last} k=$k: $e');
      }
      slowest = max(slowest, sw.elapsedMilliseconds);
    }
  }
  print('OK=$ok error_claro=$err inesperados=$bad más_lento=${slowest}ms');
  exit(bad == 0 ? 0 : 1);
}
