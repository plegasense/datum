import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dovexa/io/threemf_loader.dart';

/// Daña 3MF reales (XML truncado, bytes cambiados o borrados, ZIP cortado) y comprueba que
/// el lector devuelve una malla o un error limpio (nunca un fallo de índice, un tipo roto o un bloqueo).
/// Uso: dart run tool/verify_robust_3mf.dart <carpeta>... 
void main(List<String> args) {
  final files = <File>[];
  for (final a in args) {
    files.addAll(
      Directory(a)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.3mf') && f.lengthSync() < 3 << 20),
    );
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  final rnd = Random(7);
  final tmp = File('${Directory.systemTemp.path}/dovexa_fuzz.3mf');
  var cases = 0, ok = 0, clean = 0;
  final bad = <String>[];
  for (final f in files) {
    final src = f.readAsBytesSync();
    Archive? arc;
    try {
      arc = ZipDecoder().decodeBytes(src);
    } catch (_) {
      continue;
    }
    final variants = <String, Uint8List>{};
    for (final cut in [0.2, 0.5, 0.9]) {
      variants['zip cortado ${(cut * 100).round()}%'] = Uint8List.sublistView(src, 0, (src.length * cut).round());
    }
    for (var v = 0; v < 6; v++) {
      final a = Archive();
      for (final e in arc.files) {
        if (!e.isFile) continue;
        var data = Uint8List.fromList(e.content as List<int>);
        final isModel = e.name.toLowerCase().endsWith('.model') || e.name.endsWith('.config');
        if (isModel && data.isNotEmpty) {
          switch (v) {
            case 0:
              data = Uint8List.sublistView(data, 0, data.length ~/ 3);
            case 1:
              data = Uint8List.sublistView(data, 0, data.length * 9 ~/ 10);
            case 2:
              for (var k = 0; k < 30; k++) {
                data[rnd.nextInt(data.length)] = rnd.nextInt(256);
              }
            case 3:
              data = Uint8List.fromList([
                for (var i = 0; i < data.length; i++)
                  if (rnd.nextInt(100) != 0) data[i],
              ]);
            case 4:
              for (var k = 0; k < 40; k++) {
                data[rnd.nextInt(data.length)] = '0123456789-.e"<>/='.codeUnitAt(rnd.nextInt(18));
              }
            case 5:
              data = Uint8List(0);
          }
        }
        a.addFile(ArchiveFile(e.name, data.length, data));
      }
      variants['xml dañado $v'] = Uint8List.fromList(ZipEncoder().encode(a));
    }
    for (final e in variants.entries) {
      cases++;
      tmp.writeAsBytesSync(e.value);
      final sw = Stopwatch()..start();
      try {
        parse3mf(tmp.path);
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
  stdout.writeln('casos=$cases ok=$ok errorLimpio=$clean inesperados=${bad.length}');
  for (final b in bad.take(25)) {
    stdout.writeln('  $b');
  }
}
