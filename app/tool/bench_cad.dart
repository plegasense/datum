// Prueba masiva de STEP/IGES reales: tiempos, recuentos y fallos.
//   dart run tool/bench_cad.dart "/ruta/a/carpeta" [maxMB]
import 'dart:io';

import 'package:datum/io/loader.dart';
import 'package:datum/model/brep.dart';

Future<void> main(List<String> args) async {
  final root = Directory(args.first);
  final maxMb = args.length > 1 ? double.parse(args[1]) : 200;
  final files = [
    for (final f in root.listSync(recursive: true))
      if (f is File &&
          RegExp(
            r'\.(step|stp|iges|igs)$',
            caseSensitive: false,
          ).hasMatch(f.path) &&
          f.lengthSync() < maxMb * 1e6)
        f,
  ]..sort((a, b) => a.lengthSync().compareTo(b.lengthSync()));
  var ok = 0, bad = 0;
  for (final f in files) {
    final mb = f.lengthSync() / 1e6;
    final sw = Stopwatch()..start();
    try {
      final s = await loadScene(f.path);
      final tLoad = sw.elapsedMilliseconds;
      sw.reset();
      var faces = 0, edges = 0, tris = 0;
      for (final p in s.parts) {
        faces += p.brep?.faceCount ?? 0;
        edges += p.brep?.edgeCount ?? 0;
        tris += p.mesh.triangleCount;
      }
      var holes = 0;
      final cad = s.cad;
      if (cad != null) {
        for (final p in s.parts) {
          holes += findHoles(cad, p.id, p.brep!.faceCount).length;
        }
      }
      final tHoles = sw.elapsedMilliseconds;
      sw.reset();
      var vol = 0.0;
      if (cad != null) {
        for (final p in s.parts.take(50)) {
          vol += cad.props(p.id).volume;
        }
      }
      final tProps = sw.elapsedMilliseconds;
      stdout.writeln(
        'OK   ${mb.toStringAsFixed(2).padLeft(7)} MB  carga ${tLoad.toString().padLeft(6)} ms  '
        'piezas ${s.parts.length.toString().padLeft(4)}  inst ${s.instances(onlyVisible: false).length.toString().padLeft(5)}  '
        'caras $faces  aristas $edges  tri $tris  agujeros $holes (${tHoles} ms)  vol (${tProps} ms)  unidad ${cad?.unit}  ${f.path.split('/').last}',
      );
      s.dispose();
      ok++;
    } catch (e) {
      stdout.writeln(
        'FALLO ${mb.toStringAsFixed(2)} MB ${f.path.split('/').last} -> $e',
      );
      bad++;
    }
  }
  stdout.writeln('--- $ok correctos, $bad fallos');
  exit(bad == 0 ? 0 : 1);
}
