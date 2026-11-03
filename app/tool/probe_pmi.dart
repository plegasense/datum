import 'package:datum/io/loader.dart';
import 'package:datum/model/units.dart';

Future<void> main(List<String> a) async {
  for (final path in a) {
    final s = await loadScene(path);
    final cad = s.cad!;
    final u = LengthUnit.fromFile(cad.unit);
    print(
      '${path.split('/').last}: ${cad.pmi.length} anotaciones (unidad ${cad.unit})',
    );
    var gr = 0;
    for (final p in cad.pmi) {
      if (p.hasGraphic) gr++;
    }
    print('  con gráfico: $gr');
    for (final p in cad.pmi.take(14)) {
      print(
        '  [${p.kind.name}] ${p.name}: ${p.describe(u)}  refs=${p.refs.length}  seg=${p.segments.length ~/ 6}  v=${p.v.take(7).map((x) => x.toStringAsFixed(3)).toList()}',
      );
    }
    s.dispose();
  }
}
