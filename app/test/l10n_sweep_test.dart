import 'dart:io';

import 'package:datum/io/loader.dart';
import 'package:datum/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

/// Abre en inglés los archivos de muestra y lista los `tr()` sin traducción. Solo con
/// `L10N_SWEEP=<carpeta>` (no forma parte de la suite normal): flutter test test/l10n_sweep_test.dart
void main() {
  final dir = Platform.environment['L10N_SWEEP'];
  test('barrido en inglés', () async {
    L.lang = 'en';
    var n = 0, err = 0;
    for (final f in Directory(dir!).listSync(recursive: true).whereType<File>()) {
      final ext = f.path.contains('.') ? f.path.split('.').last.toLowerCase() : '';
      if (!kSupportedExtensions.contains(ext) || f.lengthSync() > (30 << 20)) continue;
      n++;
      try {
        await loadDocument(f.path);
      } catch (e) {
        err++;
        final s = '$e';
        if (RegExp(r'[áéíóúñ¿¡]| de la | no se ').hasMatch(s)) {
          // ignore: avoid_print
          print('ERROR ES: ${f.path.split('/').last}: $s');
        }
      }
    }
    // ignore: avoid_print
    print('archivos=$n con_error=$err');
    for (final m in L.missing.toList()..sort()) {
      // ignore: avoid_print
      print('SIN TRADUCCIÓN: $m');
    }
    L.lang = 'es';
  }, skip: dir == null, timeout: const Timeout(Duration(minutes: 25)));
}
