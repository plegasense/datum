import 'package:dovexa/io/loader.dart';
import 'package:dovexa/model/document.dart';
import 'package:dovexa/model/drawing_stats.dart';
import 'package:dovexa/model/shapes.dart';

Future<void> main(List<String> a) async {
  final d = await loadDocument(a.first) as DrawingDocument;
  final shapes = buildShapes(d.lines);
  print(
    'capas: ${d.lines.groups.map((g) => '${g.name}(${g.firstVertex},${g.vertexCount})').toList()}',
  );
  for (final s in shapes) {
    print(
      '  shape ${s.kind.name} grupo ${s.group} cerrado ${s.closed} puntos ${s.pointCount} long ${s.length.toStringAsFixed(3)} area ${s.area.toStringAsFixed(2)}',
    );
  }
  final an = analyzeDrawing(shapes, d.lines);
  for (final c in an.contours) {
    print(
      '  contorno grupo ${c.group} cerrado ${c.closed} hueco ${c.isHole} long ${c.length.toStringAsFixed(3)} area ${c.area.toStringAsFixed(2)} partes ${c.parts.length}',
    );
  }
}
