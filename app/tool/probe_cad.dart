import 'package:datum/io/loader.dart';
import 'package:datum/model/brep.dart';

Future<void> main(List<String> a) async {
  final s = await loadScene(a.first);
  final cad = s.cad!;
  for (final p in s.parts) {
    print('${p.name}: caras ${p.brep!.faceCount} aristas ${p.brep!.edgeCount}');
    for (var f = 0; f < p.brep!.faceCount && f < 60; f++) {
      final i = cad.faceInfo(p.id, f);
      print(
        '  cara $f ${i.kind} área ${i.area.toStringAsFixed(1)} r ${i.radius.toStringAsFixed(2)}',
      );
    }
  }
}
