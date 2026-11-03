import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:datum/io/gltf_loader.dart';
import 'package:datum/io/obj_loader.dart';
import 'package:datum/io/ply_loader.dart';

/// Daña archivos glTF/GLB, OBJ y PLY reales (cortados, bytes cambiados o borrados) y comprueba que
/// cada lector devuelve una malla o un error limpio: nunca un fallo de índice, de tipo o un bloqueo.
/// Uso: dart run tool/verify_robust_mesh.dart <carpeta>...
void main(List<String> args) {
  final files = <File>[];
  for (final a in args) {
    files.addAll(
      Directory(a).listSync(recursive: true).whereType<File>().where(
        (f) => RegExp(r'\.(glb|gltf|obj|ply)$', caseSensitive: false).hasMatch(f.path) && f.lengthSync() < (2 << 20),
      ),
    );
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  final rnd = Random(int.parse(Platform.environment['SEED'] ?? '11'));
  var cases = 0, ok = 0, clean = 0;
  final bad = <String>[];
  for (final f in files) {
    final src = f.readAsBytesSync();
    final ext = f.path.split('.').last.toLowerCase();
    final dir = Directory.systemTemp.createTempSync('datum_fz').path;
    // los archivos asociados (texturas, bin) se enlazan para que el lector los encuentre
    for (final sib in f.parent.listSync().whereType<File>()) {
      final n = sib.path.split('/').last;
      if (!n.toLowerCase().endsWith(ext)) {
        try {
          File('$dir/$n').createSync();
          sib.copySync('$dir/$n');
        } catch (_) {}
      }
    }
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
          for (var k = 0; k < 60; k++) {
            b[rnd.nextInt(b.length)] = rnd.nextInt(256);
          }
        case 2:
          for (var k = 0; k < 40; k++) {
            b[rnd.nextInt(b.length)] = '0123456789-.e"{}[],:/ \n'.codeUnitAt(rnd.nextInt(23));
          }
        case 3:
          variants['borrado 1%'] = Uint8List.fromList([
            for (var i = 0; i < src.length; i++)
              if (rnd.nextInt(100) != 0) src[i],
          ]);
      }
      if (v < 3) variants['bytes $v'] = b;
    }
    // también se dañan los datos binarios hermanos de un .gltf (donde viven los bloques Draco/meshopt)
    final bins = [
      for (final sib in f.parent.listSync().whereType<File>())
        if (ext == 'gltf' && sib.path.endsWith('.bin')) sib,
    ];
    final binVariants = <String, (File, Uint8List)>{};
    for (final b in bins) {
      final raw = b.readAsBytesSync();
      if (raw.length > (4 << 20)) continue;
      for (var v = 0; v < 6; v++) {
        final m = Uint8List.fromList(raw);
        if (v < 3) {
          for (var k = 0; k < 8 + v * 40; k++) {
            m[rnd.nextInt(m.length)] = rnd.nextInt(256);
          }
          binVariants['bin bytes $v'] = (b, m);
        } else if (v == 3) {
          binVariants['bin cortado'] = (b, Uint8List.sublistView(m, 0, m.length ~/ 2));
        } else if (v == 4) {
          // un solo byte cambiado, lejos de la cabecera
          m[m.length ~/ 2] ^= 0xFF;
          binVariants['bin 1 byte'] = (b, m);
        }
      }
    }
    for (final e in [
      ...variants.entries.map((e) => (e.key, e.value, null as File?)),
      ...binVariants.entries.map((e) => (e.key, Uint8List.fromList(src), e.value.$1)),
    ]) {
      cases++;
      final p = '$dir/fuzz.$ext';
      File(p).writeAsBytesSync(e.$2);
      if (e.$3 != null) {
        File('$dir/${e.$3!.path.split('/').last}').writeAsBytesSync(binVariants[e.$1]!.$2);
      }
      final sw = Stopwatch()..start();
      try {
        if (ext == 'obj') {
          parseObj(p);
        } else if (ext == 'ply') {
          parsePly(p);
        } else {
          parseGltf(p);
        }
        ok++;
      } on FormatException {
        clean++;
      } on Exception {
        clean++;
      } catch (err) {
        bad.add('${f.path.split('/').last} · ${e.$1}: ${err.runtimeType} $err');
      }
      if (sw.elapsedMilliseconds > 8000) bad.add('${f.path.split('/').last} · ${e.$1}: lento ${sw.elapsedMilliseconds} ms');
    }
    try {
      Directory(dir).deleteSync(recursive: true);
    } catch (_) {}
  }
  stdout.writeln('casos=$cases ok=$ok errorLimpio=$clean inesperados=${bad.length}');
  for (final b in bad.take(30)) {
    stdout.writeln('  $b');
  }
}
