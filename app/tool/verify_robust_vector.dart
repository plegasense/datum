import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:datum/io/hpgl_parser.dart';
import 'package:datum/io/svg_loader.dart';

/// Daña SVG y HPGL reales (cortados, bytes cambiados o borrados) y comprueba que el lector devuelve
/// un dibujo o un error limpio: nunca un fallo de tipo, de índice ni un bloqueo.
/// Uso: SEED=11 dart run tool/verify_robust_vector.dart <carpeta>...
void main(List<String> args) {
  final files = <File>[];
  for (final a in args) {
    files.addAll(
      Directory(a).listSync(recursive: true).whereType<File>().where(
        (f) => RegExp(r'\.(svg|hpgl|plt)$', caseSensitive: false).hasMatch(f.path) && f.lengthSync() < (1 << 20),
      ),
    );
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  final rnd = Random(int.parse(Platform.environment['SEED'] ?? '11'));
  var cases = 0, ok = 0, clean = 0;
  final bad = <String>[];
  final dir = Directory.systemTemp.createTempSync('datum_fzv').path;
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
          for (var k = 0; k < 80; k++) {
            b[rnd.nextInt(b.length)] = rnd.nextInt(256);
          }
        case 2:
          for (var k = 0; k < 60; k++) {
            b[rnd.nextInt(b.length)] = '0123456789-.eE";,<>=MLCZAmlcza() \n'.codeUnitAt(rnd.nextInt(34));
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
        final d = ext == 'svg' ? parseSvg(p) : parseHpgl(p);
        d.build();
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
