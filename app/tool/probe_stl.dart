import 'dart:io';

import 'package:datum/io/stl_loader.dart';
import 'package:datum/model/mesh_check.dart';

/// Revisa en lote STL reales: carga, informe de malla y tiempos.
///   dart run tool/probe_stl.dart carpeta_o_archivos...
Future<void> main(List<String> args) async {
  final files = <File>[];
  for (final a in args) {
    if (FileSystemEntity.isDirectorySync(a)) {
      files.addAll(
        Directory(a).listSync().whereType<File>().where(
          (f) => f.path.toLowerCase().endsWith('.stl'),
        ),
      );
    } else {
      files.add(File(a));
    }
  }
  files.sort((a, b) => a.lengthSync().compareTo(b.lengthSync()));
  var ok = 0, bad = 0;
  for (final f in files) {
    final name = f.path.split('/').last;
    final sw = Stopwatch()..start();
    try {
      final m = await loadStl(f.path);
      final tLoad = sw.elapsedMilliseconds;
      final meta = stlMetaOf[m]!;
      final r = await checkMesh(m.vertices);
      final size = [
        for (var k = 0; k < 3; k++)
          (m.bounds.max[k] - m.bounds.min[k]).toStringAsFixed(1),
      ].join('×');
      stdout.writeln(
        'OK ${(f.lengthSync() / 1e6).toStringAsFixed(2).padLeft(6)} MB '
        '${meta.binary ? 'bin' : 'asc'} carga ${tLoad.toString().padLeft(5)} ms '
        'revisión ${r.milliseconds.toString().padLeft(5)} ms  tri ${r.triangles} '
        'cascos ${r.shells.length} '
        '${r.watertight ? 'ESTANCA' : 'abiertas ${r.boundaryEdges}/nm ${r.nonManifoldEdges}/ori ${r.inconsistentEdges}'} '
        'deg ${r.degenerate} dup ${r.duplicates} vol ${r.volume.toStringAsFixed(1)} '
        'tam $size  $name'
        '${meta.colored ? '  [color]' : ''}${meta.skipped > 0 ? '  [${meta.skipped} no finitos]' : ''}',
      );
      ok++;
    } catch (e) {
      stdout.writeln('FALLO $name -> $e');
      bad++;
    }
  }
  stdout.writeln('--- $ok correctos, $bad fallos');
  exit(0);
}
