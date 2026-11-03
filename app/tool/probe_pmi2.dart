import 'package:datum/io/loader.dart';
import 'package:datum/model/pmi.dart';
import 'package:datum/model/units.dart';

Future<void> main(List<String> a) async {
  for (final path in a) {
    final s = await loadScene(path);
    final cad = s.cad!;
    final u = LengthUnit.fromFile(cad.unit);
    final c = <PmiKind, int>{};
    for (final p in cad.pmi) {
      c[p.kind] = (c[p.kind] ?? 0) + 1;
    }
    print('${path.split('/').last}: $c');
    for (final p
        in cad.pmi.where((p) => p.kind != PmiKind.dimension).take(10)) {
      print(
        '  [${p.kind.name}] ${p.name}: ${p.describe(u)} refs=${p.refs.length} seg=${p.segments.length ~/ 6}',
      );
    }
    s.dispose();
  }
}
