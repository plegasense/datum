import 'dart:convert';
import 'dart:io';

import 'package:dovexa/io/svg_loader.dart';

/// Caja de cada SVG (en px de 96 ppp, y hacia abajo) para compararla con un navegador.
/// Uso: dart run tool/bbox_vector.dart <lista.json> <carpeta-vector> <salida.json>
void main(List<String> args) {
  final list = (jsonDecode(File(args[0]).readAsStringSync()) as List).cast<Map<String, dynamic>>();
  final out = <Map<String, dynamic>>[];
  for (final r in list) {
    final path = '${args[1]}/${r['f']}';
    try {
      final d = parseSvg(path);
      final k = d.insUnits == 4 ? 96 / 25.4 : 1.0;
      out.add({'f': r['f'], 'b': [d.min[0] * k, -d.max[1] * k, d.max[0] * k, -d.min[1] * k], 'u': d.insUnits});
    } catch (e) {
      out.add({'f': r['f'], 'err': e.toString().split('\n').first});
    }
  }
  File(args[2]).writeAsStringSync(jsonEncode(out));
}
