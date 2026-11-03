import 'package:datum/io/gcode_loader.dart';

Future<void> main(List<String> a) async {
  for (final f in a) {
    final t = (await loadGcode(f)).build();
    print(
      '${f.split('/').last}: ${t.layerCount} capas z0=${t.layerZ.first} zN=${t.layerZ.last}',
    );
  }
}
