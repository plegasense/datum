import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dovexa/io/stl_loader.dart';
import 'package:dovexa/model/mesh_check.dart';

/// STL truncados y corrompidos: debe terminar siempre (malla o error claro), sin colgarse.
Future<void> main(List<String> args) async {
  final rnd = Random(11);
  var ok = 0, err = 0, bad = 0, slowest = 0;
  final dir = Directory.systemTemp.createTempSync('dovexa_robust_stl');
  for (final f in args) {
    final bytes = File(f).readAsBytesSync();
    if (bytes.length < 2 || bytes.length > 6 * 1024 * 1024) continue;
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
        for (var j = 0; j < 60; j++) {
          b[rnd.nextInt(b.length)] = rnd.nextInt(256);
        }
      }
      final tmp = File('${dir.path}/t.stl')..writeAsBytesSync(b);
      final sw = Stopwatch()..start();
      try {
        final m = await loadStl(tmp.path);
        final r = await checkMesh(m.vertices);
        if (r.triangles != m.triangleCount)
          throw StateError('recuento distinto');
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
