import 'dart:io';

import 'package:datum/io/dxf_loader.dart';

Future<void> main(List<String> args) async {
  for (final f in args) {
    final sw = Stopwatch()..start();
    try {
      final d = await loadDxf(f);
      final (set, texts) = d.build();
      print(
        'OK ${sw.elapsedMilliseconds} ms  ${set.segmentCount} segmentos  ${set.groups.length} capas  '
        '${texts.length} textos  ${set.bounds.size.map((e) => e.toStringAsFixed(1)).join('x')}  ${f.split('/').last}',
      );
    } catch (e) {
      print('FALLO ${f.split('/').last}: $e');
    }
  }
  exit(0);
}
