import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:datum/io/e57_loader.dart';
import 'package:datum/io/las_loader.dart';
import 'package:datum/io/laz_glue.dart';
import 'package:datum/io/pointcloud_loader.dart';

/// Daña nubes reales (LAS, LAZ, E57, PCD, XYZ, PTS) y comprueba que el lector devuelve una nube o un
/// error limpio: nunca un fallo de índice o de tipo, ni un bloqueo. Uso: SEED=11 dart run tool/verify_robust_cloud.dart <carpeta>...
void main(List<String> args) {
  final files = <File>[];
  for (final a in args) {
    files.addAll(
      Directory(a).listSync(recursive: true).whereType<File>().where(
        (f) => RegExp(r'\.(las|laz|e57|pcd|xyz|pts)$', caseSensitive: false).hasMatch(f.path) && f.lengthSync() < (4 << 20),
      ),
    );
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  final rnd = Random(int.parse(Platform.environment['SEED'] ?? '11'));
  var cases = 0, ok = 0, clean = 0;
  final bad = <String>[];
  final dir = Directory.systemTemp.createTempSync('datum_fzc').path;
  for (final f in files) {
    final src = f.readAsBytesSync();
    if (src.isEmpty) continue;
    final ext = f.path.split('.').last.toLowerCase();
    final variants = <String, Uint8List>{};
    for (final cut in [0.1, 0.5, 0.9]) {
      variants['cortado ${(cut * 100).round()}%'] = Uint8List.sublistView(src, 0, (src.length * cut).round());
    }
    for (var v = 0; v < 4; v++) {
      final b = Uint8List.fromList(src);
      switch (v) {
        case 0:
          for (var k = 0; k < 20; k++) {
            b[rnd.nextInt(b.length)] = rnd.nextInt(256);
          }
        case 1:
          for (var k = 0; k < 120; k++) {
            b[rnd.nextInt(b.length)] = rnd.nextInt(256);
          }
        case 2:
          // se ataca la cabecera, donde viven las longitudes y los desplazamientos
          for (var k = 0; k < 12; k++) {
            b[rnd.nextInt(min(b.length, 400))] = rnd.nextInt(256);
          }
        case 3:
          variants['borrado 1%'] = Uint8List.fromList([
            for (var i = 0; i < src.length; i++)
              if (rnd.nextInt(100) != 0) src[i],
          ]);
      }
      if (v < 3) variants['bytes $v'] = b;
    }
    for (final e in variants.entries) {
      cases++;
      final p = '$dir/fuzz.$ext';
      File(p).writeAsBytesSync(e.value);
      final sw = Stopwatch()..start();
      try {
        switch (ext) {
          case 'las':
            parseLas(p);
          case 'laz':
            parseLaz(p);
          case 'e57':
            parseE57(p);
          case 'pcd':
            parsePcd(p);
          default:
            parseXyz(p);
        }
        ok++;
      } on FormatException {
        clean++;
      } on Exception {
        clean++;
      } catch (err) {
        bad.add('${f.path.split('/').last} · ${e.key}: ${err.runtimeType} $err');
      }
      if (sw.elapsedMilliseconds > 8000) bad.add('${f.path.split('/').last} · ${e.key}: lento ${sw.elapsedMilliseconds} ms');
    }
  }
  Directory(dir).deleteSync(recursive: true);
  stdout.writeln('casos=$cases leídos=$ok errores limpios=$clean inesperados=${bad.length}');
  for (final b in bad.take(30)) {
    stdout.writeln('  $b');
  }
  exit(bad.isEmpty ? 0 : 1);
}
