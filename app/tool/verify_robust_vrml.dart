import 'dart:io';
import 'dart:math';

import 'package:dovexa/io/vrml_loader.dart';

/// Daña VRML/X3D reales (cortados, caracteres cambiados, líneas borradas) y comprueba que el lector
/// devuelve una escena o un error limpio. Uso: SEED=11 dart run tool/verify_robust_vrml.dart <carpeta>...
void main(List<String> args) {
  final files = <File>[];
  for (final a in args) {
    files.addAll(
      Directory(a).listSync(recursive: true).whereType<File>().where(
        (f) => RegExp(r'\.(wrl|x3d)$', caseSensitive: false).hasMatch(f.path) && f.lengthSync() < (1 << 20),
      ),
    );
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  final rnd = Random(int.parse(Platform.environment['SEED'] ?? '11'));
  var cases = 0, ok = 0, clean = 0;
  final bad = <String>[];
  final dir = Directory.systemTemp.createTempSync('dovexa_fzw').path;
  for (final f in files) {
    final src = f.readAsStringSync();
    if (src.isEmpty) continue;
    final ext = f.path.split('.').last.toLowerCase();
    final variants = <String, String>{};
    for (final cut in [0.1, 0.5, 0.9]) {
      variants['cortado ${(cut * 100).round()}%'] = src.substring(0, (src.length * cut).round());
    }
    for (var v = 0; v < 5; v++) {
      final b = src.codeUnits.toList();
      switch (v) {
        case 0:
          for (var k = 0; k < 20; k++) {
            b[rnd.nextInt(b.length)] = 32 + rnd.nextInt(90);
          }
        case 1:
          for (var k = 0; k < 60; k++) {
            b[rnd.nextInt(b.length)] = '{}[]-.0123456789e"# \n'.codeUnitAt(rnd.nextInt(21));
          }
        case 2:
          // se borran llaves y corchetes
          for (var i = 0; i < b.length; i++) {
            if ((b[i] == 123 || b[i] == 125 || b[i] == 91 || b[i] == 93) && rnd.nextInt(40) == 0) b[i] = 32;
          }
        case 3:
          // números enormes y NaN
          final t = src.replaceAllMapped(RegExp(r'\b\d+\.\d+\b'), (m) => rnd.nextInt(30) == 0 ? '1e308' : m.group(0)!);
          variants['números enormes'] = t;
        case 4:
          final lines = src.split('\n')..removeWhere((_) => rnd.nextInt(25) == 0);
          variants['líneas borradas'] = lines.join('\n');
      }
      if (v < 3) variants['caracteres $v'] = String.fromCharCodes(b);
    }
    for (final e in variants.entries) {
      cases++;
      final p = '$dir/fuzz.$ext';
      File(p).writeAsStringSync(e.value);
      final sw = Stopwatch()..start();
      try {
        parseVrml(p);
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
